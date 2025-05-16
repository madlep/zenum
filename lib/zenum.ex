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

          def z_0_3_to_list_push(unquote_splicing(params_ast), value) do
            z_0_2_filter_next(op_0_from_list_data, [value | op_3_to_list_acc])
          end

          def z_0_2_filter_push(unquote_splicing(params_ast), value) do
            if unquote(Map.fetch!(args, {2, :filter, :f})).(value) do
              z_0_3_to_list_push(unquote_splicing(params_ast), value)
            else
              z_0_2_filter_next(unquote_splicing(params_ast))
            end
          end

          def z_0_1_map_push(unquote_splicing(params_ast), value) do
            z_0_2_filter_push(
              unquote_splicing(params_ast),
              unquote(Map.fetch!(args, {1, :map, :f})).(value)
            )
          end

          def z_0_3_to_list_done(unquote_splicing(params_ast)) do
            Enum.reverse(op_3_to_list_acc)
          end

          def z_0_2_filter_done(unquote_splicing(params_ast)) do
            z_0_3_to_list_done(unquote_splicing(params_ast))
          end

          def z_0_1_map_done(unquote_splicing(params_ast)) do
            z_0_2_filter_done(unquote_splicing(params_ast))
          end

          def z_0_0_from_list_done(unquote_splicing(params_ast)) do
            z_0_1_map_done(unquote_splicing(params_ast))
          end

          def z_0_0_from_list_next(unquote_splicing(params_ast)) do
            case op_0_from_list_data do
              [value | new_op_0_from_list_data] ->
                z_0_1_map_push(new_op_0_from_list_data, op_3_to_list_acc, value)

              [] ->
                z_0_0_from_list_done(op_0_from_list_data, op_3_to_list_acc)
            end
          end

          def z_0_1_map_next(unquote_splicing(params_ast)) do
            z_0_0_from_list_next(unquote_splicing(params_ast))
          end

          def z_0_2_filter_next(unquote_splicing(params_ast)) do
            z_0_1_map_next(unquote_splicing(params_ast))
          end

          def z_0_3_to_list_next(unquote_splicing(params_ast)) do
            z_0_2_filter_next(unquote_splicing(params_ast))
          end

          defp unquote(:"z_#{id}_run")(unquote_splicing(params_ast)) do
            z_0_3_to_list_next(unquote_splicing(params_ast))
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
      |> build_ops()

    ops = [op(:to_list, [acc: []], []) | ops] |> Enum.reverse()
    ops_states = op_states(ops)

    Module.put_attribute(__CALLER__.module, :zenums, {id, ops})
    Module.put_attribute(__CALLER__.module, :zenum_id, id + 1)

    quote do
      unquote(:"z_#{id}_run")(unquote_splicing(op_states_values(ops_states)))
    end
  end

  ### parse ops

  defp op(op_name, state, args) do
    {op_name, state, args}
  end

  defp normalize_pipes({:|>, _, [piped_ast | [{fn_ast, fn_ctx, fn_args}]]}) do
    {fn_ast, fn_ctx, [normalize_pipes(piped_ast) | fn_args]}
  end

  defp normalize_pipes(ast) do
    ast
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, op_name]}, _, [z_args, f]})
       when op_name in [:map, :filter] do
    [op(op_name, [], f: f) | build_ops(z_args)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :from_list]}, _, [list]}) do
    [op(:from_list, [data: list], [])]
  end

  defp op_states(ops) do
    ops
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {{_op_name, [], _op_args}, _n} ->
        []

      {{op_name, op_state, _op_args}, n} ->
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
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {{_op_name, _op_state, []}, _n} ->
        []

      {{op_name, _op_state, op_args}, n} ->
        op_args
        |> Enum.map(fn {arg_name, arg_value} ->
          {{n, op_name, arg_name}, arg_value}
        end)
    end)
    |> Enum.into(%{})
  end

  ### build ASTs
  def build_push_asts(_ops) do
    # TODO
    []
  end
end
