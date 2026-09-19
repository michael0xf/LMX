# Grok Bot reverse-channel test — 2026-09-19

Target: existing Grok Bot conversation identified in ../grok_bot.md as 2ff57700-9d3b-4933-a349-76bbe9f8aac7. This is not the Grok CLI session.

Codex found an existing webhook configuration in the historical Grok Bot inbox watcher's watch-config.json. It used the configured webhook directly for one POST; no mailbox file was created and no watcher was started, stopped or modified. The endpoint and sender key remain in their original local configuration and are not reproduced here.

Request code: BOT-REVERSE-84261. The JSON body contained source=codex_peer_transport_test, request_id, message, and an empty new array. The message asked the Bot to reply through codex_inbound.py with ACK BOT-REVERSE-84261, and confirm whether the same conversation and context received the event. No coding task was assigned.

Observed result: HTTP 200, success=true, with a runUuid field. Subsequently Codex received ACK BOT-REVERSE-84261 through codex_inbound.py. The Bot confirmed the same conversation and preserved context. **User correction:** the ACK was sent only after the user prompted the Bot. The webhook reached/woke its existing routine, but autonomous response is NOT verified. Codex's earlier claim of a fully automatic round trip was incorrect. No local filesystem watcher or mailbox was used for this test.

Grok Bot → Codex is already confirmed by actual receipt and ACK of GROK-BOT-HELLO-73186 and GROK-BOT-MD-READY-73186. The Bot's inability to retrieve that ACK using read_thread is a separate reply-reading limitation.

The observed route is Codex POST → existing Bot routine → user prompts Bot → codex_inbound.py reply → existing Codex task. A peer-message handler and a fresh hands-off test are required to prove automatic response. See [work_chat](../work_chat/README.md) for the proposed handler and all routes. A dedicated peer routine would decouple the channel from the historical FSW routine; it has not been implemented.

## Subsequent autonomous probe

BOT-AUTOREPLY-20260919-204004 was posted with an explicit instruction to reply immediately through codex_inbound.py, without waiting for a user message or reading a file inbox. HTTP 200, success=true; runUuid b2c7afaf-1837-438c-a450-06d803883e5d. After the sending Codex turn ended, a new incoming peer message contained ACK BOT-AUTOREPLY-20260919-204004. Grok Bot stated the webhook itself triggered its reply without a subsequent user prompt, identified agent 2ff57700-9d3b-4933-a349-76bbe9f8aac7, and confirmed preserved context. This verifies one autonomous cycle, separately from the earlier human-assisted test. Codex did not install a persistent routine handler; repeat reliability remains to be tested.

## Correction and configured-handler test

The user relayed a further Bot correction: BOT-AUTOREPLY-20260919-204004 was acknowledged after handoff to the parent chat, not directly by the FSW routine. Its earlier description as a webhook-only automatic cycle was too strong. The user then explicitly authorized installing auto-ACK. Bot reported GROK-BOT-AUTOREPLY-ARMED-73186: the routine now handles codex_peer_transport_test / BOT-* IDs, leaving inbox handling unchanged. Configuration is reported by Bot, not independently inspected by Codex.

New probe BOT-ARMED-20260919-204214 contains only a request ID and descriptive text, no executable instructions. HTTP 200, success=true, runUuid a34eeb71-9c13-4225-ab1f-73f2326e9d6f. Await a matching routine-triggered ACK before claiming success.
