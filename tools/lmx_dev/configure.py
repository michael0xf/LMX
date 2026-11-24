"""Pin the accepted W3 producers. Creating configuration does not open the pipeline."""
from pathlib import Path

from .runner import sha, write_json


def accepted_w3(root: Path, output: Path) -> dict:
    chain = root / "build2/codex_fix250generationchain01"
    stage = chain / "sol-m14-field-values-01"
    t = chain / "runs/fable-m10-call-forms-20261116-01/fable/tz-20261121"
    baseline = t / "w4-accept-20261124/root01/baseline-w3-immutable-stage"
    values = {
        "tool": stage / "codex-w3-s2126i-g2-tool/lmxtool-tool.exe",
        "fe": stage / "codex-w3-s2126i-g2-frontend/l2trans.exe",
        "graph": stage / "codex-w3-s2126i-g2-graph/graph_trans-prod.exe",
        "runtime": stage / "codex-w3-s2126i-g2-runtime/driver.o",
        "observed": stage / "codex-w3-s2126i-g2-runtime/driver-observe.o",
        "base": chain / "cold-candidate48/full48/g2/frontend"
    }
    smoke = stage / "tests/codex-w3-generation-smoke10.tsv"
    required = [*values.values(), baseline / "src", baseline / "tests/full-suite.tsv", smoke]
    absent = [str(p) for p in required if not p.exists()]
    if absent:
        raise ValueError("Accepted closure is incomplete: " + ", ".join(absent))
    data = {
        "version": 1,
        "acceptedRevision": "cb7a8798a1c9a271ec7cb544db335f1f908563e9",
        "description": "W3 accepted producers. Bootstrap uses a private copy of the accepted W3 stage, not mutable W4 S.",
        "runs": str(root / "build2/lmx_dev/runs"),
        "permit": str(root / "build2/lmx_dev/compiler-permit.json"),
        "lock": str(t / "machine.lock.d"),
        "busy_markers": [str(t / "docs-check.running"), str(t / "quiet.running")],
        "stage": str(baseline),
        "stage_files": {str(smoke): "tests/service-smoke.tsv"},
        "variables": {k: str(v) for k, v in values.items()},
        "pins": {str(p): sha(p) for p in [*list(values.values())[:5], smoke]},
        "watch": [str(baseline), str(root / "selfbuild"), str(values["base"])],
        "environment": {"L2_RUNTIME_ROOT": "l2src/"},
        "memory_start_mb": 900, "memory_floor_mb": 600,
        "operations": {
            "check:syntax": {
                "hosted_exit_adapter": "p0-v1",
                "description": "Accepted Graph P0 parser only. No initializer/test/body execution; no sys-check claim.",
                "argv": ["{graph}", "0", "entry", "0", "--", "p0", "{source}"],
                "cwd": "{stage}/src", "timeout": 30, "rejected_codes": [2],
                "achieved_phase": "P0 syntax"
            },
            "check:static": {
                "unavailable": "The accepted frontend has no standalone normative sys-check/static CLI. Graph check is build/preflight only; translate is a different phase."
            },
            "check:translate": {
                "description": "Accepted frontend translates L2 to L1 (includes its CHECK), without executing the target program. Not sys\\translate.",
                "argv": ["{fe}", "0", "entry", "0", "--", "{source}", "{run}/output.lm1"],
                "cwd": "{stage}/src", "timeout": 300, "suffixes": [".lm2"], "rejected_codes": [1, 2],
                "artifacts": ["{run}/output.lm1"], "achieved_phase": "L1 translation"
            },
            "bootstrap:smoke": {
                "memory_start_mb": 3500,
                "description": "Component suite10 using accepted W3 producers; executes target programs. Does not rebuild generations.",
                "copy_stage": True,
                "argv": ["{tool}", "0", "entry", "0", "--", "suite", "{stage}/tests/service-smoke.tsv",
                         "{repo}", "{stage}", "{base}", "{fe}", "{runtime}", "{run}/suite", "{observed}"],
                "cwd": "{repo}", "timeout": 7200, "rejected_codes": [1],
                "success_pattern": "^SUITE 10 rows, 0 failures$", "achieved_phase": "W3 component smoke10"
            },
            "bootstrap:selfHost": {
                "memory_start_mb": 3500,
                "description": "Explicit full G1/G2 bootstrap, full suite and artifact equality checks, on the copied accepted W3 source stage. Potentially hours.",
                "copy_stage": True,
                "argv": ["{tool}", "0", "entry", "0", "--", "bootstrap", "full", "{repo}", "{stage}",
                         "{base}", "{fe}", "selfhost", "{stage}/tests/service-smoke.tsv", "{stage}/tests/full-suite.tsv"],
                "cwd": "{repo}", "timeout": 86400, "rejected_codes": [1],
                "success_pattern": "^BOOTSTRAP full 0 failures$", "achieved_phase": "W3 G1/G2 full bootstrap",
                "artifacts": ["{stage}/selfhost/g1/bundle.sha256", "{stage}/selfhost/g2/bundle.sha256"]
            }
        }
    }
    write_json(output, data)
    return {"config": str(output), "compilerWindow": "closed", "producerPins": len(data["pins"])}
