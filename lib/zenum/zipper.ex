defmodule Zenum.Zipper do
  @opaque t(v) :: {prev :: list(v), next :: list(v)}

  @spec new(list(v)) :: t(v) when v: var
  def new(list), do: {[], list}

  @spec current!(t(v)) :: v when v: var
  def current!({_prev, []}), do: raise("no current value")
  def current!({_prev, [v | _next]}), do: v

  @spec current(t(v)) :: {:ok, t(v)} | {:error, :no_current} when v: var
  def current({_prev, []}), do: {:error, :no_current}
  def current({_prev, [v | _next]}), do: {:ok, v}

  @spec prev!(t(v)) :: t(v) when v: var
  def prev!({[], _next}), do: raise("no previous values")
  def prev!({[v | prev], next}), do: {prev, [v | next]}

  @spec prev(t(v)) :: {:ok, t(v)} | {:error, :no_previous} when v: var
  def prev({[], _next}), do: {:error, :no_previous}
  def prev({[v | prev], next}), do: {:ok, {prev, [v | next]}}

  @spec next!(t(v)) :: t(v) when v: var
  def next!({_prev, []}), do: raise("no next values")
  def next!({prev, [v | next]}), do: {[v | prev], next}

  @spec next(t(v)) :: {:ok, t(v)} | {:error, :no_next} when v: var
  def next({_prev, []}), do: {:error, :no_next}
  def next({prev, [v | next]}), do: {:ok, {[v | prev], next}}
end
