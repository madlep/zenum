alias Bench.Transforms, as: T


variants = [
  # T.Enum,
  # T.HandOptimised,
  # T.HandOptimisedIfFilter,
  # T.Stream,
  # T.ZenumArgsState,
  # T.ZenumArgsStateTCO,
  T.ZenumArgsStateTCOMacro2,
  T.ZenumArgsStateTCOMacro,
  # T.ZenumArgsStateTCOExpanded,
  # T.ZenumFlatTupleState,
  # T.ZenumIter,
  # T.ZenumListStackState,
  # T.ZenumNestedTupleMacroState,
  # T.ZenumNestedTupleState
]

IO.puts "\nSanity checking variants: #{inspect(variants)}"
sanity_check_data = T.build_data(100)
expected_transformed_data = T.Enum.run(sanity_check_data, 500)

for mod <- variants do
  if mod.run(sanity_check_data, 500) != expected_transformed_data do
    expected_transformed_data |> IO.inspect()
    mod.run(sanity_check_data) |> IO.inspect()
    raise "#{inspect(mod)} FAIL"
  else
    IO.puts "- #{inspect(mod)} OK"
  end
end
IO.puts("")


Benchee.run(
  variants |> Enum.map(&{inspect(&1), fn {input, take_n} -> &1.run(input, take_n) end}),
  warmup: 2,
  time: 5,
  # memory_time: 10,
  # reduction_time: 10,
  # profile_after: :fprof,
  formatters: [ {Benchee.Formatters.Console, extended_statistics: false} ],
  inputs: [
    %{n: 10, take_n: 10},
    %{n: 10, take_n: 1000},
    %{n: 1000, take_n: 10},
    %{n: 1000, take_n: 1000},
  ] |> Enum.map(fn input -> {"n=#{input.n} take_n=#{input.take_n}", input} end) |> Enum.into(%{}),
  before_scenario: fn input ->
    {T.build_data(input.n), input.take_n}
  end
)
