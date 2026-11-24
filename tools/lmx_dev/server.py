"""Thin MCP facade; all useful operations also have CLI entry points."""
import asyncio
import anyio
from threading import Event
from typing import Literal

from fastmcp import FastMCP

from .runner import Runner, public_result
from .spec import SpecIndex


def create_server(index: SpecIndex, runner: Runner) -> FastMCP:
    mcp = FastMCP("LMX local development")

    @mcp.tool(annotations={"readOnlyHint": True, "openWorldHint": False})
    def get_spec_rule(topic: str, max_chars: int = 2600, include_history: bool = False) -> dict:
        """Read an exact current Markdown rule with its working-tree hash and source lines.

        Ambiguous queries return candidates. Large sections require an explicit larger budget.
        """
        return index.search(topic, max_chars, include_history)

    async def run(operation: str, file: str | None = None, closure: str = "") -> dict:
        stop = Event()
        task = asyncio.create_task(asyncio.to_thread(runner.run, operation, file, stop, closure))
        try:
            return public_result(await asyncio.shield(task))
        except asyncio.CancelledError:
            stop.set()
            with anyio.CancelScope(shield=True):
                await task  # Persist receipt and kill the owned process tree first.
            raise

    @mcp.tool(annotations={"readOnlyHint": False, "destructiveHint": False, "openWorldHint": False})
    async def check_file(file: str, phase: Literal["syntax", "static", "translate"] = "syntax",
                         closure: str = "") -> dict:
        """Check one project file without running its body/tests. Needs an open compiler window.

        Static is unavailable until a real static CLI exists. Logs/receipts go to a fresh run directory.
        `closure` selects a registered producer closure for syntax/translate by NAME only (never a path or a
        command); empty is the accepted bundle. An unknown, unadmitted or changed closure is refused before any
        process starts. This tool never opens the window.
        """
        return await run("check:" + phase, file, closure)

    @mcp.tool(annotations={"readOnlyHint": False, "destructiveHint": True, "openWorldHint": False})
    async def bootstrap(profile: Literal["smoke", "selfHost"] = "smoke") -> dict:
        """Run component smoke or EXPLICIT full G1/G2 selfHost; both execute target programs.

        Uses a private stage copy, accepted pinned producers and the shared pipeline lock.
        selfHost includes the full suite and may take hours. Never automatic after a check.
        """
        return await run("bootstrap:" + profile)

    @mcp.tool(annotations={"readOnlyHint": True, "openWorldHint": False})
    def service_status() -> dict:
        """Show configured operation coverage, compiler permit and pipeline lock state."""
        return runner.status()

    return mcp
