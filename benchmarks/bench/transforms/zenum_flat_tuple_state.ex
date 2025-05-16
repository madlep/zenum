defmodule Bench.Transforms.ZenumFlatTupleState do
  def run(data, take_n), do: z5_take({[], take_n, [], data})

  defp z1_filter({_z5_acc, _z5_n, _z2_acc, []}), do: :done

  defp z1_filter({z5_acc, z5_n, z2_acc, [value | new_z0_data]}) do
    if value.reference == :REF3 do
      {value, {z5_acc, z5_n, z2_acc, new_z0_data}}
    else
      z1_filter({z5_acc, z5_n, z2_acc, new_z0_data})
    end
  end

  defp z2_flat_map({_z5_acc, _z5_n, [], _z0_data} = state) do
    case z1_filter(state) do
      {value, {new_z5_acc, new_z5_n, _z2_acc, new_z0_data}} ->
        z2_flat_map({new_z5_acc, new_z5_n, value.events, new_z0_data})

      :done ->
        :done
    end
  end

  defp z2_flat_map({z5_acc, z5_n, [value | z2_acc], z0_data}),
    do: {value, {z5_acc, z5_n, z2_acc, z0_data}}

  defp z3_filter(state) do
    case z2_flat_map(state) do
      {value, new_state} ->
        if value.included? do
          {value, new_state}
        else
          z3_filter(new_state)
        end

      :done ->
        :done
    end
  end

  defp z4_map(state) do
    case z3_filter(state) do
      {value, new_state} -> {{value.event_id, value.parent_id}, new_state}
      :done -> :done
    end
  end

  defp z5_take({z5_acc, 0, _z2_acc, _z0_data}), do: :lists.reverse(z5_acc)

  defp z5_take(state) do
    case z4_map(state) do
      {value, {z5_acc, z5_n, z2_acc, z0_data}} ->
        z5_take({[value | z5_acc], z5_n - 1, z2_acc, z0_data})

      :done ->
        :lists.reverse(elem(state, 0))
    end
  end
end
