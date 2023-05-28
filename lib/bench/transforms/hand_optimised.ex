defmodule Bench.Transforms.HandOptimised do
  def run(data), do: do_opt([], 20, [], data)

  # take finished (take_n == 0) OR end of data (flatmap_buffer == [] AND data == [])
  defp do_opt(take_acc, take_n, flatmap_buffer, data)
       when take_n == 0 or (flatmap_buffer == [] and data == []),
       do: :lists.reverse(take_acc)

  # flatmap + filter true + map when flatmap_buffer is empty
  # flatmap buffer is empty, and there is more data, AND the head of that data reference matches (filter), AND there are events on it (map)
  defp do_opt(take_acc, take_n, [], [%{reference: :REF3, events: flatmap_buffer} | data]),
    do: do_opt(take_acc, take_n, flatmap_buffer, data)

  # flatmap + filter false when flatmap_buffer is empty
  # skip value, and get next one
  defp do_opt(take_acc, take_n, [], [_ | data]), do: do_opt(take_acc, take_n, [], data)

  # take + flat_map + filter true + map when flat map buffer has values
  defp do_opt(
         take_acc,
         take_n,
         [%{included?: true, event_id: event_id, parent_id: parent_id} | flatmap_buffer],
         data
       ),
       do: do_opt([{event_id, parent_id} | take_acc], take_n - 1, flatmap_buffer, data)

  # take + flat_map + filter false when flat map buffer has values
  defp do_opt(take_acc, take_n, [_ | flatmap_buffer], data),
    do: do_opt(take_acc, take_n, flatmap_buffer, data)
end
