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

      args = ops |> op_args()

      push_asts = build_push_asts(ops)

      [
        quote context: __CALLER__.module do
          unquote(push_asts)

          def z_0_0_to_list_push(unquote_splicing(params_ast), value) do
            z_0_1_filter_next([value | op_0_to_list_acc], op_3_from_list_data)
          end

          def z_0_1_filter_push(unquote_splicing(params_ast), value) do
            if unquote(Map.fetch!(args, {1, :filter, :f})).(value) do
              z_0_0_to_list_push(unquote_splicing(params_ast), value)
            else
              z_0_1_filter_next(unquote_splicing(params_ast))
            end
          end

          def z_0_2_map_push(unquote_splicing(params_ast), value) do
            z_0_1_filter_push(
              unquote_splicing(params_ast),
              unquote(Map.fetch!(args, {2, :map, :f})).(value)
            )
          end

          def z_0_0_to_list_done(unquote_splicing(params_ast)) do
            Enum.reverse(op_0_to_list_acc)
          end

          def z_0_1_filter_done(unquote_splicing(params_ast)) do
            z_0_0_to_list_done(unquote_splicing(params_ast))
          end

          def z_0_2_map_done(unquote_splicing(params_ast)) do
            z_0_1_filter_done(unquote_splicing(params_ast))
          end

          def z_0_0_from_list_done(unquote_splicing(params_ast)) do
            z_0_2_map_done(unquote_splicing(params_ast))
          end

          def z_0_0_from_list_next(unquote_splicing(params_ast)) do
            case op_3_from_list_data do
              [value | new_op_3_from_list_data] ->
                z_0_2_map_push(op_0_to_list_acc, new_op_3_from_list_data, value)

              [] ->
                z_0_0_from_list_done(op_0_to_list_acc, op_3_from_list_data)
            end
          end

          def z_0_2_map_next(unquote_splicing(params_ast)) do
            z_0_0_from_list_next(unquote_splicing(params_ast))
          end

          def z_0_1_filter_next(unquote_splicing(params_ast)) do
            z_0_2_map_next(unquote_splicing(params_ast))
          end

          def z_0_0_to_list_next(unquote_splicing(params_ast)) do
            z_0_1_filter_next(unquote_splicing(params_ast))
          end

          defp unquote(:"z_#{id}_run")(unquote_splicing(params_ast)) do
            z_0_0_to_list_next(unquote_splicing(params_ast))
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
    [op(n, op_name, [], f: f) | build_ops(z_args, n + 1)]
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

  defp state_param_name(n, op_name, param) do
    :"op_#{n}_#{op_name}_#{param}"
  end

  defp op_states_params_ast(op_states, context) do
    op_states
    |> Enum.map(fn {n, op_name, param, _value} ->
      {state_param_name(n, op_name, param), [], context}
    end)
  end

  defp op_states_values(op_state) do
    op_state
    |> Enum.map(&elem(&1, 3))
  end

  defp op_args(ops) do
    ops
    |> Enum.flat_map(fn
      {_n, _op_name, _op_state, []} ->
        []

      {n, op_name, _op_state, op_args} ->
        op_args
        |> Enum.map(fn {arg_name, arg_value} ->
          {{n, op_name, arg_name}, arg_value}
        end)
    end)
    |> Enum.into(%{})
  end

  ### build ASTs
  def build_push_asts(ops) do
    # TODO

    dbg(ops)
    dbg(op_states(ops))
    dbg(op_args(ops))

    []
  end
end
