defmodule Zenum do
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
      [
        build_push_fun_asts(id, ops, __CALLER__.module),
        build_return_fun_asts(id, ops, __CALLER__.module),
        build_next_fun_asts(id, ops, __CALLER__.module)
      ]
    end)
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

    ops = [op(0, :to_list, [acc: []], []) | ops]
    ops_states = op_states(ops)

    Module.put_attribute(__CALLER__.module, :zenums, {id, ops})
    Module.put_attribute(__CALLER__.module, :zenum_id, id + 1)

    quote do
      unquote(next_fun_name(id, 0))(unquote_splicing(op_states_values(ops_states)))
    end
  end

  ### parse ops

  defp op(n, op_name, state, args) do
    {n, op_name, state, args}
  end

  defp normalize_pipes({:|>, _, [piped_ast | [{fn_ast, fn_ctx, fn_args}]]}) do
    {fn_ast, fn_ctx, [normalize_pipes(piped_ast) | fn_args]}
  end

  defp normalize_pipes(ast) do
    ast
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :filter]}, _, [z_args, f]}, n) do
    [Zenum.Ops.Filter.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :map]}, _, [z_args, f]}, n) do
    [Zenum.Ops.MapLiteralFn.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :from_list]}, _, args}, n) do
    [Zenum.Ops.FromList.build_op(n, args)]
  end

  defp op_states(ops) do
    ops
    |> Enum.flat_map(fn
      {_n, _op_name, [], _op_args} ->
        []

      {n, op_name, op_state, _op_args} ->
        op_state
        |> Enum.map(fn {param, state_value} ->
          {n, op_name, param, state_value}
        end)

      op when is_struct(op) ->
        Zenum.Op.state(op)
    end)
  end

  defp state_param_name(n, param) do
    :"op_#{n}_#{param}"
  end

  defp op_states_params_ast(op_states, ctx) do
    op_states
    |> Enum.map(fn {n, _op_name, param, _value} ->
      {state_param_name(n, param), [], ctx}
    end)
  end

  defp op_states_values(op_state) do
    op_state
    |> Enum.map(&elem(&1, 3))
  end

  ### build ASTs

  defp build_push_fun_asts(id, ops, ctx) do
    ops_states = op_states(ops)
    params_ast = op_states_params_ast(ops_states, ctx)

    ops
    |> Enum.map(&push_fun_ast(&1, id, params_ast, ctx))
  end

  defp push_fun_ast({n, :to_list, _, _}, id, ps, ctx) do
    acc = fun_param_name(n, :acc)

    quote context: ctx do
      def unquote(push_fun_name(id, n))(unquote_splicing(ps), v) do
        unquote(next_fun_name(id, n + 1))(
          unquote_splicing(
            set_param(ps, acc, quote(context: ctx, do: [v | unquote(Macro.var(acc, ctx))]))
          )
        )
      end
    end
  end

  defp push_fun_ast(op, id, params, context) when is_struct(op) do
    Zenum.Op.push_fun_ast(op, id, params, context)
  end

  defp build_return_fun_asts(id, ops, ctx) do
    ops_states = op_states(ops)
    params_ast = op_states_params_ast(ops_states, ctx)

    ops |> Enum.map(&return_fun_ast(&1, id, params_ast, ctx))
  end

  defp return_fun_ast({n, :to_list, _, _}, id, ps, ctx) do
    quote context: ctx do
      def unquote(return_fun_name(id, n))(unquote_splicing(ps)) do
        Enum.reverse(unquote(Macro.var(fun_param_name(n, :acc), ctx)))
      end
    end
  end

  defp return_fun_ast(op, id, params, context) when is_struct(op) do
    Zenum.Op.return_fun_ast(op, id, params, context)
  end

  defp build_next_fun_asts(id, ops, ctx) do
    ops_states = op_states(ops)
    params_ast = op_states_params_ast(ops_states, ctx)

    ops |> Enum.map(&next_fun_ast(&1, id, params_ast, ctx))
  end

  defp next_fun_ast(op, id, params, context) when is_struct(op) do
    Zenum.Op.next_fun_ast(op, id, params, context)
  end

  defp next_fun_ast({n, op, _, _}, id, ps, ctx) when op in [:to_list] do
    quote context: ctx do
      def unquote(next_fun_name(id, n))(unquote_splicing(ps)) do
        unquote(next_fun_name(id, n + 1))(unquote_splicing(ps))
      end
    end
  end
end
