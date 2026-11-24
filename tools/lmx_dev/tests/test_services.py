import asyncio
import json
import os
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path

from tools.lmx_dev.runner import Runner, machine_lock, sha, write_json
from tools.lmx_dev.spec import SpecIndex
from tools.lmx_dev.diagnostics import collect, is_hosted_p0_rejection

ROOT = Path(__file__).resolve().parents[3]
CATALOGUE = Path(__file__).resolve().parents[1] / "catalogue.json"
FIXTURE = Path(__file__).with_name("fixture_process.py")


class SpecTests(unittest.TestCase):
    def test_real_queries_preserve_sources_and_notation(self):
        index = SpecIndex(ROOT, CATALOGUE)
        expected = {"R0": "program.root_startup", "Main": "program.root_startup",
                    "int@:": "types.postfix", "int[]": "types.postfix", "`@name`": "syntax.names",
                    "::": "syntax.signature", "динамическое связывание": "binding.chain",
                    "own default": "binding.own_default", "bind": "operations.bind", "Pattern-then": "patterns.then"}
        for query, rule in expected.items():
            with self.subTest(query=query):
                answer = index.search(query, 80000)
                self.assertEqual(answer["status"], "found", answer)
                self.assertEqual(answer["ruleId"], rule)
                source = answer["source"]
                lines = (ROOT / source["file"]).read_bytes().decode("utf-8-sig").splitlines(keepends=True)
                self.assertEqual(answer["text"], "".join(lines[source["lineStart"]-1:source["lineEnd"]]))
        answer = index.search("then")
        self.assertEqual(answer["status"], "ambiguous")
        self.assertEqual({x["ruleId"] for x in answer["candidates"]}, {"operations.bind", "patterns.then"})

    def test_refresh_history_fences_missing_anchor_and_budget(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source, catalog = root / "a.md", root / "catalog.json"
            source.write_text('# Current\n<a id="rule"></a>\nnew value\n```\n# Not a heading\n```\n'
                              '# Historical\n<a id="old"></a>\nold-only-word\n', encoding="utf-8")
            write_json(catalog, {"documents": {"a.md": "normative"}, "rules": [
                {"id": "r", "source": "a.md#rule", "aliases": ["term"]}]})
            index = SpecIndex(root, catalog)
            before = index.search("term")
            self.assertIn("# Not a heading", before["text"])
            self.assertEqual(index.search("old-only-word")["status"], "notFound")
            self.assertEqual(index.search("old-only-word", include_history=True)["authority"], "historical")
            source.write_text(source.read_text().replace("new value", "new changed value " * 100), encoding="utf-8")
            after = index.search("term", 500)
            self.assertEqual(after["status"], "sectionTooLarge")
            self.assertNotIn("text", after)
            self.assertNotEqual(before["specRevision"], after["specRevision"])
            source.write_text("# Removed\n", encoding="utf-8")
            self.assertEqual(index.search("term")["status"], "indexError")


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "file with spaces & symbols.lm2"
        self.source.write_text("initial", encoding="utf-8")
        self.config = self.root / "config.json"
        self.runner = Runner(self.root, self.config)
        self.data = {
            "version": 1, "runs": str(self.root / "runs"), "lock": str(self.root / "lock"),
            "permit": str(self.root / "permit.json"), "busy_markers": [str(self.root / "busy")],
            "watch": [str(self.source)], "pins": {str(FIXTURE): sha(FIXTURE)},
            "operations": {"check:syntax": {
                "argv": [sys.executable, str(FIXTURE), "ok", "{run}/result.txt", "{source}"],
                "cwd": "{repo}", "timeout": 5, "rejected_codes": [2],
                "success_pattern": "^FIXTURE complete$", "artifacts": ["{run}/result.txt"],
                "achieved_phase": "Python fixture, not LMX"}}}
        self.configure()

    def tearDown(self):
        self.temp.cleanup()

    def configure(self, mode="ok", **changes):
        op = self.data["operations"]["check:syntax"]
        op["argv"][2] = mode
        op.update(changes)
        write_json(self.config, self.data)
        write_json(self.root / "permit.json", {"expires": time.time() + 60, "configHash": sha(self.config)})

    def run_fixture(self, **kwargs):
        return self.runner.run("check:syntax", str(self.source), **kwargs)

    def test_success_full_receipt_and_new_artifact(self):
        a, b = self.run_fixture(), self.run_fixture()
        self.assertEqual(a["result"], "passed", a)
        self.assertFalse(a["stale"])
        self.assertNotEqual(a["runId"], b["runId"])
        self.assertEqual(a["argv"][-1], str(self.source))
        self.assertEqual(next(iter(a["artifacts"].values())), sha(Path(a["runDirectory"]) / "result.txt"))
        self.assertEqual(json.loads(Path(a["receipt"]).read_text()), a)

    def test_reject_and_unknown_diagnostic(self):
        self.configure("reject")
        answer = self.run_fixture()
        self.assertEqual((answer["execution"], answer["result"]), ("completed", "rejected"), answer)
        self.assertEqual(answer["diagnostics"][0]["code"], 4)
        self.assertIsNone(answer["diagnostics"][0]["file"])
        self.assertEqual(answer["unparsedDiagnosticLines"], 1)

    def test_missing_artifact_unknown_exit_and_stale(self):
        for mode in ["missing", "exit"]:
            self.configure(mode)
            self.assertEqual(self.run_fixture()["execution"], "protocolError")
        self.configure("stale")
        answer = self.run_fixture()
        self.assertTrue(answer["stale"])
        self.assertEqual(answer["result"], "indeterminate")

    def test_crash_is_not_source_rejection(self):
        self.configure("crash")
        answer = self.run_fixture()
        self.assertEqual(answer["execution"], "crash", answer)
        self.assertEqual(answer["result"], "indeterminate")

    def test_hosted_p0_keeps_process_and_logical_exit(self):
        self.configure("hosted_reject", hosted_exit_adapter="p0-v1")
        answer = self.run_fixture()
        self.assertEqual((answer["execution"], answer["result"]), ("completed", "rejected"), answer)
        self.assertEqual((answer["exitCode"], answer["logicalExitCode"]), (1, 2))
        self.assertEqual(answer["diagnostics"][0]["code"], 19)
        log = Path(__file__).with_name("hosted-p0-rejected.log").read_text()
        for changed in [log.replace("1 failed", "2 failed"), log.replace("FAIL [exit]", "FAIL [arena]"),
                        log.replace("exit 2,", "exit 5,"), log.split("P0 parse error")[0],
                        log + "fatal: unrelated host failure\n"]:
            p = self.root / "other.log"
            p.write_text(changed)
            self.assertFalse(is_hosted_p0_rejection(dict(collect(p, None), exitCode=1)))

    def test_gate_lock_pin_and_outside_source(self):
        with machine_lock(self.root / "lock", []):
            self.assertEqual(self.run_fixture()["execution"], "unavailable")
            # A second Python process must see the exact same atomic lock.
            cmd = [sys.executable, "-m", "tools.lmx_dev", "--root", str(self.root), "--config", str(self.config),
                   "check", str(self.source)]
            p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
            self.assertIn("Pipeline busy", json.loads(p.stdout)["message"])
        (self.root / "busy").touch()
        self.assertEqual(self.run_fixture()["execution"], "unavailable")
        (self.root / "busy").unlink()
        (self.root / "permit.json").unlink()
        self.assertEqual(self.run_fixture()["result"], "notRun")
        self.configure()
        self.data["pins"][str(FIXTURE)] = "bad pin"
        self.configure()
        self.assertIn("changed", self.run_fixture()["message"])
        self.assertEqual(self.runner.run("check:syntax", str(FIXTURE))["execution"], "protocolError")

    def test_timeout_and_cancellation_kill_descendants(self):
        for cancelled in [False, True]:
            self.configure("tree", timeout=10 if cancelled else 1)
            stop = threading.Event()
            timer = threading.Timer(1, stop.set) if cancelled else None
            if timer:
                timer.start()
            answer = self.run_fixture(cancel=stop)
            if timer:
                timer.join()
            self.assertEqual(answer["execution"], "cancelled" if cancelled else "timeout", answer)
            heartbeat = Path(answer["runDirectory"]) / "result.txt"
            self.assertTrue(heartbeat.exists())
            last = heartbeat.read_text()
            time.sleep(.4)
            self.assertEqual(heartbeat.read_text(), last, "descendant survived tree termination")
            self.assertFalse((self.root / "lock").exists())


class ProtocolTests(unittest.IsolatedAsyncioTestCase):
    async def test_mcp_cancellation_persists_receipt_and_kills_child(self):
        from fastmcp import Client
        import mcp.types
        from tools.lmx_dev.server import create_server
        fixture = RunnerTests()
        fixture.setUp()
        try:
            fixture.configure("tree", timeout=15)
            server = create_server(SpecIndex(ROOT, CATALOGUE), fixture.runner)
            async with Client(server) as client:
                # asyncio task cancellation alone is not an MCP cancellation notification.
                # The SDK allocates this monotonically increasing ID to the next request.
                request_id = client.session._request_id
                task = asyncio.create_task(client.call_tool("check_file", {"file": str(fixture.source)}))
                deadline = time.monotonic() + 8
                while not list((fixture.root / "runs").glob("*/result.txt")):
                    if time.monotonic() > deadline:
                        self.fail("Fixture never started")
                    await asyncio.sleep(.05)
                await client.session.send_notification(mcp.types.ClientNotification(
                    mcp.types.CancelledNotification(params=mcp.types.CancelledNotificationParams(
                        requestId=request_id, reason="test cancellation"))))
                await asyncio.wait_for(asyncio.gather(task, return_exceptions=True), timeout=8)
                receipt = next((fixture.root / "runs").glob("*/receipt.json"))
                while json.loads(receipt.read_text())["execution"] == "running":
                    if time.monotonic() > deadline:
                        self.fail("MCP cancellation did not finish cleanup")
                    await asyncio.sleep(.05)
                answer = json.loads(receipt.read_text())
                self.assertEqual(answer["execution"], "cancelled", answer)
                heartbeat = receipt.with_name("result.txt")
                last = heartbeat.read_text()
                await asyncio.sleep(.3)
                self.assertEqual(heartbeat.read_text(), last)
        finally:
            fixture.tearDown()

    async def test_stdio_real_handshake_and_tools(self):
        from fastmcp import Client
        from fastmcp.client.transports import StdioTransport
        transport = StdioTransport(command=sys.executable,
                                   args=["-m", "tools.lmx_dev", "serve"], cwd=str(ROOT))
        async with Client(transport) as client:
            names = {tool.name for tool in await client.list_tools()}
            self.assertEqual(names, {"get_spec_rule", "check_file", "bootstrap", "service_status"})
            result = await client.call_tool("get_spec_rule", {"topic": "R0"})
            self.assertEqual(result.data["ruleId"], "program.root_startup")
            result = await client.call_tool("check_file", {"file": "missing.lm2", "phase": "static"})
            self.assertEqual(result.data["execution"], "unavailable")


if __name__ == "__main__":
    unittest.main()
