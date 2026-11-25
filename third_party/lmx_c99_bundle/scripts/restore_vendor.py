#!/usr/bin/env python3
"""Restore selected vendor sources offline from original, unchanged inputs.

Only Python's standard library is used. Archives are read as streams; their
paths are never passed to extract()/extractall(). No network or build is run.
An existing destination is never overwritten.
"""

import argparse
import collections
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import sys
import tarfile
import zipfile


class RestoreError(Exception):
    pass


def relative_path(value):
    """Accept a canonical, portable relative path with no traversal."""
    if not isinstance(value, str) or not value or "\\" in value or "\0" in value:
        raise RestoreError("Invalid relative path: {!r}".format(value))
    parts = value.split("/")
    if any(part in ("", ".", "..") or ":" in part for part in parts):
        raise RestoreError("Unsafe relative path: {!r}".format(value))
    path = PurePosixPath(value)
    if path.is_absolute():
        raise RestoreError("Absolute path refused: {!r}".format(value))
    return path


def archive_member_path(value):
    """Permit an archive's conventional ./ prefix and trailing directory /."""
    if not isinstance(value, str) or "\\" in value or "\0" in value or value.startswith("/"):
        raise RestoreError("Unsafe archive member: {!r}".format(value))
    parts = value.split("/")
    if any(part == ".." or ":" in part for part in parts):
        raise RestoreError("Archive traversal refused: {!r}".format(value))
    normalized = "/".join(part for part in parts if part not in ("", "."))
    return relative_path(normalized) if normalized else None


def mode_value(value):
    if not isinstance(value, str) or not re.fullmatch(r"0[0-7]{3}", value):
        raise RestoreError("Invalid POSIX permission mode: {!r}".format(value))
    return int(value, 8)


def content_metadata(record):
    if not isinstance(record.get("bytes"), int) or record["bytes"] < 0:
        raise RestoreError("Invalid recorded file size")
    if not isinstance(record.get("sha256"), str) or not re.fullmatch(r"[0-9a-f]{64}", record["sha256"]):
        raise RestoreError("Invalid recorded SHA-256")


def read_manifest(path):
    with path.open("r", encoding="utf-8") as stream:
        data = json.load(stream)
    if data.get("schema_version") != 1:
        raise RestoreError("Unsupported source restoration manifest version")
    archives = {}
    input_paths = set()
    for entry in data["archives"]:
        key = entry["id"]
        if key in archives or entry["path"] in input_paths:
            raise RestoreError("Duplicate archive input: " + key)
        relative_path(entry["path"])
        content_metadata(entry)
        if entry["format"] not in ("tar", "zip"):
            raise RestoreError("Unsupported archive format: " + entry["format"])
        archives[key] = entry
        input_paths.add(entry["path"])
    directories = {}
    mode_value(data["vendor_root_mode"])
    for entry in data["directories"]:
        relative_path(entry["path"])
        mode_value(entry["mode"])
        if entry["path"] in directories:
            raise RestoreError("Duplicate directory: " + entry["path"])
        directories[entry["path"]] = entry
    files = {}
    for entry in data["files"]:
        relative_path(entry["path"])
        mode_value(entry["mode"])
        content_metadata(entry)
        if entry["path"] in files or entry["path"] in directories:
            raise RestoreError("Duplicate destination: " + entry["path"])
        source = entry["source"]
        if source["kind"] == "archive":
            if source["archive"] not in archives:
                raise RestoreError("Unknown input archive: " + source["archive"])
            if archive_member_path(source["member"]) is None:
                raise RestoreError("A file cannot use an archive root as its member")
        elif source["kind"] == "loose":
            relative_path(source["path"])
            if source["path"] in input_paths:
                raise RestoreError("Duplicate loose input: " + source["path"])
            input_paths.add(source["path"])
        else:
            raise RestoreError("Unsupported input kind: " + source["kind"])
        files[entry["path"]] = entry
    for name in list(directories) + list(files):
        parent = PurePosixPath(name).parent.as_posix()
        if parent != "." and parent not in directories:
            raise RestoreError("Unrecorded parent directory: " + parent)
    return data, archives, directories, files


def file_digest(path):
    digest = hashlib.sha256()
    size = 0
    with path.open("rb") as stream:
        while True:
            chunk = stream.read(1024 * 1024)
            if not chunk:
                break
            size += len(chunk)
            digest.update(chunk)
    return size, digest.hexdigest()


def input_path(root, name):
    path = root.joinpath(*relative_path(name).parts)
    resolved = path.resolve(strict=True)
    if root != resolved and root not in resolved.parents:
        raise RestoreError("Input escapes its root: " + name)
    if path.is_symlink() or not path.is_file():
        raise RestoreError("Input is not a regular file: " + name)
    return path


def verify_content(path, record):
    size, digest = file_digest(path)
    if size != record["bytes"] or digest != record["sha256"]:
        raise RestoreError("SHA-256/size mismatch: " + str(path))


def verify_inputs(root, archives, files):
    count = 0
    for record in archives.values():
        verify_content(input_path(root, record["path"]), record)
        count += 1
    for record in files.values():
        if record["source"]["kind"] == "loose":
            verify_content(input_path(root, record["source"]["path"]), record)
            count += 1
    return count


def write_checked(stream, destination, record):
    """Limit output to the exact recorded size and hash while writing."""
    digest = hashlib.sha256()
    size = 0
    path = destination.joinpath(*relative_path(record["path"]).parts)
    with path.open("xb") as output:
        while True:
            chunk = stream.read(min(1024 * 1024, record["bytes"] - size + 1))
            if not chunk:
                break
            size += len(chunk)
            if size > record["bytes"]:
                raise RestoreError("Input exceeds recorded size: " + record["path"])
            digest.update(chunk)
            output.write(chunk)
    if size != record["bytes"] or digest.hexdigest() != record["sha256"]:
        raise RestoreError("Restored file SHA-256/size mismatch: " + record["path"])
    os.chmod(path, mode_value(record["mode"]))
    return path


def restore_archive(path, metadata, selected, destination):
    remaining = set(selected)
    seen = set()

    def consume(name, stream, size):
        if name in seen:
            raise RestoreError("Duplicate selected archive member: " + name)
        seen.add(name)
        records = selected[name]
        if any(record["bytes"] != size for record in records):
            raise RestoreError("Wrong archive member size: " + name)
        first = write_checked(stream, destination, records[0])
        for record in records[1:]:
            with first.open("rb") as source:
                write_checked(source, destination, record)
        remaining.remove(name)

    if metadata["format"] == "tar":
        with tarfile.open(path, "r|*") as archive:
            for member in archive:
                archive_member_path(member.name)
                if member.name not in selected:
                    continue
                # Never restore archive links, devices, FIFOs or special files.
                if not member.isfile():
                    raise RestoreError("Selected TAR member is not regular: " + member.name)
                with archive.extractfile(member) as stream:
                    consume(member.name, stream, member.size)
    else:
        with zipfile.ZipFile(path) as archive:
            for member in archive.infolist():
                archive_member_path(member.filename)
                if member.filename not in selected:
                    continue
                stored_mode = member.external_attr >> 16
                kind = stat.S_IFMT(stored_mode)
                if member.is_dir() or kind not in (0, stat.S_IFREG):
                    raise RestoreError("Selected ZIP member is not regular: " + member.filename)
                with archive.open(member, "r") as stream:
                    consume(member.filename, stream, member.file_size)
    if remaining:
        raise RestoreError("Archive lacks recorded members: " + repr(sorted(remaining)[:5]))


def check_mode(path, expected):
    # Windows does not expose POSIX executable permission bits through chmod.
    if os.name == "posix" and stat.S_IMODE(path.stat().st_mode) != mode_value(expected):
        raise RestoreError("Permission mode mismatch: " + str(path))


def verify_tree(destination, data, directories, files):
    if destination.is_symlink() or not destination.is_dir():
        raise RestoreError("Vendor destination is not a real directory: " + str(destination))
    actual_files = set()
    actual_directories = set()
    for parent, names, filenames in os.walk(destination, followlinks=False):
        parent = Path(parent)
        for name in names + filenames:
            path = parent / name
            if path.is_symlink():
                raise RestoreError("Unexpected symlink: " + str(path))
        for name in names:
            actual_directories.add((parent / name).relative_to(destination).as_posix())
        for name in filenames:
            path = parent / name
            if not stat.S_ISREG(path.stat().st_mode):
                raise RestoreError("Unexpected special file: " + str(path))
            actual_files.add(path.relative_to(destination).as_posix())
    for label, actual, expected in (("files", actual_files, set(files)), ("directories", actual_directories, set(directories))):
        if actual != expected:
            raise RestoreError("Vendor {} differ: missing={}, extra={}".format(label, sorted(expected - actual)[:10], sorted(actual - expected)[:10]))
    for record in files.values():
        path = destination.joinpath(*relative_path(record["path"]).parts)
        verify_content(path, record)
        check_mode(path, record["mode"])
    for record in directories.values():
        check_mode(destination.joinpath(*relative_path(record["path"]).parts), record["mode"])
    check_mode(destination, data["vendor_root_mode"])


def restore(root, destination, data, archives, directories, files):
    if os.path.lexists(str(destination)):
        raise RestoreError("Destination already exists; refusing to overwrite: " + str(destination))
    input_count = verify_inputs(root, archives, files)
    destination.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive mkdir prevents accidentally operating on an existing tree.
    destination.mkdir(mode=0o700, exist_ok=False)
    try:
        for name in sorted(directories, key=lambda value: (value.count("/"), value)):
            destination.joinpath(*relative_path(name).parts).mkdir(mode=0o700)
        grouped = collections.defaultdict(lambda: collections.defaultdict(list))
        for record in files.values():
            source = record["source"]
            if source["kind"] == "archive":
                grouped[source["archive"]][source["member"]].append(record)
            else:
                with input_path(root, source["path"]).open("rb") as stream:
                    write_checked(stream, destination, record)
        for archive_id, selected in grouped.items():
            metadata = archives[archive_id]
            restore_archive(input_path(root, metadata["path"]), metadata, selected, destination)
        # Apply directory modes last, after all descendants have been written.
        for name in sorted(directories, key=lambda value: value.count("/"), reverse=True):
            os.chmod(destination.joinpath(*relative_path(name).parts), mode_value(directories[name]["mode"]))
        os.chmod(destination, mode_value(data["vendor_root_mode"]))
        verify_tree(destination, data, directories, files)
    except Exception:
        # Remove only the new tree this invocation created, never an old vendor.
        shutil.rmtree(destination)
        raise
    return input_count


def main():
    bundle = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=bundle / "provenance/source_restore.json")
    parser.add_argument("--inputs-root", type=Path, default=bundle)
    parser.add_argument("--destination", type=Path, default=bundle / "vendor", help="New vendor directory; existing paths are refused")
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--verify", action="store_true", help="Read-only verification of an existing vendor tree")
    action.add_argument("--verify-inputs", action="store_true", help="Read-only SHA-256 verification of all original archives and loose inputs")
    args = parser.parse_args()
    try:
        data, archives, directories, files = read_manifest(args.manifest)
        inputs_root = args.inputs_root.resolve(strict=True)
        # Do not resolve the last component: a symlink must remain detectable.
        destination = Path(os.path.abspath(str(args.destination)))
        if args.verify:
            verify_tree(destination, data, directories, files)
            print("Verified {} files and {} directories: {}".format(len(files), len(directories), destination))
        elif args.verify_inputs:
            count = verify_inputs(inputs_root, archives, files)
            print("Verified {} unchanged source inputs ({} archives).".format(count, len(archives)))
        else:
            count = restore(inputs_root, destination, data, archives, directories, files)
            print("Restored and verified {} files and {} directories from {} inputs: {}".format(len(files), len(directories), count, destination))
        if os.name != "posix":
            print("Note: this platform does not preserve/check POSIX executable permission bits.")
    except (RestoreError, OSError, ValueError, KeyError, TypeError, EOFError, tarfile.TarError, zipfile.BadZipFile) as error:
        print("restore_vendor: {}".format(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
