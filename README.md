# Zenum

Zero cost abstraction replacment for Elixir `Enum` and `Stream`. Faster and lower memory usage than both.

## Example

```elixir
    defmodule ExampleZenum do
      use Zenum

      def do_stuff(input) do
        input
        |> Zenum.from_list()
        |> Zenum.map(fn x -> x * 2 end)
        |> Zenum.filter(fn x -> x <= 6 end)
        |> Zenum.to_list()
      end
    end

    ExampleZenum.do_stuff([1, 2, 3, 4, 1, 2, 3])
    # outputs [2, 4, 6, 2, 4, 6]
```

Rather than creating an intermediate list like `Enum`, or using closure functions like `Stream`, `Zenum` instead generates optimised tail call recursive functions at compile time. This gives performance of crafting hand rolled functions, but hiding the complexity and state management.

The above module gets turned into something like...

```elixir
    defmodule ExampleZenum do
      def do_stuff(input) do
        [op_0_acc = [], op_3_data = input]

        case op_3_data do
          [v | new_data] -> __z_0_2__(op_0_acc, new_data, v)
          [] -> Enum.reverse(op_0_acc)
        end
      end

      defp __z_0_2__(op_0_acc, op_3_data, v) do
        v = (fn x -> x * 2 end).(v)

        if (fn x -> x <= 6 end).(v) do
          op_0_acc = [v | op_0_acc]

          case op_3_data do
            [v | new_data] -> __z_0_2__(op_0_acc, new_data, v)
            [] -> Enum.reverse(op_0_acc)
          end
        else
          case op_3_data do
            [v | new_data] -> __z_0_2__(op_0_acc, new_data, v)
            [] -> Enum.reverse(op_0_acc)
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

