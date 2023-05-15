defmodule Bench.Transforms.ZenumIter do
  alias Bench.Transforms.ZenumIter.Iter
  alias Bench.Transforms.ZenumIter.ZFilter
  alias Bench.Transforms.ZenumIter.ZFlatMap
  alias Bench.Transforms.ZenumIter.ZMap
  alias Bench.Transforms.ZenumIter.ZTake

  def run(data) do
    data
    |> filter(fn record -> record.reference == "REF3" end)
    |> flat_map(fn record -> record.events end)
    |> filter(fn event -> event.included? end)
    |> map(fn event -> {event.event_id, event.parent_id} end)
    |> take(20)
    |> collect()
  end

  def filter(z, f), do: ZFilter.new(z, f)
  def flat_map(z, f), do: ZFlatMap.new(z, f)
  def map(z, f), do: ZMap.new(z, f)
  def take(z, n), do: ZTake.new(z, n)
  def collect(z), do: do_collect(z, [])

  defp do_collect(z, acc) do
    case(Iter.next(z)) do
      {value, new_z} -> do_collect(new_z, [value | acc])
      :done -> :lists.reverse(acc)
    end
  end

  defimpl Iter, for: List do
    def next([v | new_list]), do: {v, new_list}
    def next([]), do: :done
  end

  defmodule ZFilter do
    defstruct [:iter, :f]

    def new(iter, f), do: %__MODULE__{iter: iter, f: f}

    defimpl Iter do
      def next(z) do
        case do_f(z.iter, z.f) do
          {v, new_iter} -> {v, %{z | iter: new_iter}}
          other -> other
        end
      end

      defp do_f(iter, f) do
        case Iter.next(iter) do
          {v, new_iter} ->
            if f.(v) do
              {v, new_iter}
            else
              do_f(new_iter, f)
            end

          other ->
            other
        end
      end
    end
  end

  defmodule ZFlatMap do
    defstruct [:iter, :f, :buffer]

    def new(iter, f), do: %__MODULE__{iter: iter, f: f, buffer: []}

    defimpl Iter do
      def next(%{buffer: []} = z) do
        case Iter.next(z.iter) do
          {v, new_iter} -> next(%{z | iter: new_iter, buffer: z.f.(v)})
          other -> other
        end
      end

      def next(%{buffer: [v | new_buffer]} = z) do
        {v, %{z | buffer: new_buffer}}
      end
    end
  end

  defmodule ZMap do
    defstruct [:iter, :f]

    def new(iter, f), do: %__MODULE__{iter: iter, f: f}

    defimpl Iter do
      def next(z) do
        case Iter.next(z.iter) do
          {v, new_iter} -> {z.f.(v), %{z | iter: new_iter}}
          other -> other
        end
      end
    end
  end

  defmodule ZTake do
    defstruct [:iter, :n]

    def new(iter, n), do: %__MODULE__{iter: iter, n: n}

    defimpl Iter do
      def next(%{n: 0}), do: :done

      def next(z) do
        case Iter.next(z.iter) do
          {v, new_iter} -> {v, %{z | n: z.n - 1, iter: new_iter}}
          other -> other
        end
      end
    end
  end
end
