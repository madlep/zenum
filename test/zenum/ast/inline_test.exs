defmodule ZEnum.AST.InlineTest do
  use ExUnit.Case
  doctest ZEnum.AST.Inline

  describe "maybe_inline_function/1" do
    test "inlines &Mod.fun/arity reference" do
      ast = quote(do: &String.capitalize/1)

      assert(
        ZEnum.AST.Inline.maybe_inline_function(ast) ==
          {:mfa_ref, {:__aliases__, [alias: false], [:String]}, :capitalize, 1}
      )
    end

    test "inlines local &fun/arity reference" do
      ast = quote(do: &do_stuff/1)

      assert(
        ZEnum.AST.Inline.maybe_inline_function(ast) ==
          {:local_fa_ref, {:do_stuff, [], ZEnum.AST.InlineTest}, 1}
      )
    end

    test "inlines &Mod.fun capture" do
      ast = quote(do: &String.bag_distance("foo", &1))

      assert(
        ZEnum.AST.Inline.maybe_inline_function(ast) ==
          {:mf_capture, {:__aliases__, [alias: false], [:String]}, :bag_distance,
           [{:inlined, "foo"}, {:capture, 1}]}
      )
    end

    test "doesn't inline &Mod.fun capture if capturing non-inlineable params" do
      ast = quote(do: &String.bag_distance(some_local_var, &1))

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:not_inlined, ast})
    end

    test "inlines &fun local capture" do
      ast = quote(do: &my_function("foo", &1))

      assert(
        ZEnum.AST.Inline.maybe_inline_function(ast) ==
          {:local_f_capture, :my_function, [{:inlined, "foo"}, {:capture, 1}]}
      )
    end

    test "doesn't inline &fun local capture if capturing non-inlineable params" do
      ast = quote(do: &my_function(some_local_var, &1))

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:not_inlined, ast})
    end

    test "inlines anonymous functions that don't close over local params" do
      ast = quote(do: fn x -> x + 1 end)

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:anon_f, ast})
    end

    test "does not inline anonymous functions that do close over local parms" do
      ast = quote(do: fn x -> x + local_var end)

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:not_inlined, ast})
    end

    test "inlines anonymous functions that define local variables" do
      ast =
        quote do
          fn x ->
            y = 1
            x + y
          end
        end

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:anon_f, ast})
    end

    test "doesn't inline anything passed as a local var" do
      ast =
        quote do
          local_fun_var
        end

      assert(ZEnum.AST.Inline.maybe_inline_function(ast) == {:not_inlined, ast})
    end
  end

  describe "inlinable_ast?/2" do
    test "atoms are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: :foo), %{}))
    end

    test "numbers are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: 1), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: 2.3), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: -4.5), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: 0x6A), %{}))
    end

    test "lists containing inlineable elements are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: [1]), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: ["foo", "bar"]), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: ["foo", {"baz", "boz"}]), %{}))

      refute(
        ZEnum.AST.Inline.inlineable_ast?(quote(do: ["foo", my_local_var, {"baz", "boz"}]), %{})
      )
    end

    test "strings are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: "foo"), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: <<"foo">>), %{}))

      assert(
        ZEnum.AST.Inline.inlineable_ast?(quote(do: "hello, #{String.capitalize("world")}"), %{})
      )
    end

    test "2-tuples containing inlineable elements are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: {:ok, "foo"}), %{}))
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: {{1, 2}, ["foo", :bar]}), %{}))
      refute(ZEnum.AST.Inline.inlineable_ast?(quote(do: {my_local_var, ["foo", :bar]}), %{}))
      refute(ZEnum.AST.Inline.inlineable_ast?(quote(do: {:ok, ["foo", :bar, my_local_var]}), %{}))
    end

    test "ast tuples containing inlineable elements are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: MyMod.do_stuff(123, ["foobar"])), %{}))

      refute(
        ZEnum.AST.Inline.inlineable_ast?(
          quote(do: MyMod.do_stuff(123, ["foobar", my_local_var])),
          %{}
        )
      )
    end

    test "ast tuples for vars are only inlineable if var is in scope bindings" do
      bindings = %{
        {:my_local_var, [generated: true], ZEnum.AST.InlineTest} => 123
      }

      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: my_local_var), bindings))
      refute(ZEnum.AST.Inline.inlineable_ast?(quote(do: other_local_var), bindings))
    end

    test "local function references are inlineable" do
      assert(ZEnum.AST.Inline.inlineable_ast?(quote(do: &my_function/1), %{}))
    end

    test "anon functions are inlineable if they don't close local vars" do
      ast =
        quote do
          fn x -> x + 1 end
        end

      assert(ZEnum.AST.Inline.inlineable_ast?(ast, %{}))
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

      assert(ZEnum.AST.Inline.inlineable_ast?(ast, %{}))
    end

    test "anon functions are inlineable if they assign new variables via =" do
      ast =
        quote do
          fn x, y ->
            {:ok, val} = y
            x + y
          end
        end

      assert(ZEnum.AST.Inline.inlineable_ast?(ast, %{}))
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

      assert(ZEnum.AST.Inline.inlineable_ast?(ast, %{}))
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

      assert(ZEnum.AST.Inline.inlineable_ast?(ast, %{}))
    end
  end
end
