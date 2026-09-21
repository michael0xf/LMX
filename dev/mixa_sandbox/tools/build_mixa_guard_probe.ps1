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



# M: genuinely isolated fixture — NO bin, NO root L1_PIN; explicit translator + KernelEvidenceDir;
#    stale sandbox L1_PIN decoy must not be read (GROK-BOT-BUILD-MIXA-ROOT-PIN-20260921-130).
$iso = Join-Path $base 'isolated_nobin'
$isoTools = Join-Path $iso 'dev\mixa_sandbox\tools'
New-Item -ItemType Directory -Force -Path $isoTools | Out-Null
Copy-Item -LiteralPath $RealScript -Destination (Join-Path $isoTools 'build_mixa.ps1') -Force
New-Item -ItemType Directory -Force -Path (Join-Path $iso 'dev\l2src_sandbox') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $iso 'lm1\build') | Out-Null
# stale decoy pin under sandbox only
Set-Content -LiteralPath (Join-Path $iso 'dev\l2src_sandbox\L1_PIN.txt') -Value '0B3D85B36E72A5935CA43D76B71B8CBBB060AF041CBB6FAE805796595810B2A2' -Encoding ASCII
# exact kernel evidence under the fixture (not relying on repo stamps)
$ked = Join-Path $iso 'build\l2src\ked_exact'
New-Item -ItemType Directory -Force -Path (Join-Path $ked 'headers\l2src') | Out-Null
Set-Content -LiteralPath (Join-Path $ked 'headers\l2src\iso_probe.lm1.h') -Value '// isolated kernel header' -Encoding ASCII
# explicit translator from real repo bin, copied outside fixture so fixture has no bin/
$binExe = Join-Path $RepoRoot 'bin\l1trans.exe'
if (-not (Test-Path -LiteralPath $binExe)) { Write-Output "FAIL M: need real bin to copy explicit translator"; $fails++ }
else {
    $explicit = Join-Path $env:TEMP ("iso_l1trans_" + $PID + ".exe")
    Copy-Item -LiteralPath $binExe -Destination $explicit -Force
    $goodHash = (Get-FileHash -LiteralPath $explicit -Algorithm SHA256).Hash.ToUpper()
    # Prove fixture has neither bin nor root pin
    if (Test-Path (Join-Path $iso 'bin')) { Write-Output "FAIL M: fixture unexpectedly has bin"; $fails++ }
    elseif (Test-Path (Join-Path $iso 'L1_PIN.txt')) { Write-Output "FAIL M: fixture unexpectedly has root L1_PIN"; $fails++ }
    else {
        $tmpScript = Join-Path $isoTools 'build_mixa.ps1'
        $arg = '-NoProfile -ExecutionPolicy Bypass -File "' + $tmpScript + '" -ExactChainGuardOnly -Translator "' + $explicit + '" -ExpectedTranslatorSha256 ' + $goodHash + ' -KernelEvidenceDir "' + $ked + '"'
        $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
        $info.Arguments = $arg
        $info.WorkingDirectory = $iso
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $info.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($info)
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        $blob = $out + "`n" + $err
        $repoFromLayout = (Resolve-Path -LiteralPath $iso).Path
        if ($p.ExitCode -eq 0 -and $blob -match 'mode=EXPLICIT' -and $blob -match 'EXACT-CHAIN-GUARD PASS' -and $blob -match [regex]::Escape($repoFromLayout) -and $blob -notmatch 'pin file path=' -and $blob -notmatch '0B3D85B3') {
            Write-Output "PASS M: isolated no-bin/no-root-pin ExactChainGuardOnly; sandbox decoy pin not consulted"
        } else {
            Write-Output "FAIL M: rc=$($p.ExitCode) out=$out err=$err"; $fails++
        }
    }
    Remove-Item -Force $explicit -ErrorAction SilentlyContinue
}
Remove-Item -Recurse -Force $iso -ErrorAction SilentlyContinue


# J: default ValidateInputsOnly / ExactChainGuardOnly prints repository-root pin path, never sandbox pin
$rootPin = (Resolve-Path -LiteralPath (Join-Path $RepoRoot 'L1_PIN.txt')).Path
$sandboxPin = Join-Path $RepoRoot 'dev\l2src_sandbox\L1_PIN.txt'
$r = Run-RepoMixa @('-ValidateInputsOnly')
# ValidateInputsOnly exits before pin print in current flow — use ExactChainGuardOnly with default translator
$stamps = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'build\l2src') -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{8}_\d{6}$' -and (Test-Path (Join-Path $_.FullName 'headers\l2src')) } |
    Sort-Object Name -Descending)
if ($stamps.Count -lt 1) { Write-Output "FAIL J: no L2 stamp"; $fails++ }
else {
    $r = Run-RepoMixa @('-ExactChainGuardOnly', '-KernelEvidenceDir', ('"' + $stamps[0].FullName + '"'))
    $blob = $r.Out + "`n" + $r.Err
    if ($r.Rc -eq 0 -and $blob -match [regex]::Escape($rootPin) -and $blob -notmatch '(?i)dev[\\/]l2src_sandbox[\\/]L1_PIN') {
        Write-Output ("PASS J: default path prints root pin only: " + $rootPin)
    } else {
        Write-Output "FAIL J: rc=$($r.Rc) out=$($r.Out) err=$($r.Err)"; $fails++
    }
}

# K: inspection — stale sandbox pin still present on disk (not deleted) and differs from root
if ((Test-Path -LiteralPath $sandboxPin) -and ((Get-Content -LiteralPath $sandboxPin -TotalCount 1).Trim().ToUpper() -ne (Get-Content -LiteralPath $rootPin -TotalCount 1).Trim().ToUpper())) {
    Write-Output "PASS K: stale sandbox pin left in place and differs from root (not selected)"
} else {
    Write-Output "FAIL K: sandbox pin missing or equal to root unexpectedly"; $fails++
}

# L: build_l2src default path prints root pin (wrong-hash early exit still prints pin path first — use matching Expected optional)
# Invoke with default translator only far enough: use a throw via missing OutDir parent? Instead run with ExpectedTranslatorSha256 matching so it proceeds past pin then we need early stop.
# Light approach: parse script text / run -? no. Run with Translator=bin and a deliberate early failure by setting OutDir to an invalid device after pin — too heavy.
# Instead: spawn with -Translator default by omitting it, ExpectedTranslatorSha256 wrong AFTER pin check for default also verifies pin — default with wrong ExpectedTranslatorSha256 fails after pin print.
$goodHash = (Get-FileHash -LiteralPath (Join-Path $RepoRoot 'bin\l1trans.exe') -Algorithm SHA256).Hash.ToUpper()
$bad = if ($goodHash[0] -eq 'A') { 'B' + $goodHash.Substring(1) } else { 'A' + $goodHash.Substring(1) }
$r = Run-RepoL2 @('-ExpectedTranslatorSha256', $bad)
$blob = $r.Out + "`n" + $r.Err
if ($r.Rc -ne 0 -and $blob -match [regex]::Escape($rootPin) -and $blob -match 'pin file path=' -and $blob -notmatch '(?i)dev[\\/]l2src_sandbox[\\/]L1_PIN') {
    Write-Output "PASS L: build_l2src default prints repository-root pin path (sandbox never selected)"
} else {
    Write-Output "FAIL L: rc=$($r.Rc) $($r.Out) $($r.Err)"; $fails++
}


# N/O: the scalar-path contract (DEEPSEEK-BUILD-MIXA-SCALAR-PATH-FIX-20260921-136).
# N is the cheap detector that would have caught 136's RED at step 0: the guard's own "headers="
# value must be ONE existing directory, not a progress line concatenated with a path.
# O proves the contract is not decoration -- a fixture copy with ONE progress line put back on the
# output stream must FAIL CLOSED, naming the arity clause, so a future leak carrying different
# prose fails identically instead of being accepted as a path.
$stampN = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'build\l2src') -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{8}_\d{6}$' -and (Test-Path (Join-Path $_.FullName 'headers\l2src')) } |
    Sort-Object Name -Descending | Select-Object -First 1)
if ($stampN.Count -lt 1) { Write-Output "FAIL N: no L2 stamp to point the guard at"; $fails++ }
else {
    $r = Run-RepoMixa @('-ExactChainGuardOnly', '-KernelEvidenceDir', ('"' + $stampN[0].FullName + '"'))
    $lineN = @($r.Out -split "`r?`n" | Where-Object { $_ -match 'EXACT-CHAIN-GUARD PASS headers=' })
    if ($lineN.Count -ne 1) {
        Write-Output "FAIL N: expected exactly one PASS line, got $($lineN.Count): $($r.Out)"; $fails++
    } else {
        $hv = $lineN[0].Substring($lineN[0].IndexOf('headers=') + 8).Trim()
        if ($r.Rc -eq 0 -and (Test-Path -LiteralPath $hv -PathType Container)) {
            Write-Output ("PASS N: guard headers= is exactly one existing directory: " + $hv)
        } else {
            Write-Output "FAIL N: rc=$($r.Rc) headers=[$hv] out=$($r.Out)"; $fails++
        }
    }
}

$ofx = Join-Path $base 'scalar_mutant'
Make-Fixture $ofx @{ bin=1; pin=1; l2=1; lm1=1 }
$kedO = Join-Path $ofx 'build\l2src\ked'
New-Item -ItemType Directory -Force -Path (Join-Path $kedO 'headers\l2src') | Out-Null
Set-Content -LiteralPath (Join-Path $kedO 'headers\l2src\probe.lm1.h') -Value '// isolated' -Encoding ASCII
$mutPath = Join-Path $ofx 'dev/mixa_sandbox/tools/build_mixa.ps1'
$origText = [System.IO.File]::ReadAllText($mutPath)
$mutText = $origText.Replace('Write-Host ("build_mixa: kernel evidence mode=EXPLICIT dir=', 'Write-Output ("build_mixa: kernel evidence mode=EXPLICIT dir=')
if ($mutText -eq $origText) {
    Write-Output "FAIL O: could not mutate the fixture (anchor missing) - the mutant test is not running"; $fails++
} else {
    [System.IO.File]::WriteAllText($mutPath, $mutText)
    $infoO = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $infoO.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $mutPath + '" -ExactChainGuardOnly -KernelEvidenceDir "' + $kedO + '"'
    $infoO.WorkingDirectory = $ofx
    $infoO.RedirectStandardOutput = $true
    $infoO.RedirectStandardError = $true
    $infoO.UseShellExecute = $false
    $pO = [System.Diagnostics.Process]::Start($infoO)
    $outO = $pO.StandardOutput.ReadToEnd()
    $errO = $pO.StandardError.ReadToEnd()
    $pO.WaitForExit()
    $blobO = $outO + "`n" + $errO
    if ($pO.ExitCode -ne 0 -and $blobO -match 'must return exactly one path') {
        Write-Output "PASS O: one leaked progress line FAILS CLOSED with the arity clause (mutant)"
    } else {
        Write-Output "FAIL O: rc=$($pO.ExitCode) out=$outO err=$errO"; $fails++
    }
}

Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue

if ($fails -gt 0) { Write-Error "PROBE RED: $fails"; exit 1 }
Write-Output "PROBE GREEN: exact-chain + pinpath + isolated-root + legacy A/B/C guards"
exit 0
