defmodule Zenum.Ops.FromList do
  import Zenum.AST

  defstruct [:n, :data]

  def build_op(n, [data]), do: %__MODULE__{n: n, data: data}

  def state(op = %__MODULE__{}) do
    [{op.n, :from_list, :data, op.data}]
  end

  # no-op - shouldn't be called
  def push_fn_ast(_op = %__MODULE__{}, _id, _params, _context) do
    []
  end

  def return_fn_ast(op = %__MODULE__{}, id, params, context) do
    quote context: context do
      def unquote(return_fn(id, op.n))(unquote_splicing(params)) do
        unquote(return_fn(id, op.n - 1))(unquote_splicing(params))
      end
    end
  end

  def next_fn_ast(op = %__MODULE__{}, id, params, context) do
    data = param(op.n, :data)

    quote context: context do
      def unquote(next_fn(id, op.n))(unquote_splicing(params)) do
        case unquote(Macro.var(data, context)) do
          [value | new_data] ->
            unquote(push_fn(id, op.n - 1))(
              unquote_splicing(set_param(params, data, Macro.var(:new_data, context))),
              value
            )

          [] ->
            unquote(return_fn(id, op.n))(unquote_splicing(params))
        end
      end
    end
  end
end
