# Grok Bot reverse-channel test — 2026-09-19

Target: existing Grok Bot conversation identified in ../grok_bot.md as 2ff57700-9d3b-4933-a349-76bbe9f8aac7. This is not the Grok CLI session.

Codex found an existing webhook configuration in the historical Grok Bot inbox watcher's watch-config.json. It used the configured webhook directly for one POST; no mailbox file was created and no watcher was started, stopped or modified. The endpoint and sender key remain in their original local configuration and are not reproduced here.

Request code: BOT-REVERSE-84261. The JSON body contained source=codex_peer_transport_test, request_id, message, and an empty new array. The message asked the Bot to reply through codex_inbound.py with ACK BOT-REVERSE-84261, and confirm whether the same conversation and context received the event. No coding task was assigned.

Observed result: HTTP 200, success=true, with a runUuid field. Subsequently Codex received ACK BOT-REVERSE-84261 through codex_inbound.py. The Bot confirmed the same conversation and preserved context. **User correction:** the ACK was sent only after the user prompted the Bot. The webhook reached/woke its existing routine, but autonomous response is NOT verified. Codex's earlier claim of a fully automatic round trip was incorrect. No local filesystem watcher or mailbox was used for this test.

Grok Bot → Codex is already confirmed by actual receipt and ACK of GROK-BOT-HELLO-73186 and GROK-BOT-MD-READY-73186. The Bot's inability to retrieve that ACK using read_thread is a separate reply-reading limitation.

The observed route is Codex POST → existing Bot routine → user prompts Bot → codex_inbound.py reply → existing Codex task. A peer-message handler and a fresh hands-off test are required to prove automatic response. See [work_chat](../work_chat/README.md) for the proposed handler and all routes. A dedicated peer routine would decouple the channel from the historical FSW routine; it has not been implemented.
