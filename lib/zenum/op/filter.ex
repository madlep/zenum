defmodule ZEnum.Op.Filter do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.AST.Inline
  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, [f]) do
    f = f && Inline.maybe_inline_function(f)
    %Filter{id: id, f: f}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %Filter{}) do
      [] ++
        case op.f do
          {:not_inlined, f} -> [{:filter_f, f}]
          _ -> []
        end
    end

    def push_ast(op = %Filter{}, ops, params, context, {zstate, value}) do
      filter_f = Macro.var(fun_param_name(op.n, :filter_f), context)

      quote context: context, generated: true do
        if unquote(Inline.call_fun(op.f, [value], filter_f, context)) do
          unquote(push(ops, params, context, {zstate, value}))
        else
          unquote(next_or_return(ops, params, context, zstate))
        end
      end
    end
  end
end
