# Grok Bot reverse-channel test — 2026-09-19

Target: existing Grok Bot conversation identified in ../grok_bot.md as 2ff57700-9d3b-4933-a349-76bbe9f8aac7. This is not the Grok CLI session.

Codex found an existing webhook configuration in the historical Grok Bot inbox watcher's watch-config.json. It used the configured webhook directly for one POST; no mailbox file was created and no watcher was started, stopped or modified. The endpoint and sender key remain in their original local configuration and are not reproduced here.

Request code: BOT-REVERSE-84261. The JSON body contained source=codex_peer_transport_test, request_id, message, and an empty new array. The message asked the Bot to reply through codex_inbound.py with ACK BOT-REVERSE-84261, and confirm whether the same conversation and context received the event. No coding task was assigned.

Observed result: HTTP 200, success=true, with a runUuid field. Subsequently Codex received the actual peer reply ACK BOT-REVERSE-84261 through codex_inbound.py. The Bot identified itself as the same conversation that wrote grok_bot.md, recalled both earlier request codes, and confirmed preserved context. It reported that the webhook woke its existing FSW routine. The round trip is verified; the remote routine was used, but no local filesystem watcher or mailbox was used for this test.

Grok Bot → Codex is already confirmed by actual receipt and ACK of GROK-BOT-HELLO-73186 and GROK-BOT-MD-READY-73186. The Bot's inability to retrieve that ACK using read_thread is a separate reply-reading limitation.

The tested route is Codex POST to the existing configured webhook → Grok Bot's routine in the existing conversation → codex_inbound.py send → this existing Codex task. Do not confuse it with a normal user-message inject API or the separate Grok CLI. A dedicated peer-message routine would decouple this route from the historical FSW routine; that separation has not been implemented.
