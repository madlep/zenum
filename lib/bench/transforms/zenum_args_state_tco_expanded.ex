defmodule Bench.Transforms.ZenumArgsStateTCOExpanded do
  # defmacrop z6_to_list_return(z6_list) do
  #   quote do
  #     :lists.reverse(unquote(z6_list))
  #   end
  # end

  # defmacrop z5_take_return(z6_list, _z5_n) do
  #   quote do
  #     z6_to_list_return(unquote(z6_list))
  #   end
  # end

  # defmacrop z4_map_return(z6_list, z5_n) do
  #   quote do
  #     z5_take_return(unquote(z6_list), unquote(z5_n))
  #   end
  # end

  # defmacrop z3_filter_return(z6_list, z5_n) do
  #   quote do
  #     z4_map_return(unquote(z6_list), unquote(z5_n))
  #   end
  # end

  # defmacrop z2_flat_map_return(z6_list, z5_n, _z2_buffer) do
  #   quote do
  #     z3_filter_return(unquote(z6_list), unquote(z5_n))
  #   end
  # end

  # defmacrop z1_filter_return(z6_list, z5_n, z2_buffer) do
  #   quote do
  #     z2_flat_map_return(unquote(z6_list), unquote(z5_n), unquote(z2_buffer))
  #   end
  # end

  # defmacrop z0_from_list(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     case unquote(z0_list) do
  #       [value | new_z0_list] ->
  #         z1_filter_push(value, unquote(z6_list), unquote(z5_n), unquote(z2_buffer), new_z0_list)

  #       _ ->
  #         :lists.reverse(unquote(z6_list))
  #     end
  #   end
  # end

  # defmacrop z1_filter(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     z0_from_list(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #   end
  # end

  # defmacrop z2_flat_map(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     case unquote(z2_buffer) do
  #       [value | new_z2_buffer] ->
  #         z3_filter_push(value, unquote(z6_list), unquote(z5_n), new_z2_buffer, unquote(z0_list))

  #       _ ->
  #         z1_filter(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #     end
  #   end
  # end

  # defmacro z3_filter(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     z2_flat_map(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #   end
  # end

  # defmacrop z4_map(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     z3_filter(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #   end
  # end

  # defmacrop z5_take(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     if unquote(z5_n) == 0 do
  #       :lists.reverse(unquote(z6_list))
  #     else
  #       z4_map(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #     end
  #   end
  # end

  # defmacrop z6_to_list(z6_list, z5_n, z2_buffer, z0_list) do
  #   quote do
  #     z5_take(unquote(z6_list), unquote(z5_n), unquote(z2_buffer), unquote(z0_list))
  #   end
  # end

  defp z1_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.reference == :REF3 do
      z2_flat_map_push(value, z6_list, z5_n, z2_buffer, z0_list)
    else
      # z1_filter

      # z0_from_list
      case z0_list do
        [value | new_z0_list] ->
          z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

        _ ->
          :lists.reverse(z6_list)
      end
    end
  end

  defp z2_flat_map_push(value, z6_list, z5_n, _z2_buffer, z0_list) do
    z2_buffer = value.events
    # z2_flat_map
    case z2_buffer do
      [value | new_z2_buffer] ->
        z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

      _ ->
        # z1_filter

        # z0_from_list
        case z0_list do
          [value | new_z0_list] ->
            z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

          _ ->
            :lists.reverse(z6_list)
        end
    end
  end

  defp z3_filter_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    if value.included? do
      value = {value.event_id, value.parent_id}
      z6_list = [value | z6_list]
      z5_n = z5_n - 1

      if z5_n == 0 do
        :lists.reverse(z6_list)
      else
        # z4_map

        # z3_filter

        # z2_flat_map
        case z2_buffer do
          [value | new_z2_buffer] ->
            z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

          _ ->
            # z1_filter

            # z0_from_list
            case z0_list do
              [value | new_z0_list] ->
                z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

              _ ->
                :lists.reverse(z6_list)
            end
        end
      end
    else
      # z3_filter

      # z2_flat_map
      case z2_buffer do
        [value | new_z2_buffer] ->
          z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

        _ ->
          # z1_filter

          # z0_from_list
          case z0_list do
            [value | new_z0_list] ->
              z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

            _ ->
              :lists.reverse(z6_list)
          end
      end
    end
  end

  defp z4_map_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    value = {value.event_id, value.parent_id}
    z6_list = [value | z6_list]
    z5_n = z5_n - 1

    if z5_n == 0 do
      :lists.reverse(z6_list)
    else
      # z4_map

      # z3_filter

      # z2_flat_map
      case z2_buffer do
        [value | new_z2_buffer] ->
          z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

        _ ->
          # z1_filter

          # z0_from_list
          case z0_list do
            [value | new_z0_list] ->
              z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

            _ ->
              :lists.reverse(z6_list)
          end
      end
    end
  end

  defp z5_take_push(value, z6_list, z5_n, z2_buffer, z0_list) do
    z6_list = [value | z6_list]
    z5_n = z5_n - 1

    if z5_n == 0 do
      :lists.reverse(z6_list)
    else
      # z4_map

      # z3_filter

      # z2_flat_map
      case z2_buffer do
        [value | new_z2_buffer] ->
          z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

        _ ->
          # z1_filter

          # z0_from_list
          case z0_list do
            [value | new_z0_list] ->
              z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

            _ ->
              :lists.reverse(z6_list)
          end
      end
    end
  end

  def run(data) do
    z6_list = []
    z5_n = 20
    z2_buffer = []
    z0_list = data

    # z6_to_list

    # z5_take
    if z5_n == 0 do
      :lists.reverse(z6_list)
    else
      # z4_map

      # z3_filter

      # z2_flat_map
      case z2_buffer do
        [value | new_z2_buffer] ->
          z3_filter_push(value, z6_list, z5_n, new_z2_buffer, z0_list)

        _ ->
          # z1_filter

          # z0_from_list
          case z0_list do
            [value | new_z0_list] ->
              z1_filter_push(value, z6_list, z5_n, z2_buffer, new_z0_list)

            _ ->
              :lists.reverse(z6_list)
          end
      end
    end
  end
end
