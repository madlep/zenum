defmodule Bench.Transforms.ZenumNestedTupleState do
  @compile {:inline, z0_data: 1, z4_map: 1, z5_take: 1}

  def run(data), do: z6_run({[], {20, {[], data}}})

  defp z0_data([value | new_state]), do: {value, new_state}
  defp z0_data(_), do: {}

  defp z1_filter(state) do
    case z0_data(state) do
      {value, new_state} ->
        if value.reference == :REF3 do
          {value, new_state}
        else
          z1_filter(new_state)
        end

      done ->
        done
    end
  end

  defp z2_flat_map({[value | z2_acc], state}), do: {value, {z2_acc, state}}

  defp z2_flat_map({_, z0_data}) do
    case z1_filter(z0_data) do
      {value, new_state} -> z2_flat_map({value.events, new_state})
      done -> done
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

      done ->
        done
    end
  end

  defp z4_map(state) do
    case z3_filter(state) do
      {value, new_state} -> {{value.event_id, value.parent_id}, new_state}
      done -> done
    end
  end

  defp z5_take({0, _state}), do: :done

  defp z5_take({z5_n, state}) do
    case z4_map(state) do
      {value, new_state} -> {value, {z5_n - 1, new_state}}
      done -> done
    end
  end

  defp z6_run({z6_acc, state}) do
    case z5_take(state) do
      {value, new_state} -> z6_run({[value | z6_acc], new_state})
      _ -> :lists.reverse(z6_acc)
    end
  end
end
