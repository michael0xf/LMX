"""Adapters for exact emitted formats, without guessing absent diagnostic fields."""
import re
from pathlib import Path

PARSER = re.compile(r"^(?:P0|l2trans) parse error (\d+) at (\d+):(\d+): (.*)$")
FRONTEND = re.compile(r"^l2trans error: (.+):(\d+):(\d+): (.*)$")
HOST_EXIT = re.compile(r"^l2_eternal_driver: exit (-?\d+), expected (-?\d+)$")
HOST_SUMMARY = re.compile(r"^l2_eternal_driver: (\d+) failed of (\d+)$")
EXPECTED_EXIT_FAILURE = "FAIL [exit] the launch's exit code is the expected one: R0's exit letter, or its success"


def collect(log: Path, source: str | None, limit: int = 6) -> dict:
    count, unparsed, selected = 0, 0, []
    exits, summaries, failures = [], [], []
    with log.open(encoding="utf-8", errors="replace") as stream:
        for log_line, line in enumerate(stream, 1):
            line = line.rstrip("\r\n")
            host_exit, host_summary = HOST_EXIT.match(line), HOST_SUMMARY.match(line)
            if host_exit:
                exits.append((int(host_exit[1]), int(host_exit[2])))
            if host_summary:
                summaries.append((int(host_summary[1]), int(host_summary[2])))
            if line.startswith("FAIL ["):
                failures.append(line)
            match = PARSER.match(line)
            item = None
            if match:
                item = {"code": int(match[1]), "file": None, "line": int(match[2]),
                        "column": int(match[3]), "message": match[4], "phase": "syntax"}
                # P0 does not print the filename; do not invent one for included sources.
            else:
                match = FRONTEND.match(line)
                if match:
                    item = {"code": None, "file": match[1], "line": int(match[2]),
                            "column": int(match[3]), "message": match[4], "phase": "translate"}
            if item:
                count += 1
                if len(selected) < limit:
                    selected.append(dict(item, severity="error", expectedTokens=None, related=[],
                                         coordinateUnit="producer-defined (not converted)", logLine=log_line))
            elif not host_summary and re.search(r"error|fatal|failed|failure", line, re.I):
                unparsed += 1
    result = {"diagnostics": selected, "diagnosticCount": count,
            "unparsedDiagnosticLines": unparsed, "diagnosticsOmitted": max(0, count - limit),
            "inputFile": source, "order": "combined log order"}
    if len(exits) == 1:
        result["logicalExitCode"] = exits[0][0]
        result["hostedDriver"] = {
            "expectedExitCode": exits[0][1],
            "failedChecks": summaries[0][0] if len(summaries) == 1 else None,
            "totalChecks": summaries[0][1] if len(summaries) == 1 else None,
            "onlyExpectedExitFailure": failures == [EXPECTED_EXIT_FAILURE] and len(summaries) == 1
                and summaries[0][0] == 1 and summaries[0][1] >= 1 and unparsed == 0}
    return result


def is_hosted_p0_rejection(result: dict) -> bool:
    """Observed host exit 1 is a source refusal ONLY with all producer evidence."""
    driver = result.get("hostedDriver", {})
    return (result.get("exitCode") == 1 and result.get("logicalExitCode") == 2
            and driver.get("expectedExitCode") == 0 and driver.get("onlyExpectedExitFailure") is True
            and any(d["phase"] == "syntax" for d in result.get("diagnostics", [])))
