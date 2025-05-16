defmodule Zenum do
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
      ops_states = op_states(ops)

      params_ast = op_states_params_ast(ops_states, __CALLER__.module)

      push_asts = build_push_asts(id, ops, __CALLER__.module)

      [
        quote context: __CALLER__.module do
          # z_0_0 - to_list
          # z_0_1 - filter
          # z_0_2 - map
          # z_0_3 - from_list
          unquote(push_asts)

          def __z_0_0_done__(unquote_splicing(params_ast)) do
            Enum.reverse(op_0_acc)
          end

          def __z_0_1_done__(unquote_splicing(params_ast)) do
            __z_0_0_done__(unquote_splicing(params_ast))
          end

          def __z_0_2_done__(unquote_splicing(params_ast)) do
            __z_0_1_done__(unquote_splicing(params_ast))
          end

          def __z_0_3_done__(unquote_splicing(params_ast)) do
            __z_0_2_done__(unquote_splicing(params_ast))
          end

          def __z_0_3_next__(unquote_splicing(params_ast)) do
            case op_3_data do
              [value | new_op_3_data] ->
                __z_0_2_push__(op_0_acc, new_op_3_data, value)

              [] ->
                __z_0_3_done__(unquote_splicing(params_ast))
            end
          end

          def __z_0_2_next__(unquote_splicing(params_ast)) do
            __z_0_3_next__(unquote_splicing(params_ast))
          end

          def __z_0_1_next__(unquote_splicing(params_ast)) do
            __z_0_2_next__(unquote_splicing(params_ast))
          end

          def __z_0_0_next__(unquote_splicing(params_ast)) do
            __z_0_1_next__(unquote_splicing(params_ast))
          end

          defp unquote(:"z_#{id}_run")(unquote_splicing(params_ast)) do
            __z_0_0_next__(unquote_splicing(params_ast))
          end
        end
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
      unquote(:"z_#{id}_run")(unquote_splicing(op_states_values(ops_states)))
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

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, op_name]}, _, [z_args, f]}, n)
       when op_name in [:map, :filter] do
    [op(n, op_name, [], %{f: f}) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :from_list]}, _, [list]}, n) do
    [op(n, :from_list, [data: list], [])]
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

  defp push_fn(id, n), do: :"__z_#{id}_#{n}_push__"
  defp next_fn(id, n), do: :"__z_#{id}_#{n + 1}_next__"
  defp param(n, name), do: :"op_#{n}_#{name}"

  defp set_param(params_ast, param, new_param_ast) do
    i = Enum.find_index(params_ast, fn {p, _, _} -> p == param end)
    List.replace_at(params_ast, i, new_param_ast)
  end

  defp build_push_asts(id, ops, ctx) do
    ops_states = op_states(ops)
    params_ast = op_states_params_ast(ops_states, ctx)

    ops
    |> Enum.map(&push_ast(&1, id, params_ast, ctx))
  end

  defp push_ast({n, :to_list, _, _}, id, ps, ctx) do
    acc = param(n, :acc)

    quote context: ctx do
      def unquote(push_fn(id, n))(unquote_splicing(ps), v) do
        unquote(next_fn(id, n))(
          unquote_splicing(
            set_param(ps, acc, quote(context: ctx, do: [v | unquote(Macro.var(acc, ctx))]))
          )
        )
      end
    end
  end

  defp push_ast({n, :filter, _, %{f: f}}, id, ps, ctx) do
    quote context: ctx do
      def unquote(push_fn(id, n))(unquote_splicing(ps), v) do
        if unquote(f).(v) do
          unquote(push_fn(id, n - 1))(unquote_splicing(ps), v)
        else
          unquote(next_fn(id, n))(unquote_splicing(ps))
        end
      end
    end
  end

  defp push_ast({n, :map, _, %{f: f}}, id, ps, ctx) do
    quote context: ctx do
      def unquote(push_fn(id, n))(unquote_splicing(ps), v) do
        unquote(push_fn(id, n - 1))(unquote_splicing(ps), unquote(f).(v))
      end
    end
  end

  defp push_ast(_, _, _, _) do
    []
  end
end
