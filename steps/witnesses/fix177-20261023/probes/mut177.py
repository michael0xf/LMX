import sys, hashlib
D = 'C:/Nyasha_Planet/LMX/build2/opus_mut177/src/l2src/'
MUTANTS = {
    # K: the kernel defers no position of another object to the callee's entry (K1 undone)
    'K': ('lmx_implements.lm1',
          '    answer: lmx_implements_call_positions(arena, have_args, want_args, 1)\n',
          '    answer: lmx_implements_call_positions(arena, have_args, want_args, 0)\n'),
    # W: the walker's activation does not run the entry receptions (the body still skips them)
    'W': ('lmx_walk.lm1',
          '    # Then each formal receives its value, before the entry load and the body (lmx_walk_receive).\nreturn: lmx_walk_receive(f, body)\n',
          '    # Then each formal receives its value, before the entry load and the body (lmx_walk_receive).\nreturn: c.LMX_WALK_OK\n'),
    # T: the trampoline copies the inputs' values but admits none of them
    'T': ('l2trans.lm1',
          '    while: k < l2_m_arity[i]\n        if: l2_reception_formal(i, k) != 0\n            if: c.fprintf(l2_out, "    l2_reception_model:',
          '    while: k < l2_m_arity[i]\n        if: 0 != 0\n            if: c.fprintf(l2_out, "    l2_reception_model:'),
}
op, name = sys.argv[1], sys.argv[2]
f, good, bad = MUTANTS[name]
p = D + f
b = open(p, 'rb').read().decode()
src, dst = (good, bad) if op == 'apply' else (bad, good)
assert b.count(src) == 1, (name, op, b.count(src))
b = b.replace(src, dst)
open(p, 'wb').write(b.encode())
print(op, name, f, hashlib.sha256(b.encode()).hexdigest())
