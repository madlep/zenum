defmodule Zenum.Examples.Simple do
  use Zenum, debug_ast: true

  def bar(input) do
    input
    |> Zenum.from_list()
    |> Zenum.map(fn x -> x * 2 end)
    |> Zenum.filter(fn x -> x <= 6 end)
    |> Zenum.to_list()
  end
end
