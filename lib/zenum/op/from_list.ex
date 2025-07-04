defmodule Zenum.Op.FromList do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :data]

  def build_op(n, [data]), do: %FromList{n: n, data: data}

  defimpl Zenum.Op do
    def state(op = %FromList{}) do
      [{op.n, :from_list, :from_list_data, op.data}]
    end

    def next_ast(op = %FromList{}, ops, id, params, context) do
      data = fun_param_name(op.n, :from_list_data)

      quote context: context, generated: true do
        case unquote(Macro.var(data, context)) do
          [value_from_list_data | from_list_data2] ->
            unquote(push_fun_name(id, op.n - 1))(
              unquote_splicing(set_param(params, data, Macro.var(:from_list_data2, context))),
              value_from_list_data
            )

          [] ->
            unquote(return_ast(op, ops, id, params, context))
        end
      end
    end

    # no-op - shouldn't be called
    def push_ast(_op = %FromList{}, _ops, _id, _params, _context, _v) do
      []
    end

    def push_fun_ast(_op = %FromList{}, _ops, _id, _params, _context) do
      []
    end

    def return_ast(_op = %FromList{}, ops, id, params, context) do
      ops2 = Zipper.prev!(ops)
      Op.return_ast(Zipper.head!(ops2), ops2, id, params, context)
    end
  end
end
