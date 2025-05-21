defmodule Zenum.AST do
  @type zenum_id() :: non_neg_integer()

  @type op_number() :: non_neg_integer()
  @type op_name() :: atom()

  @type params() :: [param_name()]
  @type param_name() :: atom()
  @type param_value_ast() :: Macro.t()

  @type state() :: [state_param()]
  @type state_param() :: {op_number(), op_name(), param_name(), param_value_ast()}

  def push_fn(id, n), do: :"__z_#{id}_#{n}_push__"
  def next_fn(id, n), do: :"__z_#{id}_#{n}_next__"
  def return_fn(id, n), do: :"__z_#{id}_#{n}_return__"
  def param(n, name), do: :"op_#{n}_#{name}"

  def set_param(params_ast, param, new_param_ast) do
    i = Enum.find_index(params_ast, fn {p, _, _} -> p == param end)
    List.replace_at(params_ast, i, new_param_ast)
  end
end
