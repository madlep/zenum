defmodule Zenum.Op.ZipWith3Test do
  use ExUnit.Case

  use ZEnum

  describe "basic usage" do
    test "zip_with/3" do
      assert ZEnum.zip_with([1, 2], [3, 4], fn a, b -> a * b end) == [3, 8]
      assert ZEnum.zip_with([:a, :b], [1, 2], &{&1, &2}) == [{:a, 1}, {:b, 2}]
      assert ZEnum.zip_with([:a, :b], [1, 2, 3, 4], &{&1, &2}) == [{:a, 1}, {:b, 2}]
      assert ZEnum.zip_with([:a, :b, :c, :d], [1, 2], &{&1, &2}) == [{:a, 1}, {:b, 2}]
      assert ZEnum.zip_with([], [1], &{&1, &2}) == []
      assert ZEnum.zip_with([1], [], &{&1, &2}) == []
      assert ZEnum.zip_with([], [], &{&1, &2}) == []

      # Ranges
      assert ZEnum.zip_with(1..6, 3..4, fn a, b -> a + b end) == [4, 6]
      assert ZEnum.zip_with([1, 2, 5, 6], 3..4, fn a, b -> a + b end) == [4, 6]

      # assert ZEnum.zip_with(fn _, _ -> {:cont, [1, 2]} end, 3..4, fn a, b -> a + b end) == [4, 6]
      assert ZEnum.zip_with(1..1, 0..0, fn a, b -> a + b end) == [1]

      # Date.range
      week_1 = Date.range(~D[2020-10-12], ~D[2020-10-16])
      week_2 = Date.range(~D[2020-10-19], ~D[2020-10-23])

      result =
        ZEnum.zip_with(week_1, week_2, fn a, b ->
          Date.day_of_week(a) + Date.day_of_week(b)
        end)

      assert result == [2, 4, 6, 8, 10]

      # Maps
      result = ZEnum.zip_with(%{a: 7}, 3..4, fn {key, value}, b -> {key, value + b} end)
      assert result == [a: 10]

      result = ZEnum.zip_with(3..4, %{a: 7}, fn a, {key, value} -> {key, value + a} end)
      assert result == [a: 10]
    end
  end
end
