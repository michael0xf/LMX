"""Registered producer closures for the check phases.

The flat configuration is the accepted bundle: the default closure, named ``accepted``. ``closures`` may register
further bundles by name. A registered closure declares its stage and its producers ``graph`` and ``fe`` explicitly,
pins them (``pins``; ``pinsManifest`` adds the lines of a sha256sum file) and gives its stage as a hashed set: the
exact set of files under ``stage/src`` in ``stageManifest``, a sha256sum file that is itself pinned. The operation
templates, the lock, the permit and the run folders stay common: a check on a closure runs the accepted template
with that closure's verified ``{graph}``, ``{fe}`` and ``{stage}``. Before any process starts, the command of the
phase starts with the declared producer and that file has the pinned hash.

Nothing here starts a process, grants a permit or reads a path given by a caller: only a registered name selects a
bundle. ``Refused`` means the service has no verdict and starts nothing; ``Malformed`` is a configuration error.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import Path

DEFAULT_CLOSURE = "accepted"
ROLES = ("accepted", "candidate")
CHECK_PREFIX = "check:"
# The variable of the accepted template that is the producer (argv[0]) of a check phase.
PRODUCERS = {"check:syntax": "graph", "check:translate": "fe", "check:static": "fe"}
# The optional phase a bundle declares itself: its fe producer offers the --check-only word (hosted-check-v1).
STATIC = "check:static"
MANIFESTS = ("stageManifest", "pinsManifest")
NAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$")
MANIFEST_LINE = re.compile(r"^([0-9a-fA-F]{64})\s+\*?(.+?)\s*$")
HASHED = ("closureName", "closureRole", "acceptedRevision", "description", "variables", "pins", "stage",
          "stageManifest", "pinsManifest", "environment", "operations", "static")
LISTED = 5


class Refused(Exception):
    """No verdict: the closure is unknown, not admitted or not intact. Nothing was started."""

    def __init__(self, message: str, inventory: dict | None = None):
        super().__init__(message)
        self.inventory = inventory


class Malformed(ValueError):
    """The configuration cannot be read as a set of closures."""


def sha(path: Path) -> str:
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def key(path) -> str:
    """One spelling for one file: pins and manifests may spell a Windows path either way."""
    return os.path.normcase(os.path.abspath(str(path)))


def validate(config: dict) -> None:
    """The shape of ``closures``; what a single closure needs is asked when it is selected."""
    if "static" in config and not isinstance(config["static"], bool):
        raise Malformed("static must be true or false: it declares that the accepted fe producer offers --check-only")
    registered = config.get("closures")
    if registered is None:
        return
    if not isinstance(registered, dict):
        raise Malformed("closures must be an object of named producer closures")
    for name, closure in registered.items():
        if not isinstance(name, str) or not NAME.match(name):
            raise Malformed(f"closures: {name!r} is not a closure name (letters, digits, . _ -)")
        if name == DEFAULT_CLOSURE:
            raise Malformed(f"closures: {DEFAULT_CLOSURE!r} names the flat accepted bundle and is not registered")
        if not isinstance(closure, dict):
            raise Malformed(f"closures.{name}: a closure is an object")
        if "static" in closure and not isinstance(closure["static"], bool):
            raise Malformed(f"closures.{name}: static must be true or false")


def merge(pins: dict, entries: dict, origin: str) -> dict:
    """Inline pins and the lines of a manifest: one file has one hash, or the closure is refused."""
    merged = {key(path): (path, expected) for path, expected in pins.items()}
    for canonical, (expected, spelling) in entries.items():
        if canonical in merged and merged[canonical][1] != expected:
            raise Refused(f"{origin}: {merged[canonical][0]} is listed twice with different hashes")
        merged.setdefault(canonical, (spelling, expected))
    return {path: expected for path, expected in merged.values()}


def read_manifest(path: Path, base: Path) -> tuple[dict, str]:
    """The lines of a sha256sum file, <sha256>  <path>: absolute paths as written, relative ones under base.

    Answers the entries by canonical path -- the hash and the path as the line spells it --, and the hash of the
    bytes they were read from: a later check under the lock compares that hash with the pinned one, so the entries
    are bound to the file that was verified.
    """
    if not path.is_file():
        raise Refused(f"Manifest is missing: {path}")
    data = path.read_bytes()
    entries = {}
    for number, line in enumerate(data.decode("utf-8-sig").splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        match = MANIFEST_LINE.match(line)
        if not match:
            raise Refused(f"{path}:{number}: not a sha256sum line")
        target = Path(match[2])
        spelling = str(target if target.is_absolute() else base / target)
        canonical = key(spelling)
        if canonical in entries and entries[canonical][0] != match[1].lower():
            raise Refused(f"{path}:{number}: {match[2]} is listed twice with different hashes")
        entries[canonical] = (match[1].lower(), spelling)
    return entries, hashlib.sha256(data).hexdigest()


def digest(effective: dict) -> str:
    """The effective configuration of one closure as one hash: what the permit admits for that name."""
    material = {}
    for name in HASHED:
        value = effective.get(name)
        if name == "operations":
            value = {op: spec for op, spec in (value or {}).items() if op.startswith(CHECK_PREFIX)}
        if name == "static" and value is None:
            continue  # a bundle that declares no static phase keeps the hash it had before the phase existed
        if isinstance(value, dict):
            value = {str(k): value[k] for k in sorted(value)}
        material[name] = value
    return hashlib.sha256(json.dumps(material, sort_keys=True, separators=(",", ":")).encode("utf-8")).hexdigest()


def select(config: dict, name: str = "") -> dict:
    """The effective configuration of a closure: the common parts and this closure's producers and stage."""
    chosen = name or DEFAULT_CLOSURE
    registered = config.get("closures") or {}
    if chosen != DEFAULT_CLOSURE and chosen not in registered:
        raise Refused(f"Unknown producer closure: {chosen!r}. Registered: {', '.join([DEFAULT_CLOSURE, *registered])}")
    effective = {k: v for k, v in config.items() if k not in ("closures", "_loadedHash")}
    effective["closureName"] = chosen
    if chosen == DEFAULT_CLOSURE:
        effective["closureRole"] = "accepted"
        effective["effectiveHash"] = digest(effective)
        return effective
    closure = registered[chosen]
    role = closure.get("role", "candidate")
    if role not in ROLES:
        raise Refused(f"Closure {chosen!r}: role is {role!r}, not one of {', '.join(ROLES)}")
    for field in ("description", "acceptedRevision", "variables", "stage"):
        if field in closure:
            effective[field] = closure[field]
    # Nor the static phase: the closure declares it for its own fe producer; undeclared, none is inherited and its
    # content hashes as it did before the phase existed.
    if closure.get("static") is True:
        effective["static"] = True
    else:
        effective.pop("static", None)
    # A named bundle inherits no producer and no stage from the accepted one: it declares them.
    variables = effective.get("variables")
    if not isinstance(variables, dict) or any(not isinstance(variables.get(p), str) or not variables[p] for p in PRODUCERS.values()):
        raise Refused(f"Closure {chosen!r}: variables must name its own graph and fe producers")
    if not effective.get("stage") or not Path(effective["stage"]).is_dir():
        raise Refused(f"Closure {chosen!r}: stage is not a directory")
    if not closure.get("stageManifest"):
        raise Refused(f"Closure {chosen!r}: stageManifest is required; a stage is a hashed set, not a path")
    effective.update(closureRole=role, pins=dict(closure.get("pins", {})), stageManifest=closure["stageManifest"],
                     pinsManifest=closure.get("pinsManifest"), pinsManifestDigest=None)
    if effective["pinsManifest"]:
        manifest = Path(effective["pinsManifest"])
        entries, read = read_manifest(manifest, manifest.parent)
        effective["pins"] = merge(effective["pins"], entries, str(manifest))
        effective["pinsManifestDigest"] = read
    pinned = {key(path) for path in effective["pins"]}
    for field in MANIFESTS:
        if effective.get(field) and key(effective[field]) not in pinned:
            raise Refused(f"Closure {chosen!r}: {field} is not pinned: {effective[field]}")
    effective["effectiveHash"] = digest(effective)
    return effective


def require(operation: str, effective: dict) -> None:
    """Only the check phases run on a registered closure; the accepted bundle serves every operation."""
    if effective["closureName"] != DEFAULT_CLOSURE and not operation.startswith(CHECK_PREFIX):
        raise Refused(f"Operation {operation} runs on the accepted closure only, not on {effective['closureName']!r}.")
    if operation == STATIC and effective.get("static") is not True:
        raise Refused(f"Operation {operation} is not declared for closure {effective['closureName']!r}: a bundle offers it "
                      "only by declaring \"static\": true for an fe producer that has the --check-only word.")


def admit(permit: dict, effective: dict) -> None:
    """The permit names the closures it admits and the content of each; a permit without names admits the accepted one."""
    chosen = effective["closureName"]
    admitted = permit.get("closures")
    if admitted is None:
        admitted = [DEFAULT_CLOSURE]
    if chosen not in admitted:
        raise Refused(f"Compiler permit does not admit closure {chosen!r} (admitted: {', '.join(admitted)}).")
    if chosen != DEFAULT_CLOSURE and (permit.get("effectiveHashes") or {}).get(chosen) != effective["effectiveHash"]:
        raise Refused(f"Compiler permit belongs to a different content of closure {chosen!r}.")


def verify_pins(effective: dict) -> dict:
    """Every pinned producer and dependency is the file it was registered as; answers the pins by canonical path.

    A manifest expanded before the lock is bound to the bytes that were read: its pinned hash, the file under the
    lock and that digest are one.
    """
    chosen = effective["closureName"]
    prefix = "" if chosen == DEFAULT_CLOSURE else f"Closure {chosen!r}: "
    expected = {}
    for path, wanted in effective.get("pins", {}).items():
        if not Path(path).is_file() or sha(Path(path)) != wanted:
            raise Refused(f"{prefix}Accepted producer/dependency changed: {path}")
        expected[key(path)] = wanted
    for field in MANIFESTS:
        recorded = effective.get("pinsManifestDigest") if field == "pinsManifest" else None
        if recorded is not None and recorded != expected.get(key(effective[field])):
            raise Refused(f"Closure {chosen!r}: {field} changed after it was read: {effective[field]}")
    return expected


def verify_producer(effective: dict, operation: str, argv: list[str] | None = None) -> dict:
    """The producer a check runs is the one the closure declared and pinned.

    For a registered closure ``graph`` and ``fe`` are pinned files of the hash they were registered with, and the
    command of the phase starts with the declared producer: in the accepted template its argv[0]. A command that
    starts with any other file, pinned or not, is refused. The accepted bundle is verified by its pins as before.
    Answers the evidence the receipt names.
    """
    chosen = effective["closureName"]
    if chosen == DEFAULT_CLOSURE:
        return {}
    evidence = {}
    for name in PRODUCERS.values():
        declared = effective["variables"][name]
        path = Path(declared)
        wanted = next((v for p, v in effective.get("pins", {}).items() if key(p) == key(path)), None)
        if wanted is None:
            raise Refused(f"Closure {chosen!r}: {name} producer is not pinned: {declared}")
        if not path.is_file() or sha(path) != wanted:
            raise Refused(f"Closure {chosen!r}: {name} producer changed: {declared}")
        evidence[name] = {"path": declared, "sha256": wanted}
    used = PRODUCERS.get(operation)
    if used is None:
        raise Refused(f"Closure {chosen!r}: {operation} names no producer of a check phase.")
    evidence["operation"] = used
    if argv is not None:
        started = argv[0] if argv else ""
        if not started or key(Path(started)) != key(Path(effective["variables"][used])):
            raise Refused(f"Closure {chosen!r}: {operation} must start with its declared {used} producer "
                          f"({effective['variables'][used]}); the command starts with {started or 'nothing'}.")
    return evidence


def files_under(folder: Path, chosen: str) -> dict:
    """The files of a tree by canonical path. A link or a junction in it is a refusal, not a hidden subtree."""
    found = {}
    for base, dirs, files in os.walk(folder):
        for name in list(dirs) + files:
            path = Path(base) / name
            if path.is_symlink() or getattr(path, "is_junction", bool)():
                raise Refused(f"Closure {chosen!r}: stage/src contains a link: {path}")
        for name in files:
            found[key(Path(base) / name)] = Path(base) / name
    return found


def stage_inventory(effective: dict) -> tuple[dict, list[Path]]:
    """The stage of a closure against its manifest: the exact set of files under stage/src.

    A file added, missing or changed, a manifest entry outside stage/src, or a link in the tree is a refusal.
    What a producer reads outside the stage (system headers, external imports) is not tracked here.
    """
    chosen = effective["closureName"]
    manifest = Path(effective["stageManifest"]) if effective.get("stageManifest") else None
    if manifest is None:
        return {"tracked": False, "note": "stage is a path; its content is not verified"}, []
    stage = Path(effective["stage"])
    expected, _ = read_manifest(manifest, stage)
    source = key(stage / "src") + os.sep
    outside = sorted(expected[p][1] for p in expected if not p.startswith(source))
    if outside:
        raise Refused(f"Closure {chosen!r}: the stage manifest lists a file outside stage/src: {outside[0]}")
    present = files_under(stage / "src", chosen) if (stage / "src").is_dir() else {}
    added = sorted(str(present[p]) for p in present.keys() - expected.keys())
    missing = sorted(expected[p][1] for p in expected.keys() - present.keys())
    changed = sorted(expected[p][1] for p in expected if p in present and sha(present[p]) != expected[p][0])
    inventory = {"root": str(stage), "manifest": str(manifest), "manifestSha256": sha(manifest), "files": len(expected),
                 "tracked": True, "added": added[:LISTED], "missing": missing[:LISTED], "changed": changed[:LISTED],
                 "addedCount": len(added), "missingCount": len(missing), "changedCount": len(changed),
                 "coverage": "The exact set of files under stage/src. Reads outside the stage are not tracked."}
    if added or missing or changed:
        kinds = [f"{len(n)} {label}" for n, label in ((added, "added"), (missing, "missing"), (changed, "changed")) if n]
        raise Refused(f"Closure {chosen!r}: stage differs from its manifest: {', '.join(kinds)} "
                      f"(added {inventory['added']}, missing {inventory['missing']}, changed {inventory['changed']})", inventory)
    return inventory, [Path(expected[p][1]) for p in sorted(expected)]


def listing(config: dict, permit: dict | None) -> dict:
    """The closures a status shows: role, producers, content and what the current permit admits. Never raises."""
    answer = {}
    registered = config.get("closures") or {}
    for name in [DEFAULT_CLOSURE, *registered]:
        try:
            effective = select(config, "" if name == DEFAULT_CLOSURE else name)
            item = {"role": effective["closureRole"], "default": name == DEFAULT_CLOSURE,
                    "effectiveHash": effective["effectiveHash"],
                    "operations": [op for op in config.get("operations", {}) if op.startswith(CHECK_PREFIX)],
                    "static": effective.get("static") is True}
            if name != DEFAULT_CLOSURE:
                item["producers"] = {p: effective["variables"][p] for p in PRODUCERS.values()}
                item["stage"] = {"root": str(effective["stage"]), "manifest": str(effective["stageManifest"])}
                item["pins"] = len(effective["pins"])
            item["admitted"] = False
            if permit is not None:
                try:
                    admit(permit, effective)
                    item["admitted"] = True
                except Refused as error:
                    item["admission"] = str(error)
            else:
                item["admission"] = "No permit file."
        except (Refused, Malformed, OSError, ValueError) as error:
            item = {"default": name == DEFAULT_CLOSURE, "admitted": False, "problem": str(error)}
        answer[name] = item
    return answer
