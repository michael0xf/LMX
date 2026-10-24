# Slice 177's controls and mutants, read from their saved run logs: for each run of the links row (lib_owner), its
# first `lmx:` line and its last witness line (S81).  It reads only run-root*.log files the suite wrote.
# Usage: python controls177.py > controls-177.out
import os
B = 'C:/Nyasha_Planet/LMX/build2/'
RUNS = [
    ('final', 'fe-05 + rt-03', 'opus_fix177/fe-05/smoke'),
    ('control-c1', 'Verified176 fe-02 + Verified176 rt-01', 'opus_fix177/control-c1'),
    ('control-c3', 'Verified176 fe-02 + 177 rt-01 (first kernel)', 'opus_fix177/control-c3'),
    ('control-c4', 'Verified176 fe-02 + 177 rt-03 (final kernel)', 'opus_fix177/control-c4'),
    ('mutant K2', 'fe-05 + rt-mutK2 (no position left to the entry)', 'opus_mut177/smoke-K2-fe05'),
    ('mutant W2', 'fe-05 + rt-mutW2 (the walker runs no reception)', 'opus_mut177/smoke-W2-fe05'),
    ('mutant T3', 'fe-mutT3 + rt-03 (the trampoline admits nothing)', 'opus_mut177/fe-mutT3/smoke'),
]
for label, build, d in RUNS:
    print('== %s: %s (%s)' % (label, build, d))
    for m in ['native', 'forced']:
        for r in ['0', '1']:
            p = B + d + '/lib_owner-%s/run-root%s.log' % (m, r)
            if os.path.basename(p) == 'l2_driver_launch.err' or not os.path.isfile(p):
                print('  %s root%s: no log' % (m, r))
                continue
            text = open(p, 'rb').read().decode('utf-8', 'replace').replace('\r\n', '\n').split('\n')
            first = next((x for x in text if x.startswith('lmx:')), '-')
            s81 = [x.strip() for x in text if x.strip().startswith('S81')]
            print('  %s root%s: %s' % (m, r, first))
            print('    S81 lines %d, last: %s' % (len(s81), s81[-1] if s81 else '-'))
