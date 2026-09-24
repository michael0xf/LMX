# L2 translator harness: take a .lm2 fixture all the way to a running program, inside LMX.
#
# WHY THIS EXISTS.  tools\build_l2src.ps1 builds and runs the L2 KERNEL; it does not build
# l2trans and it never translates a .lm2 file.  dev\l2src_sandbox\run_self_build.ps1 is the L1
# chain.  So before this script the 280 fixtures under dev\l2src_sandbox\tests were reachable
# only by reading: nothing in the repository could say whether a generated program compiles, let
# alone what it does.  That is why LMX_ETERNAL_STORE.txt could record the eternal emission gap
# but not measure it, and it is the first blocker named there (LMX-L2-HARNESS-20260920-47U).
#
# THE CHAIN, and every step is inside LMX:
#   1. STAGE.  dev\l2src_sandbox\*.lm1 -> <out>\src\l2src\, and the KERNEL-SIDE
#      dev\l2src_sandbox\l1src\* -> <out>\src\l1src\.  Both translators resolve `predef:`
#      themselves, from the WORKING DIRECTORY -- gcc's -I has nothing to do with it -- so the
#      staged root is what makes `l2src/...` and `l1src/...` mean these files.  Standing anywhere
#      else resolves `l1src/libc_abi.lm1` against the repository root, which is the TRANSLATOR's
#      own set and does not declare l1_stderr; build_l2src.ps1 carries the same note, and the
#      same mistake is what the 28 probes were.
#   2. BUILD l2trans, from tracked sources and the pinned translator: l2trans.lm1 and l2_libc.lm1
#      through l1trans, then gcc.  l2_libc.lm1 is not optional -- the layer declares l1_stdout and
#      l1_stderr, and this unit is where their bodies are, so without it the link has no stderr.
#   3. RUN THE FIXTURES.  Each one: l2trans .lm2 -> generated .lm1; l1trans that -> .c; gcc; run.
#      A fixture declares how far it is expected to get, and getting further is as much a failure
#      as stopping early.
#   4. A GENERATED PROGRAM THAT USES THE KERNEL is run through a DRIVER
#      (dev\l2src_sandbox\harness\l2_eternal_driver.lm1).  Its C includes the kernel's headers
#      and expects the kernel's objects; the driver predefs the kernel's BODIES, so the driver's
#      one object IS that closure and no link resolver is needed.  The generated C is compiled
#      UNCHANGED, with two renames on the command line (main, lmx_root_close), so the driver
#      looks at the very root the generated main opened, after its turn and before its close.
#
# NEITHER TRANSLATOR SETS AN EXIT CODE ON A DIAGNOSTIC -- both print and return 0 (measured).  So
# a step here counts as done only if its OUTPUT FILE was produced, and the printed text is what
# names the reason when it was not.  Reading the exit code alone would call every refusal a pass.
#
# Artifacts go under build\, which is ignored; nothing here writes into the source tree, and
# nothing here reads C:\Nyasha_Planet\L1.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\l2_harness.ps1

param(
    [string]$OutDir, [string]$Translator,
    # ---- provenance mode (DEEPSEEK-L2TRANSLATOR-EVIDENCE-BUILDER-20260921-146) ----------------
    # -Provenance builds l2trans from a NAMED, hash-verified translator and leaves a consumable
    # provenance manifest.  There is no default translator, no bin\ fallback and no newest-stamp
    # selection in this mode: a chain that picks its own tool cannot testify about which tool it
    # was.  What this proves is DERIVED-TOOLCHAIN PROVENANCE and nothing more -- l2trans is not
    # self-hosting (it consumes .lm2 while its source is .lm1, so it never translates itself) and
    # no fixed-point claim is made or implied.
    [switch]$Provenance,
    # Required with -Provenance: the raw SHA256 the named translator must have, checked BEFORE any
    # staging or translation.
    [string]$ExpectedTranslatorSha256,
    # -ProvenanceCheckOnly runs the pre-work checks and stops before staging.  The negative probes
    # use it so that a refusal costs a second instead of a 30-row suite.
    [switch]$ProvenanceCheckOnly,
    # -VerifyEvidence <dir> re-checks an EXISTING evidence directory: its completion manifest must
    # be present, the artifact's identity must still be the recorded one, and the staged sources
    # must still be copies of the live ones.  A directory without a complete manifest is not
    # evidence, however green its transcript reads.
    [string]$VerifyEvidence,
    # -PeInfo <path> prints one file's raw and masked identity and refuses on anything that is not
    # a well-formed PE.  The mask offsets are derived from THAT file's e_lfanew.
    [string]$PeInfo
)
$ErrorActionPreference = 'Continue'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sandbox = Join-Path $root 'dev\l2src_sandbox'

# ---- PE identity ------------------------------------------------------------------------------
# e_lfanew is read from 0x3C FOR EACH FILE and is NOT a format constant: TDS sits at e_lfanew+8
# and the COFF CheckSum at e_lfanew+24+64.  Every one of the 46 binaries measured on 2026-09-21
# (44 l2trans.exe + both l1trans.exe) reports e_lfanew = 128, so hardcoding 136 and 216 WOULD
# WORK TODAY AND WOULD BE WRONG -- a refusal on an unusual header layout could not be explained.
# The offsets actually used are printed by -PeInfo and recorded in the manifest.
# Identity is the MASKED hash (stable across rebuilds of the same source); the RAW hash is for
# transport only, since 44 harness builds produced 44 distinct raw hashes for 20 distinct codes.
function Get-PeIdentity([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw ('pe: file not found: ' + $Path) }
    $b = [System.IO.File]::ReadAllBytes($Path)
    if ($b.Length -lt 64) { throw ('pe: too short to be a PE image (' + $b.Length + ' bytes): ' + $Path) }
    if ($b[0] -ne 0x4D -or $b[1] -ne 0x5A) { throw ('pe: no MZ signature: ' + $Path) }
    $e = [System.BitConverter]::ToUInt32($b, 0x3C)
    if ($e -lt 64 -or ($e + 92) -gt $b.Length) { throw ('pe: e_lfanew out of range (e_lfanew=' + $e + ', size=' + $b.Length + '): ' + $Path) }
    if ($b[$e] -ne 0x50 -or $b[$e + 1] -ne 0x45) { throw ('pe: no PE signature at e_lfanew=' + $e + ': ' + $Path) }
    $tds = [int]$e + 8
    $cs = [int]$e + 24 + 64
    $copy = [byte[]]$b.Clone()
    for ($i = 0; $i -lt 4; $i++) { $copy[$tds + $i] = 0; $copy[$cs + $i] = 0 }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $masked = ([System.BitConverter]::ToString($sha.ComputeHash($copy)) -replace '-', '').ToUpper()
    return [pscustomobject]@{
        Path = (Resolve-Path -LiteralPath $Path).Path
        Size = $b.Length
        Raw = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpper()
        Masked = $masked
        ELfanew = $e
        TdsOff = $tds
        CsOff = $cs
    }
}

if ($PeInfo) {
    $pi = Get-PeIdentity $PeInfo
    Write-Output ('pe: path=' + $pi.Path)
    Write-Output ('pe: size=' + $pi.Size)
    Write-Output ('pe: raw_sha256=' + $pi.Raw)
    Write-Output ('pe: masked_sha256=' + $pi.Masked)
    Write-Output ('pe: e_lfanew=' + $pi.ELfanew + ' tds_off=' + $pi.TdsOff + ' checksum_off=' + $pi.CsOff)
    exit 0
}

if ($VerifyEvidence) {
    $dir = (Resolve-Path -LiteralPath $VerifyEvidence).Path
    $manifest = Join-Path $dir 'PROVENANCE_COMPLETE.txt'
    if (-not (Test-Path -LiteralPath $manifest)) {
        throw ('verify: incomplete evidence -- no PROVENANCE_COMPLETE.txt in ' + $dir + ' (a transcript alone is not evidence)')
    }
    # BYTE-LEVEL CONTRACT, asserted on the BYTES and before any parsing: UTF-8 without BOM,
    # LF-only.  A BOM makes the first parsed key "﻿stamp"; a CRLF file leaves a trailing CR on
    # nearly every VALUE.  Both are invisible to a reader that normalises them -- and Get-Content,
    # which is exactly how this verifier reads, normalises BOTH.  That is why the check has to be
    # on the bytes rather than on whatever the parse happened to yield: a verifier that shares its
    # reader with the writer cannot see a difference the reader erases.
    $raw = [System.IO.File]::ReadAllBytes($manifest)
    if ($raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF) {
        throw ('verify: manifest begins with a UTF-8 BOM (EF BB BF); the contract is UTF-8 without BOM: ' + $manifest)
    }
    $crAt = [System.Array]::IndexOf($raw, [byte]0x0D)
    if ($crAt -ge 0) {
        throw ('verify: manifest contains a CR byte at offset ' + $crAt + '; the contract is LF-only: ' + $manifest)
    }
    $m = @{}
    foreach ($ln in (Get-Content -LiteralPath $manifest)) {
        if ($ln -match '^([A-Za-z0-9_]+)=(.*)$') { $m[$Matches[1]] = $Matches[2] }
    }
    foreach ($k in @('l2trans_masked_sha256', 'l2trans_path', 'source_dev_l2trans_sha256', 'source_staged_l2trans_sha256', 'source_dev_l2_libc_sha256', 'source_staged_l2_libc_sha256')) {
        if (-not $m.ContainsKey($k)) { throw ('verify: manifest is missing key ' + $k + ': ' + $manifest) }
    }
    $pi = Get-PeIdentity $m['l2trans_path']
    if ($pi.Masked -ne $m['l2trans_masked_sha256']) {
        throw ('verify: artifact identity differs from the manifest: ' + $pi.Masked + ' vs ' + $m['l2trans_masked_sha256'])
    }
    foreach ($pair in @(@('l2trans.lm1', 'source_dev_l2trans_sha256', 'source_staged_l2trans_sha256'),
                        @('l2_libc.lm1', 'source_dev_l2_libc_sha256', 'source_staged_l2_libc_sha256'))) {
        $live = Join-Path $sandbox $pair[0]
        $stagedF = Join-Path (Join-Path $dir 'src\l2src') $pair[0]
        if (-not (Test-Path -LiteralPath $stagedF)) { throw ('verify: staged source missing: ' + $stagedF) }
        $sh = (Get-FileHash -LiteralPath $stagedF -Algorithm SHA256).Hash.ToUpper()
        if ($sh -ne $m[$pair[2]]) { throw ('verify: staged bytes differ from what the run recorded for ' + $pair[0] + ': ' + $sh + ' vs ' + $m[$pair[2]]) }
        $lh = (Get-FileHash -LiteralPath $live -Algorithm SHA256).Hash.ToUpper()
        if ($lh -ne $m[$pair[1]]) { throw ('verify: LIVE source has changed since the run for ' + $pair[0] + ': ' + $lh + ' vs ' + $m[$pair[1]]) }
    }
    Write-Output ('verify: PASS -- ' + $dir + ' (artifact identity and both staged sources still agree with its manifest)')
    exit 0
}

# ---- provenance mode: the exact tool, verified BEFORE any work ---------------------------------
$provenanceMode = [bool]($Provenance -or $ProvenanceCheckOnly)
$tHash = ''
if ($provenanceMode) {
    if (-not $Translator) { throw 'provenance: -Translator is required (no default, no bin\ fallback, no newest)' }
    if (-not (Test-Path -LiteralPath $Translator)) { throw ('provenance: translator not found: ' + $Translator) }
    if (-not $ExpectedTranslatorSha256) { throw 'provenance: -ExpectedTranslatorSha256 is required' }
    if ($ExpectedTranslatorSha256 -notmatch '^[0-9A-Fa-f]{64}$') {
        throw ("provenance: -ExpectedTranslatorSha256 must be 64 hex, got '" + $ExpectedTranslatorSha256 + "'")
    }
    $tHash = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash.ToUpper()
    if ($tHash -ne $ExpectedTranslatorSha256.ToUpper()) {
        throw ('provenance: -ExpectedTranslatorSha256 mismatch BEFORE any work: got ' + $tHash + ' expected ' + $ExpectedTranslatorSha256.ToUpper())
    }
    if (-not $OutDir) { throw 'provenance: -OutDir is required (the fresh evidence directory)' }
    if (Test-Path -LiteralPath $OutDir) {
        if (@(Get-ChildItem -LiteralPath $OutDir -Force -ErrorAction SilentlyContinue).Count -gt 0) {
            throw ('provenance: -OutDir exists and is not empty; an evidence directory is fresh: ' + $OutDir)
        }
    }
    $Translator = (Resolve-Path -LiteralPath $Translator).Path
    Write-Output ('l2_harness: PROVENANCE mode; translator ' + $Translator + ' sha256 ' + $tHash + ' (verified against ExpectedTranslatorSha256 before any work)')
    if ($ProvenanceCheckOnly) {
        Write-Output 'l2_harness: PROVENANCE-CHECK-ONLY PASS (translator verified, evidence dir fresh); stopping before staging'
        exit 0
    }
}

if (-not $OutDir) { $OutDir = Join-Path $root ('build\l2_harness\' + (Get-Date -Format 'yyyyMMdd_HHmmss')) }

if (-not $Translator) { $Translator = Join-Path $root 'bin\l1trans.exe' }
if (-not (Test-Path -LiteralPath $Translator)) { throw "translator not found: $Translator" }
# The same pin the L2 gate applies, for the same reason: a harness whose toolchain drifts
# measures the toolchain, not the fixture.
if ($Translator -eq (Join-Path $root 'bin\l1trans.exe')) {
    $pinFile = Join-Path $root 'L1_PIN.txt'
    if (Test-Path -LiteralPath $pinFile) {
        $pin = ((Get-Content -LiteralPath $pinFile -Raw) -replace '\s', '')
        $got = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash
        if ($got -ne $pin.ToUpper()) { throw "translator pin mismatch: bin\l1trans.exe is $got, L1_PIN.txt says $pin" }
    }
}
$gcc = (Get-Command gcc -ErrorAction Stop).Source

# The append-as-you-go transcript (ticket -146).  It exists so a KILLED run still explains itself,
# and it is deliberately NOT the consumable artifact: consumption reads PROVENANCE_COMPLETE.txt,
# which is written atomically and only when every row passed.  One file serving both purposes would
# leave a killed run with something a consumer might parse.
# DEFINED HERE, ABOVE ITS FIRST USE ON PURPOSE: PowerShell resolves a function name at RUNTIME, so a
# definition placed after the directory setup is not in scope yet and every call before it fails
# with CommandNotFoundException -- measured, and the failure is SILENT if the call's output is not
# checked: the manifest simply omitted the stamp, git head and l1trans identity lines and was still
# written.  That is what the required-key gate below now refuses.
$script:provLines = @()
$script:provLog = $null
function Prov-Line([string]$Text) {
    $script:provLines += $Text
    if ($script:provLog) { Add-Content -LiteralPath $script:provLog -Value $Text -Encoding utf8 }
}
$src = Join-Path $OutDir 'src'
$gen = Join-Path $OutDir 'gen'
$bin = Join-Path $OutDir 'bin'
$logs = Join-Path $OutDir 'logs'
foreach ($d in @($src, (Join-Path $src 'l2src'), (Join-Path $src 'l1src'), $gen, $bin, $logs)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
if ($provenanceMode) {
    $script:provLog = Join-Path $OutDir 'provenance.log'
    # This file keeps Set-Content -Encoding utf8 DELIBERATELY: it is the non-consumable transcript,
    # the encoding contract applies to PROVENANCE_COMPLETE.txt alone, and normalising this one too
    # would imply it is meant to be parsed.  Its first line says what it is for.
    Set-Content -LiteralPath $script:provLog -Value '# provenance transcript -- debuggable, NEVER consumable; read PROVENANCE_COMPLETE.txt instead' -Encoding utf8
    Prov-Line ('stamp=' + (Split-Path -Leaf $OutDir))
    Prov-Line ('git_head=' + ((git -C $root rev-parse HEAD) -join ''))
    Prov-Line ('tracked_modified=' + @(git -C $root status --porcelain -uno).Count)
    Prov-Line ('l1trans_path=' + $Translator)
    Prov-Line ('l1trans_raw_sha256=' + $tHash)
    Prov-Line ('l1trans_masked_sha256=' + (Get-PeIdentity $Translator).Masked)
    Prov-Line ('l1trans_verified_by=ExpectedTranslatorSha256')
}

$rows = @()
$red = @()
function Add-Row([string]$State, [string]$Label, [string]$Note) {
    $script:rows += [pscustomobject]@{ State = $State; Label = $Label; Note = $Note }
    if ($State -eq 'FAIL') { $script:red += ($Label + ': ' + $Note) }
}
function Safe([string]$Name) { return ($Name -replace '[^A-Za-z0-9_.-]', '_') }

# Run a command, capture everything, return the exit code; the transcript is the evidence.
function Invoke-Step([string]$Label, [string]$Exe, [string[]]$ArgList, [string]$WorkDir) {
    # THE OUTPUT IS NEVER HELD IN MEMORY -- the same fix as tools/build_l2src.ps1's Invoke-Captured,
    # and the same reason: `| Out-String` built each command's whole output as one string and then a
    # second copy to prepend the header. This harness inherited the shape because it was modelled on
    # that gate, so the defect travelled by copying.
    #
    # The header cannot carry the exit code any more, because the child appends to the file while it
    # runs and the code is only known afterwards -- so the exit line is APPENDED at the end instead.
    # Step-Made and the callers read the return value, not the log, so nothing depends on where it sits.
    $log = Join-Path $logs ((Safe $Label) + '.log')
    $head = 'command: "' + $Exe + '" ' + ($ArgList -join ' ') + [Environment]::NewLine + 'cwd: ' + $WorkDir
    Set-Content -LiteralPath $log -Value $head -Encoding utf8
    $here = (Get-Location).Path
    Set-Location $WorkDir
    # argv stays an ARRAY: paths here contain spaces, and Start-Process -ArgumentList would rejoin them.
    # `*>>` IS WRONG HERE AND WAS MEASURED WRONG: PS 5.1 appends through it in UTF-16LE
    # while the header above is UTF-8, so the log became a mixed-encoding file and every
    # diagnostic in it read as mojibake.  Out-File -Append streams the pipeline one record
    # at a time -- it does NOT accumulate like Out-String -- and honours -Encoding.
    & $Exe @ArgList 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
    $code = $LASTEXITCODE
    Set-Location $here
    Add-Content -LiteralPath $log -Value ('exit: ' + $code) -Encoding utf8
    return $code
}
# A translator step is judged by its OUTPUT, never by its exit code (see the header).
function Step-Made([string]$Label, [string]$Exe, [string[]]$ArgList, [string]$WorkDir, [string]$Product) {
    if (Test-Path -LiteralPath $Product) { Remove-Item -LiteralPath $Product -Force }
    Invoke-Step $Label $Exe $ArgList $WorkDir | Out-Null
    return (Test-Path -LiteralPath $Product)
}
function Log-Text([string]$Label) {
    $log = Join-Path $logs ((Safe $Label) + '.log')
    if (Test-Path -LiteralPath $log) { return ((Get-Content -LiteralPath $log -Raw)) }
    return ''
}
# THE EMITTER-ORDER ASSERTION OF THE STICKY RULE, read off the generated L1 and not off a run.
# Any executed @x sets sticky unconditionally; the selector (active) is the publication target.
# Never-bound activations must not publish: sticky without active == this occurrence is a no-op.
# What IS checkable, for every own field N that carries sticky/active:
#   1. no early/bound flags remain;
#   2. `l2_qN_sticky: 1` is an unguarded assignment at the address site, and from there to
#      `@ l2_p...` nothing resolves the cell;
#   3. `l2_qN_from:` is followed by `l2_qN_active:` (or another occurrence's active) before a call.
function Test-BindOrder([string]$L1) {
    $lines = @($L1 -split "`r?`n" | ForEach-Object { $_.Trim() })
    $owns = @([regex]::Matches($L1, '(?m)^\s*int: l2_q(\d+)_sticky 0\s*$') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
    if ($owns.Count -eq 0) { return 'no own field carries the sticky flag' }
    foreach ($n in $owns) {
        $q = 'l2_q' + $n
        if ($L1 -match [regex]::Escape($q + '_early') -or ($L1 -match ($q + '_bound'))) { return ($q + ': early/bound flags must be gone') }
        $sticks = 0
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $ln = $lines[$i]
            if ($ln -ceq ($q + '_sticky: 1')) {
                $sticks++
                if ($i -ge 1 -and ($lines[$i - 1] -match '_bound|_early')) { return ($q + ': sticky is still guarded by bound/early (line ' + ($i + 1) + ')') }
                $used = $false
                for ($k = $i + 1; $k -lt $lines.Count -and -not $used; $k++) {
                    if ($lines[$k].StartsWith($q + '_from: ')) { return ($q + ': taking the address resolves the cell (line ' + ($k + 1) + ')') }
                    if ($lines[$k] -match '@ l2_p\d+_\d+') { $used = $true }
                }
                if (-not $used) { return ($q + ': sticky with no use of the address after it (line ' + ($i + 1) + ')') }
            }
            if ($ln.StartsWith($q + '_from: ')) {
                $closed = $false
                for ($k = $i + 1; $k -lt $lines.Count -and $k -le $i + 20; $k++) {
                    if ($lines[$k] -match 'l2_q\d+_active:') { $closed = $true; break }
                    if ($lines[$k] -match 'l2_m\d+\(' -or $lines[$k] -ceq ($q + '_sticky: 1')) { break }
                }
                if (-not $closed) { return ($q + ': the cell is resolved outside a binding site (line ' + ($i + 1) + ')') }
            }
        }
        if ($sticks -eq 0) { return ($q + ': carries sticky but never raises it') }
    }
    return ''
}

Write-Output ('l2_harness on ' + ((git -C $root rev-parse HEAD) -join '').Substring(0, 8) + '; translator ' + $Translator + '; gcc ' + $gcc)
Write-Output ('l2_harness: evidence ' + $OutDir)

# ---- 1. stage -------------------------------------------------------------------------------
$staged = 0
foreach ($f in @(Get-ChildItem -LiteralPath $sandbox -File -Filter '*.lm1')) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l2src\' + $f.Name)) -Force; $staged++
}
foreach ($f in @(Get-ChildItem -LiteralPath (Join-Path $sandbox 'l1src') -File)) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l1src\' + $f.Name)) -Force; $staged++
}
# tests/*.h.lm1 headers (e.g. fnptr_local_forms) for fixture predef under cwd=$src
$testsHdr = Join-Path $sandbox 'tests'
if (Test-Path -LiteralPath $testsHdr) {
    $destTests = Join-Path $src 'l2src\tests'
    New-Item -ItemType Directory -Force -Path $destTests | Out-Null
    foreach ($f in @(Get-ChildItem -LiteralPath $testsHdr -File -Filter '*.h.lm1')) {
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $destTests $f.Name) -Force; $staged++
    }
}
Write-Output ('l2_harness: staged ' + $staged + ' files into ' + $src)
if ($provenanceMode) {
    # The staged l2src\l2trans.lm1 and l2_libc.lm1 must be BYTE COPIES of the LIVE dev sandbox
    # sources, never the frozen root l2src twin.  This matters because the translator is handed the
    # RELATIVE literal 'l2src/l2trans.lm1' with cwd = $src, so which twin built the translator is
    # decided by this copy alone, and nothing about the literal says so.
    foreach ($s in @(@('l2trans.lm1', 'l2trans'), @('l2_libc.lm1', 'l2_libc'))) {
        $live = Join-Path $sandbox $s[0]
        $stagedFile = Join-Path (Join-Path $src 'l2src') $s[0]
        if (-not (Test-Path -LiteralPath $live)) { throw ('provenance: live source missing: ' + $live) }
        if (-not (Test-Path -LiteralPath $stagedFile)) { throw ('provenance: staged source missing: ' + $stagedFile) }
        $lh = (Get-FileHash -LiteralPath $live -Algorithm SHA256).Hash.ToUpper()
        $sh = (Get-FileHash -LiteralPath $stagedFile -Algorithm SHA256).Hash.ToUpper()
        if ($lh -ne $sh) { throw ('provenance: staged ' + $s[0] + ' is not a copy of the live source: ' + $sh + ' vs ' + $lh) }
        Prov-Line ('source_dev_' + $s[1] + '_sha256=' + $lh)
        Prov-Line ('source_staged_' + $s[1] + '_sha256=' + $sh)
    }
    Prov-Line ('source_origin=dev/l2src_sandbox')
}

# ---- 2. build l2trans -----------------------------------------------------------------------
$cflags = @('-std=c99', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $sandbox)
$l2transC = Join-Path $gen 'l2trans.c'
$l2libcC = Join-Path $gen 'l2_libc.c'
$l2libcO = Join-Path $gen 'l2_libc.o'
$l2trans = Join-Path $bin 'l2trans.exe'
$built = $true
if (-not (Step-Made 'build.l2trans.translate' $Translator @('l2src/l2trans.lm1', $l2transC) $src $l2transC)) {
    Add-Row 'FAIL' 'build:l2trans translate' 'l1trans produced no C; see the log'; $built = $false
}
if ($built -and -not (Step-Made 'build.l2_libc.translate' $Translator @('l2src/l2_libc.lm1', $l2libcC) $src $l2libcC)) {
    Add-Row 'FAIL' 'build:l2_libc translate' 'l1trans produced no C; see the log'; $built = $false
}
if ($built) {
    $code = Invoke-Step 'build.l2_libc.compile' $gcc ($cflags + @('-c', $l2libcC, '-o', $l2libcO)) $root
    if ($code -ne 0) { Add-Row 'FAIL' 'build:l2_libc compile' "gcc exit $code"; $built = $false }
}
if ($built) {
    $code = Invoke-Step 'build.l2trans.link' $gcc ($cflags + @('-o', $l2trans, $l2transC, $l2libcO)) $root
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $l2trans)) { Add-Row 'FAIL' 'build:l2trans link' "gcc exit $code"; $built = $false }
}
if ($built) {
    Add-Row 'OK' 'build:l2trans' ('sha256 ' + (Get-FileHash -LiteralPath $l2trans -Algorithm SHA256).Hash.Substring(0, 16))
} else {
    if ($provenanceMode) { Prov-Line 'build_failed=1 (l2trans itself did not build; no completion manifest is written)' }
    Write-Output ''
    Write-Output ('l2_harness RED: l2trans itself did not build; evidence ' + $OutDir)
    exit 1
}
if ($provenanceMode -and $built) {
    # Get-PeIdentity REFUSES on a malformed artifact here, so a corrupt l2trans.exe ends the run
    # rather than being recorded with a blank identity.
    $pi = Get-PeIdentity $l2trans
    Prov-Line ('gen_l2trans_c_sha256=' + (Get-FileHash -LiteralPath $l2transC -Algorithm SHA256).Hash.ToUpper())
    Prov-Line ('gen_l2_libc_c_sha256=' + (Get-FileHash -LiteralPath $l2libcC -Algorithm SHA256).Hash.ToUpper())
    Prov-Line ('gcc_path=' + $gcc)
    Prov-Line ('gcc_version=' + ((& $gcc --version | Select-Object -First 1) -join ''))
    Prov-Line ('cmd_translate_l2trans=' + $Translator + ' l2src/l2trans.lm1 ' + $l2transC + ' (cwd ' + $src + ')')
    Prov-Line ('cmd_translate_l2_libc=' + $Translator + ' l2src/l2_libc.lm1 ' + $l2libcC + ' (cwd ' + $src + ')')
    Prov-Line ('cmd_compile_l2_libc=' + $gcc + ' ' + (($cflags + @('-c', $l2libcC, '-o', $l2libcO)) -join ' ') + ' (cwd ' + $root + ')')
    Prov-Line ('cmd_link_l2trans=' + $gcc + ' ' + (($cflags + @('-o', $l2trans, $l2transC, $l2libcO)) -join ' ') + ' (cwd ' + $root + ')')
    Prov-Line ('l2trans_path=' + $pi.Path)
    Prov-Line ('l2trans_size=' + $pi.Size)
    Prov-Line ('l2trans_raw_sha256=' + $pi.Raw)
    Prov-Line ('l2trans_masked_sha256=' + $pi.Masked)
    Prov-Line ('l2trans_e_lfanew=' + $pi.ELfanew)
    Prov-Line ('mask_offsets=tds:' + $pi.TdsOff + ',checksum:' + $pi.CsOff)
}

# ---- 2b. the kernel's headers and the driver of generated programs ----------------------------
# Generated C says #include "l2src/<unit>.lm1.h" or "l1src/<unit>.lm1.h" (FABLE-SONNET-PREDEF-
# RESULT-TYPE-20260924-160: l1src/own.h.lm1, the first .h.lm1 prototype header outside l2src\, is
# what surfaced the gap -- this loop only ever staged l2src\'s headers, so any fixture whose
# generated C reached gcc while predef'ing an l1src\*.h.lm1 header got "No such file or directory"
# there, never before hit since no earlier fixture's predef chain reached gcc through one): every
# staged header, in EITHER directory, is translated once, to <out>\headers\l2src\ or
# <out>\headers\l1src\ respectively.  The driver is staged NEXT TO l2src\, not inside it: it is
# not a unit.
$headers = Join-Path $OutDir 'headers'
New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l2src') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l1src') | Out-Null
# -Werror=implicit-function-declaration (-159 commit 2b): a generated unit that calls a kernel act it
# never declared (a missing predef) is refused here, not compiled with an implicit int return -- which
# truncates a returned pointer to 32 bits.
$kflags = @('-std=c99', '-Werror=implicit-function-declaration', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $src, '-I', $headers)
$driverSource = Join-Path $sandbox 'harness\l2_eternal_driver.lm1'
$driverC = Join-Path $gen 'l2_eternal_driver.c'
$driverO = Join-Path $gen 'l2_eternal_driver.o'
$driver = $true
$made = 0
foreach ($hdrDir in @('l2src', 'l1src')) {
    foreach ($h in @(Get-ChildItem -LiteralPath (Join-Path $src $hdrDir) -File -Filter '*.h.lm1' | Sort-Object Name)) {
        $base = $h.Name.Substring(0, $h.Name.Length - '.h.lm1'.Length)
        $target = Join-Path $headers ($hdrDir + '\' + $base + '.lm1.h')
        if (Step-Made ('header.' + $hdrDir + '.' + $base) $Translator @(($hdrDir + '/' + $h.Name), $target) $src $target) { $made++ }
        else { Add-Row 'FAIL' ('header:' + $hdrDir + '.' + $base) 'l1trans produced no header; see the log'; $driver = $false }
    }
}
if (-not (Test-Path -LiteralPath $driverSource)) { Add-Row 'FAIL' 'build:eternal_driver' 'driver source is missing'; $driver = $false }
if ($driver) {
    Copy-Item -LiteralPath $driverSource -Destination (Join-Path $src 'l2_eternal_driver.lm1') -Force
    if (-not (Step-Made 'build.eternal_driver.translate' $Translator @('l2_eternal_driver.lm1', $driverC) $src $driverC)) {
        Add-Row 'FAIL' 'build:eternal_driver translate' 'l1trans produced no C; see the log'; $driver = $false
    }
}
if ($driver) {
    $code = Invoke-Step 'build.eternal_driver.compile' $gcc ($kflags + @('-c', $driverC, '-o', $driverO)) $root
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $driverO)) { Add-Row 'FAIL' 'build:eternal_driver compile' "gcc exit $code"; $driver = $false }
}
if ($driver) { Add-Row 'OK' 'build:eternal_driver' ($made.ToString() + ' kernel headers; the driver object is the kernel closure') }

# ---- 3. the fixtures ------------------------------------------------------------------------
# `Expect` says how far this fixture is supposed to get, and each value is a claim about the
# translator, not about this script:
#   l2trans-refuses      -- l2trans must REFUSE it; Needle must appear in what it printed.
#   translates-with-debt -- the whole translator chain succeeds, AND the generated L1 is then
#                           read: every string in Absent must be GONE from it and every string
#                           in Debt must still be THERE.  This is for a gap that no longer stops
#                           the toolchain but is not fixed, and the asymmetry is the point.  No
#                           row uses it today; the kind stays for the next such gap.
#   eternal-runs         -- a program with `independent: const: immutable` branches.  The
#                           generated L1 is read (Absent / Debt, as above -- here Debt is simply
#                           what must be there), and then the program RUNS under the driver,
#                           which is given Args: the number of roots and facts about them (the
#                           driver's header lists the words).  Exit 0 or the row is red.
#   library-links        -- a unit translated in the LIBRARY PROFILE (`l2trans --library`), together
#                           with the units named in With.  Each is translated and compiled, its
#                           external definitions are read with nm, and the objects are joined in
#                           ONE relocatable link.  LINK AND SYMBOLS ONLY: nothing is run.  The
#                           profile is SELECTED here, never inferred from what the unit lacks: L2
#                           has no `main` (S2), so a unit of methods alone is also a program.
#   toolchain-refuses    -- l2trans MUST accept and emit L1; Absent strings must be GONE from that
#                           L1 (no silent patch); then l1trans or gcc MUST refuse.  Used when the
#                           unit omits a required include/predef and the C toolchain is the judge.
#
# THE ENTRY (S2).  An L2 program is its unit body from the first line.  The translator states in the
# generated L1 how many top-level statements the entry executes, as one line `# entry statements: N`.
# An `eternal-runs` row whose unit has none is red unless the row says EmptyEntry = $true:
# a program that executes nothing proves nothing, and before S2 a unit without `main` was silently a
# library.  `Entry` is the int the entry returns (the program's value, E1; default 0); the driver
# checks the exit value and the adapter's own result against it.
#
# WHY THESE ROWS READ THE GENERATED L1 AS WELL AS RUN IT. Qualified immutable roots are ordinary
# values of the current Message arena. Their type and lifetime come from exact physical profile
# ranges which are sealed after construction. The generated program unit becomes Message.graph;
# its private tail holds the Thread's existing growable children Array, so this is the standard
# graph shape rather than a Root-only slot. A translation-sized C array exports the exact root
# references in lexical order solely for black-box observation by this harness.
#
# The text pins the physical profiles, profiled allocations, sealing, exact root-ref export and
# graph publication, while forbidding the removed permanent-store/fixed-root-slot protocol. The
# run checks kind, type, owner arena, distinct profile identity, parentlessness, field values and
# cross-references after the generated turn and again after an explicit owner-arena collection.
# The exported pointers are valid only while that Root is open; root_close releases the arena.
#
# Sharing tools/build_l2src.ps1's Resolve-Link with this script is still the way to run a
# generated program against the kernel's separate OBJECTS; the driver does not replace that, it
# makes the question answerable before it exists.
$fixtures = @(
    [pscustomobject]@{ Name = 'entry_return7.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    # F-30 gap: os: block under the eternal driver; l2_emit_os_fn pins the X1 prologue
    # (invariant + abort), success is Entry 7 (not return: 0 alone).
    [pscustomobject]@{ Name = 'unit_os_prologue.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT',
                   "if: self = 0`n        return", "if: self = 0`n        l2_out_result");
        Debt = @('os:',
                 'fn: l2_m0 (@: Lmx node; @: Lmx self) @: char',
                 'c.fprintf(c.stderr, "lmx: invariant: a method was entered without its occurrence\n")',
                 'c.abort()',
                 'return: "win32"',
                 'return: "pthread"') },

    # S2: there is no standalone L1-only program any more -- every program is its unit, E runs in
    # R0 -- so the c.puts entries run on the kernel route, and say what they print.  The empty
    # line of entry_puts_empty is not countable by Says (blank lines are not the program's).
    [pscustomobject]@{ Name = 'entry_puts_hello.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Says = @('Hello'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_seq.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Says = @('one', 'two'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_empty.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_nl.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Says = @('x', 'y'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_esc.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Says = @('a"b\c'); Absent = @(); Debt = @() },
    # FABLE-126 part2: migrate/gate former c.array entry fixtures (owned []: char).
    [pscustomobject]@{ Name = 'entry_array.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an array'; Args = @('0'); Absent = @('c.array'); Debt = @() },
    [pscustomobject]@{ Name = 'entry_array_leading_zero.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an array'; Args = @('0'); Absent = @('c.array'); Debt = @() },
    [pscustomobject]@{ Name = 'entry_nul.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an array'; Args = @('0'); Absent = @('c.array'); Debt = @() },
    # THE UNIT IS THE ENTRY (FABLE-OPUS-S2-UNIT-IS-ENTRY-20260923-112).  Every non-callable is
    # visible only after its declaration, methods both ways.  unit_s2_vis_dynamic: a method ABOVE a
    # unit field cannot see it, so the name is its dynamic input, handed over by its caller (wrap's
    # own n = 7); a translator that lets the method see the unit field below it reads 3 and the
    # program returns 1 (the visibility mutant, measured).  The three refusals are the same rule
    # for a Structure named by a unit statement, a Structure named by a method signature, and a
    # qualified branch named by a method body.  An empty entry is an empty program (EmptyEntry).
    # A stray trailer after a closed frame is an item since the P0 change of -114 and is refused
    # by name.
    [pscustomobject]@{ Name = 'unit_s2_vis_dynamic.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @();
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx self; int: l2_p0_0) int', 'l2_t1: l2_m0(l2_c0\parent, l2_c0, l2_q0)') },
    [pscustomobject]@{ Name = 'unit_s2_vis_structure_below_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s2_vis_signature_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s2_vis_branch_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s2_empty_program.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 1; Needle = ''; Args = @('0'); EmptyEntry = $true;
        Absent = @(); Debt = @('# entry statements: 0') },
    [pscustomobject]@{ Name = 'unit_s2_stray_end_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'stray trailer: the frame above is already closed'; Absent = @(); Debt = @() },
    # S3 (FABLE-OPUS-S3-MAIL-ARGS-20260923-122, author Q10): C main posts argv to R0 inside ONE
    # letter; `receiveMessage: m` takes the next admitted letter of the current Thread (0 when the
    # inbox is empty).  Every eternal-runs row checks at close how many letters R0 still holds
    # (`Letters`, default 1: the argv letter untaken) and that close released them (P5).
    [pscustomobject]@{ Name = 'unit_next_message_twice.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @('l2_nmsg: (cast: (@: LmxMsg) lmx_thread_mail_take(lmx_thread_current(), c.LMX_POST_INBOX))') },
    [pscustomobject]@{ Name = 'unit_next_message_loop.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_in_method.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_method_first.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0');
        Absent = @('lmx_thread_mail_take'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_one_name.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'receiveMessage binds one name'; Absent = @(); Debt = @() },
    # FABLE-SONNET-RECEIVE-RENAME-20260924-166 commit 1: `nextMessage` is no longer a language
    # word (renamed to `receiveMessage`) -- `nextMessage: m` is now an ordinary colon-assignment
    # to an undeclared name, refused like any other (measured: not "unknown method" -- the shape
    # is an assignment target, not a call).
    [pscustomobject]@{ Name = 'unit_next_message_word_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    # ADMISSION (fable's B2, author Q12): an untyped graph -- the letter receiveMessage takes -- bound
    # to a declared Structure type (receiveMessage into a typed own field, rebinding it, a typed
    # formal's argument) is admitted at run time by the kernel's implements walk against the
    # declared type's shape; a refusal throws the implicit name implements (Q17 = A; g = 2, where a
    # failing merge is 1), and uncaught (`Fails`) the entry has no value, exit 1.  MainLetter is an
    # ordinary declared Structure (author Q15).
    [pscustomobject]@{ Name = 'unit_admit_letter_typed.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Argv = @('a', 'b');
        Absent = @(); Debt = @('lmx_runtime_implements(l2_program_arena, (cast: (@: Lmx) l2_ngraph)') },
    [pscustomobject]@{ Name = 'unit_admit_letter_formal.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_letter_not_model.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_formal_refused.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0; Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_rebind_refused.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_letter_extra_field.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # KNOWN COARSENESS (next_core_tasks.md 7): the walk does not look inside the outer Array, so an
    # `int: []: []:` field admits the char letter.  This row flips to Fails with the port.
    [pscustomobject]@{ Name = 'unit_admit_letter_coarse.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    # `T: []: []: x` (author Q15): the outer Array is constructed empty and merge copies it as a new one.
    [pscustomobject]@{ Name = 'unit_arrarr_field.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a Structure value'; Args = @('0');
        Absent = @(); Debt = @('lmx_array_ref_new_owned(c.LMX_TYPE_ARRAY_OF_DESC, 0U, l2_program_arena)') },
    # INDEXED FIELD PATHS (S3 part 2b): root\seg...[k] / [k][j] into an Array field of a declared
    # type through a typed root; `@` before an element addresses it in graph storage; length() on
    # both levels.  The former formal-`main` fixtures now read argv from the letter (mainArgs);
    # `{source}` in Argv is this fixture's own path.
    [pscustomobject]@{ Name = 'unit_arr_path_read.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0');
        Absent = @(); Debt = @() },
    # D-06: a failed receiveMessage or rebinding store is an invariant on the X1 route, not a printed line.
    [pscustomobject]@{ Name = 'unit_admit_rebind_read.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Argv = @('ok'); Entry = 2;
        Absent = @('lmx_msg_poll_abort', 'lmx: receiveMessage', 'lmx: rebinding');
        Debt = @('c.fprintf(c.stderr, "lmx: invariant: receiveMessage store failed for own field ', 'c.fprintf(c.stderr, "lmx: invariant: rebinding store failed for own field ') },
    [pscustomobject]@{ Name = 'entry_argc_if.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_index.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Argv = @('word'); Says = @('word');
        Absent = @(); Debt = @('c.puts(@ l2_cp') },
    [pscustomobject]@{ Name = 'entry_strcmp.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Argv = @('ok');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_charpp_return.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_entry_args.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0; Entry = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_parse_min.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Letters = 0; Argv = @('{source}');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_untyped_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs a root of a declared Structure type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_variable_index_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_inner_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an inner Array is a value only inside length()'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_bounds_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_three_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_argc.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Letters = 0; Argv = @('one', 'two');
        Absent = @(); Debt = @() },
    # The former main-signature refusals test ordinary method formals now (L2 has no main, S2).
    [pscustomobject]@{ Name = 'entry_argc_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_argc_dup.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'duplicate formal'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_bad_sig.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_two_main.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'duplicate definition'; Absent = @(); Debt = @() },
    # The unit's fields are E's own fields: a second typed declaration of one name in one scope is
    # refused, at unit level as in a method body (before S2 only the unit said so).  And E is the
    # root of every activation: a callee's dynamic input that E does not bind stops at E and is
    # resolved at the call by the callee's lexical fallback, as it was from `main`.
    [pscustomobject]@{ Name = 'unit_root_field_duplicate.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'duplicate declaration'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_asgn_fallback.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method with dynamic inputs'; Args = @('0');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    # One return-literal rule for every callable: an int result literal must fit int in a lone
    # main (literal and full body), in main beside a method (body and trailer), and in a method.
    [pscustomobject]@{ Name = 'entry_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_literal_body_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_literal_entry_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_literal_trailer_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_literal_method_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_literal_int_max.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @('return: 2147483647') },
    # T1b literal-range at every conversion point (FABLE-GROKBOT-LITERAL-RANGE-AND-FORMAL-TYPES-20260922-106 PART1).
    [pscustomobject]@{ Name = 'unit_lit_range_decl_int_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_asgn_int_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_arg_int_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_decl_unsigned_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as unsigned'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_decl_char_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as char'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_decl_size_t_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as size_t'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_decl_ulong_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as ulong'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_ret_unsigned_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as unsigned'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_bounds_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @('2147483647', '4294967295U') },
    [pscustomobject]@{ Name = 'unit_formal_unknown_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },
    # D-28 (steps/defects.md): a formal parameter must shadow a unit-level
    # named Structure sharing its spelling -- l2_path_root tried the wrong
    # one first since -113.
    [pscustomobject]@{ Name = 'unit_formal_shadows_struct.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_file_bare_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },

    [pscustomobject]@{ Name = 'unit_eternal_branch.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an eternal branch among the root''s fields';
        Args = @('1', 'size', '0', '0', '7');
        Absent = @('lmx_owned_ranges', 'lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained',
                   'DEBT: eternal ranges/bootstrap-admit absent in new kernel',
                   'DEBT: eternal bootstrap-admit / eternal-ranges absent',
                   'DEBT: eternal array bootstrap-admit / eternal-ranges absent',
                   'l2_nsp[0]: lmx_node_new_owned(l2_program_arena)',
                   'not yet in R0''s retention array',
                   'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [1]: @: Lmx l2_program_qualified_roots',
                 'l2_nsp[0]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'slot[0]: lmx_arena_take_profiled(l2_program_arena, c.sizeof(c.size_t), c.LMX_KIND_PRIMITIVE, c.LMX_TYPE_SIZE_T, l2_eprofile0)',
                 'if: l2_profile_pool = 0 || lmx_pool_seal(l2_profile_pool) != 0',
                 'l2_entry_unit: graph',
                 'if: lmx_root_open(@ l2_program_root, l2_program_entry, 5000U) != c.LMX_ROOT_OK') },
    [pscustomobject]@{ Name = 'unit_eternal_two.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an eternal branch among the root''s fields';
        Args = @('2', 'size', '0', '0', '7', 'size', '1', '0', '9');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [2]: @: Lmx l2_program_qualified_roots',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 'l2_eprofile1: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'l2_entry_unit: graph') },
    # Seventy roots: the capacity is the COUNT.  Sizing by a root's INDEX -- the trap the two
    # tables invite, l2_ns_eternal[k] beside l2_ebr_n -- would pass every smaller fixture's text.
    [pscustomobject]@{ Name = 'unit_eternal_many.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an eternal branch among the root''s fields';
        Args = @('70', 'size', '0', '0', '1', 'size', '35', '0', '36', 'size', '69', '0', '70');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [70]: @: Lmx l2_program_qualified_roots',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[69U]: l2_nsp[69]',
                 'l2_eprofile69: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'l2_entry_unit: graph') },
    # A nested member, a reference to the branch itself, a reference to the OTHER branch, and a
    # mutable Holder beside them: two roots are retained, the nested member and Holder are not.
    [pscustomobject]@{ Name = 'unit_eternal_shape.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('2', 'size', '0', '0', '7', 'size', '0', '4', '13', 'same', '0', '3', '0', 'same', '1', '0', '0', 'size', '1', '1', '17');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [2]: @: Lmx l2_program_qualified_roots',
                 'l2_nsp[1]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[1U]: l2_nsp[2]',
                 'l2_entry_unit: graph') },
    # A cross-reference INTO another branch: F\into is E's member `deep`, not a copy of it.
    [pscustomobject]@{ Name = 'unit_eternal_xref.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('2', 'slot', '1', '0', '0', '0', 'size', '0', '1', '7', 'size', '1', '1', '23');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [2]: @: Lmx l2_program_qualified_roots',
                 'l2_nsp[1]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[1U]: l2_nsp[2]',
                 'l2_entry_unit: graph') },
    # Array records/backing and merge sites use the same exact profiled owner ranges.
    [pscustomobject]@{ Name = 'unit_array_empty.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a Structure value';
        Args = @('1');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [1]: @: Lmx l2_program_qualified_roots',
                 'l2_profile_array: (cast: (@: LmxArrayDesc) lmx_arena_take_profiled',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_array_field.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('1');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [1]: @: Lmx l2_program_qualified_roots',
                 'l2_profile_array: (cast: (@: LmxArrayDesc) lmx_arena_take_profiled',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_merge_site.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('3');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [3]: @: Lmx l2_program_qualified_roots',
                 'l2_program_qualified_roots[2U]: l2_nsp[2]',
                 'lmx_merge_profiles_owned',
                 'l2_entry_unit: graph') },
    # FABLE-OPUS-MERGE-ADDRESSING-20260924-154 commit 2 (the author's merge rule, plan §4): a name
    # several operands carry is its LAST occurrence -- `R\x` is `R\[lastIndex]x`, the override, for
    # reads and writes -- and `R\[N]x` counts occurrences in operand order.  Success is 7.
    [pscustomobject]@{ Name = 'unit_merge_last_occurrence.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a Structure value';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_occurrence_range_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'merge occurrence index out of range'; Absent = @(); Debt = @() },
    # THE DECLARED-THROW ABI (FABLE-L2TRANS-THROW-FORMAL-20260920-05).  Every method that merges,
    # and every caller of one, carries the executing Message as a hidden formal.  It was spelled
    # `node`, the spelling of the reserved first formal, so EVERY such method came out as
    # `l2_m0(Lmx * node, Lmx * node, ...`.  Neither translator says a word about that -- l2trans and
    # l1trans both exit 0 silently -- and only gcc refuses it, so these three fixtures (all three
    # that have such a signature, out of 280) had never been compiled, let alone run.  The formal
    # is l2_msg now.  Absent is the duplicate in both shapes it took (adjacent, and after a
    # declared formal); Debt is the signature, a METHOD caller forwarding l2_msg, and the ENTRY
    # still forwarding its own single `node`.  The compile is the regression: the L1 generated
    # before the change fails these rows on the text, and its C fails gcc on the duplicate alone.
    #
    # WHAT THE RUN PROVES.  The generated C compiles unchanged, links against the kernel closure,
    # takes its turn through merge-in-method and closes its root once, and the driver keeps the
    # entry's own int (the root-open tap), so a `return: 81` fails the row.  The failure exit is
    # pinned as S1.1 made it (-133): merge has no payload (X2), so a failing merge leaves
    # `l2_out_throw[0]: 0` -- not the old `node` stub -- and returns its status d + g; the shape
    # checks 71..91 are invariants on the diagnostic route, never a status (X1).  A completed turn
    # leaves the Message running (`Stopped` 0).  Two of the three declare no eternal branch; the
    # driver is given 0 and checks that the array exists and is empty.
    [pscustomobject]@{ Name = 'unit_merge_in_method.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Stopped = 0;
        Args = @('1', 'size', '0', '0', '7');
        Absent = @('Lmx node; @: Lmx node', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)', 'l2_out_throw[0]: node', 'return: 71');
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx self; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m1 (@: Lmx node; @: Lmx self) int',
                 'fn: l2_m2 (@: Lmx node; @: Lmx self; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m3 (@: Lmx node; @: Lmx self; @: Lmx l2_msg; @@: Lmx l2_out_throw) int',
                 'l2_m3(l2_c0\parent, l2_c0, l2_msg, @ l2_te1)',
                 'l2_m0(l2_c2\parent, l2_c2, l2_msg, @ l2_t3, @ l2_te3)',
                 'l2_m2(l2_c0\parent, l2_c0, l2_msg, @ l2_t1, @ l2_te1)',
                 'l2_out_throw[0]: 0',
                 'c.fprintf(c.stderr, "lmx: invariant: merge result check 71\n")',
                 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_throwing_callable.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('Lmx node; @: Lmx node', 'l2_out_throw[0]: node', 'return: 71');
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx self; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'l2_m0(l2_c0\parent, l2_c0, l2_msg, @ l2_t1, @ l2_te1)',
                 'l2_out_throw[0]: 0',
                 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_recursion.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('Lmx node; @: Lmx node', 'l2_p2_0; @: Lmx node', 'l2_out_throw[0]: node', 'return: 71');
        Debt = @('fn: l2_m2 (@: Lmx node; @: Lmx self; size_t: l2_p2_0; @: Lmx l2_msg; @: size_t l2_out_result; @@: Lmx l2_out_throw) int',
                 'l2_m2(l2_c0\parent, l2_c0, l2_q7, l2_msg, @ l2_t1, @ l2_te1)',
                 'l2_m2(l2_c4\parent, l2_c4, 2U, l2_msg, @ l2_t5, @ l2_te5)',
                 'l2_out_throw[0]: 0',
                 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # S1.1, THE STATUS DISCIPLINE OF THE IMPLICIT CHANNEL (FABLE-OPUS-S1-STATUS-20260923-133).  One
    # numbering per method: 0 normal, 1..d its declared names (none before S1.2), then the implicit
    # names at d + g in one global order, merge = 1 and implements = 2 (author Q11; Q17 = A).  A
    # merge made to fail from the outside (`MergeFail`, the driver's merge tap) throws merge: a
    # checkpoint, no payload (X2), status d + 1.  Nothing catches it (catch is S1.3), so it passes
    # each caller -- re-encoded into the caller's numbering -- and reaches the root: the entry has
    # no value (`Fails`, exit 1), the Message is stopped (`Stopped` 1: R0's running = 0 at close)
    # and the status that arrived is the name's g (`Thrown`).  The first row fails the merge
    # statement inside a method E calls, the second the `Model: fresh` merge in E itself; the
    # third is a refused admission, thrown inside a method E calls, which arrives as 2.
    [pscustomobject]@{ Name = 'unit_s1_merge_uncaught.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        Absent = @('l2_out_throw[0]: node'); Debt = @('l2_out_throw[0]: 0', 'l2_out_throw[0]: l2_te') },
    [pscustomobject]@{ Name = 'unit_s1_merge_uncaught_entry.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        Absent = @('l2_out_throw[0]: node'); Debt = @('l2_out_throw[0]: 0') },
    # D-07: qualified-operand merge emits lmx_merge_profiles_owned; MergeFail 1 fails it via the
    # profiles tap (shared mergefail counter). Mutant without -Dlmx_merge_profiles_owned cannot
    # fail the merge -- the program completes with 5 and the row goes RED.
    [pscustomobject]@{ Name = 'unit_s1_merge_profiles_uncaught.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('2'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        Absent = @('l2_out_throw[0]: node');
        Debt = @('lmx_merge_profiles_owned(l2_mops, 2U, l2_mbody, node, 0, l2_program_arena, l2_program_arena, l2_mprofiles, 2U, 0, 0U, @ l2_mresult)',
                 'l2_out_throw[0]: 0', 'l2_out_throw[0]: l2_te') },
    [pscustomobject]@{ Name = 'unit_s1_implements_uncaught.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Letters = 0; Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @('l2_out_throw[0]: node'); Debt = @('l2_out_throw[0]: 0', 'l2_out_throw[0]: l2_te') },
    # A `return:` trailer of a method on the throw ABI returns its value through the normal output
    # with status 0, as a `return:` in the body does: the row completes with the value.
    [pscustomobject]@{ Name = 'unit_s1_trailer_value.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Entry = 5; Stopped = 0;
        Absent = @(); Debt = @('l2_out_result[0]: 5') },
    [pscustomobject]@{ Name = 'unit_anon_block.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 16;
        Absent = @(); Debt = @() },
    # S1.2, DECLARED THROWS (FABLE-OPUS-S1-DECLARED-20260923-135; author Q13, §14).  `throws:` is the
    # first item of a method head: the ordered names that may leave the method; name k leaves as
    # status k, the implicit names after them at d + g.  `throw: Name(args)` builds a payload
    # Structure (child k = argument k: a fresh cell of its type, or a Structure reference), publishes
    # and leaves with pos(Name).  Each declared name of a callee must be listed by its caller (catch
    # is S1.3), E lists none, and propagation maps a declared name by name.  Before S1.3 no program
    # whose E reaches a declared name compiles, so the positive rows keep the throwing methods away
    # from E: they prove emission, compilation and linking, and pin the emitted numbering and the
    # by-name mapping in the text (the multi-line pins).  The runtime distinction of declared
    # positions from d + g is the obligation of S1.3's first catch rows.
    [pscustomobject]@{ Name = 'unit_s1_declared_links.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @('l2_out_throw[0]: node');
        Debt = @("        l2_out_throw[0]: l2_tp0`n        return: 1",
                 "        l2_out_throw[0]: 0`n        return: 2",
                 "        l2_out_throw[0]: 0`n        return: 3",
                 "        if: l2_ts1 = 1`n            return: 2`n        if: l2_ts1 = 2`n            return: 1`n        return: l2_ts1") },
    [pscustomobject]@{ Name = 'unit_s1_declared_payload.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @();
        Debt = @('lmx_arena_ref_store(l2_tp1, 0U, (cast: (@: void) l2_p0_0))', 'lmx_size_store_known(l2_tc1, 9U)') },
    # The intern carries the ordered names: a and c share a signature, d and e differ by order only.
    [pscustomobject]@{ Name = 'unit_s1_throws_intern.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @('l2_entry_rec\sig: 6U'); Debt = @('l2_entry_rec\sig: 5U') },
    # `return: f` of a callable on the throw channel is called on that channel (it was called with
    # node and self alone, which gcc refused), and a throw passes through it like through any call.
    [pscustomobject]@{ Name = 'unit_s1_return_callable_throw_abi.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Entry = 5; Stopped = 0;
        Absent = @(); Debt = @('l2_ts1: l2_m0(l2_c0\parent, l2_c0, l2_msg, @ l2_t1, @ l2_te1)') },
    [pscustomobject]@{ Name = 'unit_s1_return_callable_throw_abi_fails.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_unlisted_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unhandled throw: Oops'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_entry_unhandled_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unhandled throw in entry: Oops'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throw_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'throw of an undeclared name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_not_first_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'throws: must be the first item of a method head'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_nested_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'throws: must be the first item of a method head'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_entry_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'throws: must be the first item of a method head'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_duplicate_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'duplicate name in throws:'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_implicit_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an implicit throw name is not declared'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throw_payload_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported throw payload value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_throws_formal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    # S1.3, CATCH (FABLE-OPUS-S1-CATCH-20260923-136; §14, author Q11-Q14).  `catch: Name (params)` is a
    # landing pad in the caller's block: a block with catches is lowered to one loop (its pad) whose
    # segments and handlers are guarded by where the last delivery landed, so a catch before the
    # call re-enters and one after it continues past.  The innermost enclosing block that catches a
    # name takes it (nested blocks and loops included, siblings not, Q14 K); the same name inside its
    # own handler goes to the enclosing context; parameters bind the payload by assignment (a
    # primitive after its domain check, a Structure after runtime implements; a short payload is
    # `implements`).  The first row is S1.2's obligation: a declared name and an implicit one reach
    # different handlers at run time (Oops is 1, merge d + 1 = 2).
    [pscustomobject]@{ Name = 'unit_s1_catch_declared_vs_merge.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 27; MergeFail = 1; Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_declared_vs_merge_ok.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 8; Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_tc.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_t2.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Entry = 103;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_sibling.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_rethrow.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 1011;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_nested_while.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 122;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_merge_local.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Entry = 50; MergeFail = 1;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_publish.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_user_break.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a loop'; Args = @('0'); Entry = 105;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_implements.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: receiveMessage'; Args = @('0'); Entry = 42; Letters = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_duplicate_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'duplicate catch: Oops'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_merge_params_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an implicit throw carries no payload'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_param_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported catch parameter type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a catch parameter hides a visible name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_unhandled_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unhandled throw in entry: Oops'; Absent = @(); Debt = @() },
    # A BARE ATOM STATEMENT (plan §3, "Expression statement и discard"; FABLE-OPUS-RECEIVER-CONTRACT-
    # 20260924-139).  The atom resolves like any value and the kind of its binding decides: a callable
    # (a unit method, a callable formal) is called with no arguments on the call path of `m()`, its
    # result discarded; a Structure is refused until the author settles executing one (Q19.2); any
    # other value is discarded, never called.  Every one of these crashed the translator before.
    [pscustomobject]@{ Name = 'unit_bare_fn_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_sub_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_in_method.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: * / %'; Args = @('0'); Entry = 25;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_literal_stmt.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a string or char literal'; Args = @('0');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_own_stmt.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: * / %'; Args = @('0'); Entry = 49;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_struct_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    # THE RECEIVER CONTRACT (plan §3 native gate (б)-(е); FABLE-OPUS-RECEIVER-CONTRACT-20260924-139).
    # A callable named where a value is consumed gives its result: it runs with no arguments on the
    # call path of `m()` -- a method or a callable formal, in a declaration, assignment, operand,
    # condition (guarded by && like any call), argument, and `return: m` in a body or a trailer.  A
    # callable without a result has no value and is refused.  A callable formal of the callee takes
    # the occurrence itself.  `f()` on an existing ordinary Structure assigns the empty Structure,
    # with admission to its declared type (the book §12; refused admission is implements).
    [pscustomobject]@{ Name = 'unit_value_call_result.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: * / %'; Args = @('0'); Entry = 7811;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_value_call_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    # FABLE-OPUS-ROOT-WALK-TRANSLATOR-20260924-159 commit 1 (D-38): a callable formal whose callable
    # throws is called through lmx_call_prim -- the throw status apart from the value, the thrown
    # record through `out` -- and propagated like a direct call's, so the handler takes the payload
    # (5 + 2) and the calm callable's value arrives (3).  Success is 10.
    [pscustomobject]@{ Name = 'unit_dyn_call_throw_caught.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw'; Args = @('0'); Entry = 10;
        Absent = @('lmx_call0('); Debt = @('lmx_call_prim(l2_program_arena, l2_c') },
    [pscustomobject]@{ Name = 'unit_value_call_sub_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_trailer_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 14;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_sub_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    # FABLE-SONNET-DIAG-AND-INDEX-20260924-163 commit 1 (D-40): the call-shaped sibling of the two
    # rows just above (`return: d()`, d a sub, vs their bare-atom `return: s`) used to give
    # "incompatible entry signature" here -- one rule (a callable without a result has no value
    # anywhere it is consumed as a value), one diagnostic, now that this fixture's own case is fixed.
    [pscustomobject]@{ Name = 'unit_void_value.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_assign_untyped.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Letters = 0;
        Absent = @(); Debt = @() },
    # D-06: the f() assignment's failed rebinding store is an invariant on the X1 route, not a printed line.
    [pscustomobject]@{ Name = 'unit_empty_assign_admit.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Entry = 421;
        Absent = @('lmx_msg_poll_abort', 'lmx: rebinding');
        Debt = @('c.fprintf(c.stderr, "lmx: invariant: rebinding store failed for own field ') },
    [pscustomobject]@{ Name = 'unit_empty_assign_named.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int'; Args = @('0'); Entry = 74;
        Absent = @(); Debt = @() },
    # A BARE `return` CLOSES A SUB (P0, FABLE-OPUS-RECEIVER-CONTRACT-20260924-139 commit 3; author
    # 2026-09-24 Q19.1/Q19.3): the trailer ends the body of s, and each call runs it.
    [pscustomobject]@{ Name = 'unit_sub_return_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    # THE EXPRESSION STATEMENT (plan §3 "Expression statement и discard"; FABLE-OPUS-DISCARD-20260924-147).
    # One consumer, l2_eval_discard: a bare atom, a run of fields l2_expr_span groups into one
    # expression, a call Frame.  A callable atom is called with no arguments; anything else is
    # evaluated on the value path and dropped into the typed temporaries its calls already have (a
    # pure expression emits nothing).  An anonymous Structure is a nested body; `()` and one with
    # nothing to run emit nothing.  A sub cannot be an operand.
    [pscustomobject]@{ Name = 'unit_discard_codex.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_forms.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an anonymous block'; Args = @('0'); Entry = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_calls.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: * / %'; Args = @('0'); Entry = 11112;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_fnptr.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f()'); Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_discard_void_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    # THE STICKY DIRTY OF AN ADDRESS-TAKEN LOCAL (GROK-COLON-OCCURRENCE-20260922-02).  Any executed
    # `@x` of an addressable activation-local makes sticky through activation end -- before, between
    # or after occurrence bindings.  Address-taking invents no graph field; `p` always addresses the
    # canonical cell and never retargets.  The 2026-09-21 before/after split is superseded.
    #
    # These rows have `Says`: the lines the PROGRAM must print, whole and in order.  That is the
    # only verdict a generated program can give today -- lmx_thread_dispatch_native drops the
    # entry's return, so an exit code proves nothing -- and each line is "<case> <local> <graph>".
    # The matrix is mutually discriminating, measured on translator mutants:
    #   A  before-bind, then bind   sticky: A2/A4 are checkpoints that follow NO address-taking call,
    #                               so "raise dirty again after the call returns" fails them too;
    #   B  never bound              sticky is set, but address-taking invented no field, so B 5 100
    #                               keeps the graph poke through two checkpoints.  A translator that
    #                               publishes through an unresolved cell dies (exit 139) here;
    #                               load-at-bind is what keeps the to-be-bound activation alive.
    #   C  bind, then address       NOW sticky (C3 9 9).  C2 9 4 is local-vs-graph before the next
    #                               checkpoint; C2 9 9 would mean the address retargeted to the graph.
    #   D  one method, both orders  decided at RUN time; D0 after-bind is sticky (D0 5 5).
    #   E  declared, then address   the DECLARATION is a binding line too, and the later `@` is
    #                               sticky (E 6 6).
    # Before the 2026-09-21 sticky slice the translator printed A2 6 100, A3 9 100, A4 9 200 and D1 6 100.
    [pscustomobject]@{ Name = 'unit_arg_addr_sticky.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('A1 6 6', 'A2 6 6', 'A3 9 9', 'A4 9 9', 'B 5 100', 'B 5 100', 'B+ 6 6', 'B 5 100', 'C1 4 4', 'C2 9 9', 'C3 9 9', 'D1 6 6', 'D0 5 5', 'E 6 6');
        BindOrder = $true;
        Absent = @('l2_q0_early', 'l2_q0_bound');
        Debt = @('int: l2_q1_sticky 0', 'int: l2_q1_active 0 - 1',
                 'l2_q1_sticky: 1',
                 'if: l2_q1_dirty != 0 || (l2_q1_sticky != 0 && l2_q1_active = 1)') },
    # TYPE IS AN INDEPENDENT AXIS.  unsigned was REFUSED in the declared form (a formal's type code
    # was compared with an own field's storage code: 34 against 3) and silently left a plain local
    # in the assignment form; a pointer was never bound at all.  Both now go through the same
    # mechanism, and the type only names the cell.
    [pscustomobject]@{ Name = 'unit_arg_addr_types.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not an int';
        Args = @('0');
        Says = @('U 51 51', 'Z local 71', 'Z graph 71', 'L local 81', 'L graph 81');
        BindOrder = $true;
        Absent = @();
        Debt = @('lmx_unsigned_store_known(l2_q1_from[0], l2_q', 'if: l2_q1_dirty != 0 || (l2_q1_sticky != 0 && l2_q1_active = 1)') },
    [pscustomobject]@{ Name = 'unit_arg_addr_pointer.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not an int';
        Args = @('0');
        Says = @('P local is null');
        BindOrder = $true;
        Absent = @();
        Debt = @('lmx_pointer_store_known(l2_q1_from[0], (cast: (@: void) l2_q', 'int: l2_q1_sticky 0') },
    # THE ADDRESS OF AN ETERNAL FIELD IS REFUSED WHERE IT IS TAKEN (FABLE-L2-R0-WRITE-GUARD-DESIGN-20260921-111, M0).
    # `@` yields a WRITABLE address and a raw write through it bypasses every cell helper, so until a
    # read-only address exists as a type the translator refuses it by name, with the test that already
    # refuses a path write.  Two rows because the two spellings are recognised in two different places
    # of the translator, and the first version of the rule covered only one.  The pre-rule translator
    # ACCEPTS both (and the program then dies at gcc for want of a lowering -- never a protection).
    [pscustomobject]@{ Name = 'unit_eternal_addr_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'the address of an eternal branch field cannot be taken'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_eternal_addr_flat_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'the address of an eternal branch field cannot be taken'; Absent = @(); Debt = @() },
    # THE CONTROL, NOW LOWERED.  `@: Named\field` on a mutable named Structure walks the existing
    # field-path helper to the leaf cell and yields a typed address of that cell.  The M0 rows
    # above still refuse the eternal spelling; this row must keep running.  The former residue
    # `@ A\e)` is Absent; the typed cell pointer is the positive lowering.
    [pscustomobject]@{ Name = 'unit_named_addr_gap.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('@ A\e)');
        Debt = @('(cast: (@: size_t) l2_pxp[0])') },
    # THE SAME RULE FOR A HIDDEN/DYNAMIC INPUT (FABLE-L2-ARG-ADDRESS-PROOF-20260921-84).  A free name
    # read before the body's own same-name binding line arrives in a hidden formal, and that line
    # binds it exactly as it binds a declared formal.  The matrix runs for int and for size_t.
    # int was SILENTLY WRONG: its storage code doubled as the dynamic code for "not typed yet", so
    # an int was never passed -- the callee read its own graph field.  Before the change this
    # program printed IA1 1 1, IA2 1 100, IA3 1 9, IA4 1 200, IB 0 100, IB 100 100, IB+ 101 101,
    # IB 101 100 and NO IC line at all (the early return saw 0); every Z line was already right.
    # Debt is the hidden formal itself: `int:` for int_before, and the mixed pair of int_never.
    [pscustomobject]@{ Name = 'unit_arg_addr_dynamic.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('IA1 6 6', 'IA2 6 6', 'IA3 9 9', 'IA4 9 9', 'IB 5 100', 'IB 5 100', 'IB+ 6 6', 'IB 5 100', 'IC1 4 4', 'IC2 9 9', 'IC3 9 9',
                 'ZA1 6 6', 'ZA2 6 6', 'ZA3 9 9', 'ZA4 9 9', 'ZB 5 100', 'ZB 5 100', 'ZB+ 6 6', 'ZB 5 100', 'ZC1 4 4', 'ZC2 9 9', 'ZC3 9 9',
                 'CALLER 3 3 3 3 3 3');
        BindOrder = $true;
        Absent = @();
        Debt = @('fn: l2_m5 (@: Lmx node; @: Lmx self; int: l2_p5_0) int',
                 'fn: l2_m6 (@: Lmx node; @: Lmx self; int: l2_p6_0; int: l2_p6_1) int',
                 'fn: l2_m9 (@: Lmx node; @: Lmx self; int: l2_p9_0; size_t: l2_p9_1) int') },
    # TYPE IS AN INDEPENDENT AXIS HERE TOO.  Which types could be a dynamic input was five separate
    # lists (char, size_t).  Before: W -- the translator NEVER FINISHED on a callee reading the
    # caller's int (the typing fixed point stored "not typed" over "not typed" forever; this row's
    # old-translator control is a refusal only because the F case is refused first); U, L --
    # "unresolved name"; F -- "incompatible entry signature", a FORMAL code compared raw with a
    # dynamic code (34 against 3), the mistake -67 removed from l2_bind_own, alive at a second
    # site; DP -- "unresolved name".  Debt is each hidden formal spelled with its own type.
    [pscustomobject]@{ Name = 'unit_arg_addr_dyn_types.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('W 3', 'U1 6 6', 'U2 6 6', 'L1 6 6', 'L2 6 6', 'F1 6 6', 'F2 6 6', 'DP local is null', 'DP caller keeps its pointer', 'FC 3', 'TC 3 3 3');
        BindOrder = $true;
        Absent = @();
        Debt = @('fn: l2_m4 (@: Lmx node; @: Lmx self; int: l2_p4_0) int',
                 'fn: l2_m5 (@: Lmx node; @: Lmx self; unsigned: l2_p5_0) int',
                 'fn: l2_m6 (@: Lmx node; @: Lmx self; ulong: l2_p6_0) int',
                 'fn: l2_m8 (@: Lmx node; @: Lmx self; @: int l2_p8_0) int',
                 'lmx_pointer_store_known(l2_q') },
    # THE ORDINARY CASES ALONE.  Every address here is taken after the binding line, so every cell
    # is already resolved when it is taken.  After-bind `@` is now sticky: OC3 9 9, OE 6 6, OD3 9 9.
    # OC2 9 4 remains local-vs-graph before the next checkpoint; OC2 9 9 would mean retargeting.
    # CRASH WARNING, not an old expectation: a translator that raises sticky at the address site
    # AND publishes through a cell nobody resolved dies (exit 139) on a before-bind or never-bound
    # activation, and that death hid these lines -- which is why they have a program of their own.
    # Load-at-bind and "address-taking invents no graph field" keep those cases alive.
    [pscustomobject]@{ Name = 'unit_arg_addr_ordinary.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('OC1 4 4', 'OC2 9 9', 'OC3 9 9', 'OE 6 6', 'OD1 4 4', 'OD2 9 9', 'OD3 9 9');
        BindOrder = $true;
        Absent = @();
        Debt = @('fn: l2_m6 (@: Lmx node; @: Lmx self; size_t: l2_p6_0) int') },
    # THE ONE BOUNDARY.  A dynamic input whose SOURCE exists but has no value cell (the caller's
    # const LmP0Text formal) is refused at the caller, by name.  Before, the same program was an
    # "unresolved name" at the callee -- as if nobody had supplied it -- and that is what the
    # pre-change translator still says, so this row fails on it.
    [pscustomobject]@{ Name = 'unit_arg_addr_dyn_nocell.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'dynamic input type has no value cell'; Absent = @(); Debt = @() },
    # A CHAR OWN FIELD IS PUBLISHED, AND THE PROGRAM COMPILES (FABLE-L2TRANS-CHAR-UCHAR-20260921-86).
    # Three emitters spelled the byte handed to lmx_char_rebind_known through `uchar` -- a type that
    # is defined where the TRANSLATOR is built (l1src/p0.h.lm1) and in no program it generates
    # unless that program's author includes p0 himself.  No other row and no gate target drives
    # these emitters, so before this row nothing could be RED.  The pre-change translator fails it
    # on the forbidden spelling in the text and, with the text checks taken off, at gcc:
    # "'uchar' undeclared" (both measured).  The byte is now spelled as the kernel spells it,
    # ((cast: (int) x) & 255).  Lines are "<case> <byte written> <byte read back>":
    #   M  the program entry writes a unit char field     K  the checkpoint of a char own field
    #   P  an explicit write through a node path
    # S2: the entry is method E and the unit field is E's own field, so M is published by the SAME
    # checkpoint descriptor as K; the two pins below are that one emitter at E's row (l2_q1, mark)
    # and at holder's row (l2_q0, kept).
    # The second line of each pair carries a byte above 127 in a CHAR (a literal is already an
    # int): a plain conversion to int hands the rebind a negative value, which it refuses.
    # Measured, one mutant per emitter: K2 200 255; the entry stops after M1; P2 202 255.
    [pscustomobject]@{ Name = 'unit_char_own_publish.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Says = @('M1 67 67', 'M2 202 202', 'K1 65 65', 'K2 200 200', 'P1 66 66', 'P2 202 202');
        # D-06: the char checkpoint's failed rebinding is an invariant on the X1 route, not a printed line.
        Absent = @('(cast: (uchar)', 'lmx_msg_poll_abort', 'lmx: checkpoint');
        Debt = @(('lmx_char_rebind_known(l2_q0_from[0], ((cast: (int) l2_q0) & 255)) = 0' + "`n" + '            c.fprintf(c.stderr, "lmx: invariant: checkpoint store failed for own field 0\n")'),
                 'lmx_char_rebind_known(l2_q0_from[0], ((cast: (int) l2_q0) & 255))',
                 'lmx_char_rebind_known(l2_q1_from[0], ((cast: (int) l2_q1) & 255))',
                 'lmx_char_rebind_known(l2_pxp[0], ((cast: (int) l2_p1_0) & 255))') },
    # TWO LIBRARY UNITS IN ONE LINK (FABLE-L2-LIBRARY-P2-UNIQUE-STATE-20260921-137).  A library unit keeps
    # two module cells of its own -- its arena and its opened mark -- and both were emitted under ONE
    # unhashed name for every unit, so two units could not share a link: measured, exit 1 with
    # `multiple definition of l2_program_arena` and `... l2_library_opened`, exactly those two.  The
    # translator now renames both per unit, and the renames stand BEFORE the arena's definition: the
    # list of five hashed names is emitted AFTER it, and a define that follows a definition renames the
    # later uses and not the definition (measured: the unit then does not compile).  Folding the two
    # names into that list would look tidier and would break the arena again.
    #
    # The symbol rule is what keeps this fixed: an external definition of a library object must be
    # either `l2_u<16 hex>_...` or a name the unit EXPORTS.  The next module cell born without a hash
    # is then caught here by construction, not by somebody remembering a list -- the opened mark was
    # missed by two independent readings of the translator and found only by linking.  A link made
    # green with --allow-multiple-definition would leave ONE opened mark for both units (the second
    # unit believes it is open because the first one opened); the symbol rule is red on that too.
    #
    # WHAT THIS ROW DOES NOT SAY, and must not be read as saying: that a library unit WORKS.  It
    # asserts LINK and SYMBOLS only.  The exported wrappers cannot reach their bodies until the
    # library open exists (the generated l2_library_open cannot succeed today), so nothing is run
    # here, and a row that expected 41 would be red for that reason and not for this one.  The
    # constants are non-zero for the day they ARE run: a wrapper that cannot open returns 0.
    [pscustomobject]@{ Name = 'unit_lib_pair_a.lm2'; Expect = 'library-links'; Exit = 0; Needle = '';
        With = @('unit_lib_pair_b.lm2');
        Exports = @('lib_pair_a_value', 'lib_pair_b_value');
        Absent = @(); Debt = @() },
    # SAME-UNIT FORWARD vs ONE-LINE RETURN TRAILER (GROK-L2-SAME-UNIT-FORWARD-DECL-20260921-141).
    # A complete bodiless unit-level fn is a forward when a same-unit definition exists; a one-line
    # fn whose column-0 return: is the frame trailer is a bodied definition and must not enter
    # pending body=0. Source-line heuristics are not used: l2_fn_defined reads the translator
    # Structure (trailer or body field). The forward is skipped, so one_line is l2_m0; Debt is its
    # trailer return. A pending empty body would lack that return and fail one_line(40)!=41.
    [pscustomobject]@{ Name = 'unit_forward_oneline.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: && and || (a short-circuit the walker has no role for)';
        Args = @('0');
        Absent = @();
        Debt = @('return: l2_p0_0 + 1') },
    [pscustomobject]@{ Name = 'unit_forward_mismatch.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_forward_import_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'not callable'; Absent = @(); Debt = @() },
    # GROK-PREGATE-20260922-01. Needles and Debt are measured on the live translator
    # (HEAD 4da4658 / gate l2trans). Colon updates with no qualified roots run under
    # the driver with 0 roots; graph/const/type refusals stay l2trans-refuses.
    [pscustomobject]@{ Name = 'unit_colon_callable_receiver.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'merge');
        Debt = @('l2_rw0 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_CALL, 3U)', 'lmx_walk_store_int(l2_program_arena, l2_rw1, 1U, 7)', 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # GROK-UNIVERSAL-RESOLUTION-PARTA-20260922-03. Three call forms must share one
    # physical METHOD op; an existing int is assigned. Debt/Absent distinguish that.
    [pscustomobject]@{ Name = 'unit_universal_head_resolution.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'merge');
        Debt = @('l2_rw7 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw6, c.LMX_WALK_OP_CALL, 3U)', 'lmx_walk_store_int(l2_program_arena, l2_rw8, 1U, 7)',
                 'l2_rw10 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw9, c.LMX_WALK_OP_CALL, 3U)', 'lmx_walk_store_int(l2_program_arena, l2_rw11, 1U, 7)',
                 'l2_rw12 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_CALL, 3U)', 'lmx_walk_store_int(l2_program_arena, l2_rw13, 1U, 7)',
                 'lmx_walk_store_int(l2_program_arena, l2_rw37, 1U, 2)') },
    # One logical negative fixture, three TUs: l2trans reports only the first
    # diagnostic. Needle is the converged class for every representable form.
    [pscustomobject]@{ Name = 'unit_universal_absent_paren.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_colon.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_vertical.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_existing_value_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_colon_explicit_parent_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # T-B nested host-less node path (TB-AMEND-28). Debt pins generated lowering of node\shared;
    # private mutant of l2_path_own that treats node-path like for-path (host-attached) must fail.
    # Nested-body witnesses (GROKBOT-NESTED-BODY-WITNESSES-20260922-69): else/while/C-for
    # arms host ordinary child Structures; node\shared stays host-less. Absent forbids the
    # obsolete unit-form branch helper. Debt pins per-arm host selection so dropping that
    # layout/discovery arm fails the row.
    [pscustomobject]@{ Name = 'unit_node_path_nested_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 1U)',
                 'l2_h1: lmx_arena_ref_struct(self, 2U)',
                 'lmx_arena_ref_cell(l2_h1, 0U)',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 2U)',
                 'lmx_arena_ref_cell(l2_h0, 0U)',
                 'while: l2_t0',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 1U)',
                 'lmx_arena_ref_cell(l2_h0, 1U)',
                 'l2_q1: 4',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_own_not_node.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_node_root_unit_field.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_for_root_hosted_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 1; Needle = '';
        Args = @('0'); EmptyEntry = $true;
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_node_root_in_entry_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path root'; Absent = @(); Debt = @() },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 2 / D-25: orphan for-frame
    # fixtures, measured against the current -121 for-root rule. Three
    # still translate, compile and run (a for-frame's hosted field read
    # from ITS OWN lexical body); registered with the actual observed
    # output. Six siblings assumed a for-frame's hosted field stays
    # readable AFTER `end: for`, from the enclosing scope -- measured
    # false today (`for` does not resolve outside a for-frame's own
    # lexical scope, "unresolved name"), and unit_node_array_paths.lm2
    # assumed an Array-typed field through a node/for root, which
    # l2_own_array_root_span's own comment already says is not built --
    # all seven deleted, same reasoning as D-13.
    [pscustomobject]@{ Name = 'unit_forj_parent.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('9');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_forj_sib.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_forj_stale.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('9', '9 42');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_root_field.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_formal_value.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 5; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_occ_self_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 1; EmptyEntry = $true; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_formal_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_callable_formal_descriptor.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_callable_descriptor_direct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'not callable'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_sig_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    # COMPACT-RAWFIELD-BATCHA-72: raw_fld=5 call without form-COMPACT. Debt pins emitted
    # raw-field ccall. Absent is unused (empty proves nothing; no genuine form-gate
    # leftover string appears in generated L1). translates-with-debt catches
    # checker/emitter divergence (refuse vs missing Debt).
    [pscustomobject]@{ Name = 'unit_rawfield_compact.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('l2_p0_0\zz(1)') },
    [pscustomobject]@{ Name = 'unit_rawfield_colon.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('l2_p0_0\zz(1)') },
    # COMPACT-FNPTR-BATCHC-76: ty40 callable-first in all forms; decl+init via type head.
    [pscustomobject]@{ Name = 'unit_fnptr_decl_init.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f(l2_p0_0\alloc)');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_compact.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_colon.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_vertical.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_arg_compact.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('L2TestAllocFn: f l2_p1_0\alloc', 'f(l2_p1_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_arg_colon.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('L2TestAllocFn: f l2_p1_0\alloc', 'f(l2_p1_1)') },
    # After CALL-ARGS-CLOSE: empty ty40 args are zero-args (call_args); arity admission still open.
    # Former 'unsupported body' refuse was the empty-Structure stand-in; now translates as f().
    [pscustomobject]@{ Name = 'unit_fnptr_call_sig_refuse.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('unsupported body'); Debt = @('f()') },
    [pscustomobject]@{ Name = 'unit_fnptr_noncallable_assign.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('l2_q0: 7') },
    # FABLE-GROKBOT-CALL-ARGS-20260922-92: paren-group call args via l2_call_args
    [pscustomobject]@{ Name = 'unit_call_args_empty_paren.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('l2_rw3 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw2, c.LMX_WALK_OP_CALL, 2U)') },
    [pscustomobject]@{ Name = 'unit_call_args_empty_vertical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('l2_rw3 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw2, c.LMX_WALK_OP_CALL, 2U)') },
    [pscustomobject]@{ Name = 'unit_call_args_paren_seq.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('l2_rw3 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw2, c.LMX_WALK_OP_CALL, 4U)', 'lmx_walk_store_int(l2_program_arena, l2_rw4, 1U, 1)', 'lmx_walk_store_int(l2_program_arena, l2_rw5, 1U, 2)') },
    [pscustomobject]@{ Name = 'unit_call_args_controls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('l2_rw14 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw13, c.LMX_WALK_OP_CALL, 4U)', 'lmx_walk_store_int(l2_program_arena, l2_rw15, 1U, 1)', 'lmx_walk_store_int(l2_program_arena, l2_rw16, 1U, 2)', 'l2_rw29 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw28, c.LMX_WALK_OP_CALL, 4U)', 'lmx_walk_store_int(l2_program_arena, l2_rw30, 1U, 1)', 'lmx_walk_store_int(l2_program_arena, l2_rw31, 1U, 2)') },
    [pscustomobject]@{ Name = 'unit_call_args_control_split.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('l2_rw3 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw2, c.LMX_WALK_OP_CALL, 4U)', 'lmx_walk_store_int(l2_program_arena, l2_rw4, 1U, 1)', 'lmx_walk_store_int(l2_program_arena, l2_rw5, 1U, 2)') },
    [pscustomobject]@{ Name = 'unit_call_args_refuse_nested.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_refuse_named.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    # Superseded by FABLE-SONNET-EMPTY-STRUCT-20260923-132: `mystruct: ()`
    # now declares an empty Structure instead of refusing as an unresolved
    # call (see the fixture's own header comment).
    [pscustomobject]@{ Name = 'unit_call_args_refuse_struct.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_paren.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f((l2_p0_1))');
        Debt = @('f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_forms.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f((l2_p0_1))');
        Debt = @('f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_nullary_stmt.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f(())', 'unsupported body');
        Debt = @('f()') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_nullary_value.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('f(())', 'unsupported body');
        Debt = @('f()') },
    [pscustomobject]@{ Name = 'unit_puts_method_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('c.puts("from-method")') },
    [pscustomobject]@{ Name = 'unit_puts_main_beside_method.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0');
        Absent = @();
        Debt = @('c.puts("beside-method")') },
    # COMPACT-DECL-BATCHB-75: struct local form-independent; float refuse form-independent;
    # opposite controls for fnptr call and ordinary call.
    [pscustomobject]@{ Name = 'unit_struct_decl_colon.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_struct_decl_compact.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_struct_decl_vertical.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_float_refuse_colon.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'by-value float local not yet implemented'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_float_refuse_compact.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'by-value float local not yet implemented'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_struct_decl_opp_fnptr_call.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('BatchBPoint:', 'f: l2_p0_0\alloc'); Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'return: f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_struct_decl_opp_call.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('l2_t1: l2_m0(l2_c0\parent, l2_c0, 1)') }
    [pscustomobject]@{ Name = 'unit_colon_hidden_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # S2: the unit's `Model: fresh` is an own field of the entry E, registered by the same
    # recognizer every method uses (l2_own_add(E, ...)), so the unit declares it again.
    [pscustomobject]@{ Name = 'unit_colon_model_decl.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    # FABLE-SONNET-EMPTY-STRUCT-20260923-132: the three empty-Structure
    # declaration spellings, name absent.
    [pscustomobject]@{ Name = 'unit_empty_struct_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_struct_hanging_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'empty colon Frame is not allowed'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_struct_existing_nonstruct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_typed_decl_vertical.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_duplicate_named_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'duplicate named Structure'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_method_lexical_model.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_m0(l2_c0\parent, l2_c0, l2_msg, @ l2_t1, @ l2_te1)',
                 'lmx_merge_owned(l2_mops, 1U, l2_mbody, node, 0, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_method_dynamic_precedence.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_m0(l2_c0\parent, l2_c0, l2_msg, @ l2_t1, @ l2_te1)',
                 'lmx_merge_owned(l2_mops, 1U, l2_mbody, node, 0, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_method_fresh_per_activation.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('lmx_merge_owned(l2_mops, 1U, l2_mbody, node, 0, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_own_write.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_formal.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_nested.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: l2_nsp[', 'lmx_merge_owned(l2_mops, 1U, l2_mbody, l2_nsp[') },
    [pscustomobject]@{ Name = 'unit_field_path_nested_two.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: l2_nsp[', 'lmx_merge_owned(l2_mops, 1U, l2_mbody, l2_nsp[') },
    [pscustomobject]@{ Name = 'unit_field_path_unknown_refused.lm2'; Expect = 'root-pending'; Exit = 0;
        Needle = 'root operation not walkable yet: a call of a method that can throw'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_path_unit_addr.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_unit_colon.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_unit_qualified.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('1');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_array_dispatch.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 1; Needle = '';
        Args = @('0'); EmptyEntry = $true;
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    # FABLE-SONNET-OWN-LOOKUP-AUDIT-20260923-131 part 3: the terminal
    # Structure-reference assignment checklist, one assertion per (direct
    # name / path) x (own / unit / formal) x (primitive / Structure).
    [pscustomobject]@{ Name = 'unit_field_path_terminal_checklist.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    # FABLE-SONNET-DECL-PREPASS-20260923-137 part 2 (Opus's finding 1): a
    # named-Structure method return, non-throwing and declared-throw ABI,
    # a discarded call and a nested-call value round-trip witness.
    [pscustomobject]@{ Name = 'unit_struct_return.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_struct_return_assign_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'graph assignment admission requires receiving-expression tests'; Absent = @(); Debt = @() },
    # FABLE-SONNET-DEFECTS-20260924-141 D-15: an int: field in a named
    # Structure goes through the same field-kind table as size_t (kind 7) --
    # own declaration, a nested path, a formal parameter and a merge copy
    # all read/write it through the ordinary machinery.
    # FABLE-OPUS-DISCARD-20260924-147: until the builder gave kind 7 its cell this row was vacuous
    # (the first write met an empty slot and a silent bail returned 0 from E); success is now 7.
    # D-05/D-06: a field path meeting no Structure, an own field without a cell, a method entered
    # without its occurrence, a missing control body and a failed checkpoint are invariants on the
    # X1 route (a message and an abort), never a return from the method or a printed line.
    [pscustomobject]@{ Name = 'unit_struct_int_field.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_msg_poll_abort', 'lmx: checkpoint',
                   "if: self = 0`n        return", "if: self = 0`n        l2_out_result",
                   "if: l2_h0 = 0`n        return", "if: l2_pst = 0`n        if: l2_q",
                   "if: l2_pxp = 0`n        if: l2_q", "if: l2_xp = 0`n        if: l2_q");
        Debt = @('lmx_int_store_known(l2_entry_slot[0], 1)', 'lmx_int_store_known(l2_entry_slot[0], 2)',
                 'c.fprintf(c.stderr, "lmx: invariant: a field path met no Structure\n")',
                 'c.fprintf(c.stderr, "lmx: invariant: an own field has no cell to load\n")',
                 'c.fprintf(c.stderr, "lmx: invariant: a method was entered without its occurrence\n")',
                 'c.fprintf(c.stderr, "lmx: invariant: a control body has no Structure\n")',
                 'c.fprintf(c.stderr, "lmx: invariant: checkpoint lost own field ',
                 'c.fprintf(c.stderr, "lmx: invariant: checkpoint store failed for own field ') },
    # Every numeric field of a named Structure -- size_t, int, unsigned, ulong -- has its own cell
    # holding its literal, in the Structure and in a merge copy (FABLE-OPUS-DISCARD-20260924-147).
    [pscustomobject]@{ Name = 'unit_struct_num_fields.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('lmx_int_store_known(l2_entry_slot[0], 4)', 'lmx_unsigned_store_known(l2_entry_slot[0], 5U)',
                 'lmx_ulong_store_known(l2_entry_slot[0], 6U)', 'lmx_size_store_known(l2_entry_slot[0], 3U)') },
    # The same four kinds on an eternal branch: cells of their own primitive type in the branch's
    # exact sealed profile, holding their literals (the driver's numeric root facts).
    [pscustomobject]@{ Name = 'unit_eternal_num_fields.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: an eternal branch among the root''s fields';
        Args = @('1', 'int', '0', '0', '4', 'unsigned', '0', '1', '5', 'ulong', '0', '2', '6', 'size', '0', '3', '3');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.sizeof(unsigned long)');
        Debt = @('c.LMX_TYPE_UNSIGNED, l2_eprofile0)', 'c.LMX_TYPE_ULONG, l2_eprofile0)',
                 'c.sizeof(l2_ulong_probe), c.LMX_KIND_PRIMITIVE, c.LMX_TYPE_ULONG, l2_eprofile0)') },
    # FABLE-SONNET-DECL-PREPASS-20260923-137 part 3 (Opus's finding 2), updated by
    # FABLE-SONNET-PREDEF-RESULT-TYPE-20260924-160 commit 2: a predef'd C function's result now
    # carries its own declared return type (l2_predef_result_ty, reading the prototype:
    # declaration l2_is_known already re-parses) -- entry_parse_min.lm2's `int` target and this
    # Structure target are unaffected (int is numeric either way; a Structure target was and
    # remains incompatible with a predef'd int-returning call), but a genuinely void-returning
    # predef assigned anywhere is now refused AT l2trans, not left for gcc (below).
    [pscustomobject]@{ Name = 'unit_predef_result_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    # FABLE-SONNET-DIAG-AND-INDEX-20260924-163 commit 1 (D-40): the assignment's value_ty=8
    # (void, from a void-returning predef -- the same code a plain sub: gives) now matches the
    # new "no result" check in l2_colon_check_assignment before the generic incompatible-type
    # one, unifying this row's message with unit_void_value.lm2's; Needle updated accordingly.
    [pscustomobject]@{ Name = 'unit_predef_result_void_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    # FABLE-SONNET-PREDEF-RESULT-TYPE-20260924-160 commit 2: the primary motivating case --
    # lm_own_copy_bytes's declared `@: char` return now matches copy's `@: char` target (was
    # refused under the old numeric-only -10 code, found during -155, recorded as D-35).
    # l2trans and l1trans both succeed clean (measured); `eternal-runs` was tried and reached a
    # SEPARATE, unrelated gap this ticket does not own -- the per-fixture eternal-runs link step
    # only links l2_eternal_driver.o + the fixture + l2_libc.o, never l1src/own.lm1's own compiled
    # body (unit_lm_own_actual_span.lm2 is the first fixture ever to reach a link needing it;
    # every other lm_own_* use links inside the full kernel build, tools/build_l2src.ps1, a
    # different object graph entirely) -- "undefined reference to `lm_own_copy_bytes'" etc.
    # translates-with-debt with an empty Debt stops at l1trans success, the layer this ticket
    # actually changes, without the unrelated link-object gap; flagged for whoever owns extending
    # the per-fixture link step, not fixed here.
    [pscustomobject]@{ Name = 'unit_lm_own_actual_span.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not an int';
        Absent = @(); Debt = @() },
    # FABLE-SONNET-OWN-LOOKUP-AUDIT-20260923-131 part 3: the -92 leftover --
    # a Structure value assigned through a path ending at a nested
    # Structure-typed field stays a located, fail-closed refusal.
    [pscustomobject]@{ Name = 'unit_field_path_struct_rebind_refused.lm2'; Expect = 'root-pending'; Exit = 0;
        Needle = 'root operation not walkable yet: a value that is not an int'; Absent = @(); Debt = @() },
    # FABLE-GROKBOT-C-MEMBER-ACCESS-20260923-120 part1: c.* raw member paths.
    # Mutant: l2_ty_raw_c_members always 0 -> unit_c_member_len refuses unsupported body.
    [pscustomobject]@{ Name = 'unit_c_member_len.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'unsupported body');
        Debt = @('l2_entry_unit: graph', 'l2_p0_0\length') },
    [pscustomobject]@{ Name = 'unit_c_member_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'unsupported body');
        Debt = @('l2_entry_unit: graph', 'length: 3U') },
    [pscustomobject]@{ Name = 'unit_c_member_twohop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'unsupported body');
        Debt = @('l2_entry_unit: graph', 'diagnostic') },
    [pscustomobject]@{ Name = 'unit_c_member_struct_control.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    # FABLE-GROKBOT-RAW-MEMBER-ROOT-AND-7A-CLOSE-20260923-126 part1: raw root only for c.*.
    # Mutant: restore ty>=100 alone in l2_ty_raw_c_members -> Model compound emits wrong access.
    [pscustomobject]@{ Name = 'unit_raw_root_model_compound.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_raw_root_formal_compound.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_local_model_arg.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method that can throw';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_write_from_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_write_below_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_priority.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_priority_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @('assignment target must be a declared typed mutable value'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_model_fresh_synonyms.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_decl_unknown_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_slot_structure_projection.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 2 / D-25: three orphan @:
    # depth/formal fixtures, measured -- each translated but never called
    # its own witness function, so a broken address write would have
    # passed silently either way. Completed with a real call and assertion
    # rather than rewritten from scratch (the shapes were already correct).
    [pscustomobject]@{ Name = 'unit_addr_arg.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_depth.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_take.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_entry_name_collision.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Says = @('1 2 3 4 5');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-ARRAY-ADDR-20260924-144 D-21: `@` on a bare own-array
    # element addresses the real backing (l2_emit_array_ptr), both directly
    # and through a formal pointer the array decays to.
    [pscustomobject]@{ Name = 'unit_addr_own_array_element.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-ARRAY-ADDR-20260924-144 D-22: measured L2 spec 18.2 --
    # address arithmetic IS meaningful, but l2trans has no expression-type
    # inference to stop a pointer result reaching a numeric target, so the
    # compound shape is refused outright rather than silently miscompiled
    # (ex-address_array_element_sum.lm2, D-13).
    [pscustomobject]@{ Name = 'unit_addr_own_array_arithmetic_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'address arithmetic past an own-array element is not yet supported'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_unknown_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_dyn_hidden_from_cross_method.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call of a method with dynamic inputs';
        Args = @('0');
        Says = @('beta sees shared=0', 'beta sees shared=222');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_dyn_hidden_from_undeclared_refused.lm2'; Expect = 'root-pending'; Exit = 0;
        Needle = 'root operation not walkable yet: a call of a method with dynamic inputs'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_find_last_sizeof.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_find_last_call_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 2 / D-25: orphan, measured
    # and completed -- the original never called m(), and even called, its
    # result did not depend on what the callee actually observed, so a
    # broken dynamic-input read of a dirty caller own-field would have
    # passed silently either way.
    [pscustomobject]@{ Name = 'unit_own_dirty_rhs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_raw_root_c_control_compound.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'unsupported body');
        Debt = @('l2_entry_unit: graph', 't\length') },
    # FABLE-GROKBOT-INCLUDE-AND-SIZEOF-20260923-123 part1: source-driven predef/include.
    # WITH include -> runs. WITHOUT -> L1 must not silently gain p0.lm1.h; l1trans/gcc refuse.
    # Mutant: restore LmP0-prefix l2_need_p0 in l2_foreign_intern -> without-include links (RED).
    [pscustomobject]@{ Name = 'unit_p0_with_include.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_text_hash.lm1');
        Debt = @('l2_entry_unit: graph', '"l1src/p0.lm1.h" "<stdlib.h>"') },
    [pscustomobject]@{ Name = 'unit_p0_without_include.lm2'; Expect = 'toolchain-refuses'; Exit = 0; Needle = '';
        Absent = @('l2_text_hash.lm1'); Debt = @() },
    # FABLE-GROKBOT-INCLUDE-AND-SIZEOF-20260923-123 part2: sizeof: bytes + raw c.sizeof/c.array.
    # Mutant: restore c.sizeof special -> migrated unit generated C changes.
    # Mutant: drop sizeof: receiver -> its fixtures refuse.
    [pscustomobject]@{ Name = 'unit_sizeof_array_bytes.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_sizeof_type_int.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_sizeof_struct_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_sizeof_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_sizeof_c_door_arena.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph', 'c.sizeof(c.size_t)') },
    # FABLE-OPUS-GATE-TRANSLATOR-20260924-151 commit 2: the sizeof: receiver takes a type frame --
    # `sizeof(@: T)` is C `sizeof(T *)` for a primitive type word T, lowered as L1 spells it
    # (`c.sizeof(@: T)`); the Mixa manager's line forms ride along.  Success is 7.
    [pscustomobject]@{ Name = 'unit_sizeof_type_frame.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('c.sizeof(@: void)', 'c.sizeof(@: char)', 'c.sizeof(@@: void)', 'c.sizeof(@: ulong)') },
    # A type frame names a primitive type word: L1 reads any other name as an address.
    [pscustomobject]@{ Name = 'unit_sizeof_type_frame_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'sizeof: a type frame names a primitive type'; Absent = @(); Debt = @() },
    # The raw door has no c.sizeof semantics: `@: void` is not an L2 expression (reading N).
    [pscustomobject]@{ Name = 'unit_csizeof_type_frame_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    # FABLE-OPUS-P0-SIZEOF-ATOM-20260924-157: a private buffer's element size through the sizeof:
    # receiver, `sizeof(unsigned)`, lowered as L1's single-word `c.sizeof(unsigned)`.  Success is 7.
    [pscustomobject]@{ Name = 'unit_ptr_grow.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a call with an input that is not an int';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('c.sizeof(unsigned)') },
    # FABLE-OPUS-P0-SIZEOF-ATOM-20260924-157 commit 2: P0 keeps no raw `c.sizeof(...)` atom, so an L2
    # operand of the door is lowered like any door operand -- an own int x becomes a temp -- where
    # the raw atom passed the name `x` to C ("x undeclared").  Success is 7.
    [pscustomobject]@{ Name = 'unit_csizeof_operand_lowered.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.sizeof(x)');
        Debt = @('return: c.sizeof(l2_t') },
    [pscustomobject]@{ Name = 'unit_sizeof_own_local.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not an int';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_native_activation.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.array'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_array_write_root_out_of_range.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'own array index requires an in-bounds primitive literal'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_write_general_root_no_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_write_general_root_real_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_incompatible_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_graph_const_target_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'const write'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_graph_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_graph_update_admission_blocked.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'graph assignment admission requires receiving-expression tests'; Absent = @(); Debt = @() },
    # Two identical full qualifier occurrences get distinct physical profile identities.
    # Plain in the same file stays mutable/unprofiled and is not a qualified root.
    [pscustomobject]@{ Name = 'unit_eternal_physical_profiles.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an eternal branch among the root''s fields';
        Args = @('2', 'size', '0', '0', '7', 'size', '1', '0', '7');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [2]: @: Lmx l2_program_qualified_roots',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 'l2_eprofile1: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'if: l2_eprofile0 = l2_eprofile1',
                 'l2_entry_unit: graph') },
    # Filename says refused: the merge result is an ordinary Structure (not a third
    # qualified root). The translator emits merge_profiles_owned and both operands
    # remain exported roots. This is not an l2trans refusal.
    [pscustomobject]@{ Name = 'unit_eternal_multi_profile_merge_refused.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a Structure value';
        Args = @('2', 'size', '0', '0', '1', 'size', '1', '0', '1');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('c.array: [2]: @: Lmx l2_program_qualified_roots',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 'lmx_merge_profiles_owned(l2_mops, 2U, l2_mbody, self, 0, l2_program_arena, l2_program_arena, l2_mprofiles, 2U, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_eternal_profile_partial_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'independent branch requires const'; Absent = @(); Debt = @() },
    # GROK-PORT-PREV-IMPLEMENTS-20260922-01. Compiler-side implements over named
    # Structure field lists and hosted primitive leaves. Receiver-expression unit
    # tests stay deferred; Lmx graph rebinding without a named-structure descriptor
    # stays fail-closed (unit_colon_graph_update_admission_blocked).
    [pscustomobject]@{ Name = 'unit_implements_methods.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_primitives.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_namespace.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_argument.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_assignment.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_return.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: implements';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_admission.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_invalid_implements_unknown_candidate.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown candidate descriptor'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_invalid_implements_unknown_required.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown consumer descriptor'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_invalid_implements_unknown_required_distinct.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown required descriptor'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_invalid_implements_unknown_consumer.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown consumer descriptor'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_invalid_implements_used_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_arg_slots.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ',
                 'l2_q0_from: lmx_arena_ref_cell(self, 1U)',
                 'l2_q1_from: lmx_arena_ref_cell(self, 2U)') },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 1: a named (method) root's
    # occurrence index, test\[N]arg, resolved through l2_own_find_occ --
    # the same lookup the rootless \[N]arg form already uses, no second
    # scanner.
    [pscustomobject]@{ Name = 'unit_occ_root_named.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: this expression';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_root_out_of_range_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'own occurrence index out of range'; Absent = @(); Debt = @() },
    # FABLE-SONNET-LAST-OCCURRENCE-20260924-164: unqualified test\arg is the
    # LAST occurrence of a repeated plain own field (not argument-bound, so
    # first-vs-last is the only thing deciding the read) -- test\[N]arg still
    # counts in declaration order; a write through the unqualified name lands
    # on the last occurrence too.
    [pscustomobject]@{ Name = 'unit_own_last_occurrence.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_sticky_selector.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('BEFORE 1 1', 'AFTER 9 9', 'NONE 7 100', 'NONE 7 100', 'NONE+ 1 1');
        BindOrder = $true;
        Absent = @('l2_q0_early', 'l2_q0_bound');
        Debt = @('int: l2_q1_sticky 0', 'int: l2_q1_active 0 - 1', 'l2_q1_sticky: 1') },
    [pscustomobject]@{ Name = 'unit_occ_snapshot_selector.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('BETWEEN 2', 'LAST 9');
        BindOrder = $true;
        Absent = @('l2_q0_early', 'l2_q0_bound');
        Debt = @('int: l2_q0_sticky 0', 'int: l2_q0_active 0 - 1', 'l2_q0_sticky: 1') },
    # FABLE-GROKBOT-MATRIX-20260924-143 -- B2 semantic matrix (fixtures only).
    # Grid: {absent, existing non-callable, existing callable, path} x
    # {primitive, Structure ref, Array/ref, callable} over one head-consumes-tail
    # op; three spellings where positive; physical op / identity / diagnostics.
    [pscustomobject]@{ Name = 'unit_matrix_absent_struct_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_prim_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_arrayish_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment target must be a declared typed mutable value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_prim_asgn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_empty_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_struct_rebind_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'graph assignment admission requires receiving-expression tests'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_callable_prim.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_callable_struct_identity.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_callable_array_elem.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an array';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_callable_callable_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_path_prim.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a value that is not an int';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_path_struct_rebind_refused.lm2'; Expect = 'root-pending'; Exit = 0;
        Needle = 'root operation not walkable yet: a value that is not an int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_path_array_elem.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: an array';
        Args = @('0'); Absent = @(); Debt = @() },
    # (e) empty Structure as ONE named value vs empty arg list. Named form is
    # measured refuse today (D-21); arglist is nullary CALL.
    [pscustomobject]@{ Name = 'unit_matrix_empty_named_value.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_empty_arglist.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    # Parity native for D-04 (walker FIXED -140): extra Structure arg to nullary.
    [pscustomobject]@{ Name = 'unit_matrix_parity_extra_struct_native.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @('assignment target must be a declared typed mutable value'); Debt = @() },
    # FABLE-SONNET-NAME-SPECIALS-20260924-155 commit 2: the norm's negative witness -- no
    # predef: at all for lm_own_new_zero, so l2_is_known (name resolves only through c.* or a
    # predef: declaration, never a hard-coded list) must refuse it. Measured message for a
    # call-shaped reference to an unknown name is "unknown method" (l2_check_fields :13090),
    # not "unresolved name" (that text is for a bare-atom reference, e.g. unit_bare_unknown_
    # refused.lm2); this row pins the message l2trans actually gives here. Mutant: restoring
    # the deleted 11-name list in l2_is_known turns this row GREEN (wrongly admitted) -- RED.
    [pscustomobject]@{ Name = 'unit_own_missing_predef_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown method'; Absent = @(); Debt = @() },
    # FABLE-SONNET-NAME-SPECIALS-20260924-155 commit 3: pins the DELETION of the
    # auto-injected lm_own_* prototype: block (former :18301) and the four hand-written
    # strstr-dispatch emission branches (former :14869-:14951) -- both dead since commit 2,
    # because reaching either one at all already requires l2_predef_has_function(call\head)
    # to be true, which the general l2_emit_ccall path (:14862) already satisfies first.
    # unit_bad_sizeof.lm2 calls lm_own_copy_bytes with only its own predef: "l1src/own.h.lm1"
    # (no c.* door, no other own-support); Absent pins that the generated L1 no longer
    # carries the literal injected signature text. Mutant: restoring the injection (or a
    # strstr arm) makes this string reappear -- Absent fires, RED.
    [pscustomobject]@{ Name = 'unit_bad_sizeof.lm2'; Expect = 'translates-with-debt'; Exit = 0;
        Absent = @('fn: lm_own_new_zero (size_t: size) @: void'); Debt = @() }
)

foreach ($fx in $fixtures) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($fx.Name)
    $source = Join-Path $sandbox ('tests\' + $fx.Name)
    if (-not (Test-Path -LiteralPath $source)) { Add-Row 'FAIL' ('fixture:' + $stem) 'fixture file is missing'; continue }
    $genLm1 = Join-Path $gen ($stem + '.lm1')
    $label = 'fixture.' + $stem + '.l2trans'
    $profileArgs = @()
    if ($fx.Expect -eq 'library-links') { $profileArgs = @('--library') }
    $made = Step-Made $label $l2trans ($profileArgs + @($source, $genLm1)) $src $genLm1

    # 'root-pending' (FABLE-OPUS-ROOT-WALK-TRANSLATOR-20260924-159): a row whose root uses an operation the
    # translator does not build as walker nodes yet.  It is refused, located, with the operation it needs
    # (the needle) -- never dropped, never run natively -- and flips back to eternal-runs when that
    # operation is built.
    if ($fx.Expect -eq 'l2trans-refuses' -or $fx.Expect -eq 'root-pending') {
        if ($made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans ACCEPTED a fixture that must be refused'; continue }
        # The log is matched with its line breaks removed: Windows PowerShell wraps a native stderr
        # line at the console width, and a long fixture path pushes the message across the break.
        if (((Log-Text $label) -replace "`r?`n", '') -notmatch [regex]::Escape($fx.Needle)) { Add-Row 'FAIL' ('fixture:' + $stem) ('refused, but not with "' + $fx.Needle + '"'); continue }
        Add-Row 'OK' ('fixture:' + $stem) ('refused as expected: ' + $fx.Needle); continue
    }
    if (-not $made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans produced no L1; see the log'; continue }
    if ($fx.Expect -eq 'eternal-runs') {
        $entryLine = [regex]::Match((Get-Content -LiteralPath $genLm1 -Raw), '(?m)^# entry statements: (\d+)\s*$')
        if (-not $entryLine.Success) { Add-Row 'FAIL' ('fixture:' + $stem) 'the generated L1 does not state `# entry statements: N`'; continue }
        $emptyOk = $fx.PSObject.Properties['EmptyEntry'] -and $fx.EmptyEntry
        if ([int]$entryLine.Groups[1].Value -eq 0 -and -not $emptyOk) { Add-Row 'FAIL' ('fixture:' + $stem) 'an executable row whose entry executes no statement (set EmptyEntry to mean it)'; continue }
    }

    if ($fx.Expect -eq 'toolchain-refuses') {
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = ''
        foreach ($a in $fx.Absent) {
            if ($why -eq '' -and $l1 -match [regex]::Escape($a)) { $why = 'the generated L1 still silently names "' + $a + '"' }
        }
        if ($why -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) $why; continue }
        $genC = Join-Path $gen ($stem + '.c')
        $label2 = 'fixture.' + $stem + '.l1trans'
        $made2 = Step-Made $label2 $Translator @($genLm1, $genC) $src $genC
        if (-not $made2) { Add-Row 'OK' ('fixture:' + $stem) 'l2trans accepted without silent include; l1trans refused as expected'; continue }
        $obj = Join-Path $gen ($stem + '.o')
        if (Test-Path -LiteralPath $obj) { Remove-Item -LiteralPath $obj -Force }
        $code = Invoke-Step ('fixture.' + $stem + '.compile') $gcc ($kflags + @('-c', $genC, '-o', $obj)) $root
        if ($code -eq 0 -and (Test-Path -LiteralPath $obj)) { Add-Row 'FAIL' ('fixture:' + $stem) 'gcc ACCEPTED a unit that must be refused without its include/predef'; continue }
        Add-Row 'OK' ('fixture:' + $stem) ('l2trans accepted without silent include; gcc refused as expected (exit ' + $code + ')'); continue
    }

    $genC = Join-Path $gen ($stem + '.c')
    $label2 = 'fixture.' + $stem + '.l1trans'
    $made2 = Step-Made $label2 $Translator @($genLm1, $genC) $src $genC

    if ($fx.Expect -eq 'translates-with-debt') {
        if (-not $made2) { Add-Row 'FAIL' ('fixture:' + $stem) 'l1trans produced no C from the generated L1; see the log'; continue }
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = ''
        foreach ($a in $fx.Absent) {
            if ($why -eq '' -and $l1 -match [regex]::Escape($a)) { $why = 'the generated L1 still names "' + $a + '"' }
        }
        foreach ($d in $fx.Debt) {
            if ($why -eq '' -and $l1 -notmatch [regex]::Escape($d)) { $why = 'the recorded debt "' + $d + '" is GONE -- update this fixture, the gap has closed' }
        }
        if ($why -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) $why; continue }
        Add-Row 'OK' ('fixture:' + $stem) ('expected translation debt remains isolated (' + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden)'); continue
    }
    if (-not $made2) { Add-Row 'FAIL' ('fixture:' + $stem) 'l1trans produced no C from the generated L1; see the log'; continue }

    if ($fx.Expect -eq 'library-links') {
        $nm = Join-Path (Split-Path -Parent $gcc) 'nm.exe'
        if (-not (Test-Path -LiteralPath $nm)) { Add-Row 'FAIL' ('fixture:' + $stem) 'nm.exe is not beside gcc, so the symbols cannot be read'; continue }
        $units = @($stem)
        $why = ''
        foreach ($other in $fx.With) {
            $ostem = [System.IO.Path]::GetFileNameWithoutExtension($other)
            $osource = Join-Path $sandbox ('tests\' + $other)
            $oLm1 = Join-Path $gen ($ostem + '.lm1')
            $oC = Join-Path $gen ($ostem + '.c')
            if (-not (Test-Path -LiteralPath $osource)) { $why = 'the partner fixture is missing: ' + $other; break }
            if (-not (Step-Made ('fixture.' + $ostem + '.l2trans') $l2trans @('--library', $osource, $oLm1) $src $oLm1)) { $why = 'l2trans produced no L1 for the partner ' + $other; break }
            if (-not (Step-Made ('fixture.' + $ostem + '.l1trans') $Translator @($oLm1, $oC) $src $oC)) { $why = 'l1trans produced no C for the partner ' + $other; break }
            $units += $ostem
        }
        $objects = @()
        $cells = @()
        $seen = @{}
        $bad = @()
        foreach ($u in $units) {
            if ($why -ne '') { break }
            # A unit that was NOT taken in library mode has no per-unit cells at all, and the row would
            # then be green about nothing.
            if ((Get-Content -LiteralPath (Join-Path $gen ($u + '.lm1')) -Raw) -cnotmatch 'define: l2_library_open l2_u[0-9A-F]{16}_open') { $why = $u + ' was not translated in library mode, so the row would measure nothing'; break }
            $uO = Join-Path $gen ($u + '.o')
            if (Test-Path -LiteralPath $uO) { Remove-Item -LiteralPath $uO -Force }
            $code = Invoke-Step ('fixture.' + $u + '.compile') $gcc ($kflags + @('-c', (Join-Path $gen ($u + '.c')), '-o', $uO)) $root
            if ($code -ne 0 -or -not (Test-Path -LiteralPath $uO)) { $why = "gcc exit $code on the generated C of " + $u; break }
            $objects += $uO
            Invoke-Step ('fixture.' + $u + '.nm') $nm @('-g', '--defined-only', $uO) $root | Out-Null
            $arena = 0
            $opened = 0
            foreach ($line in ((Log-Text ('fixture.' + $u + '.nm')) -split "`r?`n")) {
                if ($line -cnotmatch '^[0-9A-Fa-f]+ ([A-Za-z]) (\S+)$') { continue }
                $kind = $Matches[1]
                $name = $Matches[2]
                # Every offence is COLLECTED and the link is still attempted: a red row then names the whole
                # set at once, and says separately what the symbols say and what the linker says.
                if ($kind -ceq 'C') { $bad += ($u + ': ' + $name + ' is a COMMON symbol, two units would share that one cell'); continue }
                if ($seen.ContainsKey($name)) { $bad += ($name + ' is defined by both ' + $seen[$name] + ' and ' + $u) }
                else { $seen[$name] = $u }
                if ($name -cmatch '^l2_u[0-9A-F]{16}_') {
                    if ($name -cmatch '_arena$') { $arena++; $cells += $name }
                    if ($name -cmatch '_opened$') { $opened++; $cells += $name }
                    continue
                }
                if ($fx.Exports -ccontains $name) { continue }
                $bad += ($u + ': ' + $name + ' is neither unit-hashed nor exported')
            }
            if ($arena -ne 1 -or $opened -ne 1) { $bad += ($u + ': ' + $arena + ' hashed arena cells and ' + $opened + ' hashed opened marks, one of each is its own state') }
        }
        if ($why -eq '') {
            foreach ($e in $fx.Exports) { if (-not $seen.ContainsKey($e)) { $bad += ('the exported name ' + $e + ' is defined by no unit of the row') } }
        }
        if ($why -eq '') {
            $pair = Join-Path $gen ($stem + '.pair.o')
            if (Test-Path -LiteralPath $pair) { Remove-Item -LiteralPath $pair -Force }
            $code = Invoke-Step ('fixture.' + $stem + '.link') $gcc (@('-r', '-nostdlib', '-o', $pair) + $objects) $root
            if ($code -ne 0 -or -not (Test-Path -LiteralPath $pair)) {
                $dup = @([regex]::Matches(((Log-Text ('fixture.' + $stem + '.link')) -replace "`r?`n", ''), 'multiple definition of .([A-Za-z_0-9]+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
                $why = "the units do not link together, exit $code, multiple definition of: " + ($dup -join ', ')
            }
            if ($bad.Count -ne 0) {
                $said = 'SYMBOLS: ' + ($bad -join '; ')
                if ($why -ne '') { $why = $said + ' -- LINK: ' + $why } else { $why = $said + ' -- LINK: exit 0, which is no comfort: a cell that is shared links' }
            }
        }
        if ($why -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) $why; continue }
        Add-Row 'OK' ('fixture:' + $stem) ($units.Count.ToString() + ' library units in one relocatable link, own cells ' + ($cells -join ' ') + ', no unhashed external name; LINK and SYMBOLS only, nothing was run'); continue
    }

    if ($fx.Expect -eq 'eternal-runs') {
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = ''
        foreach ($a in $fx.Absent) {
            if ($why -eq '' -and $l1 -match [regex]::Escape($a)) { $why = 'the generated L1 still names "' + $a + '"' }
        }
        foreach ($d in $fx.Debt) {
            if ($why -eq '' -and $l1 -notmatch [regex]::Escape($d)) { $why = 'the generated L1 lacks "' + $d + '"' }
        }
        # `BindOrder`: the emitter-order assertion of the sticky rule, on the text (Test-BindOrder).
        if ($why -eq '' -and $fx.PSObject.Properties['BindOrder'] -and $fx.BindOrder) {
            $order = Test-BindOrder $l1
            if ($order -ne '') { $why = 'binding order in the generated L1: ' + $order }
        }
        if ($why -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) $why; continue }
        if (-not $driver) { Add-Row 'FAIL' ('fixture:' + $stem) 'the driver did not build, so the program cannot be run'; continue }
        $genO = Join-Path $gen ($stem + '.o')
        $exe = Join-Path $bin ($stem + '.exe')
        # The generated C is compiled AS IT IS; the renames are what hands its launch to the driver.
        # The launch rename (-159 commit 2b) lets the driver see the one lmx_root_launch main makes, the
        # program builder the host calls, and the exit code the launch returns (l2_eternal_driver.lm1).
        # The merge rename (S1.1) passes every merge the program makes through the driver's tap, which
        # fails the Nth on `MergeFail`.
        $code = Invoke-Step ('fixture.' + $stem + '.compile') $gcc ($kflags + @('-Dmain=l2_generated_main', '-Dlmx_root_launch=l2_driver_root_launch', '-Dlmx_merge_owned=l2_driver_merge_owned', '-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned', '-c', $genC, '-o', $genO)) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $genO)) { Add-Row 'FAIL' ('fixture:' + $stem) "gcc exit $code on the generated C"; continue }
        $code = Invoke-Step ('fixture.' + $stem + '.link') $gcc @('-o', $exe, $driverO, $genO, $l2libcO) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) { Add-Row 'FAIL' ('fixture:' + $stem) "link exit $code"; continue }
        # The expected entry value travels as the driver fact `entry N` (default 0, the fixtures' pass).
        $runArgs = @($fx.Args)
        if ($fx.PSObject.Properties['Entry']) { $runArgs = $runArgs + @('entry', [string]$fx.Entry) }
        # S3: C main posts argv to R0 inside a letter.  `Letters` is how many letters R0 still holds
        # at close (default 1: the argv letter, untaken; close must release it); `Argv` is the
        # program's own arguments, given to it after `--` (its argv[0] is the driver's).
        if ($fx.PSObject.Properties['Letters']) { $runArgs = $runArgs + @('letters', [string]$fx.Letters) }
        # `Fails`: the entry does not complete (an uncaught implicit failure), so the program has no
        # value and exits 1; the driver checks exactly that instead of an entry value.
        if ($fx.PSObject.Properties['Fails']) { $runArgs = $runArgs + @('fails', [string]$fx.Fails) }
        # S1.1: `MergeFail` N fails the program's Nth merge (the driver's merge tap); `Stopped` 1 is R0's
        # Message stopped at close (running = 0) and 0 still running; `Thrown` is the status that
        # reached the root -- the implicit name's g, since E declares no throws.
        if ($fx.PSObject.Properties['MergeFail']) { $runArgs = $runArgs + @('mergefail', [string]$fx.MergeFail) }
        if ($fx.PSObject.Properties['Stopped']) { $runArgs = $runArgs + @('stopped', [string]$fx.Stopped) }
        if ($fx.PSObject.Properties['Thrown']) { $runArgs = $runArgs + @('thrown', [string]$fx.Thrown) }
        if ($fx.PSObject.Properties['Argv']) { $runArgs = $runArgs + @('--') + @($fx.Argv | ForEach-Object { $_.Replace('{source}', $source) }) }
        $ran = Invoke-Step ('fixture.' + $stem + '.run') $exe $runArgs $bin
        $said = ((Log-Text ('fixture.' + $stem + '.run')) -split "`r?`n" | Where-Object { $_ -match '^l2_eternal_driver: \d+ checks' } | Select-Object -Last 1)
        # A run that completed but whose entry returned nonzero is a RESULT failure, named as such.
        $entrySaid = ((Log-Text ('fixture.' + $stem + '.run')) -split "`r?`n" | Where-Object { $_ -match '^l2_eternal_driver: entry returned ' } | Select-Object -Last 1)
        if ($ran -ne $fx.Exit -or -not $said) {
            if ($entrySaid) { Add-Row 'FAIL' ('fixture:' + $stem) ('RESULT: ' + ($entrySaid -replace '^l2_eternal_driver: ', '') + '; ran under the driver, exit ' + $ran + '; see the log'); continue }
            Add-Row 'FAIL' ('fixture:' + $stem) ('ran under the driver, exit ' + $ran + '; see the log'); continue
        }
        # `Says`: what the PROGRAM printed, as whole lines and in order.  Lines of the log that are
        # not the program's (the command header, the driver's own, the exit line) are not counted,
        # and the program must have printed EXACTLY these lines -- one more or one fewer is a miss.
        if ($fx.PSObject.Properties['Says'] -and $fx.Says) {
            $printed = @((Log-Text ('fixture.' + $stem + '.run')) -split "`r?`n" | Where-Object { $_ -ne '' -and $_ -notmatch '^(command: |cwd: |exit: |l2_eternal_driver: )' -and $_ -notmatch '^﻿?command: ' })
            $miss = ''
            if ($printed.Count -ne $fx.Says.Count) { $miss = 'printed ' + $printed.Count + ' lines, expected ' + $fx.Says.Count }
            for ($k = 0; $miss -eq '' -and $k -lt $fx.Says.Count; $k++) {
                if ($printed[$k] -cne $fx.Says[$k]) { $miss = 'line ' + ($k + 1) + ' is "' + $printed[$k] + '", expected "' + $fx.Says[$k] + '"' }
            }
            if ($miss -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) ('the program said something else: ' + $miss); continue }
        }
        # A row that declares 0 roots proved no retention and no collection, and must not say so.
        $what = ', exact profiled roots in the current Message graph survive collection ('
        if ($fx.Args[0] -eq '0') { $what = ', no eternal branch: compiled unchanged, linked to the kernel closure, ran to its one close (' }
        if ($fx.PSObject.Properties['Says'] -and $fx.Says) { $what = ', said its ' + $fx.Says.Count + ' lines exactly (' }
        if ($fx.PSObject.Properties['BindOrder'] -and $fx.BindOrder) { $what = $what + 'binding order asserted in the text, ' }
        Add-Row 'OK' ('fixture:' + $stem) (($said -replace '^l2_eternal_driver: ', '') + $what + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden in the text)'); continue
    }

    Add-Row 'FAIL' ('fixture:' + $stem) ('no such Expect kind: ' + $fx.Expect)
}

foreach ($r in $rows) { Write-Output ($r.State.PadRight(5) + $r.Label.PadRight(34) + $r.Note) }
Write-Output ''
if ($red.Count -eq 0) {
    if ($provenanceMode) {
        # FAIL CLOSED ON AN INCOMPLETE MANIFEST: the marker may only be written when every fact it
        # is meant to carry is actually present.  Without this gate a quietly failing line (a
        # function out of scope, a swallowed error) yields a manifest that omits, say, the l1trans
        # identity and still advertises itself as complete -- measured on the first version of this
        # change, where three early lines failed with CommandNotFoundException and the manifest was
        # written anyway.
        $required = @('stamp', 'git_head', 'l1trans_path', 'l1trans_raw_sha256', 'l1trans_masked_sha256',
                      'source_dev_l2trans_sha256', 'source_staged_l2trans_sha256',
                      'source_dev_l2_libc_sha256', 'source_staged_l2_libc_sha256',
                      'gen_l2trans_c_sha256', 'gen_l2_libc_c_sha256',
                      'l2trans_path', 'l2trans_raw_sha256', 'l2trans_masked_sha256',
                      'l2trans_e_lfanew', 'mask_offsets')
        $have = @{}
        foreach ($l in $script:provLines) { if ($l -match '^([A-Za-z0-9_]+)=') { $have[$Matches[1]] = 1 } }
        $missing = @($required | Where-Object { -not $have.ContainsKey($_) })
        if ($missing.Count -gt 0) {
            throw ('provenance: refusing to write a completion manifest -- required evidence is missing: ' + ($missing -join ', '))
        }
        Prov-Line ('rows_ok=' + $rows.Count)
        Prov-Line 'rows_failed=0'
        Prov-Line 'exit=0'
        Prov-Line 'claim=derived-toolchain provenance only; no self-hosting and no fixed-point claim'
        # ATOMIC: written to a sibling temp file and renamed over the target, so a reader sees
        # either nothing or a COMPLETE manifest, never a partial one.  This is the only file a
        # consumer may read; the transcript beside it is for debugging a run that died.
        # ENCODING IS PART OF THE CONTRACT: UTF-8 WITHOUT a BOM, and LF-only.  Do NOT "simplify"
        # this back to Set-Content -Encoding utf8 -- on Windows PowerShell 5.1 that writes a BOM,
        # and -Encoding utf8NoBOM does not exist before PowerShell 6, so the natural cmdlet
        # parameter produces a change that reviews clean and leaves EF BB BF in front of the first
        # key.  Measured on the previous revision: a BOM broke one key while CRLF put a trailing CR
        # on 30 of 31 lines, so a consumer splitting on LF read '...144120\r' for the stamp and a
        # trailing CR on every hash.  -VerifyEvidence asserts both bytes, and
        # tools\l2_provenance_probe.ps1 checks them independently.
        $tmp = Join-Path $OutDir ('PROVENANCE_COMPLETE.tmp.' + $PID)
        [System.IO.File]::WriteAllText($tmp, (($script:provLines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
        Move-Item -LiteralPath $tmp -Destination (Join-Path $OutDir 'PROVENANCE_COMPLETE.txt') -Force
        Write-Output ('l2_harness: provenance COMPLETE -- ' + (Join-Path $OutDir 'PROVENANCE_COMPLETE.txt'))
    }
    Write-Output ('l2_harness GREEN: ' + $rows.Count + ' targets, no failures; evidence ' + $OutDir)
    exit 0
}
if ($provenanceMode) { Prov-Line ('rows_failed=' + $red.Count + ' (no completion manifest is written)') }
Write-Output ('l2_harness RED: ' + $red.Count + ' of ' + $rows.Count + ' targets failed; evidence ' + $OutDir)
exit 1
