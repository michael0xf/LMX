"""Image-path ladder for GROK-L2-GATE-CWD-LADDER-20260921-109 amendment.

Copy hash-verified recorded EXE into a constructed directory and invoke that
copy. Record actual image-path length and cwd length separately.
Read-only scratch. No rebuild. No shared-tree mutation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

STAMP = Path(r"C:\Nyasha_Planet\LMX\build\l2src\20260921_084100")
BIN = STAMP / "bin"
ROOT = Path(r"C:\g109\img")
OUT = STAMP / "image_ladder_109.json"
SKIP_LADDER = {"lmx_app_lanes_mail_selftest.exe"}
DIRTY = "lmx_dirty_selftest.exe"
TIMEOUT = 15
TARGETS = [48, 96, 128, 140, 160, 196, 231]
DIRTY_TARGETS = [75, 96, 120, 126, 128, 132, 135, 139, 140, 145, 160]


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def env_size(env: dict) -> int:
    n = 1
    for k, v in env.items():
        n += len(k) + 1 + len(v) + 1
    return n


def mkdir_len(n: int) -> Path:
    """Directory whose resolved path has exactly n characters."""
    ROOT.mkdir(parents=True, exist_ok=True)
    base = str(ROOT.resolve())
    extra = n - len(base) - 1
    if extra < 1:
        raise SystemExit("target dir_len %s too short for base %s (%s)" % (n, base, len(base)))
    p = ROOT / ("p" * extra)
    p.mkdir(parents=True, exist_ok=True)
    actual = str(p.resolve())
    if len(actual) != n:
        raise SystemExit("wanted dir_len %s got %s path %r" % (n, len(actual), actual))
    return p


def image_dir_for(name: str, image_len: int) -> Path:
    # image = dir + '\\' + name
    dir_len = image_len - 1 - len(name)
    if dir_len < len(str(ROOT.resolve())) + 2:
        raise ValueError("image_len %s too short for %s (dir_len %s)" % (image_len, name, dir_len))
    return mkdir_len(dir_len)


def run_copy(src: Path, image_len: int, pad: int, expect_hash: str) -> dict:
    name = src.name
    rec = {
        "name": name,
        "want_image_len": image_len,
        "pad": pad,
    }
    try:
        d = image_dir_for(name, image_len)
    except ValueError as e:
        rec["error"] = str(e)
        rec["skipped"] = True
        return rec
    dest = d / name
    shutil.copy2(src, dest)
    got = sha256(dest)
    image = str(dest.resolve())
    cwd = str(d.resolve())
    rec.update(
        {
            "image": image,
            "image_len": len(image),
            "cwd": cwd,
            "cwd_len": len(cwd),
            "copy_hash": got,
            "hash_ok": got == expect_hash,
        }
    )
    if got != expect_hash:
        rec["error"] = "copy hash mismatch"
        return rec
    env = os.environ.copy()
    if pad:
        env["LMX_CWD_PAD"] = "E" * pad
    rec["env_size"] = env_size(env)
    try:
        r = subprocess.run(
            [image],
            cwd=cwd,
            env=env,
            capture_output=True,
            timeout=TIMEOUT,
            text=True,
            errors="replace",
        )
        rec["exit"] = r.returncode
        rec["timeout"] = False
        rec["stdout_head"] = (r.stdout or "")[-180:]
        rec["stderr_head"] = (r.stderr or "")[-180:]
    except subprocess.TimeoutExpired:
        rec["exit"] = None
        rec["timeout"] = True
    return rec


def list_exes() -> list[Path]:
    return sorted(p for p in BIN.glob("*.exe") if p.is_file())


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["dirty", "ladder"], default="dirty")
    args = ap.parse_args()
    ROOT.mkdir(parents=True, exist_ok=True)
    exes = list_exes()
    hashes = {p.name: sha256(p) for p in exes}
    report: dict = {
        "stamp": str(STAMP),
        "mode": args.mode,
        "headline_note": "relocation/env sweeps find bugs but cannot prove absence",
        "original_dirty_image_len": len(str((BIN / DIRTY).resolve())),
        "original_dirty_sha256": hashes.get(DIRTY),
        "exe_count": len(exes),
        "runs": [],
    }

    if args.mode == "dirty":
        src = BIN / DIRTY
        h = hashes[DIRTY]
        crashed = False
        for L in DIRTY_TARGETS:
            rec = run_copy(src, L, 0, h)
            report["runs"].append(rec)
            print(
                "dirty pad0 want=%s image_len=%s cwd_len=%s exit=%s timeout=%s hash_ok=%s"
                % (
                    L,
                    rec.get("image_len"),
                    rec.get("cwd_len"),
                    rec.get("exit"),
                    rec.get("timeout"),
                    rec.get("hash_ok"),
                ),
                flush=True,
            )
            if rec.get("exit") not in (0, None) and not rec.get("skipped"):
                crashed = True
                # keep going through 145 to bracket, then stop longer rungs
                if L >= 145:
                    break
        # env pad at 126 and 140 (or nearest obtained)
        for L in (126, 140):
            rec = run_copy(src, L, 4096, h)
            report["runs"].append(rec)
            print(
                "dirty pad4096 want=%s image_len=%s cwd_len=%s exit=%s env_size=%s"
                % (L, rec.get("image_len"), rec.get("cwd_len"), rec.get("exit"), rec.get("env_size")),
                flush=True,
            )
        report["dirty_crash_seen"] = crashed
        out = STAMP / "image_dirty_109.json"
        out.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print("wrote", out)
        return 0

    # full ladder
    names = [p.name for p in exes if p.name not in SKIP_LADDER]
    report["ladder_names"] = names
    report["skipped"] = sorted(SKIP_LADDER)
    for p in exes:
        if p.name in SKIP_LADDER:
            continue
        h = hashes[p.name]
        crash_lens = []
        for L in TARGETS:
            rec = run_copy(p, L, 0, h)
            report["runs"].append(rec)
            print(
                "%s pad0 want=%s image_len=%s exit=%s timeout=%s"
                % (p.name, L, rec.get("image_len"), rec.get("exit"), rec.get("timeout")),
                flush=True,
            )
            if rec.get("timeout"):
                crash_lens.append(L)
                break
            if rec.get("exit") not in (0, None) and not rec.get("skipped"):
                crash_lens.append(L)
                break
        for L in (140, 231):
            if crash_lens and L > min(crash_lens):
                continue
            rec = run_copy(p, L, 4096, h)
            report["runs"].append(rec)
            print(
                "%s pad4096 want=%s image_len=%s exit=%s"
                % (p.name, L, rec.get("image_len"), rec.get("exit")),
                flush=True,
            )
            if rec.get("exit") not in (0, None) and not rec.get("skipped"):
                break
            if rec.get("timeout"):
                break
    OUT.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("wrote", OUT, "runs", len(report["runs"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
