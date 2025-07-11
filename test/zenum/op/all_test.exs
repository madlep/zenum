defmodule ZEnum.Op.AllTest do
  use ExUnit.Case

  use ZEnum

  describe "all?/1" do
    test "basic usage" do
      assert ZEnum.all?([2, 4, 6])
      refute ZEnum.all?([2, nil, 4])
      assert ZEnum.all?([])
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.all?()

      assert actual == true

      actual =
        [1, 2, nil, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.all?()

      assert actual == false
    end
  end

  describe "all?/2" do
    test "basic usage" do
      assert ZEnum.all?([2, 4, 6], fn x -> rem(x, 2) == 0 end)
      refute ZEnum.all?([2, 3, 4], fn x -> rem(x, 2) == 0 end)
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.all?(fn x -> x <= 4 end)

      assert actual == true

      actual =
        [1, 2, 3, 4]
        |> ZEnum.filter(fn x -> x > 1 end)
        |> ZEnum.all?(fn x -> x > 4 end)

      assert actual == false
    end
  end
end
