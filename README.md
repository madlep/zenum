# Zenum

Zero cost abstraction replacment for Elixir `Enum` and `Stream`

Faster and lower memory usage than both.

## Example
```elixir
    use Zenum

    data = [1, 2, 3, 4, 1, 2, 3]

    actual =
      data
      |> Zenum.from_list()
      |> Zenum.map(fn x -> x * 2 end)
      |> Zenum.filter(fn x -> x <= 6 end)
      |> Zenum.to_list()

    # [2, 4, 6, 2, 4, 6]
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

