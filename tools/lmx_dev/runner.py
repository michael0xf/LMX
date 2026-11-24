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

from .closures import (Refused, admit, key as same_path, listing, require, select, stage_inventory, validate,
                       verify_pins, verify_producer)
from .diagnostics import check_evidence, collect, is_hosted_p0_rejection
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


CHECK_ADAPTER = "hosted-check-v1"
# What the frontend's environment can ask it for besides a translation: trace and dump files, a fault at an allocation.
OUTPUT_ENV = ("L2_ALLOC_TRACE", "L2_ALLOC_LOG", "L2_COLON_WRITES", "L2_EXPR_PLACES_OUT", "L2_PATH_FACTS", "L2_FAIL_MALLOC")
OWN_RUN_FILES = ("receipt.json", "inputs-before.json", "inputs-after.json", "output.log", "output-guard-before.json")
COVERAGE = ("The common semantic analysis of one .lm2 source in program context by the accepted frontend, before the "
            "backend's COUNT and emission: its P0 parse and its CHECK of names, types, calls and providers, with the "
            "rules of a machine module. The backend's COUNT and emission do not run: no L1 is written, no C is compiled, "
            "nothing is executed. It is not the normative language sys\\check or sys\\checkL3, "
            "and it takes no library, machine or construct context: a module the build translates with --library is "
            "checked as the program's code here.")


def tree_state(path: Path, deep: bool = True) -> dict:
    """The files of a folder by relative name with their size and time of change; the shallow form reads the folder alone."""
    if not path.is_dir():
        return {}
    entries = sorted(path.rglob("*") if deep else path.iterdir())
    return {str(entry.relative_to(path)): [entry.stat().st_size, entry.stat().st_mtime_ns]
            for entry in entries if entry.is_file()}


def left_behind(run_dir: Path, guard: dict) -> list[str]:
    """What the process left behind: a file of its run folder that is not the service's own, a file added, changed or
    removed under a guarded folder (the working stage source tree, the folder of the checked source)."""
    found = ["run: " + name for name in tree_state(run_dir) if name not in OWN_RUN_FILES]
    for label, item in guard.items():
        after = tree_state(Path(label), item["deep"])
        found += [label + ": " + name + " (removed)" for name in sorted(set(item["state"]) - set(after))]
        found += [label + ": " + name for name in sorted(set(after) - set(item["state"]))]
        found += [label + ": " + name + " (changed)" for name in sorted(set(after) & set(item["state"]))
                  if after[name] != item["state"][name]]
    return found


def hosted_check(result: dict, op: dict, run_dir: Path, guard: dict) -> dict:
    """hosted-check-v1: a verdict only from the complete evidence of the hosted frontend and a tree it left as it was.

    The process exit is the host driver's; the logical one is the frontend's own. A pass is process 0 with the driver's
    single done line and a clean log. A rejection is process 1 with the frontend's refusal code 1, the expected-exit
    check as the one failed check and nothing but located refusals of the checked source. Anything else -- another code,
    a line naming another file, an internal or memory failure, a file left behind -- is no verdict on the source.
    """
    written = left_behind(run_dir, guard)
    no_phase = dict(achievedPhase=None)
    if written:
        return dict(no_phase, execution="protocolError", result="indeterminate", writtenFiles=written[:10],
                    message="The check left a file behind, which is not its contract: " + "; ".join(written[:5]))
    code = result.get("exitCode")
    if code == 0:
        gaps = check_evidence(result, True)
        if not gaps:
            return dict(result="passed", achievedPhase=op["achieved_phase"], coverage=COVERAGE)
        return dict(no_phase, execution="protocolError", result="indeterminate", coverage=COVERAGE,
                    message="Process exit 0 without the evidence of a completed check: " + "; ".join(gaps))
    gaps = check_evidence(result, False)
    if code == 1 and not gaps:
        return dict(no_phase, execution="completed", result="rejected", coverage=COVERAGE,
                    message="The hosted frontend refused the source (its own exit 1): a hosted L2 CHECK rejection.")
    if result.get("execution") == "crash":
        return dict(no_phase, result="indeterminate", coverage=COVERAGE,
                    message="The hosted frontend crashed (process exit %s); not a verdict on the source." % code)
    return dict(no_phase, execution="protocolError", result="indeterminate", coverage=COVERAGE,
                message="Process exit %s is not a verdict on the source: %s" % (code, "; ".join(gaps) or "outside the contract"))


def public_result(result: dict) -> dict:
    """Keep commands/snapshots in the receipt, rather than every model response."""
    keys = ("operation", "execution", "result", "achievedPhase", "stale", "message",
            "runId", "exitCode", "logicalExitCode", "durationSeconds", "log", "receipt", "diagnostics",
            "diagnosticCount", "unparsedDiagnosticLines", "diagnosticsOmitted", "closure", "coverage", "writtenFiles")
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
        validate(data)
        data["_loadedHash"] = hashlib.sha256(raw).hexdigest()
        return data

    def permit(self, config: dict) -> dict:
        path = Path(config["permit"])
        if not path.exists():
            raise Unavailable("Compiler window is closed. The lead must grant a permit from CLI after freeing the pipeline.")
        return json.loads(path.read_text(encoding="utf-8"))

    def gate(self, config: dict, effective: dict | None = None) -> None:
        """The window is open for this configuration; with a selected closure, its name and content are admitted."""
        permit = self.permit(config)
        # A scoped permit (it names closures) binds the configuration under its own key: a runner older than
        # closures reads no configHash in it and keeps the window closed.
        bound = permit.get("scopedConfigHash" if permit.get("closures") else "configHash")
        if (bound != config["_loadedHash"] or sha(self.config) != config["_loadedHash"]
                or permit.get("expires", 0) <= time.time()):
            raise Unavailable("Compiler permit expired or belongs to a different producer configuration.")
        if effective is not None:
            try:
                admit(permit, effective)
            except Refused as error:
                raise Unavailable(str(error)) from None

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
        try:
            permit = self.permit(config) if config else None
        except (OSError, ValueError, KeyError, Unavailable):
            permit = None
        lock = config.get("lock")
        return {"compilerWindow": "permitted" if ready else "closed", "reason": reason,
                "pipelineBusy": bool(lock and Path(lock).exists()), "config": str(self.config),
                "operations": {name: {"description": op.get("description"),
                                      "configured": not bool(op.get("unavailable")),
                                      "reason": op.get("unavailable")}
                               for name, op in config.get("operations", {}).items()},
                # admitted: the permit names the closure and its registered content; the window is compilerWindow.
                "closures": listing(config, permit)}

    def run(self, operation: str, file: str | None = None, cancel: Event | None = None, closure: str = "") -> dict:
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
            # Which bundle answers: a registered name, or the accepted default. Both are refused before anything starts.
            try:
                effective = select(config, closure)
                require(operation, effective)
            except Refused as error:
                raise Unavailable(str(error)) from None
            result["closure"] = {"name": effective["closureName"], "role": effective["closureRole"],
                                 "selection": "explicit" if closure else "default",
                                 "effectiveHash": effective["effectiveHash"],
                                 "acceptedRevision": effective.get("acceptedRevision")}
            self.gate(config, effective)
            with machine_lock(Path(config["lock"]), [Path(p) for p in config.get("busy_markers", [])]):
                self.gate(config, effective)
                available = available_memory_mb()
                if available is not None and available < op.get("memory_start_mb", config.get("memory_start_mb", 0)):
                    raise Unavailable(f"Insufficient available RAM/commit: {available} MiB")
                # The integrity of the selected bundle is proved here, under the shared lock, before any process.
                try:
                    pins = verify_pins(effective)
                    result["closure"]["pinsVerified"] = len(pins)
                    # The producers of a registered closure are pinned files of their registered hash.
                    result["closure"]["producers"] = verify_producer(effective, operation)
                    inventory, stage_files = stage_inventory(effective)
                except Refused as error:
                    result["closure"]["stage"] = error.inventory
                    raise Unavailable(str(error)) from None
                result["closure"]["stage"] = inventory
                run_dir = Path(config["runs"]) / (time.strftime("%Y%m%d-%H%M%S-") + uuid.uuid4().hex[:12])
                run_dir.mkdir(parents=True)
                result.update(runId=run_dir.name, runDirectory=str(run_dir), receipt=str(run_dir / "receipt.json"))
                paths = [self.config, *[Path(p) for p in config.get("watch", [])],
                         *[Path(p) for p in effective.get("pins", {})], *stage_files]
                if source:
                    paths.append(source)
                before = snapshot(paths)
                write_json(run_dir / "inputs-before.json", before)
                variables = dict(effective.get("variables", {}), repo=str(self.root), run=str(run_dir),
                                 source=str(source or ""), stage=str(effective.get("stage", "")))
                if op.get("copy_stage"):
                    stage = run_dir / "stage"
                    shutil.copytree(effective["stage"], stage)
                    variables["stage"] = str(stage)
                    for src, relative in effective.get("stage_files", {}).items():
                        destination = (stage / relative).resolve()
                        if not destination.is_relative_to(stage.resolve()):
                            raise ValueError("stage_files destination escapes fresh stage")
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(src, destination)
                fmt = lambda value: value.format_map(variables)
                argv = [fmt(arg) for arg in op["argv"]]
                if not Path(argv[0]).is_absolute() or Path(argv[0]).suffix.lower() in (".bat", ".cmd"):
                    raise ValueError("Executable must be an absolute executable path, not a shell script")
                try:
                    # The command of the phase runs the declared producer: in the accepted template its argv[0].
                    verify_producer(effective, operation, argv)
                except Refused as error:
                    raise Unavailable(str(error)) from None
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
                              inputCoverage=("Explicit file, configured watch roots, pinned producers and the files of the stage manifest. Reads outside the stage are not tracked."
                                             if stage_files else
                                             "Explicit file, configured watch roots and pinned producers. External includes outside this closure are not tracked."),
                              environment=config.get("environment", {}),
                              environmentHash=hashlib.sha256(json.dumps(sorted(env.items())).encode()).hexdigest())
                started = time.monotonic()
                guard = {}
                if op.get("hosted_exit_adapter") == CHECK_ADAPTER:
                    if any(name in env for name in OUTPUT_ENV):
                        raise Unavailable("The environment carries " + ", ".join(name for name in OUTPUT_ENV if name in env)
                                          + ": it asks the frontend for a file or for a fault; a check writes nothing and "
                                          "injects nothing. Unset them.")
                    # A check writes nothing: the trees a file could appear in are listed before the process starts. The
                    # stage source tree is read deep, the folder of the source alone; one path by two spellings (a source
                    # checked inside the stage) is one tree, read as deep as either asked.
                    for label, deep in ((str(Path(effective["stage"]) / "src"), True), (str(source.parent), False)):
                        same = next((name for name in guard if same_path(name) == same_path(label)), None)
                        if same is None:
                            guard[label] = {"deep": deep}
                        else:
                            guard[same]["deep"] = guard[same]["deep"] or deep
                    guard = {label: dict(item, state=tree_state(Path(label), item["deep"])) for label, item in guard.items()}
                    write_json(run_dir / "output-guard-before.json", guard)
                write_json(run_dir / "receipt.json", dict(result, execution="running", result="indeterminate"))
                self.gate(config, effective)
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
                result.update(collect(run_dir / "output.log", str(source) if source else None,
                                      phase="static" if op.get("hosted_exit_adapter") == CHECK_ADAPTER else "translate"))
                if state == "completed" and op.get("hosted_exit_adapter") == CHECK_ADAPTER:
                    result.update(hosted_check(result, op, run_dir, guard))
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
