"""Registered producer closures: the accepted default, an explicit candidate, and refusals before any process.

Controlled Python fixtures stand for producers; no LMX compiler, stage or permit of the project is used. The
fixture template mirrors the accepted one: argv[0] is the declared producer (the interpreter here), and the bundle
is told by the script it is given.
"""
import asyncio
import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

from tools.lmx_dev.__main__ import grant
from tools.lmx_dev.closures import DEFAULT_CLOSURE, Refused, key, select, verify_pins
from tools.lmx_dev.runner import Runner, machine_lock, public_result, sha, write_json
from tools.lmx_dev.spec import SpecIndex

ROOT = Path(__file__).resolve().parents[3]
CATALOGUE = Path(__file__).resolve().parents[1] / "catalogue.json"
FIXTURE = Path(__file__).with_name("fixture_process.py")
CANDIDATE = "candidate-b"
TOOLS = {"get_spec_rule", "check_file", "bootstrap", "service_status"}


def former_gate(permit: dict, config_hash: str, config: Path) -> bool:
    """The gate of runner.py before closures existed (780d75ead), as a predicate."""
    return bool(permit.get("configHash") == config_hash and sha(config) == config_hash
                and permit.get("expires", 0) > time.time())


class ClosureCase(unittest.TestCase):
    """Two bundles share one operation template: the accepted one of the flat configuration and a registered candidate."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "source file.lm2"
        self.source.write_text('predef: "l2src/a.h.lm1"\n', encoding="utf-8")
        self.accepted_stage = self.root / "accepted-stage"
        (self.accepted_stage / "src" / "l2src").mkdir(parents=True)
        (self.accepted_stage / "src" / "l2src" / "a.h.lm1").write_text("accepted\n", encoding="utf-8")
        self.candidate_tool = self.root / "producers" / "b" / "tool.py"
        self.candidate_tool.parent.mkdir(parents=True)
        self.other = self.root / "producers" / "b" / "other.txt"
        self.other.write_text("a pinned file that is not the producer\n", encoding="utf-8")
        self.unpinned = self.root / "producers" / "b" / "actual-unpinned-exe.exe"
        self.unpinned.write_bytes(b"not a program")
        self.stage = self.root / "candidate-stage"
        (self.stage / "src" / "l2src").mkdir(parents=True)
        self.stage_file = self.stage / "src" / "l2src" / "a.h.lm1"
        self.extra_file = self.stage / "src" / "l2src" / "b.h.lm1"
        self.manifest = self.root / "candidate-b.stage.sha256"
        self.artifacts = self.root / "candidate-b.artifacts.sha256"
        self.config = self.root / "config.json"
        self.runner = Runner(self.root, self.config)
        self.permit = self.root / "permit.json"
        template = {"argv": ["{graph}", "{script}", "ok", "{run}/result.txt", "{source}"], "timeout": 5,
                    "rejected_codes": [2], "success_pattern": "^FIXTURE complete$",
                    "artifacts": ["{run}/result.txt"], "achieved_phase": "Python fixture, not LMX"}
        self.data = {
            "version": 1, "acceptedRevision": "a" * 40, "runs": str(self.root / "runs"),
            "lock": str(self.root / "lock"), "permit": str(self.permit),
            "busy_markers": [str(self.root / "busy")], "watch": [str(self.source)],
            "pins": {str(FIXTURE): sha(FIXTURE)},
            "variables": {"graph": sys.executable, "fe": sys.executable, "script": str(FIXTURE)},
            "stage": str(self.accepted_stage),
            "operations": {"check:syntax": dict(template, cwd="{stage}/src"),
                           "check:static": {"unavailable": "No standalone static CLI."},
                           "bootstrap:smoke": dict(template, cwd="{repo}", copy_stage=True)}}
        self.closure = {"role": "candidate", "description": "Fixture candidate bundle.", "acceptedRevision": "b" * 40,
                        "variables": {"graph": sys.executable, "fe": sys.executable, "script": str(self.candidate_tool)},
                        "stage": str(self.stage), "stageManifest": str(self.manifest),
                        "pinsManifest": str(self.artifacts)}
        self.marked = set()
        self.fresh()

    def tearDown(self):
        self.temp.cleanup()

    def stage_lines(self) -> str:
        return "".join(f"{sha(p)}  {p.relative_to(self.stage).as_posix()}\n"
                       for p in sorted((self.stage / "src").rglob("*")) if p.is_file())

    def lines(self, *paths) -> str:
        return "".join(f"{sha(Path(p))}  {Path(p).as_posix()}\n" for p in paths)

    def fresh(self, registered=True):
        """Restore both bundles byte for byte, write the configuration and close the window."""
        self.candidate_tool.write_bytes(FIXTURE.read_bytes())
        self.stage_file.write_text("candidate\n", encoding="utf-8")
        self.extra_file.write_text("candidate too\n", encoding="utf-8")
        for stray in (self.stage / "src").rglob("*"):
            if stray.is_file() and stray not in (self.stage_file, self.extra_file):
                stray.unlink()
        self.manifest.write_text(self.stage_lines(), encoding="utf-8")
        self.artifacts.write_text(self.lines(sys.executable, self.candidate_tool), encoding="utf-8")
        data = copy.deepcopy(self.data)
        if registered:
            data["closures"] = {CANDIDATE: dict(copy.deepcopy(self.closure), pins={
                str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts)})}
        write_json(self.config, data)
        self.permit.unlink(missing_ok=True)
        shutil.rmtree(self.root / "runs", ignore_errors=True)
        self.mark_runs()

    def registered(self) -> dict:
        return self.runner.load()["closures"][CANDIDATE]

    def write_closure(self, **changes):
        data = self.runner.load()
        data.pop("_loadedHash")
        data["closures"][CANDIDATE].update(changes)
        write_json(self.config, data)

    def write_template(self, *argv: str):
        data = self.runner.load()
        data.pop("_loadedHash")
        data["operations"]["check:syntax"]["argv"] = list(argv)
        write_json(self.config, data)

    def admitted(self, closures=()):
        return grant(self.runner, 60, "fixture", list(closures))

    def window(self, *closures):
        """A permit for exactly these closures, as the lead grants it on the CLI."""
        return grant(self.runner, 60, "fixture", list(closures))

    def candidate(self):
        return self.runner.run("check:syntax", str(self.source), closure=CANDIDATE)

    def runs(self):
        folder = self.root / "runs"
        return sorted(folder.iterdir()) if folder.exists() else []

    def mark_runs(self):
        """The runs made so far; the next refusal must add none that started a producer."""
        self.marked = {run.name for run in self.runs()}

    def new_runs(self):
        return [run for run in self.runs() if run.name not in self.marked]

    def assertNothingStarted(self, answer, *words):
        self.assertEqual((answer["execution"], answer["result"]), ("unavailable", "notRun"), answer)
        for word in words:
            self.assertIn(word, answer["message"])
        for run in self.new_runs():
            self.assertFalse((run / "output.log").exists(), "a producer was started for a refused request")

    def assertRefusedBeforeAnyProcess(self, answer, *words):
        self.assertNothingStarted(answer, *words)
        self.assertEqual(self.new_runs(), [], "a run folder was made for a refused request")

    def test_legacy_configuration_and_default_selection_are_unchanged(self):
        self.fresh(registered=False)
        permit = self.admitted()
        self.assertEqual(set(permit), {"expires", "configHash", "reason"}, "the permit of a flat configuration keeps its shape")
        self.assertTrue(former_gate(permit, self.runner.load()["_loadedHash"], self.config))
        answer = self.runner.run("check:syntax", str(self.source))
        self.assertEqual(answer["result"], "passed", answer)
        self.assertEqual((answer["argv"][0], answer["argv"][1], answer["argv"][2], answer["argv"][-1]),
                         (sys.executable, str(FIXTURE), "ok", str(self.source)))
        self.assertEqual(Path(answer["cwd"]), self.accepted_stage / "src")
        closure = answer["closure"]
        self.assertEqual((closure["name"], closure["role"], closure["selection"]), (DEFAULT_CLOSURE, "accepted", "default"))
        self.assertEqual(closure["acceptedRevision"], "a" * 40)
        self.assertEqual(closure["pinsVerified"], 1)
        self.assertEqual(closure["producers"], {})
        self.assertFalse(closure["stage"]["tracked"], "a flat stage is a path; nothing claims to verify it")
        self.assertEqual(json.loads(Path(answer["receipt"]).read_text(encoding="utf-8")), answer)
        self.assertEqual(public_result(answer)["closure"], closure)
        self.assertEqual(answer["result"], self.runner.run("check:syntax", str(self.source), closure=DEFAULT_CLOSURE)["result"])
        status = self.runner.status()
        self.assertEqual(list(status["closures"]), [DEFAULT_CLOSURE])
        self.assertTrue(status["closures"][DEFAULT_CLOSURE]["admitted"])

    def test_explicit_candidate_runs_its_producer_and_records_evidence(self):
        permit = self.admitted([DEFAULT_CLOSURE, CANDIDATE])
        before = self.runner.run("check:syntax", str(self.source))
        answer = self.candidate()
        self.assertEqual(answer["result"], "passed", answer)
        self.assertEqual((answer["argv"][0], answer["argv"][1]), (sys.executable, str(self.candidate_tool)),
                         "the command of the candidate, not of the accepted bundle")
        self.assertEqual(Path(answer["cwd"]), self.stage / "src")
        closure = answer["closure"]
        self.assertEqual((closure["name"], closure["role"], closure["selection"]), (CANDIDATE, "candidate", "explicit"))
        self.assertEqual(closure["acceptedRevision"], "b" * 40)
        self.assertEqual(closure["pinsVerified"], 4, "two manifests, the declared producer and the script")
        producer = {"path": sys.executable, "sha256": sha(Path(sys.executable))}
        self.assertEqual(closure["producers"], {"graph": producer, "fe": producer, "operation": "graph"})
        self.assertEqual({k: closure["stage"][k] for k in ("tracked", "files", "addedCount", "missingCount", "changedCount")},
                         {"tracked": True, "files": 2, "addedCount": 0, "missingCount": 0, "changedCount": 0})
        self.assertEqual((closure["stage"]["manifest"], closure["stage"]["manifestSha256"]),
                         (str(self.manifest), sha(self.manifest)))
        self.assertEqual(closure["effectiveHash"], select(self.runner.load(), CANDIDATE)["effectiveHash"])
        self.assertEqual(permit["closures"], [DEFAULT_CLOSURE, CANDIDATE])
        self.assertEqual(permit["effectiveHashes"], {CANDIDATE: closure["effectiveHash"]})
        self.assertNotEqual(closure["effectiveHash"], before["closure"]["effectiveHash"])
        self.assertEqual(json.loads(Path(answer["receipt"]).read_text(encoding="utf-8")), answer)
        # The input snapshot names the verified files by their real paths and hashes, and nothing else.
        snapshot = json.loads(Path(answer["inputSnapshot"]).read_text(encoding="utf-8"))
        verified = [self.config, self.source, self.stage_file, self.extra_file, self.candidate_tool,
                    self.manifest, self.artifacts, Path(sys.executable)]
        self.assertEqual({key(p) for p in snapshot}, {key(p) for p in verified})
        by_path = {key(p): digest for p, digest in snapshot.items()}
        for path in verified:
            self.assertEqual(by_path[key(path)], sha(path))
        # The accepted bundle is untouched by the selection.
        after = self.runner.run("check:syntax", str(self.source))
        self.assertEqual((after["argv"][1], after["closure"]["name"], after["closure"]["producers"]),
                         (str(FIXTURE), DEFAULT_CLOSURE, {}))
        self.assertEqual(Path(after["cwd"]), self.accepted_stage / "src")

    def test_refusals_happen_before_any_process(self):
        def candidate():
            return self.candidate()
        cases = {
            "unknown name": (lambda: self.runner.run("check:syntax", str(self.source), closure="nope"),
                              "Unknown producer closure", None),
            "accepted permit": (candidate, "does not admit closure", "legacy"),
            "changed producer": (candidate, "producer/dependency changed", "producer"),
            "producer not pinned": (candidate, "graph producer is not pinned", "unpinned"),
            "changed stage file": (candidate, "1 changed", "stage edit"),
            "added stage file": (candidate, "1 added", "stage add"),
            "removed stage file": (candidate, "1 missing", "stage remove"),
            "swapped stage manifest": (candidate, "producer/dependency changed", "swap stage"),
            # The artifact manifest is read into the pins: other bytes are another closure content, and the permit says so.
            "swapped artifact manifest": (candidate, "different content", "swap artifacts"),
            "duplicate with other hash": (candidate, "listed twice with different hashes", "duplicate"),
            "inheriting producers": (candidate, "must name its own graph and fe", "inherit"),
            "manifest outside src": (candidate, "outside stage/src", "outside"),
            "permit of other content": (candidate, "different content", "content"),
            "closed window": (candidate, "Compiler window is closed", "closed"),
        }
        ungranted = {"legacy", "closed", "duplicate", "inherit"}
        for case, (call, word, setup) in cases.items():
            with self.subTest(case=case):
                self.fresh()
                if setup not in ungranted:
                    self.admitted([CANDIDATE])
                if setup == "legacy":
                    self.admitted()
                elif setup == "producer":
                    self.candidate_tool.write_text(self.candidate_tool.read_text() + "\n# another build\n", encoding="utf-8")
                elif setup == "unpinned":
                    # The producer is installed; the pinned hashes are those of other files only.
                    self.artifacts.write_text(self.lines(self.other), encoding="utf-8")
                    self.write_closure(pins={str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts)})
                    self.admitted([CANDIDATE])
                elif setup == "stage edit":
                    self.stage_file.write_text("edited\n", encoding="utf-8")
                elif setup == "stage add":
                    (self.stage / "src" / "l2src" / "new.h.lm1").write_text("stranger\n", encoding="utf-8")
                elif setup == "stage remove":
                    self.extra_file.unlink()
                elif setup == "swap stage":
                    self.manifest.write_text(self.stage_lines().replace(sha(self.stage_file), "0" * 64), encoding="utf-8")
                elif setup == "swap artifacts":
                    self.artifacts.write_text(self.lines(sys.executable, self.candidate_tool, self.other), encoding="utf-8")
                elif setup == "duplicate":
                    # One file, two hashes: the pin of the closure and the line of the manifest disagree.
                    self.write_closure(pins={str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts),
                                             str(self.candidate_tool): "0" * 64})
                elif setup == "inherit":
                    self.write_closure(variables={"graph": sys.executable})
                elif setup == "outside":
                    (self.stage / "tests").mkdir()
                    (self.stage / "tests" / "list.tsv").write_text("row\n", encoding="utf-8")
                    self.manifest.write_text(self.stage_lines() + f"{sha(self.stage / 'tests' / 'list.tsv')}  tests/list.tsv\n",
                                             encoding="utf-8")
                    self.write_closure(pins={str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts)})
                    self.admitted([CANDIDATE])
                elif setup == "content":
                    permit = json.loads(self.permit.read_text(encoding="utf-8"))
                    permit["effectiveHashes"] = {CANDIDATE: "f" * 64}
                    write_json(self.permit, permit)
                elif setup == "closed":
                    self.permit.unlink(missing_ok=True)
                self.assertRefusedBeforeAnyProcess(call(), word)

    def test_a_manifest_with_one_file_twice_or_unpinned_is_no_evidence(self):
        self.artifacts.write_text(self.lines(sys.executable, self.candidate_tool)
                                  + f"{'0' * 64}  {self.candidate_tool.as_posix()}\n", encoding="utf-8")
        self.write_closure(pins={str(self.manifest): sha(self.manifest), str(self.artifacts): sha(self.artifacts)})
        self.assertRefusedBeforeAnyProcess(self.candidate(), "listed twice with different hashes")
        with self.assertRaisesRegex(Refused, "listed twice"):
            self.admitted([CANDIDATE])
        self.assertFalse(self.permit.exists())
        self.fresh()
        closure = self.registered()
        del closure["pins"][str(self.artifacts)]
        self.write_closure(pins=closure["pins"])
        self.assertRefusedBeforeAnyProcess(self.candidate(), "pinsManifest is not pinned")
        self.assertFalse(self.permit.exists())

    def test_manifest_read_before_the_lock_is_bound_to_its_bytes(self):
        self.admitted([CANDIDATE])
        effective = select(self.runner.load(), CANDIDATE)
        self.assertEqual(effective["pinsManifestDigest"], sha(self.artifacts))
        self.assertEqual(verify_pins(effective)[key(self.candidate_tool)], sha(self.candidate_tool))
        # The file under the lock is the pinned one, but the entries came from other bytes: refused.
        with self.assertRaisesRegex(Refused, "pinsManifest changed after it was read"):
            verify_pins(dict(effective, pinsManifestDigest="0" * 64))
        # The file changed after it was read: the pin itself refuses it.
        self.artifacts.write_text(self.lines(sys.executable, self.candidate_tool, self.other), encoding="utf-8")
        with self.assertRaisesRegex(Refused, "producer/dependency changed"):
            verify_pins(effective)

    def test_command_must_start_with_the_declared_pinned_producer(self):
        # argv[0] is an executable nobody pinned; the declared producer stays later in the command.
        for start in (str(self.unpinned), "{script}", str(self.other)):
            with self.subTest(start=start):
                self.fresh()
                self.write_template(start, "{graph}", "{script}", "ok", "{run}/result.txt", "{source}")
                self.admitted([CANDIDATE])
                answer = self.candidate()
                self.assertNothingStarted(answer, "must start with its declared graph producer")
                self.assertEqual(len(self.runs()), 1, "the refusal is recorded; nothing was started")
                receipt = json.loads((self.runs()[0] / "receipt.json").read_text(encoding="utf-8"))
                self.assertEqual(receipt["closure"]["producers"]["graph"]["sha256"], sha(Path(sys.executable)))
                self.assertFalse((self.runs()[0] / "result.txt").exists())
        # The accepted template itself, with the candidate's own producer and stage, passes.
        self.fresh()
        self.admitted([CANDIDATE])
        self.assertEqual(self.candidate()["result"], "passed")

    @unittest.skipUnless(os.name == "nt", "a junction is a Windows file system link")
    def test_a_link_in_the_stage_tree_does_not_pass_the_exact_set(self):
        import _winapi
        self.admitted([CANDIDATE])
        hidden = self.root / "hidden"
        hidden.mkdir()
        (hidden / "x.h.lm1").write_text("hidden\n", encoding="utf-8")
        link = self.stage / "src" / "linked"
        _winapi.CreateJunction(str(hidden), str(link))
        try:
            self.assertRefusedBeforeAnyProcess(self.candidate(), "contains a link")
        finally:
            os.rmdir(link)
        self.assertEqual(self.candidate()["result"], "passed")

    def test_permit_is_scoped_and_an_older_runner_does_not_accept_it(self):
        permit = self.admitted([DEFAULT_CLOSURE, CANDIDATE, CANDIDATE])
        loaded = self.runner.load()["_loadedHash"]
        self.assertEqual(set(permit), {"expires", "scopedConfigHash", "reason", "closures", "effectiveHashes"})
        self.assertEqual((permit["scopedConfigHash"], permit["closures"]), (loaded, [DEFAULT_CLOSURE, CANDIDATE]))
        self.assertEqual(permit["effectiveHashes"], {CANDIDATE: select(self.runner.load(), CANDIDATE)["effectiveHash"]})
        # The gate of a runner that ignores closures finds no binding and keeps the window closed.
        self.assertFalse(former_gate(permit, loaded, self.config))
        # The current runner admits exactly what the permit names.
        self.assertEqual(self.candidate()["result"], "passed")
        self.assertEqual(self.runner.run("check:syntax", str(self.source))["result"], "passed")
        self.mark_runs()
        # A permit with names but without the scoped binding admits nothing.
        write_json(self.permit, dict(permit, scopedConfigHash="0" * 64))
        self.assertRefusedBeforeAnyProcess(self.candidate(), "expired or belongs to a different producer configuration")
        # A legacy permit names nothing: the accepted bundle only.
        self.fresh()
        self.admitted()
        self.assertEqual(self.runner.run("check:syntax", str(self.source))["result"], "passed")
        self.mark_runs()
        self.assertRefusedBeforeAnyProcess(self.candidate(), "does not admit closure")

    def test_an_explicit_permit_admits_exactly_its_names_and_not_the_default(self):
        # A permit for a candidate only: the accepted producer is not started in this window, by any route.
        permit = self.admitted([CANDIDATE])
        self.assertEqual(permit["closures"], [CANDIDATE])
        self.assertNotIn(DEFAULT_CLOSURE, permit["closures"])
        self.assertNotIn(DEFAULT_CLOSURE, permit["effectiveHashes"])
        self.assertRefusedBeforeAnyProcess(self.runner.run("check:syntax", str(self.source)), "does not admit closure 'accepted'")
        self.assertRefusedBeforeAnyProcess(self.runner.run("check:syntax", str(self.source), closure=DEFAULT_CLOSURE),
                                           "does not admit closure 'accepted'")
        self.assertRefusedBeforeAnyProcess(self.runner.run("bootstrap:smoke"), "does not admit closure 'accepted'")
        self.assertEqual(self.runner.status()["compilerWindow"], "permitted")
        self.assertEqual([item["admitted"] for item in self.runner.status()["closures"].values()], [False, True])
        self.assertEqual(self.candidate()["result"], "passed")
        # The accepted bundle joins only when it is named too.
        permit = self.admitted([DEFAULT_CLOSURE, CANDIDATE])
        self.assertEqual(permit["closures"], [DEFAULT_CLOSURE, CANDIDATE])
        self.assertEqual(self.runner.run("check:syntax", str(self.source))["result"], "passed")
        self.assertEqual(self.candidate()["result"], "passed")
        # Without names: the former permit, the accepted bundle only.
        legacy = self.admitted()
        self.assertEqual(set(legacy), {"expires", "configHash", "reason"})

    def test_grant_refuses_unknown_names_and_a_busy_pipeline_without_writing(self):
        self.admitted()
        before = self.permit.read_bytes()
        with self.assertRaises(Refused):
            self.admitted(["nope"])
        self.assertEqual(self.permit.read_bytes(), before, "a refused grant leaves the permit as it was")
        with machine_lock(self.root / "lock", []):
            with self.assertRaises(ValueError):
                self.admitted([CANDIDATE])
        self.assertEqual(self.permit.read_bytes(), before)
        self.fresh()
        self.write_closure(variables={"graph": sys.executable})
        with self.assertRaisesRegex(Refused, "graph and fe"):
            self.admitted([CANDIDATE])
        self.assertFalse(self.permit.exists())

    def test_lock_is_not_reentered_for_a_candidate(self):
        self.admitted([CANDIDATE])
        with machine_lock(self.root / "lock", []):
            self.assertRefusedBeforeAnyProcess(self.candidate(), "Pipeline busy")
            # A second process sees the same atomic lock and refuses before starting the candidate's producer.
            cmd = [sys.executable, "-m", "tools.lmx_dev", "--root", str(self.root), "--config", str(self.config),
                   "check", str(self.source), "--closure", CANDIDATE]
            done = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(done.returncode, 1, done.stdout + done.stderr)
            answer = json.loads(done.stdout)
            self.assertIn("Pipeline busy", answer["message"])
            self.assertEqual(answer["closure"]["name"], CANDIDATE)
        (self.root / "busy").touch()
        self.assertRefusedBeforeAnyProcess(self.candidate(), "marker")
        (self.root / "busy").unlink()
        self.assertEqual(self.candidate()["result"], "passed")

    def test_bootstrap_and_static_stay_where_they_are(self):
        self.admitted([DEFAULT_CLOSURE, CANDIDATE])
        answer = self.runner.run("bootstrap:smoke", closure=CANDIDATE)
        self.assertRefusedBeforeAnyProcess(answer, "accepted closure only")
        answer = self.runner.run("check:static", str(self.source), closure=CANDIDATE)
        self.assertRefusedBeforeAnyProcess(answer, "No standalone static CLI")
        answer = self.runner.run("bootstrap:smoke")
        self.assertEqual(answer["result"], "passed", answer)
        self.assertEqual((answer["closure"]["name"], answer["argv"][1]), (DEFAULT_CLOSURE, str(FIXTURE)))

    def test_status_lists_closures_roles_and_admission(self):
        status = self.runner.status()["closures"]
        self.assertEqual(list(status), [DEFAULT_CLOSURE, CANDIDATE])
        self.assertEqual((status[CANDIDATE]["admitted"], status[CANDIDATE]["role"], status[CANDIDATE]["pins"]),
                         (False, "candidate", 4))
        self.assertEqual(status[CANDIDATE]["producers"], {"graph": sys.executable, "fe": sys.executable})
        self.assertEqual(status[CANDIDATE]["stage"], {"root": str(self.stage), "manifest": str(self.manifest)})
        self.admitted()
        status = self.runner.status()["closures"]
        self.assertEqual((status[DEFAULT_CLOSURE]["admitted"], status[DEFAULT_CLOSURE]["role"]), (True, "accepted"))
        self.assertIn("does not admit", status[CANDIDATE]["admission"])
        self.admitted([CANDIDATE])
        status = self.runner.status()["closures"]
        self.assertEqual([status[name]["admitted"] for name in status], [False, True])
        self.assertIn("does not admit closure 'accepted'", status[DEFAULT_CLOSURE]["admission"])
        self.admitted([DEFAULT_CLOSURE, CANDIDATE])
        self.assertTrue(all(item["admitted"] for item in self.runner.status()["closures"].values()))
        self.write_closure(stageManifest="")
        broken = self.runner.status()["closures"][CANDIDATE]
        self.assertEqual((broken["admitted"], "problem" in broken), (False, True))
        self.assertIn("stageManifest is required", broken["problem"])

    def test_mcp_takes_a_registered_name_only(self):
        from fastmcp import Client
        from tools.lmx_dev.server import create_server
        self.admitted([CANDIDATE])
        server = create_server(SpecIndex(ROOT, CATALOGUE), self.runner)

        async def scenario():
            async with Client(server) as client:
                tools = await client.list_tools()
                self.assertEqual({tool.name for tool in tools}, TOOLS, "no tool opens the window")
                schema = next(tool for tool in tools if tool.name == "check_file").inputSchema
                self.assertEqual(schema["properties"]["closure"]["type"], "string")
                answer = (await client.call_tool("check_file", {"file": str(self.source), "phase": "syntax",
                                                                "closure": CANDIDATE})).data
                self.assertEqual((answer["result"], answer["closure"]["name"], answer["closure"]["producers"]["operation"]),
                                 ("passed", CANDIDATE, "graph"))
                self.mark_runs()
                for bad in ("nope", "../../elsewhere", "C:/Windows/notepad.exe", "--closure=x"):
                    answer = (await client.call_tool("check_file", {"file": str(self.source), "phase": "syntax",
                                                                    "closure": bad})).data
                    self.assertNothingStarted(answer, "Unknown producer closure")
                status = (await client.call_tool("service_status", {})).data
                self.assertEqual(list(status["closures"]), [DEFAULT_CLOSURE, CANDIDATE])
        asyncio.run(scenario())
        self.assertEqual(len(self.runs()), 1, "an unknown name started nothing")

    def test_stdio_server_with_an_isolated_configuration(self):
        from fastmcp import Client
        from fastmcp.client.transports import StdioTransport
        self.admitted()  # the accepted bundle only: the candidate is refused through the real server too
        transport = StdioTransport(command=sys.executable,
                                   args=["-m", "tools.lmx_dev", "--root", str(self.root), "--config", str(self.config), "serve"],
                                   cwd=str(ROOT))

        async def scenario():
            async with Client(transport) as client:
                tools = await client.list_tools()
                self.assertEqual({tool.name for tool in tools}, TOOLS)
                answer = (await client.call_tool("check_file", {"file": str(self.source), "phase": "syntax",
                                                                "closure": CANDIDATE})).data
                self.assertNothingStarted(answer, "does not admit closure")
                answer = (await client.call_tool("check_file", {"file": str(self.source), "phase": "syntax"})).data
                self.assertEqual((answer["result"], answer["closure"]["selection"]), ("passed", "default"))
        asyncio.run(scenario())
        self.assertEqual(len(self.runs()), 1)

    def test_cli_selection_and_grant(self):
        base = [sys.executable, "-m", "tools.lmx_dev", "--root", str(self.root), "--config", str(self.config)]

        def cli(*words):
            done = subprocess.run([*base, *words], cwd=ROOT, capture_output=True, text=True)
            self.assertTrue(done.stdout.lstrip().startswith("{"), done.stdout + done.stderr)
            return done.returncode, json.loads(done.stdout)

        code, answer = cli("check", str(self.source), "--closure", CANDIDATE)
        self.assertEqual((code, answer["execution"]), (1, "unavailable"))
        self.assertIn("Compiler window is closed", answer["message"])
        self.assertEqual(answer["closure"]["name"], CANDIDATE)
        code, answer = cli("permit", "--seconds", "60", "--reason", "fixture", "--closure", "nope")
        self.assertEqual(code, 1)
        self.assertIn("Unknown producer closure", answer["message"])
        self.assertFalse(self.permit.exists(), "a refused grant wrote no permit")
        code, answer = cli("permit", "--seconds", "60", "--reason", "fixture", "--closure", CANDIDATE)
        self.assertEqual((code, answer["closures"]), (0, [CANDIDATE]))
        self.assertNotIn("configHash", json.loads(self.permit.read_text(encoding="utf-8")))
        code, answer = cli("check", str(self.source), "--phase", "syntax")
        self.assertEqual((code, answer["execution"]), (1, "unavailable"))
        self.assertIn("does not admit closure 'accepted'", answer["message"])
        code, answer = cli("check", str(self.source), "--phase", "syntax", "--closure", CANDIDATE)
        self.assertEqual((code, answer["result"], answer["closure"]["selection"]), (0, "passed", "explicit"))
        self.assertEqual(answer["closure"]["producers"]["graph"]["sha256"], sha(Path(sys.executable)))
        code, answer = cli("status")
        self.assertEqual((code, [answer["closures"][name]["admitted"] for name in answer["closures"]]), (0, [False, True]))
        code, answer = cli("check", str(self.source), "--phase", "static", "--closure", CANDIDATE)
        self.assertEqual((code, answer["execution"]), (1, "unavailable"))


if __name__ == "__main__":
    unittest.main()
