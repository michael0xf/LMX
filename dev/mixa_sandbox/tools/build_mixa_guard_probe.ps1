# build_mixa_guard_probe.ps1 -- read-only both-direction guard test.
# Fixture at <tmp>/dev/mixna_sandbox/tools/build_mixa.ps1 so $l1Root resolves inside.
$ErrorActionPreference = 'Stop'

$RepoRoot = (Get-Location).Path
$RealScript = (Resolve-Path "dev/mixa_sandbox/tools/build_mixa.ps1").Path

function Make-Fixture($Root, $Has) {
    $tools = Join-Path $Root 'dev/mixa_sandbox/tools'
    New-Item -ItemType Directory -Path $tools -Force | Out-Null
    Copy-Item -LiteralPath $RealScript -Destination (Join-Path $tools 'build_mixa.ps1') -Force
    if ($Has.bin)  { New-Item -ItemType Directory -Path (Join-Path $Root 'bin') -Force | Out-Null; Copy-Item -LiteralPath (Join-Path $RepoRoot 'bin/l1trans.exe') -Destination (Join-Path $Root 'bin/l1trans.exe') -Force }
    if ($Has.pin)  { Copy-Item -LiteralPath (Join-Path $RepoRoot 'L1_PIN.txt') -Destination (Join-Path $Root 'L1_PIN.txt') -Force }
    if ($Has.l2)   { New-Item -ItemType Directory -Path (Join-Path $Root 'dev/l2src_sandbox') -Force | Out-Null }
    if ($Has.lm1)  { New-Item -ItemType Directory -Path (Join-Path $Root 'lm1/build') -Force | Out-Null }
    if ($Has.rk)   { New-Item -ItemType Directory -Path (Join-Path $Root 'build/l2src') -Force | Out-Null }
    if ($Has.sk)   { New-Item -ItemType Directory -Path (Join-Path $Root 'dev/l2src_sandbox/build/l2src') -Force | Out-Null }
}

function Run-Guard($Root) {
    $tmpScript = Join-Path $Root 'dev/mixa_sandbox/tools/build_mixa.ps1'
    $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $info.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $tmpScript + '" -ValidateInputsOnly'
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($info)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ Rc = $p.ExitCode; Out = $out; Err = $err }
}

$base = Join-Path ([System.IO.Path]::GetTempPath()) ("mga_" + [Diagnostics.Process]::GetCurrentProcess().Id)
$fails = 0

# A: root build/l2src (real LMX shape) -> must PASS
$ra = Join-Path $base 'a'
Make-Fixture $ra @{ bin=1; pin=1; l2=1; lm1=1; rk=1 }
$r = Run-Guard $ra
Remove-Item -Recurse -Force $ra -ErrorAction SilentlyContinue
if ($r.Rc -eq 0 -and $r.Out -match 'VALIDATE-ONLY PASS') { Write-Output "PASS A: root build/l2src passes" } else { Write-Output "FAIL A: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

# B: NEITHER kernel alternative -> must FAIL before translation
$rb = Join-Path $base 'b'
Make-Fixture $rb @{ bin=1; pin=1; l2=1; lm1=1 }
$r = Run-Guard $rb
Remove-Item -Recurse -Force $rb -ErrorAction SilentlyContinue
if ($r.Rc -ne 0 -and ($r.Err -match 'missing local input' -or $r.Out -match 'missing local input')) {
    Write-Output "PASS B: both kernel alternatives missing -> refused"
} else { Write-Output "FAIL B: rc=$($r.Rc)"; $fails++ }

# C: sandbox build/l2src (L1-nested shape) -> must PASS
$rc = Join-Path $base 'c'
Make-Fixture $rc @{ bin=1; pin=1; l2=1; lm1=1; sk=1 }
$r = Run-Guard $rc
Remove-Item -Recurse -Force $rc -ErrorAction SilentlyContinue
if ($r.Rc -eq 0 -and $r.Out -match 'VALIDATE-ONLY PASS') { Write-Output "PASS C: sandbox build/l2src passes" } else { Write-Output "FAIL C: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue

if ($fails -gt 0) { Write-Error "PROBE RED: $fails"; exit 1 }
Write-Output "PROBE GREEN: 3 fixtures (A positive, B negative, C positive)"
exit 0
