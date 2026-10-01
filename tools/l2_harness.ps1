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
    # -KeepAll keeps every file of the run (next_core_tasks.md §0, build memory, item 4): without it an
    # OK fixture row's per-fixture logs and generated files are removed at the end, see below.
    [switch]$KeepAll,
    # A focused diagnostic run, selected by fixture stem. Its summary explicitly
    # records the scope; it never supplies a full-gate provenance certificate.
    [string[]]$OnlyFixture = @(),
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
if ($OnlyFixture.Count -gt 0 -and ($Provenance -or $ProvenanceCheckOnly -or $VerifyEvidence)) {
    throw 'OnlyFixture is a diagnostic scope and cannot be used with provenance modes'
}
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sandbox = Join-Path $root 'dev\l2src_sandbox'
# The peak memory of the steps (next_core_tasks.md §0, build memory, item 3).
$peakMem = Join-Path $root 'tools\peak_mem.ps1'
if (-not (Test-Path -LiteralPath $peakMem)) { throw "missing helper: $peakMem" }
. $peakMem

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

# Parse the emitted walker graph once.  A constructor's owner is allocation context, not
# attachment: executable reachability starts at the root sequence, follows STORED operators and
# bodies, and activates another callable sequence only through a reachable CALL/EXEC.
function Get-WalkGraphFacts([string]$Text) {
    $frames = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) lmx_walk_frame\([^\r\n]*?, (?<owner>l2_rw\d+|l2_entry_unit), c\.LMX_WALK_OP_(?<op>[A-Z_]+), (?<width>\d+)U\)[ \t]*$')) {
        $frames[$m.Groups['name'].Value] = [pscustomobject]@{
            Name = $m.Groups['name'].Value; Owner = $m.Groups['owner'].Value
            Op = $m.Groups['op'].Value; Width = [int]$m.Groups['width'].Value
        }
    }
    $plain = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) lmx_walk_plain\([^\r\n]*, (?<width>\d+)U\)[ \t]*$')) { $plain[$m.Groups['name'].Value] = [int]$m.Groups['width'].Value }
    $aliases = @{}
    $descriptors = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*(?<name>l2_nsp\[\d+\]):[ \t]*(?<value>[^\r\n]*)$')) {
        $name = $m.Groups['name'].Value
        $descriptors.Remove($name)
        if ($m.Groups['value'].Value -match '^lmx_(struct|node)_new_(owned|profiled)\(') { $descriptors[$name] = $true }
    }
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) (?<value>l2_entry_unit|lmx_arena_ref_struct\(l2_entry_unit, \d+U\))[ \t]*$')) {
        $aliases[$m.Groups['name'].Value] = $m.Groups['value'].Value
    }
    function Resolve-WalkName([string]$Name) {
        $seen = @{}
        while ($aliases.ContainsKey($Name) -and -not $seen.ContainsKey($Name)) { $seen[$Name] = $true; $Name = $aliases[$Name] }
        return $Name
    }
    # The generated builder is straight-line.  Observe the graph after its final write to a
    # (parent, slot), including an explicit zero which removes an earlier edge.
    $storeMap = @{}
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -notmatch '^[ \t]*if:[ \t]+') { continue }
        foreach ($m in [regex]::Matches($line, 'lmx_arena_ref_store\((?<parent>l2_rw\d+|l2_entry_unit), (?<slot>\d+)U, (?<value>.*?)\) != 0')) {
            $value = $m.Groups['value'].Value
            $child = ''
            $cm = [regex]::Match($value, '^\(cast: \(@: void\) (?<child>.+)\)$')
            if ($cm.Success) { $child = $cm.Groups['child'].Value }
            $role = ''
            $rm = [regex]::Match($value, 'c\.LMX_WALK_OP_(?<role>[A-Z_]+)')
            if ($rm.Success) { $role = $rm.Groups['role'].Value }
            $store = [pscustomobject]@{ Parent = (Resolve-WalkName $m.Groups['parent'].Value); Slot = [int]$m.Groups['slot'].Value; Value = $value; Child = (Resolve-WalkName $child); Role = $role }
            $storeMap[$store.Parent + ':' + $store.Slot] = $store
        }
    }
    $stores = @($storeMap.Values)
    $sizes = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*if: lmx_walk_store_size\(l2_program_arena, (?<node>l2_rw\d+), (?<slot>\d+)U, (?<value>\d+)U\) != c\.LMX_WALK_OK[ \t]*$')) {
        $sizes[$m.Groups['node'].Value + ':' + $m.Groups['slot'].Value] = [int64]$m.Groups['value'].Value
    }
    $ints = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*if: lmx_walk_store_int\(l2_program_arena, (?<node>l2_rw\d+), (?<slot>\d+)U, (?<value>-?\d+)\) != c\.LMX_WALK_OK[ \t]*$')) {
        $ints[$m.Groups['node'].Value + ':' + $m.Groups['slot'].Value] = [int64]$m.Groups['value'].Value
    }
    $primitiveFns = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*(?<primitive>l2_rwp\d+)\\fn: (?<fn>[A-Za-z_][A-Za-z0-9_]*)[ \t]*$')) { $primitiveFns[$m.Groups['primitive'].Value] = $m.Groups['fn'].Value }
    $witnesses = @{}
    $cellKey = ''
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -match '^\s*l2_entry_slot: lmx_arena_ref_cell\((l2_rw\d+), (\d+)U\)\s*$') { $cellKey = $Matches[1] + ':' + $Matches[2] }
        if ($cellKey -ne '' -and $line -match '^\s*l2_entry_slot\[0\]: (.+)$') { $witnesses[$cellKey] = $Matches[1] }
    }

    function Walk-EvaluatesSlot([string]$Op, [int]$Slot, [int]$Width) {
        if ($Op -in @('ADDRESS', 'DEREF', 'OF', 'OWN_OF') -and $Slot -eq 1) { return $true }
        if ($Op -eq 'ADMIT_AS' -and $Slot -eq 3) { return $true }
        if ($Op -in @('SET', 'SET_ARG') -and $Slot -eq 2) { return $true }
        if ($Op -eq 'PUT' -and ($Slot -eq 1 -or $Slot -eq 2)) { return $true }
        if ($Op -eq 'PUT_REF' -and $Slot -eq 3) { return $true }
        if ($Op -in @('SET_OF', 'PUT_OF') -and ($Slot -eq 1 -or $Slot -eq 3)) { return $true }
        if ($Op -in @('AND', 'OR', 'ADD', 'SUB', 'MUL', 'DIV', 'MOD', 'LT', 'EQ', 'ELEM') -and ($Slot -eq 1 -or $Slot -eq 2)) { return $true }
        if ($Op -eq 'ELEMPUT' -and $Slot -ge 1 -and $Slot -le 3) { return $true }
        if ($Op -in @('IF', 'WHILE', 'FOR', 'UNTIL', 'RET') -and $Slot -eq 1) { return $true }
        # Primitive frames carry their executable operands after fn/signature metadata.
        if (($Op -eq 'PRIM' -or $Op -eq 'PRIM_PUB') -and $Slot -ge 3) { return $true }
        if (($Op -eq 'CALL' -or $Op -eq 'EXEC') -and ($Slot -eq 2 -or $Slot -ge 5)) { return $true }
        # ARG's optional lexical fallback is evaluated only when no dynamic binding exists;
        # retaining it is therefore executable graph coverage too.
        if ($Op -eq 'ARG' -and $Slot -eq 2) { return $true }
        return $false
    }
    function Walk-IsBodySlot([string]$Op, [int]$Slot) {
        if ($Op -eq 'IF' -and ($Slot -eq 2 -or $Slot -eq 3)) { return $true }
        if (($Op -eq 'WHILE' -or $Op -eq 'UNTIL') -and $Slot -eq 2) { return $true }
        if ($Op -eq 'FOR' -and ($Slot -eq 2 -or $Slot -eq 3)) { return $true }
        return $false
    }

    $exec = @{ 'l2_entry_unit' = $true }
    $reachable = @{}
    do {
        $changed = $false
        foreach ($s in $stores) {
            $child = $s.Child
            # A sequence executes its stored statements.  Data stored by an operator is followed
            # only where that opcode's runtime contract evaluates it or enters it as a body.
            if ($exec.ContainsKey($s.Parent) -and $frames.ContainsKey($child) -and -not $reachable.ContainsKey($child)) { $reachable[$child] = $true; $changed = $true }
            if ($reachable.ContainsKey($s.Parent)) {
                $op = $frames[$s.Parent].Op
                if ((Walk-EvaluatesSlot $op $s.Slot $frames[$s.Parent].Width) -and $frames.ContainsKey($child) -and -not $reachable.ContainsKey($child)) { $reachable[$child] = $true; $changed = $true }
                if ((Walk-IsBodySlot $op $s.Slot) -and $child -ne '' -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
                if ($op -eq 'CALL' -and $s.Slot -eq 1 -and $child -ne '' -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
                if ($op -eq 'EXEC' -and $s.Slot -eq 2 -and $child -ne '' -and -not $frames.ContainsKey($child) -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
            }
        }
    } while ($changed)
    return [pscustomobject]@{ Frames = $frames; Plain = $plain; Stores = $stores; Sizes = $sizes; Ints = $ints; PrimitiveFns = $primitiveFns; Witnesses = $witnesses; Descriptors = $descriptors; Reachable = $reachable; Exec = $exec }
}

function Get-WalkWitnessKind($Graph, [string]$Part, [int]$Slot) {
    $key = $Part + ':' + $Slot
    if ($Graph.Witnesses.ContainsKey($key) -and $Graph.Witnesses[$key] -match '^lmx_(int|char|size|unsigned|ulong|pointer)_new_owned\(') { return $Matches[1] }
    $edge = @($Graph.Stores | Where-Object { $_.Parent -eq $Part -and $_.Slot -eq $Slot }) | Select-Object -First 1
    if ($null -ne $edge -and $edge.Child -match '^(?:l2_entry_unit|lmx_arena_ref_struct\(l2_entry_unit, \d+U\))$') { return 'descriptor' }
    if ($null -ne $edge -and $Graph.Descriptors.ContainsKey($edge.Child)) {
        $attached = @($Graph.Stores | Where-Object { $_.Parent -eq 'l2_entry_unit' -and $_.Child -eq $edge.Child })
        if ($attached.Count -eq 1) { return 'descriptor' }
    }
    return ''
}

function Test-WalkCallContract($Graph, [string]$Name, [int]$Arity, $Void, $InputKinds = $null, [string]$ResultKind = '') {
    $edge = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 3 }) | Select-Object -First 1
    if ($null -eq $edge -or -not $Graph.Plain.ContainsKey($edge.Child) -or $Graph.Plain[$edge.Child] -ne 2) { return $false }
    $parts = @()
    foreach ($slot in 0,1) {
        $part = @($Graph.Stores | Where-Object { $_.Parent -eq $edge.Child -and $_.Slot -eq $slot }) | Select-Object -First 1
        if ($null -eq $part -or -not $Graph.Plain.ContainsKey($part.Child)) { return $false }
        $parts += $part.Child
    }
    if ($Arity -lt 0) {
        $catches = 0
        if ($Graph.Sizes.ContainsKey($Name + ':4')) { $catches = $Graph.Sizes[$Name + ':4'] }
        $Arity = $Graph.Frames[$Name].Width - 5 - 3 * $catches
    }
    if ($Graph.Plain[$parts[0]] -ne $Arity -or $Graph.Plain[$parts[1]] -notin @(0,1)) { return $false }
    if ($null -ne $Void -and $Graph.Plain[$parts[1]] -ne [int](-not $Void)) { return $false }
    foreach ($part in $parts) {
        for ($slot = 0; $slot -lt $Graph.Plain[$part]; $slot++) {
            if ((Get-WalkWitnessKind $Graph $part $slot) -eq '') { return $false }
        }
    }
    if ($null -ne $InputKinds) {
        if ($InputKinds.Count -ne $Arity) { return $false }
        for ($slot = 0; $slot -lt $Arity; $slot++) { if ((Get-WalkWitnessKind $Graph $parts[0] $slot) -ne $InputKinds[$slot]) { return $false } }
    }
    if ($ResultKind -ne '' -and (Get-WalkWitnessKind $Graph $parts[1] 0) -ne $ResultKind) { return $false }
    return $true
}

function Test-WalkShapeNode($Graph, [string]$Name, $Shape) {
    if (-not $Graph.Frames.ContainsKey($Name)) { return $false }
    $node = $Graph.Frames[$Name]
    if ($node.Op -ne $Shape.Op -or $node.Width -ne [int]$Shape.Width) { return $false }
    if ($Shape.PSObject.Properties['Sizes']) {
        foreach ($v in $Shape.Sizes) { if (-not $Graph.Sizes.ContainsKey($Name + ':' + $v.Slot) -or $Graph.Sizes[$Name + ':' + $v.Slot] -ne [int64]$v.Value) { return $false } }
    }
    if ($Shape.PSObject.Properties['Ints']) {
        foreach ($v in $Shape.Ints) { if (-not $Graph.Ints.ContainsKey($Name + ':' + $v.Slot) -or $Graph.Ints[$Name + ':' + $v.Slot] -ne [int64]$v.Value) { return $false } }
    }
    if ($Shape.PSObject.Properties['WitnessKind']) {
        if ((Get-WalkWitnessKind $Graph $Name 3) -ne $Shape.WitnessKind) { return $false }
    }
    if ($Shape.PSObject.Properties['Edges']) {
        foreach ($edge in $Shape.Edges) {
            $store = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq [int]$edge.Slot -and $_.Child -ne '' }) | Select-Object -First 1
            if ($null -eq $store -or -not (Test-WalkShapeNode $Graph $store.Child $edge.Shape)) { return $false }
        }
    }
    if ($Shape.PSObject.Properties['PrimitiveFn']) {
        $store = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 1 -and $_.Child -ne '' }) | Select-Object -First 1
        if ($null -eq $store -or -not $Graph.PrimitiveFns.ContainsKey($store.Child) -or $Graph.PrimitiveFns[$store.Child] -ne $Shape.PrimitiveFn) { return $false }
    }
    if ($Shape.PSObject.Properties['CallLink'] -and $Shape.CallLink) {
        $callee = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 1 -and $_.Child -ne '' }) | Select-Object -First 1
        $receiver = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 2 -and $_.Child -ne '' }) | Select-Object -First 1
        $result = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 3 }) | Select-Object -First 1
        if ($null -eq $callee -or $null -eq $receiver -or $callee.Child -ne $receiver.Child -or $null -eq $result) { return $false }
        if ($Shape.PSObject.Properties['CalleeSlot'] -and $callee.Child -ne ('lmx_arena_ref_struct(l2_entry_unit, ' + $Shape.CalleeSlot + 'U)')) { return $false }
        $resultKind = ''
        $inputKinds = $null
        if ($Shape.PSObject.Properties['ResultKind']) { $resultKind = $Shape.ResultKind }
        if ($Shape.PSObject.Properties['InputKinds']) { $inputKinds = $Shape.InputKinds }
        if (-not (Test-WalkCallContract $Graph $Name -1 $null $inputKinds $resultKind)) { return $false }
    }
    if ($Shape.PSObject.Properties['NextRole']) {
        $incoming = @($Graph.Stores | Where-Object { $_.Child -eq $Name -and $Graph.Exec.ContainsKey($_.Parent) }) | Select-Object -First 1
        if ($null -eq $incoming) { return $false }
        $next = @($Graph.Stores | Where-Object { $_.Parent -eq $incoming.Parent -and $_.Slot -eq ($incoming.Slot + 1) -and $_.Role -eq $Shape.NextRole }) | Select-Object -First 1
        if ($null -eq $next) { return $false }
    }
    return $true
}

# Relationship witnesses for native execution WITH the original executable graph retained.
# Method numbers are fixture-local declaration order; rwN/child-slot numbers are discovered
# from the native binding and matched back to that same CALL, not pinned as global ordinals.
function Get-DispatchMethodSlots([string]$Text, [int[]]$Methods) {
    $slots = @{}
    $current = -1
    foreach ($line in ($Text -split '\r?\n')) {
        if ($line -match '^\s*#') { continue }
        if ($line -match '^\s*l2_entry_leaf: lmx_arena_ref_struct\(l2_entry_unit, (\d+)U\)\s*$') { $current = [int]$Matches[1] }
        elseif ($line -match '^\s*l2_entry_leaf: l2_entry_unit\s*$') { $current = -1 }
        elseif ($line -match '^\s*l2_entry_leaf\\native: \(cast: \(LmxEntry\) l2_m(\d+)_tr\)\s*$') {
            $slots[[int]$Matches[1]] = $current
        }
    }
    foreach ($method in $Methods) {
        if (-not $slots.ContainsKey($method) -or $slots[$method] -lt 0) { throw "Dispatch tap lacks a physical unit slot for native method $method" }
        [string]$slots[$method]
    }
}

function Get-NativeCallFacts([string]$Text) {
    $facts = [System.Collections.Generic.List[object]]::new()
    foreach ($body in [regex]::Matches($Text, '(?ms)^(?:fn|sub): l2_m(?<caller>\d+) [^\r\n]*\n(?<body>.*?)^end: l2_m\k<caller>\s*$')) {
        $code = $body.Groups['body'].Value
        $pattern = '(?m)^\s*(?<prefix>if:|l2_ts\d+:) lmx_call_prim\(l2_program_arena, (?<callee>l2_c\d+), (?<owner>l2_c\d+), (?<refs>l2_cfr\d+|0), (?<arity>\d+)U, (?<dest>[^\r\n]*), @ (?<out>l2_o\d+)\)(?<guard> != 0)?[ \t]*$'
        foreach ($call in [regex]::Matches($code, $pattern)) {
            $callee = $call.Groups['callee'].Value
            $refs = $call.Groups['refs'].Value
            $arity = [int]$call.Groups['arity'].Value
            $selection = [regex]::Match($code, '(?m)^\s*@: Lmx ' + $callee + ' (?<value>[^\r\n]+)$')
            $valid = $selection.Success -and $callee -eq $call.Groups['owner'].Value
            $args = @()
            if ($arity -eq 0) { $valid = $valid -and $refs -eq '0' }
            else {
                $valid = $valid -and [regex]::IsMatch($code, '(?m)^\s*\[\]: @\(void\) ' + $refs + ' ' + $arity + '\s*$')
                for ($index = 0; $index -lt $arity; $index++) {
                    $assign = [regex]::Matches($code, '(?m)^\s*' + $refs + '\[' + $index + '\]: \(cast: \(@: void\) \(@ (?<temp>l2_arg(?:_ref)?\d+)\)\)\s*$')
                    if ($assign.Count -ne 1) { $valid = $false; continue }
                    $temp = $assign[0].Groups['temp'].Value
                    $decl = [regex]::Match($code, '(?m)^\s*(?<type>[^\r\n]+?) ' + $temp + ' (?<value>[^\r\n]+)$')
                    if (-not $decl.Success) { $valid = $false; continue }
                    $args += [pscustomobject]@{ Type = $decl.Groups['type'].Value.Trim(); Value = $decl.Groups['value'].Value.Trim(); Temp = $temp }
                }
            }
            $throwing = $call.Groups['prefix'].Value -ne 'if:'
            $status = $call.Groups['prefix'].Value.TrimEnd(':')
            $out = $call.Groups['out'].Value
            $tail = $code.Substring($call.Index + $call.Length)
            $propagation = ''
            if ($throwing) {
                $ordinal = $status.Substring(5)
                $valid = $valid -and [regex]::IsMatch($tail, '^\s*if: ' + $status + ' != 0\s*\r?\n\s*l2_te' + $ordinal + ': \(cast: \(@: Lmx\) ' + $out + '\)\s*\r?\n')
                if ([regex]::IsMatch($tail, '(?m)^\s*if: ' + $status + ' != 0\s*\r?\n\s*l2_out_throw\[0\]: l2_te' + $ordinal + '\s*\r?\n\s*return: ' + $status + '\s*$')) { $propagation = 'forward' }
            } else {
                $valid = $valid -and $call.Groups['guard'].Success -and [regex]::IsMatch($tail, '^\s*c\.fprintf\(c\.stderr, "lmx: invariant: a callable that cannot throw reported a status\\n"\)\s*\r?\n\s*c\.abort\(\)')
            }
            $destination = $call.Groups['dest'].Value
            $result = ''; $resultType = ''
            $storage = [regex]::Match($destination, '^\(cast: \(@: void\) \(@ (?<temp>l2_t\d+)\)\)$')
            if ($storage.Success) {
                $result = $storage.Groups['temp'].Value
                $decl = [regex]::Match($code.Substring(0, $call.Index), '(?m)^\s*(?<type>[^\r\n]+?) ' + $result + '[ \t]*$')
                $valid = $valid -and $decl.Success
                $resultType = $decl.Groups['type'].Value.Trim()
            } elseif ($destination -eq '0') {
                $projection = [regex]::Match($tail, '(?m)^\s*(?<temp>l2_t\d+): \(cast: (?<type>\(@[^\r\n]+?\)) ' + $out + '\)[ \t]*$')
                if ($projection.Success) { $result = $projection.Groups['temp'].Value; $resultType = $projection.Groups['type'].Value }
                else { $resultType = 'void' }
            } else { $valid = $false }
            $facts.Add([pscustomobject]@{Caller=[int]$body.Groups['caller'].Value; Selection=$selection.Groups['value'].Value.Trim(); Arity=$arity; Args=$args; Throwing=$throwing; Destination=$destination; Result=$result; ResultType=$resultType; Tail=$tail; Propagation=$propagation; Valid=$valid})
        }
    }
    return $facts.ToArray()
}

function Test-NativeCalls($Fixture, [string]$Text) {
    $calls = @(Get-NativeCallFacts $Text)
    foreach ($wanted in $Fixture.NativeCalls) {
        $selection = ''
        if ($wanted.PSObject.Properties['Method']) {
            $slot = @(Get-DispatchMethodSlots $Text @([int]$wanted.Method))[0]
            $selection = '^lmx_arena_ref_struct\((?:node|l2_entry_unit), ' + $slot + 'U\)$'
        }
        if ($wanted.PSObject.Properties['Selection']) { $selection = $wanted.Selection }
        $matched = @($calls | Where-Object {
            $candidate = $_
            $ok = $candidate.Valid -and $candidate.Arity -eq $wanted.Args.Count
            if ($wanted.PSObject.Properties['Caller']) { $ok = $ok -and $candidate.Caller -eq $wanted.Caller }
            if ($selection) { $ok = $ok -and $candidate.Selection -match $selection }
            if ($wanted.PSObject.Properties['Throwing']) { $ok = $ok -and $candidate.Throwing -eq $wanted.Throwing }
            if ($wanted.PSObject.Properties['Destination']) { $ok = $ok -and $candidate.Destination -match $wanted.Destination }
            if ($wanted.PSObject.Properties['ResultType']) { $ok = $ok -and $candidate.ResultType -eq $wanted.ResultType }
            if ($wanted.PSObject.Properties['ResultUse']) { $ok = $ok -and $candidate.Result -ne '' -and $candidate.Tail -match $wanted.ResultUse.Replace('{result}', [regex]::Escape($candidate.Result)) }
            if ($wanted.PSObject.Properties['Propagation']) { $ok = $ok -and $candidate.Propagation -eq $wanted.Propagation }
            for ($index = 0; $ok -and $index -lt $wanted.Args.Count; $index++) {
                $ok = $candidate.Args[$index].Type -eq $wanted.Args[$index].Type -and $candidate.Args[$index].Value -match $wanted.Args[$index].Value
            }
            $ok
        })
        $count = 1
        if ($wanted.PSObject.Properties['Count']) { $count = [int]$wanted.Count }
        if ($matched.Count -ne $count) { return ('native typed dispatch relationship count ' + $matched.Count + ', expected ' + $count + ': ' + ($wanted | ConvertTo-Json -Compress -Depth 5)) }
    }
    return ''
}

function Test-NativeGraphWitnesses($Fixture, [string]$Text) {
    # Comments cannot supply bindings, constructors or value writes.
    $Text = (($Text -split "`r?`n") | Where-Object { $_ -notmatch '^\s*#' }) -join "`n"
    $graph = Get-WalkGraphFacts $Text
    if ($Fixture.PSObject.Properties['NativeCalls']) {
        $why = Test-NativeCalls $Fixture $Text
        if ($why) { return $why }
    }
    if ($Fixture.PSObject.Properties['NativePatterns']) {
        foreach ($pattern in $Fixture.NativePatterns) { if ($Text -notmatch $pattern) { return ('native relationship not found: ' + $pattern) } }
    }
    if ($Fixture.PSObject.Properties['LazyArrayReads']) {
        # This fixture has only safe array reads in logical RHS arms. Count
        # actual emitted loads, and require an enclosing lazy-result guard;
        # neither comments, backing declarations nor stores count as loads.
        $guards = [System.Collections.Generic.List[object]]::new()
        $reads = 0
        foreach ($line in ($Text -split '\r?\n')) {
            if ($line -match '^\s*(#|$)') { continue }
            $indent = $line.Length - $line.TrimStart().Length
            while ($guards.Count -gt 0 -and $guards[$guards.Count - 1].Indent -ge $indent) { $guards.RemoveAt($guards.Count - 1) }
            if ($line -match '^\s*l2_t\d+: l2_a\d+_data\[[^\]]+\]\s*$') {
                $reads++
                if (-not @($guards | Where-Object { $_.Lazy }).Count) { return 'array RHS load escaped its lazy logical guard' }
            }
            if ($line -match '^\s*if: (?<condition>.+)$') {
                $guards.Add([pscustomobject]@{ Indent = $indent; Lazy = $Matches.condition -match '^l2_t\d+(?: = 0)?$' })
            }
        }
        if ($reads -ne $Fixture.LazyArrayReads) { return ('found ' + $reads + ' guarded array loads, expected ' + $Fixture.LazyArrayReads) }
    }
    if ($Fixture.PSObject.Properties['NativeMethods']) {
        foreach ($method in $Fixture.NativeMethods) {
            if ($Text -notmatch ('\\native: \(cast: \(LmxEntry\) l2_m' + $method + '_tr\)')) {
                return ('tested method l2_m' + $method + ' has no native implementation word')
            }
        }
    }
    if ($Fixture.PSObject.Properties['WalkedMethods']) {
        foreach ($method in $Fixture.WalkedMethods) {
            if ($Text -notmatch ('(?m)^fn: l2_m' + $method + '_tr ')) { return ('missing tested method trampoline l2_m' + $method) }
            if ($Text -match ('\\native: \(cast: \(LmxEntry\) l2_m' + $method + '_tr\)')) {
                return ('tested method l2_m' + $method + ' still has its native word')
            }
        }
    }
    if ($Fixture.PSObject.Properties['PadAliases']) {
        $found = 0
        foreach ($pad in [regex]::Matches($Text, '@: Lmx (?<pad>l2_rw\d+) lmx_walk_frame\([^\r\n]*, c\.LMX_WALK_OP_PAD, 3U\)')) {
            $alias = 'lmx_arena_ref_store\(' + $pad.Groups['pad'].Value + ', 1U, lmx_arena_ref_value\((?<body>l2_b\d+), (?<slot>\d+)U\)\)'
            if (-not [regex]::IsMatch($Text, $alias)) { return ('PAD ' + $pad.Groups['pad'].Value + ' does not alias its canonical catch cell') }
            $found++
        }
        if ($found -ne $Fixture.PadAliases) { return ('found ' + $found + ' numeric PAD aliases, expected ' + $Fixture.PadAliases) }
    }
    if ($Fixture.PSObject.Properties['NativeRoot']) {
        $rootPattern = '(?ms)l2_entry_leaf: l2_entry_unit\s+(?:(?!l2_entry_leaf:).)*?l2_entry_leaf\\native: \(cast: \(LmxEntry\) l2_m' + $Fixture.NativeRoot + '_tr\)'
        if ($Text -notmatch $rootPattern) { return 'the root graph does not carry its native trampoline' }
    }
    if ($Fixture.PSObject.Properties['GraphCalls']) {
        foreach ($witness in $Fixture.GraphCalls) {
            $bindingPattern = '(?ms)l2_entry_leaf: lmx_arena_ref_struct\(l2_entry_unit, (?<slot>\d+)U\)(?:(?!l2_entry_leaf:).)*?l2_entry_leaf\\native: \(cast: \(LmxEntry\) l2_m' + $witness.Method + '_tr\)'
            $binding = [regex]::Match($Text, $bindingPattern)
            if (-not $binding.Success) { return ('no graph binding for callable l2_m' + $witness.Method) }
            $callee = 'lmx_arena_ref_struct(l2_entry_unit, ' + $binding.Groups['slot'].Value + 'U)'
            $callPattern = '@: Lmx (?<frame>l2_rw\d+) lmx_walk_frame\([^\r\n]*, c\.LMX_WALK_OP_CALL, ' + (5 + $witness.Arity) + 'U\)'
            $found = 0
            foreach ($call in [regex]::Matches($Text, $callPattern)) {
                $frame = $call.Groups['frame'].Value
                if (-not $graph.Reachable.ContainsKey($frame)) { continue }
                $calleeEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq 1 -and $_.Child -eq $callee }) | Select-Object -First 1
                if ($null -eq $calleeEdge) { continue }
                $found++
                $receiverEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq 2 -and $_.Child -eq $callee }) | Select-Object -First 1
                if ($null -eq $receiverEdge) {
                    return ('CALL ' + $frame + ' lost its callable occurrence receiver')
                }
                $isVoid = [bool]($witness.PSObject.Properties['Void'] -and $witness.Void)
                if (-not $witness.PSObject.Properties['InputKinds'] -or (-not $isVoid -and -not $witness.PSObject.Properties['ResultKind'])) { return 'GraphCalls witness lacks explicit declared types' }
                if (-not (Test-WalkCallContract $graph $frame $witness.Arity $isVoid $witness.InputKinds $witness.ResultKind)) { return ('CALL ' + $frame + ' lost its declared input/result contract') }
                if ($witness.PSObject.Properties['Ints']) {
                    for ($argIndex = 0; $argIndex -lt $witness.Ints.Count; $argIndex++) {
                        $argEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq (5 + $argIndex) -and $_.Child -match '^l2_rw\d+$' }) | Select-Object -First 1
                        if ($null -eq $argEdge) { return ('CALL ' + $frame + ' lost argument ' + $argIndex) }
                        $argName = $argEdge.Child
                        if (-not $graph.Frames.ContainsKey($argName) -or $graph.Frames[$argName].Op -ne 'LIT' -or $graph.Frames[$argName].Width -ne 2 -or
                            -not $graph.Ints.ContainsKey($argName + ':1') -or $graph.Ints[$argName + ':1'] -ne $witness.Ints[$argIndex]) {
                            return ('CALL ' + $frame + ' has the wrong literal at argument ' + $argIndex)
                        }
                    }
                }
            }
            if ($found -ne $witness.Count) { return ('callable l2_m' + $witness.Method + ' has ' + $found + ' graph CALLs, expected ' + $witness.Count) }
        }
    }
    if ($Fixture.PSObject.Properties['GraphShapes']) {
        $targets = @{}
        foreach ($shape in $Fixture.GraphShapes) {
            $matches = @()
            foreach ($name in $graph.Reachable.Keys) { if (Test-WalkShapeNode $graph $name $shape) { $matches += $name } }
            if ($matches.Count -ne $shape.Count) { return ($shape.Op + '/' + $shape.Width + ' has ' + $matches.Count + ' reachable matching shapes, expected ' + $shape.Count) }
            if ($shape.PSObject.Properties['TargetTag']) {
                foreach ($name in $matches) {
                    $store = @($graph.Stores | Where-Object { $_.Parent -eq $name -and $_.Slot -eq [int]$shape.TargetSlot -and $_.Child -ne '' }) | Select-Object -First 1
                    if ($null -eq $store) { return ($shape.Op + ' lost target slot ' + $shape.TargetSlot) }
                    if (-not $targets.ContainsKey($shape.TargetTag)) { $targets[$shape.TargetTag] = $store.Child }
                    elseif ($targets[$shape.TargetTag] -ne $store.Child) { return ('graph target tag ' + $shape.TargetTag + ' does not name one occurrence') }
                }
            }
        }
    }
    return ''
}

# Run a command, capture everything, return the exit code; the transcript is the evidence.
function Invoke-Step([string]$Label, [string]$Exe, [string[]]$ArgList, [string]$WorkDir) {
    Set-PeakStep $Label $Exe
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
Write-Output ('l2_harness on ' + ((git -C $root rev-parse HEAD) -join '').Substring(0, 8) + '; translator ' + $Translator + '; gcc ' + $gcc)
Write-Output ('l2_harness: evidence ' + $OutDir)

# ---- 1. stage -------------------------------------------------------------------------------
$staged = 0
foreach ($f in @(Get-ChildItem -LiteralPath $sandbox -File -Filter '*.lm1')) {
    if ($f.Name -match '_(win32|posix)\.lm1$') { continue }
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l2src\' + $f.Name)) -Force; $staged++
}
foreach ($logical in @('lmx_clock.lm1', 'lmx_process_deadline.lm1', 'lmx_manager_running.lm1', 'lmx_manager_running_lane.lm1')) {
    $physical = $logical -replace '\.lm1$', '_win32.lm1'
    Copy-Item -LiteralPath (Join-Path $sandbox $physical) -Destination (Join-Path $src ('l2src\' + $logical)) -Force; $staged++
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
    # Foreign ABI witnesses are frozen alongside their L2 callers; generated
    # C includes these staged headers, never a mutable live-checkout helper.
    foreach ($f in @(Get-ChildItem -LiteralPath $testsHdr -File -Filter '*.h')) {
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $destTests $f.Name) -Force; $staged++
    }
}
Copy-Item -LiteralPath (Join-Path $sandbox 'convert.lm2') -Destination (Join-Path $src 'convert.lm2') -Force
$staged++
# The sandbox's tables and receivers: parts of every row's program, named at the call (steps/table-receiver.md
# §8, Q46; the rows' Table, Primitive, Impl and Parts below).
Copy-Item -LiteralPath (Join-Path $sandbox 'primitive.lm2') -Destination (Join-Path $src 'primitive.lm2') -Force
$staged++
# The receivers the rows name (Q33): ordinary L2 methods beside the table.
Copy-Item -LiteralPath (Join-Path $sandbox 'convert_impl.lm2') -Destination (Join-Path $src 'convert_impl.lm2') -Force
$staged++
Write-Output ('l2_harness: staged ' + $staged + ' files into ' + $src)
if ($provenanceMode) {
    # The staged l2src\l2trans.lm1 and l2_libc.lm1 must be BYTE COPIES of the LIVE dev sandbox
    # sources, never the root l2src (a copy of the sandbox kept in the old place, not tested: -198).  This matters because the translator is handed the
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
Start-PeakSampler
# Translate the staged headers before any consumer, including the translator's
# own compiler-metadata records. Header production is not a runtime-only phase.
$headers = Join-Path $OutDir 'headers'
New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l2src') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l1src') | Out-Null
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
# The same four narrow -Werror guards build_l2src.ps1's default flags use (tools/build_l2src.ps1),
# so a green harness here reliably predicts a green build_l2src gate for this class of defect
# (fable_pc's remark on REVIEW c08e34f: harness flags lacked them, so a missing forward
# declaration -- implicit-function-declaration -- was caught only by build_l2src, after the
# harness had already gone green on the same translator source).
$cflags = @('-std=c99', '-Wall', '-Wextra', '-Wpedantic', '-I', $headers, '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $sandbox,
            '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
            '-Werror=implicit-function-declaration', '-Werror=implicit-int')
# §0 item 2 (build memory): cc1 collects no garbage under 128 MB of heap by default (gcc 13.1); a 16 MB
# threshold with 20 % growth -- l2trans.c 155 -> 86 MB, measured.  The same pair is in build_l2src.ps1;
# $kflags below carries it too.
$ggc = @('--param', 'ggc-min-heapsize=16384', '--param', 'ggc-min-expand=20')
$cflags += $ggc
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
# -Werror=implicit-function-declaration (-159 commit 2b): a generated unit that calls a kernel act it
# never declared (a missing predef) is refused here, not compiled with an implicit int return -- which
# truncates a returned pointer to 32 bits.
$kflags = @('-std=c99', '-Werror=implicit-function-declaration', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $src, '-I', $headers) + $ggc
$driverSource = Join-Path $sandbox 'harness\l2_eternal_driver.lm1'
$driverC = Join-Path $gen 'l2_eternal_driver.c'
$driverO = Join-Path $gen 'l2_eternal_driver.o'
# The fixtures' own predef headers (tests\*.h.lm1, staged into l2src\tests\): a running fixture whose
# predef declares a C function reaches gcc through one (D-68, unit_define_ccall).  They are not the
# driver's closure: a refused one is its own FAIL row and leaves the driver alone.
$testsStaged = Join-Path $src 'l2src\tests'
if (Test-Path -LiteralPath $testsStaged) {
    New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l2src\tests') | Out-Null
    foreach ($h in @(Get-ChildItem -LiteralPath $testsStaged -File -Filter '*.h.lm1' | Sort-Object Name)) {
        $base = $h.Name.Substring(0, $h.Name.Length - '.h.lm1'.Length)
        $target = Join-Path $headers ('l2src\tests\' + $base + '.lm1.h')
        if (-not (Step-Made ('header.tests.' + $base) $Translator @(('l2src/tests/' + $h.Name), $target) $src $target)) { Add-Row 'FAIL' ('header:tests.' + $base) 'l1trans produced no header; see the log' }
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
#   l2trans-refuses      -- l2trans must REFUSE it; Needle must appear in what it printed, and it
#                           prints at most one "l2trans error:" line (one cause, one line).
#   translates-with-debt -- the whole translator chain succeeds, AND the generated L1 is then
#                           read: every string in Absent must be GONE from it and every string
#                           in Debt must still be THERE.  This is for a gap that no longer stops
#                           the toolchain but is not fixed, and the asymmetry is the point: a Debt
#                           that is gone means the gap closed and the row must change.
#   translates           -- the same chain and the same reading, for a translation SHAPE that is
#                           the point itself, not a gap (-197 (c)): the surface forms lowering
#                           alike, a deletion's absence, a unit that links against a prototype
#                           only.  Debt here is simply what must be there.  Nothing runs.
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
# library.
#
# THE FACTS OF A RUN (-159 commits 2b and 3).  The generated main is the launch (lmx_root_launch): the
# host reserves R0, R0's one turn walks the unit, and the exit is the host's.  The driver sees it
# through its -Dlmx_root_launch tap, and each fact is what the host reports:
#   Entry N     the launch's exit code: R0's exit letter's `exit_code`, or else the mapping of R0's
#               success (1 -> 0, 0 -> 1).  Default 0.
#   Fails 1     R0 did not complete (an uncaught throw): the exit is 1.
#   Thrown k    the throw number the walk noted -- lmx_call_walk_fail_status() read after the launch
#               (the turn's channel carries k; 0 when nothing was thrown).
#   Stopped 1|0 R0 was stopped, or not, as the host's exit reason says: the driver captures the
#               launch's stderr and looks for "R0 was stopped" (the reason the host gives when R0
#               sent no exit letter and its running is 0).
#   MergeFail N the program's Nth merge fails (the -Dlmx_merge_owned / _profiles_owned taps).
#   Letters N   is not observable any more: R0's close is the host's, which releases R0's untaken
#               letters.  A row that names it is red.
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
    [pscustomobject]@{ Name = 'unit_uniform_stop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 0; NativeRoot = 8; NativeMethods = @(0,1,2,3,4,5,6,7); StopMethods = @(0,1,2,3,4,5,6,7); StopWalk = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_dispatch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 4; NativeMethods = @(0,1,2,3); DispatchMethods = @(0,1,3);
        # The runtime copied-owner tap proves this path's actual identity; the
        # relation additionally checks C storage widths, which equal low bytes alone cannot prove.
        NativeCalls = @([pscustomobject]@{Caller=3; Selection='^l2_pst$'; Count=3; Throwing=$false; ResultType='int:'; ResultUse='(?m)^\s*l2_q\d+: \({result}\)\s*$'; Args=@([pscustomobject]@{Type='int:';Value='^l2_t\d+$'},[pscustomobject]@{Type='char:';Value="^'Q'$"},[pscustomobject]@{Type='size_t:';Value='^4294967303U$'},[pscustomobject]@{Type='@: void';Value='^\(cast: \(@: void\) l2_q\d+\)$'},[pscustomobject]@{Type='int:';Value='^l2_q\d+$'})}); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_dispatch_throw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 4; NativeMethods = @(0,1,2,3); DispatchMethods = @(0,1,3); DispatchThrows = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_foreign_results.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 9; NativeMethods = @(0,1,2,3,4,5,6,7,8); WalkRoot = $true; PointerTypeCheck = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_aggregate.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 3; NativeMethods = @(0,1,2); WalkRoot = $true; PointerTypeCheck = $true; Absent = @(); Debt = @() },
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
    # D-50 / D-51 probes (Opus -175 UNGATED fixtures; registered -174 c0b after walker fixes).
    # unit_walk_int_lt_negative: -1 < 0 at root -> Entry 1. unit_walk_size_t_wide: size_t 2^32 -> Entry 2.
    [pscustomobject]@{ Name = 'unit_walk_int_lt_negative.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_size_t_wide.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2; Absent = @(); Debt = @() },

    # Uniform native root: these explicit L2 bodies no longer fail merely for being at the root.
    # Each output property remains observable, with a nonzero success and the graph's native address.
    [pscustomobject]@{ Name = 'entry_puts_hello.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Args = @('0'); Says = @('Hello'); NativeRoot = 0; Absent = @(); Debt = @('c.puts("Hello")') },
    [pscustomobject]@{ Name = 'entry_puts_seq.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Args = @('0'); Says = @('one', 'two'); NativeRoot = 0; Absent = @(); Debt = @('c.puts("one")', 'c.puts("two")') },
    # Empty output needs a blank-line witness: do not silently replace it with an execution-only row.
    [pscustomobject]@{ Name = 'entry_puts_empty.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_nl.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Args = @('0'); Says = @('x', 'y'); NativeRoot = 0; Absent = @(); Debt = @('c.puts("x\ny")') },
    [pscustomobject]@{ Name = 'entry_puts_esc.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Args = @('0'); Says = @('a"b\c'); NativeRoot = 0; Absent = @(); Debt = @('c.puts("a\"b\\c")') },
    # G4: 15 more c.puts fixtures (arg-shape probes and triple-quote parser probes, all root-level)
    # were never run by any row -- gated here with what l2trans actually gives each today, same
    # class as the five rows above. entry_puts_after_return refuses earlier, at its own `return: 0`
    # (root doesn't allow a value there at all, before the c.puts line is even reached).
    # entry_puts_triple_fence4 is a genuine P0 parse failure, not the semantic refusal the other
    # triple-quote forms get: the source is spec-correct (docs/LMX_grammar.en.md :413,433-435,
    # "four quotes produce three" -- measured to work MID-string; only the symmetric 4-open/
    # 4-close case at end of input fails) -- pin of defect D-96, not of a norm, not fixed here.
    [pscustomobject]@{ Name = 'entry_puts_after_return.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_puts_after_return.lm2:2:5: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_bad_arg.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_extra_arg.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_nested.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_fence4.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unterminated python-like string literal'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_lead.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_lead_sq.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_long.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_runs.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_seven.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_seven_sq.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_single.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_puts.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_two.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Absent = @(); Debt = @() },
    # FABLE-126 part2: migrate/gate former c.array entry fixtures (owned []: char).
    # -170 (translator half, over grok_bot's ELEM 25 / ELEMPUT 26): an own Array of the root is its
    # descriptor in the unit's slot (the graph build makes it; the declaration is no step); `x[N]: v`
    # is ELEMPUT [elemput, 0, slot, N, v] and `x[N]` ELEM [elem, 0, slot, N], N a literal.  Each row
    # writes and reads back; success 7 (it was 0, an empty witness).
    [pscustomobject]@{ Name = 'entry_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    # D-39: index is a size_t field, evaluated, not a literal cell. int index is not cast.
    [pscustomobject]@{ Name = 'entry_dyn_array_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)', 'c.LMX_WALK_OP_AT, 3U)') },
    [pscustomobject]@{ Name = 'entry_dyn_array_index_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # D-39: stack\columns[idx] is a raw C member index, not an own-array literal.
    # lm_own_new_zero is outside the kernel closure, so this row checks the spelling only.
    [pscustomobject]@{ Name = 'unit_indent_stack_field_index.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        NativePatterns = @('(?ms)@: LmP0IndentStack (?<cell>l2_q\d+)\s.*?if: \k<cell>\\columns\[2\] != 7U');
        Absent = @(); Debt = @('l2_p0_0\columns[l2_p0_1]') },
    [pscustomobject]@{ Name = 'entry_array_leading_zero.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    [pscustomobject]@{ Name = 'entry_nul.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    # THE UNIT IS THE ENTRY (FABLE-OPUS-S2-UNIT-IS-ENTRY-20260923-112).  Every non-callable is
    # visible only after its declaration, methods both ways.  unit_s2_vis_dynamic: a method ABOVE a
    # unit field cannot see it, so the name is its dynamic input, handed over by its caller (wrap's
    # own n = 7); a translator that lets the method see the unit field below it reads 3 and the
    # program returns 1 (the visibility mutant, measured).  The three refusals are the same rule
    # for a Structure named by a unit statement, a Structure named by a method signature, and a
    # qualified branch named by a method body.  An empty entry is an empty program (EmptyEntry).
    # A stray trailer after a closed frame is an item since the P0 change of -114 and is refused
    # by name.
    # §7b (7b-1): wrap's own n is a declared field with a working value, so the actual is l2_q0.
    [pscustomobject]@{ Name = 'unit_s2_vis_dynamic.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @();
        NativeCalls = @([pscustomobject]@{Caller=1; Method=0; Throwing=$false; ResultType='int:'; ResultUse='(?m)^\s*return: {result}\s*$'; Args=@([pscustomobject]@{Type='int:'; Value='^l2_q\d+$'})});
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx self; int: l2_p0_0) int') },
    [pscustomobject]@{ Name = 'unit_s2_vis_structure_below_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s2_vis_structure_below_refused.lm2:3:1: unresolved name'; Absent = @(); Debt = @() },
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
    # inbox is empty).  Under the host root (-159 2b) R0's close is the host's, which releases R0's
    # untaken letters, so how many R0 still holds is not a row fact any more: -176 dropped `Letters`
    # from the 20 rows that named it (the driver reports a row that names it red).
    # -179: the take (PRIM lmx_walk_mail_take) and `m = 0` / `m != 0` (EQ over the pointer cell) run.
    [pscustomobject]@{ Name = 'unit_next_message_twice.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @(); Debt = @('\fn: lmx_walk_mail_take') },
    # THE TAKE AT THE WALKED ROOT (FABLE-OPUS-ROOT-TAKE-20260925-179): R0's inbox holds the host's mainArgs
    # letter.  The first take yields it (m != 0); after it the box is empty and a take yields null
    # (m = 0).  Both pin the walked take.
    [pscustomobject]@{ Name = 'unit_root_take_letter.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1;
        Absent = @(); Debt = @('\fn: lmx_walk_mail_take') },
    [pscustomobject]@{ Name = 'unit_root_take_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1;
        Absent = @(); Debt = @('\fn: lmx_walk_mail_take') },
    # -179: the take and the null test are built; pending on `while:` at the root, then `&&` (-170).
    [pscustomobject]@{ Name = 'unit_next_message_loop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @(); Debt = @() },
    # -179: the take and the null test run.
    [pscustomobject]@{ Name = 'unit_next_message_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_method_first.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @('lmx_thread_mail_take'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_one_name.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'receiveMessage: unknown payload model'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_receive_letter_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    # FABLE-SONNET-SEND-REF-20260925-172 commit 3: `sendMessage: Ref X` inside a method body --
    # explicit addressee (m\sender) instead of the implicit lmx_thread_parent(t). R0's own
    # mainArgs letter's sender is the host, the same destination the implicit form already
    # reaches, so this row cannot pin a BEHAVIORAL difference (no L2-level second sender exists
    # yet, -182 pending) -- Debt/Absent pin the STRUCTURAL one instead: the generated C for this
    # site's l2_msend<k> reads its addressee from refs[], never lmx_thread_parent.
    # Mutant: revert l2_emit_send's has_ref branch -> lmx_thread_parent reappears -> RED.
    [pscustomobject]@{ Name = 'unit_send_ref_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_thread_parent');
        Debt = @(); NativePatterns = @('(?s)(?<loaded>l2_t\d+): \(cast: \(const: @\(LmxMsg\)\) lmx_pointer_value_known\((?<cell>l2_\w+)\[0\]\)\)\s+@: void (?<box>l2_msref\d+) \(cast: \(@: void\) \(\k<loaded>\)\)\s+(?<args>l2_msr\d+)\[(?<slot>\d+)\]: \(cast: \(@: void\) \(@ \k<box>\)\).*?if: (?<send>l2_msend\d+)\(0, \k<args>, 2U, 0, 0\).*?fn: \k<send>\b.*?lmx_service_post\(lmx_child_service\(t\), lmx_pointer_value_known\(refs\[\k<slot>\]\), m, a\)') },
    # FABLE-SONNET-SEND-REF-20260925-172 commit 3: `sendMessage: Ref X` at the walked root -- no
    # positive/running row here. Measured (not guessed, three probes) that no root-walkable
    # reference today is BOTH type-accepted and a real postable address: `receiveMessage: m
    # MainLetter` (2-name) refuses "an admission to a Structure type" (pre-existing,
    # l2_rw_take/-178 c3's own documented scope); a root-level `const: @(LmxMsg m 0)` own field
    # refuses "this statement" (frame=const, a separate pre-existing gap); the bare
    # `receiveMessage: m` letter reference DOES type-check and build, but posting to it at runtime
    # (it is the letter, not a Thread/Message address) crashes uncontrolled ("lmx: walk error:
    # PRIMITIVE", exit 3) -- not a Fails/Thrown-shaped outcome any row category here fits, so nothing
    # is pinned on it. steps/send-ref-172.md has the full account; the root mechanism itself
    # (l2_rw_send's has_ref detection, l2_rw_fields_ty's type check, l2_emit_send's shared
    # refs[]-based addressee) is exercised positively by unit_send_ref_method.lm2 above (same
    # l2_emit_send body) and negatively by the refusal row just below.
    # FABLE-SONNET-SEND-REF-20260925-172 commit 3: `sendMessage: Ref X` at the walked root refuses
    # a Ref that is not a reference (l2_rw_fields_ty, ty < 1000) -- on-topic negative witness for
    # the new type-check, at the exact statement.
    # D-80: the letter is a plain Message. It does not implement Thread. Type error
    # at translation. send-abort stays for a mutant that drops this check.
    [pscustomobject]@{ Name = 'unit_send_ref_method_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'a Ref that is not a reference';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_send_ref_root_fail.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'a plain Message does not implement Thread';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_send_ref_root_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a Ref that is not a reference';
        Absent = @(); Debt = @() },
    # FABLE-SONNET-SEND-REF-20260925-172 commit 4: the BEHAVIORAL driver-tap witness, gated on
    # Grok's before_turn launch tap (FABLE-GROKBOT-LAUNCH-TAP-20260925-182). Behind `ref 1`,
    # l2_driver_before_turn posts R0 a second letter (sender = a standalone peer Message the
    # driver builds itself) after mainArgs; the fixture takes mainArgs bare, then the peer's own
    # Ping letter, and replies to m\sender -- then reports its own exit(0) to the host, the ordinary
    # implicit-addressee send every eternal-runs fixture already makes, needed here too since an
    # L2-generated root program has no other way to report a defined exit code. l2_driver_service_post
    # (-Dlmx_service_post) observes every post the generated program makes and prints both counts as
    # the ONLY program output: reply-to-sender counts the Ref-addressed Pong (always 1 here);
    # reply-to-parent counts posts to the host, which includes that ordinary exit(0) (baseline 1,
    # not 0 -- measured, not assumed: a first attempt expecting 0 here was wrong, the exit call
    # itself is a post to the parent). Mutant: hardcode the addressee to lmx_thread_parent(t)
    # regardless of Ref -> the Pong reply ALSO lands on the parent -> reply-to-sender 0 /
    # reply-to-parent 2 -> RED.
    [pscustomobject]@{ Name = 'unit_send_ref_driver_tap.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 0; Needle = '';
        Args = @('0', 'ref', '1');
        Says = @('reply-to-sender 1', 'reply-to-parent 1');
        Absent = @(); Debt = @() },
    # FABLE-SONNET-RECEIVE-RENAME-20260924-166 commit 1: `nextMessage` is no longer a language
    # word (renamed to `receiveMessage`) -- `nextMessage: m` is now an ordinary colon-assignment
    # to an undeclared name, refused like any other (measured: not "unknown method" -- the shape
    # is an assignment target, not a call).
    [pscustomobject]@{ Name = 'unit_next_message_word_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_next_message_word_refused.lm2:6:18: unresolved name'; Absent = @(); Debt = @() },
    # FABLE-SONNET-RECEIVE-RENAME-20260924-166 commit 3 (D-48, Q24 = A): a repeated typed
    # declaration of one name is a new occurrence.
    [pscustomobject]@{ Name = 'unit_q24_repeated_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # A different-typed initializer uses the declared receiver conversion.
    # This program supplies no int->char converter: refuse at its actual operand.
    [pscustomobject]@{ Name = 'unit_q24_mixed_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ':8:14: the program has no method `lm_stg_convert_int_char`'; Absent = @(); Debt = @() },
    # ADMISSION (fable's B2, author Q12): an untyped graph -- the letter receiveMessage takes -- bound
    # to a declared Structure type (receiveMessage into a typed own field, rebinding it, a typed
    # formal's argument) is admitted at run time by the kernel's implements walk against the
    # declared type's shape; a refusal throws the implicit name implements (Q17 = A; g = 2, where a
    # failing merge is 1), and uncaught (`Fails`) the entry has no value, exit 1.  MainLetter is an
    # ordinary declared Structure (author Q15).
    # D-57 (-178 commit 3): the native pre-typed receive admits and binds the letter's PAYLOAD -- a whole
    # letter (sender; payload) refused every host letter since -173.
    [pscustomobject]@{ Name = 'unit_native_typed_receive.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('l2_ngraph: (cast: (@: Lmx) lmx_arena_ref_value(l2_ngraph, 1U))') },
    [pscustomobject]@{ Name = 'unit_admit_letter_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b');
        Absent = @(); Debt = @('\fn: lmx_walk_admit_letter') },
    # D-60 re-measure (fable §11): present(raw) admits the letter by its payload, then
    # `MainLetter: m` and `m: raw` run at the walked root. Success is exit_code 4, not
    # the driver's default 0, so an inverted `entry 0` is red. admit_letter stays, as
    # on unit_admit_letter_typed.
    [pscustomobject]@{ Name = 'unit_admit_letter_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 4;
        Absent = @(); Debt = @('\fn: lmx_walk_admit_letter') },
    [pscustomobject]@{ Name = 'unit_admit_letter_not_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # -178 commit 3: the letter to get's Model formal is admitted by its payload at the call site; {mainArgs}
    # is not a Model, so the caller's implicit `implements` (2 at the root) stops R0.
    [pscustomobject]@{ Name = 'unit_admit_formal_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_rebind_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_letter_extra_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # KNOWN COARSENESS (next_core_tasks.md 7): the walk does not look inside the outer Array, so an
    # `int: []: []:` field admits the char letter.  This row flips to Fails with the port.
    [pscustomobject]@{ Name = 'unit_admit_letter_coarse.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @(); Debt = @() },
    # `T: []: []: x` (author Q15): the outer Array is constructed empty and merge copies it as a new one.
    # The root has both its graph representation and native execution; success is 7.
    [pscustomobject]@{ Name = 'unit_arrarr_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_array_ref_new_owned(c.LMX_TYPE_ARRAY_OF_DESC, 0U, l2_program_arena)', '\fn: lmx_walk_merge_map') },
    # INDEXED FIELD PATHS (S3 part 2b): root\seg...[k] / [k][j] into an Array field of a declared
    # type through a typed root; `@` before an element addresses it in graph storage; length() on
    # both levels.  The former formal-`main` fixtures now read argv from the letter (mainArgs);
    # `{source}` in Argv is this fixture's own path.
    [pscustomobject]@{ Name = 'unit_arr_path_read.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0');
        Absent = @(); Debt = @() },
    # D-06: a failed receiveMessage or rebinding store is an invariant on the X1 route, not a printed line.
    # length() is size_t and exit_code is int: the root's conversion edge (implements-port slice 13).
    [pscustomobject]@{ Name = 'unit_admit_rebind_read.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('ok'); Entry = 2;
        Absent = @(); Debt = @() },
    # length(m\mainArgs) is the outer array's size_t length (semantics §17: first dimension).
    # No extra argv: the letter holds argv[0] alone, so length is 1. Success is exit 7,
    # not the walker's silent 0. An inverted entry 0 is red.
    [pscustomobject]@{ Name = 'entry_argc_if.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-20: argv "ok" is len 2, bytes o,k, no NUL. Before this slice the kernel stored strlen+1.
    [pscustomobject]@{ Name = 'entry_arg_len.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('ok'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-81, Q31 answer: a method is a sufficient receiver for the c.* door, so c.puts moved
    # into printArg -- `@: void buf` / `buf: c.calloc(1U, n + 1U)` makes the NUL-terminated
    # copy explicitly (zero-init guarantees buf[n] is a real NUL, not a lucky byte), then
    # c.memcpy(buf, @ letter\mainArgs[1][0], n) fills it. Mutant (deterministic, not "drop
    # +1U" -- that reads OOB, not reproducible): copy n-1U bytes instead of n inside printArg
    # -- argv "word" then prints "wor", reddening Says.
    [pscustomobject]@{ Name = 'entry_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('word'); Says = @('word');
        Absent = @(); Debt = @() },
    # D-81, same Q31 answer: c.strcmp moved into argIsOk (same calloc+memcpy copy). The three
    # earlier checks (letter shape, arg count, raw bytes o/k) still refuse first for any argv
    # other than exactly "ok", so this row's own normal run never exercises argIsOk's r!=0
    # branch -- the same deterministic mutant as entry_index (copy n-1U bytes) is the witness
    # that the copy and c.strcmp are load-bearing: "ok" then reddens from Entry 7 to Entry 4.
    # Success is 7, not 0 (fable_pc, REVIEW 4dc3423/ab8b245): a silent 0 is not a witness (D-15).
    [pscustomobject]@{ Name = 'entry_strcmp.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('ok'); Entry = 7;
        Absent = @(); Debt = @() },
    # §7a "L2-библиотека puts": l2_puts is ordinary L2 (a c.putchar byte loop), no c.puts at the
    # call site at all -- unlike D-81's printArg, no NUL-terminated copy is needed either, since
    # putchar takes one byte at a time. Named boundary (not solved): l2_puts is not yet a
    # separately predef'd/shared library -- the generic eternal-runs link step below only links
    # <fixture>.o with the driver and l2_libc.o, so it lives in this one unit for now (see the
    # fixture's own header comment; same class of gap as D-84/l1src/own.h.lm1's dead link).
    [pscustomobject]@{ Name = 'unit_l2_puts_library.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('word'); Says = @('word');
        Absent = @('c.puts'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_charpp_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @(); Debt = @() },
    # plus_one's formal is int; length() is size_t: the root's conversion edge (slice 13).
    [pscustomobject]@{ Name = 'unit_entry_args.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_parse_min.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body'; Args = @('0'); Argv = @('{source}');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_untyped_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs a root of a declared Structure type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_variable_index_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_inner_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an inner Array is a value only inside length()'; Absent = @(); Debt = @() },
    # Q55: translate L2 OOB syntax, but NEVER execute the undefined C access.
    [pscustomobject]@{ Name = 'unit_c99_char_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Args = @('0'); Entry = 7;
        Needle = ''; Absent = @('lmx_char_rebind_known(dest,'); Debt = @('lmx_char_value_known(l2_o') },
    [pscustomobject]@{ Name = 'unit_arr_path_bounds_refused.lm2'; Expect = 'translates'; Exit = 0;
        Needle = ''; Absent = @(); Debt = @('[3U]') },
    [pscustomobject]@{ Name = 'unit_arr_path_three_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    # -179: the take and the null test run.
    [pscustomobject]@{ Name = 'entry_argc.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('one', 'two');
        Absent = @(); Debt = @() },
    # The former main-signature refusals test ordinary method formals now (L2 has no main, S2).
    [pscustomobject]@{ Name = 'entry_argc_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_argc_dup.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'duplicate formal'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_bad_sig.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_two_main.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'duplicate definition'; Absent = @(); Debt = @() },
    # The unit's fields are E's own fields, the same mechanism a method body uses.  FABLE-SONNET-
    # RECEIVE-RENAME-20260924-166 commit 3 (D-48, Q24 = A): a repeated typed declaration of one
    # name is now a new occurrence at unit level too (was refused, S2 rule 4, self-made).  E is
    # still the root of every activation: a callee's dynamic input that E does not bind stops at E
    # and is resolved at the call by the callee's lexical fallback, as it was from `main`.
    [pscustomobject]@{ Name = 'unit_root_field_duplicate.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # bafca4c (the author, 2026-09-28; 7b, by name): inc's x is its hidden input, and the root binds none -- refused
    # at the root's call.  (Was eternal-runs: the assignment made x a field of inc.)
    [pscustomobject]@{ Name = 'unit_asgn_fallback.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_asgn_fallback.lm2:21:1: unbound dynamic input x'; Absent = @(); Debt = @() },
    # FABLE-SONNET-SEND-IN-METHODS-20260925-168 commit 2: sendMessage: X inside a method body --
    # a method called from the root sends exit(exit_code: 7; ...) directly (l2_msend<k>).
    [pscustomobject]@{ Name = 'unit_send_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_ret_tr_bad.lm2:1:1: unresolved name'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_lit_range_decl_int_neg_overflow.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_int_neg.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lit_range_ns_int_neg_min.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_formal_shadows_struct.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_file_bare_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },

    [pscustomobject]@{ Name = 'unit_eternal_branch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('1', 'size', '0', '0', '7');
        Absent = @('lmx_owned_ranges', 'lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained',
                   'DEBT: eternal ranges/bootstrap-admit absent in new kernel',
                   'DEBT: eternal bootstrap-admit / eternal-ranges absent',
                   'DEBT: eternal array bootstrap-admit / eternal-ranges absent',
                   'l2_nsp[0]: lmx_node_new_owned(l2_program_arena)',
                   'not yet in R0''s retention array',
                   'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 1',
                 'l2_nsp[0]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'slot[0]: lmx_arena_take_profiled(l2_program_arena, c.sizeof(c.size_t), c.LMX_KIND_PRIMITIVE, c.LMX_TYPE_SIZE_T, l2_eprofile0)',
                 'if: l2_profile_pool = 0 || lmx_pool_seal(l2_profile_pool) != 0',
                 'l2_entry_unit: graph',
                 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_eternal_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('2', 'size', '0', '0', '7', 'size', '1', '0', '9');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 2',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 'l2_eprofile1: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'l2_entry_unit: graph') },
    # Seventy roots: the capacity is the COUNT.  Sizing by a root's INDEX -- the trap the two
    # tables invite, l2_ns_eternal[k] beside l2_ebr_n -- would pass every smaller fixture's text.
    [pscustomobject]@{ Name = 'unit_eternal_many.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('70', 'size', '0', '0', '1', 'size', '35', '0', '36', 'size', '69', '0', '70');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 70',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[69U]: l2_nsp[69]',
                 'l2_eprofile69: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'l2_entry_unit: graph') },
    # A nested member, a reference to the branch itself, a reference to the OTHER branch, and a
    # mutable Holder beside them: two roots are retained, the nested member and Holder are not.
    [pscustomobject]@{ Name = 'unit_eternal_shape.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('2', 'size', '0', '0', '7', 'size', '0', '4', '13', 'same', '0', '3', '0', 'same', '1', '0', '0', 'size', '1', '1', '17');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 2',
                 'l2_nsp[1]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[1U]: l2_nsp[2]',
                 'l2_entry_unit: graph') },
    # A cross-reference INTO another branch: F\into is E's member `deep`, not a copy of it.
    [pscustomobject]@{ Name = 'unit_eternal_xref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 0;
        Args = @('2', 'slot', '1', '0', '0', '0', 'size', '0', '1', '7', 'size', '1', '1', '23');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 2',
                 'l2_nsp[1]: lmx_node_new_profiled(l2_program_arena, l2_eprofile0)',
                 'l2_program_qualified_roots[1U]: l2_nsp[2]',
                 'l2_entry_unit: graph') },
    # Array records/backing and merge sites use the same exact profiled owner ranges.
    [pscustomobject]@{ Name = 'unit_array_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('1', 'merge_array', '1', '1', '1', '0', 'merge_array', '1', '2', '1', '1', 'merge_same', '1', '0', '0', '0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 1',
                 'l2_profile_array: (cast: (@: VoidArray) lmx_arena_take_profiled',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_array_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('1', 'merge_array', '1', '2', '1', '0', 'merge_array', '1', '3', '1', '1', 'merge_same', '1', '0', '0', '0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 1',
                 'l2_profile_array: (cast: (@: VoidArray) lmx_arena_take_profiled',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_merge_value_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @();
        GraphShapes = @([pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
        ) }) },
    [pscustomobject]@{ Name = 'unit_merge_value_retained.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('1'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @();
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 3 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 13; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 1 }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }) } }
            ) }
        ) },
    [pscustomobject]@{ Name = 'unit_merge_value_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @();
        GraphShapes = @([pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 3 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
        ) }) },
    [pscustomobject]@{ Name = 'unit_merge_value_method_native.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_schema.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_host.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # An existing head retains its call/assignment role; a nested merge frame
    # does not redeclare it. The present receiver lowering refuses this call.
    [pscustomobject]@{ Name = 'unit_merge_known_head_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':3:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    # A reached Structure merge result does not satisfy an int return place;
    # unit_merge_value_schema is the compatible Structure-return control.
    [pscustomobject]@{ Name = 'unit_merge_value_int_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':4:9: return value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_site.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('3');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 3',
                 'l2_program_qualified_roots[2U]: l2_nsp[2]',
                 '\fn: lmx_walk_merge_map',
                 'l2_entry_unit: graph') },
    # FABLE-OPUS-MERGE-PARTS-20260926-193 T1 (the author's merge rule, plan §4): a later operand's
    # field of a model name is written INTO the model's slot -- one LmxMergePair (model slot, operand,
    # field) -- so merge makes no repeated names: R is {x, y}, `R\x` = `R\[0]x` = 7 for reads and
    # writes, and `R\[1]x` does not exist. This row executes the merge in an ordinary method.
    # Runtime source assertions prove values/independence; explicit driver facts observe width
    # and physical copy identity. The translator must not emit merge-result selftests.
    [pscustomobject]@{ Name = 'unit_merge_last_occurrence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '2', 'merge_value', '1', '0', 'size', '7', 'merge_fresh', '1', '0', '1', '0'); Entry = 7;
        Absent = @('merge result check', 'lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_mpp[0U]\model_slot: 0U', 'l2_mpp[0U]\operand: 1U', 'l2_mpp[0U]\field: 0U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 2U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    # -193 T1: later operands merge INTO the model in operand order -- two pairs on one model slot, the
    # last one C's -- and a new name is added.  R = {3, 2, 9}.  Success is 4.
    [pscustomobject]@{ Name = 'unit_merge_three_operands.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '3', 'merge_value', '1', '0', 'size', '3', 'merge_fresh', '1', '0', '2', '0'); Entry = 4;
        Absent = @('merge result check');
        Debt = @('l2_mpp[0U]\operand: 1U', 'l2_mpp[1U]\model_slot: 0U', 'l2_mpp[1U]\operand: 2U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 3U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 2U, @ l2_mresult\)') },
    # Merge is attached to its ordinary own store, not a reserved unit result slot.
    # The callback header contains pair count, actual parent and two producer tokens;
    # 3·P inline mapping cells follow operands/body. The same source also has native merge
    # code; WalkRoot checks both dispatch modes. Merge is a publication boundary (PRIM_PUB).
    # unit_root_merge_three_operands: two pairs on Model's x (C's last), B's z appended, a write
    # `R\x: 6U` through the result, and S merging the result R (read in the turn) with a body field.
    [pscustomobject]@{ Name = 'unit_root_merge_three_operands.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 0; WalkRoot = $true;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 5 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 17; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 2 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 6 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) }
        ); Absent = @(); Debt = @() },
    # unit_root_merge_body: the body as the map's operand n -- R's x into Model's x, S's z into B's
    # appended z, S's w new.  D1: each merge's pair is inline, its count in slot 3 -- one pair: 3 wider.
    [pscustomobject]@{ Name = 'unit_root_merge_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 0; WalkRoot = $true;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 12; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 5 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 13; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) }
        ); Absent = @(); Debt = @() },
    # D-75: a call through a path at the walked root is typed by its method; the int result stored into
    # a size_t own takes the root's conversion edge (slice 13 -- before it, a located refusal of the mix;
    # before D-75, walk error INVALID at run time), and its running twin.
    [pscustomobject]@{ Name = 'unit_root_path_call_type.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_path_call_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_live_source.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0', 'merge_width', '1', '2', 'merge_value', '1', '0', 'size', '9', 'merge_fresh', '1', '0', '0', '0', 'merge_fresh', '1', '1', '0', '1');
        Absent = @('merge result check'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_occurrence_range_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'merge occurrence index out of range'; Absent = @(); Debt = @() },
    # -193 T2 (on -194 K1): a later field repeating a name an earlier operand ADDED goes INTO that
    # appended slot, and the body merges INTO the result as the last operand (the kernel's `operand =
    # count`) -- both were located refusals in T1.  Never a second slot of the same name: `R\[0]z` and
    # `R\[0]x` read the one slot.  Mutants: the body appended instead of joined (body_repeat exits
    # 83); only model slots matchable (added_repeat exits 83).  A later field whose type is not the
    # placed field's stays refused.  4 and 19.
    [pscustomobject]@{ Name = 'unit_merge_added_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '2', 'merge_value', '1', '1', 'size', '3', 'merge_fresh', '1', '1', '2', '0'); Entry = 4;
        Absent = @('merge result check');
        Debt = @('l2_mpp[0U]\model_slot: 1U', 'l2_mpp[0U]\operand: 2U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 3U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    [pscustomobject]@{ Name = 'unit_merge_body_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '1', 'merge_value', '1', '0', 'size', '5', 'merge_width', '2', '3', 'merge_value', '2', '1', 'size', '9'); Entry = 19;
        Absent = @('merge result check');
        Debt = @(); NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 1U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)', 'l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 2U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    [pscustomobject]@{ Name = 'unit_merge_field_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a merge operand field has another type than the model field of its name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_field_entry_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a merge operand field has another type than the model field of its name'; Absent = @(); Debt = @() },
    # -193 T1 on qualified operands: FrozenB's value goes INTO FrozenA's slot -- one slot, FrozenB's
    # retained cell by address (a driver merge_same fact), read back as 2.
    [pscustomobject]@{ Name = 'unit_merge_eternal_pair.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('2', 'size', '0', '0', '1', 'size', '1', '0', '2', 'merge_width', '1', '1', 'merge_same', '1', '0', '1', '0'); Entry = 2;
        Absent = @('merge result check');
        Debt = @(); NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 2U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    # Callable copies have distinct occurrence descriptors but share native code; their lexical
    # parent stays the file Structure. q22: R\M() = 3; q20: all three calls return 3.
    # merged_callable additionally observes independent mutable own storage.
    [pscustomobject]@{ Name = 'unit_q22_merge_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_native', '1', '0', '0', '0'); Entry = 3;
        Absent = @('merge result check'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_q20_merge_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_native', '1', '0', '0', '0', 'merge_native', '2', '1', '1', '0'); Entry = 5;
        Absent = @('merge result check'); Debt = @() },
    # T5 slice 1: add5 is merge(y: 5; add). y is a data field, x stays ARG 0, native is 0.
    # add5(1) = 6. Mutant: read y as ARG — INVALID, not 6.
    [pscustomobject]@{ Name = 'unit_pap_add5.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @('l2_m1_tr'); Debt = @('lmx_int_store_known(l2_entry_slot[0], 5)', 'c.LMX_WALK_OP_AT, 3U)', 'c.LMX_WALK_OP_CALL, 6U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'ADD'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }
            ) },
            [pscustomobject]@{ Op = 'CALL'; Width = 6; Count = 1; CallLink = $true; CalleeSlot = 3; InputKinds = @('int'); ResultKind = 'int'; Edges = @(
                [pscustomobject]@{ Slot = 5; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }
            ) }
        ) },
    # T6: return: addN builds {n: value} and one merge. add5(1)=6, add100(1)=101, add5(1)=6.
    # Mutant: one field n for both results — the second call is not 101. Entry 7, 0 is refusal.
    [pscustomobject]@{ Name = 'unit_make_adder.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh('); Debt = @('lmx_call_prim(', 'lmx_int_store_known(', 'c.LMX_WALK_OP_AT, 3U)') },
    # T6b: the node is built from the host's activation at the return -- n changed before it, k a
    # field the host declares -- and carries only what addN names, not u.  The node is addN's occurrence copied (3:
    # args, return, one frame) under its copied lexical context C -- the host's layout (6) and a body field per formal
    # (2): k at its slot 2, n in formal 0's field 6, u's field 7 left empty (book, "Returned nested methods"; Codex,
    # 2026-09-28). add7(1)=7, add100(1)=100, add7(1)=7; the base translator refused k.
    # Mutants: the host's statements dropped (D-92) -- exit 0; the formal as the machine argument
    # -- add7(1)=6, exit 0. Every int formal carried is the 6U pin, not a behavior.
    [pscustomobject]@{ Name = 'unit_make_adder_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_arena_ref_store(l2_madc, 7U,', 'lmx_fresh('); Debt = @('lmx_arena_ref_store(l2_madc, 2U, l2_mad_cell)', 'lmx_int_store_known(l2_mad_cell, l2_p0_0) != 0 || lmx_arena_ref_store(l2_madc, 6U, l2_mad_cell)', 'lmx_arena_refs_open_owned(l2_program_arena, l2_mad, 3U)', 'lmx_arena_refs_open_owned(l2_program_arena, l2_madc, 8U)', 'lmx_int_store_known(l2_mad_cell, lmx_int_value_known(') },
    # T6b: a model that names nothing of the activation: no captured slot (3 = args, return, one
    # frame); the base translator carried the unused z. inc7(1)=7.
    [pscustomobject]@{ Name = 'unit_make_adder_no_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh('); Debt = @('lmx_arena_refs_open_owned(l2_program_arena, l2_mad, 3U)') },
    # T6b: a capture keeps its type -- the size_t formal n is a size_t cell of the node; addBig
    # (2^32) and addSmall (2^32 - 1) give 101 and 2. The base translator refused. Mutant: an int
    # cell -- 2^32 is 0, exit 0.
    [pscustomobject]@{ Name = 'unit_make_adder_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh('); Debt = @('lmx_size_new_owned(l2_program_arena)', 'lmx_size_store_known(l2_mad_cell, ') },
    # A char capture has an independent typed cell holding the target C99 char value.
    # Formal and own-field captures retain 101, 201, 1, 251, 67 independently.
    [pscustomobject]@{ Name = 'unit_make_adder_char.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh('); Debt = @('lmx_char_new_owned(l2_program_arena)', 'lmx_char_store_known(l2_mad_cell, ') },
    # Item 738 slice 1 (steps/capture-738.md; Q38/Q42/Q44): a Structure captured by a callable merge is a
    # copy of the fields its model reads, and the model reads them by the type's slots through the copy's
    # table in the arena's `implements` table (D-105).  _own: the host's own `Model: loc` -- 42 and 9 from
    # two nodes; _formal: the host's formal -- the model's writes seen by the next call of the same node
    # (41, 42), not by the root's `left` (40), and the root's write after the node is made not seen by it
    # (43).  The base translator refused both hosts, "a callable merge needs a walkable body".
    [pscustomobject]@{ Name = 'unit_capture_struct_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Item 738 slice 2 (steps/capture-738.md §6): the capture's refusals, located -- the needle carries the
    # line and column.  A model tried for the walk silently now gives its own first reason, where it stands,
    # in its host's refusal (l2_mad_unwalkable); before, the host's header alone.  Update-position paths
    # resolve their root (l2_scan_path_root); a passed-on field is the capture's to check (l2_actual_path);
    # a field that is not a number or a char is refused at translation, not by the host's abort at run.
    [pscustomobject]@{ Name = 'unit_capture_struct_past_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':22:17: a path through a captured Structure goes past its field'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_past_write_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':17:9: a path through a captured Structure goes past its field'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_nofield_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':19:21: a path through a captured Structure names no field of its type'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_nofield_write_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':15:9: a path through a captured Structure names no field of its type'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_field_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':21:27: a captured Structure''s Structure field is not copied yet (item 738: value fields)'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_field_array_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':13:21: a captured Structure''s field that is not a number or a char is not copied yet (item 738: value fields)'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_call_head_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':13:17: a path through a captured Structure names no field of its type'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_whole_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':21:5: a callable merge needs a walkable body: it can throw (a throwing method stays native)'; Args = @('0'); Absent = @(); Debt = @() },
    # REVIEW 9256c3b: one cause, one line -- a model's refusal said by the scan is not followed by
    # "unsupported body" (the at-most-one-line check above holds every refusal row to it).
    # D-108: an actual admitted to a Structure-typed formal is checked as any actual is (l2_check_call) --
    # a call inside it records its edge, so the throw closure makes the caller throwing (_throwing: 5 through
    # mk's converted field; before, gcc: 'l2_msg' / 'l2_out_throw' undeclared), and meets the static rule of
    # §14 (_declared_refused; before, only the internal backstop at 1:1).
    [pscustomobject]@{ Name = 'unit_d108_nested_throwing.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d108_nested_declared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':15:12: unhandled throw: Oops'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_model_decl_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    # Item 738 slice 2: _write_only (REVIEW 2032ca0, M46/P46) -- a field the model only writes is in the
    # copy (42, 43); _write_root -- a model that uses its capture only in update position records it (2, 3;
    # before, "unknown field path root"); _call_arg -- a value field as a call argument (82).
    [pscustomobject]@{ Name = 'unit_capture_struct_write_only.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_write_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_call_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Held numeric calls use declared-width input and caller-owned result storage.
    # The all-types witness retains two CHAR results and values wider than int;
    # both native and walked root use the same declared primitive contract.
    [pscustomobject]@{ Name = 'unit_t6_root_held_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t6_root_held_result_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The original high-bit machine-cast fixture remains native-only.
    [pscustomobject]@{ Name = 'unit_t6_root_held_results.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_portable_reference_held_results.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8;
        Absent = @(); Debt = @('l2_mad_call', 'LMX_WALK_OP_PRIM_PUB') },
    # A3 with item 739: the host calls its size_t model before the return -- over the model's occurrence, n its hidden
    # input: lmx_call_prim receives declared-width value storage. Under the knob the
    # walked host uses the same contract. The result must retain 2^32 + 3.
    [pscustomobject]@{ Name = 'unit_make_adder_model_call_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_make_adder_model_call_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_mad_call') },
    # D-103: a callable-merge host that can throw returns its node through l2_out_result, its status
    # as its return (it returned the node as the status: an unknown walk status, exit 3).  Mutant:
    # the node as the status again -- unknown status, exit 3.  Under the knob the same host stays
    # native and l2trans notes it (REVIEW c953b22), located; the row requires the note.  Mutant: no
    # note -- the Notes line is missing.
    [pscustomobject]@{ Name = 'unit_make_adder_throwing_host.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_make_adder_native_note.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Notes = @('the callable merge host makeAdder stays native under --walk-methods: it can throw'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t6_root_held_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a held callable whose header is not one number to a number'; Absent = @(); Debt = @() },
    # T6b (D-92): the build is the host's one exit. The base translator accepted these three and
    # dropped the statements with the host's body; nested_call it refused with the old phrase.
    # (D-93/D-94, 2026-09-27: after_return and nested_call now run -- rows below; the note that
    # follows holds for the two refusal rows left, model_call and early_return.)
    # §6 (REVIEW d456aff-2, fable_pc's own correction): these four give the SAME phrase with or
    # without --walk-methods on the CURRENT translator -- not because a check pass preempts the
    # count/walk pass, but because a6de5a9's own blanket "outside the walkable subset" exclusion
    # (every code-16 host, no exceptions) is gone: before §6 it aborted the count pass first for
    # ALL of these, under the knob, before native emission's own l2_mad_host_body validation ever
    # ran; §6's l2_mad_on/l2_mad_return_confirmed bypass lets a malformed host past that coarse
    # gate, so the SAME finer l2_mad_host_body check that always ran without the knob now also
    # runs, and refuses, with the knob. Measured directly (both modes, old and current translator)
    # before adding WalkMethods here; previously no row pinned the knob behaviour at all.
    # D-94: a statement after the host's return is dead, as after any method's return -- emitted after
    # the build, never reached (it was refused).  Mutant: the old refusal -- l2trans refuses, RED.
    [pscustomobject]@{ Name = 'unit_make_adder_after_return_dead.lm2'; Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    # REVIEW e8b8a8d (fable_pc's probes): a tail after the host's return is dead in the walk too --
    # l2_mad_return_point stops l2_rw_stmts there (the build is the host's trailer, so a tail built
    # in the body ran before it; a call or a return broke the run).  A call, a second return, a
    # declaration with an assignment; the call once more natively.  Mutant: the walk builds the tail.
    [pscustomobject]@{ Name = 'unit_make_adder_after_return_call.lm2'; Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_make_adder_after_return_ret.lm2'; Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_make_adder_after_return_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_make_adder_after_return_call_native.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    # A3 (Codex, 2026-09-28): the host calls its capturing model before the return -- an ordinary (M, M) call over the
    # model's occurrence, its capture n the hidden input the host supplies (the host's current value): natively
    # through lmx_call_prim (the model is walked), under the knob a CALL.  No node is built for the call.  q 6, r 16,
    # n 22; the returned node carries n 22: add(1) = 23; the base translator refused.
    [pscustomobject]@{ Name = 'unit_make_adder_model_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_make_adder_model_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_mad_construct_') },
    # A3: a capturing nested method that is not the model is called like the model -- over its own occurrence, its two
    # captures (n and m) the hidden inputs the host supplies; the model captures q only.  add(1) = 54; the base
    # translator refused.
    [pscustomobject]@{ Name = 'unit_make_adder_helper_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_make_adder_helper_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # REVIEW ba92461, A3: a helper of two formals, called by its host over its own occurrence with its two actuals and
    # its capture n -- three inputs (lmx_call_prim, the pin).  h2(1, 2) = 8 = q, add(1) = 9.  Under the knob the host
    # is walked now (a CALL carries any number of inputs; it stayed native and l2trans noted it): no native word for
    # it (the Absent pin).
    [pscustomobject]@{ Name = 'unit_make_adder_helper_arity2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_call_prim(l2_program_arena, l2_c0, l2_c0, l2_cfr1, 3U') },
    [pscustomobject]@{ Name = 'unit_walk_make_adder_helper_arity2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # D-93: a nested method that captures nothing of its host has its own native body; the host calls
    # it before its return (it was refused).  A capturing one is called over its own occurrence, walked,
    # its captures its hidden inputs (A3: _model_call and _helper_call above).  Mutant:
    # every nested method the stub -- the native twin gives k = 0, RED by run (under the knob the
    # host and twice are walked, the stub never runs).
    [pscustomobject]@{ Name = 'unit_make_adder_nested_plain_call.lm2'; Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_make_adder_nested_plain_call_native.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A3 (Codex, 2026-09-28): a capture is a hidden input of the nested method.  The host's direct call passes its
    # current values -- a Structure by reference, admitted as the capture's type itself (the pins), so the nested
    # method's write through it is the host's, the root's left -- and the node its return builds carries its own
    # copies, which later writes of left do not reach and the node's own writes do not leave.  41 and 1141 by the
    # direct calls, left\other 7; 1141 twice by the node, left\other 7000.  Success is 7, else 64 plus a bit per
    # failed reading.
    [pscustomobject]@{ Name = 'unit_a3_capture_direct_vs_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @(); NativePatterns = @('(?s)lmx_implements_register_map\(l2_program_arena, \(cast: \(@: Lmx\) l2_p0_0\), (?<model>lmx_arena_ref_struct\(node, \d+U\)), 0, 0U, 0\).*?lmx_implements_register_map\(l2_program_arena, \(cast: \(@: Lmx\) l2_p0_0\), \k<model>, 0, 0U, 0\)') },
    [pscustomobject]@{ Name = 'unit_walk_a3_capture_direct_vs_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'CALL'; Width = 8; Count = 2; CallLink = $true; ResultKind = 'int'; Edges = @([pscustomobject]@{ Slot = 6; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4 } }) } }) },
            [pscustomobject]@{ Op = 'CALL'; Width = 7; Count = 1; CallLink = $true; ResultKind = 'pointer'; Edges = @([pscustomobject]@{ Slot = 5; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3 } }) } }) }
        ); Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # Reading 1 (book, "Dynamic sources and the lexical fallback"; Codex, 2026-09-28): a free name of a returned
    # method takes the caller's own binding first, the node's copied context only as the fallback -- the root's n
    # 100: 101; go's formal n 7: 8; plain, with none: the copy, 6.  A held call passes the caller's binding per hidden
    # input, or nothing; the model's ARG falls back to the graph through `node`.
    [pscustomobject]@{ Name = 'unit_a3_caller_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_a3_caller_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Gate 3 (Codex, 2026-09-28): `node\name` in a returned method reads its copied lexical context (the node's
    # parent) -- the host's own field as it was at the return, the host's formal as the body field the merge appends,
    # a field of a Structure formal from its copy -- while a bare name takes the caller's binding: 42121 and 7.
    [pscustomobject]@{ Name = 'unit_a3_node_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_a3_node_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Gate 3, a direct call: a nested method's `node` is its host's occurrence (book §3), `node\k` the declaration
    # cell of the host's own field, never its working value -- 40, then 42 once the host's write is published before
    # the next call; the returned node, its copy -- 4104243.
    [pscustomobject]@{ Name = 'unit_a3_node_direct.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_a3_node_direct.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Gate 3, absence (option (2)): `node\n` of the host's formal in a direct call reads no value -- the formal is no
    # body field of the host's occurrence, and the args part is the signature, never read as a value: X1.
    [pscustomobject]@{ Name = 'unit_a3_node_direct_absent.lm2'; Expect = 'walk-x1'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_a3_node_direct_absent.lm2'; Expect = 'walk-x1'; Exit = 0; Needle = ''; Args = @('0'); WalkMethods = $true;
        Absent = @(); Debt = @() },
    # D-94: `return: 0` from a method whose result is a callable is the result's type error, said so
    # (l2_mad_returns_number), not a limit of the callable merge.  Mutant: no number check -- the old
    # boundary phrase, RED on the needle.
    [pscustomobject]@{ Name = 'unit_make_adder_early_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'a callable result returns a number'; Absent = @(); Debt = @() },
    # T7: return merge and a merge actual of a callable formal. wrap(5)(1)=6,
    # wrap(100)(1)=101, the first again 6, passed()=5. Entry 7. take: bin stays native.
    [pscustomobject]@{ Name = 'unit_t7_convert.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_call_prim(', 'lmx_int_store_known(', 'c.LMX_WALK_OP_AT, 3U)') },
    # §6 (steps/interpreters-callable-parity-t6t7.md): a T6/T6b callable-merge host (l2_mad_on)
    # now walks under the knob when l2_mad_return_confirmed holds -- the body's own statements
    # walk normally, the return builds a PRIM step (l2_rw_mad_ret) whose native record is a
    # standalone per-host constructor (l2_emit_mad_construct_one), not a numeric [ret, V]. Same
    # minimal shape unit_walk_methods_callable_result_refused.lm2 used to pin the refusal text
    # with, re-staged as unit_walk_make_adder.lm2 now that it runs instead: add5(1)=6. Mutant
    # (build/*, not committed): the constructor's own per-capture store call dropped -- add5(1)
    # is not 6 (a different Entry, or a crash if the capture cell is left null).
    [pscustomobject]@{ Name = 'unit_walk_make_adder.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6; WalkMethods = $true;
        Absent = @(); Debt = @('lmx_arena_ref_struct(l2_entry_unit,', 'l2_mad_construct_') },
    # T6b captures under the knob (unit_make_adder_activation.lm2's exact shape): host statements
    # before the return (n: n+1, int: k(n*2)) walk via l2_rw_stmts unchanged; only the return's own
    # emission differs from the native path. add7(1)=7, add100(1)=100, add7(1)=7.
    [pscustomobject]@{ Name = 'unit_walk_make_adder_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_mad_construct_') },
    # T6b, zero captures under the knob (unit_make_adder_no_capture.lm2's exact shape): the
    # constructor's own per-capture loop runs zero times, width 3 (args, return, one frame).
    [pscustomobject]@{ Name = 'unit_walk_make_adder_no_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_mad_construct_') },
    # T6b, a size_t capture under the knob (unit_make_adder_size_t.lm2's exact shape): the
    # constructor dispatches lmx_size_value_known/lmx_size_store_known by l2_mcap_ty, not always
    # the int pair -- addBig(2^32)=101, addSmall(2^32-1)=2 (an int cell would truncate 2^32 to 0).
    [pscustomobject]@{ Name = 'unit_walk_make_adder_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('lmx_size_value_known(refs[', 'lmx_size_store_known(') },
    # Item 738, a char capture under the knob (unit_make_adder_char.lm2's exact shape): the
    # constructor copies lmx_char_value_known(refs[k]) into a fresh owned cell.
    # Mutant: the constructor's char capture not written.
    [pscustomobject]@{ Name = 'unit_walk_make_adder_char.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_mad_construct_', 'lmx_char_new_owned((cast: (@: LmxArena) owner))', 'lmx_char_store_known(l2_mad_cell, ') },
    # next_core_tasks.md §7 "Интерпретаторы": a callable formal (T7's take (bin: op) shape) is
    # still outside l2_rw_may's walkable subset -- l2_pap_on/T7 is a separate mechanism §6 does not
    # touch (steps/interpreters-callable-parity-t6t7.md's own scope note). Same shape as
    # unit_t7_convert.lm2's take, minimised and re-staged under its own Name so this row can run
    # WITH the knob while that one keeps testing the native (non-knob) path. Mutant:
    # l2_rw_callable_excluded hardcoded to `return: 0` -- this row goes back to translating
    # silently under the knob (l2trans ACCEPTS a fixture that must be refused), RED.
    [pscustomobject]@{ Name = 'unit_walk_methods_callable_formal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'a callable result or a callable formal is outside the walkable subset'; Absent = @(); Debt = @() },
    # implements-port slice 1 (steps/implements-port-plan.md, A1): a callable formal called with
    # arguments -- int, int+size_t (order), char, unsigned+ulong -- each passed by the address of a
    # local of its formal's type, refs and nargs to lmx_call_prim.  Mutants (copies under build/):
    # nargs 0U -- the trampoline's signature invariant aborts; every refs index 0 -- refs[1] is never
    # set and the values arrive in the wrong slots; both RED by run (the pins are text neither
    # mutant touches).  A formal of another type is
    # refused, located (mutant: no type check -- a `(null)` type reaches L1, l2trans accepts, RED).
    # The walker refuses the same shape, located (checkpoint 2-6 row 234; REVIEW 9327b65).
    [pscustomobject]@{ Name = 'unit_cf_call_args.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 2; Arity = 2; Count = 1; InputKinds = @('descriptor', 'int'); ResultKind = 'int'; }, [pscustomobject]@{ Method = 5; Arity = 3; Count = 1; InputKinds = @('descriptor', 'int', 'size'); ResultKind = 'int'; }, [pscustomobject]@{ Method = 8; Arity = 1; Count = 1; InputKinds = @('descriptor'); ResultKind = 'int'; }, [pscustomobject]@{ Method = 11; Arity = 3; Count = 1; InputKinds = @('descriptor', 'unsigned', 'ulong'); ResultKind = 'int'; });
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_cf_call_pointer_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_methods_callable_formal_args_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'a callable result or a callable formal is outside the walkable subset'; Absent = @(); Debt = @() },
    # D-101: a method with a named-Structure formal used as a value (a callable actual) has its public
    # prototype written; its formal type is recovered from dt_of_own(1000+foreign) as l2_emit_formal
    # does.  Mutant: the raw type -- l2trans fails with no located diagnostic.  D-102: a field path
    # through a formal in a unit with no own field -- l2_xp is declared with the path temps.  Mutant:
    # the old condition -- gcc refuses the C.
    [pscustomobject]@{ Name = 'unit_d101_struct_formal_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('fn: peek (@: Lmx b) int') },
    # D-101, second site (REVIEW 7b9c60c remark): the SAME recovery for a named-Structure RESULT,
    # through l2_sig_ret (mk's public prototype: `fn: mk (int: v) @: Lmx`). Mutant: l2_sig_ret's own
    # recovery reverted to a raw l2_m_ret[mi] read -- l2trans fails again, no located diagnostic.
    [pscustomobject]@{ Name = 'unit_d101_struct_result_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('fn: mk (int: v) @: Lmx') },
    [pscustomobject]@{ Name = 'unit_d102_formal_path_no_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_two.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable merge needs one model'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_none.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable merge needs one model'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_header.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable merge header does not match the model'; Absent = @(); Debt = @() },
    # Historical receiving-context DEBT, not a semantic integer-admission
    # negative: the old zero-operand message misclassified the outer return.
    [pscustomobject]@{ Name = 'unit_t7_from_int.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ':5:13: merge expression is not lowered in this receiving context'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merged_callable.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_native', '1', '0', '0', '0', 'merge_child', '1', '0', '0', '0', '2'); Entry = 5;
        Absent = @('merge result check'); Debt = @() },
    # -193 T1b (Q6 = a): no name is decided by its spelling.  l2_upper_name (all-caps = a C constant
    # for gcc) is gone: a `define:` of the unit or its predef chain is a DECLARED name
    # (l2_define_name, asked after every L2 name), anything else is a located refusal, and a name only
    # C knows is `c.NAME`.  An all-caps unit field read in a method is that field (6; it was a raw `N`
    # and gcc «'N' undeclared»); an undeclared all-caps name is refused, located (it reached gcc).
    # Mutant: l2_define_name answering 0 refuses unit_define_actual.
    [pscustomobject]@{ Name = 'unit_upper_unit_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_upper_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved dynamic=NOPE'; Absent = @(); Debt = @() },
    # D-61: a bound merge result is a root of the read-position field path resolver
    # (l2_field_path_check), so its path is a value in any expression -- a condition, arithmetic, a
    # loop condition -- read through its slot map like `v: R\x`.  It was «unresolved name» (and, for
    # an all-caps R before T1b, a raw C name gcc refused).  Mutant: the gate without merge results
    # refuses both rows.  4 and 7.
    [pscustomobject]@{ Name = 'unit_merge_path_condition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 4;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; }); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_path_expr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-68: a `define:` constant (the predef's and the unit's) passed to a C function is passed as
    # itself (l2_ccall_box_int asks l2_define_name) -- it used to be staged into an `int` temporary,
    # which cut a char* define to 32 bits: the b5 mixa crash this fixture was written for.  It links
    # against a prototype only, so it stops after l1trans; unit_define_ccall RUNS the same shape
    # (strlen of a predef and a unit define: 11; without the fix the program faults).  Mutant:
    # l2_ccall_box_int without the define test brings the staging back and turns both rows red.
    [pscustomobject]@{ Name = 'unit_define_actual.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('l2_t0: PROBE_DEFINE_LABEL', 'l2_t1: PROBE_DEFINE_FG', 'l2_t0: PROBE_UNIT_LABEL');
        Debt = @('probe_define_take(l2_p0_0, 0U, PROBE_DEFINE_LABEL, PROBE_DEFINE_FG) != PROBE_DEFINE_OK', 'return: probe_define_take(l2_p1_0, 1U, PROBE_UNIT_LABEL, 7U)') },
    [pscustomobject]@{ Name = 'unit_define_ccall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 11;
        Absent = @('l2_t0: PROBE_WORD', 'l2_t1: UNIT_WORD'); Debt = @('strlen(PROBE_WORD)', 'strlen(UNIT_WORD)') },
    # Declared-throw adapters keep ordinary inputs, exact result storage and the
    # throw payload separate from the returned status. No unused Message parameter
    # accompanies the selected occurrence. The signatures also reject the historic
    # duplicate-node formal; common dispatch observers prove caller transport.
    #
    # WHAT THE RUN PROVES.  The generated C compiles unchanged, links against the kernel closure,
    # takes its turn through merge-in-method and closes its root once, and the driver keeps the
    # entry's own int (the root-open tap), so a `return: 81` fails the row.  The failure exit is
    # pinned as S1.1 made it (-133): merge has no payload (X2), so a failing merge leaves
    # `l2_out_throw[0]: 0` -- not the old `node` stub -- and returns its status d + g. The
    # merge-result properties are tested by driver observations, not generated assertions. A completed turn
    # leaves the Message running (`Stopped` 0).  Two of the three declare no eternal branch; the
    # driver is given 0 and checks that the array exists and is empty.
    [pscustomobject]@{ Name = 'unit_merge_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Stopped = 0;
        Args = @('1', 'size', '0', '0', '7', 'merge_width', '1', '1', 'merge_same', '1', '0', '0', '0', 'merge_width', '2', '1', 'merge_same', '2', '0', '0', '0');
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; }, [pscustomobject]@{ Method = 2; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; }, [pscustomobject]@{ Method = 3; Arity = 0; Count = 1; Void = $true; InputKinds = @(); ResultKind = ''; });
        NativeCalls = @([pscustomobject]@{Method=3; Throwing=$true; ResultType='void'; Propagation='forward'; Args=@()}, [pscustomobject]@{Method=0; Throwing=$true; ResultType='int:'; ResultUse='(?m)^\s*l2_out_result\[0\]: {result}\s*$'; Propagation='forward'; Args=@()});
        Absent = @('merge result check', 'Lmx node; @: Lmx node', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)', 'l2_out_throw[0]: node', 'return: 71');
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx self; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m1 (@: Lmx node; @: Lmx self) int',
                 'fn: l2_m2 (@: Lmx node; @: Lmx self; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m3 (@: Lmx node; @: Lmx self; @@: Lmx l2_out_throw) int',
                 'l2_out_throw[0]: 0',
                 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_throwing_callable.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @(); Debt = @() },
    # Every recursive result is checked against the actual `next`; temporary
    # numbering is not the source identity oracle.
    [pscustomobject]@{ Name = 'unit_recursion.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        NativeCalls = @([pscustomobject]@{Caller=2; Method=2; Throwing=$true; ResultType='size_t:'; ResultUse='(?m)^\s*l2_q\d+: \({result}\)\s*$'; Propagation='forward'; Args=@([pscustomobject]@{Type='size_t:'; Value='^l2_q\d+$'})});
        Absent = @('Lmx node; @: Lmx node', 'l2_p2_0; @: Lmx node', 'l2_out_throw[0]: node', 'return: 71');
        Debt = @('fn: l2_m2 (@: Lmx node; @: Lmx self; size_t: l2_p2_0; @: size_t l2_out_result; @@: Lmx l2_out_throw) int',
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
    [pscustomobject]@{ Name = 'unit_s1_merge_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('l2_out_throw[0]: node'); Debt = @('l2_out_throw[0]: 0', 'return: l2_ts') },
    # -178 commit 2: `P: q` is the walker's merge primitive now, and the row translates -- but it is not
    # run: the primitive's failure is LMX_WALK_PRIMITIVE (X1), not the implicit throw `merge` (E's
    # 0 + 1), and the driver's mergefail tap does not reach the kernel's own merge.  D-55: it runs
    # when a kernel primitive that fails an admission reports it as THROWN + k in the caller's
    # numbering (Grok -177 commit 5; the typed receive's `implements` is the same mechanism).
    [pscustomobject]@{ Name = 'unit_s1_merge_uncaught_entry.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        Absent = @('l2_out_throw[0]: node'); Debt = @('\fn: lmx_walk_merge_model') },
    # D-07: qualified-operand merge emits lmx_merge_profiles_owned; MergeFail 1 fails it via the
    # profiles tap (shared mergefail counter). Mutant without -Dlmx_merge_profiles_owned cannot
    # fail the merge -- the program completes with 5 and the row goes RED.
    [pscustomobject]@{ Name = 'unit_s1_merge_profiles_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('2'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('l2_out_throw[0]: node');
        Debt = @('l2_out_throw[0]: 0', 'return: l2_ts');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 2U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    [pscustomobject]@{ Name = 'unit_s1_implements_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        GraphCalls = @([pscustomobject]@{ Method = 1; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('l2_out_throw[0]: node'); Debt = @('l2_out_throw[0]: 0', 'return: l2_ts') },
    # A `return:` trailer of a method on the throw ABI returns its value through the normal output
    # with status 0, as a `return:` in the body does: the row completes with the value.
    [pscustomobject]@{ Name = 'unit_s1_trailer_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; Stopped = 0;
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
    [pscustomobject]@{ Name = 'unit_s1_declared_links.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Stopped = 0;
        Absent = @('l2_out_throw[0]: node');
        Debt = @("        l2_out_throw[0]: l2_tp0`n        return: 1",
                 "        l2_out_throw[0]: 0`n        return: 2",
                 "        l2_out_throw[0]: 0`n        return: 3",
                 "        if: l2_ts1 = 1`n            return: 2`n        if: l2_ts1 = 2`n            return: 1`n        return: l2_ts1") },
    [pscustomobject]@{ Name = 'unit_s1_declared_payload.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Stopped = 0;
        Absent = @();
        Debt = @('lmx_arena_ref_store(l2_tp1, 0U, (cast: (@: void) l2_p0_0))', 'lmx_size_store_known(l2_tc1, 9U)') },
    # The intern carries the ordered names: a and c share a signature, d and e differ by order only.
    # -189 c4: no sig word carries it into the graph any more (the signature is the args/return
    # parts); the throws lists are the translator's check (l2_check_throws_handled).
    [pscustomobject]@{ Name = 'unit_s1_throws_intern.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @('LMX_WALK_RESULT_SIG_MARK'); Debt = @() },
    # `return: f` of a callable on the throw channel is called on that channel (it was called with
    # node and self alone, which gcc refused), and a throw passes through it like through any call.
    [pscustomobject]@{ Name = 'unit_s1_return_callable_throw_abi.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; Stopped = 0;
        NativeCalls = @([pscustomobject]@{Caller=1; Method=0; Throwing=$true; ResultType='int:'; ResultUse='(?m)^\s*l2_out_result\[0\]: {result}\s*$'; Propagation='forward'; Args=@()});
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_return_callable_throw_abi_fails.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; MergeFail = 1; Stopped = 1; Thrown = 1;
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
    [pscustomobject]@{ Name = 'unit_s1_catch_declared_vs_merge.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 27; MergeFail = 1; Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_declared_vs_merge_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 8; Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_tc.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Stopped = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_t2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 103;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_sibling.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_rethrow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1011;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_nested_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 122;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s1_catch_merge_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 50; MergeFail = 1;
        Absent = @(); Debt = @() },
    # Q52 (rewritten by name, 7b): the published field is m's own, declared in its body, read at its place of
    # declaration m\x after the catch -- a bare write of the unit's x from m would be m's hidden input's only.
    [pscustomobject]@{ Name = 'unit_s1_catch_publish.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Return ABI, publication, real throws and empty/elided handler statement ranges.
    [pscustomobject]@{ Name = 'unit_char_declared_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_char_saved_address.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_void_return_abi.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 9; ReturnTypeCheck = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_void_return_abi.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; NativeRoot = 4; ReturnTypeCheck = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_native_bodies.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 5; ReturnTypeCheck = $true;
        Absent = @(); Debt = @() },
    # User break and continue inside the while, not the pad's. continue skips k = 2,
    # the throw at k = 3 adds 100, break ends the loop at k = 5. 1 + 100 + 4 = 105.
    [pscustomobject]@{ Name = 'unit_s1_catch_user_break.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 105; WalkRoot = $true; PadAliases = 1;
        Absent = @();
        Debt = @('c.LMX_WALK_OP_WHILE, 3U)', 'c.LMX_WALK_OP_PAD, 3U)', 'c.LMX_WALK_OP_BREAK, 1U)', 'c.LMX_WALK_OP_CONTINUE, 1U)', 'c.LMX_WALK_OP_CALL,') },
    [pscustomobject]@{ Name = 'unit_catch_payload_graph.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); PadAliases = 1;
        Absent = @(); Debt = @('c.LMX_WALK_OP_PAD, 3U)', 'c.LMX_WALK_OP_PUT_OF, 4U)') },
    [pscustomobject]@{ Name = 'unit_catch_scope_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 20; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); PadAliases = 1;
        Absent = @(); Debt = @('c.LMX_WALK_OP_PAD, 3U)', 'c.LMX_WALK_OP_WHILE, 3U)') },
    [pscustomobject]@{ Name = 'unit_site_hidden_pointer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_formal_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_host_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_initializer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_loop_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_model_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 6; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_views.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 6; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_null.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_collision.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 5; WalkMethods = $true; WalkedMethods = @(2,3,4); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_local_target.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_receiver.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_model_header_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_future_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':3:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_scope_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':6:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':5:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_own_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_host_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_return_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':7:9: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_opaque_model_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':4:1: unknown field path root'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_name_projection.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_input_carry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_carry_conversion.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Table = 'unit_portable_reference_convert_table.lm2'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_carry_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'conversion'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_pointer_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_foreign_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_part_repeat.lm2'; Parts = @('unit_site_part_repeat_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_part_caller.lm2'; Parts = @('unit_s7_part_root_below_refused_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_for_initializer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_prefix_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_parent_fallback.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_mixed_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:14: unbound dynamic input p'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_constructor_reception.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0); WalkedMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_sizeof_hidden.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_future_only_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_callsite_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':8:5: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_portable_reference_spans.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Absent = @(); Debt = @('LMX_WALK_OP_ADDRESS', 'LMX_WALK_OP_ELEM') },
    [pscustomobject]@{ Name = 'unit_portable_reference_values.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 0;
        Debt = @('LMX_WALK_OP_ADDRESS', 'LMX_WALK_OP_EQ'); Note = 'typed held values versus real declared places; same artifact native and actual walked root' },
    [pscustomobject]@{ Name = 'unit_portable_reference_places.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1;
        Debt = @('LMX_WALK_OP_ADDRESS', 'LMX_WALK_OP_DEREF', 'LMX_WALK_OP_PUT, 3U)'); Note = 'opaque pointer-to-cell values and physical stores independent of the working cache' },
    [pscustomobject]@{ Name = 'unit_portable_reference_arrays.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 0;
        Debt = @('LMX_WALK_OP_ADDRESS', 'LMX_WALK_OP_ELEM', 'LMX_WALK_OP_ELEMPUT'); Note = 'char and pointer element addresses select the original backing before any value projection' },
    [pscustomobject]@{ Name = 'unit_portable_reference_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Debt = @('LMX_WALK_OP_ADDRESS', 'LMX_WALK_OP_ARG', 'LMX_WALK_OP_SET_ARG'); Note = 'callee-owned stable pointer parameter places and present-null argument/result transport' },
    [pscustomobject]@{ Name = 'unit_portable_reference_native_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; NativeMethods = @(0,1,2);
        Debt = @('LMX_WALK_OP_CALL'); Note = 'same pointer/null formal program with native callees and an actually walked caller' },
    [pscustomobject]@{ Name = 'unit_portable_reference_descriptors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1);
        Debt = @('LMX_WALK_OP_ARG'); Note = 'both nonprimitive signature spellings address the descriptor, not transport storage' },
    [pscustomobject]@{ Name = 'unit_portable_reference_native_descriptors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1);
        Debt = @('LMX_WALK_OP_ARG'); Note = 'same descriptor-signature identity checks through native trampolines from an actually walked caller' },
    [pscustomobject]@{ Name = 'unit_portable_reference_convert.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Table = 'unit_portable_reference_convert_table.lm2';
        Debt = @('LMX_WALK_OP_PUT, 3U)', 'LMX_WALK_OP_CALL'); Note = 'nonidentity primitive conversion before physical indirect store, evaluated once' },
    [pscustomobject]@{ Name = 'unit_portable_reference_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        GraphShapes = @([pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'DEREF'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3 } }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 12; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }
        ) }); Debt = @(); Note = 'higher-depth receiving model survives dereference; refusal leaves physical and working binding unchanged' },
    [pscustomobject]@{ Name = 'unit_portable_reference_store_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Debt = @('LMX_WALK_OP_PUT, 3U)'); Note = 'physical target selected once before RHS mutates its pointer binding' },
    [pscustomobject]@{ Name = 'unit_own_reference_reception.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 7;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 3; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 2; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 10; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 2; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 11; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 5; CallLink = $true; ResultKind = 'pointer' } }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 2; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 11; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 5; CallLink = $true; ResultKind = 'pointer' } }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_reference_reentry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 2; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2 } }) } }) },
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 2; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 10; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3 } }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_reference_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 12; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }) },
            [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3 } }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 12; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_reference_callable_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_reference_callable_result_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_declaration_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativePatterns = @('(?ms)@: char (?<cell>l2_q\d+)\s.*?\k<cell>: \(cast: \(@: char\) \(0\)\)', '(?ms)@@: char (?<cell>l2_q\d+)\s.*?\k<cell>: \(cast: \(@@: char\) \(0\)\)', '(?ms)@: size_t (?<cell>l2_q\d+)\s.*?\k<cell>: \(cast: \(@: size_t\) \(0\)\)');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_char_from_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_int_from_char_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_char_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_const_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativePatterns = @('(?ms)const: @\(char (?<cell>l2_q\d+)\).*?\k<cell>: \(cast: \(const: @\(char\)\) \(0\)\)');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_const_drop_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_nonzero_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_numeric_zero_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_raw_c_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_pointer_raw_c_admission_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    # Common RHS typing: explicit initializer and later store share conversion/admission.
    [pscustomobject]@{ Name = 'unit_rhs_fnptr_checkpoint.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_compound_admission_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_rhs_reference_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_pointer_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_fnptr_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_init_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_assign_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_rhs_cast_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_cast_init_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_cast_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_cast_init_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_void_double_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_nested_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    # -178 commit 3: the letter's admission to get's Model formal is built (it throws implements); pending on
    # the catch role (-171).
    [pscustomobject]@{ Name = 'unit_s1_catch_implements.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 42;
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
    # Q52 (the author, 2026-09-28; re-expected by name, 7b): the counter a method writes bare is its hidden input,
    # so each call starts from the unit's 0 and the unit's field stays 0 -- the calls are what the methods print.
    # (Were Entry 2, 3 and 25: the unit's field written from the method.)  unit_bare_sub_stmt is the author's example.
    [pscustomobject]@{ Name = 'unit_bare_fn_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Says = @('m 1', 'm 1');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_sub_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Says = @('s 1', 's 1', 's 1');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Says = @('m 1', 'm 1');
        Absent = @(); Debt = @() },
    # -196: a string literal alone at the root makes no step, as natively; the numeric ones are LIT steps.
    [pscustomobject]@{ Name = 'unit_bare_literal_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_own_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 49;
        Absent = @(); Debt = @() },
    # steps/named-struct-exec.md, slice 1 (plan §3 :245 (a)): a column-0 bare `return` closes a named
    # Structure as `end: Name` does (Q19.1), and its body takes statements besides its fields (Q19.2
    # = 2); construction computes the initializer and runs no statement (book :928) -- Counter\n
    # reads 4, not 5.  Both were refused (the frame read as a statement of the entry; a body of field
    # declarations only).  Mutants: no return closing -- the first refused again; statements not set
    # aside -- both refused again.  The guard: P0 hangs a column-0 `return` on any preceding block,
    # so a named Structure is made only of a frame that could be one -- the two refusals keep their
    # old phrases; without the declared-field check the first says "unknown nested Structure
    # reference", without the first-item check the second says "a Structure reference field needs a
    # name".
    [pscustomobject]@{ Name = 'unit_named_struct_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_guard_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported trailer'; Absent = @(); Debt = @() },
    # OPUS-ROOT-CALL-20260930-17: at the root, `Model: Other` with Other declared above is Model's call (refused at its own
    # line), and so is `Model: Other extra`; the heap-corruption shape is the second.  Written above Other's declaration,
    # Other is absent there (source order), and since OPUS-TYPED-BINDING-20260930-20 the form is the typed binding of
    # Other, its candidate an int, refused.  `Model: fresh` still declares.  A `name:` block with nothing above declaring name is a named Structure, a
    # later field of that name collides with it.  The unit classifier reads the source's order, and its answer does not
    # depend on what is registered (the count and fill walks of the lexical pass agree).
    [pscustomobject]@{ Name = 'unit_root_struct_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_root_struct_call_refused.lm2:14:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_struct_call2_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_root_struct_call2_refused.lm2:15:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_struct_call2_forward_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_root_struct_call2_forward_refused.lm2:11:1: a typed binding''s candidate is not a Structure value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_struct_decl_beside_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_block_before_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_root_block_before_field_refused.lm2:8:1: named Structure collides with a unit field'; Absent = @(); Debt = @() },
    # OPUS-TYPED-BINDING-20260930-20 (next_core_tasks.md §3 item 207): `T: b c` with b absent declares b bound to c's
    # descriptor after c's admission to T -- the one a formal's actual takes: c of a named Structure at translation by
    # what b's activation uses (consumer-uses; a THIN Consumer admits an Other), a letter at run time (the interim
    # structural admission, T's whole shape).  No merge, no copy: a write through b is read through c.  b bound: the
    # two-argument call, refused.  The formal pair and the primitive control beside it.  Item 474 stays open.
    [pscustomobject]@{ Name = 'unit_bind_root_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_method_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_method_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_root_thin_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_method_thin_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_root_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_root_used_other_refused.lm2:14:1: implements is false in a typed binding'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_method_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_method_used_other_refused.lm2:14:5: implements is false in a typed binding'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_root_letter.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('ok'); Entry = 2;
        Absent = @(); Debt = @('\fn: lmx_walk_admit_letter') },
    [pscustomobject]@{ Name = 'unit_bind_root_letter_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_known_b_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_known_b_call_refused.lm2:16:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_candidate_not_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_candidate_not_name_refused.lm2:18:5: a typed binding whose candidate is not a name is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_thin_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_formal_used_other_refused.lm2:21:13: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_prim_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_guard_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_struct_guard_call_refused.lm2:7:1: unsupported trailer'; Absent = @(); Debt = @() },
    # steps/named-struct-exec.md, slice 2: a bare `S` at the root executes the named Structure -- its
    # whole body (Q19.2 = 2), the pair (a code node, S as data; §12: its procedure) walked by the root's CALL.  The author's
    # example reads Counter\n 0 before, 1 after one execution and 1 after two (was
    # unit_bare_struct_refused); a Structure only of fields goes back to its initializers; a bare
    # `return` ends the plan and the root executes S from an anonymous block and an if body.
    # Refused: a name that is not S's number field (checked whether or not S is executed, and after
    # the return too), an executed S's array field, a `return` with a value (Q19.1, in its own
    # words).  Mutants: declarations not stored again, the
    # root's CALL placed nowhere -- the three runs red; the anonymous block inert, the plan not
    # stopped at the return -- the return row red; the tail after the return or an unexecuted S not
    # checked, the return-value phrase or the array refusal gone -- their refusal rows red.  §12 (below):
    # the tail's g is refused as any free name nobody binds ("unresolved name", at g), the return with a
    # value in the words of every callable that returns nothing; an executed S's array field and a unit
    # field's read run (were unit_named_struct_exec_array_refused, unit_named_struct_stmt_operand_refused).
    [pscustomobject]@{ Name = 'unit_named_struct_exec.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_unit_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_dead_tail_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:7:12: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_return_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:6:5: return with a value in a callable that returns nothing'; Absent = @(); Debt = @() },
    # Slice 3: a bare S in a unit-level method's body -- natively the same pair through lmx_call_prim,
    # whose walk hook is the root's executor; under --walk-methods the root's CALL in the method's
    # frames.  bump executes Counter twice and reads 1; the root, which wrote 5, reads 1 after (was
    # unit_named_struct_exec_method_refused).  The code nodes follow the named Structures' unit
    # children, known before a native body names them; an empty body's code node holds an empty
    # plain Structure, which the root's walk passes.  A callable merge's nested method keeps the
    # refusal.  Mutants: the native execution emitting nothing -- the native row red, the walked one
    # green; the walked method's CALL placed nowhere -- the walked row red, the native one green; the
    # early base off by one -- the native row red; the empty node a bare return again -- the empty row
    # red; the nested guard gone -- the nested row red.  (§12 replaced the code nodes by the procedures'
    # occurrences: those mutants were of slice 3's code.)
    [pscustomobject]@{ Name = 'unit_named_struct_exec_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_exec_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_nested_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    # REVIEW b193fbb (fable_pc's M35 and probe ns3_two_exec): two executed Structures, two code nodes --
    # the root executes A, go executes B, each by its code node's rank (§12: by its procedure): A\n = 5,
    # B\m = 11.  Mutants: the
    # rank dropped in the native execution -- the native row red, the walked one green; dropped in the
    # walk's CALL -- the walked row red, the native one green.
    [pscustomobject]@{ Name = 'unit_named_struct_exec_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_exec_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Slice 4 (steps/named-struct-exec.md §10-11; REVIEW 3e4c9a0): a bare slot field of the root declared
    # `Model: fresh` executes Model's code over its value -- written 7, reads 2 after; Model\v stays 1,
    # another instance stays 5; again from an anonymous block (was unit_bare_struct_field_refused).  A
    # Structure formal is refused in its own words: its value may be admitted by names with permuted
    # fields (D-105, q39).  Mutants: the field's execution run over Model's own node -- the instance row
    # red; the anonymous block inert -- red; the formal's phrase gone -- the formal row red.
    [pscustomobject]@{ Name = 'unit_named_struct_exec_instance.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_formal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'executing a Structure formal is not supported yet'; Absent = @(); Debt = @() },
    # steps/named-struct-exec.md §12 (the author, Q45 and its two additions: a named Structure is "просто
    # процедура без аргументов и возвращаемого значения"): its body is a method's -- its procedure's, whose
    # own fields are the Structure's, in its slots -- and executing S is a call of the procedure over S.
    # The body's receivers are any body's: if/else, while, a return in a block, a method's call, for (each
    # was "a Structure reference field needs a name"), executed from the root, from a method, and walked; a
    # field declared in a block is the block's, in the procedure's occurrence (walked: reached through it,
    # not through the data); a caught throw.  Refused as in every callable: an uncaught throw (a procedure
    # lists none); a return with a value, in a block as at the top (a sub's too, which was "unsupported
    # body"); a free name nobody binds, said where it stands (it was said at the method's line, or at 1:1
    # at the root and in a procedure).
    # Mutants (steps/named-struct-exec.md §13, each by copy, both modes): the execution naming S as its code
    # -- the if, method and walked ctl rows red; the procedure run over its occurrence -- exec, if, method
    # red; fable_pc's own slots counted from the header parts -- the layout invariant says so where the
    # field is declared, and without it the program aborts (own field 0 has no cell); head 0 -- the empty
    # and walked block rows red; the walked block reached through the data -- the walked block row red,
    # the native one green; an item of no declaration shape read as a field -- the array row refused;
    # only methods declared above -- the call row refused; size_t read as a statement -- the registration
    # invariant says so at the declaration, and without it the translation fails at a reader far off;
    # the free name's old place -- the three located rows red; the old return words -- the three return
    # rows red; the empty body refused -- the empty row red; the nested statement let through -- its row
    # red.  Equivalent: the procedure's own fields counted in its occurrence again (no reader of them).
    [pscustomobject]@{ Name = 'unit_named_struct_exec_if.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_return_in_block.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The author, 2026-09-28 (OPUS-CODEX-20260928-08; 7b, re-expected by name): a named Structure is a procedure
    # without arguments -- that is, with hidden arguments.  Counter's free names (seen, last, total) are its hidden
    # inputs, from the root's 0 at each execution; their bare writes stay its own (Q52).  _call: the calls are put's
    # and later's lines, the root's fields stay 0 (were 10 and 2); _for: `total 3` twice, the root's total 0 at its
    # place of declaration (was 6); _ctl_method: put\got 4 after either call (seen was 8).  Walked twin below.
    [pscustomobject]@{ Name = 'unit_named_struct_exec_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('put 5 5', 'later 1 1', 'put 5 5', 'later 1 1');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('total 3', 'total 3');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_ctl_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The decision's own example: Counter executed from run takes run's local total 100, from the root the root's 0;
    # the root's total stays 0 at its place of declaration.  Native (lmx_call_prim(S, S) with the hidden input in
    # refs) and walked (EXEC with it after its five slots).
    [pscustomobject]@{ Name = 'unit_named_struct_hidden_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; }, [pscustomobject]@{ Method = 1; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        GraphShapes = @(
            [pscustomobject]@{ Op = 'EXEC'; Width = 6; Count = 1; TargetTag = 'Counter'; TargetSlot = 2; Edges = @([pscustomobject]@{ Slot = 5; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }) },
            [pscustomobject]@{ Op = 'EXEC'; Width = 6; Count = 1; TargetTag = 'Counter'; TargetSlot = 2; Edges = @([pscustomobject]@{ Slot = 5; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_hidden_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('c.LMX_WALK_OP_EXEC, 6U)') },
    # OPUS-WALKLOOP-20260929-11: Counter's procedure has a `for` -- it stayed native under the knob until the walker's FOR,
    # though the fixture says it is walked; now it is (the Absent pins).
    [pscustomobject]@{ Name = 'unit_walk_named_struct_exec_ctl_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_block_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_exec_block_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_exec_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_exec_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_throw_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:12:8: unhandled throw: Oops'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_return_value_block_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:6:9: return with a value in a callable that returns nothing'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_sub_return_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:7:9: return with a value in a callable that returns nothing'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_unresolved_name_located_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:5:8: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_unresolved_name_located_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:4:5: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_nested_stmt_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:8:9: a statement in a nested or qualified named Structure is not supported yet'; Absent = @(); Debt = @() },
    # REVIEW 99511ff (fable_pc's M51, probe P59): a Structure of fields only executed in an `else:` of the root
    # and of a method -- the scan finds executions in else bodies; and `else: Counter` is no declaration of a
    # field Counter (l2_unit_declares took any `X: name` for one, so Counter was no named Structure).
    [pscustomobject]@{ Name = 'unit_named_struct_exec_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-105 slice 1 (the author's Q39: the interpreter first; steps/d105-index-table.md §5): the walked
    # root hands `o: Other` (Model's fields in the other order) to `rd (Model: m)` and `wr` -- admitted by
    # NAME through lmx_walk_admit_as, whose correspondence table the arena's `implements` table keeps;
    # `m\a` is read and written at Other's slot for `a` (OF/PUT_OF carry Model).  `mm: Model` goes to
    # the same formal as Model's own.  Under --walk-methods; without it (D-105 native, steps/d105-native.md
    # §4) the callees are native and read the marked formal through the record -- _perm_native, Entry 7;
    # a field of another Structure type is refused.  Mutants (copies; scratchpad d105/mut): identity not
    # admitted -- X1, exit 3; OF or PUT_OF without Model, or a positional table -- the perm row red; the
    # walker ignoring req in OF or PUT_OF, or admit_as recording nothing (X1) -- red; the nested check
    # dropped -- its refusal row red.
    [pscustomobject]@{ Name = 'unit_walk_d105_perm.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105_perm_native.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # K01 (steps/k01-selector-identity-20261001.md): occurrence selectors through an admitted
    # formal.  _unused_first: the candidate's occurrence-0 x is an int no Consumer edge reads;
    # bare v\x is its LAST x -- a size_t like the requirement's -- 30, and the unused mismatch
    # must not reject the candidate (native and walked).  _first_refused: the same candidate
    # with a Consumer that reads `[0]x` -- refused at the call site by the used edge.
    [pscustomobject]@{ Name = 'unit_occ_selector_unused_first.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_selector_first_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    # K01a identity-layout witnesses (same note): a root value and a same-type formal whose model
    # repeats x -- reads, writes and `@` per selector; native and walked.  _root closes the
    # NAMED-MODEL-OCCURRENCE-PATH-LOWERING witness (`r\[0]x` used to lower as C members).
    [pscustomobject]@{ Name = 'unit_occ_selector_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_selector_ident_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_d105_nested.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'lm2:25:6: root operation not walkable yet: an admission to a Structure type through a Structure field of another type'; Absent = @(); Debt = @() },
    # D-105 native (the author's Q39: the interpreter first, then native; steps/d105-native.md §4, REVIEW
    # 9c34b3b): a formal a value of another named type reaches is marked (to a fixed point over the call
    # sites), each call site into it records its value in the arena's implements table with the unit's
    # pair table of the two types, and the formal's first field is read and written at the slot the
    # record gives.  Before, every row read Model's slot: 20.  _arg: native go -> rd(o); _write: a write
    # through the formal; _passon: rd2 -> rd; _passon_other: Model -> Part, the pair picked by the
    # record's table; _mixed: one formal reached by Other and by Model's own; _ownfield: a unit field;
    # _capture: a formal captured by a callable merge (item 738) -- lmx_walk_capture reads through the
    # source's record -- native and walked.
    [pscustomobject]@{ Name = 'unit_d105n_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_passon.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_passon_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_mixed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_ownfield.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105n_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_d105n_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # D-105 native, the result route (steps/d105-native.md §5): a method's result is a place like a formal
    # (k = -1); a `return:` feeds it (a source, or an edge from a formal or from a call's result), a marked
    # result records its value at its return, and a call's result passed on is picked by the value's
    # record.  _return: mk () Model returns Other; _formal: id returns its formal; _chain: a result
    # through a result; _edge_refused: a type reaching a result along an edge is admitted as a return
    # value is -- every field of the result's type -- refused at id.  Before, 20 (C2 until D-108: gcc).
    [pscustomobject]@{ Name = 'unit_d105r_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105r_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105r_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d105r_edge_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:1: implements is false in return value'; Args = @('0'); Absent = @(); Debt = @() },
    # D-112/D-113: a field path deeper than one field in value position (`m\in\x`: five atoms) is one value,
    # read by the general path walk (l2_path_chain, l2_path_text_read) -- as the whole value of a return
    # (D-112: before, "translation failed with no located diagnostic") and inside an expression (D-113:
    # before, "unresolved name" on a name that resolves); through a formal admitted by name too.  A leaf
    # that is no field is refused in its own words, located.
    [pscustomobject]@{ Name = 'unit_d112_nested_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d113_nested_expr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d112_nested_leaf_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':15:13: unknown field path segment'; Args = @('0'); Absent = @(); Debt = @() },
    # D-111: the value of a `return:` in a Structure-result method was admitted and never checked as a
    # value -- a call in it met no rule of §14 (the internal backstop at 1:1 alone): now it is checked as
    # any value is.
    [pscustomobject]@{ Name = 'unit_d111_return_declared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:9: unhandled throw: Oops'; Args = @('0'); Absent = @(); Debt = @() },
    # D-109: a bound name of another named type handed to a Structure formal was admitted by nothing; the
    # formal's uses are now checked for every type that reaches it (l2_d105_close): refused at the call.
    # D-110: a consumer's uses were its body's alone -- the hung `return:` (P0 trailer) was not walked --
    # so `rd(Lacks)` into a formal read only by `return: m\a` was admitted with empty uses; the walk reads
    # the trailer now (l2_uses_walk_body).  Before, both translated silently.
    [pscustomobject]@{ Name = 'unit_d109_uses_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':19:13: implements is false in function argument'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_d110_return_uses_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':16:9: implements is false in function argument'; Args = @('0'); Absent = @(); Debt = @() },
    # REVIEW dd07174 (fable_pc's M36 and probe ns4_two_types): two executed fields of two types, each
    # runs its own type's code -- m\v = 2, o\w = 15.  Mutant: every field takes the first Structure's
    # code -- red.  One row: the root is walked in both modes (the knob acts on methods).
    [pscustomobject]@{ Name = 'unit_named_struct_exec_two_types.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bare_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    # THE RECEIVER CONTRACT (plan §3 native gate (б)-(е); FABLE-OPUS-RECEIVER-CONTRACT-20260924-139).
    # A callable named where a value is consumed gives its result: it runs with no arguments on the
    # call path of `m()` -- a method or a callable formal, in a declaration, assignment, operand,
    # condition (guarded by && like any call), argument, and `return: m` in a body or a trailer.  A
    # callable without a result has no value and is refused.  A callable formal of the callee takes
    # the occurrence itself.  `f()` on an existing ordinary Structure assigns the empty Structure,
    # with admission to its declared type (the book §12; refused admission is implements).
    # Q52 (re-expected by name, 7b): m's hits is its hidden input -- the four runs are the four `m 1` lines (a fifth,
    # behind the false `&&`, would redden Says) and the unit's hits stays 0: 7807 (was 7811).
    [pscustomobject]@{ Name = 'unit_value_call_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7807;
        Says = @('m 1', 'm 1', 'm 1', 'm 1');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_value_call_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    # FABLE-OPUS-ROOT-WALK-TRANSLATOR-20260924-159 commit 1 (D-38): a callable formal whose callable
    # throws is called through lmx_call_prim -- the throw status apart from the value, the thrown
    # record through `out` -- and propagated like a direct call's, so the handler takes the payload
    # (5 + 2) and the calm callable's value arrives (3).  Success is 10.
    [pscustomobject]@{ Name = 'unit_dyn_call_throw_caught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 10;
        Absent = @('lmx_call0('); Debt = @('lmx_call_prim(l2_program_arena, l2_c') },
    # A sub occurrence is reference-transportable in argument position, but its reference cannot
    # satisfy an int formal.  Do not replace this with the value-position no-result diagnostic.
    [pscustomobject]@{ Name = 'unit_value_call_sub_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
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
    # Ticket 15 (book §9 after 55c1abc, the call rule; OPUS-Q54-CONTINUE-20260929-14): `S()` -- one Frame with `S: ()`
    # -- on an existing Structure binding is its nullary call, as the bare atom S is (steps/named-struct-exec.md §12),
    # never the assignment of a new empty Structure with admission these rows pinned before (were
    # unit_empty_assign_untyped, _named, _admit: 4, 74, 421).  The root's first E() declares E and the later E() / E: ()
    # call it -- EXEC pinned, no admission, no EMPTY node: 7.  Counter() and Counter: () run Counter's body from the root
    # and from bump, natively and walked (both methods walked: pinned): 7.  `Model: m` declares m, a named Structure, and
    # m() / m: () run Model's body over m: 7.  The letter's m() is its call too -- the letter's type is not declared, and
    # that call is not built yet: refused where it stands, as its bare atom is.
    [pscustomobject]@{ Name = 'unit_empty_call_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lmx_walk_admit', 'c.LMX_WALK_OP_EMPTY, 1U)'); Debt = @('c.LMX_WALK_OP_EXEC, 5U)') },
    [pscustomobject]@{ Name = 'unit_named_struct_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lmx_walk_admit', 'LMX_IMPLEMENTS_YES'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_struct_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_model_var_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lmx_walk_admit', 'c.LMX_WALK_OP_EMPTY, 1U)'); Debt = @('c.LMX_WALK_OP_EXEC, 5U)') },
    [pscustomobject]@{ Name = 'unit_letter_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_letter_call_refused.lm2:6:1: executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    # A BARE `return` CLOSES A SUB (P0, FABLE-OPUS-RECEIVER-CONTRACT-20260924-139 commit 3; author
    # 2026-09-24 Q19.1/Q19.3): the trailer ends the body of s, and each call runs it -- `s 3` twice.  This is the
    # author's Q52 example (2026-09-28; re-expected by name, 7b): y is s's hidden input, and the unit's y stays 0
    # («это независимое действие»; was Entry 6).
    [pscustomobject]@{ Name = 'unit_sub_return_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Says = @('s 3', 's 3');
        Absent = @(); Debt = @() },
    # THE EXPRESSION STATEMENT (plan §3 "Expression statement и discard"; FABLE-OPUS-DISCARD-20260924-147).
    # One consumer, l2_eval_discard: a bare atom, a run of fields l2_expr_span groups into one
    # expression, a call Frame.  A callable atom is called with no arguments; anything else is
    # evaluated on the value path and dropped into the typed temporaries its calls already have (a
    # pure expression emits nothing).  An anonymous Structure is a nested body; `()` and one with
    # nothing to run emit nothing.  A sub cannot be an operand.
    [pscustomobject]@{ Name = 'unit_discard_codex.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 2;
        Absent = @(); Debt = @() },
    # Q52 (re-expected by name, 7b): f's hits is its hidden input -- its three calls are three `f 1` lines, and the
    # unit's hits stays 0 (was Entry 3).
    [pscustomobject]@{ Name = 'unit_discard_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Says = @('f 1', 'f 1', 'f 1');
        Absent = @(); Debt = @() },
    # TYPED NUMBERS AT THE WALKED ROOT (FABLE-OPUS-ROOT-TYPED-20260925-175): size_t, unsigned, ulong
    # and char root fields; a literal takes its place's type -- the pin is `got != 41U`'s LIT size_t --
    # and two types in one operation are a conversion, refused (unit_addr_arg).
    [pscustomobject]@{ Name = 'unit_root_typed_numerics.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 63;
        Absent = @(); Debt = @('lmx_walk_store_size(l2_program_arena, l2_rw', ', 1U, 41U) != c.LMX_WALK_OK', 'lmx_walk_store_char(l2_program_arena, l2_rw') },
    # A CALL'S RESULT OF A WIDER TYPE (FABLE-OPUS-ROOT-STRUCTS-20260925-178 commit 1; -174 c4; -189 c4):
    # the CALL's rtype operand is the callee's result cell in its `return` part, by reference, so the
    # walk hands a size_t trampoline a size_t cell.  The second row: two size_t methods with
    # different inputs, each CALL referring to its own callee's return cell.
    # Keep >2^32 execution and the CALL's physical result-cell reference; do not pin global rwN indices.
    [pscustomobject]@{ Name = 'unit_root_call_wide.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'size'; });
        NativePatterns = @('(?s)fn: l2_m0_tr\b(?:(?!\nend:).)*size_t: l2_tv\s+l2_tv: l2_m0\(l2_self\\parent, l2_self\)\s+if: lmx_msg_poll_escape\(\) != 0\s+return: 0\s+lmx_size_store_known\(dest, l2_tv\)\s+\\out: dest');
        Absent = @('LMX_WALK_RESULT_SIG_MARK'); Debt = @() },
    # Both CALLs still resolve their own native-bound descriptor and result cell, with arities 1 and 0.
    [pscustomobject]@{ Name = 'unit_method_sig_distinct.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 3; NativeRoot = 2;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 1; Ints = @(5); InputKinds = @('int'); ResultKind = 'size'; }, [pscustomobject]@{ Method = 1; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'size'; });
        NativePatterns = @('(?s)fn: l2_m0_tr\b(?:(?!\nend:).)*size_t: l2_tv\s+l2_tv: l2_m0\(l2_self\\parent, l2_self, lmx_int_value_known\(refs\[0\]\)\)\s+if: lmx_msg_poll_escape\(\) != 0\s+return: 0\s+lmx_size_store_known\(dest, l2_tv\)\s+\\out: dest', '(?s)fn: l2_m1_tr\b(?:(?!\nend:).)*size_t: l2_tv\s+l2_tv: l2_m1\(l2_self\\parent, l2_self\)\s+if: lmx_msg_poll_escape\(\) != 0\s+return: 0\s+lmx_size_store_known\(dest, l2_tv\)\s+\\out: dest');
        Absent = @('LMX_WALK_RESULT_SIG_MARK'); Debt = @() },
    # D-03 (-189 c4): a callable named at the walked root is an explicit CALL the translator emits --
    # the walker calls nothing on its own; a bare statement drops the result, a value takes it.
    # Both discarded and valued bare calls now increment an explicit lexical field; neither may be elided.
    [pscustomobject]@{ Name = 'unit_root_bare_callable_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 2; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('"<string.h>"'); Debt = @('include: "<stdio.h>" "<stdlib.h>"') },
    # -197 (b): the preamble's C headers are the program's own mechanics' -- <stdio.h> and
    # <stdlib.h> always (X1 is fprintf(stderr) + abort, the launch hands the host stdout/stderr),
    # <string.h> only where the emission uses it: a send copying a text field (memcpy), the library
    # profile (memset).  unit_root_bare_callable_call above has no such use and no <string.h>.  (On this
    # toolchain <windows.h>, through lmx_clock, declares memcpy too, so gcc cannot tell; the pins do.)
    [pscustomobject]@{ Name = 'unit_send_text.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @(); Debt = @('include: "<stdio.h>" "<stdlib.h>" "<string.h>"', 'memcpy(text') },
    # THE WALKED METHODS (-193 T4a): a method whose body is in the walkable subset is built as walker
    # frames too, M's own children after its fields (steps/merge-parts-193.md §9).  These rows run with
    # WalkMethods: l2trans's test knob gives every method with frames native 0, so the root's CALL walks
    # it.  A formal is [arg, j]; an own field is the activation's data, holder 0 (K-OT2: no holder
    # stored); `return: V` is [ret, V] (and a trailer the last step); every call runs its callee over the callee's own
    # occurrence, [call, M, M, ...] -- a re-entry too (the author, 2026-09-28: no per-call instance); a unit field keeps
    # its holder, the unit.  The pins are the form: add's `s: a + b` is its first step (slot 3), its return the second.
    # §7b: the walker loads the used own fields at the activation's entry (lmx_walk_load_code) -- no step does -- and a
    # bare read or write is OWN / SET of its working value -- still no holder stored; a formal is ARG.
    [pscustomobject]@{ Name = 'unit_walk_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'if: lmx_arena_ref_store(l2_rw82, 1U, (cast: (@: void) l2_entry_unit))');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @(
                    [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } },
                    [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }
                ) } }
            ) }
        ); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_recursion.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)');
        GraphShapes = @([pscustomobject]@{ Op = 'CALL'; Width = 6; Count = 6; CallLink = $true }); Debt = @() },
    # clamp(..) + clamp(..) + clamp(..) is 13 walked too: a walked callee's number result is copied into
    # the caller's destination by its rtype (D-72, K-RET, Sonnet -194 k.5b); as a reference into the
    # callee's data the next call overwrote the cell before the sum read it.  §7b: tri's first step is its first
    # statement (`i: 0`, SET at slot 5) -- the walker loads the used own fields at the entry, no step -- and its loop
    # is a WHILE step.
    [pscustomobject]@{ Name = 'unit_walk_loop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'WHILE'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'LT'; Width = 3 } }) },
            [pscustomobject]@{ Op = 'WHILE'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AND'; Width = 3 } }) }
        ); Debt = @() },
    # unit_walk_trailer: acc's own `mine` is SET / OWN of its working value; y is s's and acc's hidden input, and
    # their writes are SET_ARG -- the root's y stays 0 (Q52, the author 2026-09-28; 7b, re-expected by name: was 6
    # after s() twice and 16 after acc(10), which is now 10).  The pins: s's write is SET_ARG 0; acc's `mine: y + by`
    # is its first step, SET of its working value (slot 2), reading y as ARG 1; `y: mine` is SET_ARG 1.  The node
    # numbers are 18 lower since OPUS-WALKLOOP-20260929-11: the root's `if: r != 10 || y != 0` is one OR node, no longer
    # a flag cell and its steps (in the count pass and the emission alike); the shapes pinned are the same.
    [pscustomobject]@{ Name = 'unit_walk_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_ARG'; Width = 4; WitnessKind = 'int'; Count = 1; NextRole = 'RET'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 3 }) } }) } }) },
            [pscustomobject]@{ Op = 'SET_ARG'; Width = 4; WitnessKind = 'int'; Count = 1; Sizes = @([pscustomobject]@{ Slot = 1; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3 } }) }
        ); Debt = @() },
    # T4b class 2 walks bind and native_caller too.  bafca4c / Q52 (an argument is its parameter): bind's
    # `n: n + 100` is the activation's write of its input n (SET_ARG), and its return reads that input (ARG) -- no
    # field is written.
    [pscustomobject]@{ Name = 'unit_walk_mixed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m3_tr)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_ARG'; Width = 4; WitnessKind = 'int'; Count = 1; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 100 }) } }) } }) },
            [pscustomobject]@{ Op = 'SET_ARG'; Width = 4; WitnessKind = 'int'; Count = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) } }) },
            [pscustomobject]@{ Op = 'RET'; Width = 2; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) }
        ); Debt = @() },
    # T4b class 1: a Structure formal is ARG j, the caller's Structure. peek reads OF(ARG 0, slot 0);
    # poke writes PUT_OF of that ARG; sum reads ARG 0 and ARG 1. The three methods are walked.
    [pscustomobject]@{ Name = 'unit_walk_struct_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)');
        Debt = @('@: Lmx l2_rw69 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw68, c.LMX_WALK_OP_ARG, 2U)',
                 'if: lmx_walk_store_size(l2_program_arena, l2_rw69, 1U, 0U) != c.LMX_WALK_OK',
                 'if: lmx_walk_store_size(l2_program_arena, l2_rw68, 2U, 0U) != c.LMX_WALK_OK',
                 '@: Lmx l2_rw71 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw70, c.LMX_WALK_OP_PUT_OF, 4U)',
                 'if: lmx_walk_store_size(l2_program_arena, l2_rw82, 1U, 1U) != c.LMX_WALK_OK') },
    # T4b class 2: a numeric field named like a formal is ARG until its declaration, then the field -- under the
    # working state (7b-2, by name): bump's `int: n` carries ARG 0 into its working value (SET over OWN, l2_rw54-56)
    # and then reads that value (OWN); see reads ARG before the declaration (`a: n`, l2_rw67) and carries after it.
    # (Were PUT of ARG into the cell and AT reads: the c3b-2 in-place row.)
    [pscustomobject]@{ Name = 'unit_walk_formal_bind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)',
            '@: Lmx l2_rw54 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw53, c.LMX_WALK_OP_PUT, 4U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 3 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 4; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }
            ) }
        ); Debt = @() },
    # D-79: a field declared in if/else/while is OWN_OF/SET_OF of that body.  keep's `int: n` carries ARG into the
    # method field's working value (SET, l2_rw133) and its bare `n: n + 1` inside `if` writes that same working value
    # (SET, l2_rw144); branch's `int: n` inside `if` is that body's field -- carried by SET_OF (l2_rw171), and after the
    # body the name is the argument again (ARG, l2_rw189; Q51: a local is not visible outward).  7b-2, by name: were
    # PUT/PUT_OF into the cells and OF reads, the c3b-2 in-place rows.
    [pscustomobject]@{ Name = 'unit_walk_nested_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)',
            'c.LMX_WALK_OP_PUT_OF, 4U)', 'c.LMX_WALK_OP_OF, 3U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 3 }) } },
                [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3 } },
                [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN_OF'; Width = 3 } }) } }) }
        ); Debt = @() },
    # Side fixes (-193 T4a): a root `M\x` of a method after the first, in a unit with no named Structure
    # (l2trans crashed); a repeated declaration's initializer reads the occurrence before it
    # (l2_own_excl, as natively); the root names its own fields by no holder (K-OT2).
    [pscustomobject]@{ Name = 'unit_occ_root_second.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_decl_init_prev.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @('1U, (cast: (@: void) l2_entry_unit)) != 0 || lmx_walk_store_size(l2_program_arena'); Debt = @() },
    # THE RAW C DOOR BY TOKEN (-198; spec 6.6.6: a c.* head is foreign C, emitted as written, the C
    # compiler judges it): c.name(...) is a call in every form -- a statement with an argument or with
    # none, a value with an argument or with none.  Kept from the retired twin's own gate
    # (l2_stable_head_call_gate.ps1, Grok -81; tag l2src-twin-20260926).  An empty statement call was
    # refused on main (D-74: l2_head_is_call counted a one-segment head as an update, whose value of
    # no fields l2_check_fields refused); for c_empty_abort the translation itself is the witness,
    # since the preamble's own X1 lines call c.abort() too.
    [pscustomobject]@{ Name = 'unit_head_call_c_arg_compact.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @(); Debt = @('    c.bogus(1)') },
    [pscustomobject]@{ Name = 'unit_head_call_c_empty_abort.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @(); Debt = @('    c.abort()') },
    [pscustomobject]@{ Name = 'unit_head_call_c_empty_rand.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @(); Debt = @('    c.rand()') },
    [pscustomobject]@{ Name = 'unit_head_call_c_expr_rand.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @(); Debt = @('(c.rand())') },
    [pscustomobject]@{ Name = 'unit_head_call_c_expr_strlen.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @(); Debt = @('(c.strlen("hi"))') },
    # The same door RUNNING: c.rand() as a value and in a condition, c.abort() as a statement in an if
    # body; empty_calls(1) is 0.
    [pscustomobject]@{ Name = 'unit_c_empty_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @(); Debt = @('(c.rand())', 'if: c.rand() < 0') },
    # STRUCTURE-TYPED ROOT FIELDS (-178 commit 2): `Model: m` is the walker's merge primitive (-174 c3)
    # held by reference as m's working value (§7b: SET, published into m's cell at a boundary); `m\value` takes the
    # field of that Structure (OF), no DEREF; `Model\value: 7U` writes the named Structure itself (PUT, its node
    # fixed when the graph is built).  n, merged after the write, sees 7; m keeps its own 41.
    [pscustomobject]@{ Name = 'unit_root_model_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 15;
        Absent = @('c.LMX_WALK_OP_DEREF'); Debt = @('@: Lmx l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw0, c.LMX_WALK_OP_PRIM_PUB, 4U)', '\fn: lmx_walk_merge_model', '@: Lmx l2_rw0 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_SET, 3U)') },
    # A WRITE THROUGH A REFERENCE (FABLE-OPUS-ROOT-PUTOF-MUL-20260925-183 commit 1): `m\value: 42U` is
    # PUT of an OF place, its holder read once from m; read back through m and through
    # a method's formal (the same Structure, by reference), Model itself untouched: 7.
    [pscustomobject]@{ Name = 'unit_root_putof.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @(); GraphShapes = @(
            [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }) } }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = 42 }) } }
            ) }
        ) },
    # `* / %` AT THE WALKED ROOT (FABLE-OPUS-ROOT-PUTOF-MUL-20260925-183 commit 2): MUL/DIV/MOD (-170 c1) over
    # one type -- precedence (2 + 3 * 4 = 14), a size_t %, an int / with a negative operand (-7 / 2 = -3,
    # as C), left to right (3 * 5 % 4 = 3): 15.  A literal 0 divisor is refused at translation; a
    # computed 0 is the walker's X1 in R0's turn.
    [pscustomobject]@{ Name = 'unit_root_mul.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 15;
        Absent = @(); Debt = @('c.LMX_WALK_OP_MUL, 3U)', 'c.LMX_WALK_OP_DIV, 3U)', 'c.LMX_WALK_OP_MOD, 3U)') },
    [pscustomobject]@{ Name = 'unit_root_div_zero_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'root operation not walkable yet: a division by zero'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_calls.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call whose result is not a number'; Args = @('0'); Entry = 11112;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_fnptr.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f()'); Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_discard_void_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a callable without a result has no value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_discard_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    # AN ARGUMENT AND ITS DECLARED FIELD (7b-2, ticket OPUS-7B2-20260929-01; L2 §10, §18.2, §18.3; book §12: "an
    # explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a
    # graph-backed field").  A formal (or a dynamic input) is the parameter until its same-name declaration executes --
    # a bare assignment binds nothing (bafca4c) -- and a declared field from then on, under the working state: the
    # declaration takes the argument's current value into the working value and marks it, the bare name reads the
    # working value, a graph write through `M\x` or through `@x` (the cell, L2 §18.2) changes the cell and not the
    # working value, and a marked working value is published at the next checkpoint, over such a write.  `@x` before
    # the declaration is the parameter's stable address, never retargeted and never a publication destination (L2
    # §18.3): no sticky flag, no republication.
    #
    # These rows have `Says`: the lines the PROGRAM must print, whole and in order; each line is
    # "<case> <name> <graph field>".  Re-expected by name in 7b-2 from the c3b-2 in-place values (the name was the
    # cell: 100 100, 9 9, 200 200):
    #   A  address before the declaration: the parameter is poked (5), carried, +1: A1 6 6; the graph writes change
    #      the cell only: A2 6 100, A3 6 9 (`@na` is now the cell), A4 6 200.
    #   B  never declared: the name stays the parameter (5) while the field holds the graph write: B 5 100; declared
    #      (go = 1): 5 carried, +1, then the graph write 200 -- the marked 6 is published over it: B+ 6 6.
    #   C  declared, then the address: the cell is poked, the working value stays: C2 4 9, C3 4 100.
    #   D  the poke before the declaration is the parameter's (D1: 5 carried, +1), after it the cell's (D0: 3 + 1):
    #      D1 6 100, D0 4 100.
    #   E  declared, address after: E 4 100.
    # Pins: the carry into the working value (l2_q1: the parameter), the parameter's address before it and the
    # cell's after it; the in-place carry into the cell is gone.
    [pscustomobject]@{ Name = 'unit_arg_addr_sticky.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('A1 6 6', 'A2 6 100', 'A3 6 9', 'A4 6 200', 'B 5 100', 'B 5 100', 'B+ 6 6', 'B 5 100', 'C1 4 4', 'C2 4 9', 'C3 4 100', 'D1 6 100', 'D0 4 100', 'E 4 100');
        Absent = @('_sticky', '_active', 'if: lmx_int_store_known(l2_q1_from[0], (l2_p3_0)) != 0');
        NativeCalls = @([pscustomobject]@{Caller=3; Method=0; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) @ l2_p3_0\)$'})}, [pscustomobject]@{Caller=3; Method=1; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) \(cast: \(@: int\) l2_q\d+_from\[0\]\)\)$'})});
        Debt = @('l2_q1: (l2_p3_0)') },
    # TYPE IS AN INDEPENDENT AXIS.  unsigned was REFUSED in the declared form (a formal's type code
    # was compared with an own field's storage code: 34 against 3) and silently left a plain local
    # in the assignment form; a pointer was never bound at all.  Both now go through the same
    # mechanism, and the type only names the cell.  7b-2 (by name): the declaration takes the poked argument into its
    # working value (50, 70, 80), +1 is published, and the graph write of 100 changes the cell only -- U 51 100,
    # Z local 71, L local 81 (the c3b-2 in-place name read the cell: 100).
    [pscustomobject]@{ Name = 'unit_arg_addr_types.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('U 51 100', 'Z local 71', 'Z graph 100', 'L local 81', 'L graph 100');
        Absent = @('_sticky', 'if: lmx_unsigned_store_known(l2_q1_from[0], (l2_p4_0)) != 0', 'if: lmx_size_store_known(l2_q3_from[0], (l2_p5_0)) != 0',
            'if: lmx_ulong_store_known(l2_q5_from[0], (l2_p6_0)) != 0');
        Debt = @('l2_q1: (l2_p4_0)', 'l2_q3: (l2_p5_0)', 'l2_q5: (l2_p6_0)') },
    [pscustomobject]@{ Name = 'unit_arg_addr_pointer.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not a number';
        Args = @('0');
        Absent = @();
        Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_named_addr_gap.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @(); Debt = @() },
    # THE SAME RULE FOR A HIDDEN/DYNAMIC INPUT (FABLE-L2-ARG-ADDRESS-PROOF-20260921-84).  A free name
    # read before the body's own same-name declaration arrives in a hidden formal, and that declaration
    # binds it exactly as it binds a declared formal.  The matrix runs for int and for size_t.
    # int was SILENTLY WRONG: its storage code doubled as the dynamic code for "not typed yet", so
    # an int was never passed -- the callee read its own graph field.  Before the change this
    # program printed IA1 1 1, IA2 1 100, IA3 1 9, IA4 1 200, IB 0 100, IB 100 100, IB+ 101 101,
    # IB 101 100 and NO IC line at all (the early return saw 0); every Z line was already right.
    # Debt is the hidden formal itself: `int:` for int_before, and the mixed pair of int_never.
    # 7b-2 (by name): as unit_arg_addr_sticky -- the declared field has a working value, graph writes change the cell
    # only, a marked value is published over them: IA2/IA3/IA4 6, IB+ 6 6, IC2/IC3 4, and the Z lines alike (were
    # the c3b-2 in-place 100/9/200).
    [pscustomobject]@{ Name = 'unit_arg_addr_dynamic.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('IA1 6 6', 'IA2 6 100', 'IA3 6 9', 'IA4 6 200', 'IB 5 100', 'IB 5 100', 'IB+ 6 6', 'IB 5 100', 'IC1 4 4', 'IC2 4 9', 'IC3 4 100',
            'ZA1 6 6', 'ZA2 6 100', 'ZA3 6 9', 'ZA4 6 200', 'ZB 5 100', 'ZB 5 100', 'ZB+ 6 6', 'ZB 5 100', 'ZC1 4 4', 'ZC2 4 9', 'ZC3 4 100',
            'CALLER 3 3 3 3 3 3');
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
    # 7b-2 (by name): the declared field keeps its working value under the graph write: U2/L2/F2 6 100 (were 100 100).
    [pscustomobject]@{ Name = 'unit_arg_addr_dyn_types.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('W 3', 'U1 6 6', 'U2 6 100', 'L1 6 6', 'L2 6 100', 'F1 6 6', 'F2 6 100', 'DP local is null', 'DP caller keeps its pointer', 'FC 3', 'TC 3 3 3');
        NativeCalls = @([pscustomobject]@{Caller=8; Method=2; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) @ l2_p8_0\)$'})});
        Absent = @();
        Debt = @('l2_p8_0: l2_p8_0', 'fn: l2_m4 (@: Lmx node; @: Lmx self; int: l2_p4_0) int',
                 'fn: l2_m5 (@: Lmx node; @: Lmx self; unsigned: l2_p5_0) int',
                 'fn: l2_m6 (@: Lmx node; @: Lmx self; ulong: l2_p6_0) int',
                 'fn: l2_m8 (@: Lmx node; @: Lmx self; @: int l2_p8_0) int') },
    # THE ORDINARY CASES ALONE.  Every address here is taken after the declaration, so it is the field's cell
    # (L2 §18.2): the poke changes the cell and not the working value (OC2 4 9), and so does the later graph write of
    # 100 (OC3 / OE / OD3 4 100) -- 7b-2, re-expected by name (were 9 9 and 100 100 in place).
    # CRASH WARNING, not an old expectation: a translator that raises sticky at the address site
    # AND publishes through a cell nobody resolved dies (exit 139) on a before-bind or never-bound
    # activation, and that death hid these lines -- which is why they have a program of their own.
    # "Address-taking invents no graph field" keeps those cases alive.
    [pscustomobject]@{ Name = 'unit_arg_addr_ordinary.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('OC1 4 4', 'OC2 4 9', 'OC3 4 100', 'OE 4 100', 'OD1 4 4', 'OD2 4 9', 'OD3 4 100');
        Absent = @();
        Debt = @('fn: l2_m6 (@: Lmx node; @: Lmx self; size_t: l2_p6_0) int') },
    # THE ONE BOUNDARY.  A dynamic input whose SOURCE exists but has no value cell (the caller's
    # const LmP0Text formal) is refused at the caller, by name.  Before, the same program was an
    # "unresolved name" at the callee -- as if nobody had supplied it -- and that is what the
    # pre-change translator still says, so this row fails on it.
    [pscustomobject]@{ Name = 'unit_arg_addr_dyn_nocell.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'dynamic input type has no value cell'; Absent = @(); Debt = @() },
    # 7b-2 WITNESSES (ticket OPUS-7B2-20260929-01; L2 §10, §18.2, §18.3; book §12; Q51).  unit_arg_decl_carry: a
    # formal's same-name declaration takes the argument into a working value, which is published and not reloaded;
    # observed from other methods, so the walk twin walks carry (the Absent pin).  In place: 65; a carry into the
    # cell alone (the walk before 7b-2): 66.
    [pscustomobject]@{ Name = 'unit_arg_decl_carry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_arg_decl_carry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # unit_arg_decl_branch: a declaration binds only when it executes, and only forward and down -- after its body the
    # name is the argument again, and a branch not taken binds nothing (313 / 300; a binding left active 65, one
    # activated statically 66).
    [pscustomobject]@{ Name = 'unit_arg_decl_branch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_arg_decl_branch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # unit_arg_decl_dyn: a dynamic input bound by its same-name declaration exactly as a formal (4004100); the walk
    # ignored the declaration before 7b-2 (4000100, 65).
    [pscustomobject]@{ Name = 'unit_arg_decl_dyn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_arg_decl_dyn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # unit_arg_decl_oldptr: `@x` of the argument taken before its declaration stays the parameter's address -- a write
    # through it after the declaration changes the parameter only, never the field (450; a sticky republication
    # 5150, 65).  Native only: the walk takes no address.
    [pscustomobject]@{ Name = 'unit_arg_decl_oldptr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @(); NativePatterns = @('(?s)@: int (?<pointer>l2_q\d+)\s+\k<pointer>: \(cast: \(@: int\) lmx_pointer_value_known\(\k<pointer>_from\[0\]\)\).*?\k<pointer>: \(cast: \(@: int\) \(@ (?<formal>l2_p\d+_\d+)\)\).*?(?<field>(?!\k<pointer>\b)l2_q\d+): \(\k<formal>\).*?@: int (?<first>l2_t\d+)\s+\k<first>: \k<pointer>\s+@: int (?<place>l2_t\d+) \k<first>\s+\\\k<place>: 50.*?\k<field>: \(\k<field> \+ 1\)') },
    # unit_arg_decl_publish: the declaration's carry is a marked write like any -- the next boundary (the call of peek)
    # publishes it with no later write: f(5) = 5.  A carry left unmarked: 0 (65).  Walk twin walks f (the Absent pin).
    [pscustomobject]@{ Name = 'unit_arg_decl_publish.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('l2_q0: (l2_p0_0)') },
    [pscustomobject]@{ Name = 'unit_walk_arg_decl_publish.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # 7b-3 WITNESSES (ticket OPUS-7B3-20260929-02; book §12 and "names"; L2 §10 `M\for\y`; Q51; Q52): one path rule for
    # a control body -- the field of its enclosing body named by its statement's head; a path root naming one is the
    # last such body visible where the path stands (inside it, or after its `end:`).  unit_body_path_for: the book's
    # program -- pair receives 9 0 (the actuals before the call's checkpoint), a later for\j 9, `for\j: 42` the cell;
    # walked too (OPUS-WALKLOOP-20260929-11: the walker's FOR; pair and test walked, the Absent pins).  Pins: the root is
    # the prologue's handle of the body.
    [pscustomobject]@{ Name = 'unit_body_path_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('l2_pst: l2_h0') },
    [pscustomobject]@{ Name = 'unit_walk_body_path_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # unit_body_path_while: the same order walked too (test walked: the Absent pin), plus position (loop B written
    # later is not visible before it) and depth (a loop inside an `if` body).  The walked actuals are typed temporaries
    # before the call's checkpoint (lmx_walk_arg_value): the walk printed 9 9 before 7b-3.
    [pscustomobject]@{ Name = 'unit_body_path_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)'); Debt = @() },
    # unit_body_path_deep: a body root under a deeper path -- while\pt\x as a value and as a call's argument, where P0
    # gives the atoms and l2_path_chain admits a body head as it admits `node`.  Native only (a Structure field in a
    # nested body keeps a method out of the walk).
    [pscustomobject]@{ Name = 'unit_body_path_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The negatives: the bare j after `end: for` is not j outside its body (Q51) -- refused where it stands; a path to a
    # field the body does not declare is refused -- nothing makes one (Q52).  Both modes.
    [pscustomobject]@{ Name = 'unit_body_path_bare_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_body_path_bare_refused.lm2:11:13: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_bare_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_body_path_bare_refused.lm2:11:13: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_body_path_absent_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_body_path_absent_refused.lm2:12:12: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_absent_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_body_path_absent_refused.lm2:12:12: unresolved name'; Absent = @(); Debt = @() },
    # OPUS-NODATA-20260929-03 (plan §7b and GATE: no auxiliary data Structure, no hidden data twin in the persistent
    # graph).  unit_decl_addr_reentry: `@x` of a declared field is its cell in M's occurrence -- one cell for every
    # activation, the outer and a re-entrant one (the re-entrant activation's write through its own @x is what the
    # outer reads through its p: 55); a per-call instance, or @x lowered to the working value's address, reads 0 (65).
    # This row executes natively; both address sites select the same declared cell.
    [pscustomobject]@{ Name = 'unit_decl_addr_reentry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativePatterns = @('(?ms)(?<first>l2_q\d+): \(cast: \(@: int\) \(\(cast: \(@: int\) (?<cell>l2_q\d+_from)\[0\]\)\)\).*?(?!\k<first>:)(?<second>l2_q\d+): \(cast: \(@: int\) \(\(cast: \(@: int\) \k<cell>\[0\]\)\)\)');
        Absent = @(); Debt = @() },
    # Q52 (the author: "у s нет поля y, оно у ROOT"; GATE: `s\y` does not exist): s writes its hidden input y bare and
    # declares no y, so the path s\y is refused where it stands.  ROOT\y = 0: unit_sub_return_trailer.  Both modes.
    [pscustomobject]@{ Name = 'unit_q52_no_sub_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_q52_no_sub_field_refused.lm2:10:6: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_q52_no_sub_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_q52_no_sub_field_refused.lm2:10:6: unresolved name'; Absent = @(); Debt = @() },
    # OPUS-LOCALINIT-20260929-04 (plan §7b "Локальные объявления и явная инициализация": the author's computed
    # initialization `int: i` / `i: findValue`; FABLE-OPUS-RECEIVER-CONTRACT-20260924-139): a callable named as the whole
    # value of an assignment gives its result, typed as its call gives it (l2_colon_value_ty) -- the assignment's check
    # refused it, "assignment value has unknown type".  unit_local_init_two_statements + walk twin (M native, walked):
    # the call only when the line runs (a skipped line calls nothing), one call per reached assignment into the same
    # local, M\i from outside reads the place during and after and runs nothing; the walked root's own pair too.
    [pscustomobject]@{ Name = 'unit_local_init_two_statements.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_init_two_statements.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Typed as its call, a callable of another numeric type has the store's edge: size_t 3000000000 into an int refuses
    # (receiver lm_stg_convert_size_t_int) -- in a native method (l2_convert_on_store) and at the walked root
    # (l2_rw_convert); without the edge C converts and the program sends 7.
    [pscustomobject]@{ Name = 'unit_local_init_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_init_conv_root.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # Through a callable formal, bare and called, by its contract (native: a callable formal keeps a method out of the
    # walk).  A Structure-typed place: the bare name is its call there too, refused exactly as `b: mk()`.
    [pscustomobject]@{ Name = 'unit_local_init_callable_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_init_graph_place_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_local_init_graph_place_refused.lm2:15:5: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    # Its explicit-reference sibling (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): `@: Box b; b: mk` binds after the
    # admission of mk's result to Box; an Other of another shape is refused -- the implicit throw `implements` stops R0.
    [pscustomobject]@{ Name = 'unit_local_init_graph_ref_admit_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # OPUS-BODYSEG-20260929-05 (the 7b-3 path rule one level down; L2 §10 `M\for\y`; Q51): after a method's name, and
    # after a body root, the names go on through bodies, each named by its statement's head (l2_body_seg) -- natively
    # one hop into the body's Structure at its child slot, walked an OF.  unit_body_seg_method + walk twin: M\while\j
    # read from outside after M (20, at the root and from another method), written from outside (77), `if\while\j` in N
    # after the if's `end` -- the place before a boundary publishes j (0), after it (21).  The walk twin pins that M,
    # peek and N are walked (no native word).
    [pscustomobject]@{ Name = 'unit_body_seg_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_seg_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_m0_tr)', 'l2_m1_tr)', 'l2_m3_tr)'); Debt = @() },
    # A later body declares no such field: refused where it stands, the walked root in the check's words.  A body not
    # yet written where the path stands (forward and down, as a root body): refused.
    [pscustomobject]@{ Name = 'unit_body_seg_absent_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_body_seg_absent_refused.lm2:13:4: unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_body_seg_position_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_body_seg_position_refused.lm2:7:12: unknown field path segment'; Absent = @(); Debt = @() },
    # A method-rooted path of more than one name is one path in every value position (l2_path_chain_check): M\b\v as a
    # `return:` value and a call's actual read the Box field -- it was the call of M with `\b\v` written out raw after
    # it, C that did not compile.  The emitter refuses a path the check would refuse (M\k\q, as a `return:` value), and
    # the method-root branch says an absent field at its name (it read a pointer it never set: the translator died).
    [pscustomobject]@{ Name = 'unit_path_chain_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_chain_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_chain_return_refused.lm2:11:13: unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_method_absent_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_method_absent_return_refused.lm2:11:15: unresolved name'; Absent = @(); Debt = @() },
    # OPUS-PATHCHECK-20260929-06: a value that is one whole path is checked to its last name (l2_check_fields returned
    # "checked" once the path's ROOT resolved; `return: b\q` went on to the emitter, whose read failed without a word --
    # exit 3), in the field check's own words and places: a single hop at the name it cannot find ("unresolved name"),
    # a deeper path at its start ("unknown field path segment") -- so six earlier refusals moved there (the two
    # body_path_absent rows, the two q52 rows, body_seg_position, s7_part_node_src).  And a `return:` value where the
    # result is a number or a char is of that kind (l2_check_ret_kind): a text or a Box returned from an int method
    # compiled and ran, the launch exiting with the pointer's value.  The trailer route and a statement `return:` both.
    [pscustomobject]@{ Name = 'unit_ret_path_segment_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ret_path_segment_refused.lm2:10:15: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ret_path_segment_stmt_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ret_path_segment_stmt_refused.lm2:9:19: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ret_text_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ret_text_refused.lm2:5:13: return value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ret_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ret_struct_refused.lm2:10:17: return value has incompatible type'; Absent = @(); Debt = @() },
    # OPUS-INDEXNUM-20260929-07: an index after a name bound to a number (int, char, size_t, unsigned, ulong) is refused at
    # the bracket -- the field check skipped every bracket atom, and `x: q[0]` / `return: q[0]` went out as C indexing an
    # int (l2trans exit 0, gcc "subscripted value is neither array nor pointer").  An Array field's element is taken
    # before (unit_array_*); a pointer's and the c.* door's index are not this check's.
    [pscustomobject]@{ Name = 'unit_index_num_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_index_num_refused.lm2:8:9: an index on a number: only an Array field is indexed'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_index_num_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_index_num_return_refused.lm2:4:14: an index on a number: only an Array field is indexed'; Absent = @(); Debt = @() },
    # OPUS-VALKIND-20260929-08: a text or a Structure where a number is consumed is refused where it stands, natively as
    # the walk already refuses it (its rule -179: a reference stands only where its own type is asked -- beside it only 0;
    # "a reference where a number is asked", "a reference compared with a number other than 0"; a text is no number).
    # Each of these compiled and RAN, the launch exiting with a pointer's value (`if: b = 3` without even a warning):
    # an operand, a condition, a formal's actual, a declaration.  unit_valkind_ref_ok: what stands -- a reference
    # compared with a reference and with 0, a callable formal in arithmetic (its call), a char literal.
    [pscustomobject]@{ Name = 'unit_valkind_op_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_op_ref_refused.lm2:12:8: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_cond_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_cond_ref_refused.lm2:11:13: a reference compared with a number other than 0'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_op_text_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_op_text_refused.lm2:11:8: a text where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_arg_text_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_arg_text_refused.lm2:10:18: a text where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_arg_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_arg_ref_refused.lm2:11:18: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_decl_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_valkind_decl_ref_refused.lm2:11:12: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_valkind_ref_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # OPUS-PATHWRITE-20260929-09: a write through a path to a number field checks its one value's kind as any number
    # place does (l2_check_path_write) -- nothing typed a path write's value, and `b\v: "x"`, `M\x: b` RAN, storing a
    # pointer into the int.  unit_pathwrite_ok: numbers through a Box field and a method's field from outside.
    [pscustomobject]@{ Name = 'unit_pathwrite_text_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_pathwrite_text_refused.lm2:9:10: a text where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathwrite_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_pathwrite_ref_refused.lm2:14:10: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathwrite_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # OPUS-PATHCONV-20260929-10: a write through a path, natively -- a number of another type has the store's conversion
    # edge, as a write to an own field has (l2_convert_value_to; the check notes the edge, a pair with no row is refused
    # as an assignment's): -1 into a size_t through `b\z` or `M\s` stored SIZE_MAX and went on, now the receiver refuses,
    # the method's convert, R0 stopped -- as the walked root already did (unit_pathconv_root_range pins it); and the
    # target's cell is kept while the value is evaluated (`b\v: c\v` stored into c's cell).
    [pscustomobject]@{ Name = 'unit_pathconv_ok.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathconv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathconv_method_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathconv_root_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathconv_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_pathconv_norow_refused.lm2:9:5: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pathwrite_cell_kept.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # OPUS-WALKLOOP-20260929-11: loops in the walk.  `a && b` / `a || b` are the walker's AND / OR, one value,
    # short-circuit: the flag cell and its flag steps are gone -- a loop ran the flag step again at the end of its body,
    # so a `continue` left the condition stale (the root and a walked method gave 10, 65; natively 5).  unit_walk_sc_short
    # pins the short-circuit: boom is called twice, no more.  And the core `for` is the walker's FOR, the step after each
    # turn, a `continue` too: a method with a `for` is walked under the knob (it stayed native; the Absent pins), the
    # book's for\j program walked (above); the root's `for` stops at its counter, a field declared in a nested body.
    [pscustomobject]@{ Name = 'unit_walk_sc_continue.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_sc_continue_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_sc_continue_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_sc_short.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('boom', 'boom');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_for_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_for_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m3_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m4_tr)'); Debt = @() },
    # WalkRoot executes the SAME artifact twice: native, then through its graph.
    [pscustomobject]@{ Name = 'unit_root_for_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6; WalkRoot = $true;
        Absent = @(); Debt = @('c.LMX_WALK_OP_FOR, 4U)', 'c.LMX_WALK_OP_OWN_OF, 3U)', 'c.LMX_WALK_OP_SET_OF, 4U)') },
    [pscustomobject]@{ Name = 'unit_root_hosted_controls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @('c.LMX_WALK_OP_FOR, 4U)', 'c.LMX_WALK_OP_WHILE, 3U)', 'c.LMX_WALK_OP_OWN_OF, 3U)', 'c.LMX_WALK_OP_SET_OF, 4U)') },
    [pscustomobject]@{ Name = 'unit_root_deepif70.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @('c.LMX_WALK_OP_IF, 3U)') },
    [pscustomobject]@{ Name = 'unit_root_hosted_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @('c.LMX_WALK_OP_PAD') },
    # OPUS-Q54-TRAILER-20260929-13 (the author, Q54): an anonymous block closed by `until` is a postcondition loop in
    # the enclosing activation -- natively a `while` whose later turns begin with the condition (a first-turn flag),
    # walked the walker's UNTIL.  The block ran once before (its `until:` was read nowhere) and a break or continue in
    # it was refused.  Each witness: the count, a body that runs once though the condition holds, a continue that goes
    # to the condition, a break.
    [pscustomobject]@{ Name = 'unit_until_block_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_until_block_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_until_block_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # OPUS-Q54-TRAILER-20260929-13 checkpoint 2 (the author, Q54 and its clarification): a named Structure is declared by
    # general head resolution (book §9, :559-:565) -- a head that resolves to nothing, with a Structure tail -- whatever
    # closes it, and neither it nor a sub needs a closer or a return.  Declaring runs nothing (hits 0), a call runs the
    # body (the unit's cell hits, written by an explicit path, read back by peek).  Counter (no closer, an executable
    # first item) was refused ("unknown field path root"); readLoop closed by `until` -- a procedure whose body is the
    # postcondition loop, hits 3 -- was refused ("unsupported trailer"); the sub with no return ran already (a positive
    # witness).  A literal declares nothing: `x: 7` stays "unresolved name".  The walked twins: every method walked.
    [pscustomobject]@{ Name = 'unit_ns_noclose_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_noclose_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_ns_noclose_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_sub_noreturn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_sub_noreturn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_until_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_until_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_ns_until_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_decl_literal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_decl_literal_refused.lm2:4:1: unresolved name'; Absent = @(); Debt = @() },
    # OPUS-Q54-CONTINUE-20260929-14 slice 1, corrected by the call rule (ticket 15; book §9 after 55c1abc): in a method,
    # f declared by `f()` is typed by the empty Structure its declaration gives, and a later `f()`, `f: ()` or bare `f`
    # is its nullary call -- the empty Structure's call runs nothing: no admission (pinned absent), nothing thrown, so
    # the method is walked under the knob (pinned) -- 7, also in an `if:` body.  A bare `f` made f a dynamic input before
    # and refused the declaration: the free-name scan registers f now.  A method's field of a named Structure type --
    # `S: fresh` -- is callable too; its call, S's body over it, is not built in a method yet: refused where it stands,
    # as its bare atom is (slice 1 had `fresh()` the assignment with admission: 74).
    [pscustomobject]@{ Name = 'unit_empty_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('LMX_IMPLEMENTS_YES'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_empty_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('LMX_IMPLEMENTS_YES', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_call_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('LMX_IMPLEMENTS_YES'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_model_var_call_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_model_var_call_method_refused.lm2:11:5: executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    # The empty type's edges: a field typed by an empty named Structure is called as the empty Structure is -- nothing
    # runs: 7; one closed by `until` runs its loop at a call (Q54), a method's Structure-typed field's call: refused.
    [pscustomobject]@{ Name = 'unit_empty_type_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_until_type_call_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_until_type_call_method_refused.lm2:8:5: executing a named Structure is not supported yet'; Absent = @(); Debt = @() },
    # Ticket 15, slice 2a corrected by the call rule: `T: value` with T an existing named Structure is T's call with the
    # value -- a Structure of fields, in a method or at the root, a number, another named Structure (the author's
    # `Model: Other`, in a method), a name bound before (Codex: when Model and m both exist, `Model: m` calls Model with m; before,
    # the second `Model: m` in a method declared m again, and at the root after `int: m` it was "incompatible entry
    # signature") -- never the assignment with admission slice 2a made of it.  A named Structure's call with an
    # argument is not built yet: refused where it stands, the implementation's status, not a rule of the language.
    [pscustomobject]@{ Name = 'unit_ns_call_arg_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_method_refused.lm2:8:5: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_lit_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_lit_refused.lm2:6:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_number_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_number_refused.lm2:5:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_name_refused.lm2:10:5: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_bound_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_bound_refused.lm2:9:5: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_bound_root_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_bound_root_refused.lm2:6:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    # OPUS-Q54-CONTINUE-20260929-14 slice 2b-1: a method's own named Structure -- `S:` + number fields, S resolving to
    # nothing there -- declared by the general route (book §9: an absent target with an explicit Structure value).  At
    # run time only its Structure exists: built at its statement, a child of the method's own Structure (pinned), bound
    # at S's slot -- no unit child (Absent) -- and each execution builds a new one (94; one kept would give 99).  The
    # walk takes no method with one (pinned native).  A field that is no number and no char is refused where it stands
    # (char fields since 2c-5, statements since 2c-2, below).
    [pscustomobject]@{ Name = 'unit_local_ns_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_nsp[0]: lmx_struct_new_owned'); Debt = @('lmx_struct_new_owned(self, l2_program_arena)') },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_nsp[0]: lmx_struct_new_owned'); Debt = @('lmx_struct_new_owned(self, l2_program_arena)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)') },
    # (2c-4: S declared in a body is that body's child -- its parent is the Structure that holds its slot, book §2.)
    [pscustomobject]@{ Name = 'unit_local_ns_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_nsp[0]: lmx_struct_new_owned'); Debt = @('lmx_struct_new_owned(l2_h0, l2_program_arena)') },
    [pscustomobject]@{ Name = 'unit_local_ns_fresh.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 94;
        Absent = @(); Debt = @() },
    # Slice 2c-1: the method executes its own named Structure -- `S()`, `S: ()`, the bare `S` -- S's procedure (§12), a
    # method after the entry E with no unit child, its occurrence S itself: built at S's statement with the
    # procedure's trampoline as its native word, run by lmx_call_prim(S, S) (both pinned), so `node` in S's body is the
    # method's occurrence.  Each call stores S's initializer again: 4 after each, though 9 was written (was
    # unit_local_ns_call_refused).  Declared in an `if:` body and executed there and from a block: the procedure's
    # fields are S's, not the body's.  Under the knob the method stays native (pinned) and the procedure is never
    # walked.
    [pscustomobject]@{ Name = 'unit_local_ns_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('l2_t0\native: (cast: (LmxEntry) l2_m2_tr)', 'lmx_call_prim(l2_program_arena, (cast: (@: Lmx) l2_q7), (cast: (@: Lmx) l2_q7), 0, 0U, 0, @ l2_nso0)') },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_t0\native: (cast: (LmxEntry) l2_m2_tr)') },
    [pscustomobject]@{ Name = 'unit_local_ns_call_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Slice 2c-2: S's statements run at its calls, in its procedure, never at its declaration (book :928) -- w 0 after
    # it, then 14 and, after `k: 20`, 24: k is a hidden input the method passes (§12).  Under the knob the method stays
    # native and the procedure unwalked (pinned).  S's statements are checked whether or not S runs (a free name nobody
    # binds, refused where it stands).  Control bodies: 2c-3; `node`: 2c-4, below.
    [pscustomobject]@{ Name = 'unit_local_ns_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)') },
    [pscustomobject]@{ Name = 'unit_local_ns_stmt_unresolved.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_local_ns_stmt_unresolved.lm2:7:12: unresolved name'; Absent = @(); Debt = @() },
    # Slice 2c-3: S's control bodies are Structures of its occurrence, built with S at its statement (R9) -- the `if:`
    # body with a cell for its field t: w 0 after the declaration, 10 after `S()` (was unit_local_ns_ctl_refused);
    # under the knob the method stays native (pinned); S declared in the method's `while:` gets new bodies each pass:
    # 15. A char field -- S's own or declared in its control body -- has its own stable typed cell:
    # 'z' written, 'a' after `S()`; the body's d
    # 'z' steers its `if:`: 5 (was unit_local_ns_ctl_char_refused).
    [pscustomobject]@{ Name = 'unit_local_ns_ctl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_ctl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)') },
    [pscustomobject]@{ Name = 'unit_local_ns_ctl_loop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_char.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_char_rebind_known'); Debt = @('lmx_char_new_owned(l2_program_arena)', 'lmx_char_store_known') },
    [pscustomobject]@{ Name = 'unit_local_ns_ctl_char.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_char_rebind_known'); Debt = @('lmx_char_new_owned(l2_program_arena)', 'lmx_char_store_known') },
    # Slice 2c-4: `node` in S's body is S's parent, the Structure that holds S's slot -- the method's occurrence, or the
    # body's Structure S is declared in (book §2; pinned: S built as that body's child).  `node\k` reads and writes the
    # graph; calling S is a publication boundary, so the method's marked `k: 5` is published first: 5, then 6 (were the
    # two `node` refusals of 2c-2).  In a body, `node\b` is b declared in it: 4, then 5.  Refused where they stand: a
    # field of the method from S declared in a body (no field of that body), and the method's formal (its args part).
    [pscustomobject]@{ Name = 'unit_local_ns_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)') },
    [pscustomobject]@{ Name = 'unit_local_ns_node_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_struct_new_owned(l2_h0, l2_program_arena)') },
    [pscustomobject]@{ Name = 'unit_local_ns_node_outer_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_local_ns_node_outer_refused.lm2:9:21: unresolved name'; Absent = @(); Debt = @() },
    # A cast to a primitive type is a value of that type for an assignment's single value (l2_colon_simple_ty): it was
    # refused "assignment value has unknown type" in any method.  In a method, through `node`, and in a method's own
    # named Structure through `node`: 7 each.
    [pscustomobject]@{ Name = 'unit_cast_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_cast_node_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_node_cast.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_node_formal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_local_ns_node_formal_refused.lm2:6:17: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_kind_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_local_ns_kind_refused.lm2:4:5: a field of this kind in a named Structure declared in a method is not built yet'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_char_own_publish.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_forward_oneline.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 0;
        Args = @('0');
        Absent = @();
        Debt = @('return: l2_p0_0 + 1') },
    [pscustomobject]@{ Name = 'unit_forward_mismatch.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_forward_import_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'not callable'; Absent = @(); Debt = @() },
    # Q8 = U2 (plan §3, "the order of the unit's declarations"; implemented in S2, f6f213a -- this is
    # its row): a declaration is an entry statement at its place; the unit's own cells exist from
    # construction, zero until their statements run.  f, declared below x and y, reads them; its call
    # above their declarations reads 0, below them 5 + 6 = 11 (a literal and an expression
    # initializer alike).  Natively and with f walked.
    [pscustomobject]@{ Name = 'unit_decl_order_u2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_decl_order_u2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # GROK-PREGATE-20260922-01. Needles and Debt are measured on the live translator
    # (HEAD 4da4658 / gate l2trans). Colon updates with no qualified roots run under
    # the driver with 0 roots; graph/const/type refusals stay l2trans-refuses.
    [pscustomobject]@{ Name = 'unit_colon_callable_receiver.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 1; Ints = @(7); InputKinds = @('int'); ResultKind = 'int'; });
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'merge');
        # The callee publishes the passed 7 to ping\observed; a dropped call cannot pass.
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # GROK-UNIVERSAL-RESOLUTION-PARTA-20260922-03. Three call forms must share one
    # physical METHOD op; an existing int is assigned (§7b: SET of its working value). Debt/Absent distinguish that.
    [pscustomobject]@{ Name = 'unit_universal_head_resolution.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 3; Ints = @(7); InputKinds = @('int'); ResultKind = 'int'; });
        GraphShapes = @([pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 2 }) } }) });
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'merge');
        Debt = @() },
    # One logical negative fixture, three TUs: l2trans reports only the first
    # diagnostic. Needle is the converged class for every representable form.
    [pscustomobject]@{ Name = 'unit_universal_absent_paren.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_universal_absent_paren.lm2:4:1: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_colon.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_universal_absent_colon.lm2:4:1: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_vertical.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_universal_absent_vertical.lm2:5:1: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_existing_value_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # Book §12, L2 §18.2 (re-expected by name, 7b): after the call the root's bare shared keeps its working value 4 --
    # the caller is not reloaded -- and read_parent's node\shared sees the 9 (was: the bare read saw 9).
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
    # Book §12 (7b, by name): these four read the written value back through read_shared's node\shared -- the root's
    # bare shared keeps its working value after the call, not reloaded.
    [pscustomobject]@{ Name = 'unit_node_path_nested_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 2U)',
                 'l2_h1: lmx_arena_ref_struct(self, 3U)',
                 'lmx_arena_ref_cell(l2_h1, 0U)',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 3U)',
                 'lmx_arena_ref_cell(l2_h0, 0U)',
                 'while: l2_t0',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # §7b (7b-1): `hosted` is the for body's field with a working value -- `int: hosted 4` writes l2_q1 and
    # marks it, and the exit publishes it into the host's cell 1; c3b-1's in-place store is Absent.
    [pscustomobject]@{ Name = 'unit_nested_body_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,', 'lmx_int_store_known(l2_q1_from[0], (4))');
        Debt = @('l2_h0: lmx_arena_ref_struct(self, 2U)',
                 'lmx_arena_ref_cell(l2_h0, 1U)',
                 'l2_q1: (4)',
                 'if: lmx_int_store_known(l2_q1_from[0], (l2_q1)) != 0',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_own_not_node.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    # Book §12 (7b, by name): peek reads bump's write through node\shared; E's own bare shared keeps its working
    # value 3 after the call (97 if it were reloaded).
    [pscustomobject]@{ Name = 'unit_node_root_unit_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
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
    # §7b (7b-1; book §12: «a same-activation `for\j: 42` writes the graph cell, not the cache»): `j` has
    # a working value, so after `for\j: 42` the bare `j` still reads 9 while the path reads 42 -- the first
    # c.printf published j = 9 and a clean j is not written back.  c3b-1's `42 42` (no working copies,
    # 2649ee7a) is withdrawn with the model it stood on.
    [pscustomobject]@{ Name = 'unit_forj_stale.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('9', '9 42');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_root_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 0;
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_formal_value.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Entry = 5; Needle = '';
        Args = @('0');
        Absent = @(); Debt = @() },
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
    # Implements port slice 2 (A2; the author's q37: the formal as in his example, `op(fn: (int: x) int)`):
    # a callable formal whose contract is its header written in place -- registered as the
    # descriptor-only method `apply(op)`, as a bodiless `fn:` named in `(test3: f)` is.  `apply(inc 10)`
    # = 11; `add` of two inputs refused at the call (13:5); `op` called with two inputs refused at that
    # call -- before A2 the same phrase was said at the header, so the needles pin the places; since the named
    # actuals (steps/named-actuals.md) a call's arity is the binding's, said at the extra actual (9:22).
    # Mutants: the header not a contract -- all three red (refused at the header); the contract not
    # made the formal's -- "unknown method", all three red; the header's inputs unread -- the witness
    # and the arity row red.
    [pscustomobject]@{ Name = 'unit_callable_anon.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_anon_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:13:5: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_anon_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:9:22: more arguments than op has formals'; Absent = @(); Debt = @() },
    # D-106 (REVIEW eb60712, fable_pc's P42): a top-level method `op` of two inputs beside `apply`'s
    # callable formal `op(fn: (int: x) int)` -- inside `apply` the formal is meant (apply(inc 10) = 11),
    # outside the method (op(1 2) = 103).  The gated translator took the method inside `apply` and refused
    # op(value) (16:13); with the method of the formal's own signature it called the method silently.
    # Mutants: the check asks the method first -- refused 16:13; the emission asks it first -- the
    # translation fails.
    [pscustomobject]@{ Name = 'unit_callable_anon_named_clash.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-106's fifth site, the typing of `int: t op(value)` (REVIEW 59c74b3, fable_pc's M44/P44): the
    # top-level `op` returns size_t, the formal an int (-1).  Mutant M44 (the typing asks the method
    # first) -- the int taken for a size_t is converted to int and the conversion throws: exit 1.
    [pscustomobject]@{ Name = 'unit_callable_anon_named_clash_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # D-107 (REVIEW 59c74b3, fable_pc): the unit's first method `zz (int: a; int: b) size_t` -- the
    # interner's self-check took it for its probe (two int inputs a, b, an int result) by two names and
    # one type and refused the unit.  Mutant: the name check back -- refused.
    [pscustomobject]@{ Name = 'unit_intern_first_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # COMPACT-RAWFIELD-BATCHA-72: raw_fld=5 call without form-COMPACT. Debt pins emitted
    # raw-field ccall. Absent is unused (empty proves nothing; no genuine form-gate
    # leftover string appears in generated L1). `translates` catches
    # checker/emitter divergence (refuse vs missing Debt).
    [pscustomobject]@{ Name = 'unit_rawfield_compact.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('l2_p0_0\zz(1)') },
    [pscustomobject]@{ Name = 'unit_rawfield_colon.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('l2_p0_0\zz(1)') },
    # COMPACT-FNPTR-BATCHC-76: ty40 callable-first in all forms; decl+init via type head.
    [pscustomobject]@{ Name = 'unit_fnptr_decl_init.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f(l2_p0_0\alloc)');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_compact.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_colon.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_vertical.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f: l2_p0_1');
        Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_arg_compact.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('L2TestAllocFn: f l2_p1_0\alloc', 'f(l2_p1_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_arg_colon.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @();
        Debt = @('L2TestAllocFn: f l2_p1_0\alloc', 'f(l2_p1_1)') },
    # After CALL-ARGS-CLOSE: empty ty40 args are zero-args (call_args); arity admission still open.
    # Former 'unsupported body' refuse was the empty-Structure stand-in; now translates as f().
    [pscustomobject]@{ Name = 'unit_fnptr_call_sig_refuse.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('unsupported body'); Debt = @('f()') },
    # §7b (7b-1): `x: 7` writes the working value and marks it; c3b-1's in-place store is Absent.
    [pscustomobject]@{ Name = 'unit_fnptr_noncallable_assign.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('lmx_int_store_known(l2_q0_from[0], (7))');
        Debt = @('l2_q0: (7)', 'l2_q0_dirty: 1') },
    # FABLE-GROKBOT-CALL-ARGS-20260922-92: paren-group call args via l2_call_args
    [pscustomobject]@{ Name = 'unit_call_args_empty_paren.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_empty_vertical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_paren_seq.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 3; NativeRoot = 1;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 2; Count = 1; Ints = @(1, 2); InputKinds = @('int', 'int'); ResultKind = 'int'; });
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_controls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; }, [pscustomobject]@{ Method = 1; Arity = 2; Count = 2; Ints = @(1, 2); InputKinds = @('int', 'int'); ResultKind = 'int'; });
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_control_split.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 2; Count = 1; Ints = @(1, 2); InputKinds = @('int', 'int'); ResultKind = 'int'; });
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_refuse_nested.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:7:4: add has no argument b'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_call_args_refuse_named.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:4:9: add has no argument b'; Absent = @(); Debt = @() },
    # Superseded by FABLE-SONNET-EMPTY-STRUCT-20260923-132: `mystruct: ()`
    # now declares an empty Structure instead of refusing as an unresolved
    # call (see the fixture's own header comment).
    [pscustomobject]@{ Name = 'unit_call_args_refuse_struct.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_paren.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f((l2_p0_1))');
        Debt = @('f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_forms.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f((l2_p0_1))');
        Debt = @('f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_nullary_stmt.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f(())', 'unsupported body');
        Debt = @('f()') },
    [pscustomobject]@{ Name = 'unit_fnptr_call_args_nullary_value.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('f(())', 'unsupported body');
        Debt = @('f()') },
    [pscustomobject]@{ Name = 'unit_puts_method_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @('c.puts("from-method")') },
    [pscustomobject]@{ Name = 'unit_puts_main_beside_method.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0');
        Absent = @(); Debt = @() },
    # COMPACT-DECL-BATCHB-75: struct local form-independent; float refuse form-independent;
    # opposite controls for fnptr call and ordinary call.
    [pscustomobject]@{ Name = 'unit_struct_decl_colon.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_struct_decl_compact.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_struct_decl_vertical.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @(); Debt = @('BatchBPoint: p') },
    [pscustomobject]@{ Name = 'unit_float_refuse_colon.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'by-value float local not yet implemented'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_float_refuse_compact.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'by-value float local not yet implemented'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_struct_decl_opp_fnptr_call.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        Absent = @('BatchBPoint:', 'f: l2_p0_0\alloc'); Debt = @('L2TestAllocFn: f l2_p0_0\alloc', 'return: f(l2_p0_1)') },
    [pscustomobject]@{ Name = 'unit_struct_decl_opp_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args=@('0'); Entry=7;
        NativeCalls = @([pscustomobject]@{Caller=1; Method=0; Throwing=$false; ResultType='int:'; ResultUse='(?m)^\s*return: {result}\s*$'; Args=@([pscustomobject]@{Type='int:'; Value='^1$'})});
        Absent = @(); Debt = @() }
    [pscustomobject]@{ Name = 'unit_colon_hidden_update.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # S2: the unit's `Model: fresh` is an own field of the entry E, registered by the same
    # recognizer every method uses (l2_own_add(E, ...)), so the unit declares it again.
    [pscustomobject]@{ Name = 'unit_colon_model_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    # FABLE-SONNET-EMPTY-STRUCT-20260923-132: the three empty-Structure
    # declaration spellings, name absent.
    [pscustomobject]@{ Name = 'unit_empty_struct_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_struct_hanging_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; ErrorLines = 0;
        Needle = 'empty colon Frame is not allowed'; Absent = @(); Debt = @() },
    # P50 (REVIEW ee58ce4): an input that does not exist is refused in its own line, "cannot read the
    # source" -- counted, so the guard adds no "internal: a refusal said nothing" and exit 3 (it did: the
    # line was printed and not counted).  The row above pins the same for a P0 diagnostic.  Mutant: the
    # line not counted -- this row red (one "l2trans error:" line, not 0).
    [pscustomobject]@{ Name = 'unit_p50_missing_input.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Missing = 1; ErrorLines = 0;
        Needle = ': cannot read the source'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_struct_existing_nonstruct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_typed_decl_vertical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    # OPUS-Q54-CONTINUE-20260929-14, re-expected by the call rule (ticket 15; book §9 after 55c1abc): a second `Model:`
    # meets the binding the first declared, a callable -- Model's call with that Structure as its argument, not built
    # yet: refused where it stands (was "duplicate named Structure", then "assignment target must be...", then the
    # admission's refusal).
    [pscustomobject]@{ Name = 'unit_duplicate_named_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_duplicate_named_struct_refused.lm2:9:1: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_method_lexical_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw0, c.LMX_WALK_OP_CALL, 5U)', 'if: lmx_arena_ref_store(l2_rw2, 1U, (cast: (@: void) lmx_arena_ref_struct(l2_entry_unit, 2U))) != 0',
                 'lmx_merge_owned(l2_mops, 1U, l2_mbody, node, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_method_dynamic_precedence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        # forward remains unexecuted legacy compatibility, not a dispatch oracle.
        NativeCalls = @([pscustomobject]@{Caller=1; Method=0; Throwing=$true; ResultType='int:'; ResultUse='(?m)^\s*l2_out_result\[0\]: {result}\s*$'; Propagation='forward'; Args=@()});
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('lmx_merge_owned(l2_mops, 1U, l2_mbody, node, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_method_fresh_per_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('lmx_merge_owned(l2_mops, 1U, l2_mbody, node, l2_program_arena, l2_program_arena, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_own_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: l2_nsp[', 'lmx_merge_owned(l2_mops, 1U, l2_mbody, l2_nsp[') },
    [pscustomobject]@{ Name = 'unit_field_path_nested_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: l2_nsp[', 'lmx_merge_owned(l2_mops, 1U, l2_mbody, l2_nsp[') },
    [pscustomobject]@{ Name = 'unit_field_path_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    # The walked root's typed reference (OPUS-CALLABLE-STRUCT-BINDING-20260929-16, step 1): `@: Model p` / `p: @fresh` at
    # the unit level runs -- p an own field of the unit, a pointer cell, bound after admission; it was refused as an L2
    # operation. p is nonnull and exactly @fresh: 7, in native and actual root-walk execution.
    [pscustomobject]@{ Name = 'unit_field_path_unit_addr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 0; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # `@: Model r` at the walked root, a pointer cell null until `r: @v` binds it after the admission of v's Structure to
    # Model (implements, the native admission's predicate): a Model's own read and written through r, 7; the letter,
    # and a Structure of another shape, refused by the admission at run time -- the implicit throw `implements`.
    [pscustomobject]@{ Name = 'unit_root_ref_bind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_ref_letter_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_ref_other_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # A method's typed reference `@: Model r` (its local, D-76) is rebound only after the native admission of the value to
    # Model (l2_emit_admit: the interim structural lmx_runtime_implements, consumer Model -- the predicate the walked
    # root's admission calls): a Model's own is admitted too, no shortcut (pinned: the admission is emitted), 7; an Other
    # of another shape is refused -- the method's implicit throw `implements`, uncaught, stops R0.  It was a plain store.
    [pscustomobject]@{ Name = 'unit_ref_rebind_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_ref_rebind_other_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # A reference formal `@: Model v` is rebound the same way (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): a Model is
    # admitted, no shortcut (pinned), read through v: 7; an Other is refused, the implicit throw stops R0.  It was a plain
    # store.  A value formal `Model: v` is callable: `v: w` its call, refused where it stands -- told apart by the
    # declaration; the row also holds the const test's bound (it read heap garbage for this formal's code).
    [pscustomobject]@{ Name = 'unit_ref_formal_rebind_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_ref_signature_synonyms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_structure_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Whole Array values and addresses retain their independently observed descriptor.
    [pscustomobject]@{ Name = 'unit_array_value_projection.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_value_pointer_elements.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_element_pointer_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_element_pointer_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_value_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_value_char_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_value_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_indexed_expression_span.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_path_actual_span.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_hidden_address_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_hidden_address_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_indexed_lazy_reads.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; LazyArrayReads = 5;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_indexed_actual_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_backing_actual_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_indexed_actual_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_actual_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_pointer_actual_const_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_indexed_initializer_extra_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_array_descriptor.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_index_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_index_formal_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_index_scalar_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_index_dynamic_scalar_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_array_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_array_char_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_array_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_reference_cell.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    [pscustomobject]@{ Name = 'unit_address_reference_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'reference depth does not match the receiving contract'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_reference_frame_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'reference depth does not match the receiving contract'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_formal_descriptor.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_address_callable_formal_descriptor.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ref_formal_rebind_other_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_value_formal_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_value_formal_call_refused.lm2:12:5: a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_path_unit_colon.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.LMX_WALK_OP_DEREF');
        Debt = @('c.LMX_WALK_OP_PUT_OF, 4U)', '@: Lmx l2_rw0 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_SET, 3U)', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_field_path_unit_qualified.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 0;
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
    [pscustomobject]@{ Name = 'unit_field_path_terminal_checklist.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    # FABLE-SONNET-DECL-PREPASS-20260923-137 part 2 (Opus's finding 1): a
    # named-Structure method return, non-throwing and declared-throw ABI,
    # a discarded call and a nested-call value round-trip witness.
    [pscustomobject]@{ Name = 'unit_struct_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_struct_return_assign_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a call of a named Structure with an argument is not built yet'; Absent = @(); Debt = @() },
    # Its explicit-reference sibling (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): `@: Model b; b: other(a)` binds after the
    # admission of the call's result to Model; an Other of another shape is refused -- the implicit throw stops R0.
    [pscustomobject]@{ Name = 'unit_struct_return_ref_admit_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # FABLE-SONNET-DEFECTS-20260924-141 D-15: an int: field in a named
    # Structure goes through the same field-kind table as size_t (kind 7) --
    # own declaration, a nested path, a formal parameter and a merge copy
    # all read/write it through the ordinary machinery.
    # FABLE-OPUS-DISCARD-20260924-147: until the builder gave kind 7 its cell this row was vacuous
    # (the first write met an empty slot and a silent bail returned 0 from E); success is now 7.
    # D-05/D-06: a field path meeting no Structure, an own field without a cell, a method entered
    # without its occurrence, a missing control body and a failed checkpoint are invariants on the
    # X1 route (a message and an abort), never a return from the method or a printed line.
    # -193 T3: the root merge `copy: merge: Model` runs, so the row runs; the pins of the native E
    # body's own-field, control-body and checkpoint invariants rotted while it was root-pending (the
    # root has been walked only since -159) and are gone -- the methods keep theirs.
    [pscustomobject]@{ Name = 'unit_struct_int_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_msg_poll_abort', 'lmx: checkpoint',
                   "if: self = 0`n        return", "if: self = 0`n        l2_out_result",
                   "if: l2_h0 = 0`n        return", "if: l2_pst = 0`n        if: l2_q",
                   "if: l2_pxp = 0`n        if: l2_q", "if: l2_xp = 0`n        if: l2_q");
        Debt = @('lmx_int_store_known(l2_entry_slot[0], 1)', 'lmx_int_store_known(l2_entry_slot[0], 2)',
                 'c.fprintf(c.stderr, "lmx: invariant: a field path met no Structure\n")',
                 'c.fprintf(c.stderr, "lmx: invariant: a method was entered without its occurrence\n")') },
    # Every numeric field of a named Structure -- size_t, int, unsigned, ulong -- has its own cell
    # holding its literal, in the Structure and in a merge copy (FABLE-OPUS-DISCARD-20260924-147).
    [pscustomobject]@{ Name = 'unit_struct_num_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('lmx_int_store_known(l2_entry_slot[0], 4)', 'lmx_unsigned_store_known(l2_entry_slot[0], 5U)',
                 'lmx_ulong_store_known(l2_entry_slot[0], 6U)', 'lmx_size_store_known(l2_entry_slot[0], 3U)') },
    # The same four kinds on an eternal branch: cells of their own primitive type in the branch's
    # exact sealed profile, holding their literals (the driver's numeric root facts).
    [pscustomobject]@{ Name = 'unit_eternal_num_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
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
    # D-88: a predef result type is read from its prototype, never stood in for by the numeric-
    # literal class: an unreadable `fn` result is an unknown type at the store.  The stand-in is not
    # reached on this path; the translator before D-88 refused the call as "unsupported body".
    [pscustomobject]@{ Name = 'unit_predef_result_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has unknown type'; Absent = @(); Debt = @() },
    # D-89: a literal written through a field path fits the field, as an ordinary assignment's does.
    # Mutant (no range check): the size_t field stores 0 and the program runs on.
    [pscustomobject]@{ Name = 'unit_path_lit_overflow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'literal not representable as size_t'; Absent = @(); Debt = @() },
    # D-97: a path off a formal, a slot or a method local of a primitive pointer type -- no
    # Structure type, no c.* door -- is refused, located. Mutant (the translator before D-97):
    # all three are accepted and emitted as C member accesses (`l2_p0_0\length`, `l2_s0_0\data`,
    # `q\data`), which only gcc refuses.
    [pscustomobject]@{ Name = 'unit_path_formal_primitive_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path root'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_slot_primitive_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ':5:15: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_local_primitive_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ':5:15: unresolved name'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_lm_own_actual_span.lm2'; Expect = 'root-pending'; Exit = 0; Needle = 'root operation not walkable yet: a call with an input that is not a number';
        Absent = @(); Debt = @() },
    # FABLE-SONNET-OWN-LOOKUP-AUDIT-20260923-131 part 3: the -92 leftover --
    # a Structure value assigned through a path ending at a nested
    # Structure-typed field stays a located, fail-closed refusal.
    # -183 (q26): a whole Structure assigned through a path to a Structure-typed field stays
    # fail-closed at the root, a located refusal (fable's interim ruling), until the author answers q26
    # (merge in place / rebind / refusal).
    [pscustomobject]@{ Name = 'unit_field_path_struct_rebind_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'root operation not walkable yet: a Structure assigned through a path'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_c_member_struct_control.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    # FABLE-GROKBOT-RAW-MEMBER-ROOT-AND-7A-CLOSE-20260923-126 part1: raw root only for c.*.
    # Mutant: restore ty>=100 alone in l2_ty_raw_c_members -> Model compound emits wrong access.
    [pscustomobject]@{ Name = 'unit_raw_root_model_compound.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_raw_root_formal_compound.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst:', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_local_model_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    # Q52 cancels this row's Q9 reading (7b, by name): the unit fields a method writes bare stay 5 at their place of
    # declaration, read through gx, gy, gz (node\x); within bump_and_read the activation reads its own 8.
    [pscustomobject]@{ Name = 'unit_field_write_from_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # steps/free-names.md §7 (REVIEW 7124005): a method above a unit field's declaration does not see the field
    # (backward visibility), so the name is free: the root's field at the call is its hidden argument, and a bare
    # write changes its value in the method's activation, declaring nothing (bafca4c; 7b, re-read by name, value
    # unchanged) -- the unit field stays 5.  The read mirror reads it the same
    # way.  (Before: unit_field_write_below_refused, "assignment target must be a declared typed mutable value".)
    [pscustomobject]@{ Name = 'unit_field_write_below_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_field_write_below_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_read_below.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_field_read_below.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Q52 (7b, by name): foo's hits and last are its hidden inputs -- each call form is observed in what foo prints,
    # `foo 1 5`, `foo 1 6`, `foo 1 7` (the unit's fields cached in foo and published back would print 1, 2, 3).
    [pscustomobject]@{ Name = 'unit_callable_priority.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('foo 1 5', 'foo 1 6', 'foo 1 7');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_priority_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:14:6: more arguments than bar has formals'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_model_fresh_synonyms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_decl_unknown_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_decl_unknown_type_refused.lm2:5:1: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_slot_structure_projection.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 2 / D-25: three orphan @:
    # depth/formal fixtures, measured -- each translated but never called
    # its own witness function, so a broken address write would have
    # passed silently either way. Completed with a real call and assertion
    # rather than rewritten from scratch (the shapes were already correct).
    [pscustomobject]@{ Name = 'unit_addr_arg.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_depth.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_take.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # D-53: `h\q: @mo` -- `@` of an own Structure field is the reference its slot holds, as its load
    # is; h\q is non-null, `@mo` and `mo` itself.  Success is 7 (it was 0, an empty witness).
    [pscustomobject]@{ Name = 'unit_ns_ref_field_general.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @();
        Debt = @() },
    # D-76: a reference `@: T` to a named Structure is one level, `@: Lmx` -- its value is the Structure
    # -- and a path goes through it: a local (main: unknown field path root), a formal (main: refused
    # write, raw `->` read), a reference field (main: refused write).  Each reads and writes through
    # the reference; success is 7.
    # D-69: a char formal's cell in the method's `args` part is the program's interned char, so the
    # char table (process_chars) and lmx_chars_owned's predef come with it (main: gcc, both undeclared).
    # D-77: char result uses the same word as a char formal. Mutant: drop the
    # depth-0 char arm of l2_ret_type_word → this row refuses "unknown type".
    # C99 char result: the trampoline writes the caller's owned typed result cell.
    # q/z execution, formal extraction, result-cell references and root-native attachment all remain checked.
    [pscustomobject]@{ Name = 'unit_char_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); NativeRoot = 2;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 2; InputKinds = @('char'); ResultKind = 'char'; }, [pscustomobject]@{ Method = 1; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('\out: lmx_char_cell_known'); Debt = @(') char', 'lmx_char_store_known(dest,', '(cast: (char) lmx_char_value_known(refs[0]))', 'lmx_char_new_owned(l2_program_arena)') },
    [pscustomobject]@{ Name = 'unit_char_formal_parts.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @('l2_entry_slot[0]: lmx_char_cell_known(process_chars, 0)'); Debt = @('lmx_chars_owned.h.lm1', '@: char process_chars lmx_chars_new_owned(l2_program_arena)', 'l2_entry_slot[0]: lmx_char_new_owned(l2_program_arena)') },
    [pscustomobject]@{ Name = 'unit_ref_local_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @('@@: Lmx r'); Debt = @(); NativePatterns = @('(?s)@: Lmx (?<ref>l2_q\d+)\s+\k<ref>: \(cast: \(@: Lmx\) lmx_pointer_value_known\(\k<ref>_from\[0\]\)\).*?@: Lmx (?<constructed>l2_t\d+) lmx_struct_new_owned\(self, l2_program_arena\).*?(?<model>(?!\k<ref>\b)l2_q\d+): \(cast: \(@: Lmx\) \(\(cast: \(@: void\) \k<constructed>\)\)\).*?@: Lmx (?<candidate>l2_t\d+) \k<model>\s+.*?int: (?<admission>l2_admission\d+) c.LMX_IMPLEMENTS_YES.*?(?<pending>l2_pending\d+)\.value: \(cast: \(@: Lmx\) \k<candidate>\)\s+\k<pending>\.req: (?<required>lmx_arena_ref_struct\(node, \d+U\)).*?\k<admission>: lmx_implements_walk_view\(l2_program_arena, \(cast: \(@: Lmx\) \k<candidate>\), \k<required>, \k<required>, @ \k<pending>, 0\).*?\k<admission>: lmx_implements_register_map\(l2_program_arena, \(cast: \(@: Lmx\) \k<candidate>\), \k<required>,.*?if: \k<admission> != c.LMX_IMPLEMENTS_YES.*?return: 2\s+\k<ref>: \(cast: \(@: Lmx\) \(\k<candidate>\)\).*?l2_pst: \k<model>.*?lmx_size_store_known\(l2_pxp\[0\], 9U\).*?l2_pst: \k<ref>.*?lmx_size_value_known\(l2_pxp\[0\]\).*?l2_pst: \k<ref>.*?lmx_size_store_known\(l2_pxp\[0\], 11U\).*?l2_pst: \k<model>.*?lmx_size_value_known\(l2_pxp\[0\]\)') },
    [pscustomobject]@{ Name = 'unit_ref_formal_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @('@@: Lmx l2_p'); Debt = @('@: Lmx l2_p0_0') },
    [pscustomobject]@{ Name = 'unit_ref_field_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @(); Debt = @('l2_pst: (cast: (@: Lmx) lmx_pointer_value_known(l2_pxp[0]))') },
    [pscustomobject]@{ Name = 'unit_addr_entry_name_collision.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # FABLE-SONNET-ARRAY-ADDR-20260924-144 D-21: `@` on a bare own-array
    # element addresses the real backing (l2_emit_array_ptr), both directly
    # and through an explicitly supplied element-pointer formal (no Array decay).
    [pscustomobject]@{ Name = 'unit_addr_own_array_element.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        Absent = @();
        Debt = @() },
    # D-24: `@ buf[i] + n` / `- n` is the element pointer. A store through it
    # reaches the element. Entry 7, not 0.
    [pscustomobject]@{ Name = 'unit_addr_own_array_arith.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7;
        Absent = @();
        Debt = @() },
    # D-22 / D-24: the same arithmetic returned as int is a pointer landing
    # in a numeric target (ex-address_array_element_sum.lm2).
    [pscustomobject]@{ Name = 'unit_addr_own_array_arithmetic_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_addr_unknown_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown type'; Absent = @(); Debt = @() },
    # Original source retained: its own declaration is below the free-name
    # use, not in beta's lexical parent. Q8 does not grant this binding.
    # The valid parent/caller counterpart is unit_site_parent_fallback.
    [pscustomobject]@{ Name = 'unit_dyn_hidden_from_cross_method.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_dyn_hidden_from_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_dyn_hidden_from_undeclared_refused.lm2:7:39: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_find_last_sizeof.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
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
        NativePatterns = @('(?ms)(?<cell>l2_q\d+)\\length:.*?3U.*?if: \k<cell>\\length != 3U');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'unsupported body');
        Debt = @('l2_entry_unit: graph') },
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
        Needle = 'unit_csizeof_type_frame_refused.lm2:5:19: unresolved addressable name'; Absent = @(); Debt = @() },
    # FABLE-OPUS-P0-SIZEOF-ATOM-20260924-157: a private buffer's element size through the sizeof:
    # receiver, `sizeof(unsigned)`, lowered as L1's single-word `c.sizeof(unsigned)`.  Success is 7.
    [pscustomobject]@{ Name = 'unit_ptr_grow.lm2'; Expect = 'root-pending'; Exit = 0; Entry = 7; Needle = 'root operation not walkable yet: a call with an input that is not a number';
        Args = @('0'); Absent = @(); Debt = @() },
    # FABLE-OPUS-P0-SIZEOF-ATOM-20260924-157 commit 2: P0 keeps no raw `c.sizeof(...)` atom, so an L2
    # operand of the door is lowered like any door operand -- an own int x becomes a temp -- where
    # the raw atom passed the name `x` to C ("x undeclared").  Success is 7.
    [pscustomobject]@{ Name = 'unit_csizeof_operand_lowered.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.sizeof(x)');
        Debt = @('return: c.sizeof(l2_t') },
    [pscustomobject]@{ Name = 'unit_sizeof_own_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_native_activation.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'L2 operation outside a method body';
        Args = @('0'); Absent = @(); Debt = @() },
    # Q55: only translation, not an executable test of C undefined behavior.
    [pscustomobject]@{ Name = 'unit_array_write_root_out_of_range.lm2'; Expect = 'translates'; Exit = 0;
        Needle = ''; Absent = @(); Debt = @('[5U]') },
    [pscustomobject]@{ Name = 'unit_array_write_general_root_no_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_array_write_general_root_real_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_undeclared_refused.lm2:2:5: unresolved name'; Absent = @(); Debt = @() },
    # missing_value is a free name no caller binds: "unresolved name" at the name (l2_dyn_typed), before the
    # assignment's check, which waits for the name's type (steps/free-names.md M2).
    [pscustomobject]@{ Name = 'unit_colon_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_unknown_value_refused.lm2:2:10: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_incompatible_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    # Historical filename: const protects the referent, while its explicit pointer cell may rebind.
    [pscustomobject]@{ Name = 'unit_colon_graph_const_target_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); Absent = @(); Debt = @('lmx_runtime_implements(') },
    # The same for a graph target: missing_graph is unresolved, said at the name (steps/free-names.md M2).
    [pscustomobject]@{ Name = 'unit_colon_graph_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_graph_unknown_value_refused.lm2:2:12: unresolved name'; Absent = @(); Debt = @() },
    # Historical filename: named-model admission succeeds before binding; a refusal preserves the old binding.
    [pscustomobject]@{ Name = 'unit_colon_graph_update_admission_blocked.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); Absent = @(); Debt = @('lmx_runtime_implements(') },
    # Two identical full qualifier occurrences get distinct physical profile identities.
    # Plain in the same file stays mutable/unprofiled and is not a qualified root.
    [pscustomobject]@{ Name = 'unit_eternal_physical_profiles.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('2', 'size', '0', '0', '7', 'size', '1', '0', '7');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 2',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 'l2_eprofile1: lmx_node_new_profiled(l2_program_arena, l2_entry_unit)',
                 'if: l2_eprofile0 = l2_eprofile1',
                 'l2_entry_unit: graph') },
    # Filename says refused: the merge result is an ordinary Structure (not a third
    # qualified root). The translator emits merge_profiles_owned and both operands
    # remain exported roots. This is not an l2trans refusal.
    # -199 + -202 (K2b): the root's merge of qualified branches is the walker's primitive, which
    # retains each branch by its own profile (Sonnet's selftest tells retention from copy); the
    # native merge_profiles call is gone from the root.  Success 7 (it was 0).
    [pscustomobject]@{ Name = 'unit_eternal_multi_profile_merge_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('2', 'size', '0', '0', '1', 'size', '1', '0', '1');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'l2_retained', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('[]: @(Lmx) l2_program_qualified_roots 2',
                 'l2_program_qualified_roots[0U]: l2_nsp[0]',
                 'l2_program_qualified_roots[1U]: l2_nsp[1]',
                 '\fn: lmx_walk_merge_map',
                 'l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_eternal_profile_partial_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'independent branch requires const'; Absent = @(); Debt = @() },
    # Compiler-side implements over named Structure field lists and hosted primitive leaves.
    # Receiving-model runtime admission and reference rebinding have independent witnesses above.
    [pscustomobject]@{ Name = 'unit_implements_methods.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_primitives.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_namespace.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_argument.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_assignment.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_implements_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    # S7 slice 1: cand = req still succeeds after l2_descriptor_implements.
    # Mutant: that function returns 1 when cand = req → this row refuses
    # "malformed implements descriptor".
    [pscustomobject]@{ Name = 'unit_s7_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # S7 empty uses: zero paths succeed inside l2_descriptor_used.
    # Mutant: that function returns 1 before the zero-path success →
    # this row refuses "malformed implements descriptor".
    [pscustomobject]@{ Name = 'unit_s7_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # S7 nonempty uses: only the read path is the Consumer. Plain lacks
    # Equatable\extra and still runs. Mutant: l2_descriptor_used returns 1
    # → this row and unit_s7_identity refuse "malformed implements descriptor".
    [pscustomobject]@{ Name = 'unit_s7_used.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # 64 used paths still run. The 65th is a located refusal. Mutant: leave
    # l2_uses_full unset → unit_s7_uses65 translates.
    [pscustomobject]@{ Name = 'unit_s7_uses64.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_uses65.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'a uses list is full'; Absent = @(); Debt = @() },
    # Nested used path and leaf kind. Mutant: stop after the first segment
    # → unit_s7_nested_missing translates. Mutant: skip the kind compare
    # → unit_s7_leaf_kind translates.
    [pscustomobject]@{ Name = 'unit_s7_nested_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Other is not Outer. Identity does not admit this row; the nested
    # shape does. Unread extra is not required.
    [pscustomobject]@{ Name = 'unit_s7_nested_shape.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_nested_missing.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_leaf_kind.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    # A call result and a field path are the same admit point as an atom.
    # Mutant: l2_actual_ns treats a call frame as not a Structure actual
    # → unit_s7_arg_call_refused translates.
    [pscustomobject]@{ Name = 'unit_s7_arg_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_arg_call_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_arg_path.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    # span 5: take(h\a\p). The leaf Structure is admitted, not the root.
    # Mutant: l2_actual_path returns 2 for span > 3 → the refusal is
    # "no located diagnostic" and the Entry 7 row does not translate.
    [pscustomobject]@{ Name = 'unit_s7_arg_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_arg_deep_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_path.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in return value'; Absent = @(); Debt = @() },
    # A return's Consumer is the required descriptor. Callers are not in the body.
    # Mutant: l2_admit_return returns 0 before the descriptor call
    # → unit_s7_ret_name translates.
    [pscustomobject]@{ Name = 'unit_s7_ret_name.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in return value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_call.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in return value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_body.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in return value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_rich.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Named primitive value codes call l2_primitive_leaf_implements.
    # Mutant: same-name success stores 0 → unit_s7_prim_same refuses.
    # Mutant: cross-leaf success stores 0 → unit_s7_prim_cross refuses
    # and unit_s7_prim_same still translates.
    # The cross row is convert.lm2 size_t → int, receiver lm_stg_convert_size_t_int: since Q33 an
    # ordinary method of the unit from convert_impl.lm2, pinned by its range test.
    [pscustomobject]@{ Name = 'unit_s7_prim_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # implements-port slice 11 (B2; q36): the conversion table is read by the names of its columns.
    # A table with its columns reversed (impl ... from, every row with them) is the same table:
    # unit_s7_prim_cross over it is still Entry 7.  A table without its receiver column is refused by
    # name.  Mutant: rows read by position -- the reversed table matches no row; the refusal row is
    # refused in other words.
    [pscustomobject]@{ Name = 'unit_s7_conv_columns.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_conv_columns_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_nocolumn.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_nocolumn_table.lm2';
        Needle = 'conversion table has no column receiver'; Absent = @(); Debt = @() },
    # REVIEW f2a1578 (fable_pc's M37: no row went red without the partial-row check; P37: without it a
    # partial row fell out silently): the table's other refusals, each over its own broken table and
    # pinned to its place -- a column named twice, a row short of a cell (said at `rows:`), a 33rd
    # column; since the receiver `table` (steps/table-receiver.md §5) in the receiver's words.  Rows
    # written before the columns were refused by the tree walk; `columns:` and `rows:` are named
    # arguments now, bound by their names (book §10): the same table, Entry 7.
    # Mutants: each check dropped -- exactly its rows red; named arguments bound by place -- rowsfirst red.
    [pscustomobject]@{ Name = 'unit_s7_conv_twice.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_twice_table.lm2';
        Needle = 'unit_s7_conv_twice_table.lm2:6:101: a table column is named twice'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_rowsfirst.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_conv_rowsfirst_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_partial.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_partial_table.lm2';
        Needle = 'unit_s7_conv_partial_table.lm2:8:5: table rows are not whole rows of its columns'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_wide.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_wide_table.lm2';
        Needle = 'unit_s7_conv_wide_table.lm2:6:549: a table has too many columns'; Absent = @(); Debt = @() },
    # Q43 (the author, 2026-09-27): a cell of `rows:` is an argument of any kind -- an atom, a Structure, an
    # array -- through the common gate of actuals (l2_expr_span), no exceptions; refusing a cell that is
    # not one atom is a bug.  A Structure cell and an expression cell are one cell each (the gated reading
    # dropped the Structure and split the expression, and refused the rows as not whole); a chosen row
    # whose receiver cell gives no name is said at that cell, when used; a seventh column of an unread
    # name (REVIEW daee4f7, P40) is kept and not read.  Mutants: a cell one field, not one actual --
    # cellexpr red; a non-atom not a cell -- cellstruct and cellneed red; no check at use -- cellneed
    # segfaults.
    [pscustomobject]@{ Name = 'unit_s7_conv_cellstruct.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_conv_cellstruct_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_cellexpr.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_conv_cellexpr_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_cellneed.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_cellneed_table.lm2';
        Needle = 'unit_s7_conv_cellneed_table.lm2:72:48: a conversion table cell this row needs is not a name (evaluating a table argument is not ported yet)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_extra.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_conv_extra_table.lm2';
        Absent = @(); Debt = @() },
    # REVIEW 914ae15 (fable_pc's M43/P43): a name only for a cell that is one atom holds for an expression
    # too -- the size_t -> int receiver written `lm_stg_convert_size_t_int + 0` is said at the cell.
    # Mutant M43 (the span check dropped: the first atom's name taken) -- accepted silently, red.
    [pscustomobject]@{ Name = 'unit_s7_conv_cellneed_expr.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_conv_cellneed_expr_table.lm2';
        Needle = 'unit_s7_conv_cellneed_expr_table.lm2:72:48: a conversion table cell this row needs is not a name (evaluating a table argument is not ported yet)'; Absent = @(); Debt = @() },
    # The receiver `table` (Q41, Q43; steps/table-receiver.md §5): `table:` is a call of the receiver; its
    # actuals are bound to its formals -- source, name, columns, rows, read from its header by the
    # method-formal parser -- by the book's rule for positional and named arguments (§10, l2_bind_actuals);
    # the source tables are those at the root whose body begins with `source`; the conversion asks for its
    # table and its columns by name, a quoted spelling the same name.  Witnesses: the table found by name
    # among two; quoted column names; a table without `source`, and one below the root, not the
    # translation's; an argument given twice, a formal without one, a name of no formal, a positional
    # argument after a named one, more positional ones than formals; two source tables of one name; an
    # empty `rows: ()`, an empty table (the tree walk refused it as not whole rows): no row converts.
    # Mutants (steps/table-receiver.md §5): each check dropped, the first table taken whatever its name,
    # names compared as written, a table without `source` taken, the tables below the root looked into --
    # exactly their rows red.
    [pscustomobject]@{ Name = 'unit_s7_tbl_named.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_tbl_named_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_quoted.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_tbl_quoted_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_runtime.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_runtime_table.lm2';
        Needle = 'unit_s7_tbl_runtime.lm2:9:5: the program has no source table `primitive.convert`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_nested.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_nested_table.lm2';
        Needle = 'unit_s7_tbl_nested_table.lm2:2:1: a named Structure in a program part is not supported yet (the program registers the named Structures of its source only)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_twice_arg.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_twice_arg_table.lm2';
        Needle = 'unit_s7_tbl_twice_arg_table.lm2:5:5: the argument name of table is given twice'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_noarg.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_noarg_table.lm2';
        Needle = 'unit_s7_tbl_noarg_table.lm2:2:1: table has no argument columns'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_unknown_arg.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_unknown_arg_table.lm2';
        Needle = 'unit_s7_tbl_unknown_arg_table.lm2:5:5: colums is not an argument of table'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_positional_after.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_positional_after_table.lm2';
        Needle = 'unit_s7_tbl_positional_after_table.lm2:137:5: a positional argument of table after a named one'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_toomany.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_toomany_table.lm2';
        Needle = 'unit_s7_tbl_toomany_table.lm2:7:5: more arguments than table has formals'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_twotables.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_twotables_table.lm2';
        Needle = 'unit_s7_tbl_twotables_table.lm2:141:11: two source tables have this name (the other at unit_s7_tbl_twotables_table.lm2:4:11)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_empty.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_empty_table.lm2';
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # REVIEW e682d71: every argument of `table` by position, the columns and the one row each a Structure --
    # bound as the named form is (M48: the positional-Structure branch of l2_arg_fields -- no gated row saw
    # it; this one does); a misspelt `colums:` before `name:` binds by position, and the words say so (P51);
    # a convert.lm2, and an impl source, that P0 refuses: the P0 diagnostic, located in that file and counted,
    # and the use site adds nothing (P54a -- it said only "cannot read ...").  Mutants: each change undone --
    # exactly its row red.
    [pscustomobject]@{ Name = 'unit_s7_tbl_positional.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'unit_s7_tbl_positional_table.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_posname.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_posname_table.lm2';
        Needle = 'unit_s7_tbl_posname_table.lm2:5:5: the argument name of table is given by position (colums:) and again by name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_unparsable.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Table = 'unit_s7_tbl_unparsable_table.lm2';
        Needle = 'unit_s7_tbl_unparsable_table.lm2:139:1: empty colon Frame is not allowed (P0 32)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_impl_unparsable.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Impl = 'unit_s7_conv_impl_unparsable_impl.lm2';
        Needle = 'unit_s7_conv_impl_unparsable_impl.lm2:52:1: empty colon Frame is not allowed (P0 32)'; Absent = @(); Debt = @() },
    # Slice 2 of the receiver `table` (steps/table-receiver.md §7): the primitive question asks
    # `primitive.description` of primitive.lm2 (lingvamyxa_prev's table, the 23 names the translator knew),
    # and the translator's tables are read at the start of every translation -- one rule for both.  A table
    # file that is not there (primitive.lm2; convert.lm2 too, for a source that converts nothing), a file
    # without its table or a column, one P0 refuses, one without a row for a type word of the translator:
    # refused once, at the start.  The table decides -- size_t with cell 0 does not implement int -- and a
    # cell the decision needs that gives no name is said at the cell, the translation failing with that one
    # line.  Mutants: each change undone -- exactly its row red.  (§8, slice 3: the tables are the program's,
    # asked by name when a question comes -- a program that asks nothing needs none, the two `absent` rows
    # run; a row's own table is a part under its own name, and its diagnostics name that file.)
    [pscustomobject]@{ Name = 'unit_s7_prim_table_absent.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Primitive = 'absent';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_table_absent.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Table = 'absent';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_nodesc.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_nodesc_prim.lm2';
        Needle = 'unit_s7_prim_table_nodesc.lm2:7:5: the program has no source table `primitive.description`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_nocol.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_nocol_prim.lm2';
        Needle = 'unit_s7_prim_table_nocol_prim.lm2:5:5: primitive table has no column cell'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_cell.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_cell_prim.lm2';
        Needle = ':8:5: assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_cellneed.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_cellneed_prim.lm2';
        Needle = 'unit_s7_prim_table_cellneed_prim.lm2:19:23: a primitive table cell this row needs is not a name (evaluating a table argument is not ported yet)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_unparsable.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_unparsable_prim.lm2';
        Needle = 'unit_s7_prim_table_unparsable_prim.lm2:33:1: empty colon Frame is not allowed (P0 32)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_norow.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_norow_prim.lm2';
        Needle = 'unit_s7_prim_table_norow_prim.lm2:2:1: primitive table has no row for size_t, a type word of the translator'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_implcell.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Primitive = 'unit_s7_prim_table_implcell_prim.lm2';
        Needle = 'unit_s7_prim_table_implcell_prim.lm2:24:23: a primitive table cell this row needs is not a name (evaluating a table argument is not ported yet)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_table_forbid.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Primitive = 'unit_s7_prim_table_forbid_prim.lm2';
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_prim_cross.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lm_stg_convert_'); Debt = @('> 2147483647U') },
    [pscustomobject]@{ Name = 'unit_s7_conv_norow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # Slice 3 of the receiver `table` (steps/table-receiver.md §8-9; the author, Q46: "таблица это тупо ресивер
    # table ... В ЛЮБОМ МЕСТЕ ПРОГРАММЫ"): the program is the source and the files named after it at the call;
    # its source tables are every `table:` with `source` first, in any of its files, at any depth; a
    # conversion's receiver is a method of the program, found by name.  The table in the source itself -- at
    # its root, in a method's body -- and at depth in a method of a part; two parts with one table name,
    # refused with both places; a program that converts with no conversion table, refused at the edge.  A
    # part gives methods, source tables and (§10, the block below) its root's fields and statements; a
    # method of a part reads its free names from its callers (the book :1182) -- m's own k, 9, not the
    # source's field k, 5 -- and one no caller binds is
    # unresolved at its read, in the part.  A `table:` without `source` is refused in its own words.
    # Mutants (steps/table-receiver.md §9, each by copy, both modes): tables only at a file's root -- the
    # method and part-depth rows red; the source's own tables unread -- the two in-source rows red; a part's
    # methods not collected -- the converting rows red (no receiver); fable_pc's: a part's method binding a
    # free name by name to the source's field -- the free-bound rows read 5, red; the primitive table
    # required at the start -- the absent row refused; a missing table said at 1:1 -- the nodesc row red;
    # two tables of one name without the other's place -- the dup-parts row red; the run-time words gone --
    # its row red; a part's root item skipped silently -- the §10 field rows red; the P59 fix undone -- the
    # else row red; the return trailer not searched -- the free-refused row red; said without the flags --
    # two lines, the cellneed and implcell rows red.
    [pscustomobject]@{ Name = 'unit_s7_tbl_in_source.lm2'; Table = 'absent'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_in_method.lm2'; Table = 'absent'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_part_depth.lm2'; Table = 'unit_s7_tbl_part_depth_part.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_dup_parts_refused.lm2'; Parts = @('unit_s7_tbl_dup_parts_second.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_tbl_dup_parts_second.lm2:4:11: two source tables have this name (the other at convert.lm2:3:11)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_table_asks_refused.lm2'; Table = 'absent'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:7:5: the program has no source table `primitive.convert`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_free_bound.lm2'; Parts = @('unit_s7_part_free_bound_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_s7_part_free_bound.lm2'; Parts = @('unit_s7_part_free_bound_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_free_refused.lm2'; Parts = @('unit_s7_part_free_bound_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_free_bound_part.lm2:4:9: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_runtime_src_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:4:1: a table built at run time is not supported yet'; Absent = @(); Debt = @() },
    # §10 (steps/table-receiver.md; REVIEW a582309 with fable_pc's three conditions): a part's root is a
    # Structure of the program with no name -- its fields built with their initializers, its statements the
    # body of its procedure, checked and never executed -- and the lexical parent, `node`, of the part's
    # methods, which reach the program's unit through l2_program_unit.  Witnesses: a part's method reads its
    # part's k, 5 (through another method, and as node\k), writes 6 and reads 6, the root's `k: 7U` not
    # executed, in both modes (the walked read through the root pinned); two parts' k's apart, and the
    # source's own; the source's method reading a part's field, a part's root statement reading the source's
    # field or its named Structure, a part's method reading node\got where only the source declares got --
    # each refused where it reads, in its file: no binding across files, and the last said while the method
    # is written, in the part; an unknown Structure type of a part's root field, said at it, in the part; a
    # part's root field named as a method, refused as a unit field is; a part's root field written by a
    # method above its declaration, refused as a unit field is (REVIEW dcc5fd3: fable_pc's M53, which drops
    # the place check, reddens it); a callable field naming a part's
    # method, its occurrence checked against that root; a run-time table at a part's root, a statement of its
    # procedure; a directive, the os block and a qualified branch at a part's root, refused in the words of
    # their registration; a forward declaration in a part, bound in its own file -- a part is read against
    # its own root.  REVIEW 70f869c's accounts: a table in a named Structure's body; a part's method
    # reading the source's named Structure, unresolved; one method name in two files, said with the other's
    # place.  A library executes no statements, its source's or a part root's (Library: --library).
    # Mutants (steps/table-receiver.md §11, each by copy, every row of the block in both modes): the part's
    # method's occurrence left the unit's child -- the field rows red; the unit through node -- the native
    # field rows crash; the root's initializers not built -- the field rows red; the root's procedure run at
    # the start -- peek reads 7, red; the nameless entry found by any name -- every unit field collides, eight
    # rows red; a part's method blind to its root -- the field rows red; the root's procedure reading the
    # source by place -- the ns row accepted; that and the field check both dropped -- the src row binds the
    # source's total (either alone is masked by the other); node\x through E -- the node row accepted; the
    # walked holder the unit, or the walker not reaching the root -- the twin's pin red (and the walked
    # values); the callable field checked against the unit -- refused at the start; a colliding field
    # accepted, a reference said at the source's first statement, a diagnostic said in its pass's file, a
    # library taking a part's root, a part read against the source's root, a duplicate without the other's
    # place -- each its own row red.
    # Q52 (7b, by name): k is a hidden input of the part's methods, bound at the root's call by the callee's lexical
    # source, the part root's 5 (a walk that named it in the unit read the unit's field 0 -- fixed); bump's write
    # stays its own, so peek reads 5 after it (was 6).  unit_s7_part_root_two: peekA and peekB take the source's k,
    # 1 -- the caller's binding comes first (book §12) -- while nodeA and nodeB read their roots' 5 and 8 explicitly.
    [pscustomobject]@{ Name = 'unit_s7_part_root_field.lm2'; Parts = @('unit_s7_part_root_field_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_s7_part_root_field.lm2'; Parts = @('unit_s7_part_root_field_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('(cast: (@: void) l2_nsp[0])) != 0 || lmx_walk_store_size') },
    [pscustomobject]@{ Name = 'unit_s7_part_root_two.lm2'; Parts = @('unit_s7_part_root_two_a.lm2', 'unit_s7_part_root_two_b.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_callable_field.lm2'; Parts = @('unit_s7_part_root_field_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_forward.lm2'; Parts = @('unit_s7_part_forward_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_hidden.lm2'; Parts = @('unit_s7_part_root_field_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_hidden.lm2:6:9: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_src_refused.lm2'; Parts = @('unit_s7_part_root_src_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_src_refused_part.lm2:4:4: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_below_refused.lm2'; Parts = @('unit_s7_part_root_below_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_below_refused_part.lm2:4:5: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_ns_refused.lm2'; Parts = @('unit_s7_part_root_ns_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_ns_refused_part.lm2:4:4: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_node_src_refused.lm2'; Parts = @('unit_s7_part_node_src_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_node_src_refused_part.lm2:6:13: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_type_refused.lm2'; Parts = @('unit_s7_part_root_type_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_type_refused_part.lm2:4:8: unknown nested Structure reference'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_collide_refused.lm2'; Parts = @('unit_s7_part_root_collide_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_collide_refused_part.lm2:3:1: method collides with a unit field'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_tbl_runtime_refused.lm2'; Parts = @('unit_s7_part_tbl_runtime_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_tbl_runtime_refused_part.lm2:3:1: a table built at run time is not supported yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_directive_refused.lm2'; Parts = @('unit_s7_part_directive_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_directive_refused_part.lm2:2:1: a directive in a program part is not supported yet (the program reads the directives of its source only)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_os_refused.lm2'; Parts = @('unit_s7_part_os_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_os_refused_part.lm2:2:1: the os block in a program part is not supported yet (the program reads the os block of its source only)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_branch_refused.lm2'; Parts = @('unit_s7_part_branch_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_branch_refused_part.lm2:3:1: a qualified branch in a program part is not supported yet (the program registers the qualified branches of its source only)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_tbl_in_struct.lm2'; Table = 'absent'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_ns_hidden.lm2'; Parts = @('unit_s7_part_ns_hidden_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_ns_hidden_part.lm2:4:9: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_dup_method_refused.lm2'; Parts = @('unit_s7_part_dup_method_refused_part.lm2', 'unit_s7_part_dup_method_refused_second.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_dup_method_refused_second.lm2:3:1: duplicate definition (the other at unit_s7_part_dup_method_refused_part.lm2:3:1)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lib_stmt_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Library = $true;
        Needle = 'unit_lib_stmt_refused.lm2:5:1: a library unit executes no statements'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lib_part_root_refused.lm2'; Parts = @('unit_lib_part_root_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0; Library = $true;
        Needle = 'unit_lib_part_root_refused_part.lm2:2:1: a library unit executes no statements'; Absent = @(); Debt = @() },
    # D-83: a converter's refusal is the implicit throw `convert` (g = 3), not c.abort() and not 0.
    # Uncaught it reaches the root: no value, Message stopped, status 3.  Caught, the handler runs
    # and the destination keeps its value.  Mutant: a body without its range test -- the first row
    # completes with 7, the second skips the handler with 3.
    # Q33: the receiver is an ordinary method of the unit taken from convert_impl.lm2 (throws: range);
    # the edge calls it and turns its refusal into the caller's `convert`.  No converter is an L1
    # function spelled by the translator any more.
    [pscustomobject]@{ Name = 'unit_s7_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @('lmx: converter range', 'fn: lm_stg_convert_'); Debt = @('> 2147483647U') },
    [pscustomobject]@{ Name = 'unit_s7_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx: converter range', 'fn: lm_stg_convert_'); Debt = @('< 0') },
    # Slices 3/4 boundary (Opus, 2026-09-27): a composite store (`a: b + 1U`) now gets the same edge.
    [pscustomobject]@{ Name = 'unit_s7_conv_compound.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_conv_compound_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # Q33: a row whose receiver has no fn: in its impl source refuses at the edge.  The row's own
    # convert_impl.lm2 is tests\unit_s7_conv_nobody_impl.lm2, which has no lm_stg_convert_size_t_int.
    [pscustomobject]@{ Name = 'unit_s7_conv_nobody.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Impl = 'unit_s7_conv_nobody_impl.lm2';
        Needle = 'unit_s7_conv_nobody.lm2:9:5: the program has no method `lm_stg_convert_size_t_int`, the receiver of this conversion'; Absent = @(); Debt = @() },
    # REVIEW 38fe8b8-1: a receiver is checked as a method of the impl source it came from, so a
    # refusal inside its body names convert_impl.lm2 (and that file's line), not the program.
    # Mutant: collect and check receivers with the program's path -- the same refusal names
    # unit_s7_conv_badbody.lm2:6:9, a line of a different file.
    [pscustomobject]@{ Name = 'unit_s7_conv_badbody.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Impl = 'unit_s7_conv_badbody_impl.lm2';
        Needle = 'unit_s7_conv_badbody_impl.lm2:6:9: throw of an undeclared name'; Absent = @(); Debt = @() },
    # implements-port slice 3 (A3, arguments; steps/implements-port-plan.md): a value of one named
    # primitive type given to a formal of another calls the row's receiver on it, as a store does
    # (l2_check_arg_convert, l2_emit_arg_convert) -- a direct call and a callable formal's call
    # alike; the receiver's refusal is the caller's implicit throw `convert`.  Mutants (copies
    # under build/): the edge not emitted -- _range completes with 7 and _catch skips its handler
    # with 1, both RED by run; no argument check -- _norow is accepted.
    [pscustomobject]@{ Name = 'unit_s3_arg_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lm_stg_convert_'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s3_arg_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s3_arg_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Slices 3/4 boundary (Opus, 2026-09-27): a composite argument (`n - 1`) now gets the same edge.
    [pscustomobject]@{ Name = 'unit_s3_arg_conv_compound.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s3_arg_conv_compound_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s3_arg_conv_norow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # The shared conversion producer now retains both take and go. Execute the
    # same artifact through native root and actual walked root; status 3 stays visible.
    [pscustomobject]@{ Name = 'unit_walk_methods_s3_arg_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; WalkRoot = $true; WalkedMethods = @(0,1); Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # implements-port slice 4 (A3, return): one value of a named primitive type returned from a
    # callable whose result is another calls the row's receiver on it (l2_check_ret_convert,
    # l2_emit_ret_convert), in a body and in a trailer alike; the receiver's refusal is the
    # callable's implicit throw `convert`, which its caller catches by that name.  Mutants (copies
    # under build/): the edge not emitted -- _range and its WalkMethods twin complete and _catch
    # skips its handler, RED by run; no return check -- _norow is not refused with its phrase.
    [pscustomobject]@{ Name = 'unit_s4_ret_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lm_stg_convert_'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Slices 3/4 boundary (Opus, 2026-09-27): a composite return (`b + 1U`) now gets the same edge.
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_compound.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_compound_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # Opus's check on unit_merged_callable's own shape (REVIEW 12195ef, follow-up): the same edge
    # and catch, but M is a shared occurrence (A: fn: M) called through a merge result (R\M()), not
    # a plain name() -- the edge lives inside M's own body, so it does not care how M was reached.
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_merge_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # fable_pc's own check on REVIEW 12195ef: unit_s4_ret_conv_range.lm2 exercises a body-field
    # return; this is the SAME out-of-range value as the method's own trailer (l2_check_ret_tr's
    # own path, not l2_check_body's), so a mutant dropping l2_check_ret_convert specifically inside
    # l2_check_ret_tr (visible only in L1 today) goes RED by run here too.
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_range_trailer.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s4_ret_conv_norow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_methods_s4_ret_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; WalkMethods = $true; WalkRoot = $true; WalkedMethods = @(0); Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # implements-port B3, a declaration's initializer: `size_t: s (x)` with an int x calls the row's
    # receiver on the value as a store does (l2_check_init_convert, l2_emit_init_convert), bare, in
    # parentheses or compound.  Mutants (copies under build/): the edge not emitted -- _range completes,
    # RED by run; no initializer check -- _norow refused with another phrase, RED.
    [pscustomobject]@{ Name = 'unit_b3_init_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_b3_init_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_b3_init_conv_norow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # implements-port slice 13 (B3, the root): at the walked root a value of one named type given to
    # a place of another -- an own, a call's formal, a message field; a single value or a compound
    # one -- calls the row's receiver on it (l2_rw_convert); every status the receiver leaves with is
    # the root's `convert` (l2_rw_catch_edge: renumbered, or caught by `catch: convert ()`).  A
    # receiver only the walk names is taken by a second translation (l2_emit_unit returns 3).
    # Mutants (copies under build/): the rows not written -- _range notes the receiver's 1, _catch
    # goes uncaught; no second translation -- _compound refuses.
    [pscustomobject]@{ Name = 'unit_s13_root_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s13_root_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s13_root_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s13_root_conv_compound.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s13_root_conv_norow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
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
    # bafca4c (the author, 2026-09-28; 7b, by name): the bare assignments of the argument `arg` declare nothing, and
    # `\[N]` numbers declarations -- \[0]arg is refused where it stands.  (Q29 made them one cell, \[0]arg = 2.)
    [pscustomobject]@{ Name = 'unit_occ_arg_slots.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_occ_arg_slots.lm2:9:13: no such occurrence'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_arg_second_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'no such occurrence'; Absent = @(); Debt = @() },
    # D-27: \[N] numbers declarations. One `int: x`, then two bare stores, is still one cell;
    # \[0]x reads 20. A following line that starts with `\` is that statement, not the tail of `x: 20`.
    [pscustomobject]@{ Name = 'unit_occ_local_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_local_second_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'no such occurrence'; Absent = @(); Debt = @() },
    # FABLE-SONNET-OCC-ROOT-20260924-146 commit 1: a named (method) root's
    # occurrence index, test\[N]arg, resolved through l2_own_find_occ --
    # the same lookup the rootless \[N]arg form already uses, no second
    # scanner.  bafca4c (7b, by name): an argument has no place of declaration, so test\[0]arg is refused at the
    # walked root (was eternal-runs, Q29's one cell); declared occurrences: unit_q24_repeated_decl.lm2.
    [pscustomobject]@{ Name = 'unit_occ_root_named.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_occ_root_named.lm2:18:13: no such occurrence'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_root_out_of_range_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'no such occurrence'; Absent = @(); Debt = @() },
    # FABLE-SONNET-LAST-OCCURRENCE-20260924-164: unqualified test\arg is the
    # LAST occurrence of a repeated plain own field (not argument-bound, so
    # first-vs-last is the only thing deciding the read) -- test\[N]arg still
    # counts in declaration order; a write through the unqualified name lands
    # on the last occurrence too.  bafca4c (7b, by name): the argument's bare assignments declare nothing, and
    # test\[0]arg from check is refused where it stands (was eternal-runs, Q29's one cell); declared occurrences
    # through a method root, read and written: unit_q24_repeated_decl.lm2.
    [pscustomobject]@{ Name = 'unit_own_last_occurrence.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_own_last_occurrence.lm2:28:20: no such occurrence'; Absent = @(); Debt = @() },
    # 7b-2 (by name; ticket OPUS-7B2-20260929-01): the declaration makes the argument's same-name field a declared
    # field with a working value -- BEFORE: poked parameter 7 carried, `ba: 1` published, the graph write 100 changes
    # the cell only: BEFORE 1 100; AFTER: `@af` is the cell, the working value 1 stays: AFTER 1 100 (both were
    # 100 100 in place); NONE lines unchanged.  Pins: the carry into the working value, and `@af` after it is the cell.
    [pscustomobject]@{ Name = 'unit_occ_sticky_selector.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('BEFORE 1 100', 'AFTER 1 100', 'NONE 7 100', 'NONE 7 100', 'NONE+ 1 1');
        Absent = @('_sticky', '_active', 'if: lmx_int_store_known(l2_q1_from[0], (l2_p3_0)) != 0');
        NativeCalls = @([pscustomobject]@{Method=1; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) \(cast: \(@: int\) l2_q\d+_from\[0\]\)\)$'})});
        Debt = @('l2_q1: (l2_p3_0)') },
    # bafca4c (7b, by name): bt and al are declared fields now (an argument has no place of declaration).  poke's
    # pointer is the place of declaration (Debt: l2_qN_from[0], the author 2026-09-28); after poke9 the bare al keeps
    # its working value 2 -- `LAST 2`, was 9 -- and the root reads after_last\al 9 at the place of declaration.
    [pscustomobject]@{ Name = 'unit_occ_snapshot_selector.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('BETWEEN 2', 'LAST 2');
        Absent = @('_sticky', '_active');
        NativeCalls = @([pscustomobject]@{Method=0; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) \(cast: \(@: int\) l2_q\d+_from\[0\]\)\)$'})}, [pscustomobject]@{Method=1; Throwing=$false; ResultType='int:'; Args=@([pscustomobject]@{Type='@: void'; Value='^\(cast: \(@: void\) \(cast: \(@: int\) l2_q\d+_from\[0\]\)\)$'})});
        Debt = @('if: l2_q0 != 2') },
    # D-79, read under bafca4c: a bare assignment creates no field -- scoped's `x: 7` inside `if` writes the parameter,
    # so after the body x is 7: 77.  nested's `int: y` is the declaration that makes y a field (7b-2: carried into the
    # working value); `y: y + 10` inside `if` writes that same field: 1414.  Success is exit 7.  7b-2: y's field has a
    # working value now (the dirty flags exist; Absent keeps _sticky only).
    [pscustomobject]@{ Name = 'unit_arg_bind_body_scope.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('_sticky'); Debt = @('l2_q2: (l2_p1_0)') },
    # Same declared occurrence: keep(1) publishes7; keep(0) skips the declaration
    # and leaves that physical cell7. Both observations give77; no fresh data graph.
    [pscustomobject]@{ Name = 'unit_fresh_instance_skipped_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 77;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 2; InputKinds = @('int'); ResultKind = 'int'; }, [pscustomobject]@{ Method = 1; Arity = 0; Count = 1; InputKinds = @(); ResultKind = 'int'; });
        Absent = @('lmx_fresh(', 'l2_new0'); Debt = @() },
    # Universal publication: local result123, innermost published x0, outer y12;
    # callable-formal seven publishes s7. No recursion tracking or fresh graph.
    [pscustomobject]@{ Name = 'unit_recursive_fresh_instance.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 1; Count = 2; InputKinds = @('int'); ResultKind = 'int'; }, [pscustomobject]@{ Method = 2; Arity = 1; Count = 1; InputKinds = @('descriptor'); ResultKind = 'int'; });
        Absent = @('lmx_fresh(', 'l2_new0', 'l2_self: ', 'l2_reent', '_act:'); Debt = @('if: lmx_call_prim(l2_program_arena, l2_c0, l2_c0, 0, 0U, ') },
    # Legacy implicit Model:b compatibility witness, pending known-head call cleanup;
    # not a current declaration/copy contract or a fresh-per-entry graph witness.
    [pscustomobject]@{ Name = 'unit_recursive_model_slot.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Absent = @('[0]: lmx_pointer_new_owned('); Debt = @('lmx_arena_ref_store(self, ') },
    # FABLE-GROKBOT-MATRIX-20260924-143 -- B2 semantic matrix (fixtures only).
    # Grid: {absent, existing non-callable, existing callable, path} x
    # {primitive, Structure ref, Array/ref, callable} over one head-consumes-tail
    # op; three spellings where positive; physical op / identity / diagnostics.
    [pscustomobject]@{ Name = 'unit_matrix_absent_struct_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_prim_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_matrix_absent_prim_refused.lm2:4:5: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_arrayish_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_matrix_absent_arrayish_refused.lm2:4:5: unresolved name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_prim_asgn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_empty_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    # The matrix cell restated by the call rule (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): the non-callable binding is
    # an explicit reference, and its rebinding runs the admission and binds a Model -- was _refused, fail-closed.
    [pscustomobject]@{ Name = 'unit_matrix_noncall_struct_rebind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_runtime_implements(') },
    # Q52 (7b, by name): as unit_callable_priority -- the three spellings are observed in foo's lines.
    [pscustomobject]@{ Name = 'unit_matrix_callable_prim.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Says = @('foo 1 5', 'foo 1 6', 'foo 1 7'); Absent = @(); Debt = @() },
    # -179 commit 2: a Structure argument of the formal's own type goes BY REFERENCE -- the CALL's
    # input is m's working value, OWN (§7b), the Structure m holds -- so bump's three writes through x are m's own:
    # 4U after them.  Passed as a fresh merge copy instead, the writes are lost and the row exits 90.
    [pscustomobject]@{ Name = 'unit_matrix_callable_struct_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('c.LMX_WALK_OP_DEREF'); Debt = @('@: Lmx l2_rw4 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw3, c.LMX_WALK_OP_OWN, 3U)') },
    [pscustomobject]@{ Name = 'unit_matrix_callable_array_elem.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0'); Absent = @(); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    [pscustomobject]@{ Name = 'unit_matrix_callable_callable_arg.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_path_prim.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    # -183 (q26): a whole Structure assigned through a path to a Structure-typed field stays
    # fail-closed at the root, a located refusal (fable's interim ruling), until the author answers q26
    # (merge in place / rebind / refusal).
    [pscustomobject]@{ Name = 'unit_matrix_path_struct_rebind_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'root operation not walkable yet: a Structure assigned through a path'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_path_array_elem.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0'); Absent = @(); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    # (e) empty Structure as ONE named value vs empty arg list. D-23: `take(x: ())`
    # admits the empty Structure to E and returns 7. Arglist is a nullary CALL.  Since the named actuals
    # (steps/named-actuals.md), `x: ()` is bound like any named argument: the empty Structure in x's place.
    # Mutant: treat the named frame as a call again -- unknown method, this row RED.
    [pscustomobject]@{ Name = 'unit_matrix_empty_named_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; Absent = @(); Debt = @('lmx_walk_admit', 'LMX_WALK_OP_EMPTY') },
    [pscustomobject]@{ Name = 'unit_matrix_empty_arglist.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    # Named actuals of an ordinary call (book :1060; steps/named-actuals.md): every call's actuals are bound to
    # its callee's formals by the one binding the receiver `table` uses (l2_bind_actuals), before any pass reads
    # them (l2_bind_calls); a call with a named argument is rewritten in its formals' order, a named argument's
    # body its formal's positional actual, kept whole when by position it would not be one actual.  Witnesses:
    # named, reordered, positional then named, an expression body, a call bound inside an argument, from a
    # method and walked; the binding's five refusals in the book's words; a callable formal called by its
    # contract's formal name (native: a callable formal is outside the walkable subset); a path call; a frame
    # among the actuals that names a formal of the callee is that formal's argument (P0 gives g(2) and g: 2 one
    # tree); a body kept whole (b: - 1).  D-23's `take(x: ())` (above) is the empty Structure after the binding.
    # Mutants (steps/named-actuals.md §3, each by copy, both modes): no binding pass -- every named row red, the
    # formal-name row runs the method g (81), D-23's row red; bound but not rewritten -- the running rows red;
    # a body never kept whole -- the whole row, "incompatible entry signature"; the callee by method name only --
    # the formal and path rows red; a bound call's actuals not read for calls of their own -- the nested call
    # red; the empty actual known only in D-23's frame form -- D-23's row red.
    [pscustomobject]@{ Name = 'unit_named_actuals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_actuals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_twice_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_twice_refused.lm2:6:12: the argument a of f is given twice'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_unknown_refused.lm2:6:12: c is not an argument of f'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_order_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_order_refused.lm2:6:12: a positional argument of f after a named one'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_missing_refused.lm2:6:4: f has no argument b'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_again_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_again_refused.lm2:6:9: the argument a of f is given by position and again by name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_formal_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # REVIEW 394f6a9: a callee's formals have no bound -- 17 bound by position and by name past the sixteenth
    # (fable_pc's P62 a; red under a copy with the former 16-slot binding: "internal: a callee with more formals
    # than a binding holds"); a named call in a method's `return:` trailer, outside its body (M54, P62 c; red
    # under M54: "unknown method"); a sub's named call as a statement (P62 d; red with no binding pass).
    [pscustomobject]@{ Name = 'unit_named_actual_many.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_actual_many.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_actual_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Q52 (7b, by name): add keeps a - b in its own declared field d, read at its place of declaration, add\d -- a
    # bare write of the unit's y would be add's hidden input's only.  Walked too: its ARG, SUB and SET are the walk's.
    [pscustomobject]@{ Name = 'unit_named_actual_sub.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_actual_sub.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # A free name under the type checks (book :1180, :1182; steps/free-names.md): a dynamic input is a value of its
    # binding's type, under the rule a local of that type is under.  The check reads types before l2_dyn_close gives
    # the inputs theirs, so a check whose value (or the hidden argument it assigns) reads an input without a type
    # waits: it runs after the closure at the same site, in its method and scope stack, and the edges it notes are
    # closed again (M2, M3); the scan reads a declaration's initializer (M1).  Witnesses, each also walked: int ->
    # size_t through a free name in a return, a composite, an argument and a hidden argument's field (B: accepted
    # before with an L1 that cannot build), its refusal caught and uncaught; `r: k` and a declaration's
    # initializer (D: refused before); a mix with a typed local, at the method and inside an if body (A: accepted
    # before, the C compiler decided); char -> size_t (C: internal words before).
    # Mutants (copies of the translator, each row in both modes):
    #   the waited checks never run -- every witness red except the char assignment, which the emitter's store
    #     conversion refuses in the same words;
    #   no check waits (the sites as before) -- all red;
    #   the closures not run again -- the runnable rows' L1 cannot build;
    #   M1 removed -- the declaration's initializer is "unresolved name";
    #   the waited check run without its scope stack -- the if-body mix is accepted;
    #   M1's initializer read with the declaration's own row visible (Q24 = A broken) -- unit_root_decl_init_prev
    #     and unit_q24_repeated_decl, above, refused.
    [pscustomobject]@{ Name = 'unit_free_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_conv_catch.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_assign.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_assign.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_decl_init.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_decl_init.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_mixed_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_mixed_refused.lm2:5:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_mixed_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_mixed_refused.lm2:5:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_ctx_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_ctx_refused.lm2:6:17: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_ctx_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_ctx_refused.lm2:6:17: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_conv_norow_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_conv_norow_refused.lm2:5:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_conv_norow_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_conv_norow_refused.lm2:5:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_assign_mixed_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_assign_mixed_refused.lm2:5:5: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_assign_mixed_refused.lm2'; Parts = @('convert_impl.lm2'); Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_assign_mixed_refused.lm2:5:5: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    # Class A inside a parenthesized group with neighbours (next_core_tasks.md :374): the native composite typer types
    # the group by its fields, as the walk does (l2_native_group_ty; l2_rw_fields_ty) -- it was untyped, and the value
    # accepted.  A local k, a free k (the check waits: l2_waits' descent into the group, M56), two groups deep in an
    # assignment, in a declaration's initializer; one type in a group, and a cast in a group, still 7.
    [pscustomobject]@{ Name = 'unit_group_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_group_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_group_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_group_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_group_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_group_mixed_refused.lm2:6:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_group_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_group_mixed_refused.lm2:6:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_group_assign_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_group_assign_mixed_refused.lm2:8:5: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_group_assign_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_group_assign_mixed_refused.lm2:8:5: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_group_decl_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_group_decl_mixed_refused.lm2:6:16: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_group_decl_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_group_decl_mixed_refused.lm2:6:16: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_group_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Class A in a method's condition: the native kind check (l2_check_value_kinds) refuses a mix at the operation's
    # first operand, and waits for a free name's type (kind 3) as the value checks do -- a condition was checked by
    # nothing, and `if: k = j` / `while: j < k` with an int k and a size_t j translated (the walk refuses them at the
    # root).  A local `if:`, a free name in `while:`; one type per condition, a waited one included, still 7.
    [pscustomobject]@{ Name = 'unit_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_cond_mixed_refused.lm2:5:12: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_cond_mixed_refused.lm2:5:12: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_cond_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A path to a number field is a value of that field's type in a method's composite (l2_native_path_ty; the walk
    # types a path operand by its field): it was untyped, which leaves the whole value untyped -- class A with a path
    # translated, in a value and in a condition, and a composite holding a path took no conversion edge.  One type
    # through P\v, node\k and a method's own S\w, a condition included, still 7.
    [pscustomobject]@{ Name = 'unit_path_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_path_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_path_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_path_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_path_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_conv_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_conv_norow_refused.lm2:7:5: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_path_conv_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_path_conv_norow_refused.lm2:7:5: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A value that is only a path (P0: the fields `P`, `\`, `v` -- one token) is a value of its field's type: the
    # composite typer typed nothing below three tokens, so a result, an initializer, an argument took no conversion,
    # and the emitter's path branch refused a store of another type.  Without a receiver: refused at the conversion;
    # with the program's receivers (convert_impl): four int places, 8.
    [pscustomobject]@{ Name = 'unit_path_return_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_return_norow_refused.lm2:7:13: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_path_return_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_path_return_norow_refused.lm2:7:13: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_store_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_store_norow_refused.lm2:8:5: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_path_store_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_path_store_norow_refused.lm2:8:5: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_value_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # An element of an own Array at a literal index is a value of the element's type (l2_rw_elem_ty, as the walk types
    # it): it was untyped, which leaves the whole value untyped -- class A with an element translated, in a value and in
    # a condition, and a value that is only an element took no conversion edge.  One type, and a conversion through
    # the program's receivers, still 7.
    [pscustomobject]@{ Name = 'unit_elem_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_elem_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_elem_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_elem_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_elem_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_elem_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_elem_cond_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_elem_cond_mixed_refused.lm2:8:9: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_elem_return_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_elem_return_norow_refused.lm2:6:13: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_elem_return_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_elem_return_norow_refused.lm2:6:13: the program has no method `lm_stg_convert_size_t_int`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_elem_same.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A callable formal, bare or called, is a value of its contract's result type (l2_native_cf_ty): it was untyped,
    # which leaves the whole value untyped -- class A with one translated.  No walked twins: a method with a callable
    # formal is outside the walkable subset, refused before this check.  One type, bare and called, still 7.
    [pscustomobject]@{ Name = 'unit_cf_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_cf_mixed_refused.lm2:9:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_cf_bare_mixed_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_cf_bare_mixed_refused.lm2:8:13: mixed numeric types (a conversion)'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_cf_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A store into an own Array's element takes the conversion edge of a value of another number type, as a write
    # through a path does (OPUS-PATHCONV-20260929-10): checked as a result or a formal is, and the receiver called on
    # the value before the store -- it had no edge and no refusal.  No receiver: refused at the value; with the
    # program's receivers: a single value and a composite, 7; -1 into size_t: the receiver's throw reaches the root.
    [pscustomobject]@{ Name = 'unit_elem_store_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_elem_store_norow_refused.lm2:7:11: the program has no method `lm_stg_convert_int_size_t`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_elem_store_norow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_elem_store_norow_refused.lm2:7:11: the program has no method `lm_stg_convert_int_size_t`'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_elem_store_conv.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_elem_store_conv_range.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 3;
        Absent = @(); Debt = @() },
    # A held callable called from a method (steps/merge-callable-r48.md S1): add5, a root own holding makeAdder's merged
    # node, called from go natively through the same l2_mad_call helper the root's walk calls -- before, l2_prep's frame
    # tail returned without a word (exit 3, "a refusal said nothing"); walked, go calls it through the walk's PRIM.
    # Mutants: the held branch removed -- the tail now says "internal: a call the emitter does not know" at the frame,
    # one line, both modes; a held frame not counted a call (l2_node_has_call) -- the guarded row's native call runs
    # before add5 holds a node and stops in the helper (the walked twin guards && on the walk's own path).
    [pscustomobject]@{ Name = 'unit_held_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_held_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_guarded.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_held_call_guarded.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # S1's typed argument cell (REVIEW ebae3b0, fable_pc's M57): a size_t header's call from a method passes a size_t
    # cell and takes the size_t variant's result -- red natively under a copy that always makes an int cell ("walk
    # error: INVALID").
    [pscustomobject]@{ Name = 'unit_held_call_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_held_call_size_t.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # A merge result (T5, l2_pap_on) called from a method (steps/merge-callable-r48.md S2a): its leaf has native 0 and its
    # C function is a stub, so the call goes through the leaf as the root's walk does -- the D-93 path, lmx_call_prim over
    # its occurrence -- and go() is 6.  Before, the native call reached the stub: 0 instead of 6 (the translator before
    # this is the mutant; walked, go reached the leaf already).
    [pscustomobject]@{ Name = 'unit_pap_add5_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_pap_add5_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # THE WORKING STATE (steps/working-state-7b.md, 7b-1; book §12, §14; Lingvamyxa spec 21.5, 21.6): each witness twice,
    # natively and walked; the value is the exit code.  In walk mode the methods the walk takes are walked (a method
    # with a self path, throw/catch, a Box field or c.* stays native; a `for` is walked since OPUS-WALKLOOP-20260929-11,
    # before it test stayed native here), the root always.
    # unit_cache_for_call: the book's for/print trace: take gets the working acc 9 and the published for\j 0 -- in place 99.
    [pscustomobject]@{ Name = 'unit_cache_for_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 90;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_for_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 90; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # unit_cache_addr_graph: `\p: 9` through `p: @x` changes the cell, not the working x 5; the clean x is not written back -- in place 99, clean published 55.
    [pscustomobject]@{ Name = 'unit_cache_addr_graph.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 59;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_addr_graph.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 59; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_no_reload: a nested `test\x: 7`: no reload (bare x stays 1), the clean x not written back (cell 7) -- in place or reloaded 77, clean published 11.
    [pscustomobject]@{ Name = 'unit_cache_no_reload.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 17;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_no_reload.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 17; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_precall: an explicit read before the call sees the published 1; the call publishes 2; the exit 3 -- in place 223, no pre-call publication 113, no exit publication 122.
    [pscustomobject]@{ Name = 'unit_cache_precall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 123;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_precall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 123; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Inner publication9, outer working2, final outer publication3:293.
    [pscustomobject]@{ Name = 'unit_cache_reentry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 293;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_reentry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 293; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # unit_cache_throw: the throw publishes the dirty x 5 -- without it 31.
    [pscustomobject]@{ Name = 'unit_cache_throw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 35;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_throw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 35; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_ccall: a c.* call publishes the dirty x 5 -- without it 1 (the walk keeps the c.* method native).
    [pscustomobject]@{ Name = 'unit_cache_ccall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_ccall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_branch_dirty: the untaken branch marks nothing: the clean x is not written over poke's 7 -- a mark by presence 1.
    [pscustomobject]@{ Name = 'unit_cache_branch_dirty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_branch_dirty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_failed_store: a refused conversion keeps the pending 6 and marks nothing (F49-04) -- erased 57, marked 65.
    [pscustomobject]@{ Name = 'unit_cache_failed_store.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 67;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_failed_store.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 67; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_struct_ref: a Box field's working value is the reference, published as the reference -- a copy of the Box 22.
    [pscustomobject]@{ Name = 'unit_cache_struct_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 25;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_struct_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 25; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_helper_not_boundary: an explicit path write is no boundary: test\x still reads the published 1 -- in place, or a helper that publishes, 5.
    [pscustomobject]@{ Name = 'unit_cache_helper_not_boundary.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_helper_not_boundary.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # unit_cache_precall_bare: the pre-call and exit publications with bare names only, walked whole -- no pre-call publication 13, no exit publication 22.
    [pscustomobject]@{ Name = 'unit_cache_precall_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 23;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_precall_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 23; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # Bare working values remain private despite ordinary inner publication; result23.
    [pscustomobject]@{ Name = 'unit_cache_reentry_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 23;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_reentry_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 23; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # External peek observes the same inner-published9 as the current self path.
    [pscustomobject]@{ Name = 'unit_cache_reentry_peek.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 293;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_reentry_peek.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 293; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_reentry_clean_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_reent', '_act:'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_reentry_clean_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @('l2_reent', '_act:'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_self_path_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_self_path_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_self_path_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_self_path_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(1);
        Absent = @(); Debt = @() },
    # unit_cache_root_precall: the root publishes its dirty x before calling peek, whose node\x reads 5 -- without it 11.
    [pscustomobject]@{ Name = 'unit_cache_root_precall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 15;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_root_precall.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 15; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # The write-only assignment to a free name (steps/free-names.md §7): the scan reads a bare assignment's target
    # like a read, so `k: 1` in peek, with k bound by the caller, changes peek's hidden argument k, typed by that
    # binding, and declares nothing (bafca4c; 7b, re-read by name, value unchanged; the assignment waits for the
    # closure, M2) and m's k stays 5; `k: 1U` against the caller's int k is refused at the
    # write, as the same int declared in peek is.  Mutant: the target not read -- the write refused again.
    [pscustomobject]@{ Name = 'unit_free_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_write_literal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_write_literal_refused.lm2:4:5: literal not representable as int'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_write_literal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_free_write_literal_refused.lm2:4:5: literal not representable as int'; Absent = @(); Debt = @() },
    # Parity native for D-04 (walker FIXED -140): extra Structure arg to nullary.
    [pscustomobject]@{ Name = 'unit_matrix_parity_extra_struct_native.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'lm2:14:5: more arguments than bar has formals'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_bad_sizeof.lm2'; Expect = 'translates'; Exit = 0;
        Absent = @('fn: lm_own_new_zero (size_t: size) @: void'); Debt = @() },
    # steps/gate-measure-20260927.md: three of dev\l2src_sandbox's own top-level L2 parser-port
    # sources, migrated from the pre-a2cf69eb bare LmP0*/LmOwn* spelling to the door c.LmP0*/
    # c.LmOwn* and gated here -- the other 13 measured ungated ports had a deeper cause after
    # that same migration and were removed (measured reasons in that file), not gated.
    [pscustomobject]@{ Name = 'parser_alloc_port.lm2'; Expect = 'translates'; Exit = 0; RootSource = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'parser_trailer_role.lm2'; Expect = 'translates'; Exit = 0; RootSource = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'parser_text_heap.lm2'; Expect = 'translates'; Exit = 0; RootSource = $true;
        Absent = @(); Debt = @('predef: "l1src/own.h.lm1"') }
)

if ($OnlyFixture.Count -gt 0) {
    $requestedFixtures = @($OnlyFixture | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) })
    $knownFixtures = @($fixtures | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) })
    $unknownFixtures = @($requestedFixtures | Where-Object { $_ -notin $knownFixtures })
    if ($unknownFixtures.Count -gt 0) { throw ('unknown fixture: ' + ($unknownFixtures -join ', ')) }
    $fixtures = @($fixtures | Where-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -in $requestedFixtures })
    Add-Row 'OK' 'scope:focused' ($requestedFixtures -join ', ')
    Write-Output ('l2_harness: FOCUSED run; ' + $fixtures.Count + ' selected fixtures; not the full gate')
}

foreach ($fx in $fixtures) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($fx.Name)
    # RootSource: a handful of fixtures are dev\l2src_sandbox's own top-level L2 parser-port
    # sources (steps/gate-measure-20260927.md), not tests\ fixtures -- same sandbox, different
    # subdirectory of it.
    # Missing (P50, REVIEW ee58ce4): the row's input does not exist -- l2trans is given a path that is not
    # there and must say so in a line of its own (a parse error without a P0 diagnostic), never as the
    # guard's "internal: a refusal said nothing".  Nothing is staged for it.
    $missing = ($fx.PSObject.Properties['Missing'] -and $fx.Missing)
    if ($missing) {
        $source = Join-Path $src ('absent\' + $fx.Name)
        if (Test-Path -LiteralPath $source) { Add-Row 'FAIL' ('fixture:' + $stem) 'the absent input exists'; continue }
    } elseif ($fx.PSObject.Properties['RootSource'] -and $fx.RootSource) {
        $source = Join-Path $sandbox $fx.Name
    } else {
        $source = Join-Path $sandbox ('tests\' + $fx.Name)
    }
    if (-not $missing -and -not (Test-Path -LiteralPath $source)) { Add-Row 'FAIL' ('fixture:' + $stem) 'fixture file is missing'; continue }
    # The program (steps/table-receiver.md §8, Q46): the fixture, then its parts, named at the call.  By
    # default the parts are the sandbox's convert.lm2 and primitive.lm2, staged at the top of this script.
    # Table and Primitive name a row's own file for either (tests\<file>, staged under its own name) or
    # 'absent' (no such part); Impl names a row's own receivers file; Parts adds files (a tests\<file>, or a
    # sandbox file staged at the top, by its name).  Nothing is renamed: a diagnostic in a part names that
    # part's own file.
    $stagedLm2 = Join-Path $src $fx.Name
    if ($missing) { $stagedLm2 = $source }
    $partNames = @()
    if ($fx.PSObject.Properties['Table'] -and $fx.Table) {
        if ($fx.Table -ne 'absent') { $partNames += @($fx.Table) }
    } else { $partNames += @('convert.lm2') }
    if ($fx.PSObject.Properties['Primitive'] -and $fx.Primitive) {
        if ($fx.Primitive -ne 'absent') { $partNames += @($fx.Primitive) }
    } else { $partNames += @('primitive.lm2') }
    if ($fx.PSObject.Properties['Impl'] -and $fx.Impl) { $partNames += @($fx.Impl) }
    if ($fx.PSObject.Properties['Parts'] -and $fx.Parts) { $partNames += @($fx.Parts) }
    $partArgs = @()
    $partMissing = ''
    foreach ($pn in $partNames) {
        $ownPart = Join-Path $sandbox ('tests\' + $pn)
        if (Test-Path -LiteralPath $ownPart) { Copy-Item -LiteralPath $ownPart -Destination (Join-Path $src $pn) -Force }
        if (-not (Test-Path -LiteralPath (Join-Path $src $pn))) { $partMissing = $pn }
        $partArgs += @($pn)
    }
    if ($partMissing) { Add-Row 'FAIL' ('fixture:' + $stem) ('a part of the program is missing: ' + $partMissing); continue }
    if (-not $missing) { Copy-Item -LiteralPath $source -Destination $stagedLm2 -Force }
    $source = $stagedLm2
    $genLm1 = Join-Path $gen ($stem + '.lm1')
    $label = 'fixture.' + $stem + '.l2trans'
    $profileArgs = @()
    # WalkMethods (-193 T4a): the row runs its methods WALKED -- l2trans's test knob `--walk-methods`
    # gives every method with frames (its body built as walker nodes) native 0, so a CALL of it walks.
    if ($fx.PSObject.Properties['WalkMethods'] -and $fx.WalkMethods) { $profileArgs += @('--walk-methods') }
    if ($fx.Expect -eq 'library-links') { $profileArgs += @('--library') }
    # Library (§10): a refusal row translated as a library -- whose unit executes no statements.
    if ($fx.PSObject.Properties['Library'] -and $fx.Library) { $profileArgs += @('--library') }
    $made = Step-Made $label $l2trans ($profileArgs + @($source) + $partArgs + @($genLm1)) $src $genLm1

    # 'root-pending' (FABLE-OPUS-ROOT-WALK-TRANSLATOR-20260924-159): a row whose root uses an operation the
    # translator does not build as walker nodes yet.  It is refused, located, with the operation it needs
    # (the needle) -- never dropped, never run natively -- and flips back to eternal-runs when that
    # operation is built.
    if ($fx.Expect -eq 'l2trans-refuses' -or $fx.Expect -eq 'root-pending') {
        # G4: this branch `continue`s right after the Needle check, below -- Says/Debt/Absent are
        # never read for a refusal row (they belong to the eternal-runs/translates branches that a
        # refusal never reaches; l2trans doesn't even produce an L1 file here). A row's own Says/
        # Debt/Absent claiming otherwise is dead weight nobody checks -- fail the ROW ITSELF, not
        # the fixture, so a reintroduced claim like that cannot sit silently again.
        $shapeBad = @()
        if ($fx.PSObject.Properties['Says'] -and $fx.Says -and $fx.Says.Count -gt 0) { $shapeBad += 'Says' }
        if ($fx.PSObject.Properties['Debt'] -and $fx.Debt -and $fx.Debt.Count -gt 0) { $shapeBad += 'Debt' }
        if ($fx.PSObject.Properties['Absent'] -and $fx.Absent -and $fx.Absent.Count -gt 0) { $shapeBad += 'Absent' }
        if ($shapeBad.Count -gt 0) { Add-Row 'FAIL' ('fixture:' + $stem) ('a ' + $fx.Expect + ' row cannot carry ' + ($shapeBad -join '/') + ' -- l2trans never runs far enough for it to mean anything'); continue }
        if ($made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans ACCEPTED a fixture that must be refused'; continue }
        # The log is matched with its line breaks removed: Windows PowerShell wraps a native stderr
        # line at the console width, and a long fixture path pushes the message across the break.
        $refusedLog = Log-Text $label
        $refusedText = $refusedLog -replace "`r?`n", ''
        # One cause, one line (REVIEW 9256c3b): l2trans stops at its first refusal, so a second
        # "l2trans error:" is a tail of the first -- general words after a located one -- and miscounts
        # refusals.  A parse error prints none of these lines, so at most one, not exactly one.  Lines
        # are counted where they START (the log with its breaks): PS 5.1 turns the first native stderr
        # line into an error record, prefixed "l2trans.exe : " and repeated inside its CategoryInfo, so
        # a substring count sees every refusal twice.
        $errorLines = ([regex]::Matches($refusedLog, '(?m)^(?:l2trans\.exe : )?l2trans error:')).Count
        if ($errorLines -gt 1) { Add-Row 'FAIL' ('fixture:' + $stem) ('refused with ' + $errorLines + ' "l2trans error:" lines -- one cause, one line'); continue }
        # ErrorLines (P50): a refusal said in a line of another kind -- a P0 parse error -- has exactly this
        # many "l2trans error:" lines; 0 pins that the silent-refusal guard does not re-say it.
        if ($fx.PSObject.Properties['ErrorLines'] -and $errorLines -ne $fx.ErrorLines) { Add-Row 'FAIL' ('fixture:' + $stem) ('refused with ' + $errorLines + ' "l2trans error:" lines, not ' + $fx.ErrorLines); continue }
        if ($refusedText -notmatch [regex]::Escape($fx.Needle)) { Add-Row 'FAIL' ('fixture:' + $stem) ('refused, but not with "' + $fx.Needle + '"'); continue }
        Add-Row 'OK' ('fixture:' + $stem) ('refused as expected: ' + $fx.Needle); continue
    }
    if (-not $made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans produced no L1; see the log'; continue }
    # Notes: lines l2trans must print while it translates (an `l2trans note:`), matched in its log
    # as a refusal's Needle is -- line breaks removed (REVIEW c953b22: a callable-merge host the knob
    # does not walk says so).
    if ($fx.PSObject.Properties['Notes'] -and $fx.Notes) {
        $noteLog = ((Log-Text $label) -replace "`r?`n", '')
        $noteGone = @($fx.Notes | Where-Object { $noteLog -notmatch [regex]::Escape($_) })
        if ($noteGone.Count -gt 0) { Add-Row 'FAIL' ('fixture:' + $stem) ('l2trans did not note "' + $noteGone[0] + '"'); continue }
    }
    if ($fx.Expect -eq 'eternal-runs' -or $fx.Expect -eq 'send-abort' -or $fx.Expect -eq 'walk-x1') {
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

    if ($fx.Expect -eq 'translates-with-debt' -or $fx.Expect -eq 'translates') {
        if (-not $made2) { Add-Row 'FAIL' ('fixture:' + $stem) 'l1trans produced no C from the generated L1; see the log'; continue }
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = Test-NativeGraphWitnesses $fx $l1
        foreach ($a in $fx.Absent) {
            if ($why -eq '' -and $l1 -match [regex]::Escape($a)) { $why = 'the generated L1 still names "' + $a + '"' }
        }
        foreach ($d in $fx.Debt) {
            if ($why -eq '' -and $l1 -notmatch [regex]::Escape($d)) {
                if ($fx.Expect -eq 'translates') { $why = 'the pinned "' + $d + '" is gone from the generated L1' }
                else { $why = 'the recorded debt "' + $d + '" is GONE -- update this fixture, the gap has closed' }
            }
        }
        if ($why -ne '') { Add-Row 'FAIL' ('fixture:' + $stem) $why; continue }
        if ($fx.Expect -eq 'translates') { Add-Row 'OK' ('fixture:' + $stem) ('translation shape holds (' + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden)'); continue }
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
            $ostaged = Join-Path $src $other
            Copy-Item -LiteralPath $osource -Destination $ostaged -Force
            if (-not (Step-Made ('fixture.' + $ostem + '.l2trans') $l2trans @('--library', $ostaged, 'convert.lm2', 'primitive.lm2', $oLm1) $src $oLm1)) { $why = 'l2trans produced no L1 for the partner ' + $other; break }
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

    if ($fx.Expect -eq 'eternal-runs' -or $fx.Expect -eq 'send-abort' -or $fx.Expect -eq 'walk-x1') {
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = Test-NativeGraphWitnesses $fx $l1
        foreach ($a in $fx.Absent) {
            if ($why -eq '' -and $l1 -match [regex]::Escape($a)) { $why = 'the generated L1 still names "' + $a + '"' }
        }
        foreach ($d in $fx.Debt) {
            if ($why -eq '' -and $l1 -notmatch [regex]::Escape($d)) { $why = 'the generated L1 lacks "' + $d + '"' }
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
        $fixtureFlags = @($kflags)
        # Source-void/status-ABI witnesses reject a missing C return value as a
        # constraint failure, not an accidentally successful undefined run.
        if ($fx.PSObject.Properties['ReturnTypeCheck'] -and $fx.ReturnTypeCheck) { $fixtureFlags += '-Werror=return-type' }
        if ($fx.PSObject.Properties['PointerTypeCheck'] -and $fx.PointerTypeCheck) { $fixtureFlags += '-Werror=incompatible-pointer-types' }
        $code = Invoke-Step ('fixture.' + $stem + '.compile') $gcc ($fixtureFlags + @('-Dmain=l2_generated_main', '-Dlmx_root_launch=l2_driver_root_launch', '-Dlmx_merge_owned=l2_driver_merge_owned', '-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned', '-Dlmx_service_post=l2_driver_service_post', '-c', $genC, '-o', $genO)) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $genO)) { Add-Row 'FAIL' ('fixture:' + $stem) "gcc exit $code on the generated C"; continue }
        $code = Invoke-Step ('fixture.' + $stem + '.link') $gcc @('-o', $exe, $driverO, $genO, $l2libcO) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) { Add-Row 'FAIL' ('fixture:' + $stem) "link exit $code"; continue }
        # The expected entry value travels as the driver fact `entry N` (default 0, the fixtures' pass).
        $runArgs = @($fx.Args)
        if ($fx.PSObject.Properties['StopMethods']) {
            $runArgs += @('stopcall') + @(Get-DispatchMethodSlots $l1 $fx.StopMethods)
        }
        if ($fx.PSObject.Properties['DispatchMethods']) {
            $dispatchFlag = 'dispatch'
            if ($fx.PSObject.Properties['DispatchThrows'] -and $fx.DispatchThrows) { $dispatchFlag = 'dispatchthrow' }
            $runArgs += @($dispatchFlag) + @(Get-DispatchMethodSlots $l1 $fx.DispatchMethods)
        }
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
        $nativeParityFailure = ''
        if (($fx.PSObject.Properties['WalkRoot'] -and $fx.WalkRoot) -or ($fx.PSObject.Properties['StopWalk'] -and $fx.StopWalk)) {
            $nativeRunArgs = @($runArgs)
            if ($fx.PSObject.Properties['Argv']) { $nativeRunArgs += @('--') + @($fx.Argv | ForEach-Object { $_.Replace('{source}', $source) }) }
            $nativeRan = Invoke-Step ('fixture.' + $stem + '.run.native') $exe $nativeRunArgs $bin
            $nativeSaid = Log-Text ('fixture.' + $stem + '.run.native')
            if ($nativeRan -ne $fx.Exit -or $nativeSaid -notmatch 'l2_eternal_driver: \d+ checks') {
                $nativeParityFailure = 'native half of dispatch parity failed, exit ' + $nativeRan
            }
            if ($fx.PSObject.Properties['StopWalk'] -and $fx.StopWalk) { $runArgs += @('stopwalk', '1') }
            else { $runArgs += @('walkroot', '1') }
        }
        if ($fx.PSObject.Properties['Argv']) { $runArgs = $runArgs + @('--') + @($fx.Argv | ForEach-Object { $_.Replace('{source}', $source) }) }
        $ran = Invoke-Step ('fixture.' + $stem + '.run') $exe $runArgs $bin
        if ($nativeParityFailure -ne '') {
            Add-Row 'FAIL' ('fixture:' + $stem) ($nativeParityFailure + '; walked half exit ' + $ran)
            continue
        }
        if ($fx.Expect -eq 'send-abort') {
            $slog = Log-Text ('fixture.' + $stem + '.run')
            if ($ran -ne 3 -or $slog -notmatch 'lmx: invariant: sendMessage failed' -or $slog -match 'lmx: walk error: PRIMITIVE') {
                Add-Row 'FAIL' ('fixture:' + $stem) ('send abort expected exit 3 and the invariant line, got exit ' + $ran)
                continue
            }
            Add-Row 'OK' ('fixture:' + $stem) 'abort exit 3, invariant sendMessage failed, no PRIMITIVE'
            continue
        }
        # 'walk-x1' (Codex, 2026-09-28): the program stops on the walker's X1 -- a read the graph has no value for
        # (`node\n` in a direct call: the host's formal is no body field) -- never a made-up 0.
        if ($fx.Expect -eq 'walk-x1') {
            $xlog = Log-Text ('fixture.' + $stem + '.run')
            if ($ran -ne 3 -or $xlog -notmatch 'lmx: walk error: INVALID') {
                Add-Row 'FAIL' ('fixture:' + $stem) ('the walker''s X1 expected (exit 3, walk error INVALID), got exit ' + $ran)
                continue
            }
            Add-Row 'OK' ('fixture:' + $stem) 'X1 exit 3, walk error INVALID'
            continue
        }
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
        $graphFacts = ''
        if ($fx.PSObject.Properties['NativeRoot']) { $graphFacts += '; native root attached' }
        if ($fx.PSObject.Properties['GraphCalls']) { $graphFacts += '; ' + $fx.GraphCalls.Count + ' callable graph relationships' }
        if ($fx.PSObject.Properties['WalkRoot'] -and $fx.WalkRoot) { $graphFacts += '; same artifact: native + driver-cleared physical root walk' }
        if ($fx.PSObject.Properties['StopWalk'] -and $fx.StopWalk) { $graphFacts += '; same artifact: native caller + driver-cleared caller walk, native root and typed stop adapters retained' }
        Add-Row 'OK' ('fixture:' + $stem) (($said -replace '^l2_eternal_driver: ', '') + $what + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden in the text)' + $graphFacts); continue
    }

    Add-Row 'FAIL' ('fixture:' + $stem) ('no such Expect kind: ' + $fx.Expect)
}

foreach ($r in $rows) { Write-Output ($r.State.PadRight(5) + $r.Label.PadRight(34) + $r.Note) }
Write-Output ''
# A STAMP KEEPS WHAT A REVIEW NEEDS (next_core_tasks.md §0, build memory, item 4; the author,
# 2026-09-27: build/ had grown to 1.7 million files, the load behind the kernel pools and the
# scanner).  summary.txt lists EVERY row with its state and note, so "N rows, 0 failed" is provable
# from the stamp (fable_pc's condition); src/ and headers/ stay (staged = blob); the build steps'
# own logs and artifacts stay.  A fixture whose rows are all OK loses its per-fixture logs
# (fixture.<stem>.*.log) and generated files (gen/<stem>.lm1 .c .o, bin/<stem>.exe); a fixture
# with any other row keeps everything.  -KeepAll keeps every file, as before.
$peakLines = @(Format-PeakReport (Stop-PeakSampler) 10)
foreach ($l in $peakLines) { Write-Output ('l2_harness: ' + $l) }
# The staged translator source as a git blob (the repository's eol filter applied, as a commit
# stores it), so "staged = blob" reads from this one file (fable_pc's request).
$stagedTrans = Join-Path $src 'l2src\l2trans.lm1'
$stagedBlob = ((git -C $root hash-object --path=dev/l2src_sandbox/l2trans.lm1 $stagedTrans) -join '').Trim()
$summaryPath = Join-Path $OutDir 'summary.txt'
# The last line is the verdict (REVIEW 00d6fba, fable_pc's mutant M23): a writer that dropped a row
# would show fewer row lines than the verdict counts, so the file checks itself.
$verdictLine = 'verdict' + "`t" + $rows.Count + ' targets' + "`t" + $red.Count + ' failed'
[System.IO.File]::WriteAllText($summaryPath, ((@('staged' + "`t" + 'src/l2src/l2trans.lm1' + "`t" + $stagedBlob) + @($rows | ForEach-Object { $_.State + "`t" + $_.Label + "`t" + $_.Note }) + $peakLines + @($verdictLine) -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
if (-not $KeepAll) {
    $keepStem = @{}
    foreach ($r in $rows) { if ($r.State -ne 'OK' -and $r.Label.StartsWith('fixture:')) { $keepStem[$r.Label.Substring(8)] = 1 } }
    $pruned = 0
    foreach ($r in $rows) {
        if ($r.State -ne 'OK' -or -not $r.Label.StartsWith('fixture:')) { continue }
        $stem = $r.Label.Substring(8)
        if ($keepStem.ContainsKey($stem)) { continue }
        foreach ($f in @(Get-ChildItem -LiteralPath $logs -File -Filter ('fixture.' + (Safe $stem) + '.*.log') -ErrorAction SilentlyContinue)) { Remove-Item -LiteralPath $f.FullName -Force; $pruned++ }
        foreach ($f in @((Join-Path $gen ($stem + '.lm1')), (Join-Path $gen ($stem + '.c')), (Join-Path $gen ($stem + '.o')), (Join-Path $bin ($stem + '.exe')))) {
            if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force; $pruned++ }
        }
    }
    Write-Output ('l2_harness: ' + $pruned + ' per-fixture files of OK rows removed (-KeepAll keeps them); every row is in ' + $summaryPath)
}
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
