defprotocol Zenum.Op do
  alias Zenum.AST

  @spec state(t()) :: AST.state()
  def state(op)

  @spec next_fn_ast(t(), AST.zenum_id(), AST.params(), context :: atom()) :: Macro.output()
  def next_fn_ast(op, id, params, context)

  @spec push_fn_ast(t(), AST.zenum_id(), AST.params(), context :: atom()) :: Macro.output()
  def push_fn_ast(op, id, params, context)

  @spec return_fn_ast(t(), AST.zenum_id(), AST.params(), context :: atom()) :: Macro.output()
  def return_fn_ast(op, id, params, context)
end
