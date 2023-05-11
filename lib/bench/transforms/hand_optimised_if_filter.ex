defmodule Bench.Transforms.HandOptimisedIfFilter do
  def run(data), do: do_opt([], 20, [], data)

  # take finished - no more data
  defp do_opt(z5_acc, _n, [], []), do: :lists.reverse(z5_acc)

  # take finished - got 20 values
  defp do_opt(z5_acc, 0, _z2_acc, _z0_data), do: :lists.reverse(z5_acc)

  # take + map + filter + flat map when flat map buffer has values
  defp do_opt(z5_acc, z5_n, [value | new_z2_acc], z0_data) do
    if value.included? do
      do_opt([{value.event_id, value.parent_id} | z5_acc], z5_n - 1, new_z2_acc, z0_data)
    else
      do_opt(z5_acc, z5_n, new_z2_acc, z0_data)
    end
  end

  # flat_map + filter when flat_map buffer empty
  defp do_opt(z5_acc, z5_n, [], [value | new_z0_data]) do
    if value.reference == "REF3" do
      do_opt(z5_acc, z5_n, value.events, new_z0_data)
    else
      do_opt(z5_acc, z5_n, [], new_z0_data)
    end
  end
end
