alias Bench.Transforms, as: T


variants = [
  T.HandOptimised,
  T.HandOptimisedIfFilter,
  T.Stream,
  T.ZenumArgsState,
  T.ZenumFlatTupleState,
  T.ZenumListStackState,
  T.ZenumNestedTupleState
]

sanity_check_data = T.build_data(100)
expected_transformed_data = T.Enum.run(sanity_check_data)

for mod <- variants do
  if mod.run(sanity_check_data) != expected_transformed_data do
    raise "transform fail #{inspect(mod)}"
  else
    IO.puts "#{inspect(mod)} transform OK"
  end
end


Benchee.run(
  %{
    #"enum" => &T.Enum.run/1,
    "hand optimised" => &T.HandOptimised.run/1,
    "hand optimised if filter" => &T.HandOptimisedIfFilter.run/1,
    #"stream" => &T.Stream.run/1,
    "zenum args state" => &T.ZenumArgsState.run/1,
    "zenum flat tuple state" => &T.ZenumFlatTupleState.run/1,
    "zenum list stack state" => &T.ZenumListStackState.run/1,
    "zenum nested tuple state" => &T.ZenumNestedTupleState.run/1,
  },
  warmup: 10,
  time: 30,
  #memory_time: 2,
  #reduction_time: 2,
  formatters: [ {Benchee.Formatters.Console, extended_statistics: true} ],
  inputs: %{
    #"n 10" => 10,
    #"n 100" => 100,
    #"n 1000" => 1000,
    "n 10000" => 10000,
  },
  before_scenario: fn n ->
    T.build_data(n)
  end
)
