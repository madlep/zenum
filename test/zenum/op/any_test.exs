defmodule ZEnum.Op.AnyTest do
  use ExUnit.Case

  use ZEnum

  describe "any?/1" do
    test "basic usage" do
      assert ZEnum.any?([2, 4, 6])
      assert ZEnum.any?([2, nil, 4])
      refute ZEnum.any?([])
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.any?()

      assert actual == true

      actual =
        [1, nil, false]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.any?()

      assert actual == false
    end
  end

  describe "any?/2" do
    test "basic usage" do
      assert ZEnum.any?([2, 4, 6], fn x -> rem(x, 2) == 0 end)
      refute ZEnum.any?([1, 3, 5], fn x -> rem(x, 2) == 0 end)
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.any?(fn x -> x >= 4 end)

      assert actual == true

      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.any?(fn x -> x > 4 end)

      assert actual == false
    end
  end
end
