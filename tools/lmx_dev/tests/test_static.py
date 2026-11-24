"""check:static: the hosted L2 CHECK of a source through the frontend's --check-only (hosted-check-v1).

Controlled Python fixtures stand for the hosted frontend and its driver; no LMX compiler, stage or permit of the
project is used. The fixture prints the lines the driver and the frontend print and answers their exit codes: the
process exit is the driver's, the logical one the frontend's own.
"""
import asyncio
import copy
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.lmx_dev.__main__ import grant
from tools.lmx_dev.closures import CHECK_PREFIX, DEFAULT_CLOSURE, HASHED, select
from tools.lmx_dev.diagnostics import check_evidence, collect
from tools.lmx_dev.runner import OWN_RUN_FILES, Runner, machine_lock, public_result, sha, tree_state, write_json

ROOT = Path(__file__).resolve().parents[3]
CATALOGUE = Path(__file__).resolve().parents[1] / "catalogue.json"
FIXTURE = Path(__file__).with_name("fixture_process.py")
NEW, OLD = "feh-with-check-only", "feh-before-the-word"
OWN = set(OWN_RUN_FILES)
REJECTED = ("FAIL [exit] the launch's exit code is the expected one: R0's exit letter, or its success\n"
            "l2_eternal_driver: exit 1, expected 0\nl2_eternal_driver: 1 failed of 42\n"
            "l2trans error: {source}:3:5: a reference where a number is asked\n")
CLEAN = "l2_eternal_driver: 42 checks, 0 roots\n"


def former_digest(effective: dict) -> str:
    """closures.digest before the static phase existed (commit 9ac4ae598), as a function: no `static` in the material."""
    material = {}
    for name in [key for key in HASHED if key != "static"]:
        value = effective.get(name)
        if name == "operations":
            value = {op: spec for op, spec in (value or {}).items() if op.startswith(CHECK_PREFIX)}
        if isinstance(value, dict):
            value = {str(k): value[k] for k in sorted(value)}
        material[name] = value
    return hashlib.sha256(json.dumps(material, sort_keys=True, separators=(",", ":")).encode("utf-8")).hexdigest()


class StaticCase(unittest.TestCase):
    """The flat accepted bundle and two registered frontends share the templates; the declaration is each one's own."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "probes" / "source file.lm2"
        self.source.parent.mkdir()
        self.source.write_text("int: service_value 1\n", encoding="utf-8")
        self.accepted_stage = self.root / "accepted-stage"
        (self.accepted_stage / "src" / "l2src").mkdir(parents=True)
        (self.accepted_stage / "src" / "l2src" / "a.h.lm1").write_text("accepted\n", encoding="utf-8")
        self.new_fe, self.old_fe = (self.root / "producers" / name / "frontend.py" for name in ("new", "old"))
        for path in (self.new_fe, self.old_fe):
            path.parent.mkdir(parents=True)
            path.write_bytes(FIXTURE.read_bytes())
        self.stage = self.root / "candidate-stage"
        (self.stage / "src" / "l2src").mkdir(parents=True)
        (self.stage / "src" / "l2src" / "a.h.lm1").write_text("candidate\n", encoding="utf-8")
        self.manifest = self.root / "candidate.stage.sha256"
        self.artifacts = self.root / "candidate.artifacts.sha256"
        self.config = self.root / "config.json"
        self.runner = Runner(self.root, self.config)
        check = {"description": "Hosted L2 CHECK of a source (the frontend's --check-only).",
                 "argv": ["{fe}", "{script}", "check_ok", "{run}/result.txt", "{source}"],
                 "cwd": "{stage}/src", "timeout": 10, "suffixes": [".lm2"],
                 "achieved_phase": "hosted L2 CHECK", "hosted_exit_adapter": "hosted-check-v1"}
        translate = {"argv": ["{fe}", "{script}", "ok", "{run}/result.txt", "{source}"], "cwd": "{stage}/src",
                     "timeout": 10, "rejected_codes": [1], "artifacts": ["{run}/result.txt"],
                     "achieved_phase": "L1 translation"}
        self.data = {
            "version": 1, "acceptedRevision": "a" * 40, "runs": str(self.root / "runs"),
            "lock": str(self.root / "lock"), "permit": str(self.root / "permit.json"),
            "busy_markers": [str(self.root / "busy")], "watch": [str(self.source)],
            "stage": str(self.accepted_stage), "static": True,
            "variables": {"graph": sys.executable, "fe": sys.executable, "script": str(FIXTURE)},
            "operations": {"check:static": check, "check:translate": translate}}
        registered = {"stage": str(self.stage), "stageManifest": str(self.manifest), "pinsManifest": str(self.artifacts)}
        self.data["closures"] = {
            NEW: dict(registered, role="candidate", description="A frontend that has --check-only.",
                      acceptedRevision="b" * 40, static=True,
                      variables={"graph": sys.executable, "fe": sys.executable, "script": str(self.new_fe)}),
            OLD: dict(registered, description="A frontend from before the word.", acceptedRevision="c" * 40,
                      variables={"graph": sys.executable, "fe": sys.executable, "script": str(self.old_fe)})}
        self.write()

    def tearDown(self):
        self.temp.cleanup()

    def write(self, keep_window=False):
        """Both bundles byte for byte and the configuration; the window closes unless it is kept open on purpose."""
        self.manifest.write_text("".join(f"{sha(p)}  {p.relative_to(self.stage).as_posix()}\n"
                                         for p in sorted((self.stage / "src").rglob("*")) if p.is_file()), encoding="utf-8")
        self.artifacts.write_text("".join(f"{sha(Path(p))}  {p}\n" for p in (sys.executable, self.new_fe, self.old_fe)),
                                  encoding="utf-8")
        data = copy.deepcopy(self.data)
        for closure in (data["closures"] or {}).values():
            closure["pins"] = {str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts)}
        write_json(self.config, data)
        if not keep_window:
            Path(self.data["permit"]).unlink(missing_ok=True)
        shutil.rmtree(self.root / "runs", ignore_errors=True)

    def configure(self, mode="check_ok"):
        """The accepted template with another answer of the fixture; the window is granted again for the changed file."""
        self.data["operations"]["check:static"]["argv"][2] = mode
        self.write()
        self.window()

    def window(self, *closures):
        return grant(self.runner, 60, "fixture", list(closures or (DEFAULT_CLOSURE, NEW, OLD)))

    def run_static(self, closure=""):
        return self.runner.run("check:static", str(self.source), closure=closure)

    def runs(self):
        folder = self.root / "runs"
        return sorted(folder.iterdir()) if folder.exists() else []

    def assertNothingStarted(self, answer, *words):
        self.assertEqual((answer["execution"], answer["result"]), ("unavailable", "notRun"), answer)
        for word in words:
            self.assertIn(word, answer["message"])
        self.assertEqual(self.runs(), [], "a run folder was made for a refused request")

    def assertNoVerdict(self, answer, execution, word):
        self.assertEqual((answer["execution"], answer["result"]), (execution, "indeterminate"), answer)
        self.assertIn(word, answer["message"])
        self.assertIsNone(answer["achievedPhase"])

    # -- the phase runs only where a bundle declares it for its own frontend ---------------------------------

    def test_configuration_without_the_phase_stays_unavailable(self):
        self.data["operations"]["check:static"] = {"unavailable": "No standalone static CLI."}
        del self.data["static"]
        self.write()
        self.window()
        self.assertNothingStarted(self.run_static(), "No standalone static CLI")
        self.assertFalse(self.runner.status()["operations"]["check:static"]["configured"])

    def test_undeclared_bundle_is_refused_before_any_process(self):
        self.window()
        self.assertNothingStarted(self.run_static(OLD), "not declared for closure '" + OLD + "'")
        self.data["closures"] = None
        del self.data["static"]
        self.write()
        self.window(DEFAULT_CLOSURE)
        # The operation exists and the window is open: the accepted bundle never said its frontend has the word.
        self.assertNothingStarted(self.run_static(), "not declared for closure 'accepted'")

    def test_the_accepted_template_serves_a_declared_frontend_only(self):
        self.window()
        self.assertNothingStarted(self.run_static(OLD), "not declared for closure")
        self.assertEqual(self.run_static()["result"], "passed")
        self.assertEqual(self.run_static(NEW)["result"], "passed")

    def test_declaration_is_boolean_and_part_of_the_admitted_content(self):
        self.data["closures"][NEW]["static"] = "yes"
        self.write()
        with self.assertRaisesRegex(ValueError, "static must be true or false"):
            self.runner.load()
        self.data["closures"][NEW]["static"] = True
        self.data["static"] = "true"
        self.write()
        with self.assertRaisesRegex(ValueError, "static must be true or false"):
            self.runner.load()
        self.data["static"] = True
        self.write()
        declared, undeclared = select(self.runner.load(), NEW), select(self.runner.load(), OLD)
        self.assertNotEqual(declared["effectiveHash"], undeclared["effectiveHash"])
        # A bundle that declares nothing keeps the hash it had before the phase existed.
        self.assertEqual(undeclared["effectiveHash"], former_digest(undeclared))
        del self.data["static"]
        self.write()
        accepted = select(self.runner.load())
        self.assertEqual(accepted["effectiveHash"], former_digest(accepted))
        self.data["static"] = True
        self.write()
        self.assertNotEqual(select(self.runner.load())["effectiveHash"], accepted["effectiveHash"])
        # A declaration added while a window is open admits nothing by that permit: it was granted for another content.
        self.window()
        self.data["closures"][OLD]["static"] = True
        self.write(keep_window=True)
        self.assertNothingStarted(self.run_static(OLD), "different producer configuration")
        self.window()
        self.assertEqual(self.run_static(OLD)["result"], "passed")

    def test_status_lists_the_declaration(self):
        self.window()
        closures = self.runner.status()["closures"]
        self.assertEqual([closures[name]["static"] for name in (DEFAULT_CLOSURE, NEW, OLD)], [True, True, False])
        self.assertIn("check:static", closures[OLD]["operations"], "the template is common; the declaration is not")

    # -- a verdict only from complete evidence ----------------------------------------------------------------

    def test_pass_is_the_frontend_s_check_command_and_writes_nothing(self):
        self.window()
        before = tree_state(self.stage / "src"), tree_state(self.source.parent)
        answer = self.run_static(NEW)
        self.assertEqual((answer["execution"], answer["result"], answer["achievedPhase"]),
                         ("completed", "passed", "hosted L2 CHECK"), answer)
        self.assertEqual(answer["argv"], [sys.executable, str(self.new_fe), "check_ok",
                                          answer["runDirectory"] + "/result.txt", str(self.source)])
        self.assertEqual(Path(answer["cwd"]), self.stage / "src")
        self.assertEqual(answer["closure"]["producers"]["operation"], "fe")
        self.assertIn("before the backend's COUNT and emission", answer["coverage"])
        self.assertIn("COUNT and emission do not run", answer["coverage"])
        self.assertIn("not the normative language", answer["coverage"])
        self.assertIn("takes no library, machine or construct context", answer["coverage"])
        self.assertNotIn("writtenFiles", answer)
        self.assertEqual((answer["exitCode"], answer.get("logicalExitCode")), (0, None))
        self.assertEqual({p.name for p in Path(answer["runDirectory"]).iterdir()}, OWN)
        self.assertEqual((tree_state(self.stage / "src"), tree_state(self.source.parent)), before)
        self.assertEqual(json.loads(Path(answer["receipt"]).read_text(encoding="utf-8")), answer)
        self.assertEqual(public_result(answer)["coverage"], answer["coverage"])

    def test_rejection_needs_the_complete_evidence(self):
        self.window()
        for mode, phase, message in (("check_reject", "static", "a reference where a number is asked"),
                                     ("check_parse", "syntax", "unescaped newline in string literal")):
            self.configure(mode)
            answer = self.run_static(NEW)
            self.assertEqual((answer["execution"], answer["result"]), ("completed", "rejected"), (mode, answer))
            self.assertEqual((answer["exitCode"], answer["logicalExitCode"]), (1, 1), mode)
            self.assertIsNone(answer["achievedPhase"], "a rejection reaches no phase")
            self.assertEqual((answer["diagnostics"][0]["message"], answer["diagnostics"][0]["phase"]), (message, phase))
            if phase == "static":
                self.assertEqual(Path(answer["diagnostics"][0]["file"]), self.source)
            else:
                self.assertIsNone(answer["diagnostics"][0]["file"], "P0 names no file; none is invented")
            self.assertIn("hosted L2 CHECK rejection", answer["message"])
            self.assertEqual({p.name for p in Path(answer["runDirectory"]).iterdir()}, OWN)

    def test_exit_one_without_evidence_is_no_verdict(self):
        expected = {"check_old": "name another file than the checked source",
                    "check_internal": "internal, memory or read failure",
                    "check_memory": "internal, memory or read failure",
                    "check_invariant": "not its refusal code 1",
                    "check_two": "not exactly the expected-exit check",
                    "check_silent": "no diagnostic line",
                    "check_unparsed": "unparsed error lines",
                    "check_read": "unparsed error lines"}
        self.window()
        for mode, word in expected.items():
            self.configure(mode)
            self.assertNoVerdict(self.run_static(NEW), "protocolError", word)

    def test_the_log_alone_decides(self):
        source, log = str(self.source), self.root / "log"
        text = REJECTED.format(source=source)
        for code, lines, passed in ((1, text, False), (0, CLEAN, True)):
            log.write_text(lines, encoding="utf-8")
            self.assertEqual(check_evidence(dict(collect(log, source), exitCode=code), passed), [], lines)
        for changed in [text.replace("exit 1,", "exit 3,"), text.replace("1 failed", "2 failed"),
                        text.replace(source, "--check-only:1:1"), text.split("l2trans error")[0],
                        text.replace("a reference where a number is asked", "out of memory"),
                        text.replace("a reference where a number is asked", "internal: missing unit"),
                        text.replace(source, source + ".h.lm1"), text + "fatal: unrelated host failure\n"]:
            log.write_text(changed, encoding="utf-8")
            self.assertTrue(check_evidence(dict(collect(log, source), exitCode=1), False), changed[:70])
        for changed in [CLEAN.replace("0 roots", "1 roots") + CLEAN, "", CLEAN + text.splitlines(keepends=True)[-1],
                        CLEAN + "l2trans error: cannot open out\n", text]:
            log.write_text(changed, encoding="utf-8")
            self.assertTrue(check_evidence(dict(collect(log, source), exitCode=0), True), changed[:70])

    def test_a_file_left_behind_is_no_pass(self):
        self.window()
        for mode, where in (("check_write_l1", "run: result.lm1"), ("check_write_stage", "candidate-stage"),
                            ("check_write_source", "probes")):
            self.configure(mode)
            answer = self.run_static(NEW)
            self.assertNoVerdict(answer, "protocolError", "left a file behind")
            self.assertTrue(any(where in name for name in answer["writtenFiles"]), (mode, answer["writtenFiles"]))
        (self.source.parent / "lmx_dev_static_left_behind.txt").unlink()
        (self.stage / "src" / "lmx_dev_static_left_behind.lm1").unlink()
        self.configure()
        self.assertEqual(self.run_static(NEW)["result"], "passed")

    def test_the_output_guard_reads_the_stage_deep_when_the_source_stands_in_it(self):
        # The same path by two spellings is one tree: a source checked right inside the stage source tree must not
        # replace the deep listing of that tree by the shallow listing of its folder.
        inside = self.stage / "src" / "inside.lm2"
        inside.write_text("int: inside_value 1\n", encoding="utf-8")
        self.window()
        self.configure("check_write_stage_deep")
        answer = self.runner.run("check:static", inside.as_posix(), closure=NEW)
        self.assertNoVerdict(answer, "protocolError", "left a file behind")
        self.assertTrue(any("candidate-stage" in name for name in answer["writtenFiles"]), answer["writtenFiles"])
        (self.stage / "src" / "l2src" / "lmx_dev_static_left_behind.lm1").unlink()
        inside.unlink()
        self.configure()
        self.assertEqual(self.run_static(NEW)["result"], "passed")

    def test_a_removed_file_is_left_behind_too(self):
        self.window()
        self.configure("check_remove")
        answer = self.run_static(NEW)
        self.assertEqual((answer["execution"], answer["result"]), ("protocolError", "indeterminate"), answer)
        self.assertTrue(any(name.endswith("(removed)") for name in answer["writtenFiles"]), answer["writtenFiles"])
        self.assertFalse((self.stage / "src" / "l2src" / "a.h.lm1").exists())
        self.configure()
        self.assertEqual(self.run_static(NEW)["result"], "passed")

    def test_exit_zero_without_a_clean_log_is_no_pass(self):
        self.window()
        for mode, word in (("check_talk", "diagnostic lines were said"), ("check_no_summary", "no single driver done line")):
            self.configure(mode)
            self.assertNoVerdict(self.run_static(NEW), "protocolError", word)

    def test_crash_and_other_exits_are_no_rejection(self):
        self.window()
        self.configure("check_exit")
        self.assertNoVerdict(self.run_static(NEW), "protocolError", "Process exit 17 is not a verdict")
        self.configure("crash")
        self.assertNoVerdict(self.run_static(NEW), "crash", "crashed")

    def test_only_lm2_sources_and_an_open_window(self):
        self.window()
        other = self.source.with_name("program.lm3")
        other.write_text("Main:\n    int: x 5\nend: Main\n", encoding="utf-8")
        # Not a source the hosted frontend reads: said before the bundle is selected, an honest non-verdict.
        self.assertNoVerdict(self.runner.run("check:static", str(other), closure=NEW), "protocolError",
                             "does not support that file extension")
        self.assertEqual(self.runs(), [])
        Path(self.data["permit"]).unlink()
        self.assertNothingStarted(self.run_static(NEW), "Compiler window is closed")
        self.window()
        with machine_lock(self.root / "lock", []):
            self.assertEqual(self.run_static(NEW)["execution"], "unavailable")

    def test_an_environment_asking_for_a_file_or_a_fault_starts_nothing(self):
        self.window()
        for name in ("L2_PATH_FACTS", "L2_ALLOC_TRACE", "L2_ALLOC_LOG", "L2_COLON_WRITES", "L2_EXPR_PLACES_OUT", "L2_FAIL_MALLOC"):
            with mock.patch.dict(os.environ, {name: "C:/nowhere/file-or-count"}):
                answer = self.run_static(NEW)
            self.assertEqual((answer["execution"], answer["result"]), ("unavailable", "notRun"), (name, answer))
            self.assertIn(name, answer["message"])
            self.assertFalse((Path(answer["runDirectory"]) / "output.log").exists(), name)
        self.assertEqual(self.run_static(NEW)["result"], "passed")

    def test_command_line_reports_the_verdict_and_its_exit(self):
        self.window()
        command = [sys.executable, "-m", "tools.lmx_dev", "--root", str(self.root), "--config", str(self.config),
                   "check", str(self.source), "--phase", "static", "--closure", NEW]
        done = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        self.assertEqual((done.returncode, json.loads(done.stdout)["result"]), (0, "passed"), done.stderr)
        self.configure("check_reject")
        done = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        answer = json.loads(done.stdout)
        self.assertEqual((done.returncode, answer["result"], answer["exitCode"], answer["logicalExitCode"]), (1, "rejected", 1, 1))
        self.assertIn("not the normative language", answer["coverage"])

    # -- what the phase does not change -----------------------------------------------------------------------

    def test_translation_keeps_its_contract(self):
        self.window()
        answer = self.runner.run("check:translate", str(self.source), closure=NEW)
        self.assertEqual((answer["execution"], answer["result"], answer["achievedPhase"]),
                         ("completed", "passed", "L1 translation"), answer)
        self.assertEqual(len(answer["artifacts"]), 1)
        self.assertNotIn("coverage", answer)
        self.assertEqual(answer["diagnosticsOutsideSource"], 0)
        self.data["operations"]["check:translate"]["argv"][2] = "check_reject"
        self.write()
        self.window()
        located = self.runner.run("check:translate", str(self.source), closure=NEW)
        self.assertEqual((located["diagnostics"][0]["phase"], located["diagnosticsOutsideSource"]), ("translate", 0),
                         "a located line of the translation phase keeps its phase")

    def test_mcp_tool_describes_the_phase_and_refuses_an_undeclared_frontend(self):
        from fastmcp import Client

        from tools.lmx_dev.server import create_server
        from tools.lmx_dev.spec import SpecIndex
        self.window()

        async def call():
            server = create_server(SpecIndex(ROOT, CATALOGUE), self.runner)
            async with Client(server) as client:
                tool = next(t for t in await client.list_tools() if t.name == "check_file")
                self.assertIn('"static"', json.dumps(tool.inputSchema))
                self.assertIn("not the normative sys", tool.description)
                self.assertIn("no library or machine context", tool.description)
                return await client.call_tool("check_file", {"file": str(self.source), "phase": "static", "closure": OLD})

        answer = asyncio.run(call()).data
        self.assertEqual((answer["execution"], answer["result"]), ("unavailable", "notRun"), answer)


if __name__ == "__main__":
    unittest.main()
