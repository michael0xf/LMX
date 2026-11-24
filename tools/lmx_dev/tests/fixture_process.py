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
