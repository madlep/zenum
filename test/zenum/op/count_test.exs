defmodule ZEnum.Op.CountTest do
  use ExUnit.Case

  use ZEnum

  describe "basic usage" do
    test "count/1" do
      assert ZEnum.count([1, 2, 3]) == 3
      assert ZEnum.count([]) == 0
      assert ZEnum.count([1, true, false, nil]) == 4
    end

    test "count/2" do
      assert ZEnum.count([1, 2, 3], fn x -> rem(x, 2) == 0 end) == 1
      assert ZEnum.count([], fn x -> rem(x, 2) == 0 end) == 0
      assert ZEnum.count([1, true, false, nil], & &1) == 2
    end
  end
end
