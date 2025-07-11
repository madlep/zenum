defmodule ZEnum.Op.AtTest do
  use ExUnit.Case

  use ZEnum

  test "at/3" do
    assert ZEnum.at([2, 4, 6], 0) == 2
    assert ZEnum.at([2, 4, 6], 2) == 6
    assert ZEnum.at([2, 4, 6], 4) == nil
    assert ZEnum.at([2, 4, 6], 4, :none) == :none
    assert ZEnum.at([2, 4, 6], -2) == 4
    assert ZEnum.at([2, 4, 6], -4) == nil
  end
end
