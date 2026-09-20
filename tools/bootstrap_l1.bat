@echo off
rem L1 bootstrap for a NEW HOST -- the Windows twin of tools\bootstrap_l1.sh.
rem Method ported (not code) from lingvamyxa_old_worked_version\buildCore.lm0.bat: derive the repo
rem from the script's own location, let every tool be overridden (LM_CC / LM_AR / LM_RANLIB),
rem pick the thread provider explicitly, pass C99 and the platform feature define.  What is NOT
rem ported: their generated sources and their link set -- the old `trans` was linked from
rem libparser.a + libown.a, while the present translator is AMALGAMATED (lm1\build\l1trans.lm1.c),
rem so linking those libraries again would duplicate symbols.  This script compiles B0 out of the
rem tracked C and nothing else; tools\run_self_build.ps1 then drives B0 -> pass1/B1 -> pass2/B2 ->
rem pass3 and checks the fixed point.  Scope, said plainly: L1 (translator) only -- NOT the L2
rem kernel, NOT the manager chain, and no fallback to any other tree's paths.
rem
rem   tools\bootstrap_l1.bat
rem   set LM_CC=clang & tools\bootstrap_l1.bat
setlocal enabledelayedexpansion

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
cd /d "%ROOT%" || (echo bootstrap_l1.bat: cannot enter "%ROOT%" 1>&2 & exit /b 1)

if not defined LM_CC set "LM_CC=gcc"
if not defined LM_AR set "LM_AR=ar"
if not defined LM_RANLIB set "LM_RANLIB=ranlib"
rem On Windows the native provider is the honest default: this .bat is the Windows entry point.
rem The .sh twin defaults to single and takes win32 only through auto-detection.
if not defined LM_THREAD_PROVIDER set "LM_THREAD_PROVIDER=win32"

if /i "%LM_THREAD_PROVIDER%"=="win32" (
    set "TP_DEF=-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_WIN32"
    set "TP_FLAG="
) else if /i "%LM_THREAD_PROVIDER%"=="single" (
    set "TP_DEF=-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_SINGLE"
    set "TP_FLAG="
) else if /i "%LM_THREAD_PROVIDER%"=="pthread" (
    set "TP_DEF=-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_PTHREAD"
    set "TP_FLAG=-pthread"
) else (
    echo bootstrap_l1.bat: unsupported LM_THREAD_PROVIDER: %LM_THREAD_PROVIDER% 1>&2
    echo Expected one of: pthread, win32, single. 1>&2
    exit /b 1
)

set "SEED=lm1\build\l1trans.lm1.c"
if not exist "%SEED%" (
    echo bootstrap_l1.bat: seed not found: %SEED% 1>&2
    echo It is VERSIONED ^(commit 2d24852^); check "git ls-files lm1/build". 1>&2
    exit /b 1
)

where %LM_CC% >nul 2>&1 || (echo bootstrap_l1.bat: C compiler not found: %LM_CC% 1>&2 & exit /b 1)

rem The stamp: cmd has no date format switch, so take it from wmic-free PowerShell.
for /f %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%D"
set "OUT=build\self_build\bootstrap_%STAMP%"
mkdir "%OUT%" 2>nul

rem Same flags as tools\run_self_build.ps1 uses for B0, so the entry points cannot drift:
rem -I . and -I lm1/build are the PRESENT include roots.
%LM_CC% -std=c99 -Wall -Wextra -Wpedantic ^
    -Werror=incompatible-pointer-types -Werror=discarded-qualifiers ^
    -Werror=implicit-function-declaration -Werror=implicit-int ^
    %TP_DEF% -D_POSIX_C_SOURCE=200809L %TP_FLAG% ^
    -I . -I lm1\build -o "%OUT%\l1trans.exe" "%SEED%"
if errorlevel 1 (
    echo bootstrap_l1.bat: B0 FAILED to build -- do not trust any later pass 1>&2
    exit /b 1
)

echo bootstrap_l1.bat: built %OUT%\l1trans.exe
echo bootstrap_l1.bat: host compiler %LM_CC%; thread provider %LM_THREAD_PROVIDER% (%TP_DEF%)
echo bootstrap_l1.bat: this is B0 only -- run tools\run_self_build.ps1 for the fixed-point cycle

rem SMOKE, not decoration: B0 must at least start on this host.  A usage exit is fine; a crash
rem (>= 0x80000000) is not -- and it is better to hear it here than three passes later.
"%OUT%\l1trans.exe" >nul 2>&1
set "SMOKE=%ERRORLEVEL%"
if %SMOKE% GEQ -1073741819 if %SMOKE% LEQ -1073741819 (
    echo bootstrap_l1.bat: B0 CRASHED -- do not trust the cycle 1>&2
    exit /b 1
)
echo bootstrap_l1.bat: B0 smoke ok (exit %SMOKE%; a non-zero usage exit is fine, a crash is not)
exit /b 0
