defmodule Bench.Transforms.Enum do
  def run(data, take_n) do
    data
    |> Enum.filter(fn record -> record.reference == :REF3 end)
    |> Enum.flat_map(fn record -> record.events end)
    |> Enum.filter(fn event -> event.included? end)
    |> Enum.map(fn event -> {event.event_id, event.parent_id} end)
    |> Enum.take(take_n)
  end
end
