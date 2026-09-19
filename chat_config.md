# LMX agent communication — operational guide for Codex and Grok

**New inbound Codex channel:** [CODEX_INBOUND.md](claude_chat/CODEX_INBOUND.md). The client is implemented and delivery to the existing active task is verified. Idle-wakeup verification is pending. This supersedes the earlier statements below that no inbound endpoint exists; the remaining channels are unchanged.

Updated 2026-09-19. Run commands from `C:\Nyasha_Planet\LMX`. This is the common entry point for both agents. Historical investigation is preserved in [steps/chat_config_investigation_20260919.md](steps/chat_config_investigation_20260919.md), not the operating procedure.

## 1. Channels and their actual scope

| Sender → recipient | Send mechanism | Receive mechanism | Verified scope |
| --- | --- | --- | --- |
| Codex → existing active Grok → Codex | `grok_active.py`, Windows console input | Same Grok session's native transcript; client returns JSON | Real existing Grok chat, verified challenge and follow-up |
| Codex or Grok → Claude `lmx_uds` | `uds.py send`, authenticated named pipe | `chat_status.py read`; native Claude transcript | Starts a model turn without pressing Enter |
| `lmx_uds` → existing Claude peer → `lmx_uds` | Claude's `ListAgents` and `SendMessage` tools | Peer replies using `SendMessage`; external caller reads `lmx_uds` | Existing `l1-c9`, repeated round trip |
| Codex → separate managed Grok conversation | `grok.py ask`, ACP | JSON returned by client | Separate conversation; NOT the user's existing Grok chat |

There is no verified unsolicited inbound endpoint for an idle Codex task. Grok can answer a Codex-initiated request and include questions in its response; Codex reads those and sends the next turn. Do not claim that Grok can wake an idle Codex task through these scripts. Grok Bot is not connected by this setup.

These channels do not use filesystem inbox/outbox mail or watchers. Native histories are still necessary for replies from the existing Grok and Claude sessions. A pipe write acknowledgement is not a model response. The readable helper replaces noisy terminal logs, not the underlying reply history.

## 2. Discover current recipients; do not ask the user for IDs already in the registry

```powershell
Set-Location C:\Nyasha_Planet\LMX
python claude_chat/chat_status.py peers
```

This reads public metadata from `~/.claude/sessions/*.json` and `~/.grok/active_sessions.json`. It does not read or print credentials. Check name, working directory, session ID and PID before choosing a recipient. Registry entries alone are not proof that a model can answer. If an entry is stale or a name is ambiguous, resolve that before sending.

At the last successful test, Claude names were `lmx_uds`, `l1-c9` and `l1-91`; `l1-98` was no longer listed. Do not send to an old PID just because it appears in an earlier document. Inside Claude, `ListAgents` is the preferred way to resolve recipients immediately before `SendMessage`.

The active Grok used in the verified test was `01a0baf9-6401-7dc3-9819-f322b493bec6`. Re-read the registry before reusing it. Ask the user only when several plausible recipients remain or the intended agent is absent.

## 3. Codex ↔ the existing active Grok

### Setup and send

Requires Windows, Python, the existing signed-in Grok CLI process, its accessible console and native history. The client uses the running session; it does not create or resume another one.

```powershell
python claude_chat/chat_status.py peers
python claude_chat/grok_active.py --session <current-session-id> --timeout 120 "Message to the existing Grok chat"
```

Replace `<current-session-id>` with the discovered ID. Send only while Grok is idle and its visible prompt is empty. Do not type concurrently. The client refuses a nonempty prompt or unfinished turn; do not clear the user's draft or bypass the refusal.

The client adds a unique marker, submits console input, and reads this same session's native `updates.jsonl` until `turn_completed`. Its JSON includes the actual session ID, delivered input, `input_transformed`, reply text and stop reason. If autocomplete transformed the input, inspect `delivered_input` before treating the answer as a response to the intended request. On timeout, inspect history; do not blindly resend an operation that may already have run.

### How Grok replies to Codex

Reply normally in the same Grok turn, including the request's unique code when testing. Codex's waiting client reads the reply and returns it to Codex. Grok may include a question; Codex can answer in another call. This is request/reply, not an independent Grok → idle Codex delivery service. Grok must not run `grok_active.py` against itself to reply.

The exchange `ACK ACTIVE-GROK-93281` followed by `ACTIVE-CONSOLE-CONFIRMED` verified the original active chat. The later input-correlation/whitespace refinements have not had a complete new live regression; do not describe them as separately verified. Details: [GROK_ACTIVE.md](claude_chat/GROK_ACTIVE.md).

### Separate ACP conversation (optional, distinct destination)

```powershell
python claude_chat/grok.py status
python claude_chat/grok.py ask "Message to the separate managed Grok conversation"
```

This uses cached Grok authentication and retains the managed conversation across calls. It is not a way to reach the user's existing terminal chat. Use only when that separate destination is intended. Details: [GROK_DIRECT.md](claude_chat/GROK_DIRECT.md).

## 4. Codex or Grok ↔ Claude peers through lmx_uds

Both Codex and Grok have shell access and can run the identical commands below. `lmx_uds` is a real Claude model acting as a relay, not either external caller's identity. Prefix requests with `From Codex` or `From Grok` and use a unique request code to distinguish concurrent traffic.

### Existing setup

```powershell
python claude_chat/uds.py --name lmx_uds status
python claude_chat/chat_status.py peers
```

Reuse the existing session. Do not run `start` for an already running name: the current script does not prevent duplicate starts. Local state is in ignored `claude_chat/profiles/lmx_uds/uds-state.json`. If state and registry disagree, diagnose the mismatch instead of starting duplicates or substituting another agent's credentials.

### Send a message to an existing Claude agent

Example for Grok (Codex uses the same command with its own sender label and code):

```powershell
python claude_chat/uds.py --name lmx_uds send "From Grok. Request GROK-CLAUDE-001. Use ListAgents to resolve the current l1-c9. SendMessage to it: Please reply to this sender via SendMessage with ACK GROK-CLAUDE-001 and your session name. Print its actual answer here unchanged. Do not contact any other peer or do code work."
```

For real work replace the test payload with the actual task and a fresh request code. The relay must ask the recipient to reply to its sender via `SendMessage`. Do not give it a nonexistent Codex or Grok pipe. Do not mistake `l1-91` or any Claude peer for Codex.

For multiline text, `uds.py send` accepts standard input when the message argument is omitted. Use a literal PowerShell here-string; do not interpolate task text into executable shell syntax.

### Read the response without terminal redraws

```powershell
python claude_chat/chat_status.py read --name lmx_uds --contains GROK-CLAUDE-001 --limit 12
```

The output contains user/assistant text and timestamps only, excluding thinking and tool payloads. A matching outbound request is not an answer: look for the inbound peer message naming the actual sender and the requested ACK or work result. Use the timestamp to distinguish old responses:

```powershell
python claude_chat/chat_status.py read --name lmx_uds --contains GROK-CLAUDE-001 --after 2026-09-19T20:00:00.000Z
```

Reading does not wait or mark messages consumed. If the peer is busy, check again after a reasonable interval; do not send the task repeatedly. A final text from the relay saying it is waiting is not completion. If necessary, read the recipient's native text with `--name l1-c9` to distinguish delivery from a delayed reply.

Diagnostic fallback only:

```powershell
python claude_chat/uds.py --name lmx_uds logs
```

`logs` uses `claude logs` and includes terminal redraws. It is not required for routine reading now that `chat_status.py read` is available. Neither reader creates a mailbox or watcher.

### Why no manual Enter is required

The user authorized automatic cross-session reception. `~/.claude/settings.json` now contains `"crossSessionInbound": "accept"`, preserving other settings. The original file was backed up beside it. This setting affects all Claude sessions using that user profile; tool permissions remain separate.

In inspected CLI 2.1.278, acceptance is sourced from user settings or launch settings. Project `.claude/settings.json` and `.claude/settings.local.json` cannot relax the policy; repositories can tighten it to hold/refuse. Managed restrictions retain priority. Do not use the old project-only `accept` as proof of effective acceptance.

The running sessions reloaded the user setting without restart and released previously held messages. On a different installation, check the effective policy and actual delivery; do not assume hot reload. If approval is held, investigate the configured scope rather than impersonating a sender permission mode.

### Fresh setup if the dedicated relay really does not exist

1. Install/use Claude Code, Python and Node.js on the same Windows account. Check `claude --version`, `python --version`, `node --version`. Tested Claude CLI: 2.1.278. The messaging flag is version-specific and hidden from help.
2. Authenticate this intended Claude profile/provider. For Anthropic OAuth, create the dedicated session, attach to its returned background ID and use `/login`; the user completes browser authentication. For another provider, start from an appropriately configured shell. Never copy credentials from another agent or print them.
3. Configure `crossSessionInbound: accept` in the intended user profile only with authorization; it is already authorized and configured on this host. Preserve other settings and any managed restrictions.
4. Run `python claude_chat/uds.py --name lmx_uds start` only after confirming no existing matching session. State stores the returned ID/PID/pipe. For a deliberately separate relay use another unique name and use it consistently in all commands.
5. Run the unique-code test above and read the actual response. Verify a second request without manual Enter. A running process or successful socket write is insufficient.

The client authenticates the local pipe using the dedicated relay's `peerToken` from its own registered `.key`, then writes two JSON lines (auth, user message). Provider authentication is separate. No model response is returned over that sending socket. Do not display or commit `.key`, OAuth data, environment tokens or local profiles. The client intentionally refuses to directly manage L1 sessions; reach them through Claude's native `SendMessage` instead of removing that guard.

## 5. Evidence and boundaries

- Claude → existing l1-c9 → Claude: `ACK AUTO2-L1C9-76428 — l1-c9 here, transport verified.` Request entered l1-c9 at 20:14:02 UTC on 2026-09-19; its SendMessage reply entered lmx_uds at 20:14:09 UTC. Codex used only pipe injection and history reading; user then confirmed receipt. No console keystrokes were used in that repeat test.
- Previous `AUTO-L1C9-58319` is not independent evidence of unattended delivery: the user reported possibly submitting it accidentally. Use the repeat test above.
- The external Claude client is callable by either Grok or Codex; a fresh Grok-originated live test has not been run by Codex. Grok can verify with its own unique code using §4.
- Automatic unsolicited delivery into idle Codex, a non-console endpoint for the existing active Grok, and Grok Bot connectivity remain unimplemented. Do not present shared names or a registry entry as those capabilities.
- Do not stop/resume the L1 agents, change their providers, or assign unrelated coding work during a transport test.
