defmodule ZEnum.Op.Count do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.AST.Inline
  import ZEnum.AST

  defstruct [:id, :n, :f, :limit]

  def build_op(id, [f, limit]) do
    f = if f, do: Inline.maybe_inline_function(f), else: nil
    alias ZEnum.AST.Inline
    limit = if limit, do: Inline.maybe_inline(limit), else: nil
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
        case op.f do
          {:mfa_ref, mod_ast, fun_ast, 1} ->
            quote generated: true, context: context do
              if unquote(mod_ast).unquote(fun_ast)(unquote_splicing([value])) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          {:local_fa_ref, fun_ast, 1} ->
            quote generated: true, context: context do
              if unquote(fun_ast)(unquote_splicing([value])) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          {:mf_capture, mod_ast, fun_ast, captured_args} ->
            args =
              captured_args
              |> Enum.map(fn
                {:inlined, i_ast} -> i_ast
                {:capture, n} -> Enum.at([value], n - 1)
              end)

            quote generated: true, context: context do
              if unquote(mod_ast).unquote(fun_ast)(unquote_splicing(args)) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          {:local_f_capture, fun_ast, captured_args} ->
            args =
              captured_args
              |> Enum.map(fn
                {:inlined, i_ast} -> i_ast
                {:capture, n} -> Enum.at([value], n - 1)
              end)

            quote generated: true, context: context do
              if unquote(fun_ast)(unquote_splicing(args)) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          {:anon_f, fun_ast} ->
            quote generated: true, context: context do
              if unquote(fun_ast).(unquote_splicing([value])) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          {:not_inlined, _} ->
            quote generated: true, context: context do
              if unquote(f_arg).(unquote_splicing([value])) do
                unquote(acc_arg) + 1
              else
                unquote(acc_arg)
              end
            end

          nil ->
            quote generated: true, context: context do
              unquote(acc_arg) + 1
            end
        end

      limit_return_ast =
        if op.limit do
          limit_ast =
            case op.limit do
              {:inlined, limit} -> limit
              {:not_inlined, _} -> limit_arg
            end

          quote generated: true, context: context do
            if unquote(acc_arg) >= unquote(limit_ast) do
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
