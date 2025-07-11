defmodule ZEnum.Op.ChunkByTest do
  use ExUnit.Case

  use ZEnum

  describe "chunk_by/2" do
    test "basic usage" do
      assert ZEnum.chunk_by([1, 2, 2, 3, 4, 4, 6, 7, 7], &(rem(&1, 2) == 1)) ==
               [[1], [2, 2], [3], [4, 4, 6], [7, 7]]

      assert ZEnum.chunk_by([1, 2, 3, 4], fn _ -> true end) == [[1, 2, 3, 4]]
      assert ZEnum.chunk_by([], fn _ -> true end) == []
      assert ZEnum.chunk_by([1], fn _ -> true end) == [[1]]
    end
  end
end
