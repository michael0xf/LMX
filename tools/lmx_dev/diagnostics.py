"""Adapters for exact emitted formats, without guessing absent diagnostic fields."""
import os
import re
from pathlib import Path

PARSER = re.compile(r"^(?:P0|l2trans) parse error (\d+) at (\d+):(\d+): (.*)$")
FRONTEND = re.compile(r"^l2trans error: (.+):(\d+):(\d+): (.*)$")
HOST_DONE = re.compile(r"^l2_eternal_driver: (\d+) checks, (\d+) roots$")
# A located line of the hosted frontend that is a failure of the producer, not a verdict on the source: an invariant of
# the translator, its memory, a size it cannot hold, or a source it could not read.
PRODUCER_FAILURE = re.compile(r"internal:|out of memory|size overflow|cannot read the source|expected a \.lm2 source$", re.I)
HOST_EXIT = re.compile(r"^l2_eternal_driver: exit (-?\d+), expected (-?\d+)$")
HOST_SUMMARY = re.compile(r"^l2_eternal_driver: (\d+) failed of (\d+)$")
EXPECTED_EXIT_FAILURE = "FAIL [exit] the launch's exit code is the expected one: R0's exit letter, or its success"


def same_file(spelled: str, source: str | None) -> bool:
    """One file by two spellings; with no source to compare against every located line is taken as outside."""
    if not source:
        return False
    return os.path.normcase(os.path.abspath(spelled)) == os.path.normcase(os.path.abspath(source))


def collect(log: Path, source: str | None, limit: int = 6, phase: str = "translate") -> dict:
    count, unparsed, selected = 0, 0, []
    exits, summaries, failures, dones = [], [], [], []
    outside, producer = 0, 0
    with log.open(encoding="utf-8", errors="replace") as stream:
        for log_line, line in enumerate(stream, 1):
            line = line.rstrip("\r\n")
            host_exit, host_summary = HOST_EXIT.match(line), HOST_SUMMARY.match(line)
            if host_exit:
                exits.append((int(host_exit[1]), int(host_exit[2])))
            if host_summary:
                summaries.append((int(host_summary[1]), int(host_summary[2])))
            done = HOST_DONE.match(line)
            if done:
                dones.append((int(done[1]), int(done[2])))
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
                            "column": int(match[3]), "message": match[4], "phase": phase}
                    if not same_file(match[1], source):
                        outside += 1
                    if PRODUCER_FAILURE.search(match[4]):
                        producer += 1
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
    if source is not None:
        result.update(driverDone={"checks": dones[0][0], "roots": dones[0][1]} if len(dones) == 1 else None,
                      failedCheckLines=len(failures), diagnosticsOutsideSource=outside, producerFailures=producer)
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


def check_evidence(result: dict, passed: bool) -> list[str]:
    """What the log of a completed hosted check lacks to be a verdict (hosted-check-v1); empty when it is one.

    A pass: the driver's single done line, no failed check, no diagnostic, no unparsed line. A rejection: the hosted
    frontend's own exit is its refusal code 1, the expected-exit check is the one failed check of one driver summary,
    at least one diagnostic -- each located on the checked source, or a P0 parse refusal --, none an internal, memory
    or read failure of the producer, no unparsed line.
    """
    driver = result.get("hostedDriver", {})
    gaps = []
    if passed:
        if result.get("driverDone") is None:
            gaps.append("no single driver done line")
        if result.get("logicalExitCode") is not None or result.get("failedCheckLines", 0):
            gaps.append("a failed check")
        if result.get("diagnosticCount", 0):
            gaps.append("diagnostic lines were said")
    else:
        if driver.get("expectedExitCode") != 0:
            gaps.append("no single driver summary that expected exit 0")
        if not driver.get("onlyExpectedExitFailure"):
            gaps.append("the failed checks are not exactly the expected-exit check")
        if result.get("logicalExitCode") != 1:
            gaps.append("the hosted frontend's own exit is %s, not its refusal code 1" % result.get("logicalExitCode"))
        if result.get("diagnosticCount", 0) < 1:
            gaps.append("no diagnostic line")
        if result.get("diagnosticsOutsideSource", 0):
            gaps.append("%d diagnostic line(s) name another file than the checked source "
                        "(a frontend without --check-only names the word as its source)" % result["diagnosticsOutsideSource"])
        if result.get("producerFailures", 0):
            gaps.append("an internal, memory or read failure of the producer")
    if result.get("unparsedDiagnosticLines", 0):
        gaps.append("unparsed error lines")
    return gaps
