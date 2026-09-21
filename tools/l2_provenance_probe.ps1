# l2_provenance_probe.ps1 -- deterministic negative probes for the l2trans provenance builder
# (DEEPSEEK-L2TRANSLATOR-EVIDENCE-BUILDER-20260921-146).
#
# Cheap by design: every probe here observes a REFUSAL, and a refusal happens before any work, so
# the whole suite runs in seconds with no translator, no gcc and no build.  The four negatives the
# ticket names map to the four modes: wrong/malformed B2 hash -> -ProvenanceCheckOnly; staged
# source drift and stale/incomplete evidence -> -VerifyEvidence; malformed/corrupt PE -> -PeInfo.
#
# Each probe asserts a SPECIFIC clause of the refusal message, never a bare non-zero exit: a probe
# that only checks the exit code passes for any failure at all, including one in the wrong branch.
#
# Nothing here writes to the repository tree.  Fixtures live under the temp directory.
param(
    # Optional.  When given, the byte-level contract is ALSO asserted against this real evidence
    # directory's manifest.  It stays a PARAMETER rather than a default so the probe never selects
    # an evidence directory by itself -- picking the newest is the hazard this whole ticket family
    # exists to remove, and a probe is not exempt from it.
    [string]$EvidenceDir
)
$ErrorActionPreference = 'Stop'

$RepoRoot = (Get-Location).Path
$RealScript = (Resolve-Path 'tools/l2_harness.ps1').Path
$Sandbox = Join-Path $RepoRoot 'dev/l2src_sandbox'
$base = Join-Path ([System.IO.Path]::GetTempPath()) ('prov_probe_' + [Diagnostics.Process]::GetCurrentProcess().Id)
New-Item -ItemType Directory -Force -Path $base | Out-Null
$fails = 0

# NOTE: the parameter must NOT be called $Args -- that is a PowerShell AUTOMATIC variable, and a
# parameter of that name leaves the function reading the automatic (empty) one, so the harness is
# launched with NO arguments and every probe silently exercises a default run.  Measured here: the
# first version of this file ran the full 30-row suite five times instead of observing refusals.
function Run-Harness([string[]]$HarnessArgs) {
    $info = New-Object System.Diagnostics.ProcessStartInfo 'powershell'
    $info.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $RealScript + '" ' + ($HarnessArgs -join ' ')
    $info.WorkingDirectory = $RepoRoot
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($info)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ Rc = $p.ExitCode; Blob = ($out + "`n" + $err) }
}
function Check([string]$Name, [bool]$Ok, [string]$Detail) {
    if ($Ok) { Write-Output ('PASS ' + $Name) } else { Write-Output ('FAIL ' + $Name + ': ' + $Detail); $script:fails++ }
}

$B2 = Join-Path $RepoRoot 'build\self_build\20260921_124415_211\b2\l1trans.exe'
$B2HASH = 'c51b859e985a22ac5c35664c0845bbe61401502b5587a4f24c9f2bed9b19f1c1'

# ---- 1. a WRONG translator hash must refuse BEFORE any work -------------------------------
$d1 = Join-Path $base 'p1_wronghash'
$r = Run-Harness @('-ProvenanceCheckOnly', '-Translator', ('"' + $B2 + '"'),
                   '-ExpectedTranslatorSha256', ('f' * 64), '-OutDir', ('"' + $d1 + '"'))
Check 'P1 wrong B2 hash refused before work' `
    ($r.Rc -ne 0 -and $r.Blob -match 'ExpectedTranslatorSha256 mismatch BEFORE any work') `
    ("rc=$($r.Rc) $($r.Blob)")
Check 'P1 left no evidence directory behind' (-not (Test-Path -LiteralPath $d1)) 'the refused run created a directory'

# ---- 2. a MALFORMED hash, and the two required-argument clauses ---------------------------
$r = Run-Harness @('-ProvenanceCheckOnly', '-Translator', ('"' + $B2 + '"'),
                   '-ExpectedTranslatorSha256', 'deadbeef', '-OutDir', ('"' + (Join-Path $base 'p2') + '"'))
Check 'P2 malformed hash refused' ($r.Rc -ne 0 -and $r.Blob -match 'must be 64 hex') ("rc=$($r.Rc) $($r.Blob)")

$r = Run-Harness @('-ProvenanceCheckOnly', '-Translator', ('"' + $B2 + '"'), '-OutDir', ('"' + (Join-Path $base 'p2b') + '"'))
Check 'P2 missing -ExpectedTranslatorSha256 refused' ($r.Rc -ne 0 -and $r.Blob -match 'ExpectedTranslatorSha256 is required') ("rc=$($r.Rc) $($r.Blob)")

$r = Run-Harness @('-ProvenanceCheckOnly', '-ExpectedTranslatorSha256', $B2HASH, '-OutDir', ('"' + (Join-Path $base 'p2c') + '"'))
Check 'P2 missing -Translator refused (no default in provenance mode)' `
    ($r.Rc -ne 0 -and $r.Blob -match 'no default, no bin') ("rc=$($r.Rc) $($r.Blob)")

# ---- 3. a stale / non-empty evidence directory must be refused ----------------------------
$d3 = Join-Path $base 'p3_stale'
New-Item -ItemType Directory -Force -Path $d3 | Out-Null
Set-Content -LiteralPath (Join-Path $d3 'leftover.txt') -Value 'x' -Encoding ASCII
$r = Run-Harness @('-ProvenanceCheckOnly', '-Translator', ('"' + $B2 + '"'),
                   '-ExpectedTranslatorSha256', $B2HASH, '-OutDir', ('"' + $d3 + '"'))
Check 'P3 non-empty evidence dir refused' ($r.Rc -ne 0 -and $r.Blob -match 'exists and is not empty') ("rc=$($r.Rc) $($r.Blob)")

# ---- synthetic evidence directories for the -VerifyEvidence probes ------------------------
$artifact = Join-Path $RepoRoot 'build\l2_harness\20260921_134644\bin\l2trans.exe'
$piOut = Run-Harness @('-PeInfo', ('"' + $artifact + '"'))
$maskedLine = @($piOut.Blob -split "`n" | Where-Object { $_ -match 'masked_sha256=' } | Select-Object -First 1)
$masked = if ($maskedLine.Count -ge 1) { ($maskedLine[0] -replace '.*masked_sha256=', '').Trim() } else { '' }
if ($masked -eq '') { Write-Error ('PROBE SETUP FAILED: -PeInfo produced no masked identity for ' + $artifact + ': ' + $piOut.Blob); exit 2 }

function New-Evidence([string]$Dir, [string]$DevL2trans, [string]$StageL2trans, [bool]$WriteManifest) {
    New-Item -ItemType Directory -Force -Path (Join-Path $Dir 'src\l2src') | Out-Null
    Copy-Item -LiteralPath (Join-Path $Sandbox 'l2trans.lm1') -Destination (Join-Path $Dir 'src\l2src\l2trans.lm1') -Force
    Copy-Item -LiteralPath (Join-Path $Sandbox 'l2_libc.lm1') -Destination (Join-Path $Dir 'src\l2src\l2_libc.lm1') -Force
    if (-not $WriteManifest) { return }
    $stageLibc = (Get-FileHash -LiteralPath (Join-Path $Dir 'src\l2src\l2_libc.lm1') -Algorithm SHA256).Hash.ToUpper()
    $devLibc = (Get-FileHash -LiteralPath (Join-Path $Sandbox 'l2_libc.lm1') -Algorithm SHA256).Hash.ToUpper()
    # EVERY element is parenthesised on purpose: in PowerShell the comma operator binds TIGHTER
    # than '+', so `'a' + $x, 'b' + $y` parses as `'a' + ($x, 'b') + $y` and collapses the whole
    # list into ONE string.  Measured here: the first version wrote a single line
    # "l2trans_path=<path> l2trans_masked_sha256=..." and the missing keys made all three
    # VerifyEvidence probes fail against a manifest that was never what they thought.
    $lines = @(
        ('l2trans_path=' + $artifact),
        ('l2trans_masked_sha256=' + $masked),
        ('source_dev_l2trans_sha256=' + $DevL2trans),
        ('source_staged_l2trans_sha256=' + $StageL2trans),
        ('source_dev_l2_libc_sha256=' + $devLibc),
        ('source_staged_l2_libc_sha256=' + $stageLibc)
    )
    # The fixture must be written to the CONTRACT bytes (UTF-8, no BOM, LF) or the byte-level gate
    # would fail against the probe's own fixtures instead of against the thing under test.
    [System.IO.File]::WriteAllText((Join-Path $Dir 'PROVENANCE_COMPLETE.txt'), (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
}
function Sha([string]$P) { return (Get-FileHash -LiteralPath $P -Algorithm SHA256).Hash.ToUpper() }

# ---- 4. staged/source drift, BOTH directions ----------------------------------------------
$d4 = Join-Path $base 'p4_drift'
$stageHash = $null
New-Evidence $d4 (Sha (Join-Path $Sandbox 'l2trans.lm1')) 'PLACEHOLDER' $true
$stageHash = Sha (Join-Path $d4 'src\l2src\l2trans.lm1')
New-Evidence $d4 (Sha (Join-Path $Sandbox 'l2trans.lm1')) $stageHash $true

# positive control FIRST: untouched, it must pass, or the refusals below prove nothing
$r = Run-Harness @('-VerifyEvidence', ('"' + $d4 + '"'))
Check 'P4a intact evidence dir verifies (positive control)' ($r.Rc -eq 0 -and $r.Blob -match 'verify: PASS') ("rc=$($r.Rc) $($r.Blob)")

Add-Content -LiteralPath (Join-Path $d4 'src\l2src\l2trans.lm1') -Value 'drift' -Encoding ASCII
$r = Run-Harness @('-VerifyEvidence', ('"' + $d4 + '"'))
Check 'P4b staged bytes drift refused' ($r.Rc -ne 0 -and $r.Blob -match 'staged bytes differ from what the run recorded') ("rc=$($r.Rc) $($r.Blob)")

$d4c = Join-Path $base 'p4c_live'
New-Evidence $d4c ('0' * 64) (Sha (Join-Path $Sandbox 'l2trans.lm1')) $true
$r = Run-Harness @('-VerifyEvidence', ('"' + $d4c + '"'))
Check 'P4c changed LIVE source refused' ($r.Rc -ne 0 -and $r.Blob -match 'LIVE source has changed since the run') ("rc=$($r.Rc) $($r.Blob)")

# ---- 5. incomplete evidence -----------------------------------------------------------------
$d5 = Join-Path $base 'p5_incomplete'
New-Evidence $d5 '' '' $false          # staged files, NO manifest
Set-Content -LiteralPath (Join-Path $d5 'provenance.log') -Value 'stamp=x' -Encoding utf8
$r = Run-Harness @('-VerifyEvidence', ('"' + $d5 + '"'))
Check 'P5a transcript without a manifest is not evidence' `
    ($r.Rc -ne 0 -and $r.Blob -match 'incomplete evidence -- no PROVENANCE_COMPLETE.txt') ("rc=$($r.Rc) $($r.Blob)")

$d5b = Join-Path $base 'p5b_missingkey'
New-Evidence $d5b (Sha (Join-Path $Sandbox 'l2trans.lm1')) (Sha (Join-Path $Sandbox 'l2trans.lm1')) $true
# Rewrite WITHOUT the key but still in contract bytes.  The first version of this fixture filtered
# the lines and wrote them back with Set-Content -Encoding utf8, which re-introduced a BOM -- so the
# byte gate fired before the missing-key clause and the check silently tested the wrong thing.  A
# negative fixture must DELIBERATELY violate the clause under test and not inherit some other
# violation from the tool used to edit it.
$kept = @(Get-Content -LiteralPath (Join-Path $d5b 'PROVENANCE_COMPLETE.txt') | Where-Object { $_ -notmatch '^l2trans_masked_sha256=' })
[System.IO.File]::WriteAllText((Join-Path $d5b 'PROVENANCE_COMPLETE.txt'), (($kept -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
$r = Run-Harness @('-VerifyEvidence', ('"' + $d5b + '"'))
Check 'P5b manifest missing a required key refused' ($r.Rc -ne 0 -and $r.Blob -match 'manifest is missing key') ("rc=$($r.Rc) $($r.Blob)")

# ---- 6. malformed / corrupt PE --------------------------------------------------------------
$p6 = Join-Path $base 'p6'
New-Item -ItemType Directory -Force -Path $p6 | Out-Null
# long enough to pass the length gate, so the MZ clause is the one that fires (not "too short")
Set-Content -LiteralPath (Join-Path $p6 'notpe.bin') -Value ('this is not an executable, but it is comfortably longer than sixty-four bytes so the signature check is reached' * 1) -Encoding ASCII
$r = Run-Harness @('-PeInfo', ('"' + (Join-Path $p6 'notpe.bin') + '"'))
Check 'P6a non-PE refused by signature' ($r.Rc -ne 0 -and $r.Blob -match 'no MZ signature') ("rc=$($r.Rc) $($r.Blob)")

[System.IO.File]::WriteAllBytes((Join-Path $p6 'short.bin'), [byte[]](0x4D, 0x5A, 0x00))
$r = Run-Harness @('-PeInfo', ('"' + (Join-Path $p6 'short.bin') + '"'))
Check 'P6b truncated image refused' ($r.Rc -ne 0 -and $r.Blob -match 'too short to be a PE image') ("rc=$($r.Rc) $($r.Blob)")

$big = New-Object byte[] 256
$big[0] = 0x4D; $big[1] = 0x5A
[System.BitConverter]::GetBytes([uint32]99999).CopyTo($big, 0x3C)   # e_lfanew far past EOF
[System.IO.File]::WriteAllBytes((Join-Path $p6 'range.bin'), $big)
$r = Run-Harness @('-PeInfo', ('"' + (Join-Path $p6 'range.bin') + '"'))
Check 'P6c e_lfanew out of range refused' ($r.Rc -ne 0 -and $r.Blob -match 'e_lfanew out of range') ("rc=$($r.Rc) $($r.Blob)")

$nope = New-Object byte[] 256
$nope[0] = 0x4D; $nope[1] = 0x5A
[System.BitConverter]::GetBytes([uint32]64).CopyTo($nope, 0x3C)     # in range, but not a PE header
[System.IO.File]::WriteAllBytes((Join-Path $p6 'nosig.bin'), $nope)
$r = Run-Harness @('-PeInfo', ('"' + (Join-Path $p6 'nosig.bin') + '"'))
Check 'P6d missing PE signature refused' ($r.Rc -ne 0 -and $r.Blob -match 'no PE signature') ("rc=$($r.Rc) $($r.Blob)")

# ---- 7. the identity itself, against an INDEPENDENT implementation --------------------------
# These three values were computed by lmx_uds with its own masking code, not by this script, so
# agreement here is a cross-author check rather than a self-consistency one.  The first two are
# separate builds 27 minutes apart that must collapse to ONE masked value; the third is a build
# after the P2 source change and must differ from both.
foreach ($case in @(
    @{ Stamp = '20260921_114848'; Expect = '9253972A7DDA2DAC' },
    @{ Stamp = '20260921_121515'; Expect = '9253972A7DDA2DAC' },
    @{ Stamp = '20260921_134644'; Expect = '6A58A1ED43299265' })) {
    $f = Join-Path $RepoRoot ('build\l2_harness\' + $case.Stamp + '\bin\l2trans.exe')
    $r = Run-Harness @('-PeInfo', ('"' + $f + '"'))
    $gl = @($r.Blob -split "`n" | Where-Object { $_ -match 'masked_sha256=' } | Select-Object -First 1)
    $got = if ($gl.Count -ge 1) { ($gl[0] -replace '.*masked_sha256=', '').Trim() } else { '<none>' }
    Check ('P7 masked identity matches the independent implementation (' + $case.Stamp + ')') `
        ($r.Rc -eq 0 -and $got.StartsWith($case.Expect)) ("rc=$($r.Rc) got=$got expected=$($case.Expect)")
}

# ---- 8. the BYTE-LEVEL contract of the consumable manifest -----------------------------------
# The manifest is the interface to code that does not exist yet, so its bytes are the contract.  A
# BOM breaks the FIRST key; CRLF puts a trailing CR on nearly every VALUE.  Both are invisible to a
# reader that normalises them, which is why these assert on bytes rather than on a parse.
$d8 = Join-Path $base 'p8_bytes'
New-Evidence $d8 (Sha (Join-Path $Sandbox 'l2trans.lm1')) (Sha (Join-Path $Sandbox 'l2trans.lm1')) $true
$man8 = Join-Path $d8 'PROVENANCE_COMPLETE.txt'
$clean = [System.IO.File]::ReadAllBytes($man8)
$fixtureBom = ($clean.Length -ge 3 -and $clean[0] -eq 0xEF -and $clean[1] -eq 0xBB -and $clean[2] -eq 0xBF)
$fixtureCr = ([System.Array]::IndexOf($clean, [byte]0x0D) -ge 0)
Check 'P8a the probe writes a manifest with no BOM and no CR' (-not $fixtureBom -and -not $fixtureCr) `
    'the fixture manifest itself violates the contract, so nothing below could be trusted'

# [byte[]](0xEF,0xBB,0xBF).CopyTo(...) throws InvalidCastException here (the comma list is not
# cast down element-wise), so the prefix is assigned by index and the body copied with
# System.Array::Copy.
$bom = New-Object byte[] ($clean.Length + 3)
$bom[0] = 0xEF; $bom[1] = 0xBB; $bom[2] = 0xBF
[System.Array]::Copy($clean, 0, $bom, 3, $clean.Length)
[System.IO.File]::WriteAllBytes($man8, $bom)
$r = Run-Harness @('-VerifyEvidence', ('"' + $d8 + '"'))
Check 'P8b a BOM is refused' ($r.Rc -ne 0 -and $r.Blob -match 'begins with a UTF-8 BOM') ("rc=$($r.Rc) $($r.Blob)")

[System.IO.File]::WriteAllBytes($man8, $clean)
$crlf = [System.Text.Encoding]::UTF8.GetString($clean) -replace "`n", "`r`n"
[System.IO.File]::WriteAllBytes($man8, [System.Text.Encoding]::UTF8.GetBytes($crlf))
$r = Run-Harness @('-VerifyEvidence', ('"' + $d8 + '"'))
Check 'P8c a CR byte is refused' ($r.Rc -ne 0 -and $r.Blob -match 'contains a CR byte') ("rc=$($r.Rc) $($r.Blob)")

[System.IO.File]::WriteAllBytes($man8, $clean)
$r = Run-Harness @('-VerifyEvidence', ('"' + $d8 + '"'))
Check 'P8d restored contract bytes verify again (both directions)' ($r.Rc -eq 0 -and $r.Blob -match 'verify: PASS') ("rc=$($r.Rc) $($r.Blob)")

if ($EvidenceDir) {
    $real = Join-Path $EvidenceDir 'PROVENANCE_COMPLETE.txt'
    if (-not (Test-Path -LiteralPath $real)) { Check 'P8e real manifest present' $false ('not found: ' + $real) }
    else {
        $b = [System.IO.File]::ReadAllBytes($real)
        $txt = [System.Text.Encoding]::UTF8.GetString($b)
        $lines = @($txt -split "`n")
        $badKey = ''; $badVal = ''
        foreach ($ln in $lines) {
            if ($ln -eq '') { continue }
            if ($ln -notmatch '^([A-Za-z0-9_]+)=(.*)$') { $badKey = $ln.Substring(0, [Math]::Min(40, $ln.Length)); continue }
            if ($Matches[2].Contains("`r")) { $badVal = $Matches[1] }
        }
        Check 'P8e real manifest: no BOM' (-not ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF)) 'BOM present'
        Check 'P8f real manifest: no CR byte anywhere' ([System.Array]::IndexOf($b, [byte]0x0D) -lt 0) 'CR present'
        Check 'P8g real manifest: first key is exactly stamp' ($lines[0] -match '^stamp=') ("first line is " + $lines[0].Substring(0, [Math]::Min(30, $lines[0].Length)))
        Check 'P8h real manifest: no parsed key or value contains CR' ($badKey -eq '' -and $badVal -eq '') ("badKey=" + $badKey + " badVal=" + $badVal)
        $r = Run-Harness @('-VerifyEvidence', ('"' + $EvidenceDir + '"'))
        Check 'P8i real manifest passes -VerifyEvidence' ($r.Rc -eq 0) ("rc=$($r.Rc) $($r.Blob)")
    }
}

Remove-Item -Recurse -Force $base -ErrorAction SilentlyContinue
if ($fails -gt 0) { Write-Error "PROVENANCE PROBE RED: $fails"; exit 1 }
Write-Output 'PROVENANCE PROBE GREEN: 4 negative classes + positive control + cross-author identity'
exit 0
