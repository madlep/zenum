alias Bench.Transforms, as: T

sanity_check_data = T.build_data(100)

if T.Enum.run(sanity_check_data) != T.HandOptimised.run(sanity_check_data) do
  raise "hand opt error"
end

if T.Enum.run(sanity_check_data) != T.ZenumNestedTupleState.run(sanity_check_data) do
  raise "zeunm nested tuple state error"
end

if T.Enum.run(sanity_check_data) != T.ZenumListStackState.run(sanity_check_data) do
  raise "zeunm list stack state error"
end

Benchee.run(
  %{
    #"enum" => &T.Enum.run/1,
    #"stream" => &T.Stream.run/1,
    #"hand optimised" => &T.HandOptimised.run/1,
    "zenum nested tuple state" => &T.ZenumNestedTupleState.run/1,
    "zenum list stack state" => &T.ZenumListStackState.run/1,
  },
  warmup: 5,
  time: 10,
  # memory_time: 2,
  #reduction_time: 2,
  formatters: [ {Benchee.Formatters.Console, extended_statistics: true} ],
  inputs: %{
    "n 10" => 10,
    #"n 100" => 100,
    #"n 1000" => 1000,
    "n 10000" => 10000,
  },
  before_scenario: fn n ->
    T.build_data(n)
  end
)
