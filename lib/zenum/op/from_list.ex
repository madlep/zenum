defmodule Zenum.Op.FromList do
  alias __MODULE__
  alias Zenum.Op

  import Zenum.AST

  defstruct [:n, :data]

  def build_op(n, [data]), do: %FromList{n: n, data: data}

  defimpl Zenum.Op do
    use Op.DefaultImpl

    def state(op = %FromList{}) do
      [{op.n, :from_list_data, op.data}]
    end

    def next_ast(op = %FromList{}, ops, id, params, context) do
      data_param = fun_param_name(op.n, :from_list_data)
      data = Macro.var(data_param, context)
      from_list_data2 = Macro.var(:from_list_data2, context)

      quote context: context, generated: true do
        case unquote(data) do
          [value_from_list_data | from_list_data2] ->
            unquote(push_fun_name(id, op.n - 1))(
              unquote_splicing(set_param(params, data_param, from_list_data2)),
              value_from_list_data
            )

          [] ->
            unquote(return_ast(op, ops, id, params, context))
        end
      end
    end

    # no-op - shouldn't be called
    def push_ast(_op = %FromList{}, _ops, _id, _params, _context, _v), do: []

    def push_fun_ast(_op = %FromList{}, _ops, _id, _params, _context), do: []
  end
end
