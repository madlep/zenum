defmodule ZEnum.Op.ConcatTest do
  use ExUnit.Case

  use ZEnum

  describe "basic usage" do
    test "concat/1" do
      assert ZEnum.concat([[1, [2], 3], [4], [5, 6]]) == [1, [2], 3, 4, 5, 6]

      assert ZEnum.concat([[], []]) == []
      assert ZEnum.concat([[]]) == []
      assert ZEnum.concat([]) == []
    end

    test "concat/2" do
      assert ZEnum.concat([], [1]) == [1]
      assert ZEnum.concat([1, [2], 3], [4, 5]) == [1, [2], 3, 4, 5]

      assert ZEnum.concat([1, 2], 3..5) == [1, 2, 3, 4, 5]

      assert ZEnum.concat([], []) == []
      assert ZEnum.concat([], 1..3) == [1, 2, 3]

      # TODO handle function Enumerables
      # assert ZEnum.concat(fn acc, _ -> acc end, [1]) == [1]
    end
  end
end
