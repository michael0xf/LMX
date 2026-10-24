# Slice 178: whether ordinary translations are untouched by the machine mode. For every row of the targeted replay,
# the L1 (p.lm1) and C (p.c) that Verified177's replay177-04 generated are compared, byte for byte, with those of
# replay178-03 (fe-02 + rt-03). Usage: python l1same178.py (cwd = C:/Nyasha_Planet/LMX/build2)
import hashlib
import os

A = 'opus_fix177/replay177-04'
B = 'opus_fix178/replay178-03'


def digest(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()


rows = sorted(d for d in os.listdir(A) if os.path.isdir(os.path.join(A, d)))
same = 0
other = []
for d in rows:
    for f in ('p.lm1', 'p.c'):
        pa, pb = os.path.join(A, d, f), os.path.join(B, d, f)
        if not os.path.exists(pa) and not os.path.exists(pb):
            continue
        if not (os.path.exists(pa) and os.path.exists(pb)):
            other.append('ONE-SIDE %s/%s' % (d, f))
        elif digest(pa) == digest(pb):
            same += 1
        else:
            other.append('DIFFER %s/%s' % (d, f))
for line in other:
    print(line)
print('L1SAME %d row directories, %d files equal, %d not' % (len(rows), same, len(other)))
