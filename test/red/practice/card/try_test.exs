defmodule Red.Practice.Card.TryTest do
  use ExUnit.Case, async: true
  alias Red.Practice.Card.Try

  # params = %{
  #   actual_interval: 5,
  #   correct_streak: 0,
  #   is_correct?: true,
  #   previous_interval: 1,
  #   tried_before: false
  # }

  describe "get_new_interval/1 new cards" do
    test "move to learning when wrong" do
      params = %{
        is_correct?: false,
        tried_before: false
      }

      assert Try.get_new_interval(params) === 0
    end

    test "move to review when correct on first try" do
      params = %{
        is_correct?: true,
        tried_before: false
      }

      assert Try.get_new_interval(params) === 1440 * 3
    end

    test "increases the interval when correct again" do
      0..10
      |> Enum.each(fn correct_streak ->
        params = %{
          is_correct?: true,
          actual_interval: 1440 * 3,
          correct_streak: correct_streak,
          previous_interval: 1440 * 3
        }

        assert Try.get_new_interval(params) === 10800
      end)
    end
  end

  describe "get_new_interval/1 learning cards" do
    test "schedules a retry when wrong" do
      assert Try.get_new_interval(%{is_correct?: false}) == 0
    end

    test "schedules an immediate retry on 1st correct try" do
      params = %{
        is_correct?: true,
        correct_streak: 1,
        previous_interval: 0
      }

      assert Try.get_new_interval(params) == 0
    end

    test "schedules a one-minute retry on 2nd correct try" do
      params = %{
        is_correct?: true,
        correct_streak: 2,
        previous_interval: 0
      }

      assert Try.get_new_interval(params) == 1
    end

    test "schedules a 10-minute retry on 3rd correct try" do
      params =
        %{
          is_correct?: true,
          correct_streak: 3,
          previous_interval: 1
        }

      assert Try.get_new_interval(params) == 10
    end

    test "promotes to review on 4 or more correct tries" do
      4..10
      |> Enum.each(fn correct_streak ->
        params = %{
          is_correct?: true,
          actual_interval: 20,
          correct_streak: correct_streak,
          previous_interval: 20
        }

        assert Try.get_new_interval(params) == 720
      end)
    end
  end

  describe "get_new_interval/1 review cards" do
    def correct_params_on_retry_at(%{
          previous_interval: previous_interval
        }) do
      params = %{
        is_correct?: true,
        actual_interval: previous_interval,
        previous_interval: previous_interval
      }
    end

    test "2.5 the retry_at" do
      params_one_day =
        correct_params_on_retry_at(%{
          previous_interval: 1440
        })

      assert Try.get_new_interval(params_one_day) == 3600

      params_five_days =
        correct_params_on_retry_at(%{
          previous_interval: 1440 * 5
        })

      assert Try.get_new_interval(params_five_days) === round(1440 * 12.5)
    end
  end
end
