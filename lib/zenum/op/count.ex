defmodule ZEnum.Op.Count do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.AST.Inline
  import ZEnum.AST

  defstruct [:id, :n, :f, :limit]

  def build_op(id, [f, limit]) do
    f = f && Inline.maybe_inline_function(f)
    limit = limit && Inline.maybe_inline(limit)

    %Count{id: id, f: f, limit: limit}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %Count{}) do
      [
        {:count_acc, 0}
      ] ++
        case op.f do
          {:not_inlined, f} -> [{:count_f, f}]
          _ -> []
        end ++
        case op.limit do
          {:not_inlined, limit} -> [{:count_limit, limit}]
          _ -> []
        end
    end

    def push_ast(op = %Count{}, ops, params, context, {zstate, value}) do
      acc_arg = Macro.var(fun_param_name(op.n, :count_acc), context)
      f_arg = Macro.var(fun_param_name(op.n, :count_f), context)
      limit_arg = Macro.var(fun_param_name(op.n, :count_limit), context)

      acc_bump_ast =
        if op.f do
          quote generated: true, context: context do
            if unquote(Inline.call_fun(op.f, [value], f_arg, context)) do
              unquote(acc_arg) + 1
            else
              unquote(acc_arg)
            end
          end
        else
          quote generated: true, context: context do
            unquote(acc_arg) + 1
          end
        end

      limit_return_ast =
        if op.limit do
          quote generated: true, context: context do
            if unquote(acc_arg) >= unquote(Inline.ast(op.limit, limit_arg)) do
              unquote(return_ast(op, ops, params, context))
            else
              unquote(next_or_return(ops, params, context, zstate))
            end
          end
        else
          next_or_return(ops, params, context, zstate)
        end

      quote generated: true, context: context do
        unquote(acc_arg) = unquote(acc_bump_ast)
        unquote(limit_return_ast)
      end
    end

    def return_ast(op = %Count{}, _ops, _params, context) do
      acc = Macro.var(fun_param_name(op.n, :count_acc), context)

      quote generated: true, context: context do
        unquote(acc)
      end
    end
  end
end
