defmodule Red.IntervalDisplayTest do
  use ExUnit.Case, async: true

  describe "seconds_to_daystime/1" do
    test "converts seconds to days" do
      assert Red.IntervalDisplay.seconds_to_daystime(86_400) == "1 day"
    end

    test "converts pluralizes for multiple days" do
      three_days = round(:timer.hours(24 * 3) / 1000)

      assert Red.IntervalDisplay.seconds_to_daystime(three_days) ==
               "3 days"
    end

    test "rounds half days more than a day" do
      three_days = round(:timer.hours(24 * 2.5) / 1000)

      assert Red.IntervalDisplay.seconds_to_daystime(three_days) ==
               "3 days"
    end

    test "shows fraction days less than a day" do
      half_day = round(:timer.hours(12) / 1000)

      assert Red.IntervalDisplay.seconds_to_daystime(half_day) ==
               "0.5 days"
    end
  end
end
