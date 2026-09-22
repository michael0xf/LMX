"""Read-only cwd independence audit of recorded gate binaries. No rebuild."""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

STAMP = Path(r"C:\Nyasha_Planet\LMX\build\l2src\20260921_084100")
BIN = STAMP / "bin"
ORIG_CWD = STAMP
# Materially longer than ORIG_CWD (~52 chars). Second length if cheap.
TEMP_A = Path(os.environ.get("TEMP", r"C:\Users\mtkra\AppData\Local\Temp")) / (
    "lmx_cwd_105_" + ("x" * 80)
)
TIMEOUT = 20
OUT = STAMP / "cwd_audit_105.json"


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def run_one(exe: Path, cwd: Path) -> dict:
    cwd.mkdir(parents=True, exist_ok=True)
    try:
        r = subprocess.run(
            [str(exe)],
            cwd=str(cwd),
            capture_output=True,
            timeout=TIMEOUT,
            text=True,
            errors="replace",
        )
        return {
            "exit": r.returncode,
            "timeout": False,
            "stdout_head": (r.stdout or "")[:400],
            "stderr_head": (r.stderr or "")[:400],
        }
    except subprocess.TimeoutExpired as e:
        return {
            "exit": None,
            "timeout": True,
            "stdout_head": ((e.stdout or b"")[:400]).decode("utf-8", "replace")
            if isinstance(e.stdout, (bytes, bytearray))
            else (e.stdout or "")[:400],
            "stderr_head": "TIMEOUT",
        }
    except OSError as e:
        return {"exit": None, "timeout": False, "stdout_head": "", "stderr_head": str(e)}


def main() -> int:
    exes = sorted(BIN.glob("*.exe"))
    rows = []
    for exe in exes:
        rec = {
            "name": exe.name,
            "sha256": sha256(exe),
            "size": exe.stat().st_size,
            "orig_cwd": str(ORIG_CWD),
            "orig_cwd_len": len(str(ORIG_CWD)),
            "temp_cwd": str(TEMP_A),
            "temp_cwd_len": len(str(TEMP_A)),
        }
        rec["orig"] = run_one(exe, ORIG_CWD)
        rec["temp"] = run_one(exe, TEMP_A)
        o, t = rec["orig"]["exit"], rec["temp"]["exit"]
        ot, tt = rec["orig"]["timeout"], rec["temp"]["timeout"]
        if o == t and ot == tt:
            rec["class"] = "same"
        else:
            rec["class"] = "diverge"
        rows.append(rec)
        print(f"{exe.name} orig={o} t/o={ot} temp={t} t/o={tt} {rec['class']}", flush=True)
    summary = {
        "stamp": str(STAMP),
        "exe_count": len(exes),
        "orig_cwd": str(ORIG_CWD),
        "orig_cwd_len": len(str(ORIG_CWD)),
        "temp_cwd": str(TEMP_A),
        "temp_cwd_len": len(str(TEMP_A)),
        "timeout_s": TIMEOUT,
        "same": sum(1 for r in rows if r["class"] == "same"),
        "diverge": sum(1 for r in rows if r["class"] == "diverge"),
        "rows": rows,
    }
    OUT.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print("wrote", OUT, "same", summary["same"], "diverge", summary["diverge"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
