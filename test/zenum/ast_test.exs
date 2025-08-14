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

  describe "treeshake/2" do
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

      assert(ZEnum.AST.treeshake(ast, used) == expected_removed_ast)
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

  describe "maybe_inline_function/1" do
    test "inlines &Mod.fun/arity reference" do
      ast = quote(do: &String.capitalize/1)

      assert(
        ZEnum.AST.maybe_inline_function(ast) ==
          {:mfa_ref, {:__aliases__, [alias: false], [:String]}, :capitalize, 1}
      )
    end

    test "inlines local &fun/arity reference" do
      ast = quote(do: &do_stuff/1)

      assert(
        ZEnum.AST.maybe_inline_function(ast) == {:local_fa_ref, {:do_stuff, [], ZEnum.ASTTest}, 1}
      )
    end

    test "inlines &Mod.fun capture" do
      ast = quote(do: &String.bag_distance("foo", &1))

      assert(
        ZEnum.AST.maybe_inline_function(ast) ==
          {:mf_capture, {:__aliases__, [alias: false], [:String]}, :bag_distance,
           [{:inlined, "foo"}, {:capture, 1}]}
      )
    end

    test "doesn't inline &Mod.fun capture if capturing non-inlineable params" do
      ast = quote(do: &String.bag_distance(some_local_var, &1))

      assert(ZEnum.AST.maybe_inline_function(ast) == {:not_inlineable, ast})
    end

    test "inlines &fun local capture" do
      ast = quote(do: &my_function("foo", &1))

      assert(
        ZEnum.AST.maybe_inline_function(ast) ==
          {:local_f_capture, :my_function, [{:inlined, "foo"}, {:capture, 1}]}
      )
    end

    test "doesn't inline &fun local capture if capturing non-inlineable params" do
      ast = quote(do: &my_function(some_local_var, &1))

      assert(ZEnum.AST.maybe_inline_function(ast) == {:not_inlineable, ast})
    end

    test "inlines anonymous functions that don't close over local params" do
      ast = quote(do: fn x -> x + 1 end)

      assert(ZEnum.AST.maybe_inline_function(ast) == {:anon_f, ast})
    end

    test "does not inline anonymous functions that do close over local parms" do
      ast = quote(do: fn x -> x + local_var end)

      assert(ZEnum.AST.maybe_inline_function(ast) == {:not_inlineable, ast})
    end

    # test "inlines anonymous functions that define local variables" do
    #   ast =
    #     quote do
    #       fn x ->
    #         y = 1
    #         x + y
    #       end
    #     end

    #   assert(ZEnum.AST.maybe_inline_function(ast) == {:anon_f, ast})
    # end
  end

  describe "inlinable_ast?/2" do
    test "atoms are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: :foo), %{}))
    end

    test "numbers are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: 1), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: 2.3), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: -4.5), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: 0x6A), %{}))
    end

    test "lists containing inlineable elements are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: [1]), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: ["foo", "bar"]), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: ["foo", {"baz", "boz"}]), %{}))
      refute(ZEnum.AST.inlineable_ast?(quote(do: ["foo", my_local_var, {"baz", "boz"}]), %{}))
    end

    test "strings are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: "foo"), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: <<"foo">>), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: "hello, #{String.capitalize("world")}"), %{}))
    end

    test "2-tuples containing inlineable elements are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: {:ok, "foo"}), %{}))
      assert(ZEnum.AST.inlineable_ast?(quote(do: {{1, 2}, ["foo", :bar]}), %{}))
      refute(ZEnum.AST.inlineable_ast?(quote(do: {my_local_var, ["foo", :bar]}), %{}))
      refute(ZEnum.AST.inlineable_ast?(quote(do: {:ok, ["foo", :bar, my_local_var]}), %{}))
    end

    test "ast tuples containing inlineable elements are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: MyMod.do_stuff(123, ["foobar"])), %{}))

      refute(
        ZEnum.AST.inlineable_ast?(quote(do: MyMod.do_stuff(123, ["foobar", my_local_var])), %{})
      )
    end

    test "ast tuples for vars are only inlineable if var is in scope bindings" do
      bindings = %{
        {:my_local_var, [generated: true], ZEnum.ASTTest} => 123
      }

      assert(ZEnum.AST.inlineable_ast?(quote(do: my_local_var), bindings))
      refute(ZEnum.AST.inlineable_ast?(quote(do: other_local_var), bindings))
    end

    test "local function references are inlineable" do
      assert(ZEnum.AST.inlineable_ast?(quote(do: &my_function/1), %{}))
    end

    test "anon functions are inlineable if they don't close local vars" do
      ast =
        quote do
          fn x -> x + 1 end
        end

      assert(ZEnum.AST.inlineable_ast?(ast, %{}))
    end

    test "anon functions are inlineable if they assign new vars via pattern matches" do
      ast =
        quote do
          fn {:ok, x}, y ->
            case y do
              {:ok, val1} -> x + val1
              [val2 | _] -> x + val2
              [val3] -> x + val3
              %{foo: val4, bar: _} -> x + val4
              val5 when val5 > 5 -> x + val5
              val6 when val6 > 6 and val6 < 123 -> x + val6
              {_, val7, _, _} -> x + val7
              {:error, _} -> x
            end
          end
        end

      assert(ZEnum.AST.inlineable_ast?(ast, %{}))
    end

    test "anon functions are inlineable if they assign new variables via =" do
      ast =
        quote do
          fn x, y ->
            {:ok, val} = y
            x + y
          end
        end

      assert(ZEnum.AST.inlineable_ast?(ast, %{}))
    end

    test "anon functions are inlineable if they assign new variables in with expression" do
      ast =
        quote do
          fn x ->
            with {:ok, val1} <- do_stuff(x),
                 {:ok, val2} <- do_stuff(val1),
                 {:ok, val3} <- do_stuff(val2),
                 do: val1 + val2 + val3
          end
        end

      assert(ZEnum.AST.inlineable_ast?(ast, %{}))
    end

    test "anon functions are inlineable if they assign new variables in for expression" do
      ast =
        quote do
          fn x, y ->
            for a <- [1, 2, 3], b <- x, c = 1..y do
              a + b + c
            end
          end
        end

      assert(ZEnum.AST.inlineable_ast?(ast, %{}))
    end
  end
end
