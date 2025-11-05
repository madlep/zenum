defmodule Zenum.Op.WithIndexTest do
  use ExUnit.Case

  use ZEnum

  describe "basic usage" do
    test "with_index/2" do
      assert ZEnum.with_index(1..3) == [{1, 0}, {2, 1}, {3, 2}]
      assert ZEnum.with_index(1..3, 3) == [{1, 3}, {2, 4}, {3, 5}]

      assert ZEnum.with_index([]) == []
      assert ZEnum.with_index([1, 2, 3]) == [{1, 0}, {2, 1}, {3, 2}]
      assert ZEnum.with_index([1, 2, 3], 10) == [{1, 10}, {2, 11}, {3, 12}]

      assert ZEnum.with_index([1, 2, 3], fn element, index -> {index, element} end) ==
               [{0, 1}, {1, 2}, {2, 3}]

      assert ZEnum.with_index(1..0//1) == []
      assert ZEnum.with_index(1..3) == [{1, 0}, {2, 1}, {3, 2}]
      assert ZEnum.with_index(1..3, 10) == [{1, 10}, {2, 11}, {3, 12}]

      assert ZEnum.with_index(1..3, fn element, index -> {index, element} end) ==
               [{0, 1}, {1, 2}, {2, 3}]
    end
  end
end
