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

Write-Log "FOUND manager exe (interactive Win32 per mixa_app_main.lm1 comments) — refusing auto-run in headless smoke"
Write-Log "manual: start $managerExe only in an interactive session"
Write-Log "OVERALL=PRODUCT_PRESENT_HEADLESS_RUN_NOT_DEFINED"
exit 4
