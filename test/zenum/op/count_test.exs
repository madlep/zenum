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

    test "count_until/2" do
      assert ZEnum.count_until([1, 2, 3], 2) == 2
      assert ZEnum.count_until([], 2) == 0
      assert ZEnum.count_until([1, 2], 2) == 2
    end

    test "count_until/2 with streams" do
      count_until_stream = fn list, limit ->
        list |> Stream.map(& &1) |> ZEnum.count_until(limit)
      end

      assert count_until_stream.([1, 2, 3], 2) == 2
      assert count_until_stream.([], 2) == 0
      assert count_until_stream.([1, 2], 2) == 2
    end

    test "count_until/3" do
      assert ZEnum.count_until([1, 2, 3, 4, 5, 6], fn x -> rem(x, 2) == 0 end, 2) == 2
      assert ZEnum.count_until([1, 2], fn x -> rem(x, 2) == 0 end, 2) == 1
      assert ZEnum.count_until([1, 2, 3, 4], fn x -> rem(x, 2) == 0 end, 2) == 2
      assert ZEnum.count_until([], fn x -> rem(x, 2) == 0 end, 2) == 0
    end

    test "count_until/3 with streams" do
      count_until_stream = fn list, fun, limit ->
        list |> Stream.map(& &1) |> ZEnum.count_until(fun, limit)
      end

      assert count_until_stream.([1, 2, 3, 4, 5, 6], fn x -> rem(x, 2) == 0 end, 2) == 2
      assert count_until_stream.([1, 2], fn x -> rem(x, 2) == 0 end, 2) == 1
      assert count_until_stream.([1, 2, 3, 4], fn x -> rem(x, 2) == 0 end, 2) == 2
      assert count_until_stream.([], fn x -> rem(x, 2) == 0 end, 2) == 0
    end
  end
end
