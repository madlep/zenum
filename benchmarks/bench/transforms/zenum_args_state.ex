defmodule Bench.Transforms.ZenumArgsState do
  def run(data, take_n), do: z5_take([], take_n, [], data)

  defp z1_filter([]), do: :done

  defp z1_filter([value | values]) do
    if value.reference == :REF3 do
      {value, values}
    else
      z1_filter(values)
    end
  end

  defp z2_flat_map([value | values], z0_data), do: {value, values, z0_data}

  defp z2_flat_map(_, z0_data) do
    case z1_filter(z0_data) do
      {value, new_z0_data} -> z2_flat_map(value.events, new_z0_data)
      done -> done
    end
  end

  defp z3_filter(z2_acc, z0_data) do
    case z2_flat_map(z2_acc, z0_data) do
      {value, new_z2_acc, new_z0_data} ->
        if value.included? do
          {value, new_z2_acc, new_z0_data}
        else
          z3_filter(new_z2_acc, new_z0_data)
        end

      done ->
        done
    end
  end

  defp z4_map(z2_acc, z0_data) do
    case z3_filter(z2_acc, z0_data) do
      {value, new_z2_acc, new_z0_data} ->
        {{value.event_id, value.parent_id}, new_z2_acc, new_z0_data}

      done ->
        done
    end
  end

  defp z5_take(z5_acc, 0, _z2_acc, _z0_data), do: :lists.reverse(z5_acc)

  defp z5_take(z5_acc, z5_n, z2_acc, z0_data) do
    case z4_map(z2_acc, z0_data) do
      {value, new_z2_acc, new_z0_data} ->
        z5_take([value | z5_acc], z5_n - 1, new_z2_acc, new_z0_data)

      _done ->
        :lists.reverse(z5_acc)
    end
  end
end
