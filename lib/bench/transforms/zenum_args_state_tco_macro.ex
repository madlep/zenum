defmodule Bench.Transforms.ZenumArgsStateTCOMacro do
  # macro construction causes incorrect no_match error in run/1. If this code
  # is regular def functions, there's no warning. Macro hardcodes the form
  # where it is called though, so it doesn't think the [h|t] form can ever
  # match (it won't right there - but it will when called elsewhere)
  @dialyzer {:no_match, run: 1}

  defmacrop return(z6_list) do
    quote do
      :lists.reverse(unquote(z6_list))
    end
  end

  defmacrop z0_from_list(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      case unquote(z0_list) do
        [value | new_z0_list] ->
          z1_filter_push(value, unquote(z6_list), unquote(z5_n), unquote(z2_buffer), new_z0_list)

        _ ->
          return(unquote(z6_list))
      end
    end
  end

  defmacrop z1_filter(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z0_from_list(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z2_flat_map(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      case unquote(z2_buffer) do
        [value | new_z2_buffer] ->
          z3_filter_push(value, unquote(z6_list), unquote(z5_n), new_z2_buffer, unquote(z0_list))

        _ ->
          z1_filter(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
      end
    end
  end

  defmacro z3_filter(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z2_flat_map(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z4_map(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z3_filter(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defmacrop z5_take(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      if unquote(z5_n) == 0 do
        return(unquote(z6_list))
      else
        z4_map(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
      end
    end
  end

  defmacrop z6_to_list(z6_list, z5_n, z2_buffer, z0_list) do
    quote do
      z5_take(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
    end
  end

  defp z1_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.reference == :REF3 do
      z2_flat_map_push(value, z6_list, z5_n, z2_buffer, z0_list)
    else
      z1_filter(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defp z2_flat_map_push(value, z6_list, z5_n, _z2_buffer, z0_list),
    do: z2_flat_map(z6_list, z5_n, value.events, z0_list)

  defp z3_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.included? do
      z4_map_push(value, z6_list, z5_n, z2_buffer, z0_list)
    else
      z3_filter(z6_list, z5_n, z2_buffer, z0_list)
    end
  end

  defp z4_map_push(value, z6_list, z5_n, z2_buffer, z0_list),
    do: z5_take_push({value.event_id, value.parent_id}, z6_list, z5_n, z2_buffer, z0_list)

  defp z5_take_push(value, z6_list, z5_n, z2_buffer, z0_list),
    do: z5_take([value | z6_list], z5_n - 1, z2_buffer, z0_list)

  def run(data), do: z6_to_list([], 20, [], data)
end
