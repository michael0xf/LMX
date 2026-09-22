"""Measured cwd-length ladder. Read-only. No rebuild. Record actual path lengths."""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

STAMP = Path(r"C:\Nyasha_Planet\LMX\build\l2src\20260921_084100")
BIN = STAMP / "bin"
TARGETS = [48, 96, 128, 140, 160, 196, 231]
TIMEOUT = 15
OUT = STAMP / "cwd_ladder_109.json"
SKIP_LADDER = {"lmx_app_lanes_mail_selftest.exe"}


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def mkdir_len(n: int) -> Path:
    """Create a directory whose resolved path has exactly n characters."""
    root = Path(r"C:\g109")
    root.mkdir(exist_ok=True)
    base = str(root.resolve())
    # Windows resolve may be C:\g109 (7). Need n >= base+2.
    if n == len(str(STAMP.resolve())):
        return STAMP.resolve()
    extra = n - len(base) - 1
    if extra < 1:
        raise SystemExit("target %s too short for base %s (%s)" % (n, base, len(base)))
    p = root / ("p" * extra)
    p.mkdir(parents=True, exist_ok=True)
    actual = str(p.resolve())
    if len(actual) != n:
        raise SystemExit("wanted len %s got %s path %r" % (n, len(actual), actual))
    return p


def env_size(env: dict) -> int:
    # Approximate Windows environment block size (key=value\0) plus trailing NUL.
    n = 1
    for k, v in env.items():
        n += len(k) + 1 + len(v) + 1
    return n


def run_one(exe: Path, cwd: Path, pad: int) -> dict:
    env = os.environ.copy()
    if pad:
        env["LMX_CWD_PAD"] = "E" * pad
    try:
        r = subprocess.run(
            [str(exe)],
            cwd=str(cwd),
            env=env,
            capture_output=True,
            timeout=TIMEOUT,
            text=True,
            errors="replace",
        )
        return {
            "cwd": str(cwd),
            "cwd_len": len(str(cwd)),
            "pad": pad,
            "env_size": env_size(env),
            "exit": r.returncode,
            "timeout": False,
            "stdout_head": (r.stdout or "")[:200],
        }
    except subprocess.TimeoutExpired:
        return {
            "cwd": str(cwd),
            "cwd_len": len(str(cwd)),
            "pad": pad,
            "env_size": env_size(os.environ) + (pad + len("LMX_CWD_PAD=") + 1 if pad else 0),
            "exit": None,
            "timeout": True,
            "stdout_head": "TIMEOUT",
        }


def crashed(row: dict) -> bool:
    if row["timeout"]:
        return False
    ex = row["exit"]
    if ex is None:
        return True
    if ex < 0 or ex >= 0xC0000000:
        return True
    if ex != 0:
        return True
    return False


def main() -> int:
    dirs = {}
    for n in TARGETS:
        d = mkdir_len(n)
        dirs[n] = d
        print("rung", n, "actual", len(str(d)), d, flush=True)

    exes = sorted(p for p in BIN.glob("*.exe") if p.name not in SKIP_LADDER)
    rows = []
    for exe in exes:
        rec = {"name": exe.name, "sha256": sha256(exe), "size": exe.stat().st_size, "runs": []}
        dead = False
        for n in TARGETS:
            if dead:
                break
            r0 = run_one(exe, dirs[n], 0)
            rec["runs"].append(r0)
            print(exe.name, "len", r0["cwd_len"], "pad0", r0["exit"], "to", r0["timeout"], flush=True)
            if crashed(r0):
                # boundary-relevant: also pad ~4096 at this length, then stop
                r1 = run_one(exe, dirs[n], 4096)
                rec["runs"].append(r1)
                print(exe.name, "len", r1["cwd_len"], "pad4096", r1["exit"], "to", r1["timeout"], flush=True)
                dead = True
                rec["first_fail_len"] = r0["cwd_len"]
                break
        else:
            # no crash: still pad 4096 at 140 and 231
            for n in (140, 231):
                r1 = run_one(exe, dirs[n], 4096)
                rec["runs"].append(r1)
                print(exe.name, "len", r1["cwd_len"], "pad4096", r1["exit"], "to", r1["timeout"], flush=True)
                if crashed(r1):
                    rec["first_fail_len"] = r1["cwd_len"]
                    rec["fail_with_pad"] = 4096
                    break
        rows.append(rec)

    summary = {
        "stamp": str(STAMP),
        "headline": "relocation/env sweeps find bugs but cannot prove absence",
        "rungs_requested": TARGETS,
        "rungs_actual": {str(n): {"path": str(dirs[n]), "len": len(str(dirs[n]))} for n in TARGETS},
        "responsive_exes": len(exes),
        "skipped_ladder": list(SKIP_LADDER),
        "timeout_s": TIMEOUT,
        "rows": rows,
    }
    OUT.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print("wrote", OUT, flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
