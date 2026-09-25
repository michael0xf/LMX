"""Header-type-name budget of the dev/l3_interp translation units, checked against the PINNED translator.

    python tools/l3_type_budget.py

WHY.  l1trans keeps the type names of one translated unit's whole predef closure in a table of 128
entries and 8192 bytes (l1src/l1trans.lm1, l1_hdr_type_add) and refuses the 129th with
`too many header type names` -- reported at whatever header happens to be read last, which is
never the one that caused it.  The L3 Thread units were at 64 of 64 when one L2 kernel header
gained two types (4ab2877): every Thread suite stopped translating, and tools/build_l2src.ps1
stayed green, because it does not build dev/l3_interp.  This check makes the next such change
fail HERE, with the number and the name of the budget, before the cliff.

WHAT IT MEASURES, and it does not trust a count of the source for it.  For each budgeted suite a
probe unit predefs exactly the suite's predef list and then a pad header of K dummy `fnptr:`
types; the largest K that still translates gives   names = 128 - K   -- the translator's own
answer.  A source model (depth-first predef closure, each unit once, struct / enum / fnptr /
foreign / type of header units) is run beside it for the BYTES, which the pad method cannot reach
while the count binds, and the two counts must agree or the model -- and its byte figure -- is
not to be believed.  (A model that misses a BOM before `predef:` or a bare predef name resolved
beside the predef'ing file comes out four names short; that mistake has been made twice.)

IT FAILS when a suite's count differs from EXPECT in either direction, when the translator already
refuses the suite, when model and translator disagree, or when the bytes come within one maximal
name of 8192.  EXPECT is changed only together with the reason the closure changed.

Everything is staged in a temporary directory; no file of the repository is written.
"""
import argparse
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
SANDBOX = ROOT / 'dev' / 'l2src_sandbox'
L3 = ROOT / 'dev' / 'l3_interp'

CAP_NAMES = 128
CAP_BYTES = 8192
MAX_NAME = 64          # l1_hdr_type_add's buffer: one more maximal name must still fit

# suite -> header type names of its translation unit. Cliff is 128 names / 8192 bytes
# (raised from 64/4096 in FABLE-134 so typed Post/Thread mail fnptrs need not be erased).
# Compositional DynamicArrays (fixed <T>Array + capacity) with typed Post Accept/Take/Count/Close
# and Thread MailAccept/Take/Count/Close kept; EXPECT=71 after mode removal (dropped RequestMode+Dispatch; WalkFn remains) (descriptor
# dispatch hook in lmx_call.h.lm1, FABLE-GROKBOT-DESCRIPTOR-DISPATCH-20260924-156).  EXPECT=70 after
# FABLE-OPUS-ROOT-WALK-TRANSLATOR-20260924-159 commit 1 (D-38): lmx_call.h.lm1 dropped fnptr
# LmxCallEntrySelf -- METHOD.addr is the method's prim-ABI trampoline, so no user of the two-reference
# entry type is left.  EXPECT=71 after FABLE-GROKBOT-WALK-RECEIVE-20260925-177 c2: LmxPostCursor
# (selective-receive inbox iterator) in lmx_post.h.lm1.  EXPECT=68 after
# FABLE-SONNET-NATIVE-WORD-20260926-191: three struct declarations dropped from the Thread
# closure -- LmxCallable and LmxMethod from lmx.h.lm1 (c.2: Lmx.native replaces the child[0]
# descriptor entirely) and LmxWalkOwn from lmx_walk.h.lm1 (c.2 gate fix-forward: dead since
# LmxWalkFrame lost its owns/nowns fields, no cached activation plan any more).  This is the
# first count taken against that baseline: dev/l3_interp did not translate at all between c.2
# landing and c.3 fixing these four suites' own LmxCallable/LmxMethod/lmx_plan uses, so the
# budget script could not run and catch the shift until now.  EXPECT=69 after
# FABLE-SONNET-MERGE-KERNEL-20260926-194 к.4 (G-call): fnptr LmxCallPrimWalkFn added to
# lmx_call.h.lm1 -- the dynamic-call counterpart of LmxCallWalkFn, for lmx_call_prim's own
# addr=0 branch (which now carries data/args/a typed dest to a walked callee, instead of
# lmx_call0's narrower nullary-int hook).  EXPECT=68 after -200 slice (a): foreign ULONGLONG
# left lmx_clock.h.lm1 (the reading is uint64_t from stdint.h, not a named header type).
# EXPECT=69: fnptr LmxManagerWork in lmx_manager_running.h.lm1 (a selftest's own thread).
# Slice (b): the POSIX clock body predefs lmx_posix_abi.h.lm1 (8 names:
# 4 foreign, 1 type, 2 struct, 1 fnptr). Windows does not.
# The POSIX lane body also declares struct LmxManagerThread. Windows keeps the handle in void*.
_POSIX_ABI = 0 if os.name == 'nt' else 8
_POSIX_THREAD = 0 if os.name == 'nt' else 1
EXPECT = {
    'tests/l3_thread_bind_selftest.lm1': 69 + _POSIX_ABI + _POSIX_THREAD,
    'tests/l3_n9_walk_selftest.lm1': 69 + _POSIX_ABI + _POSIX_THREAD,
    'tests/l3_n10_walk_selftest.lm1': 69 + _POSIX_ABI + _POSIX_THREAD,
    'tests/l3_mail_prim_selftest.lm1': 69 + _POSIX_ABI + _POSIX_THREAD,
}

PREDEF = re.compile(r'^predef:\s*(.*)$')
QUOTED = re.compile(r'"([^"]+)"')
DECL = re.compile(r'^(struct|enum|fnptr|foreign|type):\s*([A-Za-z_][A-Za-z0-9_]*)')


def stage(unit_root, l1src):
    """The same staging tools/run_l3_selftest.py does, so the closure is the one the suites translate."""
    for folder in ('l2src', 'l3_interp/tests', 'l1src'):
        (unit_root / folder).mkdir(parents=True)
    host = 'win32' if os.name == 'nt' else 'posix'
    twins = {'lmx_clock.lm1', 'lmx_process_deadline.lm1', 'lmx_manager_running.lm1', 'lmx_manager_running_lane.lm1'}
    for source in sorted(SANDBOX.glob('lmx*.lm1')):
        if source.name.endswith('_win32.lm1') or source.name.endswith('_posix.lm1'):
            continue
        shutil.copyfile(source, unit_root / 'l2src' / source.name)
    for logical in sorted(twins):
        physical = logical.replace('.lm1', '_' + host + '.lm1')
        shutil.copyfile(SANDBOX / physical, unit_root / 'l2src' / logical)
    shutil.copyfile(SANDBOX / 'l2_libc.lm1', unit_root / 'l2src' / 'l2_libc.lm1')
    for source in sorted(L3.glob('l3*.lm1')):
        shutil.copyfile(source, unit_root / 'l3_interp' / source.name)
    for source in sorted((L3 / 'tests').glob('*.lm1')):
        shutil.copyfile(source, unit_root / 'l3_interp' / 'tests' / source.name)
    for source in sorted(l1src.glob('*.lm1')):
        shutil.copyfile(source, unit_root / 'l1src' / source.name)


def read(path):
    return path.read_text(encoding='utf-8-sig', errors='replace').splitlines()      # some units begin with a BOM


def own_predefs(unit_root, unit):
    out = []
    for line in read(unit_root / unit):
        m = PREDEF.match(line)
        if m:
            out.extend(QUOTED.findall(m.group(1)))
    return out


def model(unit_root, unit):
    """(names, bytes) of the unit's closure, by reading the source."""
    seen, names = [], []

    def visit(u, via):
        if u in seen:
            return
        if not (unit_root / u).is_file() and via:
            beside = (pathlib.PurePosixPath(via).parent / u).as_posix()      # a bare name is beside the predef'ing file
            if (unit_root / beside).is_file():
                return visit(beside, via)
        if not (unit_root / u).is_file():
            raise SystemExit(f'l3_type_budget: {u} (predef of {via}) is not in the staged unit-root')
        seen.append(u)
        for line in read(unit_root / u):
            m = PREDEF.match(line)
            if m:
                for target in QUOTED.findall(m.group(1)):
                    visit(target, u)
                continue
            if u.endswith('.h.lm1'):
                d = DECL.match(line)
                if d and d.group(2) not in names:                              # `type: X struct X` + `struct: X` is one name
                    names.append(d.group(2))

    visit(unit, None)
    return len(names), sum(len(n) + 1 for n in names)


def translates(translator, unit_root, predefs, pad):
    (unit_root / 'l3_interp' / 'zz_budget_pad.h.lm1').write_text(
        ''.join(f'fnptr: ZzBudgetPad{i} (int: a) int\n' for i in range(pad)) or 'define: ZZ_BUDGET_PAD_EMPTY 1\n',
        encoding='utf-8', newline='\n')
    (unit_root / 'l3_interp' / 'zz_budget_probe.lm1').write_text(
        ''.join(f'predef: "{p}"\n' for p in predefs)
        + 'predef: "l3_interp/zz_budget_pad.h.lm1"\n\nfn: zz_budget_probe () int\nreturn: 0\n',
        encoding='utf-8', newline='\n')
    result = subprocess.run([str(translator), '--unit-root', str(unit_root), 'l3_interp/zz_budget_probe.lm1',
                             str(unit_root / 'zz_budget_probe.c')], cwd=str(unit_root), capture_output=True, timeout=300)
    text = (result.stdout + result.stderr).decode('utf-8', errors='replace').strip()
    return result.returncode == 0, (text.splitlines() or [''])[-1]


def measured(translator, unit_root, predefs):
    """names the translator itself holds for this closure, or (None, diagnostic) when it already refuses it."""
    ok, said = translates(translator, unit_root, predefs, 0)
    if not ok:
        return None, said
    if translates(translator, unit_root, predefs, CAP_NAMES)[0]:
        return 0, ''
    lo, hi = 0, CAP_NAMES                  # lo translates, hi does not
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if translates(translator, unit_root, predefs, mid)[0]:
            lo = mid
        else:
            hi = mid
    said = translates(translator, unit_root, predefs, hi)[1]
    if 'too many header type names' not in said:
        return None, 'the pad was refused for another reason: ' + said
    return CAP_NAMES - lo, ''


def check(translator, l1src, keep=None):
    work = pathlib.Path(keep) if keep else pathlib.Path(tempfile.mkdtemp(prefix='l3_type_budget_'))
    if keep:
        if work.exists():
            shutil.rmtree(work)
        work.mkdir(parents=True)
    unit_root = work / 'unitroot'
    failures = []
    try:
        stage(unit_root, l1src)
        for suite, expect in EXPECT.items():
            unit = 'l3_interp/' + suite
            if not (unit_root / unit).is_file():
                failures.append(f'{suite}: the suite is missing')
                continue
            m_names, m_bytes = model(unit_root, unit)
            names, said = measured(translator, unit_root, own_predefs(unit_root, unit))
            if names is None:
                failures.append(f'{suite}: the translator already refuses this closure ({said}); the source model counts '
                                f'{m_names} names against a table of {CAP_NAMES}')
                print(f'FAIL {suite}: over the cliff -- {said}; model {m_names} names, {m_bytes} bytes')
                continue
            line = (f'{suite}: names {names}/{CAP_NAMES} (headroom {CAP_NAMES - names}), '
                    f'bytes {m_bytes}/{CAP_BYTES} (headroom {CAP_BYTES - m_bytes}); the COUNT binds'
                    if (CAP_NAMES - names) * MAX_NAME < CAP_BYTES - m_bytes else
                    f'{suite}: names {names}/{CAP_NAMES}, bytes {m_bytes}/{CAP_BYTES}; the BYTES bind')
            why = []
            if names != m_names:
                why.append(f'translator says {names}, source model says {m_names}: the model (and its byte figure) is wrong')
            if names != expect:
                why.append(f'expected {expect}: the closure {"gained" if names > expect else "lost"} '
                           f'{abs(names - expect)} header type name(s); the cliff is {CAP_NAMES}')
            if m_bytes + MAX_NAME >= CAP_BYTES:
                why.append(f'{m_bytes} bytes: one more maximal name does not fit in {CAP_BYTES}')
            if why:
                failures.append(suite + ': ' + '; '.join(why))
                print('FAIL ' + line + ' -- ' + '; '.join(why))
            else:
                print('OK   ' + line)
    finally:
        if not keep:
            shutil.rmtree(work, ignore_errors=True)
    return failures


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--translator', type=pathlib.Path, default=ROOT / 'bin' / 'l1trans.exe')
    ap.add_argument('--l1src', type=pathlib.Path, default=SANDBOX / 'l1src')
    ap.add_argument('--keep', type=pathlib.Path, default=None, help='stage here and keep it (never inside the repository)')
    args = ap.parse_args()
    if args.keep is not None and ROOT in args.keep.resolve().parents:
        print('l3_type_budget: --keep must be outside the repository', file=sys.stderr)
        return 2
    failures = check(args.translator.resolve(strict=True), args.l1src.resolve(strict=True), args.keep)
    if failures:
        print(f'l3_type_budget RED: {len(failures)} of {len(EXPECT)} budgets')
        return 1
    print(f'l3_type_budget GREEN: {len(EXPECT)} budgets, table of {CAP_NAMES} names / {CAP_BYTES} bytes')
    return 0


if __name__ == '__main__':
    sys.exit(main())
