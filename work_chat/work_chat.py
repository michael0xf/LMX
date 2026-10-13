#!/usr/bin/env python3
r"""
work_chat.py — простой агент на Claude Agent SDK, работающий за счёт API-кредитов.

Два способа использования:

1) Интерактивный чат в терминале (с памятью диалога):
       python work_chat.py
       python work_chat.py --cwd ../some_repo --model claude-sonnet-5

2) Как библиотека из своего кода:
       from work_chat import ask, Agent
       print(ask("Найди все TODO в проекте и сгруппируй по файлам"))

       async with Agent(cwd="../repo") as a:
           print(await a.send("Прочитай README"))
           print(await a.send("Теперь предложи план рефакторинга"))

3) Через почтальона lmx_uds (как codex_inbound.py / grok.bat): lmx_uds
   запускает из корня LMX
       python C:\claude\new\work_chat.py --session relay -p "From lmx_uds. Request X. ..."
   и получает ответ на stdout. --session NAME хранит id разговора в
   C:\claude\new\profiles\NAME\session.json, так что следующий -p с тем же NAME
   продолжает тот же диалог. Без --session каждый -p — новая сессия.
   --new сбрасывает сохранённый разговор.

Установка:
       pip install claude-agent-sdk
   (SDK использует Claude Code CLI под капотом; если его нет: npm i -g @anthropic-ai/claude-code)
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

# Модель по умолчанию. Sonnet — разумный баланс цена/качество для кредитов.
DEFAULT_MODEL = "claude-fable-5-1"

# Рабочая папка агента по умолчанию — папка, где лежит скрипт.
DEFAULT_CWD = str(Path(__file__).resolve().parent)

# Какие инструменты агенту разрешены без вопросов.
DEFAULT_TOOLS = ["Read", "Write", "Edit", "Glob", "Grep", "Bash"]

# Сохранённые разговоры для --session (папка в .gitignore).
PROFILES = Path(__file__).resolve().parent / "profiles"

# Ключ ставим в окружение ТОЛЬКО этого процесса — системные настройки
# и ваш Claude Code с подпиской не затрагиваются.
if ANTHROPIC_API_KEY.startswith("sk-ant-") and "ВСТАВЬТЕ" not in ANTHROPIC_API_KEY:
    os.environ["ANTHROPIC_API_KEY"] = ANTHROPIC_API_KEY
else:
    sys.exit("Впишите API-ключ в переменную ANTHROPIC_API_KEY в начале work_chat.py")

from claude_agent_sdk import (  # noqa: E402
    AssistantMessage,
    ClaudeAgentOptions,
    ClaudeSDKClient,
    ResultMessage,
    TextBlock,
    ToolUseBlock,
)


def _options(cwd, model, tools, system_prompt, permission_mode, resume):
    return ClaudeAgentOptions(
        cwd=cwd or DEFAULT_CWD,
        model=model or DEFAULT_MODEL,
        allowed_tools=tools if tools is not None else DEFAULT_TOOLS,
        system_prompt=system_prompt,
        # "acceptEdits" — правки файлов без подтверждения;
        # "default" — спрашивать; "bypassPermissions" — вообще без вопросов (осторожно).
        permission_mode=permission_mode,
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
                 system_prompt=None, permission_mode="acceptEdits",
                 verbose=False, session=None, new=False):
        # session — имя сохранённого разговора (см. --session); new — начать заново.
        self.session = session
        resume = None if (new or not session) else load_session(session)
        self.opts = _options(cwd, model, tools, system_prompt, permission_mode, resume)
        self.verbose = verbose
        self.total_cost = 0.0
        self.session_id = resume
        self._client = None

    async def __aenter__(self):
        self._client = ClaudeSDKClient(options=self.opts)
        await self._client.connect()
        return self

    async def __aexit__(self, *exc):
        await self._client.disconnect()

    async def send(self, prompt: str) -> str:
        """Отправить сообщение, дождаться окончания работы агента, вернуть текст ответа."""
        await self._client.query(prompt)
        parts = []
        async for msg in self._client.receive_response():
            if isinstance(msg, AssistantMessage):
                for block in msg.content:
                    if isinstance(block, TextBlock):
                        parts.append(block.text)
                    elif isinstance(block, ToolUseBlock) and self.verbose:
                        print(f"  ⚙ {block.name}", file=sys.stderr)
            elif isinstance(msg, ResultMessage):
                cost = getattr(msg, "total_cost_usd", None) or 0.0
                self.total_cost += cost
                if self.verbose:
                    print(f"  💲 ${cost:.4f} (сессия: ${self.total_cost:.4f})",
                          file=sys.stderr)
                sid = getattr(msg, "session_id", None)
                if sid and self.session and sid != self.session_id:
                    self.session_id = sid
                    save_session(self.session, sid)
        return "\n".join(parts).strip()


def ask(prompt: str, **kwargs) -> str:
    """Разовый запрос без памяти: ask("...") -> str. kwargs как у Agent."""
    async def _run():
        async with Agent(**kwargs) as a:
            return await a.send(prompt)
    return asyncio.run(_run())


async def _repl(args):
    print(f"work_chat · модель {args.model} · папка {args.cwd}"
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
    p = argparse.ArgumentParser(description="Агент на Claude Agent SDK (за счёт API-кредитов)")
    p.add_argument("--cwd", default=DEFAULT_CWD, help="рабочая папка агента")
    p.add_argument("--model", default=DEFAULT_MODEL)
    p.add_argument("--mode", default="acceptEdits",
                   choices=["default", "acceptEdits", "bypassPermissions", "plan"],
                   help="режим разрешений")
    p.add_argument("-p", "--prompt", help="разовый запрос без интерактива")
    p.add_argument("--session", metavar="NAME",
                   help="продолжать сохранённый разговор NAME (profiles/NAME/ рядом со скриптом)")
    p.add_argument("--new", action="store_true",
                   help="начать разговор --session заново, забыв сохранённый")
    args = p.parse_args()

    if args.prompt:
        print(ask(args.prompt, cwd=args.cwd, model=args.model,
                  permission_mode=args.mode, verbose=True,
                  session=args.session, new=args.new))
    else:
        asyncio.run(_repl(args))


if __name__ == "__main__":
    main()
