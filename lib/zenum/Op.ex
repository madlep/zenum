defprotocol Zenum.Op do
  @type op_number() :: non_neg_integer()
  @type op_name() :: atom()

  @type params() :: [param_name()]
  @type param_name() :: atom()
  @type param_value_ast() :: Macro.t()

  @type state() :: [state_param()]
  @type state_param() :: {op_number(), op_name(), param_name(), param_value_ast()}

  @spec state(t()) :: state()
  def state(op)

  @spec next_fn_ast(t(), Zenum.id(), params(), context :: atom()) :: Macro.output()
  def next_fn_ast(op, id, params, context)

  @spec push_fn_ast(t(), Zenum.id(), params(), context :: atom()) :: Macro.output()
  def push_fn_ast(op, id, params, context)

  @spec return_fn_ast(t(), Zenum.id(), params(), context :: atom()) :: Macro.output()
  def return_fn_ast(op, id, params, context)
end
