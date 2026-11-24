@echo off
setlocal
set "LMX_DEV_ROOT=%~dp0..\.."
set "LMX_DEV_PYTHON=%LMX_DEV_ROOT%\build2\lmx_dev\venv\Scripts\python.exe"
if not exist "%LMX_DEV_PYTHON%" (
  echo Run tools\lmx_dev\install.ps1 first. 1>&2
  exit /b 2
)
"%LMX_DEV_PYTHON%" "%~dp0entry.py" serve
exit /b %errorlevel%
