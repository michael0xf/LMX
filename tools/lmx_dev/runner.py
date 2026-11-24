"""The same serial, receipt-producing runner serves CLI and MCP."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import time
import uuid
from contextlib import contextmanager
from pathlib import Path
from threading import Event

from .diagnostics import collect, is_hosted_p0_rejection
from .process import available_memory_mb, execute


def sha(path: Path) -> str:
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + "." + uuid.uuid4().hex + ".tmp")
    temp.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    # Windows readers (including an MCP client inspecting receipts) may briefly
    # hold the destination without FILE_SHARE_DELETE. Keep the replacement atomic.
    for attempt in range(20):
        try:
            temp.replace(path)
            break
        except PermissionError:
            if os.name != "nt" or attempt == 19:
                raise
            time.sleep(.05)


def snapshot(paths: list[Path]) -> dict:
    result = {}
    for path in paths:
        if not path.exists():
            result[str(path)] = None
        elif path.is_file():
            result[str(path)] = sha(path)
        else:
            for file in sorted(path.rglob("*")):
                if file.is_file():
                    result[str(file)] = sha(file)
    return result


class Unavailable(Exception):
    pass


def public_result(result: dict) -> dict:
    """Keep commands/snapshots in the receipt, rather than every model response."""
    keys = ("operation", "execution", "result", "achievedPhase", "stale", "message",
            "runId", "exitCode", "logicalExitCode", "durationSeconds", "log", "receipt", "diagnostics",
            "diagnosticCount", "unparsedDiagnosticLines", "diagnosticsOmitted")
    answer = {key: result[key] for key in keys if key in result}
    if result.get("artifacts"):
        answer["artifactFiles"] = list(result["artifacts"])
    return answer


@contextmanager
def machine_lock(path: Path, markers: list[Path]):
    if any(p.exists() for p in markers):
        raise Unavailable("The existing docs/timing pipeline marker is present.")
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.mkdir()
    except FileExistsError:
        raise Unavailable(f"Pipeline busy: {path}") from None
    owner = path / "lmx-dev-owner.json"
    try:
        write_json(owner, {"pid": os.getpid(), "created": time.time()})
        if any(p.exists() for p in markers):
            raise Unavailable("Another pipeline marker appeared; no command was started.")
        yield
    finally:
        owner.unlink(missing_ok=True)
        path.rmdir()  # Never remove someone else's files or recursively delete a lock.


class Runner:
    def __init__(self, root: Path, config: Path):
        self.root, self.config = root.resolve(), config.resolve()

    def load(self) -> dict:
        if not self.config.exists():
            raise Unavailable(f"Configure accepted producers first: {self.config}")
        raw = self.config.read_bytes()
        data = json.loads(raw)
        if data.get("version") != 1:
            raise ValueError("Unsupported configuration version")
        data["_loadedHash"] = hashlib.sha256(raw).hexdigest()
        return data

    def gate(self, config: dict) -> None:
        path = Path(config["permit"])
        if not path.exists():
            raise Unavailable("Compiler window is closed. The lead must grant a permit from CLI after freeing the pipeline.")
        permit = json.loads(path.read_text(encoding="utf-8"))
        if (permit.get("configHash") != config["_loadedHash"] or sha(self.config) != config["_loadedHash"]
                or permit.get("expires", 0) <= time.time()):
            raise Unavailable("Compiler permit expired or belongs to a different producer configuration.")

    def status(self) -> dict:
        try:
            config = self.load()
            self.gate(config)
            ready, reason = True, None
        except (OSError, ValueError, KeyError, Unavailable) as error:
            ready, reason = False, str(error)
        try:
            config = self.load()
        except (OSError, ValueError, Unavailable):
            config = {}
        lock = config.get("lock")
        return {"compilerWindow": "permitted" if ready else "closed", "reason": reason,
                "pipelineBusy": bool(lock and Path(lock).exists()), "config": str(self.config),
                "operations": {name: {"description": op.get("description"),
                                      "configured": not bool(op.get("unavailable")),
                                      "reason": op.get("unavailable")}
                               for name, op in config.get("operations", {}).items()}}

    def run(self, operation: str, file: str | None = None, cancel: Event | None = None) -> dict:
        cancel = cancel or Event()
        result = {"operation": operation, "execution": "unavailable", "result": "notRun",
                  "achievedPhase": None, "stale": None}
        run_dir = None
        try:
            config = self.load()
            op = config.get("operations", {}).get(operation)
            if op is None or op.get("unavailable"):
                raise Unavailable((op or {}).get("unavailable", "Operation is not configured"))
            source = None
            if operation.startswith("check:"):
                source = (self.root / (file or "")).resolve()
                if not source.is_relative_to(self.root) or not source.is_file():
                    raise ValueError("file must be an existing file inside the project")
                if source.suffix.lower() not in op.get("suffixes", [".lm2", ".lm3"]):
                    raise ValueError("This accepted producer does not support that file extension")
            self.gate(config)
            with machine_lock(Path(config["lock"]), [Path(p) for p in config.get("busy_markers", [])]):
                self.gate(config)
                available = available_memory_mb()
                if available is not None and available < op.get("memory_start_mb", config.get("memory_start_mb", 0)):
                    raise Unavailable(f"Insufficient available RAM/commit: {available} MiB")
                for path, expected in config.get("pins", {}).items():
                    if not Path(path).is_file() or sha(Path(path)) != expected:
                        raise Unavailable(f"Accepted producer/dependency changed: {path}")
                run_dir = Path(config["runs"]) / (time.strftime("%Y%m%d-%H%M%S-") + uuid.uuid4().hex[:12])
                run_dir.mkdir(parents=True)
                result.update(runId=run_dir.name, runDirectory=str(run_dir), receipt=str(run_dir / "receipt.json"))
                paths = [self.config, *[Path(p) for p in config.get("watch", [])],
                         *[Path(p) for p in config.get("pins", {})]]
                if source:
                    paths.append(source)
                before = snapshot(paths)
                write_json(run_dir / "inputs-before.json", before)
                variables = dict(config.get("variables", {}), repo=str(self.root), run=str(run_dir),
                                 source=str(source or ""), stage=str(config.get("stage", "")))
                if op.get("copy_stage"):
                    stage = run_dir / "stage"
                    shutil.copytree(config["stage"], stage)
                    variables["stage"] = str(stage)
                    for src, relative in config.get("stage_files", {}).items():
                        destination = (stage / relative).resolve()
                        if not destination.is_relative_to(stage.resolve()):
                            raise ValueError("stage_files destination escapes fresh stage")
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(src, destination)
                fmt = lambda value: value.format_map(variables)
                argv = [fmt(arg) for arg in op["argv"]]
                if not Path(argv[0]).is_absolute() or Path(argv[0]).suffix.lower() in (".bat", ".cmd"):
                    raise ValueError("Executable must be an absolute executable path, not a shell script")
                cwd = Path(fmt(op["cwd"]))
                env = os.environ.copy()
                for key, value in config.get("environment", {}).items():
                    if value is None:
                        env.pop(key, None)
                    else:
                        env[key] = fmt(value)
                result.update(argv=argv, cwd=str(cwd), description=op.get("description"),
                              log=str(run_dir / "output.log"), exitCode=None,
                              inputSnapshot=str(run_dir / "inputs-before.json"),
                              inputCoverage="Explicit file, configured watch roots and pinned producers. External includes outside this closure are not tracked.",
                              environment=config.get("environment", {}),
                              environmentHash=hashlib.sha256(json.dumps(sorted(env.items())).encode()).hexdigest())
                started = time.monotonic()
                write_json(run_dir / "receipt.json", dict(result, execution="running", result="indeterminate"))
                self.gate(config)
                state, code = execute(argv, cwd, env, run_dir / "output.log", op.get("timeout", 60),
                                      cancel, config.get("memory_floor_mb", 0))
                result.update(execution=state, exitCode=code, result="indeterminate",
                              durationSeconds=round(time.monotonic() - started, 3))
                if state == "completed":
                    if code == 0:
                        missing = []
                        result["artifacts"] = {}
                        for artifact in op.get("artifacts", []):
                            path = Path(fmt(artifact))
                            if not path.resolve().is_relative_to(run_dir.resolve()):
                                raise ValueError("Expected artifacts must belong to this fresh run")
                            if not path.is_file() or not path.stat().st_size:
                                missing.append(str(path))
                            else:
                                result["artifacts"][str(path)] = sha(path)
                        success = op.get("success_pattern")
                        if success:
                            with (run_dir / "output.log").open(encoding="utf-8", errors="replace") as log:
                                if not any(re.search(success, line) for line in log):
                                    missing.append("success receipt in output")
                        if missing:
                            result.update(execution="protocolError", message="Missing: " + ", ".join(missing))
                        else:
                            result.update(result="passed", achievedPhase=op["achieved_phase"])
                    elif code in op.get("rejected_codes", []):
                        result.update(result="rejected")
                    else:
                        crash = code < 0 or code >= 0x80000000
                        result.update(execution="crash" if crash else "protocolError",
                                      message="Exit code is outside the configured rejection contract")
                result.update(collect(run_dir / "output.log", str(source) if source else None))
                if state == "completed" and op.get("hosted_exit_adapter") == "p0-v1" and is_hosted_p0_rejection(result):
                    result.update(execution="completed", result="rejected",
                                  message="P0 rejected the source with logical exit 2; the hosted driver reports process exit 1.")
                after = snapshot(paths)
                write_json(run_dir / "inputs-after.json", after)
                result["stale"] = before != after
                if result["stale"]:
                    result["result"] = "indeterminate"
                    result["message"] = "Inputs changed during this run; this is not a verdict on the current tree."
        except KeyboardInterrupt:
            result.update(execution="cancelled", result="indeterminate", message="Interrupted; owned process tree terminated")
        except Unavailable as error:
            result["message"] = str(error)
        except Exception as error:
            result.update(execution="protocolError", result="indeterminate", message=str(error))
        finally:
            if run_dir is not None:
                write_json(run_dir / "receipt.json", result)
        return result
