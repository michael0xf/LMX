# Inbound messages to the existing Codex task

Закрыто 2026-09-26: Codex нет. Канал не использовать. Откроем заново, когда Codex снова будет. Код клиента на диске остаётся.

Client: `codex_inbound.py`. Grok and user-authorized Claude peers can call it from the LMX root. It uses the installed bundled codex-app-tools MCP adapter and its native send_message_to_thread tool. It does not create another task, launch another model, change model/effort, or type into the UI.

## Bind inside the intended Codex task

```powershell
python claude_chat/codex_inbound.py bind
python claude_chat/codex_inbound.py status
```

Binding reads this task's CODEX_THREAD_ID and CODEX_APP_TOOLS_PIPE_PATH environment variables. Local connection data stays in ignored claude_chat/profiles/codex_inbound/connection.json. Current target: 01a092e9-eb6e-7d61-8880-c0f88197317a. After an app restart, rebind to refresh the pipe. A new task must bind itself explicitly if it is to replace the recipient.

## Send from Grok

```powershell
python claude_chat/codex_inbound.py send --sender Grok --request-id GROK-CODEX-001 "Your message"
python claude_chat/codex_inbound.py read
```

Messages are labelled as peer-authored, not direct user approval. Sender labels are descriptive, not authenticated identities. Normal recipient permissions apply. This is a same-Windows-user integration, not a network service.

Tool success means app acceptance, not a model response. Read the actual reply and correlate its request code. Request IDs are not server-side deduplication keys; do not automatically resend after uncertain failures.

To wait for an idle task before sending once:

```powershell
python claude_chat/codex_inbound.py send --sender Grok --request-id GROK-IDLE-001 --wait-idle 300 "Reply ACK GROK-IDLE-001"
```

This polls status every three seconds for a bounded period; it is not a persistent watcher or filesystem mailbox. Idle observation and sending are not atomic, so user activity can race them. Without the option, the app handles delivery to an active task. Do not interrupt tasks to force a test. Any background helper on Windows should use Start-Process -WindowStyle Hidden.

## Verification status

Grok Bot subsequently sent GROK-BOT-HELLO-73186 and GROK-BOT-MD-READY-73186; Codex received and acknowledged both. The Bot's read_thread calls returned empty items, so the read command is not a reliable source of answer text on this build. Do not mistake that for failed delivery. Use an explicit reply endpoint where available. All-agent routes and current limitations: [work_chat](../work_chat/README.md).

INBOUND-ACTIVE-52916 arrived in this same running Codex task through the client as native incoming delegation. This proves active-turn delivery.

CODEX-IDLE-WAKE-68143 then verified idle wakeup: a separate hidden local process waited for idle, sent once through the client, and the message started a new turn in the same Codex task after its previous final response. No keyboard input was used. The sender was the local LMX test process, not Grok. Grok can invoke the identical client, but a Grok-originated test was not run because its console input was nonempty; the console adapter refused to touch it. Do not confuse verified receiver wakeup with verification of the sender's environment.

## Implementation source and limitations

The installed codex-app-tools/0.1.4/server.mjs and live MCP tools/list schemas define this version-specific adapter. A default app-server proxy endpoint was unavailable here; starting another app server would not connect to this task. The public [App Server lifecycle documentation](https://developers.openai.com/es-419/docs/app-server) describes turns generally; the desktop MCP route is verified locally, not claimed as a stable public endpoint.
