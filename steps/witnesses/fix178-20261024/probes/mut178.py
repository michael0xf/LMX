# Slice 178's mutants: each a copy of a final stage source with ONE change, written into the mutant stage
# build2/opus_mut178b (a copy of the final stage's src, headers, tools and tests). The final stage is not touched.
#   L2 -- the list's lmx_list_value returns 0: the runtime must fail its smoke if the kernel runs the L2 list.
#   A  -- the machine arithmetic rule admits everything (l2_machine_arith_open is 0): the int-arithmetic negatives
#         must translate.
#   P  -- the module declares none of its own functions: the forward positive must fail its C compile.
import sys
S = 'C:/Nyasha_Planet/LMX/build2/opus_fix178/src/l2src/'
M = 'C:/Nyasha_Planet/LMX/build2/opus_mut178b/'

def mutate(src, dst, old, new):
    b = open(src, 'rb').read().decode()
    assert '\r' not in b
    assert b.count(old) == 1, (dst, b.count(old))
    open(dst, 'wb').write(b.replace(old, new).encode())
    print('wrote', dst)

mutate(S + 'lmx_list_owned.lm2', M + 'src/l2src/lmx_list_owned.lm2',
       '''        return: 0
    return: cells[index]
end: lmx_list_value
''', '''        return: 0
    return: 0
end: lmx_list_value
''')
mutate(S + 'l2trans.lm1', M + 'mut/l2trans.mutA.lm1',
       '''    if: tok = 0 || lo >= hi
        return: 0
    best: l2_rw_split(tok, lo, hi)
    op: l2_span_node(tok, best)
''', '''    if: tok != 0 || tok = 0
        return: 0
    best: l2_rw_split(tok, lo, hi)
    op: l2_span_node(tok, best)
''')
mutate(S + 'l2trans.lm1', M + 'mut/l2trans.mutP.lm1',
       '''            if: l2_m_machine(i) != 0 && l2_m_machine_export(i) = 0
                if: own = 0 && fputs("prototype:\\n", body) < 0
''', '''            if: l2_m_machine(i) != 0 && l2_m_machine_export(i) = 0 && i < 0
                if: own = 0 && fputs("prototype:\\n", body) < 0
''')
