defmodule Bench.Transforms do
  def build_data(n) do
    for id <- 0..n, reference <- [:REF1, :REF2, :REF3, :REF4] do
      events =
        for event_id <- 0..min(id, 100) do
          %{parent_id: id, event_id: event_id, included?: rem(event_id, 3) == 0}
        end

      %{id: id, events: events, reference: reference}
    end
  end
end
