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

  describe "get_new_interval/1 for a card that has never been tried" do
    test "boosts cards when correct on first try" do
      params = %{
        is_correct?: true,
        tried_before: false
      }

      assert Try.get_new_interval(params) == 1440
    end

    test "increases the time when correct again" do
      params = %{
        is_correct?: true,
        actual_interval: 1500,
        correct_streak: 2,
        previous_interval: 1440
      }

      assert Try.get_new_interval(params) == 2880
    end
  end

  describe "get_new_interval/1 right after a failed try" do
    test "schedules a retry when wrong" do
      assert Try.get_new_interval(%{is_correct?: false}) == 0
    end

    test "schedules an immediate retry on first correct try" do
      params = %{
        is_correct?: true,
        correct_streak: 1,
        previous_interval: 0
      }

      assert Try.get_new_interval(params) == 0
    end

    test "schedules a one-minute retry on second correct try" do
      params = %{
        is_correct?: true,
        correct_streak: 2,
        previous_interval: 0
      }

      assert Try.get_new_interval(params) == 1
    end
  end

  describe "get_new_interval/1 after a few correct tries" do
    def correct_params_tried_on_retried_at(%{
          correct_streak: correct_streak,
          previous_interval: previous_interval
        }) do
      params = %{
        is_correct?: true,
        actual_interval: previous_interval,
        correct_streak: correct_streak,
        previous_interval: previous_interval
      }
    end

    test "schedules a three-minute retry on third correct try" do
      params =
        correct_params_tried_on_retried_at(%{
          correct_streak: 3,
          previous_interval: 1
        })

      assert Try.get_new_interval(params) == 2
    end

    test "schedules a retry on fourth correct try" do
      params =
        correct_params_tried_on_retried_at(%{
          correct_streak: 4,
          previous_interval: 2
        })

      assert Try.get_new_interval(params) == 4
    end

    test "bumps out on fifth correct try" do
      params =
        correct_params_tried_on_retried_at(%{
          correct_streak: 5,
          previous_interval: 9
        })

      assert Try.get_new_interval(params) == 600
    end

    test "bumps out on tries more than 5" do
      params =
        correct_params_tried_on_retried_at(%{
          correct_streak: 10,
          previous_interval: 60
        })

      assert Try.get_new_interval(params) == 600
    end
  end

  describe "get_new_interval/1 with >= one-day interval tried on retry_at" do
    def correct_params_multi_day_on_retry_at(%{
          previous_interval: previous_interval
        }) do
      params = %{
        is_correct?: true,
        actual_interval: previous_interval,
        previous_interval: previous_interval
      }
    end

    test "doubles the retry_at" do
      params =
        correct_params_multi_day_on_retry_at(%{
          previous_interval: 1440
        })

      assert Try.get_new_interval(params) == 2880
    end
  end

  describe "get_new_interval/1 with >= one-day interval tried later" do
    def correct_params_multi_day_tried_later(%{
          actual_interval: actual_interval,
          previous_interval: previous_interval
        }) do
      params = %{
        is_correct?: true,
        actual_interval: actual_interval,
        previous_interval: previous_interval
      }
    end

    test "actual interval becomes the new interval" do
      params =
        correct_params_multi_day_tried_later(%{
          actual_interval: 3000,
          previous_interval: 1440
        })

      assert Try.get_new_interval(params) == 3000
    end

    test "never more than 3x" do
      params =
        correct_params_multi_day_tried_later(%{
          actual_interval: 10_000,
          previous_interval: 1440
        })

      assert Try.get_new_interval(params) == 4320
    end
  end
end
