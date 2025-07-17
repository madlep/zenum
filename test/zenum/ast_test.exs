defmodule ZEnum.ASTTest do
  use ExUnit.Case
  doctest ZEnum.AST

  describe "used_zenum_funs/1" do
    test "finds used functions" do
      ast =
        quote do
          __z_0_1__(3, 4)

          defp __z_0_1__(a, b) do
            __z_0_2__(a, b)
          end

          defp __z_0_2__(a, b) do
            __z_0_2__(a, b)
            __z_0_4__(a, b)
          end

          defp __z_0_3__(a, b), do: {a, b}

          defp __z_0_4__(a, b), do: __z_0_1__(a, b)
        end

      assert(ZEnum.AST.used_zenum_funs(ast) == MapSet.new([:__z_0_1__, :__z_0_2__, :__z_0_4__]))
    end
  end

  describe "remove_unused_zenum_funs/2" do
    test "removed functions that aren't in used list" do
      ast =
        quote do
          __z_0_1__(3, 4)

          defp __z_0_1__(a, b) do
            __z_0_2__(a, b)
          end

          defp __z_0_2__(a, b) do
            __z_0_2__(a, b)
            __z_0_4__(a, b)
          end

          defp __z_0_3__(a, b), do: {a, b}

          defp __z_0_4__(a, b), do: __z_0_1__(a, b)
        end

      used = [:__z_0_1__, :__z_0_2__, :__z_0_4__]

      expected_removed_ast =
        quote do
          __z_0_1__(3, 4)

          defp __z_0_1__(a, b) do
            __z_0_2__(a, b)
          end

          defp __z_0_2__(a, b) do
            __z_0_2__(a, b)
            __z_0_4__(a, b)
          end

          defp __z_0_4__(a, b), do: __z_0_1__(a, b)
        end

      assert(ZEnum.AST.remove_unused_zenum_funs(ast, used) == expected_removed_ast)
    end
  end

  describe "normalize_pipes/1" do
    test "converts pipes and regular nested functions into same AST" do
      piped_ast =
        quote do
          my_data
          |> foo()
          |> bar(:a)
          |> baz(:b, :c)
        end

      nested_ast =
        quote do
          baz(bar(foo(my_data), :a), :b, :c)
        end

      assert(ZEnum.AST.normalize_pipes(piped_ast) == ZEnum.AST.normalize_pipes(nested_ast))
    end

    test "converts pipes and regular nested functions into nested AST" do
      piped_ast =
        quote do
          my_data
          |> foo()
          |> bar(:a)
          |> baz(:b, :c)
        end

      nested_ast =
        quote do
          baz(bar(foo(my_data), :a), :b, :c)
        end

      assert(ZEnum.AST.normalize_pipes(piped_ast) == nested_ast)
    end
  end
end
