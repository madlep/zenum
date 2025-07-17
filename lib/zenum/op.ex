defprotocol ZEnum.Op do
  @type op_number() :: non_neg_integer()
  @type op_name() :: atom()

  @type params() :: [param_name_ast()]
  @type param_name() :: atom()
  @type param_name_ast() :: {param_name(), [], context :: atom()}
  @type param_value_ast() :: Macro.t()

  @type state() :: [state_param()]
  @type state_param() :: {op_number(), param_name(), param_value_ast()}

  @type zstate() :: :cont | :halt
  @type push_value() :: {zstate(), Macro.t()}

  @doc """
  Return the ID of this zenum chain in the containing module
  """
  @spec zenum_id(t()) :: ZEnum.id()
  def zenum_id(op)

  @doc """
  Return the sequence number of the operation in this zenum chain
  """
  @spec op_number(t()) :: op_number()
  def op_number(op)

  @doc """
  Build the initial state function arguments for the operation that will be
  passed to generated tail recursive functions for the zenum chain macro
  output.
  """
  @spec state(t()) :: state()
  def state(op)

  @doc """
  Generate the AST output for the operation to fetch and process the next
  element. This will typically delegate back along the zenum chain to where
  values are produced for most operations, but will do the actual logic to grab
  elements out of what ever the original source input is for the zenum chain.
  """
  @spec next_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) ::
          Macro.output()
  def next_ast(op, ops, params, context)

  @doc """
  Generate the AST output for pushing a generated/transformed value along the
  zenum chain to the consumer of this op for further processing in that op. The
  main logic of most operations will be implemented here.
  """
  @spec push_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom(), push_value()) ::
          Macro.output()
  def push_ast(op, ops, params, context, v)

  @doc """
  Generate the AST for a function that explicitly contains the logic for a push
  operation (instead of just inserting generated AST code inline). This is
  required for operations that recursively call back along the zenum chain
  potentially resulting in an infinite recursive loop when generating the AST.
  """
  @spec push_fun_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) ::
          Macro.output()
  def push_fun_ast(op, ops, params, context)

  @doc """
  Generate the AST to handle the zenum chain being terminated by a producing
  operation pushing values to this operation. Typically will delegate to the
  consuming operation for most operations, but can also allow cleanup
  operations to be done. For fhe final operation in a zenum chain, will output
  the actual final value to be returned to the caller.
  """
  @spec return_ast(t(), ops :: ZEnum.Zipper.t(t()), params(), context :: atom()) :: Macro.output()
  def return_ast(op, ops, params, context)
end
