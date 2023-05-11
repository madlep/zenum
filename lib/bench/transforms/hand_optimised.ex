defmodule Bench.Transforms.HandOptimised do
  def run(data), do: do_opt([], 20, [], data)

  # take finished - got 20 values
  defp do_opt(z5_acc, 0, _z2_acc, _z0_data), do: :lists.reverse(z5_acc)

  # take finished - no more data
  defp do_opt(z5_acc, _z5_n, [], []), do: :lists.reverse(z5_acc)

  # take + map + filter true + flat_map when flat_map buffer is empty and needs new value from data
  defp do_opt(z5_acc, z5_n, [], [%{reference: "REF3", events: z2_acc} | z0_data]),
    do: do_opt(z5_acc, z5_n, z2_acc, z0_data)

  # take + map + filter false when flat_map buffer is empty and needs new value from data
  defp do_opt(z5_acc, z5_n, [], [_ | z0_data]), do: do_opt(z5_acc, z5_n, [], z0_data)

  # take + flat_map + filter true + map when flat map buffer has values
  defp do_opt(
         z5_acc,
         z5_n,
         [%{included?: true, event_id: event_id, parent_id: parent_id} | z2_acc],
         z0_data
       ),
       do: do_opt([{event_id, parent_id} | z5_acc], z5_n - 1, z2_acc, z0_data)

  # take + flat_map + filter false when flat map buffer has values
  defp do_opt(z5_acc, z5_n, [_ | z2_acc], z0_data), do: do_opt(z5_acc, z5_n, z2_acc, z0_data)
end
