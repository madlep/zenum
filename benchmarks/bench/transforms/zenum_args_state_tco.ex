defmodule Bench.Transforms.ZenumArgsStateTCO do
  @compile {:inline,
            z0_from_list: 4, z1_filter: 4, z2_flat_map: 4, z3_filter: 4, z5_take: 4, z6_to_list: 4}
  defp z0_from_list(z6_list, z5_n, z2_buffer, z0_list) do
    case z0_list do
      [value | new_z0_list] ->
        z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

      _ ->
        z6_to_list_push(z6_list, z5_n, z2_buffer, [])
    end
  end

  defp z1_filter(z6_list, z5_n, z2_buffer, z0_list) do
    z0_from_list(z6_list, z5_n, z2_buffer, z0_list)
  end

  defp z1_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.reference == :REF3 do
      z2_flat_map_push(value, z6_list, z5_n, [], z0_list)
    else
      z1_filter(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defp z2_flat_map(z6_list, z5_n, z2_buffer, z0_list) do
    case z2_buffer do
      [value | new_z2_buffer] ->
        z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

      _ ->
        z1_filter(z6_list, z5_n, [], z0_list)
    end
  end

  defp z2_flat_map_push(value, z6_list, z5_n, [], z0_list),
    do: z2_flat_map(z6_list, z5_n, value.events, z0_list)

  defp z3_filter(z6_list, z5_n, z2_buffer, z0_list) do
    z2_flat_map(z6_list, z5_n, z2_buffer, z0_list)
  end

  defp z3_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.included? do
      z4_map_push(value, z6_list, z5_n, z2_buffer, z0_list)
    else
      z3_filter(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defp z4_map(z6_list, z5_n, z2_buffer, z0_list) do
    z3_filter(z6_list, z5_n, z2_buffer, z0_list)
  end

  defp z4_map_push(value, z6_list, z5_n, z2_buffer, z0_list),
    do: z5_take_push({value.event_id, value.parent_id}, z6_list, z5_n, z2_buffer, z0_list)

  defp z5_take(z6_list, z5_n, z2_buffer, z0_list) do
    z4_map(z6_list, z5_n, z2_buffer, z0_list)
  end

  defp z5_take_push(_value, z6_list, 0, z2_buffer, z0_list),
    do: z6_to_list_push(z6_list, 0, z2_buffer, z0_list)

  defp z5_take_push(value, z6_list, z5_n, z2_buffer, z0_list),
    do: z5_take([value | z6_list], z5_n - 1, z2_buffer, z0_list)

  defp z6_to_list(z6_list, z5_n, z2_buffer, z0_list) do
    z5_take(z6_list, z5_n, z2_buffer, z0_list)
  end

  defp z6_to_list_push(z6_list, _z5_n, _z2_buffer, _z0_list), do: :lists.reverse(z6_list)

  def run(data, take_n), do: z6_to_list([], take_n, [], data)
end
