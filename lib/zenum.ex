defmodule Zenum do
  alias Zenum.Op
  alias Zenum.Zipper

  @type id() :: non_neg_integer()

  defmacro __using__(opts) do
    quote generated: true do
      require Zenum
      @before_compile Zenum

      Module.register_attribute(__MODULE__, :zenum_debug, accumulate: false)

      Module.put_attribute(
        __MODULE__,
        :zenum_debug,
        unquote(Keyword.get(opts, :debug_ast))
      )

      Module.register_attribute(__MODULE__, :zenums, accumulate: true)
      Module.register_attribute(__MODULE__, :zenum_id, accumulate: false)
      Module.put_attribute(__MODULE__, :zenum_id, 0)
    end
  end

  defmacro __before_compile__(_env) do
    zenums = Module.get_attribute(__CALLER__.module, :zenums)

    zenums
    |> Enum.flat_map(fn {id, ops} ->
      params_ast = op_states_params_ast(ops, __CALLER__.module)

      Enum.concat([
        ops
        |> Zipper.map_zipper(
          &Op.push_fun_ast(Zipper.head!(&1), &1, id, params_ast, __CALLER__.module)
        )
      ])
    end)
    |> debug_ast("__before_compile__", Module.get_attribute(__CALLER__.module, :zenum_debug))
  end

  ### public API

  defmacro from_list(_z) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro map(_z, _f) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro filter(_z, _f) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro to_list(z) do
    id = Module.get_attribute(__CALLER__.module, :zenum_id, 0)

    ops =
      z
      |> normalize_pipes()
      |> build_ops(1)

    ops = [Op.ToList.build_op(0, []) | ops] |> Zipper.new()

    Module.put_attribute(__CALLER__.module, :zenums, {id, ops})
    Module.put_attribute(__CALLER__.module, :zenum_id, id + 1)

    params_ast = op_states_params_ast(ops, __CALLER__.module)

    args_ast =
      ops
      |> op_states()
      |> Enum.map(fn {n, _op_name, param, value} ->
        var_ast = state_param_name(n, param)

        quote generated: true do
          unquote(Macro.var(var_ast, __CALLER__.module)) = unquote(value)
        end
      end)

    quote generated: true do
      unquote(args_ast)
      unquote(Op.next_ast(Zipper.head!(ops), ops, id, params_ast, __CALLER__.module))
    end
    |> debug_ast("to_list", Module.get_attribute(__CALLER__.module, :zenum_debug))
  end

  ### parse ops

  defp normalize_pipes({:|>, _, [piped_ast | [{fn_ast, fn_context, fn_args}]]}) do
    {fn_ast, fn_context, [normalize_pipes(piped_ast) | fn_args]}
  end

  defp normalize_pipes(ast) do
    ast
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :filter]}, _, [z_args, f]}, n) do
    [Op.Filter.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :map]}, _, [z_args, f]}, n) do
    [Op.MapLiteralFn.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :from_list]}, _, args}, n) do
    [Op.FromList.build_op(n, args)]
  end

  defp op_states(ops) do
    Enum.flat_map(ops, &Op.state(&1))
  end

  defp state_param_name(n, param) do
    :"op_#{n}_#{param}"
  end

  defp op_states_params_ast(op, context) do
    op
    |> op_states()
    |> Enum.map(fn {n, _op_name, param, _value} ->
      {state_param_name(n, param), [], context}
    end)
  end

  defp debug_ast(ast, title, debug) do
    if debug do
      IO.puts(title)
      ast |> Macro.to_string() |> IO.puts()
    end

    ast
  end

  defp debug_ast(ast, title, true) do
    IO.puts(title)
    ast |> Macro.to_string() |> IO.puts()

    ast
  end

  defp debug_ast(ast, title, :ast) do
    IO.puts(title)
    IO.inspect(ast)
  end

  defp debug_ast(ast, _title, false), do: ast
end
