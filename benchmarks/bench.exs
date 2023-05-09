defmodule TransformBenchCases do

  def build_data(n) do
    for parent_id <- 0..n, reference <- ["REF1", "REF2", "REF3", "REF4"] do
      events = for event_id <- 0..min(parent_id, 100) do
        %{parent_id: parent_id, event_id: event_id, included?: rem(event_id, 3) == 0}
      end
      %{parent_id: parent_id, events: events, reference: reference}
    end
  end

  def with_enum(data) do
    data
    |> Enum.filter(fn record -> record.reference == "REF3" end)
    |> Enum.flat_map(fn record -> record.events end)
    |> Enum.filter(fn event -> event.included? end)
    |> Enum.map(fn event -> {event.event_id, event.parent_id} end)
    |> Enum.take(20)
  end

  def with_stream(data) do
    data
    |> Stream.filter(fn record -> record.reference == "REF3" end)
    |> Stream.flat_map(fn record -> record.events end)
    |> Stream.filter(fn event -> event.included? end)
    |> Stream.map(fn event -> {event.event_id, event.parent_id} end)
    |> Enum.take(20)
  end

  def with_hand_optimized(data), do: do_opt([], data, [], 20)

  defp do_opt(_events, _records, acc, 0), do: :lists.reverse(acc)
  defp do_opt([], [], acc, _n), do: :lists.reverse(acc)
  defp do_opt([], [%{reference: "REF3", events: events}|rest], acc, n), do: do_opt(events, rest, acc, n)
  defp do_opt([], [_ignore_record|rest], acc, n), do: do_opt([], rest, acc, n)
  defp do_opt([%{event_id: event_id, parent_id: parent_id, included?: true}|rest], records, acc, n), do: do_opt(rest, records, [{event_id, parent_id} | acc], n - 1)
  defp do_opt([_skip_event|rest], records, acc, n), do: do_opt(rest, records, acc, n)
end

sanity_check_data = TransformBenchCases.build_data(1000)

if TransformBenchCases.with_enum(sanity_check_data) != TransformBenchCases.with_hand_optimized(sanity_check_data) do
  raise "bad data"
end

Benchee.run(
  %{
    "with_enum" => &TransformBenchCases.with_enum/1,
    "with_stream" => &TransformBenchCases.with_stream/1,
    "with_hand_optimized" => &TransformBenchCases.with_hand_optimized/1,
  },
  warmup: 10,
  time: 30,
  memory_time: 2,
  reduction_time: 2,
  formatters: [ {Benchee.Formatters.Console, extended_statistics: true} ],
  inputs: %{
    "n 10" => 10,
    "n 100" => 100,
    "n 1000" => 1000,
    #"n 10000" => 10000,
  },
  before_scenario: fn n ->
    TransformBenchCases.build_data(n)
  end
)
