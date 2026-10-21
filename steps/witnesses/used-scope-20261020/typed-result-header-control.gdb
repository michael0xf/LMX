set pagination off
set confirm off
file C:/Nyasha_Planet/LMX/build/codex_catalog94_build_01/l2trans.exe
break l2_emit_parts if i == 2
run C:/Nyasha_Planet/LMX/build/codex_giving96_return_02.lm2 convert.lm2 primitive.lm2 C:/Nyasha_Planet/LMX/build/codex_source96_return_control_04/generated.lm1
printf "actual header result: method=%d declared-Model=%d signature=%d storage=%d\n",i,(int)l2_input_model(i,-1),(int)l2_sig_ret(i),(int)l2_ret_cell_ty(i)
tbreak l2_emit_cell_new_ty
continue
printf "actual header result storage constructor: ty=%d n=%zu owner=%s field=%zu\n",ty,n,owner,field
bt 4
finish
disable 1
continue
quit
