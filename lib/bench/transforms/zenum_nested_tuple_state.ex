defmodule Bench.Transforms.ZenumNestedTupleState do
  def run(data), do: z5_take({[], 20, {[], data}})

  defp z1_filter([value | z0_data]) do
    if value.reference == :REF3 do
      {value, z0_data}
    else
      z1_filter(z0_data)
    end
  end

  defp z1_filter([]), do: :done

  defp z2_flat_map({[value | z2_acc], state}), do: {value, {z2_acc, state}}

  defp z2_flat_map({[], state}) do
    case z1_filter(state) do
      {value, new_state} -> z2_flat_map({value.events, new_state})
      other -> other
    end
  end

  defp z3_filter(state) do
    case z2_flat_map(state) do
      {value, new_state} = value_state ->
        if value.included? do
          value_state
        else
          z3_filter(new_state)
        end

      other ->
        other
    end
  end

  defmacrop z4_map(state) do
    quote do
      case z3_filter(unquote(state)) do
        {value, new_state} -> {{value.event_id, value.parent_id}, new_state}
        other -> other
      end
    end
  end

  defp z5_take({z5_acc, 0, _state}), do: :lists.reverse(z5_acc)

  defp z5_take({z5_acc, z5_n, state}) do
    case z4_map(state) do
      {value, new_state} -> z5_take({[value | z5_acc], z5_n - 1, new_state})
      :done -> :lists.reverse(z5_acc)
    end
  end
end
