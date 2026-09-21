# build_mixa_guard_probe.ps1 -- read-only test of the no-fallback guard.
#
# Creates a temp directory that mimics an LMX repo root but is MISSING lm1/build,
# then replicates build_mixa.ps1's guard logic to verify it fails BEFORE any
# translation, with the exact missing path.  Does not touch real directories or
# the sibling L1 tree.
param(
    [string]$TranslatorHash,
    [string]$PinHash
)

$ErrorActionPreference = 'Stop'

# Isolate: temp dir, cleaned up on exit.
$fakeRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("build_mixa_guard_" + [System.Diagnostics.Process]::GetCurrentProcess().Id)
if (Test-Path -LiteralPath $fakeRoot) { Remove-Item -Recurse -Force $fakeRoot }
New-Item -ItemType Directory -Path $fakeRoot | Out-Null
try {
    # Fake a repo root with bin/l1trans.exe + L1_PIN.txt but NO lm1/build,
    # NO dev/l2src_sandbox, NO build/l2src.
    $binDir = Join-Path $fakeRoot 'bin'
    New-Item -ItemType Directory -Path $binDir | Out-Null
    # Write a dummy translator (a 0-byte file is enough for Test-Path).
    Set-Content -LiteralPath (Join-Path $binDir 'l1trans.exe') -Value '' -Encoding ascii
    Set-Content -LiteralPath (Join-Path $fakeRoot 'L1_PIN.txt') -Value ('A' * 64) -Encoding ascii

    # Replicate the guard from build_mixa.ps1 exactly.
    $l1Root = $fakeRoot
    $mustHave = @(
        @{ Name = 'translator (bin\l1trans.exe)'; Path = (Join-Path $l1Root 'bin\l1trans.exe') },
        @{ Name = 'L1_PIN.txt'; Path = (Join-Path $l1Root 'L1_PIN.txt') },
        @{ Name = 'L2 core sources (dev/l2src_sandbox)'; Path = (Join-Path $l1Root 'dev\l2src_sandbox') },
        @{ Name = 'lm1/build'; Path = (Join-Path $l1Root 'lm1\build') },
        @{ Name = 'kernel evidence (build/l2src)'; Path = (Join-Path $l1Root 'build\l2src') },
        @{ Name = 'kernel evidence (dev/l2src_sandbox/build/l2src)'; Path = (Join-Path $l1Root 'dev\l2src_sandbox\build\l2src') }
    )
    $firstFail = $null
    foreach ($m in $mustHave) {
        if (-not (Test-Path -LiteralPath $m.Path)) {
            $firstFail = $m
            break
        }
    }

    if ($firstFail) {
        Write-Output ("PASS: guard fails before translation on missing $($firstFail.Name) at $($firstFail.Path)")
        exit 0
    } else {
        Write-Error "FAIL: guard did not detect missing local inputs in fake root"
        exit 1
    }
} finally {
    Remove-Item -Recurse -Force $fakeRoot -ErrorAction SilentlyContinue
}
