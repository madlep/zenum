defmodule ZEnum.AST.Inline do
  @doc """
  Generate inlined form of function if it is safe to inline - ie doesn't close over any vars from it's parent scope
  """
  @spec maybe_inline_function(Macro.t()) ::
          {:mfa_ref, mod :: Macro.t(), fun :: Macro.t(), arity :: integer()}
          | {:local_fa_ref, fun :: Macro.t(), arity :: integer()}
          | {:mf_capture, mod :: Macro.t(), fun :: Macro.t(), args :: list(inlined_arg())}
          | {:local_f_capture, fun :: Macro.t(), args :: list(inlined_arg())}
          | {:anon_f, ast :: Macro.t()}
          | {:not_inlined, ast :: Macro.t()}
  def maybe_inline_function(f)

  # &Mod.fun/arity reference eg `&String.capitalize/1`
  def maybe_inline_function(
        {:&, _, [{:/, _, [{{:., _, [mod = {:__aliases__, _, _}, fun]}, _, []}, arity]}]}
      )
      when is_integer(arity) do
    {:mfa_ref, mod, fun, arity}
  end

  # &fun/arity local reference eg `&local_do_stuff/1`
  def maybe_inline_function({:&, _, [{:/, _, [fun, arity]}]})
      when is_integer(arity) do
    {:local_fa_ref, fun, arity}
  end

  # inlineable mf capture
  # `&String.bag_distance("something", &1)` - ok
  # `&String.bag_distance(some_var, &1)` - not ok, don't have access to `some_var` when inlined
  def maybe_inline_function(
        ast =
          {:&, _,
           [
             {{:., _, [mod = {:__aliases__, _, _}, fun]}, _, args}
           ]}
      )
      when is_list(args) do
    if Enum.all?(args, &inlineable_ast?(&1, %{})) do
      {:mf_capture, mod, fun, Enum.map(args, &inline_arg/1)}
    else
      {:not_inlined, ast}
    end
  end

  # short & &1 anonymous function
  # TODO properly distinguish between short anon fns and local capture. These are identical
  # `&{&1}` AST = `{:&, [], [{:{},  [], [{:&, [], [1]}]}]}`
  # `&foo(&1)` =  `{:&, [], [{:foo, [], [{:&, [], [1]}]}]}`
  def maybe_inline_function(ast = {:&, _, [{:&, _, [1]}]}) do
    {:anon_f, ast}
  end

  # inlineable local f capture
  def maybe_inline_function(ast = {:&, _, [{fun, _, args}]})
      when is_list(args) do
    if Enum.all?(args, &inlineable_ast?(&1, %{})) do
      {:local_f_capture, fun, Enum.map(args, &inline_arg/1)}
    else
      {:not_inlined, ast}
    end
  end

  # anonymous function
  def maybe_inline_function(ast = {:fn, _, [{:->, _, [params, _body]}]}) when is_list(params) do
    if inlineable_ast?(ast, %{}) do
      {:anon_f, ast}
    else
      {:not_inlined, ast}
    end
  end

  # local var function
  def maybe_inline_function(ast = {fun_var, _, context})
      when is_atom(fun_var) and is_atom(context),
      do: {:not_inlined, ast}

  @doc """
  Mark AST as inlined if it is able to be
  """
  @spec maybe_inline(Macro.t()) :: {:inlined, Macro.t()} | {:not_inlined, Macro.t()}
  def maybe_inline(ast) do
    if inlineable_ast?(ast, %{}) do
      {:inlined, ast}
    else
      {:not_inlined, ast}
    end
  end

  @doc """
  Determine if an AST is inlinable - ie does it close over any vars from the parent scope, which won't be available if inlined into a different scope
  """
  @spec inlineable_ast?(ast :: Macro.t(), bindings :: %{Macro.t() => any()}) :: boolean()
  def inlineable_ast?(ast, bindings)

  def inlineable_ast?(ast, _bindings) when is_atom(ast), do: true

  def inlineable_ast?(ast, _bindings) when is_number(ast), do: true

  def inlineable_ast?(ast, bindings) when is_list(ast),
    do: Enum.all?(ast, &inlineable_ast?(&1, bindings))

  def inlineable_ast?(ast, _bindings) when is_binary(ast), do: true

  def inlineable_ast?({ast1, ast2}, bindings),
    do: inlineable_ast?(ast1, bindings) && inlineable_ast?(ast2, bindings)

  # handle ::/2 operator, as this has special rules around what is allowed
  def inlineable_ast?({:"::", meta, [ast1, _bitstring_args]}, bindings) when is_list(meta),
    do: inlineable_ast?(ast1, bindings)

  # handle matches in `->` with in fn / case etc
  def inlineable_ast?({:->, _, [params, body]}, bindings) when is_list(params) do
    bindings_assigned =
      params
      |> extract_pattern_match_vars()
      |> Enum.map(&{&1, true})
      |> Enum.into(bindings)

    inlineable_ast?(body, bindings_assigned)
  end

  # handle blocks/with/for, which may assign var using `=` or `<-`
  # these have different rules about what is legal syntax, but the compiler can
  # deal with that, and we don't care here - just if vars are closed over from
  # outside the scope of this ast
  def inlineable_ast?({expression, _, expressions}, bindings)
      when expression in [:__block__, :for, :with] and is_list(expressions) do
    result =
      expressions
      |> Enum.reduce_while(bindings, fn exp, bindings2 ->
        case exp do
          {op, _, [left, _right]} when op in [:<-, :=] ->
            bindings_assigned =
              [left]
              |> extract_pattern_match_vars()
              |> Enum.map(&{&1, true})
              |> Enum.into(bindings2)

            {:cont, bindings_assigned}

          exp ->
            if inlineable_ast?(exp, bindings2) do
              {:cont, bindings2}
            else
              {:halt, :not_inlined}
            end
        end
      end)

    result != :not_inlined
  end

  # local function captures are ok
  def inlineable_ast?({:&, meta1, [{:/, meta2, [{fun, meta3, context}, arity]}]}, _bindings)
      when is_list(meta1) and is_list(meta2) and is_atom(fun) and is_list(meta3) and
             is_atom(context) and is_integer(arity),
      do: true

  # ast node that is NOT a variable
  def inlineable_ast?({ast1, meta, ast2}, bindings) when is_list(meta) and is_list(ast2),
    do: inlineable_ast?(ast1, bindings) && inlineable_ast?(ast2, bindings)

  # ast node that IS a variable, BUT it's in the bindings for this scope
  def inlineable_ast?(ast, bindings) when is_map_key(bindings, ast), do: true

  def inlineable_ast?(_ast, _bindings), do: false

  defp extract_pattern_match_vars([{:when, _, params}]) when is_list(params) do
    # when is in last spot in args list, drop it as it's not assigning match values
    params = Enum.take(params, length(params) - 1)
    extract_pattern_match_vars(params)
  end

  defp extract_pattern_match_vars(params) when is_list(params),
    do: Enum.flat_map(params, &extract_pattern_match_var/1)

  defp extract_pattern_match_var(ast = {var, meta, context})
       when is_atom(var) and is_list(meta) and is_atom(context),
       do: [ast]

  defp extract_pattern_match_var({ast1, ast2}),
    do: extract_pattern_match_var(ast1) ++ extract_pattern_match_var(ast2)

  defp extract_pattern_match_var(ast) when is_list(ast),
    do: Enum.flat_map(ast, &extract_pattern_match_var/1)

  defp extract_pattern_match_var({_ast1, _meta, ast2}), do: extract_pattern_match_var(ast2)

  defp extract_pattern_match_var(ast) when is_atom(ast), do: []
  # defp extract_pattern_match_var(_ast), do: []

  @type inlined_arg() :: {:capture, n :: integer()} | {:inlined, arg :: Macro.t()}
  def inline_arg({:&, _, [n]}), do: {:capture, n}
  def inline_arg(ast), do: {:inlined, ast}
end
