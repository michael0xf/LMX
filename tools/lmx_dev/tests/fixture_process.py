"""Controlled subprocess for runner tests. Not a simulated LMX compiler."""
import os
import subprocess
import sys
import time
from pathlib import Path

mode, output = sys.argv[1:3]
if mode == "ok":
    Path(output).write_text("fresh artifact", encoding="utf-8")
    print("FIXTURE complete")
elif mode == "reject":
    print("P0 parse error 4 at 2:3: expected delimiter", file=sys.stderr)
    print("unrecognized fatal diagnostic", file=sys.stderr)
    sys.exit(2)
elif mode == "hosted_reject":
    print(Path(__file__).with_name("hosted-p0-rejected.log").read_text(encoding="utf-8"), end="")
    sys.exit(1)
elif mode == "missing":
    print("FIXTURE complete")
elif mode == "exit":
    sys.exit(17)
elif mode == "crash":
    if os.name == "nt":
        import ctypes
        ctypes.windll.kernel32.ExitProcess(0xC0000005)
    else:
        import signal
        os.kill(os.getpid(), signal.SIGKILL)
elif mode == "stale":
    Path(output).write_text("fresh artifact", encoding="utf-8")
    Path(sys.argv[3]).write_text("changed", encoding="utf-8")
    print("FIXTURE complete")
elif mode == "child":
    while True:
        Path(output).write_text(str(time.time()), encoding="utf-8")
        time.sleep(.1)
elif mode == "tree":
    subprocess.Popen([sys.executable, __file__, "child", output])
    print("child launched", flush=True)
    time.sleep(60)
elif mode == "sleep":
    time.sleep(.5)
    Path(output).write_text("fresh artifact", encoding="utf-8")
    print("FIXTURE complete")
# The hosted frontend's check-only contract (hosted-check-v1): the driver's lines and the frontend's own exit. The
# template is `fixture MODE OUTPUT SOURCE`; OUTPUT is a file inside the run folder, cwd is the stage source tree.
elif mode.startswith("check_"):
    source = sys.argv[3]
    say = lambda *lines: [print(line, file=sys.stderr) for line in lines]
    refused = lambda where, message: say(f"l2trans error: {where}: {message}")
    driver = lambda code, failed: say("FAIL [exit] the launch's exit code is the expected one: R0's exit letter, or its success",
                                      f"l2_eternal_driver: exit {code}, expected 0", f"l2_eternal_driver: {failed} failed of 42")
    if mode == "check_ok":
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_reject":
        refused(f"{source}:3:5", "a reference where a number is asked")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_parse":
        say("l2trans parse error 19 at 1:33: unescaped newline in string literal")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_old":
        # A frontend without the word takes --check-only for its source.
        refused("--check-only:1:1", "expected a .lm2 source")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_internal":
        refused(f"{source}:1:1", "internal: missing unit")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_memory":
        refused(f"{source}:0:0", "out of memory")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_invariant":
        refused(source, "internal: a refusal said nothing (a step failed without a located diagnostic)")
        driver(3, 1)
        sys.exit(1)
    elif mode == "check_two":
        refused(f"{source}:3:5", "a reference where a number is asked")
        driver(1, 2)
        sys.exit(1)
    elif mode == "check_silent":
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_unparsed":
        refused(f"{source}:3:5", "a reference where a number is asked")
        say("unrecognized fatal diagnostic")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_read":
        say(f"l2trans parse error: {source}: cannot read the source")
        driver(1, 1)
        sys.exit(1)
    elif mode == "check_write_l1":
        Path(output).with_suffix(".lm1").write_text("L1 that a check never writes\n", encoding="utf-8")
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_write_stage":
        Path("lmx_dev_static_left_behind.lm1").write_text("written into the stage source tree\n", encoding="utf-8")
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_write_source":
        (Path(source).parent / "lmx_dev_static_left_behind.txt").write_text("written beside the source\n", encoding="utf-8")
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_write_stage_deep":
        (Path("l2src") / "lmx_dev_static_left_behind.lm1").write_text("written into a folder of the stage source tree\n",
                                                                      encoding="utf-8")
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_remove":
        Path("l2src/a.h.lm1").unlink()
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_talk":
        # The done line and a refusal said: what says an error cannot answer a pass.
        refused(f"{source}:1:1", "a reference where a number is asked")
        print("l2_eternal_driver: 42 checks, 0 roots")
    elif mode == "check_no_summary":
        print("nothing of the driver")
    elif mode == "check_exit":
        sys.exit(17)
    else:
        raise SystemExit("unknown fixture mode " + mode)
