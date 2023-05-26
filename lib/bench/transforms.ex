defmodule Bench.Transforms do
  def build_data(n) do
    for parent_id <- 0..n, reference <- [:REF1, :REF2, :REF3, :REF4] do
      events =
        for event_id <- 0..min(parent_id, 100) do
          %{parent_id: parent_id, event_id: event_id, included?: rem(event_id, 3) == 0}
        end

      %{parent_id: parent_id, events: events, reference: reference}
    end
  end
end
