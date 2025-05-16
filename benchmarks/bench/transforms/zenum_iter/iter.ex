defprotocol Bench.Transforms.ZenumIter.Iter do
  @spec next(t()) :: {T, t()} | :done when T: var
  def next(z)
end
