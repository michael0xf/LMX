# run_manager_smoke.ps1 — GROK-BOT-MANAGER-RUN-20260920-61B
# Consumes existing build_mixa evidence bins only. Does NOT call or duplicate build_mixa.ps1.
# Fails closed until bin/mixa_app_main.exe (real manager shell product) exists in the stamp.
param(
    [string]$Stamp,
    [switch]$AllowControllerE2EProxy
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
Set-Location $RepoRoot

$ProbeRoot = Join-Path $RepoRoot "build\grok_bot_manager"
New-Item -ItemType Directory -Force -Path $ProbeRoot | Out-Null
$Log = Join-Path $ProbeRoot ("smoke_{0:yyyyMMdd_HHmmss}.txt" -f (Get-Date))

function Write-Log([string]$msg) {
    $msg | Tee-Object -FilePath $Log -Append
}

# The one PowerShell 5.1-safe launcher (DEEPSEEK-PS51-PROC-HELPER-20260920-07). Its header carries
# why ProcessStartInfo.ArgumentList is never used: it does not exist under Windows PowerShell 5.1 /
# .NET Framework, and touching it throws (measured). A missing helper is a hard failure, never a
# silent fall-back to an ad-hoc command line.
$ps51Proc = Join-Path $PSScriptRoot '..\..\..\tools\ps51_proc.ps1'
if (-not (Test-Path -LiteralPath $ps51Proc)) {
    Write-Log "FAIL: missing helper $ps51Proc"
    exit 2
}
. $ps51Proc

$buildRoot = Join-Path $RepoRoot "dev\mixa_sandbox\build"
if (-not (Test-Path -LiteralPath $buildRoot)) {
    Write-Log "FAIL: missing evidence root $buildRoot"
    exit 2
}

if (-not $Stamp -or $Stamp.Trim().Length -eq 0) {
    $Stamp = (
        Get-ChildItem -LiteralPath $buildRoot -Directory |
        Where-Object { $_.Name -match '^\d{8}_\d{6}$' } |
        Sort-Object Name -Descending |
        Select-Object -First 1
    ).Name
}

if (-not $Stamp) {
    Write-Log "FAIL: no stamped evidence directory under $buildRoot"
    exit 2
}

$stampDir = Join-Path $buildRoot $Stamp
$binDir = Join-Path $stampDir "bin"
$managerExe = Join-Path $binDir "mixa_app_main.exe"

Write-Log "repo=$RepoRoot"
Write-Log "stamp=$Stamp"
Write-Log "binDir=$binDir"
Write-Log "looking_for=$managerExe"

if (-not (Test-Path -LiteralPath $binDir)) {
    Write-Log "FAIL: no bin directory in stamp (run DeepSeek build_mixa gate first)"
    exit 2
}

$exeCount = @(Get-ChildItem -LiteralPath $binDir -Filter *.exe -File).Count
Write-Log "bin_exe_count=$exeCount"

if (-not (Test-Path -LiteralPath $managerExe)) {
    Write-Log "BLOCKER: missing manager shell product: $managerExe"
    Write-Log "first_missing_target=dev/mixa_sandbox/build/$Stamp/bin/mixa_app_main.exe"
    Write-Log "expose: Test-Path '$managerExe'  -> False"
    Write-Log "see steps/mixa-manager-run-audit.md"

    if ($AllowControllerE2EProxy) {
        $e2e = Join-Path $binDir "tests_mixa_app_controller_e2e_selftest.exe"
        if (Test-Path -LiteralPath $e2e) {
            Write-Log "PROXY: running controller e2e only (NOT manager shell): $e2e"
            & $e2e
            $rc = $LASTEXITCODE
            Write-Log "PROXY_EXIT=$rc"
            Write-Log "OVERALL=BLOCKED (manager exe still missing)"
            exit 3
        }
        Write-Log "PROXY: controller e2e exe also missing"
    }

    exit 3
}

# THE REAL PRODUCT IS RUN HERE, AND IT IS THE PRODUCT (DEEPSEEK-MANAGER-HEADLESS-20260920-01).
# What used to stand here was a refusal -- PRODUCT_PRESENT_HEADLESS_RUN_NOT_DEFINED, exit 4 --
# because the only entry mixa_app_main.exe had would open a window. It now takes
# --headless-smoke, which selects the product's own mixa_backend_headless_table instead of the
# Win32 one and bounds the step loop; the window came from the BACKEND TABLE and never from
# main, so nothing about the lifecycle is simulated. The controller that runs is the product's
# own, opened, stepped and closed by the product's own entry.
#
# THIS IS NOT THE CONTROLLER E2E PROXY, and the two must never be reported as the same thing.
# The proxy above is a TEST driving the controller in the product's place; this is the PRODUCT
# driving it. A run that reaches here says the product ran; a run that reaches the proxy says
# only that the controller can be driven.
Write-Log "FOUND manager exe: $managerExe"

# A root the smoke owns, so the product cannot touch anything of the repository's, and a small
# step bound so the run is bounded by construction rather than by the timeout below.
$smokeRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("mixa_headless_smoke_" + [System.Diagnostics.Process]::GetCurrentProcess().Id)
New-Item -ItemType Directory -Force -Path $smokeRoot | Out-Null
$smokeSteps = 32
$smokeTimeoutSec = 60
Write-Log "PRODUCT run: $managerExe --headless-smoke <temp root> $smokeSteps (timeout ${smokeTimeoutSec}s)"

# THE TIMEOUT IS A SECOND FLOOR UNDER THE STEP BOUND, not the primary one. The bound is what
# makes the run finite; the timeout catches the case where a single step never returns, which
# the bound cannot. A run killed here is reported as a TIMEOUT and never as a pass.
# THE ARGUMENTS ARE PASSED AS AN ARRAY and the command line is built by the shared helper
# (tools\ps51_proc.ps1, DEEPSEEK-PS51-PROC-HELPER-20260920-07). This used to hand-build
# '--headless-smoke "<root>" <steps>' as one string, which is exactly the shape that silently splits
# when a value contains a space -- and the temp root below can. The helper quotes every element with
# the rule the C runtimes parse, so the product, gcc and l1trans all see the same argv.
# ProcessStartInfo.ArgumentList is never used: it does not exist under Windows PowerShell 5.1 /
# .NET Framework and touching it throws 'You cannot call a method on a null-valued expression'
# (measured; the helper's header carries the full note). The helper also returns the child's real
# exit code -- the thing Start-Process -PassThru with redirected streams could not report
# (tools\build_l2src.ps1:199-202, measured there).
$run = Invoke-ProcBounded -Exe $managerExe -Argv @('--headless-smoke', $smokeRoot, [string]$smokeSteps) -TimeoutSec $smokeTimeoutSec
if (-not $run.Started) {
    Write-Log "PRODUCT_EXIT=did-not-start"
    Write-Log "OVERALL=FAIL (product did not start)"
    exit 5
}
if ($run.TimedOut) {
    Write-Log "PRODUCT_EXIT=timeout after ${smokeTimeoutSec}s -- killed"
    Write-Log "OVERALL=FAIL (headless smoke did not terminate)"
    exit 5
}
$rc = $run.Code
$summary = $run.Text.Trim()
foreach ($line in ($summary -split "`r?`n")) { if ($line.Trim()) { Write-Log "PRODUCT_OUT $line" } }
Write-Log "PRODUCT_EXIT=$rc"
try { Remove-Item -LiteralPath $smokeRoot -Recurse -Force -ErrorAction SilentlyContinue } catch { }

# BOTH the exit code AND the summary must agree. An exit code alone could be produced by a
# binary that never reached the lifecycle; the summary alone could be printed by one that then
# failed. Requiring the pair is what makes this evidence of a completed run.
$okLine = ($summary -match 'MIXA_HEADLESS_SMOKE status=OK steps=' + $smokeSteps + ' bound=' + $smokeSteps)
if ($rc -ne 0) {
    Write-Log "OVERALL=FAIL (product exit $rc)"
    exit 5
}
if (-not $okLine) {
    Write-Log "OVERALL=FAIL (exit 0 but no matching MIXA_HEADLESS_SMOKE status=OK line for $smokeSteps steps)"
    exit 5
}
Write-Log "OVERALL=PRODUCT_HEADLESS_RUN_OK (real executable, real controller, $smokeSteps bounded steps)"
exit 0
