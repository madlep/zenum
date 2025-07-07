defmodule Zenum.ZipperTest do
  use ExUnit.Case
  doctest Zenum.Zipper

  alias Zenum.Zipper, as: Z

  describe "new/1" do
    test "creates new zipper" do
      z = [1, 2] |> Z.new()
      assert(z == %Z{next: [1, 2], prev: []})
    end

    test "expects a list" do
      assert_raise(FunctionClauseError, fn -> Z.new(:foobar) end)
    end
  end

  describe "head?/1" do
    test "true when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.head?(z) == true)
    end

    test "true when not exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.head?(z) == true)
    end

    test "false when empty" do
      z = [] |> Z.new()
      assert(Z.head?(z) == false)
    end

    test "false when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.head?(z) == false)
    end
  end

  describe "head!/1" do
    test "returns head value when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.head!(z) == 1)
    end

    test "returns head value when not exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.head!(z) == 2)
    end

    test "raises when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert_raise(RuntimeError, fn -> Z.head!(z) end)
    end

    test "raises when empty" do
      z = [] |> Z.new()
      assert_raise(RuntimeError, fn -> Z.head!(z) end)
    end
  end

  describe "head/1" do
    test "returns head ok tuple when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.head(z) == {:ok, 1})
    end

    test "returns head value ok tuple when not exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.head(z) == {:ok, 2})
    end

    test "returns error tuple when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.head(z) == {:error, :no_head})
    end

    test "returns error tuple when empty" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.head(z) == {:error, :no_head})
    end
  end

  describe "prev?/1" do
    test "false when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.prev?(z) == false)
    end

    test "true when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.prev?(z) == true)
    end

    test "false when empty" do
      z = [] |> Z.new()
      assert(Z.prev?(z) == false)
    end

    test "true when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.prev?(z) == true)
    end
  end

  describe "prev!/1" do
    test "raises when at start" do
      z = [1, 2] |> Z.new()
      assert_raise(RuntimeError, fn -> Z.prev!(z) end)
    end

    test "moves to previous when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.prev!(z) == %Z{next: [1, 2], prev: []})
    end

    test "moves to previous when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.prev!(z) == %Z{next: [2], prev: [1]})
    end

    test "raises when empty" do
      z = [] |> Z.new()
      assert_raise(RuntimeError, fn -> Z.prev!(z) end)
    end
  end

  describe "prev/1" do
    test "returns error tuple when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.prev(z) == {:error, :no_previous})
    end

    test "returns ok tuple for move to previous when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.prev(z) == {:ok, %Z{next: [1, 2], prev: []}})
    end

    test "returns ok tuple for move to previous when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.prev(z) == {:ok, %Z{next: [2], prev: [1]}})
    end

    test "returns error tuple when empty" do
      z = [] |> Z.new()
      assert(Z.prev(z) == {:error, :no_previous})
    end
  end

  describe "next?/1" do
    test "true when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.next?(z) == true)
    end

    test "true when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.next?(z) == true)
    end

    test "false when empty" do
      z = [] |> Z.new()
      assert(Z.next?(z) == false)
    end

    test "false when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.next?(z) == false)
    end
  end

  describe "next!/1" do
    test "moves to next when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.next!(z) == %Z{next: [2], prev: [1]})
    end

    test "moves to next when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.next!(z) == %Z{next: [], prev: [2, 1]})
    end

    test "raises when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert_raise(RuntimeError, fn -> Z.next!(z) end)
    end

    test "raises when empty" do
      z = [] |> Z.new()
      assert_raise(RuntimeError, fn -> Z.next!(z) end)
    end
  end

  describe "next/1" do
    test "returns ok tuple for move to next when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.next(z) == {:ok, %Z{next: [2], prev: [1]}})
    end

    test "returns ok tuple for move to next when not at start" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.next(z) == {:ok, %Z{next: [], prev: [2, 1]}})
    end

    test "returns error tuple when exhausted" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.next!()
      assert(Z.next(z) == {:error, :no_next})
    end

    test "returns error tuple when empty" do
      z = [] |> Z.new()
      assert(Z.next(z) == {:error, :no_next})
    end
  end

  describe "count/1" do
    test "returns remaining when at start" do
      z = [1, 2] |> Z.new()
      assert(Z.count(z) == 2)
    end

    test "returns remaining after moving to next" do
      z = [1, 2] |> Z.new() |> Z.next!()
      assert(Z.count(z) == 1)
    end

    test "returns remaining after moving back prev" do
      z = [1, 2] |> Z.new() |> Z.next!() |> Z.prev!()
      assert(Z.count(z) == 2)
    end
  end
end
