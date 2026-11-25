#!/usr/bin/env python3
"""Check mirrors, then compile/run with GHC when available; never invent a run."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile

GROUP = Path(__file__).resolve().parents[1]
EXAMPLES = GROUP.parent


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def main():
    index = json.loads((GROUP / "comparison_index.json").read_text())
    fixtures = json.loads((GROUP / "validation/fixtures.json").read_text())
    errors = []
    cases = index["entries"]
    ids = [entry["id"] for entry in cases]
    if len(ids) != 24 or len(set(ids)) != 24:
        errors.append("Expected 24 distinct comparison IDs")
    if set(ids) != {case["id"] for case in fixtures["cases"]}:
        errors.append("Fixture IDs differ from comparison IDs")
    harness = (GROUP / "validation/Main.hs").read_text()
    checked_sources = set()
    for entry in cases:
        identifier = entry["id"]
        source = EXAMPLES / entry["foreign_source"]
        code = source.read_text()
        page = (EXAMPLES / entry["lmx_style_comparison"]).read_text()
        if code != entry["foreign_code"]:
            errors.append(identifier + ": JSON/Haskell differ")
        if sha(code) != entry["foreign_listing_sha256"]:
            errors.append(identifier + ": Haskell hash differs")
        blocks = re.findall(r"```haskell\n(.*?)\n```", page, re.S)
        if len(blocks) != 1 or blocks[0].strip() != code.strip():
            errors.append(identifier + ": Markdown/Haskell differ")
        if not code.startswith("module " + identifier + " where\n"):
            errors.append(identifier + ": unexpected module name")
        if "import qualified " + identifier + "\n" not in harness:
            errors.append(identifier + ": missing harness import")
        if entry["status"] not in ("complete_pair", "related_analogy"):
            errors.append(identifier + ": incomplete foreign coverage")
        measured = sum(not char.isspace() for char in code)
        if entry["foreign_listing_metrics"]["non_whitespace_characters"] != measured:
            errors.append(identifier + ": current foreign metrics differ")
        lmx_blocks = re.findall(r"```lmx\n(.*?)\n```", page, re.S)
        shared = entry['style_relation'] == 'same_minimal_form'
        if len(lmx_blocks) != (1 if shared else 2):
            errors.append(identifier + ": expected each distinct LMX body exactly once")
        for position, style in enumerate(("procedural", "functional")):
            variant = entry["lmx_variants"][style]
            lmx = (EXAMPLES / variant["source_file"]).read_text()
            checked_sources.add(variant["source_file"])
            if lmx != variant["code"] or sha(lmx) != variant["source_sha256"]:
                errors.append(identifier + ": " + style + " source/JSON/hash differ")
            block_position = 0 if shared else position
            if block_position < len(lmx_blocks) and lmx_blocks[block_position].strip() != lmx.strip():
                errors.append(identifier + ": " + style + " Markdown differs")
        for dependency in entry["custom_dependencies"]:
            if not (EXAMPLES / dependency).is_file():
                errors.append(identifier + ": missing custom dependency")
    receipt = {
        "kind": "haskell-comparision-check-v1",
        "static_status": "FAIL" if errors else "PASS",
        "static_errors": errors,
        "haskell_modules_checked": len(cases),
        "lmx_source_files_checked": len(checked_sources),
        "measurement_status": "CURRENT_FULL_SOURCE",
        "haskell_compilation": "NOT_RUN",
        "haskell_execution": "NOT_RUN",
        "lmx_execution": "NOT_RUN",
        "compiler": shutil.which("ghc"),
    }
    success = not errors
    if success and receipt["compiler"]:
        with tempfile.TemporaryDirectory(prefix="haskell-comparision-") as directory:
            executable = str(Path(directory) / "comparison-tests")
            command = [receipt["compiler"], "-Wall", "-isource/haskell",
                       "-odir", directory, "-hidir", directory, "-package", "containers",
                       "validation/Main.hs", "-o", executable]
            try:
                compiled = subprocess.run(command, cwd=GROUP, text=True,
                                          capture_output=True, timeout=60)
                receipt["compile_command"] = command
                receipt["compile_log"] = compiled.stdout + compiled.stderr
                receipt["haskell_compilation"] = "PASS" if compiled.returncode == 0 else "FAIL"
                success = compiled.returncode == 0
                if success:
                    executed = subprocess.run([executable], cwd=GROUP, text=True,
                                              capture_output=True, timeout=30)
                    receipt["run_log"] = executed.stdout + executed.stderr
                    receipt["haskell_execution"] = "PASS" if executed.returncode == 0 else "FAIL"
                    success = executed.returncode == 0
            except subprocess.TimeoutExpired as error:
                receipt["timeout"] = str(error)
                receipt["haskell_execution" if receipt["haskell_compilation"] == "PASS"
                        else "haskell_compilation"] = "TIMEOUT"
                success = False
    elif success:
        receipt["not_run_reason"] = "ghc is not installed; no compilation or execution claimed"
    target = GROUP / "validation/check_receipt.json"
    target.write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({key: value for key, value in receipt.items()
                      if key not in ("compile_log", "run_log")}, ensure_ascii=False, indent=2))
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
