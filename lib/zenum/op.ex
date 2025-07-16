defprotocol ZEnum.Op do
  @type op_number() :: non_neg_integer()
  @type op_name() :: atom()

  @type params() :: [param_name()]
  @type param_name() :: atom()
  @type param_value_ast() :: Macro.t()

  @type state() :: [state_param()]
  @type state_param() :: {op_number(), param_name(), param_value_ast()}

  @spec zenum_id(t()) :: ZEnum.id()
  def zenum_id(op)

  @spec op_number(t()) :: op_number()
  def op_number(op)

  @spec state(t()) :: state()
  def state(op)

  @spec next_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) ::
          Macro.output()
  def next_ast(op, ops, params, context)

  @spec push_ast(
          t(),
          ops :: ZEnum.Zipper.t(t()),
          params(),
          context :: atom(),
          v :: {:cont, Macro.t()} | {:halt, Macro.t()}
        ) :: Macro.output()
  def push_ast(op, ops, params, context, v)

  @spec push_fun_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) ::
          Macro.output()
  def push_fun_ast(op, ops, params, context)

  @spec return_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) :: Macro.output()
  def return_ast(op, ops, params, context)
end
