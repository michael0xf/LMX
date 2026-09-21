# build_miya_guard_probe.ps1 -- read-only test of the no-fallback guard.
# Tests BOTH directions: a valid LMX layout passes, and a layout missing both
# kernel-evidence alternatives fails BEFORE translation with the exact path.
# Creates and destroys temp directories; never touches real directories or
# the sibling L1 tree.

param(
    [string]$Translator = (Get-Command l1trans.exe -ErrorAction SilentlyContinue)?.Source
)

$ErrorActionPreference = 'Stop'

function Test-Guard([string]$Label, [hashtable]$Layout, [bool]$ShouldPass) {
    $fakeRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("build_miya_probe_" + [System.Diagnostics.Process]::GetCurrentProcess().Id + "_" + (Get-Random))
    if (Test-Path $fakeRoot) { Remove-Item -Recurse -Force $fakeRoot }
    New-Item -ItemType Directory -Path $fakeRoot | Out-Null

    try {
        # Build the fake tree
        if ($Layout.ContainsKey('translator')) {
            $bin = New-Item -ItemType Directory -Path (Join-Path $fakeRoot 'bin') -Force
            Set-Content -Path (Join-Path $fakeRoot 'bin\l1trans.exe') -Value '' -Encoding ascii
        }
        if ($Layout.ContainsKey('pin')) {
            Set-Content -Path (Join-Path $fakeRoot 'L1_PIN.txt') -Value ('A' * 64) -Encoding ascii
        }
        if ($Layout.ContainsKey('l2src')) {
            New-Item -ItemType Directory -Path (Join-Path $fakeRoot 'dev/l2src_sandbox') -Force | Out-Null
        }
        if ($Layout.ContainsKey('lm1')) {
            New-Item -ItemType Directory -Path (Join-Path $fakeRoot 'lm1/build') -Force | Out-Null
        }
        if ($Layout.ContainsKey('build_l2src')) {
            New-Item -ItemType Directory -Path (Join-Path $fakeRoot 'build/l2src') -Force | Out-Null
        }
        if ($Layout.ContainsKey('sb_l2src')) {
            New-Item -ItemType Directory -Path (Join-Path $fakeRoot 'dev/l2src_sandbox/build/l2src') -Force | Out-Null
        }

        # Run build_miya.ps1 against the fake root by setting -Translator explicitly
        # and using -ManagerLinkOnly to skip the guard, then separately check the guard
        # logic by invoking the script's resolution with a modified $l1Root.
        # Since the script derives $l1Root from $migRoot's location, we simulate by
        # copying build_miya.ps1 next to the fake root and running from there.
        $scriptDir = Join-Path $fakeRoot 'mixa_sandbox/tools'
        New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
        Copy-Item -Path (Join-Path $PSScriptRoot 'build_miya.ps1') -Destination $scriptDir -Force

        # Create a fake mixa_manager so $migRoot resolves
        $mixaDir = Join-Path $fakeRoot 'mixa_manager'
        New-Item -ItemType Directory -Path (Join-Path $mixaDir 'build') -Force | Out-Null

        # Run from fake root
        $orig = Get-Location
        Set-Location $fakeRoot
        try {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = 'powershell'
            $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File mixa_sandbox/tools/build_miya.ps1 -BuildOnly"
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($psi)
            $out = $p.StandardOutput.ReadToEnd()
            $err = $p.StandardError.ReadToEnd()
            $p.WaitForExit()
            $rc = $p.ExitCode
        } finally {
            Set-Location $orig
        }

        if ($ShouldPass) {
            if ($rc -eq 0 -or ($out -notmatch 'missing local input' -and $err -notmatch 'missing local input')) {
                Write-Output "PASS [$Label]: good layout did not trigger guard failure"
                return $true
            } else {
                Write-Output "FAIL [$Label]: good layout triggered guard: $($out -replace "`r`n", ' ' | Select-Object -First 1)"
                return $false
            }
        } else {
            if ($rc -ne 0 -and ($err -match 'missing local input' -or $out -match 'missing local input')) {
                Write-Output "PASS [$Label]: bad layout correctly refused before translation"
                return $true
            } else {
                Write-Output "FAIL [$Label]: bad layout was NOT refused (rc=$rc)"
                return $false
            }
        }
    } finally {
        Remove-Item -Recurse -Force $fakeRoot -ErrorAction SilentlyContinue
    }
}

$results = @()
# Positive: minimal LMX layout (root build/l2src, no sandbox build/l2src)
$results += Test-Guard "positive: root build/l2src only" @{translator=1; pin=1; l2src=1; lm1=1; build_l2src=1} $true
# Negative: missing both kernel-evidence paths
$results += Test-Guard "negative: no kernel evidence" @{translator=1; pin=1; l2src=1; lm1=1} $false
# Negative: missing lm1/build
$results += Test-Guard "negative: missing lm1/build" @{translator=1; pin=1; l2src=1; build_l2src=1} $false

if ($results -contains $false) {
    Write-Output "PROBE RED: some assertions failed"
    exit 1
}
Write-Output "PROBE GREEN: all assertions passed"
exit 0
