defmodule Zenum do
  alias Zenum.Op

  import Zenum.AST

  @type id() :: non_neg_integer()

  defmacro __using__([]) do
    quote do
      require Zenum
      @before_compile Zenum

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
        Enum.map(ops, &Op.push_fun_ast(&1, id, params_ast, __CALLER__.module)),
        Enum.map(ops, &Op.return_fun_ast(&1, id, params_ast, __CALLER__.module)),
        Enum.map(ops, &Op.next_fun_ast(&1, id, params_ast, __CALLER__.module))
      ])
    end)
    |> tap(fn x -> x |> Macro.to_string() |> IO.puts() end)
  end

  ### public API

  defmacro from_list(_z) do
    quote do
      raise "must be finished with to_list()"
    end
  end

  defmacro map(_z, _f) do
    quote do
      raise "must be finished with to_list()"
    end
  end

  defmacro filter(_z, _f) do
    quote do
      raise "must be finished with to_list()"
    end
  end

  defmacro to_list(z) do
    id = Module.get_attribute(__CALLER__.module, :zenum_id, 0)

    ops =
      z
      |> normalize_pipes()
      |> build_ops(1)

    ops = [Op.ToList.build_op(0, []) | ops]

    Module.put_attribute(__CALLER__.module, :zenums, {id, ops})
    Module.put_attribute(__CALLER__.module, :zenum_id, id + 1)

    next_fun_args_ast = ops |> op_states() |> Enum.map(&elem(&1, 3))

    quote do
      unquote(next_fun_name(id, 0))(unquote_splicing(next_fun_args_ast))
    end
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
end
