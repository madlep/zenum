defmodule Bench.Transforms.HandOptimised do
  def run(data), do: do_opt([], data, [], 20)

  defp do_opt(_events, _records, acc, 0), do: :lists.reverse(acc)
  defp do_opt([], [], acc, _n), do: :lists.reverse(acc)

  defp do_opt([], [%{reference: "REF3", events: events} | rest], acc, n),
    do: do_opt(events, rest, acc, n)

  defp do_opt([], [_ignore_record | rest], acc, n), do: do_opt([], rest, acc, n)

  defp do_opt(
         [%{event_id: event_id, parent_id: parent_id, included?: true} | rest],
         records,
         acc,
         n
       ),
       do: do_opt(rest, records, [{event_id, parent_id} | acc], n - 1)

  defp do_opt([_skip_event | rest], records, acc, n), do: do_opt(rest, records, acc, n)
end
