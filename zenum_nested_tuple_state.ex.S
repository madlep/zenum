{module, 'Elixir.Bench.Transforms.ZenumNestedTupleState'}.  %% version = 0

{exports, [{'__info__',1},{module_info,0},{module_info,1},{run,1}]}.

{attributes, []}.

{labels, 63}.


{function, '__info__', 1, 2}.
  {label,1}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,'__info__'},
               1}.
  {label,2}.
    {select_val,{x,0},
                {f,9},
                {list,[{atom,attributes},
                       {f,8},
                       {atom,compile},
                       {f,8},
                       {atom,deprecated},
                       {f,7},
                       {atom,exports_md5},
                       {f,6},
                       {atom,functions},
                       {f,5},
                       {atom,macros},
                       {f,7},
                       {atom,md5},
                       {f,8},
                       {atom,module},
                       {f,4},
                       {atom,struct},
                       {f,3}]}}.
  {label,3}.
    {move,{atom,nil},{x,0}}.
    return.
  {label,4}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},{x,0}}.
    return.
  {label,5}.
    {move,{literal,[{run,1}]},{x,0}}.
    return.
  {label,6}.
    {move,{literal,<<68,253,119,166,65,245,181,24,193,76,222,254,70,56,131,102>>},
          {x,0}}.
    return.
  {label,7}.
    {move,nil,{x,0}}.
    return.
  {label,8}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
  {label,9}.
    {call_only,1,{f,60}}. % '-inlined-__info__/1-'/1


{function, run, 1, 11}.
  {label,10}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",4}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,run},
               1}.
  {label,11}.
    {test_heap,9,1}.
    {put_tuple2,{x,0},{list,[nil,{x,0}]}}.
    {put_tuple2,{x,0},{list,[{integer,20},{x,0}]}}.
    {put_tuple2,{x,0},{list,[nil,{x,0}]}}.
    {call_only,1,{f,51}}. % z6_run/1


{function, z1_filter, 1, 13}.
  {label,12}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",9}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,z1_filter},
               1}.
  {label,13}.
    {test,is_nonempty_list,{f,14},[{x,0}]}.
    {test_heap,3,1}.
    {get_list,{x,0},{x,1},{x,0}}.
    {put_tuple2,{x,0},{list,[{x,1},{x,0}]}}.
    {jump,{f,15}}.
  {label,14}.
    {move,{literal,{}},{x,0}}.
  {label,15}.
    {test,test_arity,{f,21},[{x,0},2]}.
    {allocate,2,1}.
    {move,{x,0},{y,1}}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {get_tuple_element,{y,1},1,{y,0}}.
    {test,is_map,{f,16},[{x,0}]}.
    {get_map_elements,{f,16},
                      {tr,{x,0},{t_map,any,any}},
                      {list,[{atom,reference},{x,1}]}}.
    {move,{x,1},{x,0}}.
    {jump,{f,18}}.
  {label,16}.
    {test,is_atom,{f,20},[{x,0}]}.
    {select_val,{x,0},
                {f,17},
                {list,[{atom,false},
                       {f,20},
                       {atom,nil},
                       {f,20},
                       {atom,true},
                       {f,20}]}}.
  {label,17}.
    {move,{atom,reference},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",12}]}.
    {apply,0}.
  {label,18}.
    {test,is_eq_exact,{f,19},[{x,0},{atom,'REF3'}]}.
    {move,{y,1},{x,0}}.
    {deallocate,2}.
    return.
  {label,19}.
    {move,{y,0},{x,0}}.
    {call_last,1,{f,13},2}. % z1_filter/1
  {label,20}.
    {test_heap,4,1}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,reference},{x,0}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},2}.
  {label,21}.
    return.


{function, z2_flat_map, 1, 23}.
  {label,22}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",23}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,z2_flat_map},
               1}.
  {label,23}.
    {test,is_tuple,{f,22},[{x,0}]}.
    {test,test_arity,{f,22},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {get_tuple_element,{x,0},1,{x,0}}.
    {test,is_nonempty_list,{f,24},[{x,1}]}.
    {test_heap,6,2}.
    {get_list,{x,1},{x,2},{x,1}}.
    {put_tuple2,{x,0},{list,[{x,1},{x,0}]}}.
    {put_tuple2,{x,0},{list,[{x,2},{x,0}]}}.
    return.
  {label,24}.
    {allocate,1,1}.
    {init_yregs,{list,[{y,0}]}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",26}]}.
    {call,1,{f,13}}. % z1_filter/1
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {test,test_arity,{f,29},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {get_tuple_element,{x,0},1,{y,0}}.
    {test,is_map,{f,25},[{x,1}]}.
    {get_map_elements,{f,25},
                      {tr,{x,1},{t_map,any,any}},
                      {list,[{atom,events},{x,0}]}}.
    {jump,{f,27}}.
  {label,25}.
    {test,is_atom,{f,28},[{x,1}]}.
    {select_val,{x,1},
                {f,26},
                {list,[{atom,false},
                       {f,28},
                       {atom,nil},
                       {f,28},
                       {atom,true},
                       {f,28}]}}.
  {label,26}.
    {move,{x,1},{x,0}}.
    {move,{atom,events},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",27}]}.
    {apply,0}.
  {label,27}.
    {test_heap,3,1}.
    {put_tuple2,{x,0},{list,[{x,0},{y,0}]}}.
    {call_last,1,{f,23},1}. % z2_flat_map/1
  {label,28}.
    {test_heap,4,2}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,events},{x,1}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},1}.
  {label,29}.
    {deallocate,1}.
    return.


{function, z3_filter, 1, 31}.
  {label,30}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",32}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,z3_filter},
               1}.
  {label,31}.
    {allocate,2,1}.
    {init_yregs,{list,[{y,0},{y,1}]}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",33}]}.
    {call,1,{f,23}}. % z2_flat_map/1
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {bif,tuple_size,{f,0},[{tr,{x,0},{t_tuple,0,false,#{}}}],{x,1}}.
    {move,{x,0},{y,1}}.
    {test,is_eq_exact,
          {f,38},
          [{tr,{x,1},{t_integer,{0,16777215}}},{integer,2}]}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {get_tuple_element,{y,1},1,{y,0}}.
    {test,is_map,{f,32},[{x,0}]}.
    {get_map_elements,{f,32},
                      {tr,{x,0},{t_map,any,any}},
                      {list,[{atom,'included?'},{x,1}]}}.
    {move,{x,1},{x,0}}.
    {jump,{f,34}}.
  {label,32}.
    {test,is_atom,{f,37},[{x,0}]}.
    {select_val,{x,0},
                {f,33},
                {list,[{atom,false},
                       {f,37},
                       {atom,nil},
                       {f,37},
                       {atom,true},
                       {f,37}]}}.
  {label,33}.
    {move,{atom,'included?'},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",35}]}.
    {apply,0}.
  {label,34}.
    {select_val,{x,0},{f,36},{list,[{atom,false},{f,35},{atom,nil},{f,35}]}}.
  {label,35}.
    {move,{y,0},{x,0}}.
    {call_last,1,{f,31},2}. % z3_filter/1
  {label,36}.
    {move,{y,1},{x,0}}.
    {deallocate,2}.
    return.
  {label,37}.
    {test_heap,4,1}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,'included?'},{x,0}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},2}.
  {label,38}.
    {deallocate,2}.
    return.


{function, z4_map, 1, 40}.
  {label,39}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",46}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,z4_map},
               1}.
  {label,40}.
    {allocate,3,1}.
    {init_yregs,{list,[{y,0},{y,1},{y,2}]}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",47}]}.
    {call,1,{f,31}}. % z3_filter/1
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {test,test_arity,{f,49},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{y,2}}.
    {get_tuple_element,{x,0},1,{y,1}}.
    {test,is_map,{f,41},[{y,2}]}.
    {get_map_elements,{f,41},
                      {tr,{y,2},{t_map,any,any}},
                      {list,[{atom,event_id},{x,0}]}}.
    {move,{x,0},{y,0}}.
    {jump,{f,43}}.
  {label,41}.
    {test,is_atom,{f,48},[{y,2}]}.
    {select_val,{y,2},
                {f,42},
                {list,[{atom,false},
                       {f,48},
                       {atom,nil},
                       {f,48},
                       {atom,true},
                       {f,48}]}}.
  {label,42}.
    {move,{atom,event_id},{x,1}}.
    {move,{y,2},{x,0}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",48}]}.
    {apply,0}.
    {move,{x,0},{y,0}}.
  {label,43}.
    {test,is_map,
          {f,44},
          [{tr,{y,2},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {get_map_elements,{f,44},
                      {tr,{y,2},{t_map,any,any}},
                      {list,[{atom,parent_id},{x,0}]}}.
    {jump,{f,46}}.
  {label,44}.
    {test,is_atom,
          {f,47},
          [{tr,{y,2},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {select_val,{y,2},
                {f,45},
                {list,[{atom,false},
                       {f,47},
                       {atom,nil},
                       {f,47},
                       {atom,true},
                       {f,47}]}}.
  {label,45}.
    {move,{atom,parent_id},{x,1}}.
    {move,{y,2},{x,0}}.
    {init_yregs,{list,[{y,2}]}}.
    {apply,0}.
  {label,46}.
    {test_heap,6,1}.
    {put_tuple2,{x,0},{list,[{y,0},{x,0}]}}.
    {put_tuple2,{x,0},{list,[{x,0},{y,1}]}}.
    {deallocate,3}.
    return.
  {label,47}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,parent_id},{y,2}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},3}.
  {label,48}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,event_id},{y,2}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},3}.
  {label,49}.
    {deallocate,3}.
    return.


{function, z6_run, 1, 51}.
  {label,50}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",62}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,z6_run},
               1}.
  {label,51}.
    {'%',{var_info,{x,0},[{type,{t_tuple,2,true,#{1 => {t_list,any,nil}}}}]}}.
    {get_tuple_element,{x,0},1,{x,1}}.
    {test,is_tuple,{f,54},[{x,1}]}.
    {test,test_arity,{f,54},[{x,1},2]}.
    {allocate,2,2}.
    {get_tuple_element,{x,0},0,{y,1}}.
    {get_tuple_element,{x,1},0,{y,0}}.
    {test,is_ne_exact,{f,53},[{y,0},{integer,0}]}.
    {get_tuple_element,{x,1},1,{x,0}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",56}]}.
    {call,1,{f,40}}. % z4_map/1
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {test,test_arity,{f,52},[{x,0},2]}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",57}]}.
    {gc_bif,'-',{f,0},1,[{y,0},{integer,1}],{x,1}}.
    {test_heap,6,2}.
    {get_tuple_element,{x,0},0,{x,2}}.
    {get_tuple_element,{x,0},1,{x,0}}.
    {put_tuple2,{x,0},{list,[{x,1},{x,0}]}}.
    {put_tuple2,{x,0},{list,[{x,2},{x,0}]}}.
  {label,52}.
    {test,test_arity,{f,53},[{x,0},2]}.
    {test_heap,5,1}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {get_tuple_element,{x,0},1,{x,0}}.
    {put_list,{x,1},{y,1},{x,1}}.
    {put_tuple2,{x,0},{list,[{x,1},{x,0}]}}.
    {call_last,1,{f,51},2}. % z6_run/1
  {label,53}.
    {move,{y,1},{x,0}}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",65}]}.
    {call_ext_last,1,{extfunc,lists,reverse,1},2}.
  {label,54}.
    {move,{x,1},{x,0}}.
    {call_only,1,{f,62}}. % '-inlined-z5_take/1-'/1


{function, module_info, 0, 56}.
  {label,55}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,module_info},
               0}.
  {label,56}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 58}.
  {label,57}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,module_info},
               1}.
  {label,58}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.


{function, '-inlined-__info__/1-', 1, 60}.
  {label,59}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,'-inlined-__info__/1-'},
               1}.
  {label,60}.
    {jump,{f,59}}.


{function, '-inlined-z5_take/1-', 1, 62}.
  {label,61}.
    {line,[{location,"lib/bench/transforms/zenum_nested_tuple_state.ex",53}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumNestedTupleState'},
               {atom,'-inlined-z5_take/1-'},
               1}.
  {label,62}.
    {jump,{f,61}}.
