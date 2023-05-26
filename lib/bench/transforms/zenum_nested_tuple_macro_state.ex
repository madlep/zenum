defmodule Bench.Transforms.ZenumNestedTupleMacroState do
  defmacrop z0_data(data) do
    quote do
      case unquote(data) do
        [] -> :done
        [value | new_z0_data] -> {value, new_z0_data}
      end
    end
  end

  defmacrop z1_filter(state) do
    quote do
      case z0_data(unquote(state)) do
        {value, new_state} ->
          if value.reference == :REF3 do
            {value, new_state}
          else
            z1_filter_rec(new_state)
          end

        other ->
          other
      end
    end
  end

  defp z1_filter_rec(state), do: z1_filter(state)

  defmacrop z2_flat_map(state) do
    quote do
      case unquote(state) do
        {[value | new_z2_acc], new_state} ->
          {value, {new_z2_acc, new_state}}

        {[], new_state} ->
          case z1_filter(new_state) do
            {value, new_state} -> z2_flat_map_rec({value.events, new_state})
            other -> other
          end
      end
    end
  end

  defp z2_flat_map_rec(state), do: z2_flat_map(state)

  defmacrop z3_filter(state) do
    quote do
      case z2_flat_map(unquote(state)) do
        {value, new_state} = value_state ->
          if value.included? do
            value_state
          else
            z3_filter_rec(new_state)
          end

        other ->
          other
      end
    end
  end

  defp z3_filter_rec(state), do: z3_filter(state)

  defmacrop z4_map(state) do
    quote do
      case z3_filter(unquote(state)) do
        {value, new_state} -> {{value.event_id, value.parent_id}, new_state}
        other -> other
      end
    end
  end

  defmacrop z5_take(state) do
    quote do
      case unquote(state) do
        {z5_acc, 0, _new_state} ->
          :lists.reverse(z5_acc)

        {z5_acc, z5_n, new_state} ->
          case z4_map(new_state) do
            {value, new_state2} -> z5_take_rec({[value | z5_acc], z5_n - 1, new_state2})
            :done -> :lists.reverse(z5_acc)
          end
      end
    end
  end

  defp z5_take_rec(state), do: z5_take(state)

  # defp z5_take({z5_acc, 0, _state}), do: :lists.reverse(z5_acc)

  # defp z5_take({z5_acc, z5_n, state}) do
  #   case z4_map(state) do
  #     {value, new_state} -> z5_take({[value | z5_acc], z5_n - 1, new_state})
  #     :done -> :lists.reverse(z5_acc)
  #   end
  # end

  def run(data), do: z5_take_rec({[], 20, {[], data}})
end
