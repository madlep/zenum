defmodule Zenum.Op.TakeTest do
  use ExUnit.Case

  use ZEnum

  describe "basic usage" do
    test "take/2" do
      assert ZEnum.take([1, 2, 3], 0) == []
      assert ZEnum.take([1, 2, 3], 1) == [1]
      assert ZEnum.take([1, 2, 3], 2) == [1, 2]
      assert ZEnum.take([1, 2, 3], 3) == [1, 2, 3]
      assert ZEnum.take([1, 2, 3], 4) == [1, 2, 3]
      assert ZEnum.take([1, 2, 3], -1) == [3]
      assert ZEnum.take([1, 2, 3], -2) == [2, 3]
      assert ZEnum.take([1, 2, 3], -4) == [1, 2, 3]
      assert ZEnum.take([], 3) == []

      # assert_raise FunctionClauseError, fn ->
      #   ZEnum.take([1, 2, 3], 0.0)
      # end
    end
  end

  describe "take/2" do
    test "variable amount" do
      amount = 2
      assert ZEnum.take([1, 2, 3], amount) == [1, 2]
    end
  end
end
