# build_mixa_guard_probe.ps1 -- lightweight guards for local inputs + exact-chain (ticket 128).
# No full build_mixa / L2 heavy gate.
$ErrorActionPreference = 'Stop'

$RepoRoot = (Get-Location).Path
$RealScript = (Resolve-Path "dev/mixa_sandbox/tools/build_mixa.ps1").Path
$L2Script = (Resolve-Path "tools/build_l2src.ps1").Path

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

function Run-Guard($Root, [string[]]$ExtraArgs) {
    $tmpScript = Join-Path $Root 'dev/mixa_sandbox/tools/build_mixa.ps1'
    $arg = '-NoProfile -ExecutionPolicy Bypass -File "' + $tmpScript + '" -ValidateInputsOnly'
    if ($ExtraArgs) { $arg = '-NoProfile -ExecutionPolicy Bypass -File "' + $tmpScript + '" ' + ($ExtraArgs -join ' ') }
    $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $info.Arguments = $arg
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($info)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ Rc = $p.ExitCode; Out = $out; Err = $err }
}

function Run-RepoMixa([string[]]$ExtraArgs) {
    $arg = '-NoProfile -ExecutionPolicy Bypass -File "' + $RealScript + '" ' + ($ExtraArgs -join ' ')
    $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $info.Arguments = $arg
    $info.WorkingDirectory = $RepoRoot
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($info)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ Rc = $p.ExitCode; Out = $out; Err = $err }
}

function Run-RepoL2([string[]]$ExtraArgs) {
    $arg = '-NoProfile -ExecutionPolicy Bypass -File "' + $L2Script + '" ' + ($ExtraArgs -join ' ')
    $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $info.Arguments = $arg
    $info.WorkingDirectory = $RepoRoot
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
$r = Run-Guard $ra @()
Remove-Item -Recurse -Force $ra -ErrorAction SilentlyContinue
if ($r.Rc -eq 0 -and $r.Out -match 'VALIDATE-ONLY PASS') { Write-Output "PASS A: root build/l2src passes" } else { Write-Output "FAIL A: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

# B: NEITHER kernel alternative -> must FAIL before translation
$rb = Join-Path $base 'b'
Make-Fixture $rb @{ bin=1; pin=1; l2=1; lm1=1 }
$r = Run-Guard $rb @()
Remove-Item -Recurse -Force $rb -ErrorAction SilentlyContinue
if ($r.Rc -ne 0 -and ($r.Err -match 'missing local input' -or $r.Out -match 'missing local input')) {
    Write-Output "PASS B: both kernel alternatives missing -> refused"
} else { Write-Output "FAIL B: rc=$($r.Rc)"; $fails++ }

# C: sandbox build/l2src (L1-nested shape) -> must PASS
$rc = Join-Path $base 'c'
Make-Fixture $rc @{ bin=1; pin=1; l2=1; lm1=1; sk=1 }
$r = Run-Guard $rc @()
Remove-Item -Recurse -Force $rc -ErrorAction SilentlyContinue
if ($r.Rc -eq 0 -and $r.Out -match 'VALIDATE-ONLY PASS') { Write-Output "PASS C: sandbox build/l2src passes" } else { Write-Output "FAIL C: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

# D/E/F/G: exact-chain on real repo (needs bin\l1trans.exe + a real L2 stamp with headers)
$binExe = Join-Path $RepoRoot 'bin\l1trans.exe'
if (-not (Test-Path -LiteralPath $binExe)) { Write-Output "FAIL D-G: missing $binExe"; $fails += 4 }
else {
    $goodHash = (Get-FileHash -LiteralPath $binExe -Algorithm SHA256).Hash.ToUpper()
    $explicitCopy = Join-Path $env:TEMP ("l1trans_explicit_" + $PID + ".exe")
    Copy-Item -LiteralPath $binExe -Destination $explicitCopy -Force

    $stampRoot = Join-Path $RepoRoot 'build\l2src'
    $stamps = @(Get-ChildItem -LiteralPath $stampRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d{8}_\d{6}$' -and (Test-Path (Join-Path $_.FullName 'headers\l2src')) } |
        Sort-Object Name -Descending)
    if ($stamps.Count -lt 1) { Write-Output "FAIL D-G: no L2 stamp with headers\l2src under build\l2src"; $fails += 4 }
    else {
        $older = $stamps[-1]
        $newerName = (Get-Date).ToString('yyyyMMdd_HHmmss')
        # ensure newer than all by bumping if collision
        if ($stamps[0].Name -ge $newerName) { $newerName = $stamps[0].Name.Substring(0,11) + ([int]$stamps[0].Name.Substring(11) + 1).ToString('000000') }
        $decoy = Join-Path $stampRoot $newerName
        New-Item -ItemType Directory -Force -Path (Join-Path $decoy 'headers\l2src') | Out-Null
        Set-Content -LiteralPath (Join-Path $decoy 'headers\l2src\decoy_only.lm1.h') -Value '// decoy' -Encoding ASCII

        # D: KernelEvidenceDir exact older stamp wins over newer decoy
        $r = Run-RepoMixa @('-ExactChainGuardOnly', '-KernelEvidenceDir', ('"' + $older.FullName + '"'))
        if ($r.Rc -eq 0 -and $r.Out -match 'mode=EXPLICIT' -and $r.Out -match [regex]::Escape($older.FullName) -and $r.Out -match 'kernel headers count=' -and $r.Out -notmatch 'decoy_only') {
            Write-Output ("PASS D: EXPLICIT KernelEvidenceDir=" + $older.Name + " over decoy " + $newerName)
        } else {
            Write-Output "FAIL D: rc=$($r.Rc) out=$($r.Out) err=$($r.Err)"; $fails++
        }

        # E: missing headers on KernelEvidenceDir fails (no auto fallback)
        $emptyEv = Join-Path $env:TEMP ("ked_empty_" + $PID)
        New-Item -ItemType Directory -Force -Path $emptyEv | Out-Null
        $r = Run-RepoMixa @('-ExactChainGuardOnly', '-KernelEvidenceDir', ('"' + $emptyEv + '"'))
        if ($r.Rc -ne 0 -and (($r.Err + $r.Out) -match 'missing headers\\l2src|KernelEvidenceDir')) {
            Write-Output "PASS E: missing exact headers refused (no auto fallback)"
        } else { Write-Output "FAIL E: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }
        Remove-Item -Recurse -Force $emptyEv -ErrorAction SilentlyContinue

        # F: explicit translator + matching ExpectedTranslatorSha256 succeeds without needing pin path semantics
        $r = Run-RepoMixa @('-ExactChainGuardOnly', '-Translator', ('"' + $explicitCopy + '"'), '-ExpectedTranslatorSha256', $goodHash, '-KernelEvidenceDir', ('"' + $older.FullName + '"'))
        if ($r.Rc -eq 0 -and $r.Out -match 'ExpectedTranslatorSha256 verified' -and $r.Out -match 'mode=EXPLICIT') {
            Write-Output "PASS F: explicit translator + matching ExpectedTranslatorSha256"
        } else { Write-Output "FAIL F: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

        # G: wrong ExpectedTranslatorSha256 fails before work (mixa)
        $bad = if ($goodHash[0] -eq 'A') { 'B' + $goodHash.Substring(1) } else { 'A' + $goodHash.Substring(1) }
        $r = Run-RepoMixa @('-ExactChainGuardOnly', '-Translator', ('"' + $explicitCopy + '"'), '-ExpectedTranslatorSha256', $bad, '-KernelEvidenceDir', ('"' + $older.FullName + '"'))
        if ($r.Rc -ne 0 -and (($r.Err + $r.Out) -match 'ExpectedTranslatorSha256 mismatch')) {
            Write-Output "PASS G: mixa wrong ExpectedTranslatorSha256 fails before work"
        } else { Write-Output "FAIL G: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

        # H: build_l2src wrong ExpectedTranslatorSha256 fails before translation (no heavy gate)
        $r = Run-RepoL2 @('-Translator', ('"' + $explicitCopy + '"'), '-ExpectedTranslatorSha256', $bad)
        if ($r.Rc -ne 0 -and (($r.Err + $r.Out) -match 'ExpectedTranslatorSha256 mismatch')) {
            Write-Output "PASS H: build_l2src wrong ExpectedTranslatorSha256 fails before work"
        } else { Write-Output "FAIL H: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

        # I: default/pinned ValidateInputsOnly still OK on real tree
        $r = Run-RepoMixa @('-ValidateInputsOnly')
        if ($r.Rc -eq 0 -and $r.Out -match 'VALIDATE-ONLY PASS') {
            Write-Output "PASS I: default/pinned ValidateInputsOnly still OK"
        } else { Write-Output "FAIL I: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++ }

        Remove-Item -Recurse -Force $decoy -ErrorAction SilentlyContinue
    }
    Remove-Item -Force $explicitCopy -ErrorAction SilentlyContinue
}

Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue

if ($fails -gt 0) { Write-Error "PROBE RED: $fails"; exit 1 }
Write-Output "PROBE GREEN: exact-chain + legacy A/B/C guards"
exit 0
