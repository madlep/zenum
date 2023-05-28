defmodule Bench.Transforms.ZenumArgsStateTCO do
  def run(data), do: z0_data([], 20, [], data)

  defp z0_data(acc, _z5_n, _z2_buffer, []), do: done(acc)

  defp z0_data(acc, z5_n, z2_buffer, [value | z0_data]),
    do: z1_filter_push(acc, value, z5_n, z2_buffer, z0_data)

  defp z1_filter_push(acc, value, z5_n, z2_buffer, z0_data) do
    if value.reference == :REF3 do
      z2_flat_map_push(acc, value, z5_n, z2_buffer, z0_data)
    else
      z1_filter(acc, z5_n, z2_buffer, z0_data)
    end
  end

  defp z1_filter(acc, z5_n, z2_buffer, z0_data), do: z0_data(acc, z5_n, z2_buffer, z0_data)

  defp z2_flat_map_push(acc, value, z5_n, [], z0_data),
    do: z2_flat_map(acc, z5_n, value.events, z0_data)

  defp z2_flat_map(acc, z5_n, [value | z2_buffer], z0_data),
    do: z3_filter_push(acc, value, z5_n, z2_buffer, z0_data)

  defp z2_flat_map(acc, z5_n, [], z0_data), do: z1_filter(acc, z5_n, [], z0_data)

  defp z3_filter_push(acc, value, z5_n, z2_buffer, z0_data) do
    if value.included? do
      z4_map_push(acc, value, z5_n, z2_buffer, z0_data)
    else
      z3_filter(acc, z5_n, z2_buffer, z0_data)
    end
  end

  defp z3_filter(acc, z5_n, z2_buffer, z0_data), do: z2_flat_map(acc, z5_n, z2_buffer, z0_data)

  defp z4_map_push(acc, value, z5_n, z2_buffer, z0_data),
    do: z5_take_push(acc, {value.event_id, value.parent_id}, z5_n, z2_buffer, z0_data)

  defp z4_map(acc, z5_n, z2_buffer, z0_data), do: z3_filter(acc, z5_n, z2_buffer, z0_data)

  defp z5_take_push(acc, value, z5_n, z2_buffer, z0_data),
    do: z5_take([value | acc], z5_n - 1, z2_buffer, z0_data)

  defp z5_take(acc, 0, _z2_buffer, _z0_data), do: done(acc)

  defp z5_take(acc, z5_n, z2_buffer, z0_data), do: z4_map(acc, z5_n, z2_buffer, z0_data)

  defp done(acc), do: :lists.reverse(acc)
end
