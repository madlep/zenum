defmodule Bench.Transforms.ZenumArgsStateTCOMacro do
  # macro construction causes incorrect no_match error in run/1. If this code
  # is regular def functions, there's no warning. Macro hardcodes the form
  # where it is called though, so it doesn't think the [h|t] form can ever
  # match (it won't right there - but it will when called elsewhere)
  @dialyzer {:no_match, run: 2}

  defmacrop z6_to_list_done(z6_list) do
    quote do
      :lists.reverse(unquote(z6_list))
    end
  end

  defmacrop z5_take_done(z6_list, _z5_n) do
    quote do
      z6_to_list_done(unquote(z6_list))
    end
  end

  defmacrop z4_map_done(z6_list, z5_n) do
    quote do
      z5_take_done(unquote(z6_list), unquote(z5_n))
    end
  end

  defmacrop z3_filter_done(z6_list, z5_n) do
    quote do
      z4_map_done(unquote(z6_list), unquote(z5_n))
    end
  end

  defmacrop z2_flat_map_done(z6_list, z5_n, _z2_buffer) do
    quote do
      z3_filter_done(unquote(z6_list), unquote(z5_n))
    end
  end

  defmacrop z1_filter_done(z6_list, z5_n, z2_buffer) do
    quote do
      z2_flat_map_done(unquote(z6_list), unquote(z5_n), unquote(z2_buffer))
    end
  end

  defmacrop z0_from_list_done(z6_list, z5_n, z2_buffer, _z0_list) do
    quote do
      z1_filter_done(unquote(z6_list), unquote(z5_n), unquote(z2_buffer))
    end
  end

  def z0_from_list_next(z6_list, z5_n, z2_buffer, z0_list) do
    case z0_list do
      [value | new_z0_list] ->
        z1_filter_push(z6_list, z5_n, z2_buffer, new_z0_list, value)

      [] ->
        z0_from_list_done(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defmacrop z1_filter_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z0_from_list_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z2_flat_map_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      case unquote(z2_buffer) do
        [value | new_z2_buffer] ->
          z3_filter_push(unquote(z6_list), unquote(z5_n), new_z2_buffer, unquote(z0_list), value)

        [] ->
          z1_filter_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
      end
    end
  end

  defmacro z3_filter_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z2_flat_map_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z4_map_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z3_filter_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z5_take_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      case unquote(z5_n) do
        0 -> z5_take_done(unquote(z6_list), unquote(z5_n))
        _ -> z4_map_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
      end
    end
  end

  defmacrop z6_to_list_next(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z5_take_next(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z6_to_list_push(z6_list, z5_n, z2_buffer, z0_list, value) do
    quote do
      z5_take_next(
        [unquote(value) | unquote(z6_list)],
        unquote(z5_n),
        unquote(z2_buffer),
        unquote(z0_list)
      )
    end
  end

  defmacrop z5_take_push(z6_list, z5_n, z2_buffer, z0_list, value) do
    quote do
      z6_to_list_push(
        unquote(z6_list),
        unquote(z5_n) - 1,
        unquote(z2_buffer),
        unquote(z0_list),
        unquote(value)
      )
    end
  end

  defmacro z4_map_push(z6_list, z5_n, z2_buffer, z0_list, value) do
    quote do
      z5_take_push(
        unquote(z6_list),
        unquote(z5_n),
        unquote(z2_buffer),
        unquote(z0_list),
        (fn %{event_id: event_id, parent_id: parent_id} -> {event_id, parent_id} end).(
          unquote(value)
        )
      )
    end
  end

  defp z3_filter_push(z6_list, z5_n, z2_buffer, z0_list, value) do
    if (fn %{included?: included} -> included end).(value) do
      z4_map_push(z6_list, z5_n, z2_buffer, z0_list, value)
    else
      z3_filter_next(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defmacrop z2_flat_map_push(z6_list, z5_n, _z2_buffer, z0_list, value) do
    quote do
      z2_flat_map_next(
        unquote(z6_list),
        unquote(z5_n),
        (fn %{events: events} -> events end).(unquote(value)),
        unquote(z0_list)
      )
    end
  end

  defp z1_filter_push(z6_list, z5_n, z2_buffer, z0_list, value) do
    if (fn
          %{reference: :REF3} -> true
          _ -> false
        end).(value) do
      z2_flat_map_push(z6_list, z5_n, z2_buffer, z0_list, value)
    else
      z1_filter_next(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  def run(data, take_n) when is_list(data) do
    z6_to_list_next([], take_n, [], data)
  end
end
