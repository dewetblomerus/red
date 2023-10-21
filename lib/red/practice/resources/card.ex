defmodule Red.Practice.Card do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define_for Red.Practice

    define :create, action: :create

    define :next, action: :next
    define :oldest_untried_card, action: :oldest_untried_card
  end

  actions do
    defaults [:read, :update]

    create :create do
      change relate_actor(:user)
    end

    read :next do
      get? true

      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(retry_at < now() and user_id == ^actor(:id))

      prepare fn query, context ->
        Ash.Query.after_action(query, fn
          query, [] ->
            dbg("No cards found with retry_at < now")
            Red.Practice.Card.oldest_untried_card(actor: context.actor)

          _query, results ->
            dbg("A card was found with retry_at < now")
            {:ok, results}
        end)
      end
    end

    read :oldest_untried_card do
      prepare build(limit: 1, sort: [created_at: :asc])

      filter expr(is_nil(retry_at) and user_id == ^actor(:id))
    end

    update :try do
      accept [:tried_spelling]
      argument(:tried_spelling, :string, allow_nil?: false)
      manual Red.Practice.Card.Try
    end
  end

  attributes do
    integer_primary_key :id

    attribute :word, :string, allow_nil?: false
    attribute :tried_at, :utc_datetime, allow_nil?: true
    attribute :retry_at, :utc_datetime, allow_nil?: true
    attribute :correct_streak, :integer, allow_nil?: false, default: 0

    create_timestamp :created_at
    create_timestamp :updated_at
  end

  identities do
    identity :unique_word, [:word, :user_id]
  end

  relationships do
    belongs_to :user, Red.Accounts.User,
      attribute_writable?: true,
      attribute_type: :integer,
      allow_nil?: false
  end

  postgres do
    table "cards"
    repo Red.Repo
  end
end

defmodule Red.Practice.Card.Try do
  use Ash.Resource.ManualUpdate
  @interval_unit :minute

  def update(changeset, opts, context) do
    is_correct? = changeset.data.word == changeset.arguments.tried_spelling

    suggested_interval =
      calculate_suggested_interval(
        changeset.data.retry_at,
        changeset.data.tried_at
      )

    actual_interval =
      calculate_actual_interval(changeset.data.tried_at)

    correct_streak =
      if is_correct? do
        changeset.data.correct_streak + 1
      else
        0
      end

    new_interval = calculate_interval(is_correct?, suggested_interval, actual_interval)

    now = NaiveDateTime.utc_now()

    params = %{
      correct_streak: correct_streak,
      retry_at: NaiveDateTime.add(now, new_interval, @interval_unit),
      tried_at: now
    }

    changeset
    |> Ash.Changeset.for_update(:update, params)
    |> Red.Practice.update()
  end

  defp calculate_suggested_interval(retry_at, tried_at)
       when is_nil(retry_at) or is_nil(tried_at) do
    0
  end

  defp calculate_suggested_interval(retry_at, tried_at) do
    NaiveDateTime.diff(
      retry_at,
      tried_at,
      @interval_unit
    )
  end

  def calculate_actual_interval(nil), do: 0

  def calculate_actual_interval(tried_at) do
    NaiveDateTime.diff(
      NaiveDateTime.utc_now(),
      tried_at,
      @interval_unit
    )
  end

  defp calculate_interval(true, 0, _) do
    1
  end

  defp calculate_interval(true, suggested_interval, actual_interval)
       when suggested_interval > 0 and actual_interval > 0 do
    if actual_interval > suggested_interval * 2 do
      actual_interval
    else
      suggested_interval * 2
    end
  end

  defp calculate_interval(false, _, _), do: 0
end
