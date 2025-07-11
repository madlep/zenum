# ZEnum

Zero cost abstraction replacment for Elixir `Enum` and `Stream`. Faster and lower memory usage than both.

## Example

```elixir
    defmodule ExampleZEnum do
      use ZEnum

      def do_stuff(input) do
        input
        |> ZEnum.from_list()
        |> ZEnum.map(fn x -> x * 2 end)
        |> ZEnum.filter(fn x -> x <= 6 end)
      end
    end

    ExampleZEnum.do_stuff([1, 2, 3, 4, 1, 2, 3])
    # outputs [2, 4, 6, 2, 4, 6]
```

Rather than creating an intermediate list like `Enum`, or using closure functions like `Stream`, `ZEnum` instead generates optimised tail call recursive functions at compile time. This gives performance of crafting hand rolled functions, but hiding the complexity and state management.

The above module gets turned into something like...

```elixir
    defmodule ExampleZEnum do
      def do_stuff(input) do
        [op_0_to_list_acc = [], op_3_from_list_data = input]

        case op_3_from_list_data do
          [value_from_list_data | from_list_data2] ->
            __z_0_2__(op_0_to_list_acc, from_list_data2, value_from_list_data)

          [] ->
            Enum.reverse(op_0_to_list_acc)
        end
     end

      defp __z_0_2__(op_0_to_list_acc, op_3_from_list_data, value) do
        value2 = (fn x -> x * 2 end).(value)

        if (fn x -> x <= 6 end).(value2) do
          op_0_to_list_acc = [value2 | op_0_to_list_acc]

          case op_3_from_list_data do
            [value_from_list_data | from_list_data2] ->
              __z_0_2__(op_0_to_list_acc, from_list_data2, value_from_list_data)

            [] ->
              Enum.reverse(op_0_to_list_acc)
          end
        else
          case op_3_from_list_data do
            [value_from_list_data | from_list_data2] ->
              __z_0_2__(op_0_to_list_acc, from_list_data2, value_from_list_data)

            [] ->
              Enum.reverse(op_0_to_list_acc)
          end
        end
      end
    end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zenum` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zenum, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/zenum>.

