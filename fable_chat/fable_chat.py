#!/usr/bin/env python3
r"""
fable_chat.py — агент fable_chat на Claude Agent SDK (модель Fable 5.1),
работающий за счёт API-кредитов.

Рабочая копия: C:\claude\new\fable_chat.py (с ключом).
Прототип в git: fable_chat/fable_chat.py (с заглушкой вместо ключа).

1) Интерактивный чат в терминале (с памятью диалога):
       C:\claude\new\fable_chat.bat
       python C:\claude\new\fable_chat.py --model claude-sonnet-5

2) Через почтальона lmx_uds (см. for_lmx_uds_about_fable_chat.md в LMX):
       python C:\claude\new\fable_chat.py --session relay --prompt-file msg.txt --out reply.txt
   Ответ печатается на stdout и, с --out, пишется в файл (UTF-8).
   -p TEXT — запрос строкой; -p - — запрос со stdin.
   --session NAME хранит id разговора в profiles\NAME\session.json рядом со
   скриптом, так что следующий вызов с тем же NAME продолжает тот же диалог.
   --new начинает разговор NAME заново. Код выхода 1 — ошибка API/модели.

Рабочая папка агента по умолчанию — корень LMX (C:\Nyasha_Planet\LMX),
переопределяется --cwd или переменной FABLE_CHAT_CWD. Файл for_fable_chat.md
из рабочей папки дописывается к системному промпту на каждом запросе.

Установка:
       pip install claude-agent-sdk
"""

import argparse
import asyncio
import json
import os
import sys
from pathlib import Path

# ======================================================================
# ВСТАВЬТЕ СЮДА API-КЛЮЧ из привязанной организации Console (workspace-scope)
ANTHROPIC_API_KEY = "sk-ant-ВСТАВЬТЕ_КЛЮЧ"
# ======================================================================

DEFAULT_MODEL = "claude-fable-5-1"

# Рабочая папка агента по умолчанию — корень проекта LMX.
DEFAULT_CWD = os.environ.get("FABLE_CHAT_CWD", r"C:\Nyasha_Planet\LMX")

# Инструкция агенту: файл в рабочей папке, дописывается к системному промпту.
INSTRUCTIONS_NAME = "for_fable_chat.md"

# Режим разрешений по умолчанию: bypassPermissions — любой инструмент
# без подтверждения (спросить разрешения всё равно не у кого).
DEFAULT_MODE = "bypassPermissions"

# Сохранённые разговоры для --session.
PROFILES = Path(__file__).resolve().parent / "profiles"

# Ответы на русском не должны падать на кодировке консоли или канала.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass

# Ключ ставим в окружение ТОЛЬКО этого процесса — системные настройки
# и ваш Claude Code с подпиской не затрагиваются.
if ANTHROPIC_API_KEY.startswith("sk-ant-") and "ВСТАВЬТЕ" not in ANTHROPIC_API_KEY:
    os.environ["ANTHROPIC_API_KEY"] = ANTHROPIC_API_KEY
else:
    sys.exit("Впишите API-ключ в переменную ANTHROPIC_API_KEY в начале fable_chat.py")

from claude_agent_sdk import (  # noqa: E402
    AssistantMessage,
    ClaudeAgentOptions,
    ClaudeSDKClient,
    ResultMessage,
    TextBlock,
    ToolUseBlock,
)


def _system_prompt(cwd):
    """Системный промпт Claude Code плюс for_fable_chat.md, если он есть."""
    path = Path(cwd) / INSTRUCTIONS_NAME
    if not path.is_file():
        print(f"  ! нет {path}: агент работает без инструкции fable_chat",
              file=sys.stderr)
        return {"type": "preset", "preset": "claude_code"}
    # snapshot=False: правки инструкции действуют и в продолжаемом разговоре.
    return {"type": "preset", "preset": "claude_code",
            "append": path.read_text(encoding="utf-8"), "snapshot": False}


def _options(cwd, model, tools, permission_mode, resume):
    cwd = cwd or DEFAULT_CWD
    return ClaudeAgentOptions(
        cwd=cwd,
        model=model or DEFAULT_MODEL,
        allowed_tools=tools or [],
        system_prompt=_system_prompt(cwd),
        permission_mode=permission_mode or DEFAULT_MODE,
        # id разговора из прошлого запуска; None — новый разговор.
        resume=resume,
    )


def _session_file(session):
    if not session.replace("_", "").replace("-", "").isalnum():
        sys.exit("--session: только буквы, цифры, _ и -")
    return PROFILES / session / "session.json"


def load_session(session):
    """Сохранённый session_id для --session NAME, или None."""
    path = _session_file(session)
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8")).get("session_id")
    except (OSError, ValueError):
        return None


def save_session(session, session_id):
    path = _session_file(session)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({"session_id": session_id}, indent=2) + "\n",
                    encoding="utf-8")


class Agent:
    """Агент с памятью диалога. Используйте через `async with`."""

    def __init__(self, cwd=None, model=None, tools=None,
                 permission_mode=DEFAULT_MODE,
                 verbose=False, session=None, new=False):
        # session — имя сохранённого разговора (см. --session); new — начать заново.
        self.session = session
        resume = None if (new or not session) else load_session(session)
        self.opts = _options(cwd, model, tools, permission_mode, resume)
        self.verbose = verbose
        self.total_cost = 0.0
        self.session_id = resume
        self.error = None
        self._client = None

    async def __aenter__(self):
        self._client = ClaudeSDKClient(options=self.opts)
        await self._client.connect()
        return self

    async def __aexit__(self, *exc):
        await self._client.disconnect()

    async def send(self, prompt: str) -> str:
        """Отправить сообщение, дождаться окончания работы агента, вернуть текст ответа."""
        self.error = None
        await self._client.query(prompt)
        parts = []
        async for msg in self._client.receive_response():
            if isinstance(msg, AssistantMessage):
                for block in msg.content:
                    if isinstance(block, TextBlock):
                        parts.append(block.text)
                    elif isinstance(block, ToolUseBlock):
                        # Ответ — только текст после последнего вызова
                        # инструмента; промежуточные реплики не пересылаются.
                        parts = []
                        if self.verbose:
                            print(f"  ⚙ {block.name}", file=sys.stderr)
            elif isinstance(msg, ResultMessage):
                cost = getattr(msg, "total_cost_usd", None) or 0.0
                self.total_cost += cost
                if self.verbose:
                    print(f"  💲 ${cost:.4f} (сессия: ${self.total_cost:.4f})",
                          file=sys.stderr)
                if getattr(msg, "is_error", False):
                    self.error = getattr(msg, "result", None) or "ошибка без текста"
                sid = getattr(msg, "session_id", None)
                if sid and self.session and sid != self.session_id:
                    self.session_id = sid
                    save_session(self.session, sid)
        return "\n".join(parts).strip()


async def _once(prompt, args):
    async with Agent(cwd=args.cwd, model=args.model,
                     permission_mode=args.mode, verbose=True,
                     session=args.session, new=args.new) as agent:
        reply = await agent.send(prompt)
        return reply, agent.error


async def _repl(args):
    print(f"fable_chat · модель {args.model} · папка {args.cwd}"
          + (f" · сессия {args.session}" if args.session else ""))
    print("Пустая строка + Enter — отправить многострочный ввод; /exit — выход\n")
    async with Agent(cwd=args.cwd, model=args.model,
                     permission_mode=args.mode, verbose=True,
                     session=args.session, new=args.new) as agent:
        while True:
            lines = []
            prompt_mark = "› "
            while True:
                try:
                    line = input(prompt_mark)
                except (EOFError, KeyboardInterrupt):
                    print(f"\nИтого потрачено: ${agent.total_cost:.4f}")
                    return
                if line.strip() == "/exit":
                    print(f"Итого потрачено: ${agent.total_cost:.4f}")
                    return
                if line == "" and lines:
                    break
                if line == "" and not lines:
                    continue
                lines.append(line)
                prompt_mark = "  "
            reply = await agent.send("\n".join(lines))
            print(f"\n{reply}\n")


def main():
    p = argparse.ArgumentParser(description="fable_chat: агент на Claude Agent SDK (за счёт API-кредитов)")
    p.add_argument("--cwd", default=DEFAULT_CWD, help="рабочая папка агента (по умолчанию корень LMX)")
    p.add_argument("--model", default=DEFAULT_MODEL)
    p.add_argument("--mode", default=DEFAULT_MODE,
                   choices=["default", "acceptEdits", "bypassPermissions", "plan"],
                   help="режим разрешений (по умолчанию bypassPermissions: всё без вопросов)")
    p.add_argument("-p", "--prompt", help="разовый запрос без интерактива; '-' — читать со stdin")
    p.add_argument("--prompt-file", metavar="PATH", help="разовый запрос из файла (UTF-8)")
    p.add_argument("--out", metavar="PATH", help="записать ответ ещё и в файл (UTF-8)")
    p.add_argument("--session", metavar="NAME",
                   help="продолжать сохранённый разговор NAME (profiles/NAME/ рядом со скриптом)")
    p.add_argument("--new", action="store_true",
                   help="начать разговор --session заново, забыв сохранённый")
    args = p.parse_args()

    prompt = None
    if args.prompt_file:
        prompt = Path(args.prompt_file).read_text(encoding="utf-8-sig")
    elif args.prompt == "-":
        prompt = sys.stdin.buffer.read().decode("utf-8-sig")
    elif args.prompt:
        prompt = args.prompt

    if prompt is None:
        asyncio.run(_repl(args))
        return
    if not prompt.strip():
        sys.exit("Пустой запрос")
    reply, error = asyncio.run(_once(prompt, args))
    if args.out:
        Path(args.out).parent.mkdir(parents=True, exist_ok=True)
        Path(args.out).write_text(reply + "\n", encoding="utf-8", newline="\n")
    print(reply)
    if error:
        print(f"fable_chat: ошибка: {error}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
