# Grok Bot reverse-channel test — 2026-09-19

Target: existing Grok Bot conversation identified in ../grok_bot.md as 2ff57700-9d3b-4933-a349-76bbe9f8aac7. This is not the Grok CLI session.

Codex found an existing webhook configuration in the historical Grok Bot inbox watcher's watch-config.json. It used the configured webhook directly for one POST; no mailbox file was created and no watcher was started, stopped or modified. The endpoint and sender key remain in their original local configuration and are not reproduced here.

Request code: BOT-REVERSE-84261. The JSON body contained source=codex_peer_transport_test, request_id, message, and an empty new array. The message asked the Bot to reply through codex_inbound.py with ACK BOT-REVERSE-84261, and confirm whether the same conversation and context received the event. No coding task was assigned.

Observed result: HTTP 200, success=true, with a runUuid field. This proves webhook acceptance only. At the time of writing, no correlated reply has arrived in Codex. The webhook's association with the desired conversation has not been independently confirmed; do not label the reverse channel verified until the Bot replies and confirms identity/context.

Grok Bot → Codex is already confirmed by actual receipt and ACK of GROK-BOT-HELLO-73186 and GROK-BOT-MD-READY-73186. The Bot's inability to retrieve that ACK using read_thread is a separate reply-reading limitation.

Next: inspect the Bot's reply if it arrives. If the existing routine discards the message body or targets another execution context, obtain a dedicated peer-message webhook through the Bot's own supported routine setup rather than changing the historical watcher.
