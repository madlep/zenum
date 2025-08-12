defmodule ZEnum.Op.Count do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, [f]), do: %Count{id: id, f: f}

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %Count{}) do
      [
        {:count_acc, 0}
      ] ++ if op.f, do: [{:count_f, op.f}], else: []
    end

    def push_ast(op = %Count{}, ops, params, context, {zstate, value}) do
      acc = Macro.var(fun_param_name(op.n, :count_acc), context)

      acc_bump_ast =
        if op.f do
          quote generated: true, context: context do
            if unquote(op.f).(unquote_splicing([value])) do
              unquote(acc) + 1
            else
              unquote(acc)
            end
          end
        else
          quote generated: true, context: context do
            unquote(acc) + 1
          end
        end

      quote generated: true, context: context do
        unquote(acc) = unquote(acc_bump_ast)

        unquote(next_or_return(ops, params, context, zstate))
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
