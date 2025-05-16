defmodule Bench.Transforms.Stream do
  def run(data, take_n) do
    data
    |> Stream.filter(fn record -> record.reference == :REF3 end)
    |> Stream.flat_map(fn record -> record.events end)
    |> Stream.filter(fn event -> event.included? end)
    |> Stream.map(fn event -> {event.event_id, event.parent_id} end)
    |> Stream.take(take_n)
    |> Enum.to_list()
  end
end
