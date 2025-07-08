defmodule ExampleZenum do
  use Zenum, debug: false

  def do_stuff(input) do
    input
    |> Zenum.from_list()
    |> Zenum.map(fn x -> x * 2 end)
    |> Zenum.filter(fn x -> x <= 6 end)
    |> Zenum.to_list()
  end
end
