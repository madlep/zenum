defmodule ZEnum.Op.FromList do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  import ZEnum.AST

  defstruct [:id, :n, :data]

  def build_op(id, n, [data]), do: %FromList{id: id, n: n, data: data}

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %FromList{}) do
      [{op.n, :from_list_data, op.data}]
    end

    def next_ast(op = %FromList{}, ops, params, context) do
      data_param = fun_param_name(op.n, :from_list_data)
      data = Macro.var(data_param, context)
      ops_push = Zipper.prev!(ops)

      quote context: context, generated: true do
        case unquote(data) do
          [value_from_list_data | from_list_data2] ->
            unquote(push_fun_name(Zipper.head!(ops_push)))(
              unquote_splicing(
                set_param(params, data_param, Macro.var(:from_list_data2, context))
              ),
              value_from_list_data
            )

          [] ->
            unquote(return(ops, params, context))
        end
      end
    end

    # no-op - shouldn't be called
    def push_ast(_op = %FromList{}, _ops, _params, _context, _v), do: []

    def push_fun_ast(_op = %FromList{}, _ops, _params, _context), do: []
  end
end
