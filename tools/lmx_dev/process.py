"""Owned process trees: Windows Job Objects, POSIX sessions. No shell."""
from __future__ import annotations

import os
import signal
import subprocess
import time
from pathlib import Path
from threading import Event


def available_memory_mb() -> int | None:
    if os.name != "nt":
        return None
    import ctypes
    class Status(ctypes.Structure):
        _fields_ = [("length", ctypes.c_ulong), ("load", ctypes.c_ulong)] + [
            (name, ctypes.c_ulonglong) for name in
            ("physical", "available", "commit", "free_commit", "virtual", "free_virtual", "extended")]
    status = Status()
    status.length = ctypes.sizeof(status)
    if not ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
        raise OSError("GlobalMemoryStatusEx failed")
    return min(status.available, status.free_commit) // (1024 * 1024)


def execute(argv: list[str], cwd: Path, env: dict, log: Path, timeout: float,
            cancel: Event, memory_floor_mb: int = 0) -> tuple[str, int | None]:
    start = time.monotonic()
    with log.open("wb", buffering=0) as output, open(os.devnull, "rb") as stdin:
        if cancel.is_set():
            return "cancelled", None
        if os.name == "nt":
            import msvcrt
            import win32api
            import win32con
            import win32event
            import win32job
            import win32process
            job = win32job.CreateJobObject(None, "")
            limits = win32job.QueryInformationJobObject(job, win32job.JobObjectExtendedLimitInformation)
            limits["BasicLimitInformation"]["LimitFlags"] |= win32job.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
            win32job.SetInformationJobObject(job, win32job.JobObjectExtendedLimitInformation, limits)
            process = thread = None
            assigned = False
            try:
                startup = win32process.STARTUPINFO()
                startup.dwFlags = win32process.STARTF_USESTDHANDLES
                startup.hStdInput = msvcrt.get_osfhandle(stdin.fileno())
                startup.hStdOutput = startup.hStdError = msvcrt.get_osfhandle(output.fileno())
                handles = [startup.hStdInput, startup.hStdOutput]
                for handle in handles:
                    os.set_handle_inheritable(handle, True)
                try:
                    process, thread, _, _ = win32process.CreateProcess(
                        argv[0], subprocess.list2cmdline(argv), None, None, True,
                        win32con.CREATE_SUSPENDED | win32con.CREATE_NO_WINDOW,
                        env, str(cwd), startup)
                finally:
                    for handle in handles:
                        os.set_handle_inheritable(handle, False)
                # Child cannot create descendants before it belongs to our kill-on-close job.
                win32job.AssignProcessToJobObject(job, process)
                assigned = True
                win32process.ResumeThread(thread)
                def poll():
                    if win32event.WaitForSingleObject(process, 0) == win32event.WAIT_OBJECT_0:
                        return win32process.GetExitCodeProcess(process)
                    return None
                return monitor(poll, start, timeout, cancel, memory_floor_mb)
            finally:
                if process:
                    # Also terminates descendants left behind by a normally exited parent.
                    if assigned:
                        win32job.TerminateJobObject(job, 1)
                    elif win32event.WaitForSingleObject(process, 0) != win32event.WAIT_OBJECT_0:
                        win32api.TerminateProcess(process, 1)  # assignment failure while suspended
                    win32event.WaitForSingleObject(process, 10000)
                    if assigned:
                        deadline = time.monotonic() + 10
                        while win32job.QueryInformationJobObject(job, win32job.JobObjectBasicAccountingInformation)["ActiveProcesses"]:
                            if time.monotonic() >= deadline:
                                raise RuntimeError("Timed out waiting for the terminated process tree")
                            time.sleep(.01)
                    process.Close()
                if thread:
                    thread.Close()
                job.Close()
        else:
            process = subprocess.Popen(argv, cwd=cwd, env=env, stdin=stdin, stdout=output,
                                       stderr=subprocess.STDOUT, shell=False, start_new_session=True)
            try:
                return monitor(process.poll, start, timeout, cancel, memory_floor_mb)
            finally:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()


def monitor(poll, start: float, timeout: float, cancel: Event, floor: int) -> tuple[str, int | None]:
    while True:
        code = poll()
        if code is not None:
            return "completed", code
        if cancel.is_set():
            return "cancelled", None
        if time.monotonic() - start >= timeout:
            return "timeout", None
        if floor:
            available = available_memory_mb()
            if available is not None and available < floor:
                return "resourceLimit", None
        cancel.wait(0.1)
