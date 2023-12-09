defmodule Red.IntervalDisplay do
  def seconds_to_daystime(seconds) do
    days = round(seconds / 86_400)
    fraction_day = Float.round(seconds / 86_400, 1)

    cond do
      fraction_day < 1 -> "#{fraction_day} days"
      days == 1 -> "1 day"
      days > 1 -> "#{days} days"
    end
  end
end
