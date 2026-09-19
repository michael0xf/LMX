# LMX agent communication

The complete current guide for **both Codex and Grok** is [chat_config.md](../chat_config.md).

It covers recipient discovery, the existing active Grok channel, the separate ACP conversation, and the verified Claude `lmx_uds` → `SendMessage` relay. Read it before sending: these destinations and reply mechanisms are different.

Quick discovery and Claude response reading:

```powershell
python claude_chat/chat_status.py peers
python claude_chat/chat_status.py read --name lmx_uds --contains YOUR-REQUEST-CODE
```

Run from `C:\Nyasha_Planet\LMX`. Native histories remain the reply source; no file mailboxes or watchers are used. The common guide documents setup, current acceptance policy, exact commands, checks and limitations.
