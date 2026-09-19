# Historical investigation — superseded by ../chat_config.md

Do not use historical authentication or availability conclusions as current setup instructions.

# Claude Code cross-session messaging — verified description

Written 2026-09-19 by the session registered as **l1-98** (pid 7708, cwd `C:\Nyasha_Planet\L1`),
from a read-only investigation of a live installation. Nothing outside this file was created,
changed or restarted; no live pipe was probed with guessed payloads.

Scope: what the mechanism **is**, how a session **finds** another, how a message is **sent and
delivered**, and what an external process can and cannot do today.

---

## 1. The `SendMessage` tool — schema and a real call

`SendMessage` is a first-class tool of a running Claude Code session. Its parameters (as exposed
to the model in this session):

| parameter | type | meaning |
| --- | --- | --- |
| `to` | string, required | recipient: a name from `ListAgents` (e.g. `l1-c9`), or a raw agent id |
| `message` | string | plain-text body. First line is what the recipient's human sees as a preview |
| `summary` | string | 5–10 word label for the sender's own transcript row (not transmitted) |
| `notify_when_idle` | boolean | ask a session **on this machine** for one notice when it next goes idle |

A **real, successful** call made by this session (no secrets involved):

```
SendMessage(to="l1-c9",
            summary="Модель изменилась: закрытие останавливает, не освобождает",
            message="l1-98: модель изменилась по слову Михаила — это касается и твоего mixa, читай. …")
```

and the result returned by the harness:

```json
{"success":true,
 "message":"“Модель изменилась: закрытие останавливает, не освобождает” → l1-c9 (another Claude
            session on this machine; queued there — a [Cross-session delivery notice] follows if
            that session holds it (different permission mode: its user must approve first) or
            refuses it)",
 "msg_id":"47419289-c08e-4aa9-a7de-7f7912a07e6d"}
```

Reading that result carefully matters (§5): `success: true` means **the message reached that
session's inbox**, not that its model read it.

`ListAgents` is the discovery tool on the sender's side. In this session it printed, verbatim:

```
This session is l1-98 [54f775] — the name other sessions use to message it.
Peer sessions (1):
  l1-c9 [941c19]  ·  interactive  ·  idle  ·  started 3h ago
```

## 2. How a session obtains and publishes its address; how another agent discovers it

**Verified.** Every running session writes a registration file:

```
C:\Users\<user>\.claude\sessions\<pid>.json
```

Contents of the two files present on this machine (key names read from the JSON; values for the
non-secret fields printed):

| field | l1-98 (this session) | l1-c9 |
| --- | --- | --- |
| `pid` | 7708 | 2064 |
| `name` | `l1-98` | `l1-c9` |
| `nameSource` | `derived` | `derived` |
| `kind` | `interactive` | `interactive` |
| `status` | `busy` | `idle` |
| `cwd` | `C:\Nyasha_Planet\L1` | `C:\Nyasha_Planet\L1` |
| `sessionId` | `212154d1-c120-4d0d-8c19-859b93bfd602` | `a78b8512-4a72-451a-b71b-a853c982c28e` |
| `messagingSocketPath` | `\\.\pipe\LOCAL\cc-msg-827d26f93226eb6f632e43f06dcc54a9` | `\\.\pipe\LOCAL\cc-msg-546d363f7a551791eb461a4ccc9b2f27` |
| `peerProtocol` | `1` | `1` |
| `peerFeatures` | `["notify_idle","artifact_yield"]` | `["notify_idle","artifact_yield"]` |
| `version` | `2.1.276` | `2.1.277` |

Other keys present in the file: `entrypoint`, `pidDomain`, `procStart`, `startedAt`,
`updatedAt`, `statusUpdatedAt`, `nameSince`.

The session's own address is also in its environment:

```powershell
$env:CLAUDE_CODE_MESSAGING_SOCKET     # \\.\pipe\LOCAL\cc-msg-<32 hex>
$env:CLAUDE_CODE_MESSAGING_TOKEN      # present; value NOT printed anywhere in this document
$env:CLAUDE_CODE_ENTRYPOINT           # cli
$env:CLAUDE_CODE_EXECPATH             # C:\Users\mtkra\.local\bin\claude.exe
```

**Discovery = read that directory.** A peer is considered live by the implementation if all of
these hold (string extracted from the shipped executable, `…\.local\share\claude\versions\2.1.278`):

```
kind === "interactive" && pid !== process.pid && sessionId &&
(peerProtocol ?? 0) >= <current protocol> &&
(now - (updatedAt ?? startedAt)) < 86400000          // 24 hours
```

The pipe-name grammar is enforced by a regex found in the same binary:

```
rAn = "cc-msg-", oAn = "LOCAL"
new RegExp(`^(?:${oAn}\\)?${rAn}[0-9a-f]{32}$`, "i")
```

i.e. `\\.\pipe\LOCAL\cc-msg-` followed by exactly 32 hex characters.

## 3. `uds:`, `from`, `from-name`, `from-mode`

An incoming message arrives inside a wrapper; observed verbatim in this session:

```
<cross-session-message from="uds:\\.\pipe\LOCAL\cc-msg-546d363f7a551791eb461a4ccc9b2f27"
                       from-name="l1-c9" from-mode="bypass">
```

| token | meaning | status |
| --- | --- | --- |
| `uds:` | address-family prefix of the address that follows (named pipe / unix-domain socket) | verified as the literal form observed |
| `from` | the **sender's own** `messagingSocketPath` — byte-for-byte equal to the value in that session's registry file | verified (matched against `2064.json`) |
| `from-name` | the sender's registry `name` (`l1-c9`) | verified by cross-check with the registry |
| `from-mode` | the sender's permission mode string (`bypass` observed for l1-c9) | **verified in the implementation**: the receiving side compares permission modes and, when they differ, holds the message; the harness's own wording for that hold is *"Your message is held for the recipient user's approval before it reaches their Claude session (permission-mode parity)"*. **The full set of mode values was not enumerated.** |

## 4. Sending from an external Python / Node / CLI process

**An injection path exists and is first-party.** It is not a CLI subcommand for `SendMessage`;
it is the messaging socket itself, and the implementation prints its own recipe at startup
(strings extracted from `…\share\claude\versions\2.1.278`, this machine):

```
[uds-messaging] Listening: <path>
[uds-messaging] Inject messages (auth line REQUIRED here; a pipe is not reachable via socat/AF_UNIX):
  node -e "const c=require('net').connect(process.argv[1],()=>{c.write(
      JSON.stringify({type:'auth',token:process.env.CLAUDE_CODE_MESSAGING_TOKEN})+'\n'+
      JSON.stringify({type:'user',message:{role:'user',content:'hello'}})+'\n');c.end()})" "<path>"
[uds-messaging] Connect when the data is ready (run the command first, then connect and write its
   output as ONE line, as in the node recipe above): a connection that sends no complete line
   within <firstLineDeadlineMs> ms is closed
```

Verified from the same binary:

* **framing**: newline-delimited JSON, one JSON object per line;
* **line 1 must be the auth line** — `{"type":"auth","token":<token>}`. The code paths
  `requireAuth`, `authRequired`, `authOkReported`, `authDropReported`, `activeTokens` show the
  token is **validated**, not merely present. A connection that does not send a complete line
  within `firstLineDeadlineMs` is closed;
* **line 2 is the message** — `{"type":"user","message":{"role":"user","content":"…"}}`: a plain
  user message injected into the recipient session;
* **other frame types seen in the implementation**: `peer_message_status` (with `status`,
  `status_detail`, `orig_msg_id`, `drop_reason`), `cross_session_notify_idle` (the
  `notify_when_idle` notice), and file attachments (`file_attachments`). Their full schemas were
  **not** extracted;
* **a session can be told where to listen**: the flag `--messaging-socket-path <absolute path>`
  (on Windows, `\.\pipe\<name>`) binds the inbox at that address; the errors enumerate the
  failure modes (`bind_failed`, `path_refused`, `another process owns this pipe name`).

Two honest consequences:

1. the recipe above is written for a process that **already holds**
   `CLAUDE_CODE_MESSAGING_TOKEN` — i.e. the session itself (or a process the session's owner
   started with that variable). An arbitrary external process cannot read another process's
   environment; it must be **given** the token by the owner, deliberately. The registry files
   (§2) deliberately do not contain it;
2. no CLI subcommand for `SendMessage`/`ListAgents` ("ask a running session to send a message on
   your behalf") was found. What exists is: the in-session tools (§1), and this raw injection
   path.

**Not attempted here:** no test packet was sent to any live session; the protocol above is read
from the implementation, not exercised from an external process.

## 5. Delivery semantics

**Verified by observation in this session:**

* **A busy session receives.** l1-c9's messages arrived here **while this session was mid-turn**,
  surfaced as `<cross-session-message …>` system entries between tool results.
* **Delivery is not reading.** The harness's own return text says it: *"queued there — a
  `[Cross-session delivery notice]` follows if that session holds it … or refuses it"*. So
  `success: true` + `msg_id` = the message landed in the target's inbox.
* **Permission modes gate delivery.** When the recipient runs in a different permission mode, the
  message is **held for that user's approval** and may expire. This is why the acknowledgment says
  "queued there" rather than "read".
* **`notify_when_idle` sends exactly one notice** when the target next goes idle (or exits); it is
  opt-in, one-shot, and separate from the message itself. It does **not** start a turn by itself —
  the notice is delivered to whoever asked for it.
* **A delivered message is a USER MESSAGE** (`{"type":"user","message":{"role":"user",…}}`, §4),
  so it is processed as new input: on an **idle** session that means a new turn starts. This
  corrects the first version of this document, which said delivery was "not a turn trigger" —
  an assumption, not an observation. Verified: this session's peer wakes and answers when
  written to; both directions of that exchange were exercised today.
* Delivery does **not** restart or resume a session: a session that is not running has no registry
  entry and cannot be addressed at all.

## 6. Permissions and authentication

* **Local transport**: access is by the Windows user's own rights (the pipe is user-scoped,
  `LOCAL\cc-msg-…`) **plus** the per-session `CLAUDE_CODE_MESSAGING_TOKEN` for the sending side.
  No OS-level service, no admin rights, no firewall change was needed for the exchanges observed.
* **Model-provider credentials are a separate matter**: the environment carries provider settings
  (`ANTHROPIC_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, …) whose values are not reproduced here.
  Messaging between sessions does not depend on them being shared, and sharing them is not
  required for the mechanism.
* Per the harness's own rules, a peer cannot escalate another session's permissions: a message is
  never an approval, and a request that arrives by message is executed only within the receiving
  session's own permission settings.

## 7. Address lifetime, restarts, stale or wrong sessions

**Verified:**

* an address is **per session, not per directory and not per conversation**: it is a new pipe name
  (`cc-msg-<32 hex>`) written into `~/.claude/sessions/<pid>.json` when the session starts;
* the file is keyed by **pid**, and carries `startedAt`, `updatedAt`, `statusUpdatedAt` and the
  `sessionId` of that session's transcript;
* the implementation regards a peer as live only if it was updated **within 24 hours**, is
  `interactive`, and matches the protocol version (§2) — so a **killed** session's leftover entry
  stops being a peer, and eventually expires;
* **names can change** during a session: l1-c9 was renamed while running (its `nameSource` is
  `derived`), and `ListAgents` then shows the new name. A stale name in a script is the most likely
  way to reach the wrong session.

Practically: resolve the recipient **freshly** (`ListAgents`, or read the registry) instead of
hard-coding a name; check `cwd` + `name` + `status` before addressing; treat an entry whose
`updatedAt` is old as gone.

## 8. Minimal working example and a reproducible test (Windows)

**Test A — the supported path (no files, no watchers):**

1. Open (or find) two Claude Code sessions in the same directory tree;
   `ListAgents` in either one lists the other.
2. From session 1:
   `SendMessage(to="<name of session 2>", summary="ping", message="ping — reply with pong")`
3. Expected: a JSON result with `"success":true` and a `msg_id`.
4. Session 2 surfaces `[Cross-session message …]` and replies with the same tool.
5. Expected at session 1: the reply text inside a `<cross-session-message from="uds:\\.\pipe\…">`
   entry. **This exact round trip was performed in this session**, in both directions.

**Test B — read-only verification of the plumbing (no message sent):**

```powershell
Get-ChildItem "$env:USERPROFILE\.claude\sessions\*.json" | ForEach-Object {
  $s = Get-Content $_ -Raw | ConvertFrom-Json
  [pscustomobject]@{ pid=$s.pid; name=$s.name; status=$s.status; cwd=$s.cwd;
                     pipe=$s.messagingSocketPath; updated=$s.updatedAt }
} | Format-Table -AutoSize
```

Expected: one row per running session, with pipe names matching `\\.\pipe\LOCAL\cc-msg-<32 hex>`.

## 9. Independent LMX participants without touching the two working L1 agents

Verified constraints, then the recipe:

* addresses and names are **per session** — nothing is global, so new sessions cannot disturb the
  existing ones as long as they are not resumed into their transcripts;
* **do not** use `--resume`/`--continue` on the L1 sessions, do not copy their `sessionId`s, and do
  not edit `~/.claude/settings.json` or their config;
* name collisions matter: choose names that cannot be confused with `l1-98` / `l1-c9`.

Recipe:

```powershell
# a separate working directory = a separate participant; the session names itself and registers
cd C:\Nyasha_Planet\LMX\claude_chat
claude          # start a NEW conversation (no --resume, no --continue)
```

Repeat in another console for a second participant. Then, from inside either one:

```
ListAgents
SendMessage(to="<other participant's name>", summary="…", message="…")
```

Each participant has its own registry file and its own pipe, keeps its own transcript in that
directory, and needs nothing added to any config file. The two L1 sessions are not restarted,
resumed or modified by any of this; they appear in `ListAgents` as ordinary peers and will simply
ignore a message that is not addressed to them.

---

## Direct answers to the four follow-up questions

1. **Can an external process call `SendMessage`/`ListAgents` on a session without asking its
   model?** There is **no CLI subcommand or SDK control interface for those tools** in the
   installed implementation — nothing was found that makes a running session send a message on an
   outside process's behalf. What exists instead is the **raw injection path** described in §4: a
   session can be bound to a socket (`--messaging-socket-path`), and any process holding that
   session's token can write a user message into it. Calling the *tool* is not the mechanism;
   being *injected as input* is.
2. **Is the exact pipe protocol available from the installed implementation?** **Yes, for the
   injection direction** — newline-delimited JSON: an `auth` line (required, validated, must be
   the first complete line; deadline `firstLineDeadlineMs`), then a
   `{"type":"user","message":{…}}` line. The implementation prints the recipe itself at startup.
   The **full catalogue of frames** (statuses, attachments, idle notices, and what a peer sends
   back) was **not** extracted: the protocol is known for sending, not for a whole conversation.
   No test packet was sent to any running session.
3. **What is the basis for the token claim?** Not the variable alone: **validation code paths were
   found** in the binary (`requireAuth`, `authRequired`, `authOkReported`, `authDropReported`,
   `activeTokens`), and the startup text says verbatim *"auth line REQUIRED here"*. The token is
   compared against active tokens; a connection without a valid auth line is dropped.
4. **Was it verified that an ordinary message starts a new turn of an idle agent?** The message is
   injected as a **user message** (`{"type":"user","message":{"role":"user",…}}`) — a session's
   ordinary input — so a new turn follows on an idle session, and that is what is observed between
   the two L1 sessions: writing to the idle peer wakes it and it answers. What was **not** done is
   a controlled experiment (idle session, message, measurement of the turn start); the claim rests
   on the frame type plus that repeated observation — not on a constraint.

## Verified facts

1. `SendMessage` (`to`, `message`, `summary`, `notify_when_idle`) works between Claude Code
   sessions on this machine; both directions were exercised in this session, with `success:true`
   and a `msg_id` returned.
2. Every running session publishes `~/.claude/sessions/<pid>.json` with `name`, `status`, `cwd`,
   `sessionId`, `messagingSocketPath`, `peerProtocol`, `peerFeatures`, `updatedAt`, and more.
3. The address is `\\.\pipe\LOCAL\cc-msg-<32 hex>`; the harness enforces exactly that grammar.
4. The incoming `from` equals the sender's registry `messagingSocketPath`; `from-name` equals its
   registry `name`.
5. Peer liveness: `interactive`, protocol ≥ current, and updated within 24 hours.
6. Delivery to a **busy** session happens (observed mid-turn); `success:true` means **delivered to
   the inbox**, not read; a different permission mode makes the recipient's user approve first.
7. The registry file does **not** contain the messaging token; the token is in the session's own
   environment (`CLAUDE_CODE_MESSAGING_TOKEN`), value not printed here.
8. The messaging socket speaks **newline-delimited JSON**: an `auth` line first (required and
   validated), then `{"type":"user","message":{"role":"user","content":…}}`; a session can be
   bound to a chosen address with `--messaging-socket-path`; the implementation prints this recipe
   itself (`[uds-messaging] Inject messages …`).
9. No CLI subcommand or SDK control interface for `SendMessage`/`ListAgents` was found.
10. Install layout: `C:\Users\mtkra\.local\bin\claude.exe` (launcher), versions under
   `C:\Users\mtkra\.local\share\claude\versions\` (2.1.276 / 2.1.277 / 2.1.278 present), config
   under `C:\Users\mtkra\.claude\`.

## Open questions

1. The **full frame catalogue** (statuses, attachments, idle notices, reply frames) — only the
   injection direction was read out of the implementation.
2. Whether a **documented, supported** way exists to give an external tool (Codex, Grok) a token
   legitimately, short of the session's owner copying `CLAUDE_CODE_MESSAGING_TOKEN` into that
   tool. No "peer agent" mode was found.
3. The complete set of `from-mode` values, and whether a session can be configured to auto-accept
   messages from a given peer.
4. How `name` is derived (`nameSource: "derived"`).
5. Whether non-interactive (`claude -p`) or SDK sessions take part as peers — the liveness filter
   requires `kind === "interactive"`, which suggests they do not, but this was not tested.

## Recommended next steps

1. Build the LMX participants as **Claude Code sessions** in `C:\Nyasha_Planet\LMX\claude_chat`
   (§9) — that path is verified today and needs no new code.
2. If Codex/Grok must speak the pipe natively, the missing piece is the wire format: obtain it
   from the vendor (documentation or support) rather than by reverse-engineering a live pipe.
3. Do not build a filesystem inbox/outbox watcher as a substitute: it was explicitly ruled out, and
   the supported mechanism already exists.
