defmodule Red.Practice.Card.Try do
  use Ash.Resource.ManualUpdate
  @interval_unit :minute

  def update(changeset, _opts, _context) do
    is_correct? = changeset.data.word == changeset.arguments.tried_spelling

    previous_interval =
      get_previous_interval(
        changeset.data.retry_at,
        changeset.data.tried_at
      )

    actual_interval =
      get_real_interval(changeset.data.tried_at)

    correct_streak =
      if is_correct? do
        changeset.data.correct_streak + 1
      else
        0
      end

    new_interval_params = %{
      actual_interval: actual_interval,
      correct_streak: correct_streak,
      is_correct?: is_correct?,
      previous_interval: previous_interval,
      tried_before: !is_nil(changeset.data.tried_at)
    }

    new_interval =
      get_new_interval(new_interval_params)

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

  defp get_previous_interval(retry_at, tried_at)
       when is_nil(retry_at) or is_nil(tried_at) do
    0
  end

  defp get_previous_interval(retry_at, tried_at) do
    NaiveDateTime.diff(
      retry_at,
      tried_at,
      @interval_unit
    )
  end

  def get_real_interval(nil), do: 0

  def get_real_interval(tried_at) do
    NaiveDateTime.diff(
      NaiveDateTime.utc_now(),
      tried_at,
      @interval_unit
    )
  end

  def get_new_interval(%{is_correct?: false}), do: 0

  def get_new_interval(%{tried_before: false}) do
    1440
  end

  def get_new_interval(%{
        actual_interval: actual_interval,
        previous_interval: previous_interval
      })
      when previous_interval > 1400 and actual_interval > 0 do
    if actual_interval > previous_interval * 2 do
      min(actual_interval, previous_interval * 3)
    else
      previous_interval * 2
    end
  end

  def get_new_interval(%{correct_streak: 1}), do: 0
  def get_new_interval(%{correct_streak: 2}), do: 1
  def get_new_interval(%{correct_streak: 3}), do: 2
  def get_new_interval(%{correct_streak: 4}), do: 4

  def get_new_interval(%{correct_streak: correct_streak})
      when correct_streak > 4 do
    1440
  end
end
