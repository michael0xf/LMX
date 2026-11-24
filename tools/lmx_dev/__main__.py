import argparse
import json
import sys
import time
from pathlib import Path

from .closures import DEFAULT_CLOSURE, select
from .runner import Runner, public_result, sha, write_json
from .spec import SpecIndex


def grant(runner: Runner, seconds: int, reason: str, closures: list[str]) -> dict:
    """Lead only, CLI only: the window is never opened by MCP.

    The permit names the closures it admits and, for each registered one, the hash of its effective configuration.
    With names it admits exactly those (the accepted bundle only when it is named: ``--closure accepted``).
    Without names it admits the accepted bundle only and keeps the former shape.
    """
    data = runner.load()
    if Path(data["lock"]).exists() or any(Path(p).exists() for p in data.get("busy_markers", [])):
        raise ValueError("The shared pipeline is busy")
    admitted, hashes = [], {}
    for name in dict.fromkeys(closures):
        effective = select(data, name)
        admitted.append(name)
        if name != DEFAULT_CLOSURE:
            hashes[name] = effective["effectiveHash"]
    # A scoped permit carries no configHash: a runner older than closures then reads no binding at all and keeps
    # the window closed, instead of running the accepted producer under a permit granted for a candidate.
    permit = {"expires": time.time() + seconds, "reason": reason}
    if closures:
        permit.update(scopedConfigHash=sha(runner.config), closures=admitted, effectiveHashes=hashes)
    else:
        permit["configHash"] = sha(runner.config)
    write_json(Path(data["permit"]), permit)
    return permit


def main() -> int:
    parser = argparse.ArgumentParser(description="LMX local development services")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--config", type=Path)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("serve")
    sub.add_parser("status")
    sub.add_parser("configure-w3")
    spec = sub.add_parser("spec")
    spec.add_argument("topic")
    spec.add_argument("--max-chars", type=int, default=2600)
    spec.add_argument("--include-history", action="store_true")
    check = sub.add_parser("check")
    check.add_argument("file")
    check.add_argument("--phase", choices=["syntax", "static", "translate"], default="syntax")
    check.add_argument("--closure", default="",
                       help="Registered producer closure for syntax/translate/static (name only); default: the accepted bundle")
    bootstrap = sub.add_parser("bootstrap")
    bootstrap.add_argument("profile", choices=["smoke", "selfHost"], default="smoke", nargs="?")
    permit = sub.add_parser("permit", help="Lead only: admit compiler jobs after releasing the shared pipeline")
    permit.add_argument("--seconds", required=True, type=int)
    permit.add_argument("--reason", required=True)
    permit.add_argument("--closure", action="append", default=[],
                        help="Admit exactly the closures named here (repeatable; the accepted bundle is `accepted`); "
                             "without the flag the permit admits the accepted bundle only")
    sub.add_parser("close-window")
    args = parser.parse_args()
    root = args.root.resolve()
    config = (args.config or root / "build2/lmx_dev/config.json").resolve()
    runner = Runner(root, config)
    index = SpecIndex(root, Path(__file__).with_name("catalogue.json"))
    try:
        if args.command == "serve":
            from .server import create_server
            create_server(index, runner).run(transport="stdio", show_banner=False)
            return 0
        if args.command == "spec":
            result = index.search(args.topic, args.max_chars, args.include_history)
        elif args.command == "configure-w3":
            from .configure import accepted_w3
            if config.exists():
                raise ValueError("Configuration already exists; review/edit it instead of overwriting producer pins")
            result = accepted_w3(root, config)
        elif args.command == "status":
            result = runner.status()
        elif args.command == "permit":
            if not 1 <= args.seconds <= 86400 or not args.reason.strip():
                raise ValueError("Permit requires a reason and 1..86400 seconds")
            result = grant(runner, args.seconds, args.reason, args.closure)
        elif args.command == "close-window":
            Path(runner.load()["permit"]).unlink(missing_ok=True)
            result = {"compilerWindow": "closed", "note": "Running jobs keep their lock until completion/cancellation."}
        else:
            result = (runner.run("check:" + args.phase, args.file, closure=args.closure) if args.command == "check"
                      else runner.run("bootstrap:" + args.profile))
            result = public_result(result)
    except Exception as error:
        if args.command == "serve":
            print(f"LMX MCP startup failed: {error}", file=sys.stderr)
            return 1
        result = {"execution": "protocolError", "result": "indeterminate", "message": str(error)}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 1 if result.get("execution") in ("crash", "protocolError", "timeout", "unavailable") or result.get("result") in ("rejected", "indeterminate") or result.get("status") == "indexError" else 0


if __name__ == "__main__":
    sys.exit(main())
