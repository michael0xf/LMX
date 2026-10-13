@echo off
rem work_chat_cli — ОБЫЧНАЯ сессия Claude Code (не work_chat.py), оплачиваемая
rem API-кредитами Console: ключ ставится в окружение только этого процесса.
rem Это проверка пути "просто claude с ANTHROPIC_API_KEY": если он работает, сессия
rem становится полноценным пиром по имени work_chat (ListAgents / SendMessage у
rem lmx_uds, fable_pc и др.), и клиент work_chat.py для почтальона не нужен.
rem Без --remote-control: Remote Control требует логин claude.ai, с API-ключом
rem он не работает; локальные пиры и именной pipe от этого не зависят.
rem Что проверить после старта:
rem   /status  — в строке авторизации должен быть API key (Console), не подписка;
rem   если CLI спросит, использовать ли ключ из окружения, — ответить да;
rem   в другой сессии ListAgents должен показать work_chat.
rem Usage: work_chat_cli.bat [additional claude arguments...]
cd /d C:\Nyasha_Planet\LMX
setlocal
chcp 65001 >nul
set CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
rem ===== ВСТАВЬТЕ КЛЮЧ из привязанной организации Console (тот же, что в work_chat.py) =====
set "ANTHROPIC_API_KEY=sk-ant-ВСТАВЬТЕ_КЛЮЧ"
rem =====================================================================================
if "%ANTHROPIC_API_KEY:ВСТАВЬТЕ=%" neq "%ANTHROPIC_API_KEY%" echo Впишите ANTHROPIC_API_KEY в work_chat_cli.bat 1>&2 & exit /b 1
rem Real executable, not the wrapper in C:\claude (same as fable.bat).
set "WC_EXE=%USERPROFILE%\.local\bin\claude.exe"
if defined LMX_CLAUDE_EXE set "WC_EXE=%LMX_CLAUDE_EXE%"
if not exist "%WC_EXE%" echo Claude executable not found at "%WC_EXE%". Set LMX_CLAUDE_EXE.1>&2
if not exist "%WC_EXE%" exit /b 1
set "WC_NAME=work_chat"
if defined LMX_WORK_CHAT_NAME set "WC_NAME=%LMX_WORK_CHAT_NAME%"
set "WC_MODEL=claude-sonnet-4-5"
if defined LMX_WORK_CHAT_MODEL set "WC_MODEL=%LMX_WORK_CHAT_MODEL%"
"%WC_EXE%" --model "%WC_MODEL%" --name "%WC_NAME%" %*
endlocal
