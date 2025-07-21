defmodule ExampleZEnum do
  use ZEnum

  def do_stuff(input) do
    input
    |> ZEnum.from_list()
    |> ZEnum.map(fn x -> x * 2 end)
    |> ZEnum.filter(fn x -> x <= 6 end)
  end
end
