alias Bench.Transforms, as: T


variants = [
  # T.Enum,
  # T.HandOptimised,
  # T.HandOptimisedIfFilter,
  T.Stream,
  # T.ZenumArgsState,
  # T.ZenumArgsStateTCO,
  T.ZenumArgsStateTCOMacro,
  T.ZenumArgsStateTCOExpanded,
  # T.ZenumFlatTupleState,
  # T.ZenumIter,
  # T.ZenumListStackState,
  # T.ZenumNestedTupleMacroState,
  # T.ZenumNestedTupleState
]

sanity_check_data = T.build_data(100)
expected_transformed_data = T.Enum.run(sanity_check_data)

for mod <- variants do
  if mod.run(sanity_check_data) != expected_transformed_data do
    expected_transformed_data |> IO.inspect()
    mod.run(sanity_check_data) |> IO.inspect()
    raise "transform fail #{inspect(mod)}"
  else
    IO.puts "#{inspect(mod)} transform OK"
  end
end


Benchee.run(
  variants |> Enum.map(&{inspect(&1), fn input -> &1.run(input) end}),
  warmup: 5,
  time: 10,
  # memory_time: 10,
  reduction_time: 10,
  # profile_after: :fprof,
  formatters: [ {Benchee.Formatters.Console, extended_statistics: false} ],
  inputs: %{
    "n 10" => 10,
    #"n 100" => 100,
    #"n 1000" => 1000,
    "n 1000" => 1000,
    "n 100000" => 100000,
  },
  before_scenario: fn n ->
    T.build_data(n)
  end
)
