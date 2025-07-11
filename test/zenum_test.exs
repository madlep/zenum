defmodule ZEnumTest do
  use ExUnit.Case
  doctest ZEnum

  use ZEnum, debug: false

  test "simple pipe" do
    input = [1, 2, 3, 4, 1, 2, 3]

    actual =
      input
      |> ZEnum.map(fn x -> x * 2 end)
      |> ZEnum.filter(fn x -> x <= 6 end)

    assert actual == [2, 4, 6, 2, 4, 6]
  end

  describe "zenum terminator" do
    test "explicit to_list/1" do
      input = [1, 2, 3, 4, 1, 2, 3]

      actual =
        input
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)
        |> ZEnum.to_list()

      assert actual == [2, 4, 6, 2, 4, 6]
    end

    test "implicit to list conversion" do
      input = [1, 2, 3, 4, 1, 2, 3]

      actual =
        input
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)

      assert actual == [2, 4, 6, 2, 4, 6]
    end
  end

  describe "zenum initialization" do
    test "explicit from_list/1 with variable" do
      input = [1, 2, 3, 4, 1, 2, 3]

      actual =
        input
        |> ZEnum.from_list()
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)

      assert actual == [2, 4, 6, 2, 4, 6]
    end

    test "explicit from_list/1 with literal list" do
      actual =
        [1, 2, 3, 4, 1, 2, 3]
        |> ZEnum.from_list()
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)

      assert actual == [2, 4, 6, 2, 4, 6]
    end

    test "implicit from list with variable" do
      input = [1, 2, 3, 4, 1, 2, 3]

      actual =
        input
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)

      assert actual == [2, 4, 6, 2, 4, 6]
    end

    test "implicit from list with literal list" do
      actual =
        [1, 2, 3, 4, 1, 2, 3]
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)

      assert actual == [2, 4, 6, 2, 4, 6]
    end
  end

  defp double(x), do: x * 2
  defp lte6(x), do: x <= 6

  test "simple pipe local functions" do
    input = [1, 2, 3, 4, 1, 2, 3]

    actual =
      input
      |> ZEnum.map(&double/1)
      |> ZEnum.filter(&lte6/1)

    assert actual == [2, 4, 6, 2, 4, 6]
  end

  # TODO doesn't compile yet. Need to store non-literal callback functions in state args
  # test "simple functions variable" do
  #   map_f = fn x -> x * 2 end
  #   filter_f = fn x -> x <= 6 end

  #   actual =
  #     ZEnum.filter(ZEnum.map(ZEnum.from_list([1, 2, 3, 4, 1, 2, 3]), map_f), filter_f)

  #   assert actual == [2, 4, 6, 2, 4, 6]
  # end

  test "simple functions inline" do
    actual =
      ZEnum.filter(ZEnum.map(ZEnum.from_list([1, 2, 3, 4, 1, 2, 3]), fn x -> x * 2 end), fn x ->
        x <= 6
      end)

    assert actual == [2, 4, 6, 2, 4, 6]
  end
end
