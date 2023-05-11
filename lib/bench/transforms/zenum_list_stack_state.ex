defmodule Bench.Transforms.ZenumListStackState do
  def run(data),
    do:
      z5_take([
        [],
        0,
        []
        | data
      ])

  defp z1_filter([value | values] = data) do
    if value.reference == "REF3" do
      data
    else
      z1_filter(values)
    end
  end

  defp z1_filter([]), do: :done

  defp z2_flat_map([[value | values] | state]), do: [value | [values | state]]

  defp z2_flat_map([[] | state]) do
    case z1_filter(state) do
      [value | new_state] -> z2_flat_map([value.events | new_state])
      :done -> :done
    end
  end

  defp z3_filter(state) do
    case z2_flat_map(state) do
      [value | new_state] = data ->
        if value.included? do
          data
        else
          z3_filter(new_state)
        end

      :done ->
        :done
    end
  end

  defp z4_map(state) do
    case z3_filter(state) do
      [value | new_state] -> [{value.event_id, value.parent_id} | new_state]
      :done -> :done
    end
  end

  defp z5_take([values, 20 | _state]), do: :lists.reverse(values)

  defp z5_take([values, n | state]) do
    case z4_map(state) do
      [value | new_state] -> z5_take([[value | values], n + 1 | new_state])
      :done -> :lists.reverse(values)
    end
  end
end
