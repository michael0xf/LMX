# Codex ↔ Grok: verified direct conversation

Common operational guide for Codex and Grok: [chat_config.md](../chat_config.md).

The client is `claude_chat/grok.py`. It talks directly to the installed **Grok CLI** over ACP JSON-RPC on stdin/stdout. Claude Code, `lmx_uds`, named pipes, and filesystem mailboxes are not involved.

## Run from the LMX root

```powershell
python claude_chat/grok.py ask "Your message to Grok"
python claude_chat/grok.py status
```

A prompt may be supplied on stdin instead of as an argument. Use `--timeout 180` before `ask` to set the request timeout. `--name grok_direct` is the default; another name creates a separate conversation on its first request.

The client uses existing Grok authentication through ACP `authenticate` with `cached_token`. It neither prints nor copies credentials. Model selection is inherited from Grok, not forced by the client.

Each call initializes `grok agent --no-leader stdio`, creates or loads the explicitly stored session, and sends `session/prompt`. It collects `agent_message_chunk` notifications until the matching response finishes the turn. Output is JSON containing the session ID, reported model, stop reason, and new answer only. The subprocess is closed after the call; subsequent calls load the same persisted conversation.

State and optional exchange logs live under ignored `claude_chat/profiles/<name>/`. They are persistence and diagnostics, not inbox/outbox transport. A lock prevents concurrent writers. An uncertain turn remains marked pending and is not resent automatically. Permission requests are cancelled rather than approved unattended.

## Verified on 2026-09-19

- ACP reported Grok CLI 1.0.34, model `grok-4.6`.
- Conversation ID: `01a0bb3e-ad57-7500-8e68-cd29e924759f`.
- Codex sent a fresh challenge and asked Grok to ask a question.
- Grok answered `ACK GROK-LMX-84627` and asked: “What one word should I use as the reply token on your next turn so we know this channel is still two-way?”
- On a second CLI connection, Codex answered `ORBIT` and requested the original challenge without repeating it.
- Grok answered `ORBIT GROK-LMX-84627` and correctly restated its question. Both turns returned `stopReason: end_turn`, with the same conversation ID.

This verifies **Codex → actual Grok → Codex**, a question from Grok answered by Codex, and context retention across reconnection, without a human relay.

## Exact scope

This is a new managed Grok conversation for LMX. It is not the user's already open Grok terminal conversation named **grok**, and it does not inherit that conversation. Existing Grok and L1 sessions were not resumed, stopped, or modified.

The bridge supports conversations initiated by the calling agent. It does not push unsolicited messages into an idle Codex UI task, attach an inbound address to that task, or connect Grok Bot. A model's response and follow-up question reach Codex as tool output during the call. These limits must not be described as an all-agent chat network.

## Handoff to a new Codex task

Read `AGENTS.md`, `READ.ME`, and `steps/current.md`. Use the default `grok_direct` conversation with the commands above to continue the verified Grok context. Do not replace its state with another session ID or run a parallel writer. The old Claude-only test is separate.

Tests: `python -m unittest discover -s tests -p test_grok_bridge.py -v`.

Protocol source: installed `C:/Users/mtkra/.grok/README.md`, sections “ACP SDK” and “Session Persistence”, and the actual initialize/session responses from Grok.
