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

# Observe stable builder handles and the final root attachments. Reusable
# l2_entry_leaf is sampled at each assignment/use, never made a stable alias.
# These are facts about emitted construction, not runtime language metadata.
function Resolve-BuilderIdentity($Aliases, [string]$Name) {
    $seen = @{}
    while ($Aliases.ContainsKey($Name)) {
        if ($seen.ContainsKey($Name)) { return '' }
        $seen[$Name] = $true
        $Name = [string]$Aliases[$Name]
    }
    return $Name
}
function Get-BuilderSourceBody([string]$Text) {
    $bodies = [regex]::Matches($Text, '(?ms)^\s*fn: l2_program_build [^\r\n]*\r?\n(?<body>.*?)^\s*end: l2_program_build[ \t]*$')
    if ($bodies.Count -gt 1) { throw 'More than one emitted program builder' }
    if ($bodies.Count -eq 1) { return $bodies[0].Groups['body'].Value }
    # Pure controls may pass an isolated construction fragment, not a file.
    if ($Text -match '(?m)^\s*(?:fn|sub):') { throw 'Emitted construction lacks its program builder' }
    return $Text
}
function Get-BuilderIdentityFacts([string]$Text) {
    $Text = Get-BuilderSourceBody $Text
    $aliases = @{}
    $allocated = @{}
    $descriptors = @{}
    $native = @{}
    $rootWrites = @{}
    $graphWrites = @{}
    $parentWrites = @{}
    $numericWrites = @{}
    $leaf = ''
    $leafAllocation = 0
    $handle = '(?:l2_(?:rw|sc|b)\d+|l2_nsp\[\d+\])'
    $identity = '(?:' + $handle + '|l2_entry_unit|lmx_arena_ref_struct\(l2_entry_unit, \d+U\))'
    function Snapshot-BuilderIdentity([string]$Value) {
        $value = Resolve-BuilderIdentity $aliases $Value
        if ($value -match '^lmx_arena_ref_struct\(l2_entry_unit, (\d+)U\)$') {
            $slot = [int]$Matches[1]
            if ($rootWrites.ContainsKey($slot) -and $descriptors.ContainsKey([string]$rootWrites[$slot])) { return [string]$rootWrites[$slot] }
            if ($rootWrites.ContainsKey($slot) -and [string]$rootWrites[$slot] -eq '') { return '' }
            return $value
        }
        if ($value -eq 'l2_entry_unit' -or $allocated.ContainsKey($value)) { return $value }
        return ''
    }
    foreach ($line in ($Text -split '\r?\n')) {
        if ($line -match '^\s*#') { continue }
        if ($line -match '^\s*l2_entry_leaf:\s*(.+?)\s*$') {
            $leaf = ''
            $value = $Matches[1]
            if ($value -match ('^' + $identity + '$')) { $leaf = Snapshot-BuilderIdentity $value }
            elseif ($value -match '^lmx_(struct|node)_new_(owned|profiled)\(') {
                # This reusable local receives distinct existing allocations.
                # The tag is only this observer's statement identity.
                $leafAllocation++
                $leaf = 'builder-allocation:' + $leafAllocation
                $allocated[$leaf] = $true
                $descriptors[$leaf] = $true
            }
        }
        if ($line -match ('^\s*(?:@: Lmx )?(?<name>' + $handle + ')(?::)?\s+(?<value>.+?)\s*$')) {
            $name = $Matches['name']; $value = $Matches['value']
            $snapshot = ''
            if ($value -eq 'l2_entry_leaf') { $snapshot = $leaf }
            elseif ($value -match ('^' + $identity + '$')) { $snapshot = Snapshot-BuilderIdentity $value }
            $aliases.Remove($name)
            if ($name -match '^l2_nsp\[') {
                if ($descriptors.ContainsKey($name) -and $value -match '^lmx_(struct|node)_new_(owned|profiled)\(') { throw ('Builder identity has more than one allocation for ' + $name) }
                if ($descriptors.ContainsKey($name) -and $snapshot -ne $name) { throw ('Builder identity changes an allocated namespace handle: ' + $name) }
                if ($value -match '^lmx_(struct|node)_new_(owned|profiled)\(') { $descriptors[$name] = $true }
            }
            if ($allocated.ContainsKey($name) -and $snapshot -ne $name) {
                throw ('Builder rebinds an allocated stable handle: ' + $name)
            }
            if ($value -match '^lmx_(?:(struct|node)_new_(owned|profiled)|walk_(frame|plain))\(') { $allocated[$name] = $true }
            elseif ($snapshot -eq $name) { $allocated[$name] = $true }
            elseif ($snapshot -ne '') { $aliases[$name] = $snapshot }
            else { $allocated.Remove($name); $aliases[$name] = '' }
        }
        if ($line -match '^\s*l2_entry_leaf\\native: \(cast: \(LmxEntry\) l2_m(\d+)_tr\)\s*$') {
            $native[[int]$Matches[1]] = $leaf
        }
        if ($line -match ('^\s*(?<name>' + $handle + ')\\parent: (?<owner>' + $identity + ')\s*$')) {
            $object = Snapshot-BuilderIdentity $Matches['name']
            $owner = Snapshot-BuilderIdentity $Matches['owner']
            if ($object -ne '' -and $owner -ne '') { $parentWrites[$object] = $owner }
        }
        if ($line -notmatch '^\s*if:') { continue }
        # Helpers allocate a new typed cell and replace the same graph slot.
        # Reference and helper writes therefore share one ordered event stream.
        $writePattern = 'lmx_arena_ref_store\((?<owner>' + $identity + '), (?<slot>\d+)U, (?<value>.*?)\) != 0|lmx_walk_store_(?<kind>[A-Za-z0-9_]+)\(l2_program_arena, (?<owner>l2_rw\d+), (?<slot>\d+)U, (?<value>.*?)\) != c\.LMX_WALK_OK'
        foreach ($m in [regex]::Matches($line, $writePattern)) {
            $owner = Snapshot-BuilderIdentity $m.Groups['owner'].Value
            if ($owner -eq '') { continue }
            $slot = [int]$m.Groups['slot'].Value
            $key = $owner + ':' + $slot
            $numericWrites.Remove($key)
            $child = ''
            $value = $m.Groups['value'].Value
            $kind = $m.Groups['kind'].Value
            if ($kind -eq '' -and $value -match '^\(cast: \(@: void\) (?<child>.+)\)$') {
                $child = $Matches['child']
                if ($child -eq 'l2_entry_leaf') { $child = $leaf }
                elseif ($child -match ('^' + $identity + '$')) { $child = Snapshot-BuilderIdentity $child }
                # Other stored values (for example a primitive callable cell)
                # keep their expression identity. They are not inferred Lmx
                # allocations and cannot become executable by naming alone.
            }
            # Explicit zero or a later different value replaces an earlier edge.
            $role = ''
            if ($kind -eq '') {
                $roleMatch = [regex]::Match($value, '^lmx_arena_ref_value\(l2_rw_roles, \(cast: \(size_t\) c\.LMX_WALK_OP_(?<role>[A-Z_]+)\)\)$')
                if ($roleMatch.Success) { $role = $roleMatch.Groups['role'].Value }
            } elseif ($kind -in @('size','int') -and $value -match '^(?<number>-?\d+)U?$') {
                $numericWrites[$key] = [pscustomobject]@{ Node = $owner; Slot = $slot; Kind = $kind; Value = [int64]$Matches['number'] }
            }
            $graphWrites[$key] = [pscustomobject]@{ Parent = $owner; Slot = $slot; Value = $value; Child = $child; Role = $role }
            if ($owner -eq 'l2_entry_unit') { $rootWrites[$slot] = $child }
        }
    }
    $rootSlots = @{}
    foreach ($slot in $rootWrites.Keys) {
        # Stored values and native bindings captured the object at that line.
        # A later rebinding of its construction variable cannot change it.
        $child = [string]$rootWrites[$slot]
        if ($child -eq '' -or -not $descriptors.ContainsKey($child)) { continue }
        if (-not $rootSlots.ContainsKey($child)) { $rootSlots[$child] = @() }
        $rootSlots[$child] += [int]$slot
    }
    $canonical = @{}
    foreach ($name in $rootSlots.Keys) {
        if ($rootSlots[$name].Count -eq 1) { $canonical[$name] = 'lmx_arena_ref_struct(l2_entry_unit, ' + $rootSlots[$name][0] + 'U)' }
    }
    return [pscustomobject]@{ Text = $Text; Aliases = $aliases; Descriptors = $descriptors; Native = $native; RootWrites = $rootWrites; RootSlots = $rootSlots; Canonical = $canonical; GraphWrites = $graphWrites; ParentWrites = $parentWrites; NumericWrites = $numericWrites }
}

# Parse the emitted walker graph once.  A constructor's owner is allocation context, not
# attachment: executable reachability starts at the root sequence, follows STORED operators and
# bodies, and activates another callable sequence only through a reachable CALL/EXEC.
function Get-WalkGraphFacts([string]$Text) {
    $builder = Get-BuilderIdentityFacts $Text
    $Text = $builder.Text
    $frames = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) lmx_walk_frame\([^\r\n]*?, (?<owner>l2_rw\d+|l2_entry_unit), c\.LMX_WALK_OP_(?<op>[A-Z_]+), (?<width>\d+)U\)[ \t]*$')) {
        $frames[$m.Groups['name'].Value] = [pscustomobject]@{
            Name = $m.Groups['name'].Value; Owner = $m.Groups['owner'].Value
            Op = $m.Groups['op'].Value; Width = [int]$m.Groups['width'].Value; Index = -1
        }
    }
    $plain = @{}
    $plainOwners = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) lmx_walk_plain\(l2_program_arena, (?<owner>l2_(?:rw|sc|b)\d+|l2_entry_unit), (?<width>\d+)U\)[ \t]*$')) {
        $plain[$m.Groups['name'].Value] = [int]$m.Groups['width'].Value
        $plainOwners[$m.Groups['name'].Value] = $m.Groups['owner'].Value
    }
    $aliases = @{}
    $descriptors = @{}
    foreach ($name in $builder.Canonical.Keys) { $aliases[$name] = $builder.Canonical[$name] }
    foreach ($name in $builder.Descriptors.Keys) {
        $descriptor = $name
        if ($builder.Canonical.ContainsKey($name)) { $descriptor = $builder.Canonical[$name] }
        $descriptors[$descriptor] = $true
    }
    foreach ($name in $builder.Aliases.Keys) {
        $value = Resolve-BuilderIdentity $builder.Aliases $name
        if ($builder.Canonical.ContainsKey($value)) { $value = $builder.Canonical[$value] }
        # sc -> rw is a presentation mapping below, never its reverse too.
        if ($name -match '^l2_rw\d+$' -and $value -match '^(?:l2_rw\d+|l2_entry_unit|l2_nsp\[\d+\]|lmx_arena_ref_struct\(l2_entry_unit, \d+U\))$') { $aliases[$name] = $value }
    }
    # Source-owned containers are allocated once, then filled through their
    # ordinary rw aliases. Observe that same allocation and its shared role;
    # constructor spelling is not the graph's operation identity.
    $sourceWidths = @{}
    foreach ($m in [regex]::Matches($Text, 'lmx_arena_refs_open_owned\(l2_program_arena, (?<name>l2_sc\d+), (?<width>\d+)U\)')) {
        $sourceWidths[$m.Groups['name'].Value] = [int]$m.Groups['width'].Value
    }
    foreach ($source in $sourceWidths.Keys) { $plain[$source] = $sourceWidths[$source] }
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*@: Lmx (?<name>l2_rw\d+) (?<value>l2_sc\d+)[ \t]*$')) {
        $name = $m.Groups['name'].Value
        $source = $m.Groups['value'].Value
        if (-not $sourceWidths.ContainsKey($source)) { continue }
        # Presentation must not undo the line-time identity snapshot. A
        # reusable rw alias that later changes is no longer this allocation.
        if ((Resolve-BuilderIdentity $builder.Aliases $name) -ne $source) { continue }
        $aliases[$source] = $name
        # Width belongs to the allocation. Its role/parent are derived from
        # the final physical writes below, not from an earlier alias spelling.
    }
    foreach ($name in $builder.Aliases.Keys) {
        $source = Resolve-BuilderIdentity $builder.Aliases $name
        if ($name -match '^l2_rw\d+$' -and $sourceWidths.ContainsKey($source) -and $aliases[$source] -ne $name) { $aliases[$name] = $source }
    }
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*(?<name>l2_b\d+): (?<value>l2_sc\d+)[ \t]*$')) {
        $aliases[$m.Groups['name'].Value] = $m.Groups['value'].Value
    }
    function Resolve-WalkName([string]$Name) {
        $seen = @{}
        while ($aliases.ContainsKey($Name)) {
            if ($seen.ContainsKey($Name)) { return '' }
            $seen[$Name] = $true; $Name = $aliases[$Name]
        }
        return $Name
    }
    # The generated builder is straight-line.  Observe the graph after its final write to a
    # (parent, slot), including an explicit zero which removes an earlier edge.
    $storeMap = @{}
    # The reusable builder locals are handles, not graph identities. Resolve
    # each actual signature-part allocation before the next handle assignment.
    # Ordinary CALL reads the callee's real header, not a duplicate tail node.
    $headerWitnesses = @{}
    $headerLeaf = ''
    $headerPart = ''
    $headerCell = ''
    $headerSerial = 0
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -match '^\s*l2_entry_leaf: (l2_entry_unit|l2_nsp\[\d+\]|lmx_arena_ref_struct\(l2_entry_unit, \d+U\))\s*$') {
            $headerLeaf = Resolve-WalkName (Resolve-BuilderIdentity $builder.Aliases $Matches[1])
            $headerPart = ''; $headerCell = ''
        } elseif ($line -match '^\s*l2_entry_leaf:') { $headerLeaf = ''; $headerPart = ''; $headerCell = '' }
        if ($headerLeaf -ne '' -and $line -match '^\s*l2_fkid: lmx_struct_new_owned\(l2_entry_leaf, l2_program_arena\)\s*$') {
            $headerSerial++
            $headerPart = 'signature-part:' + $headerSerial
            $headerCell = ''
            $plain[$headerPart] = 0
        }
        if ($headerPart -ne '' -and $line -match 'lmx_arena_ref_store\(l2_entry_leaf, (\d+)U, \(cast: \(@: void\) l2_fkid\)\)') {
            $slot = [int]$Matches[1]
            $storeMap[$headerLeaf + ':' + $slot] = [pscustomobject]@{ Parent = $headerLeaf; Slot = $slot; Value = $headerPart; Child = $headerPart; Role = '' }
        }
        if ($headerPart -ne '' -and $line -match 'lmx_arena_refs_open_owned\(l2_program_arena, l2_fkid, (\d+)U\)') { $plain[$headerPart] = [int]$Matches[1] }
        if ($headerPart -ne '' -and $line -match 'lmx_arena_ref_store\(l2_fkid, (\d+)U, \(cast: \(@: void\) (lmx_arena_ref_struct\(l2_entry_unit, \d+U\)|l2_nsp\[\d+\])\)\)') {
            $slot = [int]$Matches[1]
            $child = Resolve-WalkName $Matches[2]
            $storeMap[$headerPart + ':' + $slot] = [pscustomobject]@{ Parent = $headerPart; Slot = $slot; Value = $child; Child = $child; Role = '' }
        }
        if ($headerPart -ne '' -and $line -match '^\s*l2_entry_slot: lmx_arena_ref_cell\(l2_fkid, (\d+)U\)\s*$') { $headerCell = $headerPart + ':' + $Matches[1] }
        elseif ($line -match '^\s*l2_entry_slot:') { $headerCell = '' }
        if ($headerCell -ne '' -and $line -match '^\s*l2_entry_slot\[0\]: (.+)$') { $headerWitnesses[$headerCell] = $Matches[1] }
    }
    # The shared builder pass snapshots identities at each write, before a
    # later alias assignment. Only presentation canonicalization happens here.
    foreach ($write in $builder.GraphWrites.Values) {
        $parent = Resolve-WalkName $write.Parent
        if ($parent -eq '') { continue }
        $store = [pscustomobject]@{ Parent = $parent; Slot = $write.Slot; Value = $write.Value; Child = (Resolve-WalkName $write.Child); Role = $write.Role }
        $storeMap[$parent + ':' + $store.Slot] = $store
    }
    $stores = @($storeMap.Values)
    $filledParents = @{}
    foreach ($name in $builder.ParentWrites.Keys) {
        $actual = Resolve-WalkName $name
        if ($actual -ne '') { $filledParents[$actual] = Resolve-WalkName $builder.ParentWrites[$name] }
    }
    # A reserved plain allocation may acquire its operator role during FILL
    # through another stable handle. Resolve the actual allocation and final
    # role store; neither a fresh alias nor constructor spelling is an object.
    foreach ($name in @($plain.Keys)) {
        $actual = Resolve-WalkName $name
        if ($actual -eq '') { continue }
        $roleKey = $actual + ':0'
        if (-not $storeMap.ContainsKey($roleKey) -or $storeMap[$roleKey].Role -eq '') { continue }
        $owner = ''
        if ($plainOwners.ContainsKey($name)) { $owner = Resolve-WalkName $plainOwners[$name] }
        if ($filledParents.ContainsKey($actual)) { $owner = $filledParents[$actual] }
        $frames[$actual] = [pscustomobject]@{
            Name = $actual; Owner = $owner; Op = $storeMap[$roleKey].Role
            Width = [int]$plain[$name]; Index = -1
        }
    }
    # Frame constructors initialize a role too. A subsequent explicit child0
    # store supersedes it just as it supersedes a deferred plain role.
    foreach ($name in @($frames.Keys)) {
        $roleKey = $name + ':0'
        if (-not $storeMap.ContainsKey($roleKey)) { continue }
        $role = $storeMap[$roleKey].Role
        if ($role -eq '') { $role = 'UNKNOWN' }
        $frames[$name].Op = $role
    }
    $sizes = @{}
    $ints = @{}
    foreach ($write in $builder.NumericWrites.Values) {
        $actual = Resolve-WalkName $write.Node
        if ($actual -eq '') { continue }
        $key = $actual + ':' + $write.Slot
        if ($write.Kind -eq 'size') { $sizes[$key] = $write.Value }
        else { $ints[$key] = $write.Value }
    }
    $primitiveFns = @{}
    foreach ($m in [regex]::Matches($Text, '(?m)^[ \t]*(?<primitive>l2_rwp\d+)\\fn: (?<fn>[A-Za-z_][A-Za-z0-9_]*)[ \t]*$')) { $primitiveFns[$m.Groups['primitive'].Value] = $m.Groups['fn'].Value }
    $witnesses = $headerWitnesses
    $cellKey = ''
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -match '^\s*l2_entry_slot: lmx_arena_ref_cell\((l2_rw\d+|l2_sc\d+), (\d+)U\)\s*$') { $cellKey = (Resolve-WalkName $Matches[1]) + ':' + $Matches[2] }
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
        if ($Op -eq 'IF' -and $Slot -eq 3) { return $true }
        # Primitive frames carry their executable operands after fn/signature metadata.
        if (($Op -eq 'PRIM' -or $Op -eq 'PRIM_PUB') -and $Slot -ge 3) { return $true }
        # ARG's optional lexical fallback is evaluated only when no dynamic binding exists;
        # retaining it is therefore executable graph coverage too.
        if ($Op -eq 'ARG' -and $Slot -eq 2) { return $true }
        return $false
    }
    function Walk-IsBodySlot([string]$Op, [int]$Slot) {
        if ($Op -eq 'IF' -and $Slot -eq 2) { return $true }
        if ($Op -eq 'ELSE' -and $Slot -eq 1) { return $true }
        if (($Op -eq 'WHILE' -or $Op -eq 'UNTIL') -and $Slot -eq 2) { return $true }
        if ($Op -eq 'FOR' -and ($Slot -eq 2 -or $Slot -eq 3)) { return $true }
        return $false
    }

    $callLayouts = @{}
    $layoutGraph = [pscustomobject]@{ Frames = $frames; Plain = $plain; PlainOwners = $plainOwners; Stores = $stores; Sizes = $sizes }
    foreach ($name in $frames.Keys) {
        if ($frames[$name].Op -in @('CALL','EXEC')) { $callLayouts[$name] = Get-WalkCallLayout $layoutGraph $name }
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
                $evaluates = Walk-EvaluatesSlot $op $s.Slot $frames[$s.Parent].Width
                if ($op -in @('CALL','EXEC')) {
                    $layout = $callLayouts[$s.Parent]
                    $evaluates = $null -ne $layout -and $s.Slot -ge $layout.ArgBase -and $s.Slot -lt ($layout.ArgBase + $layout.Arity)
                    if ($null -ne $layout -and $layout.ArgBase -eq 5 -and $s.Slot -eq 2) { $evaluates = $true }
                }
                if ($evaluates -and $frames.ContainsKey($child) -and -not $reachable.ContainsKey($child)) { $reachable[$child] = $true; $changed = $true }
                if ((Walk-IsBodySlot $op $s.Slot) -and $child -ne '' -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
                if ($op -eq 'CALL' -and $s.Slot -eq 1 -and $child -ne '' -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
                if ($op -eq 'EXEC' -and $s.Slot -eq 2 -and $child -ne '' -and -not $frames.ContainsKey($child) -and -not $exec.ContainsKey($child)) { $exec[$child] = $true; $changed = $true }
            }
        }
    } while ($changed)
    return [pscustomobject]@{ Frames = $frames; Plain = $plain; PlainOwners = $plainOwners; Stores = $stores; Sizes = $sizes; Ints = $ints; PrimitiveFns = $primitiveFns; Witnesses = $witnesses; Descriptors = $descriptors; Reachable = $reachable; Exec = $exec }
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

function Get-WalkCallLayout($Graph, [string]$Name) {
    if (-not $Graph.Frames.ContainsKey($Name)) { return $null }
    $frame = $Graph.Frames[$Name]
    if ($frame.Op -notin @('CALL','EXEC')) { return $null }
    $callee = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 1 -and $_.Child -ne '' }) | Select-Object -First 1
    $tail = @($Graph.Stores | Where-Object { $_.Parent -eq $Name -and $_.Slot -eq 3 -and $_.Child -ne '' }) | Select-Object -First 1
    $contracts = @()
    if ($frame.Op -eq 'CALL' -and $null -ne $callee) { $contracts += $callee.Child }
    if ($null -ne $tail -and $tail.Child -notin $contracts) { $contracts += $tail.Child }
    foreach ($contract in $contracts) {
        $parts = @()
        foreach ($slot in 0,1) {
            $part = @($Graph.Stores | Where-Object { $_.Parent -eq $contract -and $_.Slot -eq $slot -and $_.Child -ne '' })
            if ($part.Count -eq 1 -and $Graph.Plain.ContainsKey($part[0].Child)) { $parts += $part[0].Child }
        }
        if ($parts.Count -ne 2 -or $Graph.Plain[$parts[1]] -notin @(0,1)) { continue }
        $actualHeader = $frame.Op -eq 'CALL' -and $null -ne $callee -and $contract -eq $callee.Child
        if ($actualHeader) {
            # These identities were observed at actual header allocations.
            # Two arbitrary source Structures are not a method signature.
            if ($parts[0] -notmatch '^signature-part:' -or $parts[1] -notmatch '^signature-part:') { continue }
        } else {
            if (-not $Graph.PlainOwners.ContainsKey($contract) -or $Graph.PlainOwners[$contract] -ne $Name) { continue }
            if ($Graph.Plain[$contract] -ne 2 -or $Graph.PlainOwners[$parts[0]] -ne $contract -or $Graph.PlainOwners[$parts[1]] -ne $contract) { continue }
        }
        $arity = $Graph.Plain[$parts[0]]
        # A direct compact CALL carries only the actual callee and inputs.
        # Neither its first nor its second actual determines the layout.
        if ($actualHeader -and $frame.Width -eq (2 + $arity)) {
            return [pscustomobject]@{ Contract = $contract; Arity = $arity; ArgBase = 2; Catches = 0 }
        }
        $catches = 0
        if ($Graph.Sizes.ContainsKey($Name + ':4')) { $catches = $Graph.Sizes[$Name + ':4'] }
        if ($frame.Width -eq (5 + $arity + 3 * $catches)) {
            # An explicit receiving contract belongs to the long layout.
            # Prefer it over the callee's header when both are present.
            if ($null -ne $tail -and $contract -ne $tail.Child) { continue }
            return [pscustomobject]@{ Contract = $contract; Arity = $arity; ArgBase = 5; Catches = $catches }
        }
    }
    return $null
}

function Get-WalkCallContractNode($Graph, [string]$Name) {
    $layout = Get-WalkCallLayout $Graph $Name
    if ($null -eq $layout) { return $null }
    return $layout.Contract
}

function Test-WalkCallContract($Graph, [string]$Name, [int]$Arity, $Void, $InputKinds = $null, [string]$ResultKind = '') {
    $layout = Get-WalkCallLayout $Graph $Name
    if ($null -eq $layout) { return $false }
    $contract = $layout.Contract
    $edge = [pscustomobject]@{ Child = $contract }
    $parts = @()
    foreach ($slot in 0,1) {
        $part = @($Graph.Stores | Where-Object { $_.Parent -eq $edge.Child -and $_.Slot -eq $slot }) | Select-Object -First 1
        if ($null -eq $part -or -not $Graph.Plain.ContainsKey($part.Child)) { return $false }
        $parts += $part.Child
    }
    if ($Arity -lt 0) {
        $Arity = $layout.Arity
    }
    if ($Arity -ne $layout.Arity) { return $false }
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
        if ($null -eq $callee) { return $false }
        $layout = Get-WalkCallLayout $Graph $Name
        if ($null -eq $layout) { return $false }
        if ($layout.ArgBase -eq 5 -and $null -ne $receiver -and $callee.Child -ne $receiver.Child) { return $false }
        if ($Shape.PSObject.Properties['CalleeSlot'] -and $callee.Child -ne ('lmx_arena_ref_struct(l2_entry_unit, ' + $Shape.CalleeSlot + 'U)')) { return $false }
        $resultKind = ''
        $inputKinds = $null
        if ($Shape.PSObject.Properties['ResultKind']) { $resultKind = $Shape.ResultKind }
        if ($Shape.PSObject.Properties['InputKinds']) { $inputKinds = $Shape.InputKinds }
        if (-not (Test-WalkCallContract $Graph $Name -1 $null $inputKinds $resultKind)) { return $false }
    }
    if ($Shape.PSObject.Properties['NextShape']) {
        $incoming = @($Graph.Stores | Where-Object { $_.Child -eq $Name -and $Graph.Exec.ContainsKey($_.Parent) })
        if ($incoming.Count -ne 1) { return $false }
        $next = @($Graph.Stores | Where-Object { $_.Parent -eq $incoming[0].Parent -and $_.Slot -eq ($incoming[0].Slot + 1) })
        if ($next.Count -ne 1 -or -not (Test-WalkShapeNode $Graph $next[0].Child $Shape.NextShape)) { return $false }
    }
    return $true
}

# Relationship witnesses for native execution WITH the original executable graph retained.
# Method numbers are fixture-local declaration order; rwN/child-slot numbers are discovered
# from the native binding and matched back to that same CALL, not pinned as global ordinals.
function Get-DispatchMethodSlots([string]$Text, [int[]]$Methods) {
    $builder = Get-BuilderIdentityFacts $Text
    foreach ($method in $Methods) {
        $identity = ''
        if ($builder.Native.ContainsKey($method)) { $identity = [string]$builder.Native[$method] }
        if ($identity -match '^lmx_arena_ref_struct\(l2_entry_unit, (\d+)U\)$') {
            $slot = [int]$Matches[1]
            if ($builder.RootWrites.ContainsKey($slot) -and [string]$builder.RootWrites[$slot] -ne $identity) { throw "Dispatch tap's captured unit slot no longer holds native method $method" }
            [string]$slot; continue
        }
        if ($builder.RootSlots.ContainsKey($identity) -and $builder.RootSlots[$identity].Count -eq 1) { [string]$builder.RootSlots[$identity][0]; continue }
        throw "Dispatch tap lacks a unique physical unit slot for native method $method"
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
        $places = [System.Collections.Generic.HashSet[string]]::new()
        $reads = 0
        foreach ($line in ($Text -split '\r?\n')) {
            if ($line -match '^\s*(#|$)') { continue }
            $indent = $line.Length - $line.TrimStart().Length
            while ($guards.Count -gt 0 -and $guards[$guards.Count - 1].Indent -ge $indent) { $guards.RemoveAt($guards.Count - 1) }
            if ($line -match '^\s*l2_t\d+: (?<value>.+)$') {
                # A load can occur inside the received comparison expression;
                # its new captured place is not required to have the old
                # standalone-temporary spelling. Backing declarations and
                # element STORE destinations do not match this RHS boundary.
                # This numeric fixture contains no quoted RHS expressions.
                # Inline comments and address-of are not value loads; repeating
                # one captured place cannot replace a missing independent arm.
                $value = $Matches.value -replace '#.*$', ''
                $value = $value -replace '@\s*l2_a(?:i)?\d+_data\[[^\]]+\]', ''
                $loads = [regex]::Matches($value, '\bl2_a(?:i)?\d+_data\[[^\]]+\]')
                foreach ($load in $loads) {
                    if ($places.Add(($load.Value -replace '\s+', ''))) { $reads++ }
                }
                if ($loads.Count -gt 0 -and -not @($guards | Where-Object { $_.Lazy }).Count) { return 'array RHS load escaped its lazy logical guard' }
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
    if ($Fixture.PSObject.Properties['PadOwnCells']) {
        $found = 0
        foreach ($pad in $graph.Frames.Values) {
            if ($pad.Op -ne 'PAD' -or $pad.Width -ne 3) { continue }
            $cellKey = $pad.Name + ':1'
            if (-not $graph.Witnesses.ContainsKey($cellKey) -or $graph.Witnesses[$cellKey] -notmatch '^lmx_int_new_owned\(') { return ('PAD ' + $pad.Name + ' does not own its canonical parameter cell') }
            $found++
        }
        if ($found -ne $Fixture.PadOwnCells) { return ('found ' + $found + ' owned numeric PAD parameter cells, expected ' + $Fixture.PadOwnCells) }
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
            $callPattern = '@: Lmx (?<frame>l2_rw\d+) lmx_walk_frame\([^\r\n]*, c\.LMX_WALK_OP_CALL, (?<width>\d+)U\)'
            $found = 0
            foreach ($call in [regex]::Matches($Text, $callPattern)) {
                $width = [int]$call.Groups['width'].Value
                if ($width -ne (5 + $witness.Arity) -and $width -ne (2 + $witness.Arity)) { continue }
                $frame = $call.Groups['frame'].Value
                if (-not $graph.Reachable.ContainsKey($frame)) { continue }
                $calleeEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq 1 -and $_.Child -eq $callee }) | Select-Object -First 1
                if ($null -eq $calleeEdge) { continue }
                $found++
                $layout = Get-WalkCallLayout $graph $frame
                if ($null -eq $layout) { return ('CALL ' + $frame + ' has no complete physical contract layout') }
                $argBase = $layout.ArgBase
                $receiverEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq 2 -and $_.Child -ne '' }) | Select-Object -First 1
                if ($argBase -eq 5 -and $null -ne $receiverEdge -and $receiverEdge.Child -ne $callee) {
                    return ('CALL ' + $frame + ' lost its callable occurrence receiver')
                }
                $isVoid = [bool]($witness.PSObject.Properties['Void'] -and $witness.Void)
                if (-not $witness.PSObject.Properties['InputKinds'] -or (-not $isVoid -and -not $witness.PSObject.Properties['ResultKind'])) { return 'GraphCalls witness lacks explicit declared types' }
                if (-not (Test-WalkCallContract $graph $frame $witness.Arity $isVoid $witness.InputKinds $witness.ResultKind)) { return ('CALL ' + $frame + ' lost its declared input/result contract') }
                if ($witness.PSObject.Properties['Ints']) {
                    for ($argIndex = 0; $argIndex -lt $witness.Ints.Count; $argIndex++) {
                        $argEdge = @($graph.Stores | Where-Object { $_.Parent -eq $frame -and $_.Slot -eq ($argBase + $argIndex) -and $_.Child -match '^l2_rw\d+$' }) | Select-Object -First 1
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
            $candidates = @($graph.Reachable.Keys)
            $scope = 'reachable'
            # Source topology also includes dormant bodies. Select an exact
            # stored place without pretending that its method was executed.
            if ($shape.PSObject.Properties['StoredAt']) {
                $place = $shape.StoredAt
                if (-not $place.PSObject.Properties['Method'] -or -not $place.PSObject.Properties['Path']) { return 'stored graph shape lacks a method and source path' }
                $slots = @(Get-DispatchMethodSlots $Text @([int]$place.Method))
                if ($slots.Count -ne 1) { return 'stored graph shape has no unique method occurrence' }
                $candidates = @('lmx_arena_ref_struct(l2_entry_unit, ' + $slots[0] + 'U)')
                foreach ($slot in $place.Path) {
                    $parent = $candidates[0]
                    $edges = @($graph.Stores | Where-Object { $_.Parent -eq $parent -and $_.Slot -eq [int]$slot -and $_.Child -ne '' })
                    if ($edges.Count -ne 1) { return ('stored graph shape lost its unique source edge at slot ' + $slot) }
                    $candidates = @($edges[0].Child)
                }
                $scope = 'source-attached'
            }
            foreach ($name in $candidates) { if (Test-WalkShapeNode $graph $name $shape) { $matches += $name } }
            if ($matches.Count -ne $shape.Count) { return ($shape.Op + '/' + $shape.Width + ' has ' + $matches.Count + ' ' + $scope + ' matching shapes, expected ' + $shape.Count) }
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
# it has no private children/settings tail: runtime membership is Thread.children,
# while launch settings stay in the host stub. A translation-sized C array exports the exact root
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
# Exact ordered graph expectation for one declaration/assignment witness.
# No search-ahead or generated temporary names: every actual operand slot is read.
$criticalDeclExactShape = @('shape', 'exact',
    'intvalue', '0',
    'init', 'SET', 'fields', 'role', '8', '1',
        'OWN', 'fields', 'role', '4', '0', 'null', 'sizevalue', '0', 'endfields',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '5', 'endfields', 'endfields',
    'intvalue', '0',
    'init', 'SET', 'fields', 'role', '8', '1',
        'OWN', 'fields', 'role', '4', '0', 'null', 'sizevalue', '2', 'endfields',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '8', 'endfields', 'endfields',
    'assign', 'SET', 'fields', 'role', '8', '0',
        'OWN', 'fields', 'role', '4', '0', 'null', 'sizevalue', '0', 'endfields',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '6', 'endfields', 'endfields',
    'PRIM_PUB', 'fields', 'role', '33', '0', 'primitive', 'null',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '7', 'endfields', 'endfields',
    'RET', 'fields', 'role', '1', '0', 'endfields', 'endshape')

# Unknown heads retain genuine literal-bodied Structures. These expectations
# cover the complete graph, not just accepted translation or a positive exit.
$criticalLiteralOp = {
    param($value)
    @('owned','LIT','fields','role','3','0','intvalue',[string]$value,'endfields')
}
$criticalLiteralOwn = {
    param($slot)
    @('owned','OWN','fields','role','4','0','null','sizevalue',[string]$slot,'endfields')
}
$criticalLiteralCall = @('owned','CALL','fields','role','2','0','same','endfields')
$criticalLiteralReturn0 = @('owned','RET','fields','role','1','0') + (& $criticalLiteralOp 0) + @('endfields')
$criticalLiteralRootReturn = @('owned','RET','fields','role','1','0','endfields')
$criticalLiteralPublish7 = @('owned','PRIM_PUB','fields','role','33','0','primitive','null') + (& $criticalLiteralOp 7) + @('endfields')
$criticalLiteralSignature = @('owned','struct','fields','endfields','owned','struct','fields','int','endfields')
$criticalLiteralRoot = {
    param($head, $value)
    @('0','namepath','1','0',$head,'widthpath','1','0','1','parentpath','1','0','0',
      'intpath','2','0','0',[string]$value,'shape','exact','owned','struct','fields','intvalue',[string]$value,'endfields') +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
}
$criticalLiteralMethod = {
    param($method, $head, $value)
    @('0','namepath','1','0',$method,'namepath','2','0','2',$head,'widthpath','1','0','4',
      'widthpath','2','0','0','0','widthpath','2','0','2','1','parentpath','1','0','0',
      'parentpath','2','0','2','1','0','intpath','3','0','2','0',[string]$value,
      'samepath','3','2','2','1','1','0','shape','exact','owned','struct','fields') +
    $criticalLiteralSignature + @('owned','struct','fields','intvalue',[string]$value,'endfields') +
    $criticalLiteralReturn0 + @('endfields','int','owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 1) + $criticalLiteralCall + @('endfields') +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
}
$criticalLiteralUnknownInput = @('0','namepath','1','0','peek','namepath','1','1','m','namepath','2','0','2','k',
    'widthpath','1','0','4','widthpath','1','1','8','widthpath','2','0','0','0',
    'parentpath','2','0','2','1','0','cellpath','3','0','2','0','1','15',
    'samepath','4','1','6','2','1','1','0','samepath','3','4','2','1','1','1',
    'shape','exact','owned','struct','fields') + $criticalLiteralSignature +
    @('owned','struct','fields','numvalue','unsigned','1','endfields') + $criticalLiteralReturn0 +
    @('endfields','owned','struct','fields') + $criticalLiteralSignature +
    @('int','owned','init','SET','fields','role','8','1') + (& $criticalLiteralOwn 2) + (& $criticalLiteralOp 5) +
    @('endfields','int','owned','init','SET','fields','role','8','1') + (& $criticalLiteralOwn 4) + (& $criticalLiteralOp 0) +
    @('endfields','owned','assign','SET','fields','role','8','0') + (& $criticalLiteralOwn 4) + $criticalLiteralCall +
    @('endfields','owned','RET','fields','role','1','0') + (& $criticalLiteralOwn 4) +
    @('endfields','endfields','int','owned','init','SET','fields','role','8','1') + (& $criticalLiteralOwn 2) + (& $criticalLiteralOp 0) +
    @('endfields','owned','assign','SET','fields','role','8','0') + (& $criticalLiteralOwn 2) + $criticalLiteralCall +
    @('endfields') + $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')

# External applications retain the same actual-value readers as language
# expressions. Check whole source order, native capability and real bindings;
# effect-only success cannot establish retained source fidelity.
$criticalExternalLitSize = {
    param([int]$value)
    @('owned','LIT','fields','role','3','0','sizevalue',[string]$value,'endfields')
}
$criticalExternalOwn = @('owned','OWN','fields','role','4','0','null','sizevalue','2','endfields')
$criticalExternalArg = @('owned','ARG','fields','role','5','0','sizevalue','0','null','size','endfields')
$criticalExternalApplication = {
    param([string]$name, [string[]]$actuals)
    @('owned','spell',$name,'fields','role','45','0','owned','struct','fields') +
    $actuals + @('endfields','endfields')
}
# Cast's first field describes a type; its remaining body is an ordinary
# value expression. A homonymous own cell must not replace the type leaf,
# and a known value formal must not survive as an unresolved source symbol.
$criticalCastInner = & $criticalExternalApplication 'cast' (
    @('owned','struct','fields','spell','L2TestByte','endfields') + $criticalExternalArg)
$criticalCastOuter = & $criticalExternalApplication 'cast' (
    @('owned','struct','fields','spell','int','endfields') + $criticalCastInner)
$criticalCastShape = @('widthpath','0','4','widthpath','1','1','9',
    'shape','exact','owned','spell','predef',
    'owned','struct','fields',
      'owned','struct','fields','size','endfields',
      'owned','struct','fields','int','endfields','int',
      'owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 2) + (& $criticalLiteralOp 91) +
    @('endfields','int','owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 4) + (& $criticalLiteralOp 0) +
    @('endfields','owned','SET','fields','role','8','0') +
    (& $criticalLiteralOwn 4) + $criticalCastOuter +
    @('endfields','owned','IF','fields','role','13','0',
      'owned','SUB','fields','role','10','0') + (& $criticalLiteralOp 1) +
    @('owned','EQ','fields','role','12','0') +
    (& $criticalLiteralOwn 2) + (& $criticalLiteralOp 91) +
    @('endfields','endfields','owned','struct','fields',
      'owned','RET','fields','role','1','0') + (& $criticalLiteralOp 81) +
    @('endfields','endfields','endfields','owned','RET','fields','role','1','4',
      'owned','ADD','fields','role','9','0') +
    (& $criticalLiteralOwn 4) + (& $criticalLiteralOp 2) +
    @('endfields','endfields','endfields','owned','PRIM_PUB','owned','RET','endshape')
# Named Structure trailers belong to the original source frame, not a fn
# adapter. A real assignment distinguishes construction from invocation.
# This one-field layout isolates trailer loss; it does not certify the pending
# multi-field namespace source-order cutover.
$criticalNsTrailerContract = @('owned','struct','fields',
    'owned','struct','fields','endfields',
    'owned','struct','fields','endfields','endfields')
$criticalNsTrailerExec = @('owned','EXEC','fields','role','35','0','null','same') +
    $criticalNsTrailerContract + @('null','endfields')
$criticalNsTrailerShape = @('widthpath','0','6','widthpath','1','0','4',
    'parentpath','1','0','0','namepath','1','0','Counter',
    'intpath','2','0','0','1','samepath','2','2','2','1','0',
    'shape','exact','owned','struct','fields','intvalue','1',
    'owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 0) + (& $criticalLiteralOp 1) +
    @('endfields','owned','assign','SET','fields','role','8','0') +
    (& $criticalLiteralOwn 0) + (& $criticalLiteralOp 2) +
    @('endfields','owned','RET','fields','role','1','4','endfields','endfields','IF') +
    $criticalNsTrailerExec + @('IF') + $criticalLiteralPublish7 +
    $criticalLiteralRootReturn + @('endshape')
# Ordinary named bodies use the same source-order producer as method bodies.
# INIT/SET coordinates point to real cells, including repeated declaration names.
$criticalNsInit = {
    param($slot, $value)
    @('owned','init','SET','fields','role','8','1') +
        (& $criticalLiteralOwn $slot) + (& $criticalLiteralOp $value) + @('endfields')
}
$criticalDepth6Shape = @('shape','exact','owned','struct','fields',
    'owned','struct','fields','owned','struct','fields','owned','struct','fields',
    'owned','struct','fields','owned','struct','fields','intvalue','37') +
    (& $criticalNsInit 0 37) + @('endfields','endfields','endfields',
    'endfields','endfields','endfields','PRIM_PUB','RET','endshape','copy')
$criticalUnknownNestShape = @('shape','exact','owned','struct','fields',
    'owned','struct','fields','intvalue','1') + (& $criticalNsInit 0 1) +
    @('endfields','endfields','intvalue','0') + (& $criticalNsInit 1 0) +
    @('PRIM_PUB','RET','endshape','copy','mergenest','namepath','1','0','A',
    'namepath','2','0','0','B','placenamepath','3','0','0','0','x')
# One actual descriptor place, independent field occurrence and element index.
# Both reads and writes retain the same source-resolved OF/ARG/ADD edges.
$criticalArrayPlaceShape = {
    param($op, $slot, $index, $value)
    $edges = @(
        [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = $slot }) } },
        [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'size'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = $index }) } }
        ) } }
    )
    $width = 3
    if ($op -eq 'ELEMPUT') {
        $width = 4
        $edges += [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = $value }) } }
    }
    [pscustomobject]@{ Op = $op; Width = $width; Count = 1; Edges = $edges }
}
$criticalArrayPlaceShapes = @(
    (& $criticalArrayPlaceShape 'ELEMPUT' 2 1 11),
    (& $criticalArrayPlaceShape 'ELEMPUT' 5 2 22),
    (& $criticalArrayPlaceShape 'ELEM' 2 1 0),
    (& $criticalArrayPlaceShape 'ELEM' 5 2 0)
)
$criticalNsAssign = {
    param($slot, $value)
    @('owned','assign','SET','fields','role','8','0') +
        (& $criticalLiteralOwn $slot) + (& $criticalLiteralOp $value) + @('endfields')
}
$criticalNsHolder5 = @('owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + (& $criticalNsAssign 0 2) +
    @('intvalue','3') + (& $criticalNsInit 3 3) + @('endfields')
$criticalNsRepeated5 = @('owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('intvalue','7') +
    (& $criticalNsInit 2 7) + (& $criticalNsAssign 2 2) + @('endfields')
$criticalNsPure4 = @('owned','struct','fields','intvalue','5') +
    (& $criticalNsInit 0 5) + @('intvalue','9') +
    (& $criticalNsInit 2 9) + @('endfields')
$criticalNsMixedShape = @('widthpath','0','6','widthpath','1','0','5',
    'parentpath','1','0','0','namepath','1','0','Holder',
    'namepath','2','0','0','x','namepath','2','0','3','y',
    'cellpath','2','0','0','1','2','cellpath','2','0','3','1','2',
    'intpath','2','0','0','1','intpath','2','0','3','3',
    'rolepath','1','2','35','0','widthpath','1','2','5',
    'samepath','2','2','2','1','0','shape','exact') +
    $criticalNsHolder5 + @('IF') + $criticalNsTrailerExec + @('IF') +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
$criticalNsRepeatedShape = @('widthpath','0','6','widthpath','1','0','5',
    'parentpath','1','0','0','namepath','1','0','Repeated',
    'namepath','2','0','0','x','namepath','2','0','2','x',
    'cellpath','2','0','0','1','2','cellpath','2','0','2','1','2',
    'intpath','2','0','0','1','intpath','2','0','2','7',
    'rolepath','1','2','35','0','widthpath','1','2','5',
    'samepath','2','2','2','1','0','shape','exact') +
    $criticalNsRepeated5 + @('IF') + $criticalNsTrailerExec + @('IF') +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
$criticalNsDormantShape = @('widthpath','0','6','widthpath','1','0','5',
    'widthpath','1','1','4','widthpath','1','2','4',
    'parentpath','1','0','0','parentpath','1','1','0','parentpath','1','2','0',
    'namepath','1','0','Holder','namepath','1','1','Cold','namepath','1','2','Warm',
    'namepath','2','0','0','x','namepath','2','0','3','y',
    'namepath','2','1','0','a','namepath','2','1','2','b',
    'namepath','2','2','0','a','namepath','2','2','2','b',
    'intpath','2','0','0','1','intpath','2','0','3','3',
    'intpath','2','1','0','5','intpath','2','1','2','9',
    'intpath','2','2','0','5','intpath','2','2','2','9',
    'rolepath','1','3','35','0','widthpath','1','3','5',
    'samepath','2','3','2','1','2','shape','exact') +
    $criticalNsHolder5 + $criticalNsPure4 + $criticalNsPure4 +
    $criticalNsTrailerExec + $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
# Target acceptance for original nested namespace source retention. These
# exact fixtures have no fn/sub/converter rows: preorder registration must
# give Outer=0, in=1, ROOT=2. The current unsupported producer is not waived.
# Finite witness paths do not impose a language nesting-depth ceiling.
$criticalNsNestedPaths = {
    param($rootWidth, $outerWidth, $innerWidth)
    @('widthpath','0',[string]$rootWidth,
      'widthpath','1','0',[string]$outerWidth,
      'widthpath','2','0','2',[string]$innerWidth,
      'parentpath','1','0','0','parentpath','2','0','2','1','0',
      'namepath','1','0','Outer','namepath','2','0','0','tag',
      'namepath','2','0','2','in','namepath','2','0','3','after',
      'namepath','3','0','2','0','x','namepath','3','0','2','2','y',
      'cellpath','2','0','0','1','2','cellpath','2','0','3','1','2',
      'cellpath','3','0','2','0','1','2','cellpath','3','0','2','2','1','2',
      'intpath','2','0','0','9','intpath','2','0','3','11',
      'intpath','3','0','2','0','1','intpath','3','0','2','2','3',
      'rolepath','2','0','1','8','1','rolepath','2','0','4','8','1',
      'rolepath','3','0','2','1','8','1','rolepath','3','0','2','3','8','1')
}
$criticalNsNestedInner4 = @('owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('intvalue','3') +
    (& $criticalNsInit 2 3) + @('endfields')
$criticalNsNestedInner5 = @('owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('intvalue','3') +
    (& $criticalNsInit 2 3) + (& $criticalNsAssign 0 2) + @('endfields')
$criticalNsNestedOuter5 = @('owned','struct','fields','intvalue','9') +
    (& $criticalNsInit 0 9) + $criticalNsNestedInner4 +
    @('intvalue','11') + (& $criticalNsInit 3 11) + @('endfields')
# OWN(current-self, slot2): the existing working binding selects this parent's
# child, not a saved reference to the original module child (§7b).
$criticalNsNestedChildExec = @('owned','EXEC','fields','role','35','0','null',
    'owned','OWN','fields','role','4','0','null','sizevalue','2','endfields') +
    $criticalNsTrailerContract + @('null','endfields')
$criticalNsNestedOuter6 = @('owned','struct','fields','intvalue','9') +
    (& $criticalNsInit 0 9) + $criticalNsNestedInner5 +
    @('intvalue','11') + (& $criticalNsInit 3 11) +
    $criticalNsNestedChildExec + @('endfields')
$criticalNsNestedDormantShape = (& $criticalNsNestedPaths 3 5 4) +
    @('shape','exact') + $criticalNsNestedOuter5 +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
$criticalNsNestedCalledShape = (& $criticalNsNestedPaths 6 6 5) +
    @('rolepath','3','0','2','4','8','0',
      'rolepath','2','0','5','35','0','widthpath','2','0','5','5',
      'rolepath','3','0','5','2','4','0','widthpath','3','0','5','2','3',
      'samepath','2','2','2','1','0','shape','exact') +
    $criticalNsNestedOuter6 + @('IF') + $criticalNsTrailerExec + @('IF') +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
# Native pointer operations retain their actual base and index bindings. The
# root can be walked with its pointer-bearing method still native; clearing
# that method is not an assertion that machine indexing is L3-walkable.
$criticalPointerArg = @('owned','ARG','fields','role','5','0','sizevalue','0','null','ptr','endfields')
$criticalPointerIndexArg = @('owned','ARG','fields','role','5','0','sizevalue','1','null','size','endfields')
$criticalPointerStore0 = & $criticalExternalApplication 'p[0]' ($criticalPointerArg + @('intvalue','0','intvalue','23'))
$criticalPointerStoreI = & $criticalExternalApplication 'p[i]' ($criticalPointerArg + $criticalPointerIndexArg + @('intvalue','29'))
$criticalPointerRead0 = & $criticalExternalApplication '[' ($criticalPointerArg + (& $criticalLiteralOp 0))
$criticalPointerReadI = & $criticalExternalApplication '[' ($criticalPointerArg + $criticalPointerIndexArg)
$criticalPointerNot0 = @('owned','SUB','fields','role','10','0') + (& $criticalLiteralOp 1) +
    @('owned','EQ','fields','role','12','0') + $criticalPointerRead0 + (& $criticalLiteralOp 23) + @('endfields','endfields')
$criticalPointerNotI = @('owned','SUB','fields','role','10','0') + (& $criticalLiteralOp 1) +
    @('owned','EQ','fields','role','12','0') + $criticalPointerReadI + (& $criticalLiteralOp 29) + @('endfields','endfields')
$criticalPointerIndexShape = @('widthpath','0','7','widthpath','1','0','6',
    'cellpath','5','0','2','1','0','3','1','1035',
    'samepath','3','3','2','1','1','0',
    'shape','exact','owned','struct','fields','owned','struct','fields','ptr','size','endfields',
    'owned','struct','fields','int','endfields') +
    $criticalPointerStore0 + $criticalPointerStoreI +
    @('owned','IF','fields','role','13','0','owned','OR','fields','role','39','0') +
    $criticalPointerNot0 + $criticalPointerNotI +
    @('endfields','owned','struct','fields','owned','RET','fields','role','1','0') +
    (& $criticalLiteralOp 81) + @('endfields','endfields','endfields',
    'owned','RET','fields','role','1','4') + (& $criticalLiteralOp 7) +
    @('endfields','endfields','array','int','owned','init','SET','owned','IF','owned','PRIM_PUB','owned','RET','endshape')
$criticalExternalPaths = @('widthpath','0','6','widthpath','1','1','8',
    'namepath','1','1','probe','namepath','2','1','2','v',
    'namepath','1','3','Unknown','samepath','3','4','3','1','1','1')
$criticalExternalShape = {
    param([bool]$predef)
    $directive = 'include'; $header = '<stdlib.h>'; $unknown = '23'
    $first = & $criticalExternalApplication 'c.abs' $criticalExternalOwn
    $branch = & $criticalExternalApplication 'c.abs' $criticalExternalArg
    $tail = & $criticalExternalApplication 'c.abs' @('intvalue','17')
    $rootCall = & $criticalExternalApplication 'c.abs' @('intvalue','19')
    if ($predef) {
        $directive = 'predef'; $header = 'l2src/lmx_clock.h.lm1'; $unknown = '41'
        $first = & $criticalExternalApplication 'lmx_deadline_passed' ($criticalExternalOwn + @('numvalue','unsigned','13'))
        $branch = & $criticalExternalApplication 'lmx_deadline_wait' ($criticalExternalArg + @('numvalue','unsigned','19'))
        $tail = & $criticalExternalApplication 'lmx_deadline_passed' @('numvalue','unsigned','23','numvalue','unsigned','29')
        $rootCall = & $criticalExternalApplication 'lmx_deadline_wait' @('numvalue','unsigned','31','numvalue','unsigned','37')
    }
    @('shape','exact','owned','spell',$directive,'fields','role','44','0',
      'owned','struct','fields','spell',$header,'endfields','endfields',
      'owned','struct','fields','owned','struct','fields','size','endfields',
      'owned','struct','fields','int','endfields','size',
      'owned','init','SET','fields','role','8','1') + $criticalExternalOwn +
    (& $criticalExternalLitSize 11) + @('endfields') + $first +
    @('owned','IF','fields','role','13','0') + (& $criticalLiteralOp 0) +
    @('owned','struct','fields') + $branch + @('endfields','endfields',
      'owned','RET','fields','role','1','0') + (& $criticalLiteralOp 7) +
    @('endfields') + $tail + @('endfields') + $rootCall +
    @('owned','struct','fields','intvalue',$unknown,'endfields',
      'owned','PRIM_PUB','fields','role','33','0','primitive','null',
      'owned','CALL','fields','role','2','0','same') +
    (& $criticalExternalLitSize 5) + @('endfields','endfields',
      'owned','RET','fields','role','1','0','endfields','endshape')
}
$criticalPredefShadowShape = @('widthpath','0','6','namepath','1','1','lmx_deadline_wait',
    'shape','exact','owned','spell','predef','fields','role','44','0',
    'owned','struct','fields','spell','l2src/lmx_clock.h.lm1','endfields','endfields',
    'int','owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 1) + (& $criticalLiteralOp 0) + @('endfields',
    'owned','assign','SET','fields','role','8','0') + (& $criticalLiteralOwn 1) +
    (& $criticalLiteralOp 13) + @('endfields','owned','PRIM_PUB','fields','role','33','0','primitive','null') +
    (& $criticalLiteralOwn 1) + @('endfields') + $criticalLiteralRootReturn + @('endshape')

$criticalExternalValue = & $criticalExternalApplication 'lmx_deadline_passed' ($criticalExternalArg + @('numvalue','unsigned','13'))
$criticalExternalOperandShape = @('widthpath','0','4','widthpath','1','1','6',
    'namepath','1','1','probe','namepath','2','1','2','v','samepath','3','2','3','1','1','1',
    'shape','exact','owned','spell','predef','fields','role','44','0',
    'owned','struct','fields','spell','l2src/lmx_clock.h.lm1','endfields','endfields',
    'owned','struct','fields','owned','struct','fields','size','endfields',
    'owned','struct','fields','int','endfields','int','owned','init','SET','fields','role','8','1') +
    (& $criticalLiteralOwn 2) + (& $criticalLiteralOp 0) + @('endfields',
    'owned','assign','SET','fields','role','8','0') + (& $criticalLiteralOwn 2) + $criticalExternalValue +
    @('endfields','owned','RET','fields','role','1','0','owned','ADD','fields','role','9','0') +
    $criticalExternalValue + (& $criticalLiteralOp 6) + @('endfields','endfields','endfields',
    'owned','PRIM_PUB','fields','role','33','0','primitive','null','owned','CALL','fields','role','2','0','same') +
    (& $criticalExternalLitSize 5) + @('endfields','endfields') + $criticalLiteralRootReturn + @('endshape')

$criticalMethodNestShape = @('shape','exact','owned','struct','fields',
    'owned','struct','fields','endfields','owned','struct','fields','endfields',
    'owned','struct','fields','owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('endfields','intvalue','3') +
    (& $criticalNsInit 1 3) + @('endfields') + $criticalLiteralRootReturn +
    @('endfields') + $criticalLiteralCall + $criticalLiteralPublish7 +
    $criticalLiteralRootReturn + @('endshape')

$criticalLocalMethodShape = {
    param([string[]]$body)
    @('shape','exact','owned','struct','fields',
      'owned','struct','fields','endfields','owned','struct','fields','endfields') +
    $body + $criticalLiteralRootReturn + @('endfields') + $criticalLiteralCall +
    $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
}
$criticalMethodFieldsShape = @('widthpath','0','4','widthpath','1','0','4','widthpath','2','0','2','4',
    'namepath','1','0','task','namepath','2','0','2','Holder',
    'placenamepath','3','0','2','0','a','placenamepath','3','0','2','2','c',
    'intpath','3','0','2','0','1','intpath','3','0','2','2','3',
    'parentpath','1','0','0','parentpath','2','0','2','1','0','samepath','2','1','1','1','0') +
    (& $criticalLocalMethodShape (@('owned','struct','fields','intvalue','1') +
        (& $criticalNsInit 0 1) + @('intvalue','3') + (& $criticalNsInit 2 3) + @('endfields')))
$criticalMethodPtrShape = & $criticalLocalMethodShape (@('owned','struct','fields','intvalue','3') +
    (& $criticalNsInit 0 3) + @('ptr','owned','implicit','SET','fields','role','8','2') +
    (& $criticalLiteralOwn 2) + @('owned','LIT','fields','role','3','0','ptr','endfields','endfields','endfields'))
$criticalMethodArrayShape = & $criticalLocalMethodShape (@('owned','struct','fields','intvalue','3') +
    (& $criticalNsInit 0 3) + @('array','endfields'))
$criticalMethodArrarrShape = & $criticalLocalMethodShape (@('owned','struct','fields','intvalue','3') +
    (& $criticalNsInit 0 3) + @('descs','endfields'))
$criticalMethodDeepShape = & $criticalLocalMethodShape (@('owned','struct','fields',
    'owned','struct','fields','owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('endfields','endfields','intvalue','3') +
    (& $criticalNsInit 1 3) + @('endfields'))
# Unit-level Point precedes the method. The method-local Holder keeps its int
# cell and written INIT first, then the nested Structure with its own cell/INIT.
$criticalMethodRefShape = @('shape','exact','owned','struct','fields','intvalue','1') +
    (& $criticalNsInit 0 1) + @('endfields','owned','struct','fields',
    'owned','struct','fields','endfields','owned','struct','fields','endfields',
    'owned','struct','fields','intvalue','3') + (& $criticalNsInit 0 3) +
    @('owned','struct','fields','intvalue','1') + (& $criticalNsInit 0 1) +
    @('endfields','endfields') + $criticalLiteralRootReturn + @('endfields') +
    $criticalLiteralCall + $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape')
# An imported C function-pointer local has no graph cell. Unit: predef,
# include, check, publish, return. check: two header parts, the retained
# declaration, IF, got's pointer cell, its written initialization, IF, c.free
# and the return trailer. The declared name is one leaf: the declaration's
# child 0 and the comparison's operand are the same object; the call through
# the local is a separate application named by its head.
$criticalMachineLocalPaths = @('widthpath','0','5','widthpath','1','2','9',
    'widthpath','3','2','2','1','2',
    'namepath','1','2','check','namepath','2','2','2','L2TestAllocFn',
    'namepath','4','2','2','1','0','allocate','namepath','4','2','2','1','1','c.malloc',
    'samepath','4','2','2','1','0','4','2','3','1','1',
    'namepath','3','2','5','2','allocate','widthpath','4','2','5','2','1','1',
    'namepath','2','2','7','c.free')

# Address arithmetic and the address of a raw element are machine operators
# named by their written spelling. Unit: bump, step, publish, return. bump:
# two header parts, q's pointer cell, its initialization, the store of
# `@ p[1]`, the store through q and the return trailer; the address operator
# holds the raw index, whose operands are the formal and the literal. step:
# header parts, buf, q, q's initialization, the store of `@ buf[0] + 2`, the
# store through q, two IFs and the return trailer; `+` holds the element
# address and the count in source order. Both methods keep their native word.
$criticalMachineAddressPaths = @('widthpath','0','4','namepath','1','0','bump','namepath','1','1','step',
    'widthpath','1','0','7','widthpath','1','1','10',
    'rolepath','3','0','4','2','45','0','namepath','3','0','4','2','@','widthpath','4','0','4','2','1','1',
    'rolepath','5','0','4','2','1','0','45','0','namepath','5','0','4','2','1','0','[',
    'widthpath','6','0','4','2','1','0','1','2',
    'rolepath','7','0','4','2','1','0','1','0','5','0','rolepath','7','0','4','2','1','0','1','1','3','0',
    'intpath','8','0','4','2','1','0','1','1','1','1',
    'rolepath','3','1','5','2','45','0','namepath','3','1','5','2','+','widthpath','4','1','5','2','1','2',
    'rolepath','5','1','5','2','1','0','42','0','rolepath','6','1','5','2','1','0','1','25','0',
    'rolepath','5','1','5','2','1','1','3','0','intpath','6','1','5','2','1','1','1','2',
    'nativepath','1','0','1','nativepath','1','1','1')

# An Array declared in a nested body. Unit: check, result, its store, IF,
# publish, return. check: header parts, values, a store into it, seen and its
# initialization, two IFs, the return trailer. The first IF's body holds its
# own values descriptor at child 0; a store into it names that body as the
# holder of its AT, while the method-level store's AT names no holder. The two
# descriptors are distinct objects. The root's IF body holds marks the same way.
$criticalNestedArrayPaths = @('widthpath','0','6','namepath','1','0','check','widthpath','1','0','9',
    'rolepath','2','0','3','26','0','rolepath','3','0','3','1','6','0',
    'nullpath','4','0','3','1','1','sizepath','4','0','3','1','2','2',
    'widthpath','3','0','6','2','5',
    'rolepath','4','0','6','2','1','26','0','rolepath','5','0','6','2','1','1','6','0',
    'samepath','6','0','6','2','1','1','1','3','0','6','2','sizepath','6','0','6','2','1','1','2','0',
    'differentpath','4','0','6','2','0','2','0','2',
    'widthpath','2','3','2','3',
    'samepath','5','3','2','1','1','1','2','3','2','sizepath','5','3','2','1','1','2','0')

# Calls of two copied Structures with different hidden inputs. Unit: seen and
# its initialization, A, B, x, y and their initializations, the declarations
# of ra and rb, ps, result, then call ra, IF, call rb, IF, the store into x,
# call ra, IF, publish, return. Each call is EXEC over the very output
# operand its row's declaration produced; its one hidden input is the
# caller's own cell of the name that copy's body needs: x (child 4) for ra,
# y (child 6) for rb. The two rows are distinct objects.
$criticalCopyCallPaths = @('widthpath','0','23',
    'rolepath','1','14','35','0','widthpath','1','14','6','samepath','2','14','2','2','8','1',
    'widthpath','3','14','3','0','1','rolepath','2','14','5','4','0','sizepath','3','14','5','2','4',
    'rolepath','1','16','35','0','widthpath','1','16','6','samepath','2','16','2','2','9','1',
    'rolepath','2','16','5','4','0','sizepath','3','16','5','2','6',
    'rolepath','1','19','35','0','samepath','2','19','2','2','8','1','sizepath','3','19','5','2','4',
    'differentpath','2','8','1','2','9','1')
# A chain of copies. Unit children 5, 6, 7 declare ra, rb, rc: rb's merge takes
# the very output operand of ra's declaration, rc's that of rb's, three
# distinct rows. The calls (11: rb, 17: rc) are EXEC over the called row's own
# operand with the caller's x (child 3) as the one hidden input. In h (unit
# child 8) statement 7 declares xc as a copy of the row that defines C (own 6)
# and statement 8 is EXEC over xc's operand with h's own x (own 2).
$criticalCopyChainPaths = @(
    'samepath','3','6','2','7','2','5','1','samepath','3','7','2','7','2','6','1',
    'differentpath','2','5','1','2','6','1','differentpath','2','6','1','2','7','1',
    'rolepath','1','11','35','0','widthpath','1','11','6','samepath','2','11','2','2','6','1',
    'rolepath','2','11','5','4','0','sizepath','3','11','5','2','3',
    'rolepath','1','17','35','0','widthpath','1','17','6','samepath','2','17','2','2','7','1',
    'rolepath','2','17','5','4','0','sizepath','3','17','5','2','3',
    'sizepath','5','8','7','2','7','2','6',
    'rolepath','2','8','8','35','0','widthpath','2','8','8','6','samepath','3','8','8','2','3','8','7','1',
    'rolepath','3','8','8','5','4','0','sizepath','4','8','8','5','2','2')

# A foreign C value by value has no graph cell. Unit: predef, include, echo,
# read, kind, probe, check, publish, return. echo's declared input part is
# one named empty place; after its `throws` line, its read of that input is
# ARG 0 whose witness place is empty too, and so is kind's. probe keeps
# `kind(41)` as a CALL of kind's very occurrence with the literal at its
# place; check keeps `read(echo(make()))` whole, the call that can throw
# holding its actual at the first input place of the long frame. All five
# methods keep their native word.
$criticalForeignValuePaths = @('widthpath','0','9','namepath','1','2','echo','namepath','1','3','read',
    'namepath','1','4','kind','namepath','1','5','probe','namepath','1','6','check',
    'widthpath','2','2','0','1','placenamepath','3','2','0','0','value','nullpath','3','2','0','0',
    'rolepath','5','2','3','1','1','0','5','0','widthpath','5','2','3','1','1','0','4',
    'sizepath','6','2','3','1','1','0','1','0','nullpath','6','2','3','1','1','0','3',
    'rolepath','3','4','2','1','5','0','nullpath','4','4','2','1','3',
    'rolepath','5','5','2','1','2','1','2','0','widthpath','5','5','2','1','2','1','3',
    'samepath','6','5','2','1','2','1','1','1','4',
    'rolepath','6','5','2','1','2','1','2','3','0','intpath','7','5','2','1','2','1','2','1','41',
    'rolepath','3','6','3','2','2','0','samepath','4','6','3','2','1','1','3',
    'rolepath','4','6','3','2','2','2','0','widthpath','4','6','3','2','2','9','samepath','5','6','3','2','2','1','1','2',
    'rolepath','5','6','3','2','2','5','45','0','namepath','5','6','3','2','2','5','c.l2_dispatch_pair_make',
    'nativepath','1','2','1','nativepath','1','3','1','nativepath','1','4','1','nativepath','1','5','1','nativepath','1','6','1')

# Named actuals stand in the retained call at their written places: NAMED (47)
# carries the written name, the resolved formal coordinate and the payload.
# h (unit child 6) writes f(b: ..; a: ..): coordinates 1 then 0. k (child 7)
# writes g(positional; c: ..; b: ..): a plain CALL, then coordinates 2 and 1.
# The root's third call (child 13) repeats h's order in a SET.
$namedActualOrderShape = @(
    'rolepath','3','6','2','1','2','0','widthpath','3','6','2','1','4',
    'rolepath','4','6','2','1','2','47','0','widthpath','4','6','2','1','2','3',
    'namepath','4','6','2','1','2','b','sizepath','5','6','2','1','2','1','1',
    'rolepath','5','6','2','1','2','2','2','0',
    'rolepath','4','6','2','1','3','47','0','widthpath','4','6','2','1','3','3',
    'namepath','4','6','2','1','3','a','sizepath','5','6','2','1','3','1','0',
    'rolepath','5','6','2','1','3','2','2','0',
    'rolepath','3','7','2','1','2','0','widthpath','3','7','2','1','5',
    'rolepath','4','7','2','1','2','2','0',
    'rolepath','4','7','2','1','3','47','0','namepath','4','7','2','1','3','c','sizepath','5','7','2','1','3','1','2',
    'rolepath','4','7','2','1','4','47','0','namepath','4','7','2','1','4','b','sizepath','5','7','2','1','4','1','1',
    'rolepath','5','7','2','1','3','2','2','0','rolepath','5','7','2','1','4','2','2','0',
    'rolepath','2','13','2','2','0','widthpath','2','13','2','4',
    'rolepath','3','13','2','2','47','0','namepath','3','13','2','2','b','sizepath','4','13','2','2','1','1',
    'rolepath','3','13','2','3','47','0','namepath','3','13','2','3','a','sizepath','4','13','2','3','1','0')
# via (unit child 5) invokes its callable formal: EXEC (35) keeps the callee's
# formal, the contract and then the two named operands in their written places.
$namedActualCallableShape = @(
    'rolepath','3','5','2','1','35','0','widthpath','3','5','2','1','7',
    'rolepath','4','5','2','1','2','5','0',
    'rolepath','4','5','2','1','5','47','0','widthpath','4','5','2','1','5','3',
    'namepath','4','5','2','1','5','b','sizepath','5','5','2','1','5','1','1','rolepath','5','5','2','1','5','2','2','0',
    'rolepath','4','5','2','1','6','47','0','widthpath','4','5','2','1','6','3',
    'namepath','4','5','2','1','6','a','sizepath','5','5','2','1','6','1','0','rolepath','5','5','2','1','6','2','2','0')

# A prefix sign is one retained operator with one operand: NEG (48) for `-`,
# POS (49) for `+`, width 2. Unit children 4..11 are neg, grp, twice, after,
# once, plus, cond, wide. neg: NEG over the formal. grp: NEG over the ADD of a
# group. twice: NEG over NEG. after: SUB whose right operand is NEG. once: NEG
# over the CALL. plus: POS. cond: NEG under LT. wide: NEG under ADD. The root:
# NEG over its own x (40), under MUL (43), over the literal 1 in an actual (46;
# the literal is 1, not a signed -1) and over a group as a whole value (50).
$prefixSignShape = @(
    'rolepath','3','4','2','1','48','0','widthpath','3','4','2','1','2','rolepath','4','4','2','1','1','5','0',
    'rolepath','3','5','2','1','48','0','widthpath','3','5','2','1','2','rolepath','4','5','2','1','1','9','0',
    'rolepath','3','6','2','1','48','0','rolepath','4','6','2','1','1','48','0','rolepath','5','6','2','1','1','1','5','0',
    'rolepath','3','7','2','1','10','0','rolepath','4','7','2','1','1','5','0','rolepath','4','7','2','1','2','48','0','widthpath','4','7','2','1','2','2',
    'rolepath','3','8','2','1','48','0','rolepath','4','8','2','1','1','2','0',
    'rolepath','3','9','2','1','49','0','widthpath','3','9','2','1','2','rolepath','4','9','2','1','1','5','0',
    'rolepath','4','10','2','1','1','48','0',
    'rolepath','4','11','2','1','1','48','0',
    'rolepath','2','40','2','48','0','widthpath','2','40','2','2','rolepath','3','40','2','1','4','0',
    'rolepath','3','43','2','2','48','0',
    'rolepath','3','46','2','2','48','0','rolepath','4','46','2','2','1','3','0','intpath','5','46','2','2','1','1','1',
    'rolepath','2','50','2','48','0','rolepath','3','50','2','1','9','0')
# The original witness: h (unit child 1) stores f(a: 8; b: - 1). The named
# actual b keeps its sign over the literal 1.
$prefixSignNamedActualShape = @(
    'rolepath','4','1','4','2','3','47','0','namepath','4','1','4','2','3','b',
    'rolepath','5','1','4','2','3','2','48','0','widthpath','5','1','4','2','3','2','2',
    'rolepath','6','1','4','2','3','2','1','3','0','intpath','7','1','4','2','3','2','1','1','1')

# The root's calls of held callables: PRIM_PUB (33) of width 4 + declared +
# hidden inputs. Child 3 is the held callable's own row, the declared
# arguments follow in the order written, the model's hidden input the root
# does not bind is an empty place. 15: h0(), no argument. 18: h2(mark(1);
# mark(2)). 23: h3(7U; <an int expression>; 9U), a size_t, an int, a size_t.
$heldArityShape = @(
    'rolepath','2','15','2','33','0','widthpath','2','15','2','5','rolepath','3','15','2','3','4','0','nullpath','3','15','2','4',
    'rolepath','2','18','2','33','0','widthpath','2','18','2','7','rolepath','3','18','2','3','4','0',
    'rolepath','3','18','2','4','2','0','intpath','5','18','2','4','2','1','1',
    'rolepath','3','18','2','5','2','0','intpath','5','18','2','5','2','1','2','nullpath','3','18','2','6',
    'rolepath','2','23','2','33','0','widthpath','2','23','2','8','rolepath','3','23','2','3','4','0',
    'rolepath','3','23','2','4','3','0','sizepath','4','23','2','4','1','7','rolepath','3','23','2','5','9','0',
    'rolepath','3','23','2','6','3','0','sizepath','4','23','2','6','1','9','nullpath','3','23','2','7')

# The receiving instruction of a method's own typed reference: ADMIT_AS (37).
# Child 8 is its reception mode -- 2 when it carries the coverage of the place
# it receives into, 1 for the full reception of unknown coverage -- and with
# mode 2 the coverage stands from child 9: its count of cells, then each level
# as a count of pairs and (edge, below) per field the Consumer reads.
# declared: `@: Model b o`, b compared by identity alone -- a root level of no
# pair.  stored: `r: o` into a declared reference, the same.
$recvUseEmptyShape = @(
    'rolepath','3','2','4','2','37','0','widthpath','3','2','4','2','20',
    'sizepath','4','2','4','2','8','2','sizepath','4','2','4','2','9','2','sizepath','4','2','4','2','10','0',
    'rolepath','3','3','6','2','37','0','widthpath','3','3','6','2','20',
    'sizepath','4','3','6','2','8','2','sizepath','4','3','6','2','9','2','sizepath','4','3','6','2','10','0')
# reads: b reads in\x, [0]a and the bare a of a Model of width 7. The root level
# has three pairs: in through its LAST half (7 + 0) with its nested level at
# cell 8; [0]a through its ORDINAL half (slot 1); the bare a through its LAST
# half (7 + 3). The nested level has one pair: x through the LAST half of the
# nested Structure's own width (4 + 0).
$recvUseNestedShape = @(
    'rolepath','3','1','4','2','37','0','widthpath','3','1','4','2','49',
    'sizepath','4','1','4','2','8','2','sizepath','4','1','4','2','9','11','sizepath','4','1','4','2','10','3',
    'sizepath','4','1','4','2','11','7','sizepath','4','1','4','2','12','8',
    'sizepath','4','1','4','2','13','1','sizepath','4','1','4','2','14','0',
    'sizepath','4','1','4','2','15','10','sizepath','4','1','4','2','16','0',
    'sizepath','4','1','4','2','17','1','sizepath','4','1','4','2','18','4','sizepath','4','1','4','2','19','0')
# Formal invocations select ARG, not the unit method of the same spelling.
# Native words stay selected; these facts certify retained source, not the
# currently excluded --walk-methods callable-formal execution profile.
$criticalCallableFormalArg = @('owned','ARG','fields','role','5','0','sizevalue','0','null','same','endfields')
$criticalCallableFormalExec = @('owned','EXEC','fields','role','35','0','null') + $criticalCallableFormalArg +
    @('owned','struct','fields') + $criticalLiteralSignature + @('endfields','null','endfields')
$criticalCallableFormalShape = @('widthpath','0','6',
    'namepath','1','0','real','namepath','1','1','f','namepath','1','2','invoke','namepath','1','3','forward',
    'widthpath','1','2','4','widthpath','1','3','3',
    'rolepath','2','2','2','35','0','widthpath','2','2','2','5',
    'rolepath','3','2','2','2','5','0','widthpath','3','2','2','2','4',
    'widthpath','3','2','2','3','2','widthpath','4','2','2','3','0','0',
    'cellpath','5','2','2','3','1','0','1','2',
    'rolepath','2','2','3','1','0','rolepath','3','2','3','1','35','0',
    'rolepath','4','2','3','1','2','5','0',
    'rolepath','2','3','2','1','0','rolepath','3','3','2','1','2','0',
    'samepath','4','3','2','1','1','1','2',
    'rolepath','4','3','2','1','2','5','0',
    'parentpath','2','2','2','1','2','parentpath','3','2','2','2','2','2','2',
    'parentpath','3','2','3','1','2','2','3',
    'samepath','4','4','3','2','1','0',
    'shape','exact','owned','struct','fields') + $criticalLiteralSignature +
    @('owned','RET','fields','role','1','0') + (& $criticalLiteralOp 7) + @('endfields','endfields',
      'owned','struct','fields') + $criticalLiteralSignature +
    @('owned','RET','fields','role','1','0') + (& $criticalLiteralOp 23) + @('endfields','endfields',
      'owned','struct','fields','owned','struct','fields','same','endfields','owned','struct','fields','int','endfields') +
    $criticalCallableFormalExec + @('owned','RET','fields','role','1','0') +
    $criticalCallableFormalExec + @('endfields','endfields',
      'owned','struct','fields','owned','struct','fields','same','endfields','owned','struct','fields','int','endfields',
      'owned','RET','fields','role','1','0','owned','CALL','fields','role','2','0','same') +
    $criticalCallableFormalArg + @('endfields','endfields','endfields',
      'owned','PRIM_PUB','fields','role','33','0','primitive','null','owned','CALL','fields','role','2','0','same',
      'owned','AT','fields','role','6','0','struct','sizevalue','0','endfields','endfields','endfields') +
    $criticalLiteralRootReturn + @('endshape')

# Full physical source, not only the result of the still-native method.
# A previous callable input is visible in its own declaration's initializer;
# after that declaration a bare name reads the new own value. The unexpanded
# root reference in AT avoids a cyclic exact-shape traversal. The initializer's
# named actual `f(x: 3)` stands in the invocation as NAMED with its written
# name, the formal's coordinate and the literal.
$criticalCallableOwnIdentity = @('samepath','3','1','0','0','1','0',
    'samepath','3','2','3','1','1','1','samepath','4','2','3','2','1','0')
$criticalCallableOwnSelectedIdentity = @('samepath','3','1','0','0','1','0',
    'samepath','5','1','3','2','2','3','1','0',
    'samepath','3','2','3','1','1','1','samepath','4','2','3','2','1','0')
$criticalCallableOwnShape = @('shape','exact','struct','fields',
    'struct','fields','endfields','struct','fields','unsigned','endfields',
    'RET','fields','role','1','0','LIT','fields','role','3','0','numvalue','unsigned','7','endfields','endfields','endfields',
    'struct','fields','struct','fields','same','endfields','struct','fields','int','endfields','int','init',
    'SET','fields','role','8','1','OWN','fields','role','4','0','null','sizevalue','2','endfields',
    'LIT','fields','role','3','0','intvalue','3','endfields','endfields',
    'RET','fields','role','1','0','OWN','fields','role','4','0','null','sizevalue','2','endfields','endfields','endfields',
    'PRIM_PUB','fields','role','33','0','primitive','null','CALL','fields','role','2','0','same',
    'AT','fields','role','6','0','struct','sizevalue','0','endfields','endfields','endfields',
    'RET','fields','role','1','0','endfields','endshape') + $criticalCallableOwnIdentity
$criticalCallableOwnInitShape = @('shape','exact','struct','fields',
    'struct','fields','int','endfields','struct','fields','int','endfields',
    'RET','fields','role','1','0','ARG','fields','role','5','0','sizevalue','0','null','int','endfields','endfields','endfields',
    'struct','fields','struct','fields','same','endfields','struct','fields','int','endfields','int','init',
    'SET','fields','role','8','1','OWN','fields','role','4','0','null','sizevalue','2','endfields',
    'EXEC','fields','role','35','0','null','ARG','fields','role','5','0','sizevalue','0','null','same','endfields',
    'struct','fields','struct','fields','int','endfields','struct','fields','int','endfields','endfields','null',
    'NAMED','fields','role','47','0','sizevalue','0',
    'LIT','fields','role','3','0','numvalue','int','3','endfields','endfields','endfields','endfields',
    'RET','fields','role','1','0','OWN','fields','role','4','0','null','sizevalue','2','endfields','endfields','endfields',
    'PRIM_PUB','fields','role','33','0','primitive','null','CALL','fields','role','2','0','same',
    'AT','fields','role','6','0','struct','sizevalue','0','endfields','endfields','endfields',
    'RET','fields','role','1','0','endfields','endshape') + $criticalCallableOwnSelectedIdentity +
    @('namepath','4','1','3','2','5','x')
$criticalCallableOwnSiteShape = @('shape','exact','struct','fields',
    'struct','fields','endfields','struct','fields','unsigned','endfields',
    'RET','fields','role','1','0','LIT','fields','role','3','0','numvalue','unsigned','7','endfields','endfields','endfields',
    'struct','fields','struct','fields','same','endfields','struct','fields','int','endfields','unsigned','init',
    'SET','fields','role','8','1','OWN','fields','role','4','0','null','sizevalue','2','endfields',
    'EXEC','fields','role','35','0','null','ARG','fields','role','5','0','sizevalue','0','null','same','endfields',
    'struct','fields','struct','fields','endfields','struct','fields','unsigned','endfields','endfields','null','endfields','endfields',
    'int','init','SET','fields','role','8','1','OWN','fields','role','4','0','null','sizevalue','4','endfields',
    'LIT','fields','role','3','0','numvalue','int','3','endfields','endfields',
    'IF','fields','role','13','0','SUB','fields','role','10','0',
    'LIT','fields','role','3','0','numvalue','int','1','endfields',
    'EQ','fields','role','12','0','OWN','fields','role','4','0','null','sizevalue','2','endfields',
    'LIT','fields','role','3','0','numvalue','unsigned','7','endfields','endfields','endfields',
    'struct','fields','RET','fields','role','1','0','LIT','fields','role','3','0','numvalue','int','81','endfields','endfields','endfields','endfields',
    'RET','fields','role','1','0','OWN','fields','role','4','0','null','sizevalue','4','endfields','endfields','endfields',
    'PRIM_PUB','fields','role','33','0','primitive','null','CALL','fields','role','2','0','same',
    'AT','fields','role','6','0','struct','sizevalue','0','endfields','endfields','endfields',
    'RET','fields','role','1','0','endfields','endshape') + $criticalCallableOwnSelectedIdentity

$criticalWideShape = @('shape', 'exact', 'struct', 'fields')
for ($criticalOccurrence = 0; $criticalOccurrence -lt 24; $criticalOccurrence++) {
    $criticalWideShape += @('struct', 'fields', 'endfields')
}
$criticalWideShape += @('endfields',
    'PRIM_PUB', 'fields', 'role', '33', '0', 'primitive', 'null',
    'LIT', 'fields', 'role', '3', '0', 'intvalue', '7', 'endfields', 'endfields',
    'RET', 'fields', 'role', '1', '0', 'endfields', 'endshape')

$criticalInertMethodGroup = @('struct','fields','add','1','2',
    'struct','fields','add','3','4','struct','fields','add','5','6',
    'struct','fields','endfields','endfields','endfields',
    'LIT','fields','role','3','0','intvalue','7','endfields','endfields')
$criticalInertMethodSignature = @('struct','fields','endfields','struct','fields','endfields')
$criticalInertMethodReturn = @('RET','fields','role','1','0','endfields')
$criticalInertMethodRootTail = @('endfields','CALL','fields','role','2','0','same','endfields',
    'PRIM_PUB','fields','role','33','0','primitive','null',
    'LIT','fields','role','3','0','intvalue','7','endfields','endfields',
    'RET','fields','role','1','0','endfields','endshape')

$criticalInertDeepShape = @('shape', 'exact')
for ($criticalInertDepth = 0; $criticalInertDepth -lt 6; $criticalInertDepth++) {
    $criticalInertDeepShape += @('struct', 'fields', 'add', [string](2 * $criticalInertDepth + 1), [string](2 * $criticalInertDepth + 2))
}
$criticalInertDeepShape += @('struct', 'fields', 'endfields')
for ($criticalInertDepth = 0; $criticalInertDepth -lt 5; $criticalInertDepth++) {
    $criticalInertDeepShape += @('endfields')
}
$criticalInertDeepShape += @('LIT', 'fields', 'role', '3', '0', 'intvalue', '13', 'endfields',
    'endfields', 'PRIM_PUB', 'RET', 'endshape')

$criticalOwnedInertShape = @('shape', 'exact',
    'owned', 'struct', 'fields', 'add', '1', '2',
        'owned', 'struct', 'fields', 'add', '3', '4',
            'owned', 'struct', 'fields', 'add', '5', '6',
                'owned', 'struct', 'fields', 'endfields',
            'endfields', 'endfields',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '7', 'endfields',
    'endfields', 'PRIM_PUB', 'RET', 'endshape')

$criticalInertControlShape = @('shape', 'exact',
    'owned', 'IF', 'fields', 'role', '13', '0',
        'LIT', 'fields', 'role', '3', '0', 'intvalue', '1', 'endfields',
        'owned', 'struct', 'fields',
            'owned', 'struct', 'fields', 'add', '1', '2',
                'owned', 'struct', 'fields', 'add', '3', '4',
                    'owned', 'struct', 'fields', 'endfields',
                'endfields', 'endfields',
        'endfields', 'endfields', 'PRIM_PUB', 'RET', 'endshape')

# These witnesses constrain operand relationships, not generated temporary names.
# The same source additionally checks publication and the external hosted-field path.
$criticalNestedBodyShapes = @{}
foreach ($pair in @(@('else', 2, 21), @('while', 3, 31), @('for', 4, 41))) {
    $holderPath = @()
    if ($pair[0] -eq 'else') { $holderPath = @(3,1) }
    elseif ($pair[0] -eq 'while') { $holderPath = @(4,2) }
    else { $holderPath = @(3,2) }
    $holderShape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = $holderPath[0] }) }
    for ($index = 1; $index -lt $holderPath.Count; $index++) {
        $holderShape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = $holderPath[$index] }); Edges = @([pscustomobject]@{ Slot = 1; Shape = $holderShape }) }
    }
    $cellSlot = 0
    $criticalNestedBodyShapes[$pair[0]] = @(
        [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = $cellSlot }); Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = $holderShape },
            [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = $pair[1] }) } }
        ) },
        [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'NODE'; Width = 1 } }
            ) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = $pair[2] }) } }
        ) }
    )
}
$criticalNestedBodyShapes['else'] += [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
    [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }); Edges = @(
        [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }
    ) } },
    [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }
) }
$criticalNestedBodyShapes['for'] += [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }); Edges = @(
    [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 3 }) } },
    [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }
) }

# Exact mixed-body source order: two real cells separated by a retained body,
# not a packed all-values prefix. Inspect operand/role and owning parent edges.
$criticalMixedLiteral = { param($n) @('owned','LIT','fields','role','3','0','intvalue',"$n",'endfields') }
$criticalRootOrderExpression = { param($a,$b) @('owned','struct','fields','owned','ADD','fields','role','9','0') + (& $criticalMixedLiteral $a) + (& $criticalMixedLiteral $b) + @('endfields','endfields') }
$criticalRootDefinitionOrderShape = @('shape','exact') + (& $criticalRootOrderExpression 11 12) + @('owned','struct','fields','endfields') + (& $criticalRootOrderExpression 31 32) + @('PRIM_PUB','RET','endshape')
$criticalRootMethodOrderShape = @('shape','exact') + (& $criticalRootOrderExpression 11 12) + @('owned','struct','fields','owned','struct','fields','endfields','owned','struct','fields','int','endfields','endfields') + (& $criticalRootOrderExpression 31 32) + @('PRIM_PUB','RET','endshape')
$criticalReturnMethodShape = @('shape','method','IF','fields','role','13','0','LIT','fields','role','3','0','intvalue','0','endfields','struct','fields','RET','fields','role','1','0','endfields','endfields','endfields','IF','fields','role','13','0','LIT','fields','role','3','0','intvalue','0','endfields','struct','fields','RET','fields','role','1','0','endfields','endfields','endfields','RET','fields','role','1','4','endfields','endmethod')
$criticalReturnOccurrenceShape = $criticalReturnMethodShape + @('call','endcall','pub','endpub','RET','fields','role','1','0','endfields','endshape')
$criticalDormantReturnOccurrenceShape = $criticalReturnMethodShape + @('pub','endpub','RET','fields','role','1','0','endfields','endshape')
$criticalDormantDivisionShape = @('shape','exact','owned','struct','fields','owned','struct','fields','endfields','owned','struct','fields','endfields','owned','struct','fields','owned','DIV','fields','role','21','0') + (& $criticalMixedLiteral 7) + (& $criticalMixedLiteral 0) + @('endfields','owned','MOD','fields','role','22','0') + (& $criticalMixedLiteral 7) + (& $criticalMixedLiteral 0) + @('endfields','endfields','owned','RET','fields','role','1','0','endfields','endfields','PRIM_PUB','RET','endshape')
# Narrow physical relationships for a hosted declaration. These do not certify
# the complete host method as a certified source graph.
$criticalHostedFnPaths = @(
    'widthpath','3','0','4','2','2',
    'widthpath','4','0','4','2','0','5',
    'intpath','5','0','4','2','0','0','3',
    'intpath','5','0','4','2','0','3','11',
    'samepath','5','0','4','2','0','2','1','1',
    'parentpath','4','0','4','2','0','3','0','4','2',
    'parentpath','1','1','0')
$criticalMixedHolder = @('owned','OF','fields','role','15','0','owned','AT','fields','role','6','0','null','sizevalue','2','endfields','sizevalue','2','endfields')
$criticalMixedOwn = { param($slot) @('owned','OWN_OF','fields','role','31','0') + $criticalMixedHolder + @('sizevalue',"$slot",'endfields') }
$criticalMixedInit = { param($slot,$n) @('owned','init','SET_OF','fields','role','32','1') + $criticalMixedHolder + @('sizevalue',"$slot") + (& $criticalMixedLiteral $n) + @('endfields') }
$criticalMixedAssign = { param($slot,$n) @('owned','assign','SET_OF','fields','role','32','0') + $criticalMixedHolder + @('sizevalue',"$slot",'owned','ADD','fields','role','9','0') + (& $criticalMixedOwn $slot) + (& $criticalMixedLiteral $n) + @('endfields','endfields') }
$criticalMixedInert = @('owned','struct','fields','owned','ADD','fields','role','9','0') + (& $criticalMixedLiteral 1) + (& $criticalMixedLiteral 2) + @('endfields','owned','struct','fields','owned','ADD','fields','role','9','0') + (& $criticalMixedLiteral 3) + (& $criticalMixedLiteral 4) + @('endfields','owned','struct','fields','endfields','endfields','endfields')
$criticalMixedBody = @('owned','struct','fields','intvalue','0') + (& $criticalMixedInit 0 3) + $criticalMixedInert + @('intvalue','0') + (& $criticalMixedInit 3 4) + (& $criticalMixedAssign 0 1) + (& $criticalMixedAssign 3 2) + @('endfields')
$criticalMixedIf = @('owned','IF','fields','role','13','0') + (& $criticalMixedLiteral 1) + $criticalMixedBody + @('endfields')
$criticalMixedDeclShape = @('shape','exact','owned','struct','fields','struct','fields','endfields','struct','fields','endfields') + $criticalMixedIf + @('owned','RET','fields','role','1','0','endfields','endfields','owned','CALL','fields','role','2','0','same','endfields','IF','PRIM_PUB','RET','endshape')

# One physical FOR header owns its counter. The source body owns its local
# declaration cell in source order; no sibling storage shell or vacant slot.
$criticalForLiteral = { param($n) @('owned','LIT','fields','role','3','0','intvalue',"$n",'endfields') }
$criticalForHeader = @('owned','AT','fields','role','6','0','null','sizevalue','3','endfields')
$criticalForBodyHolder = @('owned','OF','fields','role','15','0') + $criticalForHeader + @('sizevalue','2','endfields')
$criticalForCounter = @('owned','OWN_OF','fields','role','31','0') + $criticalForHeader + @('sizevalue','4','endfields')
$criticalForRootOwn = @('owned','OWN','fields','role','4','0','null','sizevalue','0','endfields')
$criticalForCounterInit = @('owned','init','SET_OF','fields','role','32','1') + $criticalForHeader + @('sizevalue','4') + (& $criticalForLiteral 0) + @('endfields')
$criticalForLocalInit = @('owned','init','SET_OF','fields','role','32','1') + $criticalForBodyHolder + @('sizevalue','0') + (& $criticalForLiteral 5) + @('endfields')
$criticalForRootAssign = @('owned','assign','SET','fields','role','8','0') + $criticalForRootOwn + (& $criticalForLiteral 1) + @('endfields')
$criticalForBody = @('owned','struct','fields','intvalue','0') + $criticalForLocalInit + $criticalForRootAssign + @('endfields')
$criticalForStep = @('owned','struct','fields','owned','assign','SET_OF','fields','role','32','0') + $criticalForHeader + @('sizevalue','4','owned','ADD','fields','role','9','0') + $criticalForCounter + (& $criticalForLiteral 1) + @('endfields','endfields','endfields')
$criticalForCondition = @('owned','LT','fields','role','11','0') + $criticalForCounter + (& $criticalForLiteral 1) + @('endfields')
$criticalForNode = @('owned','FOR','fields','role','40','0') + $criticalForCondition + $criticalForBody + $criticalForStep + @('intvalue','0','endfields')
$criticalForShape = @('shape','exact','intvalue','0','owned','init','SET','fields','role','8','1') + $criticalForRootOwn + (& $criticalForLiteral 0) + @('endfields') + $criticalForCounterInit + $criticalForNode + @('PRIM_PUB','owned','RET','fields','role','1','0','endfields','endshape')

# These values are created during execution, not by the initial builder.
# Observe them at this fixture's final generated service post, before release.
$criticalMethodFnShape = @('shape','exact','method','struct','struct','owned','struct','fields','int') +
    (& $criticalNsInit 0 3) + @('struct','int') + (& $criticalNsInit 3 11) +
    @('endfields','RET','endmethod','same','CALL','PRIM_PUB','RET','endshape')
# w and u are receivers (`@: w wrap(5)`, FACTORY, the author 2026-10-05): each root slot (2, 4) is
# the pointer cell of a reference (q26), and `deref` crosses it to the callable the call returned.
$criticalLocalProjectionPost = @('postpaths',
    'differentpath','1','2','1','4',
    'differentpath','2','2','deref','2','4','deref',
    'differentpath','3','2','deref','3','3','4','deref','3',
    'differentpath','3','2','deref','3','2','0','2',
    'differentpath','3','4','deref','3','2','0','2',
    'differentpath','4','2','deref','3','0','4','4','deref','3','0',
    'parentpath','3','2','deref','3','2','2','deref',
    'parentpath','3','4','deref','3','2','4','deref',
    'widthpath','3','2','deref','3','3','widthpath','3','4','deref','3','3',
    'intpath','3','2','deref','2','5','intpath','3','4','deref','2','100',
    'intpath','4','2','deref','3','0','3','intpath','4','4','deref','3','0','3',
    'intpath','3','0','2','0','2',
    'namepath','3','2','deref','3','S','namepath','3','4','deref','3','S')
$criticalLocalProjectionNative = @('nativepath','3','2','deref','3','1','nativepath','3','4','deref','3','1','nativepath','2','0','2','1','endpostpaths')
$criticalLocalProjectionWalk = @('nativepath','3','2','deref','3','0','nativepath','3','4','deref','3','0','nativepath','2','0','2','0','endpostpaths')
# graph_shape_t7_copy_parent: the unit's slots are E 0 (a qualified branch), the root's body 2 (m at 2 1 1, whose
# parent is the unit: a merge's container), other 3, w 7; from w's cell, `deref` is the node and `up` its parent, the
# copy of the unit (T7).
$criticalT7CopyPost = @('postpaths',
    'differentpath','0','3','7','deref','up',
    'differentpath','1','3','4','7','deref','up','3',
    'intpath','4','7','deref','up','3','9',
    'differentpath','3','2','1','1','6','7','deref','up','2','1','1',
    'intpath','7','7','deref','up','2','1','1','0','4',
    'parentpath','3','2','1','1','0',
    'parentpath','6','7','deref','up','2','1','1','3','7','deref','up',
    'parentpath','5','7','deref','up','2','1','4','7','deref','up','2',
    'samepath','1','0','4','7','deref','up','0',
    'endpostpaths')

$fixtures = @(
    [pscustomobject]@{ Name = 'unit_uniform_stop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 0; NativeRoot = 8; NativeMethods = @(0,1,2,3,4,5,6,7); StopMethods = @(0,1,2,3,4,5,6,7); StopWalk = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_dispatch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 5; NativeMethods = @(0,1,2,3); DispatchMethods = @(0,1,3);
        # The runtime copied-owner tap proves this path's actual identity; the
        # relation additionally checks C storage widths, which equal low bytes alone cannot prove.
        NativeCalls = @([pscustomobject]@{Caller=3; Selection='^l2_pst$'; Count=3; Throwing=$false; ResultType='int:'; ResultUse='(?m)^\s*l2_q\d+: \({result}\)\s*$'; Args=@([pscustomobject]@{Type='int:';Value='^l2_t\d+$'},[pscustomobject]@{Type='char:';Value="^'Q'$"},[pscustomobject]@{Type='size_t:';Value='^4294967303U$'},[pscustomobject]@{Type='@: void';Value='^\(cast: \(@: void\) l2_q\d+\)$'},[pscustomobject]@{Type='int:';Value='^l2_q\d+$'})}); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_uniform_dispatch_throw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 5; NativeMethods = @(0,1,2,3); DispatchMethods = @(0,1,3); DispatchThrows = $true; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'entry_puts_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @(''); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'entry_puts_after_return.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_puts_after_return.lm2:1:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    # These three sources fail on their valued root return, not on any named C function.
    # Do not execute their undefined/constraint-violating C calls to test this diagnostic.
    [pscustomobject]@{ Name = 'entry_puts_bad_arg.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_puts_bad_arg.lm2:2:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_extra_arg.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_puts_extra_arg.lm2:2:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_nested.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_puts_nested.lm2:2:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @('a"""b'); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_fence4.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unterminated python-like string literal'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_lead.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @('"hello'); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_lead_sq.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @("'hello"); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_long.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @('x' * 100); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_runs.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @('a"b""c"""d'); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_seven.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @('"""x'); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_seven_sq.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @("'''x"); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_puts_triple_single.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Says = @("a'''b"); NativeRoot = 0; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_puts.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_ret_tr_puts.lm2:2:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_two.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_ret_tr_two.lm2:3:1: return with a value in a callable that returns nothing'; Args = @('0'); Absent = @(); Debt = @() },
    # FABLE-126 part2: migrate/gate former c.array entry fixtures (owned []: char).
    # -170 (translator half, over grok_bot's ELEM 25 / ELEMPUT 26): an own Array of the root is its
    # descriptor in the unit's slot (the graph build makes it; the declaration is no step); `x[N]: v`
    # is ELEMPUT [elemput, 0, slot, N, v] and `x[N]` ELEM [elem, 0, slot, N], N a literal.  Each row
    # writes and reads back; success 7 (it was 0, an empty witness).
    [pscustomobject]@{ Name = 'entry_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)') },
    # D-39: index is a size_t field, evaluated, not a literal cell. int index is not cast.
    [pscustomobject]@{ Name = 'entry_dyn_array_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); Absent = @('c.array'); Debt = @('c.LMX_WALK_OP_ELEMPUT, 4U)', 'c.LMX_WALK_OP_ELEM, 3U)', 'c.LMX_WALK_OP_AT, 3U)') },
    [pscustomobject]@{ Name = 'entry_dyn_array_index_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'the program has no method `lm_stg_convert_int_size_t`, the receiver of this conversion'; Absent = @(); Debt = @() },
    # D-39: stack\columns[idx] is a raw C member index, not an own-array literal.
    # lm_own_new_zero is outside the kernel closure, so this row checks the spelling only.
    [pscustomobject]@{ Name = 'unit_indent_stack_field_index.lm2'; Expect = 'translates'; Exit = 0; Needle = '';
        NativePatterns = @('(?ms)@: LmP0IndentStack (?<cell>l2_q\d+)\s.*?if: \k<cell>\\columns\[2\] != 7U');
        Absent = @(); Debt = @('l2_p0_0\columns[l2_p0_1]') },
    # `08` is not a C99 integer literal (a leading zero starts an octal literal). The old
    # index-only decimal reading accepted it; the refusal is located at the literal.
    [pscustomobject]@{ Name = 'entry_array_leading_zero.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'entry_array_leading_zero.lm2:5:8: not an integer literal: a leading zero starts an octal literal'; Args = @('0'); Absent = @(); Debt = @() },
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
        Needle = 'unit_s2_vis_branch_refused.lm2:15:1: unbound dynamic input cfg'; Absent = @(); Debt = @() },
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
    # Registered frame-owned body planning must match ordinary operand bodies.
    # The take consumes the initial letter; a second take must be null.
    [pscustomobject]@{ Name = 'unit_receive_else_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_receive_else_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_method_first.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Absent = @('lmx_thread_mail_take'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_next_message_one_name.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'receiveMessage: unknown payload model'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_receive_letter_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); NativeMethods = @(0); Absent = @(); Debt = @() },
    # The same reception run by the interpreter: the method walked, and at the root, where the
    # letter's sender is also the explicit addressee of the exit.
    [pscustomobject]@{ Name = 'unit_receive_letter_model_walk.lm2'; Source = 'unit_receive_letter_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_receive_letter_model_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_send_ref_driver_tap_walk.lm2'; Source = 'unit_send_ref_driver_tap.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 0; Needle = '';
        Args = @('0', 'ref', '1');
        Says = @('reply-to-sender 1', 'reply-to-parent 1');
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # FABLE-SONNET-RECEIVE-RENAME-20260924-166 commit 1: `nextMessage` is no longer a language
    # word (renamed to `receiveMessage`) -- `nextMessage: m` is now an ordinary colon-assignment
    # to an undeclared name, refused like any other (measured: not "unknown method" -- the shape
    # is an assignment target, not a call).
    # Triage 2026-10-03: `nextMessage` is an unknown head, so `nextMessage: m` defines a named
    # Structure and executes nothing (head resolution). The pinned refusal predates that rule.
    [pscustomobject]@{ Name = 'unit_next_message_word_definition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
    # A positive with an explicit copy for its setup: reads, length(), the address of an
    # element and a typed formal, through an indexed field path whose root is a merge result.
    [pscustomobject]@{ Name = 'unit_arr_path_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
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
    # Triage 2026-10-03: a positive again, with a typed letter reference for its setup. OPEN
    # positive (the letter's Array-of-Array element contract).
    [pscustomobject]@{ Name = 'entry_parse_min.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('{source}'); Entry = 0;
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
        Needle = ''; Absent = @(); Debt = @();
        NativePatterns = @('(?m)size_t: (?<place>l2_ai\d+)_index 3\r?\n\s+if: \k<place>_data\[\k<place>_index\] != 0') },
    [pscustomobject]@{ Name = 'unit_arr_path_three_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'an indexed field path needs decimal literal indices'; Absent = @(); Debt = @() },
    # -179: the take and the null test run.
    [pscustomobject]@{ Name = 'entry_argc.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('one', 'two');
        Absent = @(); Debt = @() },
    # Graph shape: unit child order by role and retained spelling, not by slot number.
    # These bounded tests inspect actual cells before the root turn, not generated text.
    [pscustomobject]@{ Name = 'graph_shape_occurrences24.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalWideShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_occurrences24.lm2'; Source = 'graph_shape_occurrences24.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'collapse-late') + $criticalWideShape; Entry = 7; Absent = @(); Debt = @() },
    # No initializer exists here: a failed setup must NOT count as detected graph damage.
    [pscustomobject]@{ Name = 'graph_shape_mut_setup_missed.lm2'; Source = 'graph_shape_occurrences24.lm2'; Expect = 'shape-mutant'; MutationSetupMiss = $true; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'retarget-init') + $criticalWideShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_decl_exact.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalDeclExactShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_root_definition_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalRootDefinitionOrderShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_root_method_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalRootMethodOrderShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_dormant_zero_divisor.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalDormantDivisionShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_root_definition_order.lm2'; Source = 'graph_shape_root_definition_order.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','swap-root-fields','1','2') + $criticalRootDefinitionOrderShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_root_method_order.lm2'; Source = 'graph_shape_root_method_order.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','swap-root-fields','1','2') + $criticalRootMethodOrderShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_profile_name_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'exact', 'struct', 'fields', 'intvalue', '7') + (& $criticalNsInit 0 7) + @('endfields', 'endshape'); Entry = 1; EmptyEntry = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_profile_spelling_l1.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_profile_spelling_l3.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_multi.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'exact', 'struct', 'fields', 'add', '1', '2',
            'struct', 'fields', 'add', '3', '4', 'struct', 'fields', 'add', '5', '6',
            'struct', 'fields', 'endfields', 'endfields', 'endfields',
            'LIT', 'fields', 'role', '3', '0', 'intvalue', '7', 'endfields',
            'endfields', 'PRIM_PUB', 'RET', 'endshape'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_owned_inert.lm2'; Source = 'graph_shape_inert_multi.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalOwnedInertShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_control.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalInertControlShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mixed_decl_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMixedDeclShape; Entry = 7; WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_walk_mixed_decl_order.lm2'; Source = 'graph_shape_mixed_decl_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMixedDeclShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_control_parent.lm2'; Source = 'graph_shape_inert_control.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'reparent-add', '3', '4') + $criticalInertControlShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_pap.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'source-add-count', '1', '2', '2'); Entry = 6; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_t7.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        # The build retains only the original model. Projected occurrences
        # are constructed at the factory statement, not as hidden unit tails.
        Args = @('0', 'source-add-count', '1', '2', '1'); Entry = 7; WalkRoot = $true;
        Absent = @('l2_t7s0', 'l2_t7k0'); Debt = @('fn: l2_view_build_0') },
    [pscustomobject]@{ Name = 'graph_shape_t7_owned_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_mixed_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'source-add-count', '1', '2', '1', 'source-add-count', '5', '6', '1');
        Entry = 7; WalkRoot = $true; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_walk_inert_mixed_body.lm2'; Source = 'graph_shape_inert_mixed_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'source-add-count', '1', '2', '1', 'source-add-count', '5', '6', '1');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_parent.lm2'; Source = 'graph_shape_inert_multi.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'reparent-add', '3', '4') + $criticalOwnedInertShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_parent_setup_missed.lm2'; Source = 'graph_shape_inert_multi.lm2'; Expect = 'shape-mutant'; MutationSetupMiss = $true; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'reparent-add', '101', '103') + $criticalOwnedInertShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_multi_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','struct','fields') + $criticalInertMethodSignature + $criticalInertMethodGroup + $criticalInertMethodReturn + $criticalInertMethodRootTail; Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_multi_erase.lm2'; Source = 'graph_shape_inert_multi.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'erase-add', 'shape', 'exact', 'struct', 'fields', 'add', '1', '2',
            'struct', 'fields', 'add', '3', '4', 'struct', 'fields', 'add', '5', '6',
            'struct', 'fields', 'endfields', 'endfields', 'endfields',
            'LIT', 'fields', 'role', '3', '0', 'intvalue', '7', 'endfields',
            'endfields', 'PRIM_PUB', 'RET', 'endshape'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalInertDeepShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_inert_after_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','struct','fields') + $criticalInertMethodSignature + $criticalInertMethodReturn + $criticalInertMethodGroup + $criticalInertMethodRootTail; Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_init_target.lm2'; Source = 'graph_shape_decl_exact.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'retarget-init') + $criticalDeclExactShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_init_order.lm2'; Source = 'graph_shape_decl_exact.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'move-init') + $criticalDeclExactShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_init_candidate.lm2'; Source = 'graph_shape_decl_exact.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'change-init-candidate') + $criticalDeclExactShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_decl_init.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'init', 'SET', 'assign', 'SET', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_init_role.lm2'; Source = 'graph_shape_decl_init.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'erase-init-role', 'shape', 'int', 'init', 'SET', 'assign', 'SET', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_decl_carry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','method','struct','struct','int','implicit','SET','RET','endmethod','method','struct','struct','int','init','SET','RET','endmethod','pub','endpub','RET','endshape'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0, 1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_value_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','struct','fields','intvalue','11') + (& $criticalNsInit 0 11) + @('intvalue','22') + (& $criticalNsInit 2 22) + @('endfields','PRIM_PUB','RET','endshape'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_swap_values.lm2'; Source = 'graph_shape_value_order.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','swap-values','shape','exact','owned','struct','fields','intvalue','11') + (& $criticalNsInit 0 11) + @('intvalue','22') + (& $criticalNsInit 2 22) + @('endfields','PRIM_PUB','RET','endshape'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_depth6.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalDepth6Shape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_depth6_mut_init.lm2'; Source = 'graph_shape_depth6.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','7','0','0','0','0','0','0','1') + $criticalDepth6Shape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_depth6_mut_init_walk.lm2'; Source = 'graph_shape_depth6.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','7','0','0','0','0','0','0','1') + $criticalDepth6Shape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_atom.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','spell','b','int','SET','IF','PRIM_PUB','RET','endshape',
            'namepath','1','0','A','namepath','2','0','0','b','copy'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_add.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'add', '2', '2', 'IF', 'body', 'SET', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # Source after return stays in the graph: the string and the later assignment are not executed.
    [pscustomobject]@{ Name = 'graph_shape_keep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'PRIM_PUB', 'RET', 'spell', 'kept', 'SET', 'RET', 'endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # An empty group, a discarded call, and a nested group stay in source order. The nested group sets n.
    [pscustomobject]@{ Name = 'graph_shape_discard.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','method','endmethod','int','SET','struct','call','endcall','IF','body','SET','endbody','PRIM_PUB','RET','endshape'); Entry = 1; WalkRoot = $true; Absent = @(); Debt = @() },
    # An unknown Structure keeps a nested unknown Structure.
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalUnknownNestShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_init.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','0','1') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_init_walk.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','3','0','0','1') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_body.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','2','0','0') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_body_walk.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','2','0','0') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_facet.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','source-facet','3','0','0','1','0') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_unknown_nest_mut_facet_walk.lm2'; Source = 'graph_shape_unknown_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','source-facet','3','0','0','1','0') + $criticalUnknownNestShape; Entry = 7; Absent = @(); Debt = @() },
    # A parenthesized body is the same Structure as the block form.
    [pscustomobject]@{ Name = 'graph_shape_unknown_paren.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','struct','fields','intvalue','1') + (& $criticalNsInit 0 1) +
            @('endfields','int','SET','PRIM_PUB','RET','endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # A(), A: () and the block form are three empty Structures.
    [pscustomobject]@{ Name = 'graph_shape_unknown_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','struct','struct','struct','int','SET','PRIM_PUB','RET','endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # Two anonymous groups stay nested. The inner group sets n.
    [pscustomobject]@{ Name = 'graph_shape_nest2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'IF', 'body', 'IF', 'body', 'SET', 'endbody', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 2; WalkRoot = $true; Absent = @(); Debt = @() },
    # The exit value is the computed sum, once native and once with the root walked.
    [pscustomobject]@{ Name = 'graph_shape_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'add', '2', '2', 'PRIM_PUB', 'RET', 'endshape'); Entry = 4; WalkRoot = $true; Absent = @(); Debt = @() },
    # Declaration, assignment, later declaration, then the discarded sum. Cells stay in source order.
    [pscustomobject]@{ Name = 'graph_shape_mixed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'SET', 'int', 'SET', 'add', '2', '2', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # Known A: b stays a call after the argument's cell and initializer.
    [pscustomobject]@{ Name = 'graph_shape_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','struct','int','SET','pub','call','OWN','endcall','endpub','RET','endshape'); Entry = 5; WalkRoot = $true; Absent = @(); Debt = @() },
    # An assignment does not add an occurrence. [0]n stays 1 and the last n becomes 6.
    [pscustomobject]@{ Name = 'graph_shape_assign_occ.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','struct','fields','int') + (& $criticalNsInit 0 1) + @('int') + (& $criticalNsInit 2 2) + @('endfields','PUT','PRIM_PUB','RET','endshape'); Entry = 16; WalkRoot = $true; Absent = @(); Debt = @() },
    # [0]n is the first of two same-name fields. The exit is that field's 1.
    [pscustomobject]@{ Name = 'graph_shape_occ.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','struct','fields','int') + (& $criticalNsInit 0 1) + @('int') + (& $criticalNsInit 2 2) + @('endfields','PRIM_PUB','RET','endshape'); Entry = 1; WalkRoot = $true; Absent = @(); Debt = @() },
    # A method-local Holder keeps an int, then the shared method step.
    [pscustomobject]@{ Name = 'graph_shape_method_fn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodFnShape + @(
            'widthpath','2','0','2','5','intpath','3','0','2','0','3','intpath','3','0','2','3','11',
            'samepath','3','0','2','2','1','1','parentpath','2','0','2','1','0','parentpath','1','1','0',
            'namepath','1','0','task','namepath','2','0','2','Holder','placenamepath','3','0','2','0','c',
            'placenamepath','3','0','2','2','step','placenamepath','3','0','2','3','d','namepath','1','1','step'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_fn_init_mutant.lm2'; Source = 'graph_shape_method_fn.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','1') + $criticalMethodFnShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_hosted_fn_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalHostedFnPaths; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_atoms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','2','0','2','1','widthpath','2','0','3','1',
            'parentpath','2','0','2','1','0','parentpath','2','0','3','1','0',
            'namepath','2','0','2','Body','namepath','2','0','3','Expr',
            'cellpath','3','0','2','0','23','36','namepath','3','0','2','0','missing',
            'widthpath','3','0','3','0','3','intpath','5','0','3','0','1','1','2','intpath','5','0','3','0','2','1','2',
            'copy'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_hosted_atoms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','3','0','2','2','2','widthpath','4','0','2','2','0','1','widthpath','4','0','2','2','1','1',
            'parentpath','4','0','2','2','0','3','0','2','2','parentpath','4','0','2','2','1','3','0','2','2',
            'namepath','4','0','2','2','0','Body','namepath','4','0','2','2','1','Expr',
            'cellpath','5','0','2','2','0','0','23','36','namepath','5','0','2','2','0','0','missing',
            'intpath','7','0','2','2','1','0','1','1','2','intpath','7','0','2','2','1','0','2','1','2',
            'copy'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_atoms_mutant.lm2'; Source = 'graph_shape_method_atoms.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','0','cellpath','3','0','2','0','23','36'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_hosted_atoms_mutant.lm2'; Source = 'graph_shape_hosted_atoms.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','0','2','2','1','0','widthpath','5','0','2','2','1','0','3'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_raw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalPaths + (& $criticalExternalShape $false); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_raw_walk_methods.lm2'; Source = 'graph_shape_external_raw.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalPaths + (& $criticalExternalShape $false); Entry = 7; WalkMethods = $true;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_raw_binding_mutant.lm2'; Source = 'graph_shape_external_raw.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','4','1','0') + $criticalExternalPaths + (& $criticalExternalShape $false); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_predef.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalPaths + (& $criticalExternalShape $true); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_predef_walk_methods.lm2'; Source = 'graph_shape_external_predef.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalPaths + (& $criticalExternalShape $true); Entry = 7; WalkMethods = $true;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_predef_binding_mutant.lm2'; Source = 'graph_shape_external_predef.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','4','1','0') + $criticalExternalPaths + (& $criticalExternalShape $true); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_predef_dead_mutant.lm2'; Source = 'graph_shape_external_predef.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','7','1','0') + $criticalExternalPaths + (& $criticalExternalShape $true); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_graph_predef_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalPredefShadowShape; Entry = 13; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalOperandShape; Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_operand_walk_methods.lm2'; Source = 'graph_shape_external_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalExternalOperandShape; Entry = 7; WalkMethods = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_external_operand_arg_mutant.lm2'; Source = 'graph_shape_external_operand.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','6','1','5','1','1','1','0') + $criticalExternalOperandShape; Entry = 7;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalCallableFormalShape; Entry = 7; WalkRoot = $true; NativeRoot = 4; NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_formal_arg_mutant.lm2'; Source = 'graph_shape_callable_formal.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','2','2','2') + $criticalCallableFormalShape; Entry = 7; NativeRoot = 4; NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalCallableOwnShape; Entry = 3; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own_site.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalCallableOwnSiteShape; Entry = 3; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own_init.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalCallableOwnInitShape; Entry = 3; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own_ret_mutant.lm2'; Source = 'graph_shape_callable_own.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','1','4','1') + $criticalCallableOwnShape; Entry = 3; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own_site_arg_mutant.lm2'; Source = 'graph_shape_callable_own_site.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','3','2','2') + $criticalCallableOwnSiteShape; Entry = 3; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_callable_own_init_arg_mutant.lm2'; Source = 'graph_shape_callable_own_init.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','3','2','2') + $criticalCallableOwnInitShape; Entry = 3; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_source_boundaries.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','rolepath','2','0','2','1','0','rolepath','2','1','2','1','4',
            'rolepath','1','4','13','3','rolepath','1','5','13','0','copy'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_source_boundary_mutant.lm2'; Source = 'graph_shape_source_boundaries.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','source-facet','1','4','0','rolepath','1','4','13','3'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_source_trailer_mutant.lm2'; Source = 'graph_shape_source_boundaries.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','source-facet','2','1','2','0','rolepath','2','1','2','1','4'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_else_source.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','0','8','rolepath','1','2','13','0','rolepath','1','3','46','0',
            'rolepath','1','4','13','0','rolepath','1','5','46','0',
            'samepath','2','2','3','1','3','samepath','2','4','3','1','5',
            'parentpath','1','3','0','parentpath','2','3','1','1','3',
            'widthpath','2','3','1','3','namepath','3','3','1','0','x',
            'cellpath','3','3','1','0','1','2','copy'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_else_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','1','0','9','rolepath','2','0','4','13','0','rolepath','2','0','5','46','0',
            'samepath','3','0','4','3','2','0','5','samepath','3','0','6','3','2','0','7',
            'parentpath','2','0','5','1','0','parentpath','3','0','5','1','2','0','5',
            'widthpath','3','0','5','1','3','namepath','4','0','5','1','0','x',
            'cellpath','4','0','5','1','0','1','2','copy'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_else_source_mutant.lm2'; Source = 'graph_shape_else_source.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        # Remove the dormant ELSE's source head, not its body/place container.
        # Native body-place setup still needs that container even for a dormant arm.
        # The declared-role comparison must fail while the program still returns 7.
        Args = @('0','mutate','null-path','2','5','0','rolepath','1','5','46','0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_hosted_fn_field_mutant.lm2'; Source = 'graph_shape_hosted_fn_field.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','0','4','2','0','2') + $criticalHostedFnPaths; Entry = 7; Absent = @(); Debt = @() },
    # A method-local Holder keeps an int, then a nested Structure written in
    # place; unit-level Point precedes the method. The former implicit
    # `Point: box` copy is not a current construction form (K03).
    [pscustomobject]@{ Name = 'graph_shape_method_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodRefShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_ref_inner_init_mutant.lm2'; Source = 'graph_shape_method_ref.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','2','2','1') + $criticalMethodRefShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_ref_point_init_mutant.lm2'; Source = 'graph_shape_method_ref.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','2','0','1') + $criticalMethodRefShape; Entry = 7; Absent = @(); Debt = @() },
    # An activation-local machine value: the retained declaration, its one
    # name leaf borrowed by the comparison, and the call through it. The
    # method runs natively and really allocates; the root is also walked.
    [pscustomobject]@{ Name = 'graph_shape_machine_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMachineLocalPaths; Entry = 7; WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_local_leaf_mutant.lm2'; Source = 'graph_shape_machine_local.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','2','2','1','0') + $criticalMachineLocalPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_local_init_mutant.lm2'; Source = 'graph_shape_machine_local.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','2','2','1','1') + $criticalMachineLocalPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_local_use_mutant.lm2'; Source = 'graph_shape_machine_local.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','2','3','1','1') + $criticalMachineLocalPaths; Entry = 7; Absent = @(); Debt = @() },
    # Address arithmetic and the address of a raw element: retained machine
    # operators. Both methods run natively and really store through the
    # computed addresses; under the method-walk knob they keep their native
    # word, because the interpreter has no implementation for the operators.
    [pscustomobject]@{ Name = 'graph_shape_machine_address.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMachineAddressPaths; Entry = 7; WalkRoot = $true; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_walk_machine_address.lm2'; Source = 'graph_shape_machine_address.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMachineAddressPaths; Entry = 7; WalkRoot = $true; WalkMethods = $true; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_address_base_mutant.lm2'; Source = 'graph_shape_machine_address.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','1','5','2','1','0') + $criticalMachineAddressPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_address_count_mutant.lm2'; Source = 'graph_shape_machine_address.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','1','5','2','1','1') + $criticalMachineAddressPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_address_element_mutant.lm2'; Source = 'graph_shape_machine_address.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','0','4','2','1','0') + $criticalMachineAddressPaths; Entry = 7; Absent = @(); Debt = @() },
    # An Array declared in a nested body: its descriptor is that body's child and
    # every element operation names the body as holder. The method runs
    # natively and, under the method-walk knob, in the interpreter; the root's
    # nested Array is walked in both.
    [pscustomobject]@{ Name = 'graph_shape_nested_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalNestedArrayPaths; Entry = 7; WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_walk_nested_array.lm2'; Source = 'graph_shape_nested_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalNestedArrayPaths; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_nested_array_holder_mutant.lm2'; Source = 'graph_shape_nested_array.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','6','0','6','2','1','1','1') + $criticalNestedArrayPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_nested_array_root_mutant.lm2'; Source = 'graph_shape_nested_array.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','3','2','1','1','1') + $criticalNestedArrayPaths; Entry = 7; Absent = @(); Debt = @() },
    # A foreign C value by value: retained calls, an empty witness place,
    # native words kept in both modes -- probe's only machine operation is the
    # by-value call. The witness mutant moves the input ordinal into the
    # witness place and carries the one fact that must then fail.
    [pscustomobject]@{ Name = 'graph_shape_foreign_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalForeignValuePaths; Entry = 7; WalkRoot = $true; NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_walk_foreign_value.lm2'; Source = 'graph_shape_foreign_value.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalForeignValuePaths; Entry = 7; WalkRoot = $true; WalkMethods = $true; NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_foreign_value_actual_mutant.lm2'; Source = 'graph_shape_foreign_value.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','6','3','2','2','5') + $criticalForeignValuePaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_foreign_value_callee_mutant.lm2'; Source = 'graph_shape_foreign_value.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','6','3','2','2','1') + $criticalForeignValuePaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_foreign_value_literal_mutant.lm2'; Source = 'graph_shape_foreign_value.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','6','5','2','1','2','1','2') + $criticalForeignValuePaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_foreign_value_witness_mutant.lm2'; Source = 'graph_shape_foreign_value.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','5','2','3','1','1','0','1','3','nullpath','6','2','3','1','1','0','3'); Entry = 7; Absent = @(); Debt = @() },
    # A valid explicit copy retains INIT and its OWN operand. The source
    # walks the actual merge return after mutation, then calls the native
    # original; neither action may touch the other's primitive cell.
    [pscustomobject]@{ Name = 'graph_shape_method_explicit_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','1','1','2','intpath','2','1','0','1',
            'rolepath','2','1','1','8','1',
            'merge_width','1','2','merge_value','1','0','int','1',
            'merge_fresh','1','0','0','0','merge_fresh','1','1','0','1',
            'merge_child','1','1','0','1','1'); Entry = 7;
        NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    # A method-local Holder keeps its cell, written initializer, and reference.
    [pscustomobject]@{ Name = 'graph_shape_method_ptr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodPtrShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_ptr_init_mutant.lm2'; Source = 'graph_shape_method_ptr.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','1') + $criticalMethodPtrShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_ptr_default_mutant.lm2'; Source = 'graph_shape_method_ptr.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','3') + $criticalMethodPtrShape; Entry = 7; Absent = @(); Debt = @() },
    # A method-local Holder keeps an int, then an Array of Arrays.
    [pscustomobject]@{ Name = 'graph_shape_method_arrarr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodArrarrShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # A method-local Holder keeps an int, then an int Array.
    [pscustomobject]@{ Name = 'graph_shape_method_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodArrayShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # Two nested Structures inside a method: Mid holds Inner, then c.
    [pscustomobject]@{ Name = 'graph_shape_method_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodDeepShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_deep_init_mutant.lm2'; Source = 'graph_shape_method_deep.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','0','2','0','0','1') + $criticalMethodDeepShape; Entry = 7; Absent = @(); Debt = @() },
    # The source retains both typed cells and both written initializations.
    [pscustomobject]@{ Name = 'graph_shape_method_nest.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodNestShape; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_nest_inner_init_mutant.lm2'; Source = 'graph_shape_method_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','0','2','0','1') + $criticalMethodNestShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_nest_outer_init_mutant.lm2'; Source = 'graph_shape_method_nest.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','2') + $criticalMethodNestShape; Entry = 7; Absent = @(); Debt = @() },
    # A named Structure inside a method keeps field order a then c.
    [pscustomobject]@{ Name = 'graph_shape_method_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodFieldsShape + @('copy','merge'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_fields_walk_methods.lm2'; Source = 'graph_shape_method_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalMethodFieldsShape; Entry = 7; WalkMethods = $true; NativeRoot = 1; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_fields_cell_mutant.lm2'; Source = 'graph_shape_method_fields.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','0') + $criticalMethodFieldsShape; Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_fields_first_init_mutant.lm2'; Source = 'graph_shape_method_fields.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','1') + $criticalMethodFieldsShape; Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_fields_second_init_mutant.lm2'; Source = 'graph_shape_method_fields.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','3') + $criticalMethodFieldsShape; Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    # A method body keeps an if after flag, and the if's local stays inside the if.
    [pscustomobject]@{ Name = 'graph_shape_method_if.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','method','SET','IF','body','SET_OF','endbody','RET','endmethod','call','endcall','pub','endpub','RET','endshape'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # All three zero-operand return producers own distinct application Structures.
    [pscustomobject]@{ Name = 'graph_shape_return_occurrences.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalReturnOccurrenceShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # An uncalled body isolates source order from native body-holder lookup.
    # The called return witness above remains unchanged and actually executes.
    [pscustomobject]@{ Name = 'graph_shape_dormant_return_occurrences.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalDormantReturnOccurrenceShape;
        Entry = 7; NativeRoot = 1; NativeMethods = @(0); WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_move_nested_backward_mutant.lm2'; Source = 'graph_shape_dormant_return_occurrences.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','1','0','4','2') + $criticalDormantReturnOccurrenceShape;
        Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_move_nested_forward_mutant.lm2'; Source = 'graph_shape_dormant_return_occurrences.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','move-path-field','1','0','2','4') + $criticalDormantReturnOccurrenceShape;
        Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_move_nested_setup_missed.lm2'; Source = 'graph_shape_dormant_return_occurrences.lm2'; Expect = 'shape-mutant'; MutationSetupMiss = $true; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','1','0','5','2') + $criticalDormantReturnOccurrenceShape;
        Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_return_first_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # A for body writes a, then sets n. The loop runs once.
    [pscustomobject]@{ Name = 'graph_shape_for_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $criticalForShape; Entry = 1; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_for_no_init.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','FOR','PRIM_PUB','owned','RET','fields','role','1','0','endfields','endshape'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # Actual body fields: the declared cell, its initializer, then n's update.
    [pscustomobject]@{ Name = 'graph_shape_while_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'exact', 'int', 'owned', 'SET', 'owned', 'WHILE', 'body', 'int', 'owned', 'SET_OF', 'owned', 'SET', 'endbody', 'owned', 'PRIM_PUB', 'owned', 'RET', 'endshape'); Entry = 1; WalkRoot = $true; Absent = @(); Debt = @() },
    # An if body keeps two declarations in source order.
    [pscustomobject]@{ Name = 'graph_shape_if_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'exact', 'int', 'owned', 'SET', 'owned', 'IF', 'body', 'int', 'owned', 'SET_OF', 'int', 'owned', 'SET_OF', 'owned', 'PRIM_PUB', 'endbody', 'owned', 'RET', 'endshape'); Entry = 3; WalkRoot = $true; Absent = @(); Debt = @() },
    # Two declarations of one name stay two occurrences. The last one is the exit value.
    [pscustomobject]@{ Name = 'graph_shape_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'int', 'SET', 'PRIM_PUB', 'RET', 'endshape'); Entry = 2; WalkRoot = $true; Absent = @(); Debt = @() },
    # Method body keeps source order: i, then i: 6, then j, then (2 + 2).
    # The same order at unit level: i, i: 6, j, (2 + 2).
    [pscustomobject]@{ Name = 'graph_shape_unit_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'SET', 'int', 'SET', 'add', '2', '2', 'PRIM_PUB', 'RET', 'endshape'); Entry = 6; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_method_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','method','SET','SET','SET','nest','add','2','2','endnest','RET','endmethod','call','endcall','pub','endpub','RET','endshape'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # Compact A(b) is the same application as A: b.
    [pscustomobject]@{ Name = 'graph_shape_call_paren.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','struct','int','SET','pub','call','OWN','endcall','endpub','RET','endshape'); Entry = 5; WalkRoot = $true; Absent = @(); Debt = @() },
    # A known int b does not turn unknown A: b into a call. The Structure keeps the spelling.
    [pscustomobject]@{ Name = 'graph_shape_known_atom.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','int','SET','spell','b','PRIM_PUB','RET','endshape',
            'namepath','1','2','A','namepath','2','2','0','b','copy'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    # Named Structure fields stay in source order: int a, then int c.
    [pscustomobject]@{ Name = 'graph_shape_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','shape','exact','owned','struct','fields','intvalue','1') + (& $criticalNsInit 0 1) +
            @('intvalue','3') + (& $criticalNsInit 2 3) +
            @('endfields','PRIM_PUB','RET','endshape'); Entry = 0; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_erase.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'erase-add', 'shape', 'int', 'SET', 'add', '2', '2', 'IF', 'body', 'SET', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; Absent = @(); Debt = @() },
    # This source moves the expression: it is an input-order negative control, not a graph mutation.
    [pscustomobject]@{ Name = 'graph_shape_mut_move.lm2'; Expect = 'shape-mutant'; SourceOrderNegative = $true; Exit = 1; Needle = '';
        Args = @('0', 'shape', 'int', 'SET', 'add', '2', '2', 'IF', 'body', 'SET', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_mut_collapse.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'collapse', 'shape', 'int', 'SET', 'add', '2', '2', 'IF', 'body', 'SET', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; Absent = @(); Debt = @() },
    # The caller publishes before the re-entrant call. The outer read is 1 and the base read is 1.
    [pscustomobject]@{ Name = 'graph_shape_reenter.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 11; WalkRoot = $true; Absent = @(); Debt = @() },
    # A copied Structure field is its own cell. The original stays 0. The sum is 20.
    [pscustomobject]@{ Name = 'graph_shape_copy_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 20; WalkRoot = $true; Absent = @(); Debt = @() },
    # A hosted field is one cell slot. Two reads and two later calls all see 5.
    [pscustomobject]@{ Name = 'graph_shape_hosted_use.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 20; WalkRoot = $true; Absent = @(); Debt = @() },
    # Two reads of one assigned cell share the working value. The sum is 10.
    [pscustomobject]@{ Name = 'graph_shape_repeat_use.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 10; WalkRoot = $true; Absent = @(); Debt = @() },
    # Replacing the if body by an empty container keeps exit 0 and fails the shape.
    [pscustomobject]@{ Name = 'graph_shape_mut_empty.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0', 'mutate', 'empty-body', 'shape', 'int', 'SET', 'add', '2', '2', 'IF', 'body', 'SET', 'endbody', 'PRIM_PUB', 'RET', 'endshape'); Entry = 0; Absent = @(); Debt = @() },
    # The former main-signature refusals test ordinary method formals now (L2 has no main, S2).
    [pscustomobject]@{ Name = 'entry_argc_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_argc_dup.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'duplicate formal'; Absent = @(); Debt = @() },
    # Output binding is resolved before reservation. Later explicit rows are
    # not early targets, and source order is not the own table's append order.
    [pscustomobject]@{ Name = 'unit_output_future_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_future_decl_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # Exact written body and compact output operands. Each later cached read
    # borrows the corresponding declaration operand; two declarations differ.
    [pscustomobject]@{ Name = 'unit_output_repeated.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','widthpath','0','8',
            'rolepath','1','0','8','2','rolepath','1','4','8','2',
            'rolepath','2','0','1','4','0','rolepath','2','4','1','4','0',
            'widthpath','2','0','1','2','widthpath','2','4','1','2',
            'parentpath','2','0','1','1','0','parentpath','2','4','1','1','4',
            'differentpath','2','0','1','2','4','1',
            'samepath','2','0','1','3','3','1','1',
            'samepath','2','4','1','4','5','1','2','1',
            'placenamepath','3','0','1','1','m','placenamepath','3','4','1','1','m');
        Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_repeated_place_mutant.lm2'; Source = 'unit_output_repeated.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','append-null-path-field','0','widthpath','0','8');
        Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_repeated_place_walk_mutant.lm2'; Source = 'unit_output_repeated.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','append-null-path-field','0','widthpath','0','8');
        Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_repeated_operand_facet_mutant.lm2'; Source = 'unit_output_repeated.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','source-facet','2','4','1','1','rolepath','2','4','1','4','0');
        Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_repeated_operand_facet_walk_mutant.lm2'; Source = 'unit_output_repeated.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','walkroot','1','mutate','source-facet','2','4','1','1','rolepath','2','4','1','4','0');
        Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_output_typed_target.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Argv = @('one','two'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_future_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
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
    # The author's decision of 2026-10-05 (HEAD-ROLE-UNESTABLISHED-ROWS) settles the host's role: nothing
    # establishes x in inc, so `x: x + 1` defines a named Structure x and inc has no input x.  The body of x is
    # inert and its x a free name of that body (Codex, OPUS-CODEX-20261005-01, the HEAD checkpoint review): OPEN,
    # required before G5, red until built (DORMANT-BODY-FREE-INPUT).  Refused at 01ecd69b at that x, "17:8:
    # unresolved name": the body's callable row has the input x, and no caller gives it a type (l2_dyn_typed).
    # (Was, after bafca4c, "21:1: unbound dynamic input x" at the root's call: the reading the author rejected.
    # Before bafca4c it was eternal-runs: the assignment made x a field of inc.)
    [pscustomobject]@{ Name = 'unit_asgn_fallback.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # FABLE-SONNET-SEND-IN-METHODS-20260925-168 commit 2: sendMessage: X inside a method body --
    # a method called from the root sends exit(exit_code: 7; ...) directly (l2_msend<k>).
    [pscustomobject]@{ Name = 'unit_send_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0');
        Absent = @();
        Debt = @() },
    # Triage 2026-10-03: `idle: 1` at the root is an unknown head and defines a named Structure.
    [pscustomobject]@{ Name = 'entry_ret_tr_bad.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
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
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
        ) }) },
    [pscustomobject]@{ Name = 'unit_merge_value_retained.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('1'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @();
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 13; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 1 }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }) } }
            ) }
        ) },
    [pscustomobject]@{ Name = 'unit_merge_value_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @();
        GraphShapes = @([pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
        ) }) },
    [pscustomobject]@{ Name = 'unit_merge_value_method_native.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    # DUPLICATE-STOP (Codex, FABLE-CODEX-20261004-12: "If current origin is not proved, use the common dynamic
    # admission rather than a defensive abort"): make returns its own typed references, places that hold what was
    # given to them; the return's admission is make's implicit `implements`, and the process stop is gone.
    [pscustomobject]@{ Name = 'unit_merge_value_schema.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @('the record of a proved admission was not kept'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_value_host.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # An existing head retains its call/assignment role; a nested merge frame
    # does not redeclare it. The present receiver lowering refuses this call.
    [pscustomobject]@{ Name = 'unit_merge_known_head_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':3:1: more arguments than '; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_merge_last_occurrence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '5', 'merge_value', '1', '0', 'size', '7', 'merge_fresh', '1', '0', '1', '0'); Entry = 7;
        Absent = @('merge result check', 'lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_mpp[0U]\model_slot: 0U', 'l2_mpp[0U]\operand: 1U', 'l2_mpp[0U]\field: 0U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 2U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    # -193 T1: later operands merge INTO the model in operand order -- two pairs on one model slot, the
    # last one C's -- and a new name is added.  R = {3, 2, 9}.  Success is 4.
    [pscustomobject]@{ Name = 'unit_merge_three_operands.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '8', 'merge_value', '1', '0', 'size', '3', 'merge_fresh', '1', '0', '2', '0'); Entry = 4;
        Absent = @('merge result check');
        Debt = @('l2_mpp[0U]\operand: 1U', 'l2_mpp[1U]\model_slot: 0U', 'l2_mpp[1U]\operand: 2U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 3U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 2U, @ l2_mresult\)') },
    # Merge is attached to its ordinary own store, not a reserved unit result slot.
    # The callback header contains pair count, actual parent and two producer tokens;
    # 3·P inline mapping cells follow operands/body. The same source also has native merge
    # code; WalkRoot checks both dispatch modes. Merge is a publication boundary (PRIM_PUB).
    # unit_root_merge_three_operands: two pairs on Model's x (C's last), B's z appended, a write
    # `R\x: 6U` through the result, and S merging the result R (read in the turn) with a body field.
    [pscustomobject]@{ Name = 'unit_root_merge_three_operands.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 3; WalkRoot = $true;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 17; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 2 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 9; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) }
        ); Absent = @(); Debt = @() },
    # unit_root_merge_body: the body as the map's operand n -- R's x into Model's x, S's z into B's
    # appended z, S's w new.  D1: each merge's pair is inline, its count in slot 3 -- one pair: 3 wider.
    [pscustomobject]@{ Name = 'unit_root_merge_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 2; WalkRoot = $true;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'PRIM_PUB'; Width = 12; Count = 1; PrimitiveFn = 'lmx_walk_merge_map'; Sizes = @([pscustomobject]@{ Slot = 3; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 4; Shape = [pscustomobject]@{ Op = 'SELF'; Width = 1 } }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } },
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
    # K02 witness (next_core_tasks_v2.md K02, second bullet): a FORMAL merge operand -- the
    # method's own formals merged through the same value path; the first operand's model is the
    # result's schema and the later operand's added field joins it.
    [pscustomobject]@{ Name = 'unit_merge_formal_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # K02 witness (next_core_tasks_v2.md K02, first bullet): `@: A p B` binds a reference whose
    # declared model is A and whose candidate is B; a merge over p must project the ACTUAL
    # operand's fields (B's pad and x), so `R\pad` resolves and C's later x lands in the x slot.
    [pscustomobject]@{ Name = 'unit_merge_actual_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_live_source.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0', 'merge_width', '1', '4', 'merge_value', '1', '0', 'size', '9', 'merge_fresh', '1', '0', '0', '0', 'merge_fresh', '1', '2', '0', '2');
        Absent = @('merge result check'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_occurrence_range_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'merge occurrence index out of range'; Absent = @(); Debt = @() },
    # -193 T2 (on -194 K1): a later field repeating a name an earlier operand ADDED goes INTO that
    # appended slot, and the body merges INTO the result as the last operand (the kernel's `operand =
    # count`) -- both were located refusals in T1.  Never a second slot of the same name: `R\[0]z` and
    # `R\[0]x` read the one slot.  Mutants: the body appended instead of joined (body_repeat exits
    # 83); only model slots matchable (added_repeat exits 83).  A later field whose type is not the
    # placed field's stays refused.  4 and 19.
    [pscustomobject]@{ Name = 'unit_merge_added_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '5', 'merge_value', '1', '2', 'size', '3', 'merge_fresh', '1', '2', '2', '0'); Entry = 4;
        Absent = @('merge result check');
        Debt = @('l2_mpp[0U]\model_slot: 2U', 'l2_mpp[0U]\operand: 2U');
        NativePatterns = @('l2_mstatus: lmx_merge_profiles_owned\(l2_mops, 3U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n\d+, l2_mpp, 1U, @ l2_mresult\)') },
    [pscustomobject]@{ Name = 'unit_merge_body_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_width', '1', '2', 'merge_value', '1', '0', 'size', '5', 'merge_width', '2', '5', 'merge_value', '2', '2', 'size', '9'); Entry = 19;
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
    [pscustomobject]@{ Name = 'unit_q20_merge_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0', 'merge_native', '1', '0', '0', '0', 'merge_native', '2', '2', '1', '0'); Entry = 5;
        Absent = @('merge result check'); Debt = @() },
    # T5 slice 1: add5 is merge(y: 5; add). y is a data field, x stays ARG 0, native is 0.
    # add5(1) = 6. Mutant: read y as ARG — INVALID, not 6.
    [pscustomobject]@{ Name = 'unit_pap_add5.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 6;
        Absent = @('l2_m1_tr'); Debt = @('lmx_int_store_known(l2_entry_slot[0], 5)', 'c.LMX_WALK_OP_AT, 3U)', 'c.LMX_WALK_OP_CALL, 3U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'ADD'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }
            ) },
            [pscustomobject]@{ Op = 'CALL'; Width = 3; Count = 1; CallLink = $true; CalleeSlot = 1; InputKinds = @('int'); ResultKind = 'int'; Edges = @(
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }
            ) }
        ) },
    # T6: return: addN builds {n: value} and one merge. add5(1)=6, add100(1)=101, add5(1)=6.
    # Mutant: one field n for both results — the second call is not 101. Entry 7, 0 is refusal.
    [pscustomobject]@{ Name = 'unit_make_adder.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh('); Debt = @('lmx_call_prim(', 'lmx_int_store_known(', 'c.LMX_WALK_OP_OF, 3U)', 'c.LMX_WALK_OP_NODE, 1U)') },
    # T6b: the node is built from the host's activation at the return -- n changed before it, k a
    # field the host declares -- and carries only what addN names, not u.  The node is addN's occurrence copied (3:
    # args, return, one frame) under its copied lexical context C -- the host's layout (6) and a body field per formal
    # (2): k at its source slot 3, n in formal 0's field 6, u's field 7 left empty (book, "Returned nested methods"; Codex,
    # 2026-09-28). add7(1)=7, add100(1)=100, add7(1)=7; the base translator refused k.
    # Mutants: the host's statements dropped (D-92) -- exit 0; the formal as the machine argument
    # -- add7(1)=6, exit 0. Every int formal carried is the 6U pin, not a behavior.
    [pscustomobject]@{ Name = 'unit_make_adder_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_arena_ref_store(l2_madc, 7U,', 'lmx_fresh('); Debt = @('lmx_arena_ref_store(l2_madc, 3U, l2_mad_cell)', 'lmx_int_store_known(l2_mad_cell, l2_p0_0) != 0 || lmx_arena_ref_store(l2_madc, 6U, l2_mad_cell)', 'lmx_arena_refs_open_owned(l2_program_arena, l2_mad, 3U)', 'lmx_arena_refs_open_owned(l2_program_arena, l2_madc, 8U)', 'lmx_int_store_known(l2_mad_cell, lmx_int_value_known(') },
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
    # FIXED-BLOCKS-AUDIT: the fields a capture copies are as many as the definition reads -- 40, past the 32 places
    # the copy had (it refused "a captured Structure has too many fields read").
    [pscustomobject]@{ Name = 'unit_capture_many_fields.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_many_fields_walk.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # Item 738 slice 2 (steps/capture-738.md §6): the capture's refusals, located -- the needle carries the
    # line and column.  A model tried for the walk silently now gives its own first reason, where it stands,
    # in its host's refusal (l2_mad_unwalkable); before, the host's header alone.  Update-position paths
    # resolve their root (l2_scan_path_root); a passed-on field is the capture's to check (l2_actual_path);
    # a field that is not a number or a char is refused at translation, not by the host's abort at run.
    [pscustomobject]@{ Name = 'unit_capture_struct_past_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':23:17: a path through a captured Structure goes past its field'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_past_write_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':18:9: a path through a captured Structure goes past its field'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_nofield_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':20:21: a path through a captured Structure names no field of its type'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_nofield_write_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':16:9: unknown field path segment'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_field_struct_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':22:27: a captured Structure''s Structure field is not copied yet (item 738: value fields)'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_field_array_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:21: a captured Structure''s field that is not a number or a char is not copied yet (item 738: value fields)'; Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_capture_struct_call_head_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:17: a path through a captured Structure names no field of its type'; Args = @('0'); Absent = @(); Debt = @() },
    # Triage 2026-10-03: a captured Structure used whole is a required positive; the pinned
    # refusal was an implementation limit, not a rule. OPEN positive (capture closure).
    [pscustomobject]@{ Name = 'unit_capture_struct_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    # A captured copy of two operands has no one named Structure for its type. OPEN positive
    # (capture closure: a capture typed by a merge result's own schema).
    [pscustomobject]@{ Name = 'unit_capture_struct_merge_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
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
        WalkedMethods = @(0); Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t6_root_held_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_t6_root_held_arity_refused.lm2:11:9: p5 has no argument y'; Absent = @(); Debt = @() },
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
            [pscustomobject]@{ Op = 'CALL'; Width = 4; Count = 1; CallLink = $true; ResultKind = 'pointer'; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } }) } }) }
        ); Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)'); Debt = @() },
    # Reading 1 (book, "Dynamic sources and the lexical fallback"; Codex, 2026-09-28 and 2026-10-04): a free name
    # of a returned method takes the nearest binding of its callers first, the node's copied context only as the
    # fallback -- the root's n 100: 101; go's formal n 7: 8; plain, which only hands the name on: the copy, 6, where
    # no caller has an n, and the root's 100 through plain, 101, where it has.  A held call asks its model's names
    # along the chain of callers (K04 S3); the model's ARG falls back to the graph through `node`.
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
    # The merge given as the actual is followed as a node of its model (K04 S3).
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
        Needle = 'unit_upper_undeclared_refused.lm2:10:30: unbound dynamic input NOPE'; Absent = @(); Debt = @() },
    # FIXED-BLOCKS-AUDIT: the words of a refusal name what they refuse in full -- a free name of 300 bytes, a
    # named Structure of 300 bytes; the words were cut at 256 and 240 bytes (l2_error_name).
    # FIXED-BLOCKS-AUDIT: sizeof's operand is a declared name of any length (a scalar, a reference and an array local
    # of 300 bytes); a name over 200 bytes was "unresolved name".  Natively: a method with sizeof keeps its native
    # word under --walk-methods.
    [pscustomobject]@{ Name = 'unit_sizeof_long_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # SPRINTF-PAST-BUFFER: twenty nested `for:` loops, each stepping its counter; the step's indentation was written
    # past 64 bytes on the stack and the previous translator's L1 does not parse.  Native and walked.
    [pscustomobject]@{ Name = 'unit_for_nested_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_for_nested_deep_walk.lm2'; Source = 'unit_for_nested_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_unbound_input_long_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ('unit_unbound_input_long_name_refused.lm2:11:30: unbound dynamic input unbound' + ('u' * 293)); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_struct_arity_long_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ('unit_struct_arity_long_name_refused.lm2:13:1: more arguments than Model' + ('m' * 295) + ' has formals'); Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_s1_catch_user_break.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 105; WalkRoot = $true; PadOwnCells = 1;
        Absent = @();
        GraphShapes = @([pscustomobject]@{ Op = 'PAD'; Width = 3; Count = 1 });
        Debt = @('c.LMX_WALK_OP_WHILE, 3U)', 'c.LMX_WALK_OP_BREAK, 1U)', 'c.LMX_WALK_OP_CONTINUE, 1U)', 'c.LMX_WALK_OP_CALL,') },
    [pscustomobject]@{ Name = 'unit_catch_payload_graph.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); PadOwnCells = 1;
        GraphShapes = @([pscustomobject]@{ Op = 'PAD'; Width = 3; Count = 1 });
        Absent = @(); Debt = @('c.LMX_WALK_OP_PUT_OF, 4U)') },
    [pscustomobject]@{ Name = 'unit_catch_scope_repeat.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 20; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); PadOwnCells = 1;
        GraphShapes = @([pscustomobject]@{ Op = 'PAD'; Width = 3; Count = 1 });
        Absent = @(); Debt = @('c.LMX_WALK_OP_WHILE, 3U)') },
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
    # DUPLICATE-ADMISSION-STOP (b): the formal's admission of a declared Structure is proved by the translation;
    # what is left is the record the reads by name need, checked with a stop that says so.
    [pscustomobject]@{ Name = 'unit_site_model_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @('lmx: invariant: the record of a proved admission was not kept') },
    [pscustomobject]@{ Name = 'unit_site_hidden_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_views.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 9; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_null.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 5; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_collision.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_local_target.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_receiver.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_model_header_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_future_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':3:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_scope_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':6:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_local_model_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':5:8: unknown type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 7; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_own_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_host_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 5; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_return_bare.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_layout_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_model_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':7:9: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_opaque_model_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':4:1: unknown field path root'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_name_projection.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_input_carry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_carry_conversion.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Table = 'unit_portable_reference_convert_table.lm2'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_carry_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'conversion'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_pointer_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_pointer_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalPointerIndexShape; Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_pointer_index_erase_real_arg_mutant.lm2'; Source = 'graph_shape_pointer_index.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = ''; Args = @('0','mutate','null-path','4','0','3','1','1') + $criticalPointerIndexShape; Entry = 7; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_raw_pointer_index_expression.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_raw_pointer_index_types.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_raw_pointer_index_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_foreign_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_part_repeat.lm2'; Parts = @('unit_site_part_repeat_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_part_caller.lm2'; Parts = @('unit_s7_part_root_below_refused_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_for_initializer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_prefix_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 4; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_parent_fallback.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_mixed_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = ':14:14: unbound dynamic input p'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_constructor_reception.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkRoot = $true; NativeRoot = 3; NativeMethods = @(0); WalkedMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_sizeof_hidden.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_future_only_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unit_site_future_only_refused.lm2:11:30: unbound dynamic input p'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_portable_reference_descriptors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1);
        Debt = @('LMX_WALK_OP_ARG'); Note = 'both nonprimitive signature spellings address the descriptor, not transport storage' },
    [pscustomobject]@{ Name = 'unit_portable_reference_native_descriptors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; NativeMethods = @(0,1);
        Debt = @('LMX_WALK_OP_ARG'); Note = 'same descriptor-signature identity checks through native trampolines from an actually walked caller' },
    [pscustomobject]@{ Name = 'unit_portable_reference_convert.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Table = 'unit_portable_reference_convert_table.lm2';
        Debt = @('LMX_WALK_OP_PUT, 3U)', 'LMX_WALK_OP_CALL'); Note = 'nonidentity primitive conversion before physical indirect store, evaluated once' },
    [pscustomobject]@{ Name = 'unit_portable_reference_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 6; WalkMethods = $true; WalkedMethods = @(0,1,2);
        GraphShapes = @([pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'DEREF'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3 } }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 17; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 5; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }, [pscustomobject]@{ Slot = 14; Value = 2 }, [pscustomobject]@{ Slot = 16; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer'; Sizes = @([pscustomobject]@{ Slot = 4; Value = 1 }, [pscustomobject]@{ Slot = 5; Value = 2 }, [pscustomobject]@{ Slot = 7; Value = 0 }) } }) } }
        ) }); Debt = @(); Note = 'higher-depth receiving model survives dereference; refusal leaves physical and working binding unchanged' },
    [pscustomobject]@{ Name = 'unit_portable_reference_store_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Debt = @('LMX_WALK_OP_PUT, 3U)'); Note = 'physical target selected once before RHS mutates its pointer binding' },
    # ADMIT_AS carries two map cells per actual source child. Model now has its
    # typed field plus the retained INIT: mapped frames are13/14, not11/12.
    # Identity frames remain9. Frozen namespace cutover08 proves these exact
    # widths and coordinates; the runtime counts/links/results remain strict.
    [pscustomobject]@{ Name = 'unit_own_reference_reception.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 8;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 2; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 2; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 13; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 3; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 14; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 0; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 2; CallLink = $true; ResultKind = 'pointer' } }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 3; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 14; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 2; CallLink = $true; ResultKind = 'pointer' } }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_reference_reentry.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 2; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 9; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2 } }) } }) },
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 2; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 13; Sizes = @([pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3 } }) } }) }
        ); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_own_reference_failure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 7;
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 22; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 5; Value = 2 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }) },
            [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }); Edges = @(
                    [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }); Edges = @(
                        [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 17 }) } }
                    ) } }
                ) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 17; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 5; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }
            ) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADMIT_AS'; Width = 17; Sizes = @([pscustomobject]@{ Slot = 2; Value = 1 }, [pscustomobject]@{ Slot = 5; Value = 1 }, [pscustomobject]@{ Slot = 8; Value = 1 }); Edges = @([pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'CALL'; Width = 8; CallLink = $true; ResultKind = 'pointer' } }) } }) }
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
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_pointer_raw_c_admission_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    # Common RHS typing: explicit initializer and later store share conversion/admission.
    [pscustomobject]@{ Name = 'unit_rhs_fnptr_checkpoint.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_compound_admission_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_rhs_reference_admission.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_pointer_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_fnptr_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    # The three refusals below receive a candidate of another shape through a reference that reads the field the
    # candidate lacks: the refusal is by that field (the receiving-use contract).  Each was a refusal by Model's whole
    # shape of a reference never read, which is a valid program.
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_init_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_assign_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    # The programs those three were before the read was added, as the positives they are: the same candidate by the
    # same route, no field read through the reference, and the reference observed to be the candidate.  With the
    # methods walked, check is walked; raw, whose result is a machine cast, keeps its native word.
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_init_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_init_thin_walk.lm2'; Source = 'unit_rhs_void_admission_init_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(1); NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_assign_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_void_admission_assign_thin_walk.lm2'; Source = 'unit_rhs_void_admission_assign_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(1); NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_rhs_returned_model_thin_walk.lm2'; Source = 'unit_rhs_returned_model_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
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
    # FIXED-BLOCKS-AUDIT: the words name the catch in full -- 300 bytes.  They were formatted into 160 bytes without
    # a bound, and a name this long crashed the translator.
    [pscustomobject]@{ Name = 'unit_catch_duplicate_long_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ('unit_catch_duplicate_long_name_refused.lm2:8:1: duplicate catch: Oops' + ('o' * 296)); Absent = @(); Debt = @() },
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
    # CALLABLE-FORMAL-STATEMENT-CALL-INTERNAL: a standalone Frame of a known callable formal is
    # that same nullary call, for a returning contract and for a contract with no result. The empty
    # argument list is not a store into the formal. Unknown f() stays a definition.
    [pscustomobject]@{ Name = 'unit_formal_frame_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Says = @('m 1');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_frame_sub_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 0;
        Says = @('s 1');
        Absent = @(); Debt = @() },
    # Row 5: a no-result occurrence admitted to (Holder: x) and (@: Holder x).
    # mark is not slot 0. Transport does not run the body. The walker is unclaimed.
    [pscustomobject]@{ Name = 'unit_occ_descriptor_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_descriptor_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_occ_descriptor_refused.lm2:17:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # Row 6: a path selects the callable field's occurrence. An own of the
    # same spelling hides the unit method. The walker is unclaimed.
    [pscustomobject]@{ Name = 'unit_occ_path_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_own_shadow.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_occ_own_shadow.lm2:15:5: incompatible entry signature'; Absent = @(); Debt = @() },
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
        Needle = 'unit_root_struct_call_refused.lm2:14:1: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_root_struct_call2_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_root_struct_call2_refused.lm2:15:1: more arguments than '; Absent = @(); Debt = @() },
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
        NativeMethods = @(0); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_bind_method_thin_other_walk.lm2'; Source = 'unit_bind_method_thin_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # The receiving-use contract (Codex, FABLE-CODEX-20261003-01 and -20261004-01): a method's own typed reference
    # receives a candidate by what its Consumer reads through it.  Each program natively and with its methods walked.
    # The native text must call the reception by coverage; the graph facts hold the instruction's mode and its cells.
    # A Consumer that compares the reference by identity and reads no field: the exact candidate, at a declaration with
    # its initializer and at a later store.
    [pscustomobject]@{ Name = 'unit_recv_use_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $recvUseEmptyShape; Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_identity_walk.lm2'; Source = 'unit_recv_use_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $recvUseEmptyShape; Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_identity_mode_mutant.lm2'; Source = 'unit_recv_use_identity.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','2','4','2','8') + $recvUseEmptyShape; Entry = 7; Absent = @(); Debt = @() },
    # A field the Consumer does not read: missing in one candidate, there with another type in the other.
    [pscustomobject]@{ Name = 'unit_recv_use_unused_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_unused_field_walk.lm2'; Source = 'unit_recv_use_unused_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # A field the Consumer reads and the candidate lacks: refused where the store is reached, the candidate evaluated
    # once, the reference still holding what it held.  A store through the place asks for its field as a read does.
    [pscustomobject]@{ Name = 'unit_recv_use_used_field_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_used_field_refused_walk.lm2'; Source = 'unit_recv_use_used_field_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # One candidate received thin, then by a second reference: refused when that Consumer reads the field it lacks,
    # received through the same correspondence when it reads fields it carries.
    [pscustomobject]@{ Name = 'unit_recv_use_later_consumer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_later_consumer_walk.lm2'; Source = 'unit_recv_use_later_consumer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # The selector is part of the requirement: a bare name and [0] reach the candidate's one field of that name, [1]
    # asks for an occurrence it lacks.
    [pscustomobject]@{ Name = 'unit_recv_use_selectors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_selectors_walk.lm2'; Source = 'unit_recv_use_selectors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # A path below the place: a nested level in the nested Structure's own index space, one edge per selector.  The
    # facts hold every cell of the instruction's coverage; two shape mutants: an edge emptied, the nested level's
    # start emptied.
    [pscustomobject]@{ Name = 'unit_recv_use_nested_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $recvUseNestedShape; Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_path_walk.lm2'; Source = 'unit_recv_use_nested_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $recvUseNestedShape; Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_path_edge_mutant.lm2'; Source = 'unit_recv_use_nested_path.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','4','2','15') + $recvUseNestedShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_path_level_mutant.lm2'; Source = 'unit_recv_use_nested_path.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','1','4','2','12') + $recvUseNestedShape; Entry = 7; Absent = @(); Debt = @() },
    # A field that is needed and missing is refused however the need reaches the reference.  In the programs below
    # the need is not in the method's own body: a callee the reference is passed whole to reads the field, a
    # definition inside the method reads it -- one the method returns, one the method calls, one a definition beside
    # it calls -- another method reads it by a path.  Each refusal is right by the contract; these rows hold the
    # behaviour.  What the callee reads through its formal is composed into the coverage of the reference handed to
    # it whole (the passed row: the native text receives by coverage).  The other routes still receive in full, for
    # want of a composed coverage; that is held apart, by the probes below.
    [pscustomobject]@{ Name = 'unit_recv_use_passed_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_refused_walk.lm2'; Source = 'unit_recv_use_passed_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_reader_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_reader_refused_walk.lm2'; Source = 'unit_recv_use_nested_reader_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_called_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_called_refused_walk.lm2'; Source = 'unit_recv_use_nested_called_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_sibling_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_sibling_refused_walk.lm2'; Source = 'unit_recv_use_nested_sibling_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # A path rooted at the method's name reaches its reference from another method.  A candidate with every field in
    # its own places is received and read through the reference's correspondence from the other method; one that
    # lacks the field read there is refused at the declaration.
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method_walk.lm2'; Source = 'unit_recv_use_path_from_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method_refused_walk.lm2'; Source = 'unit_recv_use_path_from_method_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # The coverage composed across a call, and the definition nothing consumes (Codex, FABLE-CODEX-20261004-04 and
    # -11).  Nothing that runs reads the field the Other lacks: in the first the reading definition is neither
    # called nor returned by its method and asks for nothing; in the second the callee the reference is passed to
    # reads nothing, so the composed coverage is known and empty.  Both receive the Other.  The passed_reads pair
    # runs every route by which a callee's reads reach the reference -- directly, handed on, in a branch the call
    # does not take, handed to itself, by the formal's name: received where the candidate carries what is read,
    # refused at the declaration where it does not.  A store the reference refuses publishes no candidate: the
    # value held before reaches the later Consumer, and that Consumer is not refused for the rejected one.
    [pscustomobject]@{ Name = 'unit_recv_use_nested_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_dormant_walk.lm2'; Source = 'unit_recv_use_nested_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_thin_walk.lm2'; Source = 'unit_recv_use_passed_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_reads.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_reads_walk.lm2'; Source = 'unit_recv_use_passed_reads.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_reads_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_passed_reads_refused_walk.lm2'; Source = 'unit_recv_use_passed_reads_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_rejected_store_keeps.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_recv_use_rejected_store_keeps_walk.lm2'; Source = 'unit_recv_use_rejected_store_keeps.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # TEMPORARY IMPLEMENTATION-COVERAGE PROBES (Codex, FABLE-CODEX-20261004-04).  Not language acceptance criteria.
    # Each reads the generated text of a program above and holds the present LIMIT of the coverage analysis: the
    # program's reference gets no coverage and is received in full.  A composition that gives it a coverage and still
    # refuses what must be refused is correct, closes the gap, and this row must then change or go.
    [pscustomobject]@{ Name = 'unit_recv_use_nested_called_refused_limit_probe.lm2'; Source = 'unit_recv_use_nested_called_refused.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_implements_receiving_use('); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_sibling_refused_limit_probe.lm2'; Source = 'unit_recv_use_nested_sibling_refused.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_implements_receiving_use('); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_reader_refused_limit_probe.lm2'; Source = 'unit_recv_use_nested_reader_refused.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_implements_receiving_use('); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method_limit_probe.lm2'; Source = 'unit_recv_use_path_from_method.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_implements_receiving_use('); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_recv_use_path_from_method_refused_limit_probe.lm2'; Source = 'unit_recv_use_path_from_method_refused.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_implements_receiving_use('); Debt = @('lmx_implements_receiver_view(') },
    # TEMPORARY IMPLEMENTATION-COVERAGE PROBES of another kind.  Not language rules either.  The coverage analysis
    # counts a definition inside a method as unconsumed when no method calls it and its method does not return it
    # (unit_recv_use_nested_dormant).  That holds only while no other route to such a definition is accepted.  The
    # two routes below -- a path from outside the method, a copy of the method -- are refused by this
    # implementation today.  A row that goes red means the route opened: the analysis must model it first.
    [pscustomobject]@{ Name = 'unit_recv_use_nested_path_reach_limit_probe.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_use_nested_path_reach_limit_probe.lm2:30:11: unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_use_nested_copy_reach_limit_probe.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_use_nested_copy_reach_limit_probe.lm2:30:10: unknown merge operand'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_root_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_root_used_other_refused.lm2:14:1: implements is false in a typed binding'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_method_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_method_used_other_refused.lm2:14:5: implements is false in a typed binding'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_root_letter.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('ok'); Entry = 2;
        Absent = @(); Debt = @('\fn: lmx_walk_admit_letter') },
    [pscustomobject]@{ Name = 'unit_bind_root_letter_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_known_b_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_known_b_call_refused.lm2:16:1: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_candidate_not_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_bind_candidate_not_name_refused.lm2:18:5: a typed binding whose candidate is not a name is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_thin_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_used_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_formal_used_other_refused.lm2:21:13: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_bind_prim_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Q58 (K03c): `q:` with the body `show(7)`, show a method -- a named Structure holding the retained call, closed by
    # the level cut alone; executed by its bare name (hits 0 -> 7).  Formerly unit_named_struct_guard_call_refused,
    # which pinned the withdrawn reading that a call first in the body makes no named Structure.
    [pscustomobject]@{ Name = 'unit_named_struct_call_body_retained.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
        Needle = 'lm2:9:1: unbound dynamic input g'; Absent = @(); Debt = @() },
    # DORMANT-BODY-FREE-INPUT (Codex, OPUS-CODEX-20261005-01): Counter's g after the bare `return` is its input all
    # the same, and its call with no source of g is refused at the call (above; until 2026-10-05 at g, 7:12).
    # dead_tail_given: the root gives g, so the call is admitted, the tail does not run (Counter\n stays 0), and
    # the retained graph holds it -- Counter has five children, four without the tail.  dead_tail_invalid_refused:
    # a dead tail no execution could make valid is refused where it stands: a check, not an execution.
    [pscustomobject]@{ Name = 'unit_named_struct_dead_tail_given.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0','postpaths','widthpath','1','0','5','endpostpaths'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_dead_tail_given_walk.lm2'; Source = 'unit_named_struct_dead_tail_given.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0','postpaths','widthpath','1','0','5','endpostpaths'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_struct_dead_tail_invalid_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_struct_dead_tail_invalid_refused.lm2:7:10: unresolved name'; Absent = @(); Debt = @() },
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
    # K02c (next_core_tasks_v2.md K02 bullet 3; defects.md MERGE-HIDDEN-INPUT-PROJECTION; Codex DS-CODEX-004): a
    # unit-level MERGE RESULT named free in a method is that method's hidden input like any unit field (Q52), its
    # tagged merge schema the receiving metadata (l2_input_schema): the caller's own `copy: merge: Other` (22) wins
    # over the unit's (1); an intermediate caller without a binding forwards; no caller binding falls back to the
    # unit's; a candidate with `value` at another position is read by NAME through the pair map (K01); native and,
    # for the first, walked -- the walker's ADMIT_AS takes the unit's result itself as the model, read where the op
    # runs (a frame in the model's place, lmx_walk_model_operand).
    [pscustomobject]@{ Name = 'unit_merge_hidden_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_merge_hidden_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @('LMX_WALK_OP_ADMIT_AS') },
    [pscustomobject]@{ Name = 'unit_merge_hidden_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_hidden_lexical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_hidden_position.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Its negative: the caller's result (Bare) has no `value`, which read uses -- the Consumer-uses admission refuses
    # the call at translation (the source does not carry a field the Consumer reads; K01's used-edge check).
    [pscustomobject]@{ Name = 'unit_merge_hidden_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_merge_hidden_refused.lm2:11:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # K03d (next_core_tasks_v2.md K02 bullet 4; docs, "Явное копирование": `b: merge A C` -- the operands are A
    # and C, the outer b receives the result, the destination name is not a first operand).  The receiver `merge`
    # written as an ATOM with its operands after it is the book's own spelling of one statement -- the same
    # statement as `b: merge: A C`, settled into that one frame form in the tree before any later pass reads it
    # (arity, mrs, native emission, walker), so both spellings emit the same L1.  A method-local result reading
    # the CURRENT cells, a three-operand result whose later operand joins an appended slot, and a unit-level
    # result a method reads as its hidden input (the shape K03b/K03c recorded as still "unresolved name merge").
    [pscustomobject]@{ Name = 'unit_merge_atom_receiver.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_atom_operands.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 4;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_merge_atom_unit.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The same statement with the destination name ALREADY bound is an assignment of a merge value to an existing
    # binding, not a declaration; it is refused by the same receiving-context path, with the same diagnostic at
    # the same site as its frame-spelling twin `w: merge: Model`.  The message is that path's current one.
    [pscustomobject]@{ Name = 'unit_merge_atom_assign_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_merge_atom_assign_refused.lm2:10:5: assignment value has unknown type'; Absent = @(); Debt = @() },
    # K04a (next_core_tasks_v2.md K04; steps/callable-actual-projection-20260930.md, witness matrix row 1): a
    # NONRETURNING `sub task` received by a `(task: f)` formal is transmitted by reference -- the counter the
    # task changes stays 0 through the receiving call and is changed once by the explicit invocation.
    [pscustomobject]@{ Name = 'unit_callable_sub_transport.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # K04a (steps/callable-actual-projection-20260930.md, matrix row 2): the callable input is FORWARDED from one
    # formal to another -- the actual is resolved in the caller's context, not by a unit-namespace method lookup
    # -- and the transport still executes nothing (hits 0 through both calls, then 1 after the explicit call).
    [pscustomobject]@{ Name = 'unit_callable_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Its negative: forwarding is not a way around the signature check -- a callable formal whose contract is
    # incompatible with the receiving formal's is refused at the call.
    [pscustomobject]@{ Name = 'unit_callable_forward_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_callable_forward_refused.lm2:20:13: incompatible entry signature'; Absent = @(); Debt = @() },
    # K04b (steps/callable-actual-projection-20260930.md, matrix row 3): the equivalent nullary actual forms --
    # bare `task`, `task()`, `task: ()` -- carry one receiving contract to a callable formal: the same descriptor,
    # no execution, hits 0 through all three and 1 only at the explicit invocation.
    [pscustomobject]@{ Name = 'unit_callable_nullary_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # K04b, matrix row 4: a RETURNING callable received once by a callable formal (reference reception -- the
    # callable does not execute: hits stays 0) and once by a result-receiving primitive formal (executes exactly
    # once -- hits becomes 1 and the value is the callable's result, 41).
    [pscustomobject]@{ Name = 'unit_callable_returning_two_contracts.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
        Needle = 'lm2:8:5: unbound dynamic input g'; Absent = @(); Debt = @() },
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
    # K01b witness (steps/k01-selector-identity-20261001.md §5): the correspondence carries one
    # target per selector.  Pair reads its own two x (0), and through the admitted Triple the SAME
    # required field 1 must give 30 for bare `v\x` (the value's last occurrence) and 20 for
    # `v\[1]x` (its occurrence 1).  Red before K01b: exit 82, both selectors one target.
    [pscustomobject]@{ Name = 'unit_occ_selector_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # K01c witness (same note, §5): writes and addresses of a repeated name through the admitted
    # candidate follow the same edge as reads -- bare reaches the value's last x, `[1]` its
    # occurrence 1 -- with the identity order and a repeated call on one value.
    [pscustomobject]@{ Name = 'unit_occ_selector_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true;
        Absent = @(); Debt = @() },
    # K01d witnesses (same note, §5): the mirror pair.  The candidate's LAST occurrence of the
    # name is an int, its occurrence 0 a size_t like the requirement's, so the bare read (which
    # selects the last occurrence) must be refused while the ordinal read is legal.
    [pscustomobject]@{ Name = 'unit_occ_selector_last_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_occ_selector_ordinal_ok.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
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
    # satisfy an int formal.  K04c: the refusal is the ordinary reference-versus-number one, the phrase
    # the Structure case already gives (unit_valkind_arg_ref_refused), not the value-position
    # no-result diagnostic and not the call-form one.
    [pscustomobject]@{ Name = 'unit_value_call_sub_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_value_call_sub_refused.lm2:14:3: a reference where a number is asked'; Absent = @(); Debt = @() },
    # The canonical nullary call form of the same nonreturning callable: one receiving contract with the
    # bare atom above, so one refusal.
    [pscustomobject]@{ Name = 'unit_callable_frame_int_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_callable_frame_int_refused.lm2:16:3: a reference where a number is asked'; Absent = @(); Debt = @() },
    # An atom naming a UNIT-LEVEL named Structure is a reference like a method-local one; a number
    # formal refuses it the same way (was accepted and emitted as an int argument).
    [pscustomobject]@{ Name = 'unit_named_struct_number_arg_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_struct_number_arg_refused.lm2:16:15: a reference where a number is asked'; Absent = @(); Debt = @() },
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
    # that call is refused where it stands: a resolved argumentless Structure takes no
    # argument (the arity refusal, Q59), as its bare atom is.
    [pscustomobject]@{ Name = 'unit_empty_call_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('fn: lmx_walk_admit', 'c.LMX_WALK_OP_EMPTY, 1U)'); Debt = @('c.LMX_WALK_OP_EXEC, 5U)') },
    [pscustomobject]@{ Name = 'unit_named_struct_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0','widthpath','0','21','namepath','1','0','Counter','namepath','1','1','bump',
            'widthpath','1','0','4','parentpath','1','0','0','nativepath','1','0','1',
            'rolepath','2','0','1','8','1','rolepath','2','0','2','8','0','rolepath','2','0','3','1','4',
            'parentpath','2','0','1','1','0','parentpath','2','0','3','1','0',
            'samepath','2','3','2','1','0','samepath','2','8','2','1','0',
            'samepath','3','1','2','2','1','0');
        GraphShapes = @([pscustomobject]@{ Op = 'EXEC'; Width = 5; Count = 3 });
        Absent = @('fn: lmx_walk_admit'); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_root_bare_callable_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 1; WalkRoot = $true;
        GraphCalls = @([pscustomobject]@{ Method = 0; Arity = 0; Count = 2; InputKinds = @(); ResultKind = 'int'; });
        Absent = @(); Debt = @('include: "<stdio.h>" "<stdlib.h>"') },
    # -197 (b): the preamble's C headers are the program's own mechanics' -- <stdio.h> and
    # <stdlib.h> always (X1 is fprintf(stderr) + abort, the launch hands the host stdout/stderr),
    # <string.h> is also required by typed source-leaf storage initialization.
    # Header minimization is not an executable/source-graph invariant.
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
        GraphShapes = @([pscustomobject]@{ Op = 'CALL'; Width = 3; Count = 6; CallLink = $true }); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_walk_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4);
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_ARG'; Width = 4; WitnessKind = 'int'; Count = 1; NextShape = [pscustomobject]@{ Op = 'RET'; Width = 1 }; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 3 }) } }) } }) },
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
        WalkedMethods = @(0,1,2);
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'RET'; Width = 2; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'descriptor'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) } }) },
            [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'descriptor'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = 9 }) } }
            ) },
            [pscustomobject]@{ Op = 'RET'; Width = 2; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'descriptor'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'descriptor'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }) } }
            ) } }) }
        ); Debt = @() },
    # T4b class 2: a numeric field named like a formal is ARG until its declaration, then the field -- under the
    # working state (7b-2, by name): bump's `int: n` carries ARG 0 into its working value (SET over OWN, l2_rw54-56)
    # and then reads that value (OWN); see reads ARG before the declaration (`a: n`, l2_rw67) and carries after it.
    # (Were PUT of ARG into the cell and AT reads: the c3b-2 in-place row.)
    [pscustomobject]@{ Name = 'unit_walk_formal_bind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m0_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)', 'l2_entry_leaf\native: (cast: (LmxEntry) l2_m2_tr)',
            '@: Lmx l2_rw54 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw53, c.LMX_WALK_OP_PUT, 4U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
            [pscustomobject]@{ Op = 'SET'; Width = 3; Count = 1; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } }, [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
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
            'c.LMX_WALK_OP_PUT_OF, 4U)');
        GraphShapes = @(
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } }) } },
                [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ARG'; Width = 4; WitnessKind = 'int'; Sizes = @([pscustomobject]@{ Slot = 1; Value = 0 }) } }) },
            [pscustomobject]@{ Op = 'SET_OF'; Width = 4; Count = 1; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } }) } },
                [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'ADD'; Width = 3; Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN_OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 4 }) } }) } }) } }) } }) }
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
        Absent = @('c.LMX_WALK_OP_DEREF'); Debt = @('\fn: lmx_walk_merge_map') },
    # A WRITE THROUGH A REFERENCE (FABLE-OPUS-ROOT-PUTOF-MUL-20260925-183 commit 1): `m\value: 42U` is
    # PUT of an OF place, its holder read once from m; read back through m and through
    # a method's formal (the same Structure, by reference), Model itself untouched: 7.
    [pscustomobject]@{ Name = 'unit_root_putof.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @(); GraphShapes = @(
            [pscustomobject]@{ Op = 'PUT'; Width = 3; Count = 1; Edges = @(
                [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OF'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 0 }); Edges = @([pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 2 } }) } },
                [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = 42 }) } }
            ) }
        ) },
    # `* / %` AT THE WALKED ROOT (FABLE-OPUS-ROOT-PUTOF-MUL-20260925-183 commit 2): MUL/DIV/MOD (-170 c1) over
    # one type -- precedence (2 + 3 * 4 = 14), a size_t %, an int / with a negative operand (-7 / 2 = -3,
    # as C), left to right (3 * 5 % 4 = 3): 15. Zero divisors are retained too;
    # translation-only coverage below must never execute the undefined C case.
    [pscustomobject]@{ Name = 'unit_root_mul.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 15;
        Absent = @(); Debt = @('c.LMX_WALK_OP_MUL, 3U)', 'c.LMX_WALK_OP_DIV, 3U)', 'c.LMX_WALK_OP_MOD, 3U)') },
    [pscustomobject]@{ Name = 'unit_root_div_zero_refused.lm2'; Expect = 'translates'; Exit = 0;
        Needle = ''; Absent = @(); Debt = @('c.LMX_WALK_OP_DIV, 3U)') },
    [pscustomobject]@{ Name = 'unit_discard_calls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 11112;
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
    [pscustomobject]@{ Name = 'unit_arg_addr_pointer.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Says = @('P local is null');
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
    # The else shell is child 0 of the IF's other body. else\hosted reads 21. Walked twin drops the native word.
    [pscustomobject]@{ Name = 'unit_body_path_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # The else shell inside a while is still child 0 of the IF's other body.
    [pscustomobject]@{ Name = 'unit_body_path_else_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_else_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # The else shell inside a for is still child 0 of the IF's other body.
    [pscustomobject]@{ Name = 'unit_body_path_else_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_else_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # Point inside the then arm. if\pt\x is 4. return at the fn column is the trailer.
    [pscustomobject]@{ Name = 'unit_body_path_if_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Point inside a while. while\pt\x is 4. return at the fn column is the trailer.
    [pscustomobject]@{ Name = 'unit_body_path_while_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Point inside an until block. pt\x is 4. return at the fn column is the trailer.
    [pscustomobject]@{ Name = 'unit_body_path_until_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Force the first merge to fail: the handler stores 4 and the call exits 7.
    # Without the existing merge tap the merge succeeds and the handler is never entered.
    [pscustomobject]@{ Name = 'unit_body_path_merge_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; MergeFail = 1;
        Absent = @(); Debt = @() },
    # Point inside a catch. The caught value is stored and read back as 1.
    [pscustomobject]@{ Name = 'unit_body_path_catch_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 1;
        Absent = @(); Debt = @() },
    # Point inside a for. for\pt\x is 4.
    [pscustomobject]@{ Name = 'unit_body_path_for_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Point inside an else that is inside a while. else\pt\x is 4.
    [pscustomobject]@{ Name = 'unit_body_path_else_while_pt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # An unwalked method still stores the else shell. else\pt\x is 4.
    [pscustomobject]@{ Name = 'unit_body_path_else_unwalked.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # return at the same column as fn is that fn's trailer and closes the nested ifs.
    [pscustomobject]@{ Name = 'unit_return_fn_level.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        Absent = @(); Debt = @() },
    # A while inside an else. --- is the only closer, and only for the two-level jump.
    [pscustomobject]@{ Name = 'unit_body_path_while_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_while_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # A for inside an else. --- is the only closer, and only for the two-level jump.
    [pscustomobject]@{ Name = 'unit_body_path_for_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_for_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @('l2_entry_leaf\native: (cast: (LmxEntry) l2_m1_tr)'); Debt = @() },
    # unit_body_path_deep: a body root under a deeper path -- while\pt\x as a value and as a call's argument, where P0
    # gives the atoms and l2_path_chain admits a body head as it admits `node`.  Native only (a Structure field in a
    # nested body keeps a method out of the walk).
    [pscustomobject]@{ Name = 'unit_body_path_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The negatives: the bare j after `end: for` is not j outside its body (Q51) -- refused where it stands; a path to a
    # field the body does not declare is refused -- nothing makes one (Q52).  Both modes.
    [pscustomobject]@{ Name = 'unit_body_path_bare_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_body_path_bare_refused.lm2:14:4: unbound dynamic input j'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_body_path_bare_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0; WalkMethods = $true;
        Needle = 'unit_walk_body_path_bare_refused.lm2:14:4: unbound dynamic input j'; Absent = @(); Debt = @() },
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
        Needle = 'unit_local_init_graph_place_refused.lm2:15:5: more arguments than '; Absent = @(); Debt = @() },
    # Its explicit-reference sibling (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): `@: Box b; b: mk` binds after the
    # admission of mk's result to Box; an Other of another shape is refused by the field w reads through b -- the
    # implicit throw `implements` stops R0.
    [pscustomobject]@{ Name = 'unit_local_init_graph_ref_admit_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    # The program that row was before the read was added, as the positive it is: the same candidate by the same
    # route, no field read through b, and b observed to be the candidate.
    [pscustomobject]@{ Name = 'unit_local_init_graph_ref_admit_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_init_graph_ref_admit_thin_walk.lm2'; Source = 'unit_local_init_graph_ref_admit_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_walk_path_chain_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4);
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
        GraphShapes = @([pscustomobject]@{ Op = 'FOR'; Width = 5; Count = 1 }); Absent = @(); Debt = @('c.LMX_WALK_OP_OWN_OF, 3U)', 'c.LMX_WALK_OP_SET_OF, 4U)') },
    [pscustomobject]@{ Name = 'unit_root_hosted_controls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        GraphShapes = @([pscustomobject]@{ Op = 'FOR'; Width = 5; Count = 4 }); Absent = @(); Debt = @('c.LMX_WALK_OP_WHILE, 3U)', 'c.LMX_WALK_OP_OWN_OF, 3U)', 'c.LMX_WALK_OP_SET_OF, 4U)') },
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
    [pscustomobject]@{ Name = 'unit_decl_literal_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralRoot 'x' 7); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # OPUS-Q54-CONTINUE-20260929-14 slice 1, corrected by the call rule (ticket 15; book §9 after 55c1abc): in a method,
    # f declared by `f()` is typed by the empty Structure its declaration gives, and a later `f()`, `f: ()` or bare `f`
    # is its nullary call -- the empty Structure's call runs nothing: no admission (pinned absent), nothing thrown, so
    # the method is walked under the knob (pinned) -- 7, also in an `if:` body.  A bare `f` made f a dynamic input before
    # and refused the declaration: the free-name scan registers f now.  A method's field of a named Structure type --
    # `S: fresh` -- is callable too; its call, S's body over it, is not built in a method yet: refused where it stands,
    # as its bare atom is (slice 1 had `fresh()` the assignment with admission: 74).
    [pscustomobject]@{ Name = 'unit_empty_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_admission', 'LMX_WALK_OP_ADMIT_AS'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_empty_call_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0, 2);
        Absent = @('l2_admission', 'LMX_WALK_OP_ADMIT_AS'); Debt = @() },
    [pscustomobject]@{ Name = 'unit_empty_call_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_admission', 'LMX_WALK_OP_ADMIT_AS'); Debt = @() },
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
    # argument is refused where it stands: a resolved argumentless Structure takes no argument
    # -- the common arity refusal (Q59), not an implementation status.
    [pscustomobject]@{ Name = 'unit_ns_call_arg_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_method_refused.lm2:8:5: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_lit_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_lit_refused.lm2:6:1: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_number_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_number_refused.lm2:5:1: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_name_refused.lm2:10:5: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_bound_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_bound_refused.lm2:9:5: more arguments than '; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_call_arg_bound_root_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_ns_call_arg_bound_root_refused.lm2:6:1: more arguments than '; Absent = @(); Debt = @() },
    # OPUS-Q54-CONTINUE-20260929-14 slice 2b-1: a method's own named Structure -- `S:` + number fields, S resolving to
    # nothing there -- declared by the general route (book §9: an absent target with an explicit Structure value).  At
    # run time only its Structure exists: built at its statement, a child of the method's own Structure (pinned), bound
    # at S's slot -- no unit child (Absent) -- and each execution builds a new one (94; one kept would give 99).  The
    # walk takes no method with one (pinned native).  A field that is no number and no char is refused where it stands
    # (char fields since 2c-5, statements since 2c-2, below).
    [pscustomobject]@{ Name = 'unit_local_ns_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0, 2);
        Absent = @(); Debt = @() },
    # (2c-4: S declared in a body is that body's child -- its parent is the Structure that holds its slot, book §2.)
    [pscustomobject]@{ Name = 'unit_local_ns_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_source_layout.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 5; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_local_definition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalLocalProjectionPost + $criticalLocalProjectionNative; Entry = 7; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(3);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_local_definition_walk.lm2'; Source = 'graph_shape_t7_local_definition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalLocalProjectionPost + $criticalLocalProjectionWalk; Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(3);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_local_callable_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_local_callable_field_walk.lm2'; Source = 'graph_shape_t7_local_callable_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,4);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_nullary_source_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_nullary_source_field_walk.lm2'; Source = 'unit_held_nullary_source_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    # A held callable called with the arguments of its header at any count: none, two ints, a size_t, an
    # int and a size_t. Each argument is evaluated once in the order written (the trace of mark) and
    # reaches the formal of its position. At the root (walked) and in a method, natively and walked.
    # The path facts hold each call's width, its target and its arguments in their places.
    [pscustomobject]@{ Name = 'unit_held_call_arity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $heldArityShape; Entry = 7; WalkRoot = $true; NativeMethods = @(0,1,8);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_arity_walk.lm2'; Source = 'unit_held_call_arity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $heldArityShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,8);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_arity_order_mutant.lm2'; Source = 'unit_held_call_arity.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','2','18','2','4','5') + $heldArityShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_arity_argument_mutant.lm2'; Source = 'unit_held_call_arity.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','23','2','5') + $heldArityShape; Entry = 7; Absent = @(); Debt = @() },
    # The count of a held call's actuals is refused where the call's actuals are bound to the header's
    # formals, in the words a method's call gets: a formal left without an actual at the call, an
    # actual past the last formal at that actual.  The rule and the place of the first are what these
    # rows held before; the words were the check's, "a held callable takes the arguments of its header".
    [pscustomobject]@{ Name = 'unit_held_call_count_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_count_refused.lm2:9:8: h2 has no argument y'; Absent = @(); Debt = @() },
    # FIXED-BLOCKS-AUDIT: the binding's words name a callee of 300 bytes in full; its name was copied into 160 bytes.
    [pscustomobject]@{ Name = 'unit_held_call_long_name_count_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ('unit_held_call_long_name_count_refused.lm2:11:8: held' + ('h' * 296) + ' has no argument y'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_more_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_more_refused.lm2:9:15: more arguments than h2 has formals'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_fresh.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 99;
        Absent = @(); Debt = @() },
    # Slice 2c-1: the method executes its own named Structure -- `S()`, `S: ()`, the bare `S` -- S's procedure (§12), a
    # method after the entry E with no unit child, its occurrence S itself: built at S's statement with the
    # procedure's trampoline as its native word, run by lmx_call_prim(S, S) (both pinned), so `node` in S's body is the
    # method's occurrence.  Each call stores S's initializer again: 4 after each, though 9 was written (was
    # unit_local_ns_call_refused).  Declared in an `if:` body and executed there and from a block: the procedure's
    # fields are S's, not the body's.  Under the knob the method stays native (pinned) and the procedure is never
    # walked.
    [pscustomobject]@{ Name = 'unit_local_ns_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0, 2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_call_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Slice 2c-2: S's statements run at its calls, in its procedure, never at its declaration (book :928) -- w 0 after
    # it, then 14 and, after `k: 20`, 24: k is a hidden input the method passes (§12).  Under the knob the method stays
    # native and the procedure unwalked (pinned).  S's statements are checked whether or not S runs (a free name nobody
    # binds, refused where it stands).  Control bodies: 2c-3; `node`: 2c-4, below.
    [pscustomobject]@{ Name = 'unit_local_ns_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_stmt.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(2);
        Absent = @(); Debt = @() },
    # OPEN, required before G5, red until built (DORMANT-BODY-FREE-INPUT; Codex, OPUS-CODEX-20261005-01: this row's
    # refusal was implementation evidence, no rule).  S is never executed and its free name nosuch is missing
    # nowhere; m returns 7.  Refused at 01ecd69b at nosuch, "7:12: unresolved name" (l2_dyn_typed: S's callable
    # row has the input nosuch, which no caller types).
    [pscustomobject]@{ Name = 'unit_local_ns_stmt_unresolved.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Slice 2c-3: S's control bodies are Structures of its occurrence, built with S at its statement (R9) -- the `if:`
    # body with a cell for its field t: w 0 after the declaration, 10 after `S()` (was unit_local_ns_ctl_refused);
    # under the knob the method stays native (pinned); S declared in the method's `while:` gets new bodies each pass:
    # 15. A char field -- S's own or declared in its control body -- has its own stable typed cell:
    # 'z' written, 'a' after `S()`; the body's d
    # 'z' steers its `if:`: 5 (was unit_local_ns_ctl_char_refused).
    [pscustomobject]@{ Name = 'unit_local_ns_ctl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_local_ns_ctl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0, 2);
        Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_walk_local_ns_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true; WalkedMethods = @(0, 2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_ns_node_nested.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_local_ns_kind_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
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
    # The root above the declarations has no binding to hand: it hands the inputs absent and f's own entry reads
    # the unit's cells through its occurrence's parent (K04; Codex, FABLE-CODEX-20261004-12).  The pins: no read
    # of those cells in the caller, by either route, and the read in the entry.
    [pscustomobject]@{ Name = 'unit_decl_order_u2.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('l2_xp: lmx_arena_ref_cell(self, ', 'l2_xp: lmx_arena_ref_cell(l2_c'); Debt = @('lmx_arena_ref_cell(l2_self\parent, ') },
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
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'OWN'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 5 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 2 }) } }) });
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'merge');
        Debt = @() },
    # One unknown-head definition in three equivalent forms, not three calls.
    [pscustomobject]@{ Name = 'unit_universal_absent_paren.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralRoot 'ping' 7); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_colon.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralRoot 'ping' 7); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_universal_absent_vertical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralRoot 'ping' 7); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # K03c (next_core_tasks_v2.md K03; Q57, Q58).  A nested head inside a definition that resolves to nothing, with a
    # Structure tail, defines a NESTED named Structure -- a kind-2 field built in place under its parent, as the
    # `(): name` spelling declares one: `C: makeA()` with both unknown (the pins: makeA under C, E under D), the block
    # form with fields (D\E\x reads 5).  Was "internal: an own declaration has no physical field".
    [pscustomobject]@{ Name = 'unit_q57_nested_unknown.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('l2_nsp[1]: lmx_struct_new_owned(l2_nsp[0], l2_program_arena)', 'l2_nsp[3]: lmx_struct_new_owned(l2_nsp[2], l2_program_arena)') },
    # A KNOWN head inside a definition is a call, checked against the resolved value's contract (Q59, K03a): an
    # ordinary named Structure has no arguments -- the arity refusal, where it stands.
    [pscustomobject]@{ Name = 'unit_q57_nested_known_arity_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_q57_nested_known_arity_refused.lm2:7:4: more arguments than Known has formals'; Absent = @(); Debt = @() },
    # Absent b: A is not a reference binding yet: b\value is an unknown field.
    # @: b A is read as type b and refused as an unknown type.
    [pscustomobject]@{ Name = 'unit_ref_absent_colon.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ref_absent_at.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown type'; Absent = @(); Debt = @() },
    # In a method, Holder: 1 is the same arity refusal, not an assignment into Holder.
    [pscustomobject]@{ Name = 'unit_struct_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'more arguments than Holder has formals'; Absent = @(); Debt = @() },
    # Q58: `Batch: (put: 7)` with put a method -- Batch holds the one Structure (put: 7); the known call is retained as
    # a statement of its body, not executed at the definition (hits 0), executed when Batch is (hits 1).  Native, and
    # walked (put and Batch's procedure under --walk-methods).
    [pscustomobject]@{ Name = 'unit_q58_batch_retained.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_q58_batch_retained.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_nested_body_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['else'];
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_else_walk.lm2'; Source = 'unit_nested_body_else.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['else']; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_body_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['while'];
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,');
        Debt = @('while: l2_t0',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_while_walk.lm2'; Source = 'unit_nested_body_while.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['while']; Absent = @(); Debt = @() },
    # §7b (7b-1): `hosted` is the for body's field with a working value -- `int: hosted 4` writes l2_q1 and
    # marks it, and the exit publishes it into the host's cell 1; c3b-1's in-place store is Absent.
    [pscustomobject]@{ Name = 'unit_nested_body_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['for'];
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'lmx_branch_struct_known(unit,', 'lmx_int_store_known(l2_q1_from[0], (4))');
        Debt = @('l2_q1: (4)',
                 'if: lmx_int_store_known(l2_q1_from[0], (l2_q1)) != 0',
                 '# const: @(char l2_own1) "hosted"',
                 'l2_entry_unit: graph', 'return: lmx_root_launch(@ l2_program_root, argc, argv, l2_program_build, ') },
    [pscustomobject]@{ Name = 'unit_nested_body_for_walk.lm2'; Source = 'unit_nested_body_for.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); GraphShapes = $criticalNestedBodyShapes['for']; Absent = @(); Debt = @() },
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
    # FIXED-BLOCKS-AUDIT: callable formals written in place, as many as the method has formals -- ten, past the
    # eight places the collector had (it refused "too many callable formals written in place").  Natively: a
    # callable formal is outside the walkable subset, as for unit_callable_anon.
    [pscustomobject]@{ Name = 'unit_callable_formals_many_in_place.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
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
    # Triage 2026-10-03: the root is compiled like every body; the rule "L2 operation outside a
    # method body" is withdrawn. The line is printed and the exit is idle()'s 0.
    [pscustomobject]@{ Name = 'unit_puts_main_beside_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 0; Says = @('beside-method');
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
    # The author's decision of 2026-10-05 (HEAD-ROLE-UNESTABLISHED-ROWS): `hidden: hidden + 1`, with nothing
    # establishing hidden in bump_hidden, defines a named Structure, and returning it as an int is a type error.
    # (Was eternal-runs, bump_hidden() = 5 with outer's hidden kept: the reading the author rejected.)
    [pscustomobject]@{ Name = 'unit_colon_hidden_update.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_hidden_update.lm2:12:13: return value has incompatible type'; Absent = @(); Debt = @() },
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
        Needle = 'unit_duplicate_named_struct_refused.lm2:9:1: more arguments than '; Absent = @(); Debt = @() },
    # Observe the lexical model's copied value and the model's unchanged cell;
    # temporary numbers and CALL frame widths are not the construction contract.
    [pscustomobject]@{ Name = 'unit_colon_method_lexical_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
    [pscustomobject]@{ Name = 'unit_colon_method_dynamic_precedence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        # forward remains unexecuted legacy compatibility, not a dispatch oracle.
        NativeCalls = @([pscustomobject]@{Caller=1; Method=0; Throwing=$true; ResultType='int:'; ResultUse='(?m)^\s*l2_out_result\[0\]: {result}\s*$'; Propagation='forward'; Args=@()});
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_mops[0U]: lmx_arena_ref_struct(node, 0U)',
                 'lmx_merge_profiles_owned(l2_mops, 1U, l2_mbody, self, l2_program_arena, l2_program_arena, l2_mprofiles, l2_mprofile_n0, 0, 0U, @ l2_mresult)',
                 'l2_entry_unit: graph') },
    # Both calls must verify their 1 -> 2 copy, with Model still 1.
    [pscustomobject]@{ Name = 'unit_colon_method_fresh_per_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_entry_unit: graph') },
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
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: lmx_arena_ref_struct(node, ', 'lmx_merge_profiles_owned(l2_mops, 1U, l2_mbody, self, ') },
    [pscustomobject]@{ Name = 'unit_field_path_nested_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT');
        Debt = @('l2_pst: lmx_arena_ref_struct(l2_pst,', 'l2_pxp: lmx_arena_ref_cell(l2_pst,', 'l2_mops[0U]: lmx_arena_ref_struct(node, ', 'lmx_merge_profiles_owned(l2_mops, 1U, l2_mbody, self, ') },
    [pscustomobject]@{ Name = 'unit_field_path_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    # The walked root's typed reference (OPUS-CALLABLE-STRUCT-BINDING-20260929-16, step 1): `@: Model p` / `p: @fresh` at
    # the unit level runs -- p an own field of the unit, a pointer cell, bound after admission; it was refused as an L2
    # operation. p is nonnull and exactly @fresh: 7, in native and actual root-walk execution.
    [pscustomobject]@{ Name = 'unit_field_path_unit_addr.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeRoot = 2; WalkRoot = $true;
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
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    # It was `unit_ref_rebind_other_refused`: a refusal by Model's whole shape of a reference the method never reads.
    # That expectation was wrong (the receiving-use contract): the Other is received, and r is o.
    [pscustomobject]@{ Name = 'unit_ref_rebind_other_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_ref_rebind_other_thin_walk.lm2'; Source = 'unit_ref_rebind_other_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # A reference formal `@: Model v` is rebound the same way (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): a Model is
    # admitted, no shortcut (pinned), read through v: 7; an Other is refused, the implicit throw stops R0.  It was a plain
    # store.  A value formal `Model: v` is callable: `v: w` its call, refused where it stands -- told apart by the
    # declaration; the row also holds the const test's bound (it read heap garbage for this formal's code).
    [pscustomobject]@{ Name = 'unit_ref_formal_rebind_same.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
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
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
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
    # Both signature spellings of a nonprimitive formal, `(Model: v)` and `(@: Model v)`, are ONE reference transport
    # (the book, "A signature is not executed"; next_core_tasks_v2.md K03; generated-diagnostic-migration-20260930.md
    # D4): in the body v is a reference binding, and `v: w` is its rebinding after w's admission to Model -- the same
    # operation for both spellings, the caller's Structure untouched.  Success is 7.  Formerly
    # unit_value_formal_call_refused, which asserted that `(Model: v)` made v a callable value and `v: w` its refused
    # call: the obsolete distinction between the spellings, withdrawn with the K03b slice.
    [pscustomobject]@{ Name = 'unit_formal_spelling_rebind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # Its negative: the `(Model: v)` spelling rebound to an Other of another shape -- the admission refuses it, and the
    # method's implicit throw `implements`, uncaught, stops R0 (the `@: Model v` sibling: unit_ref_formal_rebind_other_refused).
    [pscustomobject]@{ Name = 'unit_formal_spelling_rebind_other_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_path_unit_colon.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.LMX_WALK_OP_DEREF');
        Debt = @('\fn: lmx_walk_merge_map', 'l2_entry_unit: graph') },
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
        Needle = 'more arguments than '; Absent = @(); Debt = @() },
    # Its explicit-reference sibling (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): `@: Model b; b: other(a)` binds after the
    # admission of the call's result to Model.  It was `unit_struct_return_ref_admit_refused`, a refusal by Model's whole
    # shape of a reference the method never reads; that expectation was wrong (the receiving-use contract).  The Other
    # is received, and a reference to Other received from b reads what the callee wrote into its result.
    [pscustomobject]@{ Name = 'unit_struct_return_ref_admit_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_struct_return_ref_admit_thin_walk.lm2'; Source = 'unit_struct_return_ref_admit_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
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
    # Actual byte-span and mutable-char* result witness. LinkSources names the
    # declared support bodies explicitly; the generic link step builds them with
    # the same pinned translator and staged headers. The unchanged program must
    # copy the full expression span, grow to element 7, and exit 10.
    # Its foreign operations require native execution; this is not walker parity.
    [pscustomobject]@{ Name = 'unit_lm_own_actual_span.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        LinkSources = @('l1src/own.lm1'); Args = @('0'); Entry = 10;
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
    [pscustomobject]@{ Name = 'unit_decl_unknown_type_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 7; Absent = @(); Debt = @() },
    # Triage 2026-10-03: a positive again (the withdrawn root rule had pinned a refusal).
    [pscustomobject]@{ Name = 'unit_addr_slot_structure_projection.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 0;
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
    # Null reference cells are not dereferenced: dormant readers must still
    # resolve their exact LAST/[0] pointee model, with no FIRST-match fallback.
    [pscustomobject]@{ Name = 'unit_ns_reference_occurrence_contract.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeRoot = 5; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_reference_last_other_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_reference_first_other_field_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unknown field path segment'; Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_ref_local_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0','namepath','1','0','Model','namepath','2','1','2','mo',
            'differentpath','1','0','2','1','2','parentpath','2','1','2','1','1',
            'sizepath','2','0','0','1','sizepath','3','1','2','0','1',
            'rolepath','3','1','2','1','8','1','rolepath','2','1','6','8','0',
            'postpaths','sizepath','2','0','0','1','sizepath','3','1','2','0','11','endpostpaths');
        Absent = @('lmx_struct_new_owned(self, l2_program_arena)'); Debt = @();
        NativePatterns = @('(?s)@: Lmx (?<ref>l2_q\d+)\s+\k<ref>: \(cast: \(@: Lmx\) lmx_pointer_value_known\(\k<ref>_from\[0\]\)\).*?(?<model>(?!\k<ref>\b)l2_q\d+): \(cast: \(@: Lmx\) (?<cell>l2_q\d+_from)\[0\]\).*?@: Lmx (?<candidate>l2_t\d+) \k<model>\s+.*?int: (?<admission>l2_admission\d+) c.LMX_IMPLEMENTS_YES.*?(?<pending>l2_pending\d+)\.value: \(cast: \(@: Lmx\) \k<candidate>\)\s+\k<pending>\.req: (?<required>lmx_arena_ref_struct\(node, \d+U\)).*?\k<admission>: lmx_implements_receiving_use\(l2_program_arena, \(cast: \(@: Lmx\) \k<candidate>\), \k<required>, \k<required>, @ \k<pending>, @ l2_rusev\d+\).*?\k<admission>: lmx_implements_register_map\(l2_program_arena, \(cast: \(@: Lmx\) \k<candidate>\), \k<required>,.*?if: \k<admission> != c.LMX_IMPLEMENTS_YES.*?return: 2\s+\k<ref>: \(cast: \(@: Lmx\) \(\k<candidate>\)\).*?l2_pst: \k<model>.*?lmx_size_store_known\(l2_pxp\[0\], 9U\).*?l2_pst: \k<ref>.*?lmx_size_value_known\(l2_pxp\[0\]\).*?l2_pst: \k<ref>.*?lmx_size_store_known\(l2_pxp\[0\], 11U\).*?l2_pst: \k<model>.*?lmx_size_value_known\(l2_pxp\[0\]\)') },
    [pscustomobject]@{ Name = 'unit_ref_formal_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @('@@: Lmx l2_p'); Debt = @('@: Lmx l2_p0_0') },
    [pscustomobject]@{ Name = 'unit_ref_field_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @(); Debt = @('l2_pst: (cast: (@: Lmx) lmx_pointer_value_known(l2_pxp[0]))') },
    # REF-FIELD-VALUE-READ: a reference field read as a value into a reference local -- one hop, two hops, a chain
    # walked to its end, a field written from a field, the root's read.  The statement's path branch read number
    # leaves only and stored stale text for a reference leaf: the previous translator's L1 does not parse.
    [pscustomobject]@{ Name = 'unit_ref_field_value_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0');
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ref_field_value_read_walk.lm2'; Source = 'unit_ref_field_value_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7; Args = @('0'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # Triage 2026-10-03: a positive again, with an explicit copy for its setup: each of the five
    # user locals keeps its value next to the entry adapter's own names.
    [pscustomobject]@{ Name = 'unit_addr_entry_name_collision.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Entry = 0; Says = @('1 2 3 4 5');
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
        Needle = 'unit_dyn_hidden_from_cross_method.lm2:21:1: unbound dynamic input shared'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_dyn_hidden_from_undeclared_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_dyn_hidden_from_undeclared_refused.lm2:17:1: unbound dynamic input shared'; Absent = @(); Debt = @() },
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
        Needle = 'unit_sizeof_unknown_refused.lm2:8:1: unbound dynamic input unknownName'; Absent = @(); Debt = @() },
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
    # This null-input witness returns before any raw buffer access/realloc. It
    # proves native dispatch from the same root after clearing its native word,
    # not allocation success or interpreted execution of raw pointer operations.
    [pscustomobject]@{ Name = 'unit_ptr_grow.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_cast_bindings.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalCastShape; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_cast_erase_arg_mutant.lm2'; Source = 'graph_shape_machine_cast_bindings.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','null-path','7','1','6','2','1','1','1','1') + $criticalCastShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_cast_erase_type_mutant.lm2'; Source = 'graph_shape_machine_cast_bindings.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','null-path','8','1','6','2','1','1','1','0','0') + $criticalCastShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_cast_walk_erase_arg_mutant.lm2'; Source = 'graph_shape_machine_cast_bindings.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','7','1','6','2','1','1','1','1') + $criticalCastShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_machine_cast_walk_erase_type_mutant.lm2'; Source = 'graph_shape_machine_cast_bindings.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','8','1','6','2','1','1','1','0','0') + $criticalCastShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsNestedDormantShape; WalkRoot = $true;
        NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_dormant_walk_methods.lm2'; Source = 'graph_shape_ns_source_nested_dormant.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsNestedDormantShape; WalkRoot = $true;
        NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_erase_init_mutant.lm2'; Source = 'graph_shape_ns_source_nested_dormant.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','null-path','3','0','2','1') + $criticalNsNestedDormantShape;
        NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_walk_erase_init_mutant.lm2'; Source = 'graph_shape_ns_source_nested_dormant.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','3','0','2','1') + $criticalNsNestedDormantShape;
        NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_called.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsNestedCalledShape; WalkRoot = $true;
        NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_called_walk_methods.lm2'; Source = 'graph_shape_ns_source_nested_called.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsNestedCalledShape; WalkRoot = $true;
        NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','widthpath','2','2','4','1','parentpath','2','2','4','1','2',
            'rolepath','3','2','4','0','7','0','rolepath','4','2','4','0','1','15','0',
            'rolepath','5','2','4','0','1','1','36','0'); WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_node_walk_methods.lm2'; Source = 'graph_shape_ns_source_nested_node.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','widthpath','2','2','4','1','parentpath','2','2','4','1','2',
            'rolepath','3','2','4','0','7','0','rolepath','4','2','4','0','1','15','0',
            'rolepath','5','2','4','0','1','1','36','0'); WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_bare_array.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_bare_array_walk_methods.lm2'; Source = 'graph_shape_ns_source_bare_array.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','6','widthpath','2','0','4','1','parentpath','2','0','4','1','0');
        WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_copy_walk_methods.lm2'; Source = 'graph_shape_ns_source_nested_copy.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','6','widthpath','2','0','4','1','parentpath','2','0','4','1','0');
        WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_siblings.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','4','widthpath','2','0','2','4','widthpath','3','0','2','2','1',
            'widthpath','1','1','4','widthpath','2','1','2','4','widthpath','3','1','2','2','1',
            'parentpath','3','0','2','2','2','0','2','parentpath','3','1','2','2','2','1','2');
        WalkRoot = $true; NativeRoot = 6; NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_nested_siblings_walk_methods.lm2'; Source = 'graph_shape_ns_source_nested_siblings.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','4','widthpath','2','0','2','4','widthpath','3','0','2','2','1',
            'widthpath','1','1','4','widthpath','2','1','2','4','widthpath','3','1','2','2','1',
            'parentpath','3','0','2','2','2','0','2','parentpath','3','1','2','2','2','1','2');
        WalkRoot = $true; NativeRoot = 6; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_trailer.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsTrailerShape; WalkRoot = $true;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_trailer_walk_methods.lm2'; Source = 'graph_shape_ns_source_trailer.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsTrailerShape; WalkRoot = $true;
        NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_trailer_erase_mutant.lm2'; Source = 'graph_shape_ns_source_trailer.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','null-path','2','0','3') + $criticalNsTrailerShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_trailer_walk_erase_mutant.lm2'; Source = 'graph_shape_ns_source_trailer.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','walkroot','1','mutate','null-path','2','0','3') + $criticalNsTrailerShape;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_ns_source_trailer_value_refused.lm2';
        Expect = 'l2trans-refuses'; Exit = 0; Needle = 'return with a value in a callable that returns nothing'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsMixedShape; WalkRoot = $true;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_order_walk_methods.lm2'; Source = 'graph_shape_ns_source_order.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsMixedShape; WalkRoot = $true;
        NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_repeated.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsRepeatedShape; WalkRoot = $true;
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_repeated_walk_methods.lm2'; Source = 'graph_shape_ns_source_repeated.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsRepeatedShape; WalkRoot = $true;
        NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0') + $criticalNsDormantShape;
        NativeRoot = 3; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_old_prefix_mutant.lm2'; Source = 'graph_shape_ns_source_dormant.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','move-path-field','1','0','3','1') + $criticalNsDormantShape;
        NativeRoot = 3; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_pointer_depth3.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','4','namepath','2','0','0','deep',
            'namepath','2','0','2','marker','shape','exact','owned','struct','fields','ptr','owned','implicit','SET',
            'fields','role','8','2') + (& $criticalLiteralOwn 0) +
            @('owned','LIT','fields','role','3','0','ptr','endfields','endfields','intvalue','7') +
            (& $criticalNsInit 2 7) + @('endfields') + $criticalLiteralPublish7 + $criticalLiteralRootReturn + @('endshape');
        NativeRoot = 1; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_array_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','namepath','2','2','0','first','namepath','2','2','2','values',
            'namepath','2','2','3','step','namepath','2','2','4','last','rolepath','2','2','1','8','1',
            'rolepath','2','2','5','8','1','cellpath','2','2','0','1','2','cellpath','2','2','4','1','2',
            'samepath','2','2','3','1','3','parentpath','2','2','3','0','parentpath','1','2','0');
        NativeRoot = 3; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_array_read_walk_methods.lm2'; Source = 'graph_shape_ns_source_array_read.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','namepath','2','2','0','first','namepath','2','2','2','values',
            'namepath','2','2','3','step','namepath','2','2','4','last','rolepath','2','2','1','8','1',
            'rolepath','2','2','5','8','1','cellpath','2','2','0','1','2','cellpath','2','2','4','1','2',
            'samepath','2','2','3','1','3','parentpath','2','2','3','0','parentpath','1','2','0');
        NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_constructors.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','namepath','2','2','0','first','namepath','2','2','2','values',
            'namepath','2','2','3','step','namepath','2','2','4','last','rolepath','2','2','1','8','1',
            'rolepath','2','2','5','8','1','cellpath','2','2','0','1','2','cellpath','2','2','4','1','2',
            'samepath','2','2','3','1','3','parentpath','2','2','3','0','parentpath','1','2','0');
        NativeRoot = 3; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_ns_source_constructors_walk_methods.lm2'; Source = 'graph_shape_ns_source_constructors.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','2','6','namepath','2','2','0','first','namepath','2','2','2','values',
            'namepath','2','2','3','step','namepath','2','2','4','last','rolepath','2','2','1','8','1',
            'rolepath','2','2','5','8','1','cellpath','2','2','0','1','2','cellpath','2','2','4','1','2',
            'samepath','2','2','3','1','3','parentpath','2','2','3','0','parentpath','1','2','0');
        NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_array_place_selectors.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','8','namepath','2','0','2','values','namepath','2','0','5','values','widthpath','3','1','3','2','3');
        NativeRoot = 2; NativeMethods = @(0); GraphShapes = $criticalArrayPlaceShapes; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_array_place_selectors_walk.lm2'; Source = 'graph_shape_array_place_selectors.lm2';
        Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0','widthpath','1','0','8','namepath','2','0','2','values','namepath','2','0','5','values','widthpath','3','1','3','2','3');
        NativeRoot = 2; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); GraphShapes = $criticalArrayPlaceShapes; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_array_place_erase_index_mutant.lm2'; Source = 'graph_shape_array_place_selectors.lm2';
        Expect = 'shape-mutant'; Exit = 1; Entry = 7; Needle = '';
        Args = @('0','mutate','null-path','3','1','3','2','widthpath','1','0','8','widthpath','3','1','3','2','3');
        NativeRoot = 2; NativeMethods = @(0); GraphShapes = $criticalArrayPlaceShapes; Absent = @(); Debt = @() },
    # FABLE-OPUS-P0-SIZEOF-ATOM-20260924-157 commit 2: P0 keeps no raw `c.sizeof(...)` atom, so an L2
    # operand of the door is lowered like any door operand -- an own int x becomes a temp -- where
    # the raw atom passed the name `x` to C ("x undeclared").  Success is 7.
    [pscustomobject]@{ Name = 'unit_csizeof_operand_lowered.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT', 'c.sizeof(x)');
        Debt = @('return: c.sizeof(l2_t') },
    [pscustomobject]@{ Name = 'unit_sizeof_own_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @('lmx_perm', 'LMX_ROOT_ETERNAL_SLOT'); Debt = @('l2_entry_unit: graph') },
    # The former refusal "L2 operation outside a method body" is a withdrawn
    # rule (semantics section 1): the root is compiled like every body.
    [pscustomobject]@{ Name = 'unit_native_activation.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Entry = 7;
        Args = @('0'); Absent = @(); Debt = @() },
    # Q55: only translation, not an executable test of C undefined behavior.
    [pscustomobject]@{ Name = 'unit_array_write_root_out_of_range.lm2'; Expect = 'translates'; Exit = 0;
        Needle = ''; Absent = @(); Debt = @();
        NativePatterns = @('(?m)size_t: (?<place>l2_ai\d+)_index 5\r?\n\s+\k<place>_data\[\k<place>_index\]: 1');
        GraphShapes = @([pscustomobject]@{ Op = 'ELEMPUT'; Width = 4; Count = 1; StoredAt = [pscustomobject]@{ Method = 0; Path = @(3) }; Edges = @(
            [pscustomobject]@{ Slot = 1; Shape = [pscustomobject]@{ Op = 'AT'; Width = 3; Sizes = @([pscustomobject]@{ Slot = 2; Value = 2 }) } },
            [pscustomobject]@{ Slot = 2; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Sizes = @([pscustomobject]@{ Slot = 1; Value = 5 }) } },
            [pscustomobject]@{ Slot = 3; Shape = [pscustomobject]@{ Op = 'LIT'; Width = 2; Ints = @([pscustomobject]@{ Slot = 1; Value = 1 }) } }
        ) }) },
    [pscustomobject]@{ Name = 'unit_array_write_general_root_no_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported index'; Absent = @(); Debt = @() },
    # A positive store into an Array field of an explicit copy, with the model's Array and an
    # unrelated own Array as controls.
    [pscustomobject]@{ Name = 'unit_array_write_general_root_real_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # A slot of a merge result has the element contract of the declaration that contributed
    # it: the model's int Array and a later operand's char Array, a copy of a copy, a
    # variable index, the address of an element. Natively and with the three methods walked.
    [pscustomobject]@{ Name = 'unit_arr_path_merge_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeMethods = @(0,1,2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_arr_path_merge_result_walk.lm2'; Source = 'unit_arr_path_merge_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2);
        Absent = @(); Debt = @() },
    # A reference field of a merge result leads into its pointee: read and written through, in
    # a method and at the root through a copy of a copy. Natively and with the method and the
    # root walked.
    [pscustomobject]@{ Name = 'unit_mres_ref_field_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_mres_ref_field_path_walk.lm2'; Source = 'unit_mres_ref_field_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # A store into that reference field admits the value to the field's model: another shape
    # is refused by the method's implicit throw `implements`. Natively and walked.
    [pscustomobject]@{ Name = 'unit_mres_ref_field_store_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_mres_ref_field_store_refused_walk.lm2'; Source = 'unit_mres_ref_field_store_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_undeclared_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralMethod 'broken' 'arg' 7); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    # missing_value is a free name no caller binds: "unresolved name" at the name (l2_dyn_typed), before the
    # assignment's check, which waits for the name's type (steps/free-names.md M2).
    [pscustomobject]@{ Name = 'unit_colon_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_unknown_value_refused.lm2:6:1: unbound dynamic input missing_value'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_colon_incompatible_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'assignment value has incompatible type'; Absent = @(); Debt = @() },
    # Historical filename: const protects the referent, while its explicit pointer cell may rebind.
    [pscustomobject]@{ Name = 'unit_colon_graph_const_target_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    # The same for a graph target: missing_graph is unresolved, said at the name (steps/free-names.md M2).
    [pscustomobject]@{ Name = 'unit_colon_graph_unknown_value_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_colon_graph_unknown_value_refused.lm2:2:12: unresolved name'; Absent = @(); Debt = @() },
    # Historical filename: named-model admission succeeds before binding; a refusal preserves the old binding.
    [pscustomobject]@{ Name = 'unit_colon_graph_update_admission_blocked.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    [pscustomobject]@{ Name = 'unit_colon_graph_update_admission_walk.lm2'; Source = 'unit_colon_graph_update_admission_blocked.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); WalkRoot = $true; NativeRoot = 7; WalkMethods = $true; WalkedMethods = @(2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_reference_source_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); WalkRoot = $true; NativeRoot = 9; NativeMethods = @(0,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_reference_source_chain_walk.lm2'; Source = 'unit_opaque_reference_source_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); WalkRoot = $true; NativeRoot = 9; WalkMethods = $true; WalkedMethods = @(0,3,5); NativeMethods = @(4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_reference_ordinal_flow.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); WalkRoot = $true; NativeRoot = 5; NativeMethods = @(1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_reference_ordinal_flow_walk.lm2'; Source = 'unit_opaque_reference_ordinal_flow.lm2'; Expect = 'eternal-runs'; Exit = 0; Entry = 7;
        Needle = ''; Args = @('0'); WalkRoot = $true; NativeRoot = 5; WalkMethods = $true; WalkedMethods = @(1,2); Absent = @(); Debt = @() },
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
    # The used-path list is growable (K01e): the sixty-fourth and the sixty-fifth path both run,
    # and the count is no longer a limit. What the check is for is shown by the mismatch fixture:
    # the same 65 used paths against a candidate that differs in ONE of them are refused.
    [pscustomobject]@{ Name = 'unit_s7_uses64.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_uses65.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_uses65_mismatch_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
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
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    # The leaf is a nested written Structure; the callee's write through the admitted argument
    # is observed in Holder's own leaf. The same with the three methods and the root walked.
    [pscustomobject]@{ Name = 'unit_s7_arg_deep_walk.lm2'; Source = 'unit_s7_arg_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_arg_deep_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_deep_walk.lm2'; Source = 'unit_s7_ret_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_path.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'implements is false in return value'; Absent = @(); Debt = @() },
    # The same with a nested written leaf: it is admitted like any Structure, not accepted
    # because it is one. Mutant: l2_admit_return returns 0 before the descriptor call.
    [pscustomobject]@{ Name = 'unit_s7_ret_nested_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_ret_nested_refused.lm2:15:1: implements is false in return value'; Absent = @(); Debt = @() },
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
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_ret_field_walk.lm2'; Source = 'unit_s7_ret_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
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
        Needle = 'unit_s7_part_free_refused.lm2:8:6: unbound dynamic input k'; Absent = @(); Debt = @() },
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
        Needle = 'unit_s7_part_root_hidden.lm2:8:4: unbound dynamic input k'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_s7_part_root_src_refused.lm2'; Parts = @('unit_s7_part_root_src_refused_part.lm2'); Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_s7_part_root_src_refused_part.lm2:4:4: unresolved name'; Absent = @(); Debt = @() },
    # Triage 2026-10-03: bump has no established k (the field is declared below it), so its `k: 7`
    # is an unknown head and defines a Structure; the part's field keeps 5 (as unit_free_write).
    [pscustomobject]@{ Name = 'unit_s7_part_root_below_definition.lm2'; Parts = @('unit_s7_part_root_below_definition_part.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
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
        Needle = 'unit_s7_part_ns_hidden.lm2:9:6: unbound dynamic input Counter'; Absent = @(); Debt = @() },
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
    # Recursive working copies yield 123 and leave Box's v at 0. Pointer cells
    # elsewhere in operation frames say nothing about this source output slot.
    [pscustomobject]@{ Name = 'unit_recursive_model_slot.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @('lmx_fresh(', 'l2_new0'); Debt = @() },
    # FABLE-GROKBOT-MATRIX-20260924-143 -- B2 semantic matrix (fixtures only).
    # Grid: {absent, existing non-callable, existing callable, path} x
    # {primitive, Structure ref, Array/ref, callable} over one head-consumes-tail
    # op; three spellings where positive; physical op / identity / diagnostics.
    [pscustomobject]@{ Name = 'unit_matrix_absent_struct_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_prim_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralMethod 'probe' 'x' 5); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_absent_arrayish_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = (& $criticalLiteralMethod 'probe' 'buf' 3); Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_prim_asgn.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_matrix_noncall_empty_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unsupported body'; Absent = @(); Debt = @() },
    # The matrix cell restated by the call rule (OPUS-CALLABLE-STRUCT-BINDING-20260929-16): the non-callable binding is
    # an explicit reference, and its rebinding runs the admission and binds a Model -- was _refused, fail-closed.
    [pscustomobject]@{ Name = 'unit_matrix_noncall_struct_rebind.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @('lmx_implements_receiver_view(') },
    # Q52 (7b, by name): as unit_callable_priority -- the three spellings are observed in foo's lines.
    [pscustomobject]@{ Name = 'unit_matrix_callable_prim.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0'); Says = @('foo 1 5', 'foo 1 6', 'foo 1 7'); Absent = @(); Debt = @() },
    # -179 commit 2: a Structure argument of the formal's own type goes BY REFERENCE -- the CALL's
    # input is m's working value, OWN (§7b), the Structure m holds -- so bump's three writes through x are m's own:
    # 4U after them.  Passed as a fresh merge copy instead, the writes are lost and the row exits 90.
    # Each of the three calls admits the very output operand m's declaration produced: the
    # callee writes the Structure the caller holds, not a copy (exit 90 otherwise).
    [pscustomobject]@{ Name = 'unit_matrix_callable_struct_identity.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0','samepath','3','3','2','3','2','2','1','samepath','3','4','2','3','2','2','1','samepath','3','5','2','3','2','2','1'); Absent = @('c.LMX_WALK_OP_DEREF'); Debt = @() },
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
    # them (l2_bind_calls); a call with a named argument gets a projection in its formals' order beside its
    # body, which stays as written -- a named argument's body its formal's positional actual, kept whole when
    # by position it would not be one actual -- and a reader takes the actuals through l2_call_actuals.  Witnesses:
    # named, reordered, positional then named, an expression body, a call bound inside an argument, from a
    # method and walked; the binding's five refusals in the book's words; a callable formal called by its
    # contract's formal name (native: a callable formal is outside the walkable subset); a path call; a frame
    # among the actuals that names a formal of the callee is that formal's argument (P0 gives g(2) and g: 2 one
    # tree); a body kept whole (b: - 1).  D-23's `take(x: ())` (above) is the empty Structure after the binding.
    # Mutants (steps/named-actuals.md §3, each by copy, both modes): no binding pass -- every named row red, the
    # formal-name row runs the method g (81), D-23's row red; a reader of the actuals turned back to the body's
    # own fields -- the running rows red (the controls of §5 there, reader by reader);
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
    # FIXED-BLOCKS-AUDIT: the binding's words name a named actual of 300 bytes in full; they were cut at 200 bytes.
    [pscustomobject]@{ Name = 'unit_named_actual_long_unknown_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = ('unit_named_actual_long_unknown_refused.lm2:8:12: zz' + ('z' * 298) + ' is not an argument of f'); Absent = @(); Debt = @() },
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
    [pscustomobject]@{ Name = 'unit_named_actual_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $prefixSignNamedActualShape; Entry = 7; NativeMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_named_actual_whole.lm2'; Source = 'unit_named_actual_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $prefixSignNamedActualShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    # A prefix sign (grammar, operators): one operator over one operand, told from the binary operator by
    # where it stands. Over a name, a group, a sign, a call evaluated once, after a binary minus, in a
    # condition, a declaration, a store and an actual; the unary plus; an unsigned operand that wraps.
    # Natively, and with the root and the ten methods walked. The path facts hold the retained shape: a
    # subtraction from an invented zero gives the same numbers and fails them.
    [pscustomobject]@{ Name = 'unit_prefix_sign.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $prefixSignShape; Entry = 7; NativeMethods = @(0,1,2,3,4,5,6,7,8,9);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_prefix_sign_walk.lm2'; Source = 'unit_prefix_sign.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $prefixSignShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8,9);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_prefix_sign_operand_mutant.lm2'; Source = 'unit_prefix_sign.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','4','4','2','1','1') + $prefixSignShape; Entry = 7; Absent = @(); Debt = @() },
    # The kind rule under a sign: a reference and a text are refused where they stand, in the field
    # form and inside a group. The sign of a char is an int: storing it into a char is a conversion.
    [pscustomobject]@{ Name = 'unit_prefix_sign_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_prefix_sign_ref_refused.lm2:10:9: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_prefix_sign_group_ref_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_prefix_sign_group_ref_refused.lm2:11:10: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_prefix_sign_text_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_prefix_sign_text_refused.lm2:8:10: a text where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_prefix_sign_char_promoted_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_prefix_sign_char_promoted_refused.lm2:8:5: the program has no method `lm_stg_convert_int_char`, the receiver of this conversion'; Absent = @(); Debt = @() },
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
    # Nondestructive binding of named actuals: the actuals are evaluated once in the order they are
    # written and each value goes to the formal its name resolves to. mark() records the order of its
    # calls in the unit's trace; f(b: mark(1); a: mark(2)) must leave 12, not the formal order 21, and
    # still compute a - b = 1. A positional prefix followed by two named actuals out of formal order
    # (g) and the root's own call hold the same. Natively, and with the root and all six methods
    # walked: the walker reads the written order and the coordinates from the graph's NAMED operands.
    [pscustomobject]@{ Name = 'unit_named_actual_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $namedActualOrderShape; Entry = 7; NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_order_walk.lm2'; Source = 'unit_named_actual_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $namedActualOrderShape; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    # The shape facts see the written order (the two named operands of h exchanged) and a named
    # operand's payload (emptied).
    [pscustomobject]@{ Name = 'unit_named_actual_order_swap_mutant.lm2'; Source = 'unit_named_actual_order.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','3','6','2','1','2','3') + $namedActualOrderShape; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_order_payload_mutant.lm2'; Source = 'unit_named_actual_order.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','5','7','2','1','4','2') + $namedActualOrderShape; Entry = 7; Absent = @(); Debt = @() },
    # The same order wherever a call stands: a sub called as a statement, a call in a condition, an
    # operand of an expression, a named actual of another named call, a method's `return:` trailer and
    # a sub called by the root. Natively, and with the root and the ten methods walked.
    [pscustomobject]@{ Name = 'unit_named_actual_order_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7,8,9); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_order_forms_walk.lm2'; Source = 'unit_named_actual_order_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8,9); Absent = @(); Debt = @() },
    # The invocation of a callable formal. The --walk-methods profile excludes callable formals, so
    # the interpreter does not run this EXEC: its order is seen natively and its named operands as
    # retained source, with the exchange of the two as the facts' control.
    [pscustomobject]@{ Name = 'unit_named_actual_order_callable.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0') + $namedActualCallableShape; Entry = 7; WalkRoot = $true; NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_order_callable_swap_mutant.lm2'; Source = 'unit_named_actual_order_callable.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','move-path-field','3','5','2','1','5','6') + $namedActualCallableShape; Entry = 7; Absent = @(); Debt = @() },
    # A bound call's body stays as written: the Frames that name its actuals are the binding's to read, and
    # every other reader takes the call's actuals (l2_call_actuals).  These rows hold what that view must
    # keep.  A name that names an actual is a formal of the callee, never a name of the caller's scope:
    # not when it is also a unit field, a local or a hidden input of the caller (scope_names), a method
    # (method_names), a Structure (structure_name: no declaration, no construction, and so no throw
    # channel -- the library row, link and symbols only: a method on the throw channel has no library
    # ABI), the caller's typed reference (reference_name: no store, so the reference's only use is the
    # field it reads and it receives the thinner candidate; reference_whole: the reference handed whole
    # to another Consumer is a use of it, not a store to it), a name of a definition's host (capture) or
    # of the caller of a callable formal (callable_names).  What an analysis looks for inside a named
    # actual is found there (facts: a read through node, an admitted formal passed on, a whole typed
    # reference, a store's right side), in every form a call takes (forms, machine).  A free name inside
    # a named actual is said at its own place (free_name_refused).  Natively, and with the root and the
    # methods walked; three forms are machine text and their methods stay native in the walked row too
    # (boom's throw with a payload; casted, thrower and sized), and each row says which.
    [pscustomobject]@{ Name = 'unit_named_actual_scope_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7,8,9,10,11,12,13); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_scope_names_walk.lm2'; Source = 'unit_named_actual_scope_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8,9,10,11,12,13); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_method_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_method_names_walk.lm2'; Source = 'unit_named_actual_method_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_reference_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_reference_name_walk.lm2'; Source = 'unit_named_actual_reference_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # The whole reference passed on by a named actual takes on what the callee reads through that formal: the
    # naming Frame is not a store to the reference.  The refusing neighbour is the method named in
    # unit_recv_use_passed_reads_refused: read as a store, the Frame would give the reference an empty coverage
    # and the candidate without the field would be received.
    [pscustomobject]@{ Name = 'unit_named_actual_reference_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1); Absent = @(); Debt = @('lmx_implements_receiving_use(') },
    [pscustomobject]@{ Name = 'unit_named_actual_reference_whole_walk.lm2'; Source = 'unit_named_actual_reference_whole.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_structure_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_structure_name_walk.lm2'; Source = 'unit_named_actual_structure_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_structure_name_lib.lm2'; Expect = 'library-links'; Exit = 0; Needle = '';
        With = @(); Exports = @('named_lib_f', 'named_lib_use'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_capture_walk.lm2'; Source = 'unit_named_actual_capture.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_callable_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_facts.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_facts_walk.lm2'; Source = 'unit_named_actual_facts.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_forms_walk.lm2'; Source = 'unit_named_actual_forms.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,3,4,5,6); NativeMethods = @(2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_machine.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_machine_walk.lm2'; Source = 'unit_named_actual_machine.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4,5,6); NativeMethods = @(2,3,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_free_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_free_name_refused.lm2:12:30: unbound dynamic input a'; Absent = @(); Debt = @() },
    # A named actual inside the index of a store's head.  The head is an expression of its own, parsed
    # apart and kept by its statement; the binding walks that one tree as it walks a body, so a call
    # there is bound as any call's.  The callee is a * 2 + b: bound by place every case writes another
    # cell.  The refusals are the ordinary ones, each at its own place in the head: a name that is no
    # formal, and a free name inside a named actual.  Mutant (the binding does not walk the head): the
    # three are refused as "unknown method".
    [pscustomobject]@{ Name = 'unit_named_actual_head_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_head_index_walk.lm2'; Source = 'unit_named_actual_head_index.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_head_index_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_head_index_name_refused.lm2:10:21: the argument a of pick is given by position (c:) and again by name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_head_index_free_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_head_index_free_refused.lm2:10:24: unresolved name'; Absent = @(); Debt = @() },
    # The reader of declarations answers by the call role the binding established, before its cache and
    # for a Frame its reading passes through.  The own rows are collected before the binding and read
    # statements by shape, so the cache holds `@: f(x b: 1)` as a pointer to f named x.  Mutants (the
    # cache asked first; the role asked of the Frame alone): the refusal names f an unknown type, 12:8.
    # The row holds that the answer does not depend on the cache, not the wording of the refusal.
    [pscustomobject]@{ Name = 'unit_named_actual_address_statement_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_address_statement_refused.lm2:12:5: unsupported body'; Absent = @(); Debt = @() },
    # The binding's records are found by their body's address through an index that starts at 64 places
    # and is kept at most half full: 90 named calls make it grow twice.  Mutants (the index grows without
    # placing the earlier records again; it does not search past an occupied place): refused or wrong.
    [pscustomobject]@{ Name = 'unit_named_actual_index_growth.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_index_growth_walk.lm2'; Source = 'unit_named_actual_index_growth.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # A held callable called with named actuals.  Its formals are those of the header of its declared
    # callable type (the result signature its constructor declares), not the constructor's inputs.
    # The binding binds them as a method's;
    # native code evaluates the actuals in written order into their formals' places; the retained
    # PRIM_PUB keeps a named actual at its written place under NAMED with its coordinate among the
    # primitive's inputs (the callable is input 0).  The refusals are a method's, in a method's words.
    # The header and the returned definition name the formals alike here; where they differ is OPEN,
    # the two probes below.
    # Mutants: the binding does not bind a held call, or the check reads the written body -- "unknown
    # method"; the header's names reversed -- refused; native code in the formals' order -- the native
    # row's trace, exit 84; the graph operand at its formal's place -- the walked row's trace, exit 84;
    # NAMED with the formal's index for its coordinate -- the walk refuses, INVALID; no NAMED -- exit 87.
    [pscustomobject]@{ Name = 'unit_named_actual_held.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_held_walk.lm2'; Source = 'unit_named_actual_held.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_held_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_held_name_refused.lm2:10:17: the argument x of h2 is given by position (z:) and again by name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_held_again_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_held_again_refused.lm2:9:13: the argument x of h2 is given by position and again by name'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_held_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_held_missing_refused.lm2:9:8: h2 has no argument x'; Absent = @(); Debt = @() },
    # OPEN (Codex, FABLE-CODEX-20261004-08), two temporary probes of what the translator does and no
    # norm: a constructor declares its result's header with the names p and q and returns a definition
    # whose own formals are x and y.  A call by p and q is bound by the header and reaches the
    # definition by coordinate; a call by x and y is refused.  Whether the named use is accepted by the
    # interface the callable actually has is not settled, and no rule that adapts the names has been
    # shown.  The probes go when the admission is decided; they are not evidence of either answer.
    [pscustomobject]@{ Name = 'unit_named_actual_held_header_names_limit_probe.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_held_definition_names_limit_probe.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_named_actual_held_definition_names_limit_probe.lm2:13:11: unknown method'; Absent = @(); Debt = @() },
    # The neighbour of the reading path of l2_declaration (Codex, FABLE-CODEX-20261004-07): a named
    # Structure whose body is one call with named actuals stays a definition whose body runs the call;
    # the stop at a call is the declaration reader's own nesting, not a rule for an enclosing Structure.
    [pscustomobject]@{ Name = 'unit_named_actual_structure_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('f 9 2', 'f 8 3', 'f 9 2'); NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_actual_structure_body_walk.lm2'; Source = 'unit_named_actual_structure_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('f 9 2', 'f 8 3', 'f 9 2'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1,2); NativeMethods = @(0); Absent = @(); Debt = @() },
    # The role of a statement and of a call head comes from the binding of the site (Codex,
    # FABLE-CODEX-20261004-06 and -08).  A callable formal called as a statement, `p: x`, `p(x)`,
    # `p(a: x)`, `q()`, is the call of what the formal carries, though the unit has no method of that
    # name.  A number formal or local is stored to, and its value checked, though the unit has a method
    # of its name.  A held callable of the root applied by a statement is its call, at the root and in
    # a method, also as the method's first statement; a local or a formal of its name hides it, and the
    # call of such a local is refused as the call of a local that hides a method is.  The controls ran
    # before the change.  The rows with a callable formal are native: the walked profile excludes them.
    # Mutants: the statement classifier asks the unit's methods by name -- the formal's statement is
    # refused and the two stores are accepted; a method's name still makes a statement a call -- the two
    # stores are accepted; the held callable found by name alone -- the shadowed call is accepted and
    # the store to the local refused; no statement role for a held callable, or its role asked of the
    # collected rows only -- "more arguments than h2 has formals"; no branch of the graph for it --
    # "not walkable yet"; the statement that stores the callable merge not kept apart -- every unit
    # with a held callable is refused, "unresolved name".
    [pscustomobject]@{ Name = 'unit_callable_formal_statement.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_store_method_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_store_method_name_refused.lm2:10:5: assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_store_local_method_name_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_store_local_method_name_refused.lm2:9:5: assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_statement.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_statement_walk.lm2'; Source = 'unit_held_call_statement.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_shadow_walk.lm2'; Source = 'unit_held_call_shadow.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_local_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_local_shadow_refused.lm2:12:13: unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_formal_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_formal_shadow_refused.lm2:11:13: unknown method'; Absent = @(); Debt = @() },
    # The held callable a head names is the row the name selects at its site (Codex,
    # FABLE-CODEX-20261004-09): the site's own row declared last before it, or in a method the unit's
    # field visible from the method.  The store of a callable merge declares its head only where the
    # head has no binding at the site; under a head that has one the same shape is a use of that
    # binding.  So `h2: make2 200` after `h2: make2 100` is the application h2(make2 200), refused as
    # that call, at the root and in a method (it ran to 200 before: the second statement replaced the
    # callable); under a number of the name -- a field, a local, a formal -- it is a store to the
    # number, refused as one.  A failed application leaves the callable as it was (the first actual
    # throws; the callable is then called and is the one stored).  A later `int: h2 5` supersedes
    # the callable from there on and does not reach back: the root calls h2 between the two, a
    # method standing between them sees the store, a method below both sees the int, and a call of
    # the method between them from a site whose h2 is the int is refused.  A callable held by a
    # field of a nested body is called there and is no binding after it.  A method's local holds a
    # callable as the root does; another method does not see it.  A held callable's call is typed
    # by its header's result where it is assigned alone, and an empty statement under a nullary held
    # callable is its call.
    # A head that selects no row names no held callable (Codex, FABLE-CODEX-20261004-10): a method
    # standing above every declaration of the name has no binding of it, and the head is an unknown
    # head there.  In a value position the call is refused; the statements `h2(5 6)` and `h2: 7 8`
    # are one form in two spellings, each defines a Structure of the method, and neither calls the
    # callable the root holds.  The lookup by the entry's last declaration is gone with its row.
    # The caller binds a method's free name by its own binding at the call: a caller that holds a
    # callable of its own under the name is called through; a caller with none leaves the
    # declaration the method sees; a caller whose binding is an int is refused (above).
    # A nullary held callable named alone as a statement is its call, as `p0()` is.
    # Mutants: the roots collected last -- the statement in a method is refused or accepted
    # wrongly; the collector or every pass by shape -- the reapplied
    # stores are accepted or "callable result field was not reserved"; the check alone by shape --
    # "root operation not walkable yet"; the classifier alone by shape -- "more arguments than h2
    # has formals"; the entry's last declaration in a method -- unit_held_call_superseded refused;
    # the row selected without the site -- the same; a row of another kind not blocking -- the
    # shadow rows flip; the entry's last declaration where no row is selected --
    # unit_held_call_above_refused accepted and unit_held_call_above_unknown_head runs to 81; a formal
    # not blocking -- the formal's rows flip; the root's rows only -- unit_held_call_method_local
    # refused; no type of an assigned call -- "assignment value has unknown type"; an empty
    # statement sent to the Structure route -- "executing a named Structure is not supported yet";
    # the bare name not taken by the check -- the same refusal; not taken by the native emission,
    # by the graph, or counted inert as a body's only statement -- unit_held_call_bare_name runs to
    # 81, natively or walked.
    # Two mutants did not reach a witness: the graph alone and the native emission alone
    # intercepting by shape.  No program the check accepts carries the storing shape under a bound
    # head, so neither point is entered with one.
    [pscustomobject]@{ Name = 'unit_held_call_reapplied_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_reapplied_refused.lm2:12:5: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_reapplied_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_reapplied_method_refused.lm2:12:9: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_store_callable_over_number_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_store_callable_over_number_refused.lm2:10:5: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_store_callable_over_local_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_store_callable_over_local_refused.lm2:13:9: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_store_callable_over_formal_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_store_callable_over_formal_refused.lm2:12:9: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_failed_application.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_failed_application_walk.lm2'; Source = 'unit_held_call_failed_application.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_superseded.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_superseded_walk.lm2'; Source = 'unit_held_call_superseded.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_superseded_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_superseded_refused.lm2:13:13: unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_superseded_caller_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_superseded_caller_refused.lm2:18:30: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_above_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_above_refused.lm2:7:13: unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_above_unknown_head.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_above_unknown_head_walk.lm2'; Source = 'unit_held_call_above_unknown_head.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_caller_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_caller_binding_walk.lm2'; Source = 'unit_held_call_caller_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_block.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_block_walk.lm2'; Source = 'unit_held_call_block.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_block_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_block_refused.lm2:12:30: unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_method_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_method_local_walk.lm2'; Source = 'unit_held_call_method_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_other_method_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_other_method_refused.lm2:15:13: unknown method'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_assigned.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_assigned_walk.lm2'; Source = 'unit_held_call_assigned.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_assigned_type_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_assigned_type_refused.lm2:12:1: assignment value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_nullary_statement.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_nullary_statement_walk.lm2'; Source = 'unit_held_call_nullary_statement.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_walk.lm2'; Source = 'unit_held_call_bare_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,4); Absent = @(); Debt = @() },
    # The bare name of a held callable where a result is received (Codex, FABLE-CODEX-20261004-11 and -12; semantics,
    # #callables): a place whose receiving contract is a number receives what the call gives -- a store, an int
    # formal's actual, the value an int method returns (the first program); an initializer, a method's local, a
    # number field through a path, an element, a place of another number type through its conversion (the second);
    # a number field of a message (the third).  A place that receives a reference takes the occurrence and executes
    # nothing: an opaque reference declared with the name, an opaque formal's actual, a cast (the fourth; its method
    # holds machine operations and stays native under the knob, the root's receipts are walked).  The bare name
    # passes no argument: a header whose formals have no defaults is refused as the call without actuals is.
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_result_walk.lm2'; Source = 'unit_held_call_bare_name_result.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_places.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_places_walk.lm2'; Source = 'unit_held_call_bare_name_places.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_message.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_occurrence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_occurrence_walk.lm2'; Source = 'unit_held_call_bare_name_occurrence.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4); NativeMethods = @(5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_args_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_bare_name_args_refused.lm2:13:4: a held callable takes the arguments of its header'; Absent = @(); Debt = @() },
    # The operands of an operation and the one value of a condition receive a number too (Codex,
    # FABLE-CODEX-20261004-12): the bare name of a held callable there is executed, and `z0 = 0` compares what z0
    # gives, not its occurrence.  The first program: arithmetic, an ordering, equalities with a zero result and a
    # non-null occurrence, short-circuits, a prefix sign, groups, operations in an actual, a store, a path write and
    # a return, and an opaque reference compared without a call.  The second: the conditions of if, while, until
    # and for.  The third: an operation in a number field of a message.
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_operand_walk.lm2'; Source = 'unit_held_call_bare_name_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_condition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,7,9,11,13); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_condition_walk.lm2'; Source = 'unit_held_call_bare_name_condition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,7,9,11,13); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_message_operand.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    # An operation given to a place of another number type, where that conversion is the method's only one: the
    # store notes its edge from the type the operation has with its operands received.
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_operand_convert.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_bare_name_operand_convert_walk.lm2'; Source = 'unit_held_call_bare_name_operand_convert.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4,5); Absent = @(); Debt = @() },
    # A group is one operand of the operation around it: natively a group whose fields call went out without its
    # parentheses (NATIVE-GROUP-CALL-PARENTHESES), `(u() + 1) * 2` as 100 + 1 * 2.
    [pscustomobject]@{ Name = 'unit_group_call_parentheses.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_group_call_parentheses_walk.lm2'; Source = 'unit_group_call_parentheses.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # A held definition as the actual of a callable formal (HELD-CALLABLE-TO-CALLABLE-FORMAL; K04 S3; Codex,
    # FABLE-CODEX-20261004-12).  The formal receives the node the name holds, and nothing is called on reception
    # (to_callable_formal).  The definition's free names are formed where the formal is called, as any
    # callable's: each copy reads its own where no caller has the name, and a caller's value wins over both
    # copies, through a formal handed on and from a method (free_names).  The formal holds that very node: an
    # explicit read of the node gives the copy's own value whatever the callers give, and a write to the node
    # stays in that copy (node).  A definition made in a method and kept in that method's own name is given from
    # there, each call its own copy (local).  A definition and methods of the unit that form their inputs alike
    # are one formation, and nothing is told apart where the formal is called (alike).  Natively only: a method
    # with a callable formal is outside the walkable subset.
    [pscustomobject]@{ Name = 'unit_held_call_to_callable_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_free_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_alike.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    # A held definition is admitted to a callable formal by the signature of its model.
    [pscustomobject]@{ Name = 'unit_held_actual_signature_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_actual_signature_refused.lm2:21:8: incompatible entry signature'; Absent = @(); Debt = @() },
    # OPEN positives, required before G5.  A limit of this implementation and no rule; red until built, never to
    # be turned into expected refusals.  A definition's node at a formal that also receives callables formed in
    # another way -- methods of the unit (among_methods), the nodes of another definition (two_models) -- is
    # refused where the formal is called: a node has no contract route of its own yet to be told by.
    [pscustomobject]@{ Name = 'unit_held_actual_among_methods.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_two_models.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # Formation against transport (K04 S3; Codex, FABLE-CODEX-20261004-12, eleventh reply).  A method that reads
    # a free name forms its own value of it, from its own lexical source where no caller gives one, and its
    # callees receive that value; a method that only hands the name on forms nothing, and the reader uses its
    # own source; an assignment changes the value of that activation and no node (formed_input).  Natively and
    # with the methods walked; the definitions are walked in both.
    [pscustomobject]@{ Name = 'unit_held_call_formed_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,4,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_formed_input_walk.lm2'; Source = 'unit_held_call_formed_input.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4,6); Absent = @(); Debt = @() },
    # A definition's assignment to a name of the method that holds it -- a formal, a field declared at method
    # level -- assigns the definition's own value of that free name; it is no declaration of a Structure of the
    # definition.
    [pscustomobject]@{ Name = 'unit_nested_definition_assigns_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,4,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_assigns_free_name_walk.lm2'; Source = 'unit_nested_definition_assigns_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4,6); Absent = @(); Debt = @() },
    # Held definitions at a callable formal, further.  Two definitions of two methods that form alike are one
    # formation (two_alike).  A reference among the definition's free names travels as any method's input: the
    # root's, a caller's own of the same declaration, a caller's own of another declaration admitted by the field
    # read (reference); a caller's own without that field is refused where the formal is called
    # (reference_refused).  Natively only: a method with a callable formal is outside the walkable subset.
    [pscustomobject]@{ Name = 'unit_held_actual_two_alike.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_reference.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_actual_reference_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_actual_reference_refused.lm2:28:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # The node a merge builds carries its own complete contract (T7-MODEL-FREE-NAME): the formals the merge
    # leaves unbound, then the model's hidden inputs, and its body reads each at its place there.  A model that
    # reads a number of the unit, held: the root, another copy, a caller's value (free_name).  Two formals left
    # unbound (two_formals).  A model that reads a reference of the unit, held (reference_held).  A model that
    # calls a method reading, as free names, the formal the merge binds and the one it leaves
    # (model_calls_reader).  Natively and with the methods walked; the method that returns the merge stays
    # native in both.
    [pscustomobject]@{ Name = 'unit_t7_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_free_name_walk.lm2'; Source = 'unit_t7_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_two_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_two_formals_walk.lm2'; Source = 'unit_t7_two_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_reference_held.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_reference_held_walk.lm2'; Source = 'unit_t7_reference_held.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_model_calls_reader.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_model_calls_reader_walk.lm2'; Source = 'unit_t7_model_calls_reader.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    # T7 (T7-NODE-LEXICAL-LINKS; the author, 2026-10-05: merge copies the used part of the tree and rewrites the parent
    # links inside the copy; the place of the merge gives no parent).  The node hangs under a copy of its model's
    # lexical tree, made at the merge, and its body reads the copy where no caller gives a name.  copy_lexical_formal:
    # make's own other is 50, the copy reads the unit's 9 before and after bump writes 11 into the unit, and the
    # original add reads 11 (the fallback of a free name).  copy_lexical_node: the same through `node\other` (the node's
    # parent).  copy_parent: the post paths from w's cell (`deref`, `up`) find the node's parent a distinct copy of the
    # unit, its other and m distinct, m's parent the copy as the original m's is the unit, the qualified branch E the
    # same object.  Natively, with the root walked and with the methods walked.  Mutants: the body over the live unit --
    # formal, T7 9 11 9 11; the node at the merge's place -- node, T7 9 11 11; no qualified branch retained --
    # copy_parent's samepath.
    [pscustomobject]@{ Name = 'unit_t7_copy_lexical_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Says = @('T7 9 9 9 11'); NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_t7_copy_lexical_formal.lm2'; Source = 'unit_t7_copy_lexical_formal.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('T7 9 9 9 11'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); NativeMethods = @(6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_copy_lexical_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Says = @('T7 9 9 11'); NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_t7_copy_lexical_node.lm2'; Source = 'unit_t7_copy_lexical_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('T7 9 9 11'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); NativeMethods = @(6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_copy_parent.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('1') + $criticalT7CopyPost; Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'graph_shape_t7_copy_parent_walk.lm2'; Source = 'graph_shape_t7_copy_parent.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('1') + $criticalT7CopyPost; Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # T7-TRAILER-ONLY-MODEL-CRASH: a model whose only line is its trailer `return:` has no body Structure, and the T7
    # count and frame passes read one: the translator crashed, whether or not anything called the merge.  The node
    # walks the trailer alone, as a merge result's steps and a walked method's do.  trailer_only_copy: make's own k is
    # 50, the copy reads the unit's 9 before and after bump writes 11, and the original r reads 11;
    # trailer_only_copy_indented is the same program with the return in r's body; trailer_only_never_invoked is the
    # defect's program; trailer_only_formals has a bound and a given formal beside the free name.  A descriptor with
    # neither a body nor a trailer stays without an implementation: merge(test3), invoked, is refused at the merge
    # (descriptor_model_refused; its direct call is unit_callable_descriptor_direct_refused).  Natively, with the root
    # walked and with the methods walked.  Mutants: the crash turned into a refusal -- the three trailer-only programs
    # refused; an empty step invented where there is no trailer -- descriptor_model_refused translates and runs; the
    # emission pass skipping a body-less model's trailer -- "a method's steps changed between the passes".
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_copy_walk.lm2'; Source = 'unit_t7_trailer_only_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_copy_indented.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_copy_indented_walk.lm2'; Source = 'unit_t7_trailer_only_copy_indented.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_never_invoked.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_never_invoked_walk.lm2'; Source = 'unit_t7_trailer_only_never_invoked.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_trailer_only_formals_walk.lm2'; Source = 'unit_t7_trailer_only_formals.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_descriptor_model_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_t7_descriptor_model_refused.lm2:9:13: a callable merge needs a walkable body'; Absent = @(); Debt = @() },
    # K04 S3, step four (Codex -12, twelfth to fifteenth reply): a merge's node is built by one constructor of the
    # generated module, which the native body calls and the walked body's step calls through its primitive entry;
    # under the knob the method that returns the merge is walked (the four _walk rows above, and these).  A method
    # that does something before it returns a merge builds the node once, where its own body ends, with the value
    # each bound name has there: a field, a loop and an if before the return, and a caller's value before the
    # unit's (host_body); a field named like the bound formal (host_bound_field).  The rows are written with the
    # model first and call the node with its bound formal at its default: a bounded case, not the whole of a
    # callable merge (steps/defects.md, MERGE-KEEPS-MODEL-INTERFACE).  The node's parent and the source of a name
    # no caller gives: the copy of the model's lexical tree, the T7 rows above (steps/defects.md,
    # T7-NODE-LEXICAL-LINKS).
    # Mutants, each run natively, with the root walked and with the methods walked: the native body hands 0 for
    # the bound formal -- host_body and host_bound_field red natively, green walked; the walked step hands 0 --
    # both red walked, green natively; the formal as it was received, not the value its name has at the merge --
    # host_bound_field red, in the body that was mutated.
    [pscustomobject]@{ Name = 'unit_t7_host_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @('LMX_WALK_OP_SOURCE_MACHINE'); Debt = @('l2_t7n0: l2_t7_make_0(self, (', '\fn: l2_t7_construct_0', 'lmx_int_value_known(refs[1U])') },
    [pscustomobject]@{ Name = 'unit_t7_host_body_walk.lm2'; Source = 'unit_t7_host_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @('LMX_WALK_OP_SOURCE_MACHINE'); Debt = @('\fn: l2_t7_construct_0') },
    [pscustomobject]@{ Name = 'unit_t7_host_bound_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_host_bound_field_walk.lm2'; Source = 'unit_t7_host_bound_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # A host builds its node where its own body ends: a nested body of it -- a loop, an if -- is its statements.
    # Routed as the host's body, the loop's body built the node, and returned it, at its own end: 7 where the
    # norm gives 9, natively, with no refusal; the walked host was right (steps/defects.md,
    # HOST-BUILDS-IN-NESTED-BODY).  Mutant: the routing back -- this row and host_body red natively, their _walk
    # rows green.
    [pscustomobject]@{ Name = 'unit_nested_definition_host_loop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_host_loop_walk.lm2'; Source = 'unit_nested_definition_host_loop.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); Absent = @(); Debt = @() },
    # The root gives a merge as the actual of a callable formal, and so does a method: the same merge, the same
    # constructor.  The root has a native body and a walked one, and each builds the node: the row runs the
    # artifact natively and then through its graph (WalkRoot), the root's leaf carries its native word
    # (NativeRoot), the native bodies call the constructor and the graph's steps name its primitive entry, and no
    # machine operation is retained for a merge.  Source change of 2026-10-04: the fixture was written with the
    # data first and was red at a limit of the root; it is moved to the model first (steps/defects.md,
    # T7-DATA-FIRST-SHAPE).  The methods are not walked here: a method with a callable formal is outside the
    # knob's subset (unit_walk_methods_callable_formal_refused), which the walked consumer's step takes away.
    # Mutants: the primitive entry gives no node -- red with the root walked, green natively; no place for a body
    # with nothing above it -- red in both, the root's native body stops; the root's limit back -- refused.
    [pscustomobject]@{ Name = 'unit_t7_actual_from_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeRoot = 5; NativeMethods = @(0,1,2,3,4); Absent = @('LMX_WALK_OP_SOURCE_MACHINE');
        Debt = @('l2_t7n0: l2_t7_make_0(self)', 'l2_t7n3: l2_t7_make_3(self)', '\fn: l2_t7_construct_0', '\fn: l2_t7_construct_3') },
    # A body that is always walked gives a merge as an actual: a definition nested in a method and returned by
    # it reads the method's formal, so it has no native body, and its node's body is walked wherever it is called.
    # The walked step builds the merge's node by the constructor a native body calls; no native body builds this
    # one (Absent: no native call of the constructor).  Before step four the definition was refused: its graph
    # retained the merge as a machine operation.  Mutants: the walked step hands 0 for the bound formal -- red;
    # the primitive entry gives no node -- red; the native body hands 0 -- green, no native body is involved.
    [pscustomobject]@{ Name = 'unit_t7_actual_in_definition.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,5); Absent = @('l2_t7n0: l2_t7_make_0(self', 'LMX_WALK_OP_SOURCE_MACHINE');
        Debt = @('\fn: l2_t7_construct_0', 'l2_t7_made: l2_t7_make_0(l2_t7_at, lmx_int_value_known(refs[1U]))') },
    # A merge given as the actual of a callable formal is followed as a node of its model: its model's free
    # names are formed where the formal is called, a number and a size_t each at the model's own place
    # (actual_free_name); a merge and a method of the unit that form alike are one formation, through a formal
    # handed on (actual_alike); a typed reference of the unit reaches the node as a reference
    # (actual_typed_reference).  The merges of a unit are not counted against a fixed size (many).  Natively only.
    [pscustomobject]@{ Name = 'unit_t7_actual_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_actual_alike.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_actual_typed_reference.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_t7_many.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29); Absent = @(); Debt = @() },
    # A merge given as the actual whose model reads a reference admitted through a Structure the unit holds in a
    # nested body.  A merge's node is built when the merge runs, by a constructor of its own, which has none of
    # the aliases the unit's constructor names its holders by: it reaches that Structure from the unit along the
    # unit's own edges (the pin).  9, and 45 with the caller's own m.
    [pscustomobject]@{ Name = 'unit_t7_actual_reference.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @('1U, (cast: (@: void) lmx_arena_ref_struct(l2_entry_unit, ') },
    # OPEN positive, required before G5.  A limit of this implementation and no rule; red until built, never to
    # be turned into an expected refusal.  A merge returned from a nested body of its method: a method's
    # returned merge is built at one place, a statement of the method's own body (host_nested_return).
    [pscustomobject]@{ Name = 'unit_t7_host_nested_return.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # A reference among the free names of a definition its method returns (HELD-CALL-FROM-NESTED-DEFINITION; Codex,
    # FABLE-CODEX-20261004-12).  The caller that names no such reference supplies nothing, and the definition reads
    # its lexical source at the call: a held callable of the unit (root, method), with an argument and two in one
    # expression (args), two levels deep and named bare (chain), a Structure of the unit read by a path, also after
    # a write to it (structure_path).  From the root the unit's own row is the caller's binding and the lexical
    # source at once.  The control beside them is the number, which had this reading before
    # (number_override: the caller's own number first).  Each natively and with the methods walked.
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_root_walk.lm2'; Source = 'unit_held_call_from_nested_definition_root.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_method_walk.lm2'; Source = 'unit_held_call_from_nested_definition_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_args.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,4,6,8,9); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_args_walk.lm2'; Source = 'unit_held_call_from_nested_definition_args.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4,6,8,9); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,4,6,8,9); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_from_nested_definition_chain_walk.lm2'; Source = 'unit_held_call_from_nested_definition_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,4,6,8,9); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_structure_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_structure_path_walk.lm2'; Source = 'unit_nested_definition_structure_path.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_number_override.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_number_override_walk.lm2'; Source = 'unit_nested_definition_number_override.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3); Absent = @(); Debt = @() },
    # A caller's own Structure under the definition's free name, with no field the definition reads: present and
    # not fitting.  It is a candidate for the definition's use of the name and is refused by the ordinary
    # admission, by the field the definition reads; the unit's Structure is not read in its place.
    [pscustomobject]@{ Name = 'unit_nested_definition_structure_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_nested_definition_structure_other_refused.lm2:25:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # A caller's own Structure of the same type under the definition's free name is the caller's nearest binding
    # and comes first: 5 + 40.  It is another declaration than the one the definition's lexical source names, and
    # is admitted to the definition's use as a call of a method admits a hidden input.
    [pscustomobject]@{ Name = 'unit_nested_definition_structure_override.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_nested_definition_structure_override_walk.lm2'; Source = 'unit_nested_definition_structure_override.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2); Absent = @(); Debt = @() },
    # A reference among a held definition's free names is asked along the chain of callers, as a number is
    # (Codex, FABLE-CODEX-20261004-12, the seventeenth reply).  A method that makes the held call and has no
    # binding of the name only hands it on; the caller's nearest binding comes first, of the same declaration
    # (45) or of another, with the field at another position, two methods above the held call (65) and at the
    # held call itself (75); from the root the unit's own is read (9).
    [pscustomobject]@{ Name = 'unit_held_reference_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_reference_chain_walk.lm2'; Source = 'unit_held_reference_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4,5,6); Absent = @(); Debt = @() },
    # The same for a Structure the definition takes from its host, whose own source is the copy its node keeps.
    # With no binding anywhere the name arrives absent through two methods that only hand it on, and through
    # the instruction that admits it where the methods are walked (LMX_WALK_OP_ADMIT_AS keeps an absent operand
    # absent): the definition reads its node's copy, 35.  A caller's own Structure of the same declaration, 25;
    # of another, with the field at another position, admitted by the declaration it carries among those the
    # translation records as reaching the input, 45.  The definition's own Structure is as it was after them.
    [pscustomobject]@{ Name = 'unit_held_capture_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_capture_chain_walk.lm2'; Source = 'unit_held_capture_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4,5); Absent = @(); Debt = @('c.LMX_WALK_OP_ADMIT_AS') },
    # A Structure with no field the definition reads, given two methods above the held call: refused by the
    # ordinary admission where the value is admitted to the definition's use; the node's copy is not read in
    # its place.
    [pscustomobject]@{ Name = 'unit_held_capture_chain_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_capture_chain_other_refused.lm2:26:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # Three more kinds of name the chain reaches.  A Structure field of the host itself is a free name of the
    # definition as a Structure the host takes is: 35, and 55 with a caller's own (capture_host_field).  A typed
    # reference of the unit, with a caller's reference to another declaration two methods above: 9 and 65
    # (reference_typed_chain).  A definition that writes through the reference writes the Structure it was
    # given: the caller's own, and the unit's is as the root's call left it (reference_write_chain).
    [pscustomobject]@{ Name = 'unit_held_capture_host_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_capture_host_field_walk.lm2'; Source = 'unit_held_capture_host_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_reference_typed_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_reference_typed_chain_walk.lm2'; Source = 'unit_held_reference_typed_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_reference_write_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_reference_write_chain_walk.lm2'; Source = 'unit_held_reference_write_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3); Absent = @(); Debt = @() },
    # A reference that is present and holds nothing, through two methods that only hand it on: it stays present
    # and is not replaced by the lexical value an absent one falls back to (7, not 11).
    [pscustomobject]@{ Name = 'unit_site_hidden_null_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_site_hidden_null_chain_walk.lm2'; Source = 'unit_site_hidden_null_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    # The admission of a candidate the translation has no layout for, where an input is formed, can fail when the
    # program runs: the failure is the implicit `implements` of the method that forms the input, natively as
    # walked, and never a stop of the process (Codex, FABLE-CODEX-20261004-12, the eighteenth reply).  A letter
    # through an opaque formal to a Structure formal: the handler of the forming method takes it, the callee is
    # not entered, the candidate is produced once, and a refused admission records nothing (actual_catch).  With
    # no handler the Message is stopped with no value (actual_uncaught).  Under a free name, through two methods
    # that only hand it on, beside a caller whose Structure fits: refused where the last of them forms the
    # definition's input, taken by the handler of the method that received the letter (hidden_catch).  That
    # method stays native where the methods are walked; the two that hand the name on, and so the admission and
    # the way of its refusal, are walked.
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_catch_walk.lm2'; Source = 'unit_admit_dynamic_actual_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,7); NativeMethods = @(6); Absent = @(); Debt = @() },
    # RECEPTION-EDGE-DEBTS (c) (Codex, FABLE-CODEX-20261004-12): the result of a call of opaque type given directly
    # to a Structure formal is received as the same value through a local reference is -- a dynamic candidate,
    # admitted where the input is formed, the call evaluated once.  call_result_actual: a Model 4, an Other whose
    # `value` is its second field 9 by name, the Model through a local reference 4, three productions.
    # call_result_actual_catch: the catch row above with get(same(p)) -- 42 twice, get not entered, 43 for pass2's
    # own `implements`.  A number and a deeper reference stay refused where they are given.
    [pscustomobject]@{ Name = 'unit_recv_call_result_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_call_result_actual_walk.lm2'; Source = 'unit_recv_call_result_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_call_result_actual_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_call_result_actual_catch_walk.lm2'; Source = 'unit_recv_call_result_actual_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,7); NativeMethods = @(6); Absent = @(); Debt = @() },
    # The same edge reaches a pointer cast given directly: its operand's sources reach the formal, read by name (9);
    # until 2026-10-05 the formal was read by position, the Other's first field (1), with no refusal.  run keeps its
    # native word where the methods are walked; get, which reads the formal, is walked.
    [pscustomobject]@{ Name = 'unit_recv_cast_actual_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_cast_actual_by_name_walk.lm2'; Source = 'unit_recv_cast_actual_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_call_number_result_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_call_number_result_refused.lm2:10:11: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_call_depth_result_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_call_depth_result_refused.lm2:11:11: implements is false in function argument'; Absent = @(); Debt = @() },
    # RECEPTION-EDGE-DEBTS (d) (Codex, FABLE-CODEX-20261004-12: "the good branch succeeds, the incompatible branch
    # fails catchably at the receiving edge"): a candidate chosen when the program runs, among one that fits and one
    # that does not, is admitted by the one it is.  possible_result: pick returns either -- 4; the Thin refused where
    # run forms the input, taken by run's handler, 42, get entered once; with no handler the Message is stopped
    # (uncaught).  possible_formal: the same through an opaque formal (until 2026-10-05 the internal error of
    # OPAQUE-ACTUAL-KNOWN-LAYOUT).  possible_result_only_refused: every candidate the edge brings is refused, so is
    # the call, at translation.  opaque_formal_by_name, opaque_local_by_name: an Other through an opaque formal and
    # through an opaque local reads its `value` by name, 9 (until 2026-10-05 the formal read by position, 1, and the
    # local was refused when the program ran).  opaque_actual_known_layout: OPAQUE-ACTUAL-KNOWN-LAYOUT's own
    # program, 5.  Where the methods are walked, every method of these fixtures is.
    [pscustomobject]@{ Name = 'unit_recv_possible_result_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_result_catch_walk.lm2'; Source = 'unit_recv_possible_result_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_result_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_result_uncaught_walk.lm2'; Source = 'unit_recv_possible_result_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_result_only_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_possible_result_only_refused.lm2:22:8: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_formal_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_possible_formal_catch_walk.lm2'; Source = 'unit_recv_possible_formal_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_formal_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_formal_by_name_walk.lm2'; Source = 'unit_recv_opaque_formal_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_local_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_local_by_name_walk.lm2'; Source = 'unit_recv_opaque_local_by_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_actual_known_layout.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_opaque_actual_known_layout_walk.lm2'; Source = 'unit_opaque_actual_known_layout.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 5;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # RECEPTION-EDGE-DEBTS (e) (Codex, FABLE-CODEX-20261004-12: "the same receiving-edge conversion/admission as the
    # explicit analogue, provided actual reference depth/type is correct"): a caller's `@: void` under a free name its
    # reader uses as a Model reference -- a Model 11, an Other by name 9, a Thin refused where caller forms relay's
    # input, 42 (until 2026-10-05 "incompatible entry signature" at caller's call); a `@@: void` stays refused.
    # ARGUMENT-EDGE-REFERENCE-TYPE: a name a level deeper than the Structure formal, or `@: char`, is refused where
    # it is given (until 2026-10-05 admitted, the first stopping the process at the read).
    [pscustomobject]@{ Name = 'unit_recv_hidden_opaque_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_hidden_opaque_typed_walk.lm2'; Source = 'unit_recv_hidden_opaque_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_hidden_opaque_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_hidden_opaque_depth_refused.lm2:11:9: incompatible entry signature'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_name_depth_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_name_depth_refused.lm2:13:11: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_name_char_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_name_char_refused.lm2:13:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # RECEPTION-EDGE-DEBTS (f) (Codex, FABLE-CODEX-20261004-12: "absence of a named source schema is not proved
    # implements-false"): a value of opaque type returned as a typed result is admitted when the program runs, by
    # every field of the result's type, as the returning method's implicit `implements` -- a Model 4, an Other by
    # name 9, a Thin refused where back returns it and taken by run's handler 42, a call's opaque result 4 (until
    # 2026-10-05 both returns refused at translation); a formal given only the Thin stays refused at translation.
    [pscustomobject]@{ Name = 'unit_recv_opaque_return_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_return_typed_walk.lm2'; Source = 'unit_recv_opaque_return_typed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_recv_opaque_return_only_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_recv_opaque_return_only_refused.lm2:13:1: implements is false in return value'; Absent = @(); Debt = @() },
    # The refusal is thrown with the statuses and handlers of the method that forms the input, whatever the callee
    # declares: the callee has a throw of its own, and the forming method's handler of `implements` takes the
    # refusal, not its handler of the callee's name (43, not 44).  A method that declares a throw stays native
    # where the methods are walked; the forming method is walked.
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_context_walk.lm2'; Source = 'unit_admit_dynamic_actual_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1,2); NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_actual_uncaught_walk.lm2'; Source = 'unit_admit_dynamic_actual_uncaught.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_hidden_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_admit_dynamic_hidden_catch_walk.lm2'; Source = 'unit_admit_dynamic_hidden_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4,5,6); NativeMethods = @(7); Absent = @(); Debt = @() },
    # A reference a method requires, which nothing in its sight declares and no caller of the chain has: refused
    # at the root's call of the method that hands it on, where the chain starts, as a number is.
    [pscustomobject]@{ Name = 'unit_reference_required_unbound_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_reference_required_unbound_refused.lm2:25:8: unbound dynamic input box'; Absent = @(); Debt = @() },
    # A path through a free name that nothing in the method's sight declares (FREE-REFERENCE-NO-DECLARATION; Codex,
    # FABLE-CODEX-20261004-12, the eighteenth and nineteenth replies).  Such a name has no type of its own.  Among
    # the declarations the translation records as reaching it, one that has every path the method uses is the
    # coordinate space of those paths; a Structure of another declaration is admitted to it by those paths only,
    # as to a declared requirement.  No type is made up, and nothing of it exists when the program runs.
    # Through a method that only hands the name on (31), with the field at another position (41), from a caller
    # that calls the reader itself (51); natively and with the reader and the forwarder walked.
    [pscustomobject]@{ Name = 'unit_free_path_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_read_walk.lm2'; Source = 'unit_free_path_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    # What is accepted and what is read do not depend on the order of the unit, on fields the method does not
    # use, or on which declaration is taken.  The declaration with unused fields first and the callers above the
    # reader (order); the reader above the declarations and the declaration with only the field first
    # (order_swapped): 21 and 31 in both.
    [pscustomobject]@{ Name = 'unit_free_path_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_order_walk.lm2'; Source = 'unit_free_path_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_order_swapped.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_order_swapped_walk.lm2'; Source = 'unit_free_path_order_swapped.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # A declaration that has not the field one method reads, declared first, reaching another method's name only,
    # does not decide for the declarations that have it: each method reads what its caller gave (31, 52).
    [pscustomobject]@{ Name = 'unit_free_path_first_lacks.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_first_lacks_walk.lm2'; Source = 'unit_free_path_first_lacks.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # A Structure with no field the method reads through the name is refused by the ordinary admission where it
    # is handed to the reader.  At its giver's call (other_refused) the edge brings nothing else: every call through
    # it is incompatible, refused at translation.  Through a method that hands the name on (other_chain_refused) the
    # edge brings has's Model too: a possible candidate, refused when the program runs where mid forms r's input
    # (RECEPTION-EDGE-DEBTS (d); until 2026-10-05 at translation, 17:13) -- has gives 31, bad's refusal leaves the
    # root uncaught; with bad's handler, 42 (other_chain_catch).
    [pscustomobject]@{ Name = 'unit_free_path_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_other_refused.lm2:25:13: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_other_chain_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_other_chain_refused_walk.lm2'; Source = 'unit_free_path_other_chain_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Fails = 1; Stopped = 1; Thrown = 2;
        WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_other_chain_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_other_chain_catch_walk.lm2'; Source = 'unit_free_path_other_chain_catch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # A write through such a path changes the Structure the caller gave, through a method that only hands the
    # name on, with the field at another position.  A method that only writes through the name reads the name
    # as one that reads through it does: the root of a written path is read (4142, 808, 13, 14).
    [pscustomobject]@{ Name = 'unit_free_path_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_write_walk.lm2'; Source = 'unit_free_path_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    # The same for a name the unit declares: a method that only writes box\v took no box from its caller, and
    # the write went to whichever declaration of that spelling the path's resolution found -- another method's
    # own field, in generated code the C compiler refused.  The root's call writes the unit's Structure; a
    # caller's own Structure is written from a caller that has one, and the unit's is as the root left it.
    [pscustomobject]@{ Name = 'unit_field_path_write_only.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_field_path_write_only_walk.lm2'; Source = 'unit_field_path_write_only.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    # A reference that is present and holds nothing stays present under such a name: no Structure is made up and
    # no declaration's default is read in its place (11, 22, 7).  A read through it stops where a read through a
    # declared reference does -- the path meets no Structure (the pin; walked, the walker's X1 below) -- and is
    # no refusal of an admission: the handler of `implements` in null_read does not take it.
    [pscustomobject]@{ Name = 'unit_free_path_null.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @('c.fprintf(c.stderr, "lmx: invariant: a field path met no Structure\n")') },
    [pscustomobject]@{ Name = 'unit_free_path_null_walk.lm2'; Source = 'unit_free_path_null.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_null_read_walk.lm2'; Source = 'unit_free_path_null_read.lm2'; Expect = 'walk-x1'; Exit = 0; Needle = ''; Args = @('0'); WalkMethods = $true;
        WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # OPEN positives, required before G5 (Codex, FABLE-CODEX-20261004-12, the twenty-first reply).  Limits of this
    # implementation and no rules; red until built, never to be turned into expected refusals.  What a method
    # consumes at a read decides, not equality of the field's type in one declaration and another: a reader that
    # forms an int from a field reads an int field as it is and a size_t field at its own type, through the
    # ordinary converter: 31 and 41, in either order of the two declarations (field_converted, _swapped), and for
    # a declared formal as for a free name (unit_formal_field_converted).  Under a free name the path is refused
    # where it stands, with the same words in either order; for the formal the candidate is refused by the
    # difference of the types.  The walked twins come with the mechanism: the conversion at the receiving edge.
    [pscustomobject]@{ Name = 'unit_free_path_field_converted.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_field_converted_swapped.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_field_converted.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # OPEN positive, required before G5 (the same reply).  A returned definition that itself reads a name nothing
    # declares takes it from the caller, as a method of the unit does: 45.  It is refused with the words of a
    # merge's binding, which are about another thing.
    [pscustomobject]@{ Name = 'unit_held_definition_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    # No declaration that reaches the name has the field the method reads.  The programs are not valid whatever
    # is built -- the only caller gives a Structure without the field -- and the words are those of the limit
    # that stands where no coordinate space is established: values with no layout may reach such a name too.
    # A read in an expression (none_refused), a path that is the whole of a value (value_none_refused), a method
    # that only writes, whose check waits for the callers (write_none_refused), a path of two steps
    # (deep_none_refused).
    [pscustomobject]@{ Name = 'unit_free_path_none_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_none_refused.lm2:10:13: a path through a free name that no declaration reaching it gives its fields to is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_value_none_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_value_none_refused.lm2:8:5: a path through a free name that no declaration reaching it gives its fields to is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_write_none_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_write_none_refused.lm2:9:5: a path through a free name that no declaration reaching it gives its fields to is not built yet'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_deep_none_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_deep_none_refused.lm2:7:13: a path through a free name that no declaration reaching it gives its fields to is not built yet'; Absent = @(); Debt = @() },
    # A value the translation has no layout for, under such a name, beside a caller whose Structure fits: admitted
    # where the reader's input is formed, when the program runs; refused there as the forming method's implicit
    # `implements`, before the reader is entered (7, 42, one entry).  The method that receives the letter stays
    # native where the methods are walked; the reader and the forming method are walked.
    [pscustomobject]@{ Name = 'unit_free_path_letter.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_letter_walk.lm2'; Source = 'unit_free_path_letter.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); NativeMethods = @(5); Absent = @(); Debt = @() },
    # Through an opaque formal and a typed reference: a letter is refused where the reference takes it (42); a
    # Structure made from a declaration reaches the name by that declaration, through the formal and the
    # reference (9).  The method with the reference stays native where the methods are walked.
    [pscustomobject]@{ Name = 'unit_free_path_typed_place.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_typed_place_walk.lm2'; Source = 'unit_free_path_typed_place.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); NativeMethods = @(2); Absent = @(); Debt = @() },
    # The same with a Structure made from Thin in the letter's place (RECEPTION-EDGE-DEBTS (d)): the edge to r
    # brings the Model too, so the Thin is refused when the program runs, 42, and the Model gives 9; until
    # 2026-10-05 the translation refused the Thin at far's call of r.
    [pscustomobject]@{ Name = 'unit_free_path_typed_place_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_typed_place_thin_walk.lm2'; Source = 'unit_free_path_typed_place_thin.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); NativeMethods = @(2); Absent = @(); Debt = @() },
    # Each method that reads through the name has its own uses: a method that hands the name on and reads
    # another field of it (341), a reader given a Structure without that other field (31).
    [pscustomobject]@{ Name = 'unit_free_path_two_readers.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_two_readers_walk.lm2'; Source = 'unit_free_path_two_readers.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # The path as the argument of a call and by its address (9135, 12145).
    [pscustomobject]@{ Name = 'unit_free_path_argument.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_argument_walk.lm2'; Source = 'unit_free_path_argument.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    # No ceiling on this route (Codex, the twenty-first reply: the translation's own tables are no place for an
    # arbitrary count or length).  The search for a coordinate space holds its candidates and the places it
    # reaches in storage sized from the program; a path's steps are joined and compared at their own length; the
    # tables of the admission by name grow.  Each row is past a count or a length the translator once stopped
    # at, and gives its real result.
    # Seventy declarations reach one name, at one call that forms the reader's input (64 candidates, 64 pairs).
    [pscustomobject]@{ Name = 'unit_free_path_many_declarations.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..71); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_many_declarations_walk.lm2'; Source = 'unit_free_path_many_declarations.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..71); Absent = @(); Debt = @() },
    # The name passes through 262 methods that only hand it on, two of them in a cycle (256 places; 128 edges;
    # 256 sources).
    [pscustomobject]@{ Name = 'unit_free_path_many_places.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..264); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_many_places_walk.lm2'; Source = 'unit_free_path_many_places.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..264); Absent = @(); Debt = @() },
    # A field whose name is 141 bytes long, read and written through the name (a 128-byte copy of a step).  A
    # Structure whose field has that name and one byte more has not the field (long_step_other_refused).
    [pscustomobject]@{ Name = 'unit_free_path_long_step.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_long_step_walk.lm2'; Source = 'unit_free_path_long_step.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_long_step_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_long_step_other_refused.lm2:24:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # The same for a declared formal.  The uses of a method were collected into 128 bytes, and a path that did
    # not fit was left out: a candidate without the long field was admitted (long_field_other_refused translated
    # before this step, and is refused now).
    [pscustomobject]@{ Name = 'unit_formal_long_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_long_field_walk.lm2'; Source = 'unit_formal_long_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_long_field_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_formal_long_field_other_refused.lm2:19:13: implements is false in function argument'; Absent = @(); Debt = @() },
    # No ceiling on the text of a path or a name (FIXED-BLOCKS-AUDIT; Codex, OPUS-CODEX-20261005-01 (2) B).  Names of
    # 600 bytes, a path of two of them over 1200 bytes: read and written through a declared formal, through a free
    # name and in the method that made the copy; a field of one such name, read also by its occurrence; an Array
    # field's element through its address and its length; a path read through a typed reference of such a name and
    # stored into a declared field (path_long_names).  A call through a path to a method's occurrence held by a
    # Structure of such a name (path_long_call).  A path of twenty names, past the walked path's table of twelve
    # (path_deep_names).  A typed reference that reads a path of
    # such a name receives by that use and admits a Structure without the field it does not read
    # (reference_long_path_coverage; its method receives natively).  True missing-field controls: a candidate
    # without the formal's field of such a name, and a returned Structure without the result model's field of such
    # a name -- this one translated before and stopped the process when it ran.
    [pscustomobject]@{ Name = 'unit_path_long_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0..6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_long_names_walk.lm2'; Source = 'unit_path_long_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,5,6); NativeMethods = @(4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_long_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0..2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_long_call_walk.lm2'; Source = 'unit_path_long_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_deep_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0..3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_deep_names_walk.lm2'; Source = 'unit_path_deep_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_reference_long_path_coverage.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_path_long_names_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_path_long_names_other_refused.lm2:18:9: implements is false in function argument'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_return_long_field_other_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_return_long_field_other_refused.lm2:17:1: implements is false in return value'; Absent = @(); Debt = @() },
    # A write through a free name of a path over 1200 bytes that nothing reaching the name gives its fields to: the
    # check of a path write passed a head of 1024 bytes or more over.
    [pscustomobject]@{ Name = 'unit_free_path_write_long_none_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_free_path_write_long_none_refused.lm2:10:5: a path through a free name that no declaration reaching it gives its fields to is not built yet'; Absent = @(); Debt = @() },
    # Seventy formals each filled with another declaration than its own (64 formals admitted by name).
    [pscustomobject]@{ Name = 'unit_formal_many_admitted.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..70); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_many_admitted_walk.lm2'; Source = 'unit_formal_many_admitted.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..70); Absent = @(); Debt = @() },
    # A declaration of seventy fields admitted to one with the same fields in the opposite order (a
    # correspondence of 128 cells).
    [pscustomobject]@{ Name = 'unit_formal_wide_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0..2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_formal_wide_model_walk.lm2'; Source = 'unit_formal_wide_model.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0..2); Absent = @(); Debt = @() },
    # A letter held in a place of its own declaration and admitted to a formal of another declaration by what
    # the formal's method reads (TYPED-PLACE-LETTER-READMISSION; Codex, FABLE-CODEX-20261004-12, the nineteenth
    # reply (b), and OPUS-HANDOFF-20261005-103112).  Where the input is formed, the letter's own record of its
    # reception by position (lmx_implements_identity) and the pair map of the two declarations give the formal's
    # fields; the declaration of a place is a possible anchor and no evidence.  Explicit actual, the same letter
    # twice and through a MainLetter formal (other); a hidden input (hidden); two opaque formals, a method that
    # hands it to itself and two that hand it to each other, then a Structure with a layout of its own at the
    # same sites (forward); a field the declaration has not, newly demanded after an admission that did not ask
    # for it: refused where the input is formed and caught, 42 (missing_field); the letter alone under a free
    # name, the typed reference's declaration the coordinate space (free_name); an untyped alias after a
    # binding (alias_after).  Where the methods are walked, the consumers that read a formal admitted by name
    # and the methods that receive the letter stay native; the methods that form the inputs are walked.
    [pscustomobject]@{ Name = 'unit_letter_place_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_other_walk.lm2'; Source = 'unit_letter_place_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1,2); NativeMethods = @(0,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_hidden.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_hidden_walk.lm2'; Source = 'unit_letter_place_hidden.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2,3,4,5,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_forward_walk.lm2'; Source = 'unit_letter_place_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1,2,3,4,5); NativeMethods = @(0,6); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_missing_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_missing_field_walk.lm2'; Source = 'unit_letter_place_missing_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Argv = @('a', 'b'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(2,3,4); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_free_name_walk.lm2'; Source = 'unit_letter_place_free_name.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Argv = @('a', 'b'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_alias_after.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_alias_after_walk.lm2'; Source = 'unit_letter_alias_after.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b');
        Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1,2); NativeMethods = @(0,3); Absent = @(); Debt = @() },
    # Two declarations whose records both answer for the letter (Codex's reply to OPUS-HANDOFF-20261005-103112:
    # a fixture probing multiple available anchors).  The letter is bound to a MainLetter and to an Other
    # reference, both handed to hop's opaque formal: both reach hop's place, both records answer where observe's
    # input is formed, and both give observe's one used path the same place of the value -- one class, the first
    # entry taken, 2 + n both times.  A disagreement on a used target cannot be built while the only value with
    # no layout of its own is the one-field argv letter; the walker's selftest has it.
    [pscustomobject]@{ Name = 'unit_letter_place_two_anchors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_letter_place_two_anchors_walk.lm2'; Source = 'unit_letter_place_two_anchors.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0');
        Argv = @('a', 'b'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(1); NativeMethods = @(0,2); Absent = @(); Debt = @() },
    # OPEN positive, required before G5 (OPUS-HANDOFF-20261005-103112, point 6).  The letter given untyped to a
    # Long formal before anything admitted it to MainLetter is valid by the consumer's uses, as it is after the
    # binding.  It has no record of a reception to ask, and a value with no layout of its own is still admitted
    # by position against the whole model: refused, red until that admission is by the consumer's uses.
    [pscustomobject]@{ Name = 'unit_letter_alias_before.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Argv = @('a', 'b'); Entry = 7;
        WalkRoot = $true; NativeMethods = @(0,1); Absent = @(); Debt = @() },
    # A path of two steps through the name (31, 42).
    [pscustomobject]@{ Name = 'unit_free_path_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_path_deep_walk.lm2'; Source = 'unit_free_path_deep.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    # The callable given to a callable formal is called with its own free names (CALLABLE-FORMAL-HIDDEN-CONTRACT,
    # K04; Codex, FABLE-CODEX-20261004-12).  The translator follows which methods reach each formal and the call
    # forms their list, never the list of the method that declares the formal: another name of the same count
    # (other), the caller's own binding first (override), more names and none (extra, none), a formal handed on
    # (forward).  What the callable needs is asked of the callers as any known requirement: through a chain of
    # methods (chain), through mutual recursion (mutual), through a callee that is itself a formal's value
    # (higher); a supplied zero is present (zero).  Natively: a consumer of a callable formal is not walked yet.
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_other.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_override.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_extra.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_none.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_mutual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_higher.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_zero.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    # A definition nothing consumes asks for nothing: a call of a callable formal that no call in the program
    # supplies translates, and the definition stays whole.
    [pscustomobject]@{ Name = 'unit_callable_formal_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    # A required input no one supplies: the call is inadmissible before entry and is refused where it stands.
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_callable_formal_free_names_missing_refused.lm2:25:8: unbound dynamic input zz'; Absent = @(); Debt = @() },
    # Two callables with one free name whose lexical declarations differ form their inputs alike: an input no
    # caller binds is handed absent and each reads its own (K04, the transport of an absent input).
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_lexical_differ.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    # The transport of an absent input (K04; Codex, FABLE-CODEX-20261004-12).  An input no caller binds is
    # handed absent (refs[k] = 0).  A method that only forwards the name hands the entry on as it is; the method
    # that reads it takes its own lexical source through its occurrence's parent, the native entry as the walked
    # body's ARG.  A supplied zero is present (forward).  A method that reads or assigns the name has it as its
    # working value and hands that on; the unit's field is not written (reader).  The root above a declaration
    # has no binding to hand (decl_order).  Each natively and with the methods walked.
    [pscustomobject]@{ Name = 'unit_absent_input_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_forward_walk.lm2'; Source = 'unit_absent_input_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_reader.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,5,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_reader_walk.lm2'; Source = 'unit_absent_input_reader.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,5,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_decl_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_decl_order_walk.lm2'; Source = 'unit_absent_input_decl_order.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # The absent input reaches the method that reads it, and that method reads its own lexical source, never the
    # source of a method that only handed the name on (K04 S2; Codex, FABLE-CODEX-20261004-12).  A definition
    # that only hands the name on, whose host method has a local of that name, called above the unit's
    # declaration (forward_host_local).  Two program parts with a root each: the reader of one, a forwarder of
    # the other, called from a source that declares no such name -- the reader's own root, 5, not the
    # forwarder's, 8 (parts).  Each natively and with the methods walked.
    [pscustomobject]@{ Name = 'unit_absent_input_forward_host_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_forward_host_local_walk.lm2'; Source = 'unit_absent_input_forward_host_local.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_parts.lm2'; Parts = @('unit_absent_input_parts_a.lm2', 'unit_absent_input_parts_b.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_absent_input_parts_walk.lm2'; Source = 'unit_absent_input_parts.lm2'; Parts = @('unit_absent_input_parts_a.lm2', 'unit_absent_input_parts_b.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkMethods = $true; WalkedMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    # A required input no one can give is refused at translation, where the chain starts: the root calls a held
    # definition that only hands the name on to a reader with no source of its own.  The local of the method that
    # made the definition is not the definition's to give.
    [pscustomobject]@{ Name = 'unit_absent_input_unavailable_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_absent_input_unavailable_refused.lm2:24:8: unbound dynamic input zz'; Absent = @(); Debt = @() },
    # Requirements by call site, and the formation by exact occurrence (K04 S2 part two; Codex,
    # FABLE-CODEX-20261004-12).  One callable formal receives callables with different free names: each call
    # forms the inputs of the callable it has (differ; the pin is the text of the class selection).  A site is
    # asked only for the names of the callable it gives: a caller without a name of another alternative is not
    # refused and hands that entry absent (site_names), through formals handed on and through a callee that is a
    # formal's value (site_names_forward), through mutual recursion (site_names_mutual), and where the name is
    # needed only while six formals hold six methods (site_conditions: no number of conditions is fixed).  A
    # consumer of a callable formal is not walked yet: natively.
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_differ.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @('int: l2_cfk') },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_names.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_names_forward.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_names_mutual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_conditions.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5,6,7,8,9); Absent = @(); Debt = @() },
    # The callable a site gives needs a name no one can give: refused where that site stands, and not where
    # another callable is given.
    [pscustomobject]@{ Name = 'unit_callable_formal_site_names_missing_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_callable_formal_site_names_missing_refused.lm2:27:8: unbound dynamic input zz'; Absent = @(); Debt = @() },
    # A held call asks its model's number names along the chain of callers, as a call of a method does (K04 S3;
    # Codex, FABLE-CODEX-20261004-12).  A name the model's reader requires, bound by the caller of the method
    # that makes the held call (required_input_from_caller).  A name of the method that made the definition is
    # the definition's free name, and the copied value its own source and no frozen binding: two copies each
    # read their own where no caller has the name; a caller's value, handed on through a method that only
    # forwards it, wins over both copies; a nearer binding wins over a farther one; a present zero is present
    # (free_name_chain).  A method that assigns the name hands its working value on and the unit's field is not
    # written (free_name_working).  An explicit read of the node keeps the copied value whatever the callers
    # give (free_name_node).  Each natively and with the methods walked.
    [pscustomobject]@{ Name = 'unit_held_call_required_input_from_caller.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_required_input_from_caller_walk.lm2'; Source = 'unit_held_call_required_input_from_caller.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,3,4,5); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_chain_walk.lm2'; Source = 'unit_held_call_free_name_chain.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3,4,5,6,7,8); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_working.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_working_walk.lm2'; Source = 'unit_held_call_free_name_working.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_node_walk.lm2'; Source = 'unit_held_call_free_name_node.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2,3); Absent = @(); Debt = @() },
    # A name a held definition requires that no one can give: refused at the root's call of the method that
    # makes the held call, where the chain starts.
    [pscustomobject]@{ Name = 'unit_held_call_required_input_unavailable_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_required_input_unavailable_refused.lm2:28:8: unbound dynamic input zz'; Absent = @(); Debt = @() },
    # The same with nothing to type zz (DORMANT-BODY-FREE-INPUT: one admission rule for an input with a type and
    # one without): the root's call of inner, and the root's own held call, are refused where the chain starts;
    # until 2026-10-05 the closure said "unresolved name" at r's zz.
    [pscustomobject]@{ Name = 'unit_held_call_untyped_input_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_untyped_input_refused.lm2:21:8: unbound dynamic input zz'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_untyped_root_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_held_call_untyped_root_refused.lm2:14:9: unbound dynamic input zz'; Absent = @(); Debt = @() },
    # A reference among the names of a callable a site does not give is left out, as a number is: whether an
    # input is formed does not depend on how it is represented.  Through a method that only hands the callable
    # on, the reference left out stays absent (site_reference_forwarded).  A caller whose own Structure under
    # the name has no field the other callable reads gives the callable that does not read it: its Structure
    # is neither asked nor admitted to the other's use (site_reference_unasked: 10, with 22 and 7 beside it).
    [pscustomobject]@{ Name = 'unit_callable_formal_site_names_reference.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_reference_forwarded.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_site_reference_unasked.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3,4,5); Absent = @(); Debt = @() },
    # HELD-FREE-NAME-OTHER-TYPE: a caller's value of another numeric type for a held definition's free name is
    # converted by the call that hands it, by the ordinary row (the receivers are the program's: convert_impl);
    # absent, it stays absent and the definition reads its own copy.  A value handed on keeps its type and its
    # presence: an untaken conversion does not run, a taken one's refusal is the forming caller's catchable
    # `convert`, a present zero is read.  Natively, and with the methods walked through the presence guard.
    [pscustomobject]@{ Name = 'unit_held_call_free_name_converted.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_converted_walk.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(4,5);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_untaken.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_untaken_walk.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(4,5,6,7,8);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_own_binding.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_held_call_free_name_own_binding_walk.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(2,3);
        Absent = @(); Debt = @() },
    # OPEN positives, required before G5.  Limits of this implementation and no rules; each is refused where it
    # stands and stays red until built.  A method that only hands a name on has one type for it, so a second
    # caller binding it as another type is refused (FORWARDER-BINDINGS-OF-TWO-TYPES, two_types).  A merge built
    # as the actual reaching a formal handed on, where a method formed differently reaches it too: the node a
    # merge builds is no occurrence of the unit, and its class is not told where the formal is called
    # (unfollowed_actual).  A library unit's callable formal: every method of a library unit has an exported
    # wrapper, so an occurrence from another translation can reach the formal.
    [pscustomobject]@{ Name = 'unit_held_call_free_name_two_types.lm2'; Parts = @('convert_impl.lm2'); Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_unfollowed_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_lib_callable_formal.lm2'; Expect = 'library-links'; Exit = 0; Needle = '';
        With = @(); Exports = @('lib_cf_run', 'lib_cf_use'); Absent = @(); Debt = @() },
    # The actual is the method that declares the formal.  Its free name takes the caller's binding, else the
    # lexical source.  With the methods walked a callable formal is outside the walkable subset (the limit row
    # unit_walk_methods_callable_formal_refused): that is debt of the implementation and no rule, and the walked
    # twin is an OPEN positive, red.
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_self.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_free_names_self_walk.lm2'; Source = 'unit_callable_formal_free_names_self.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_callable_formal_statement_controls.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7); Absent = @(); Debt = @() },
    # A throw raised while an actual is evaluated (found beside the named actuals, and no matter of them):
    # it reaches the caller's handler with the payload it was thrown with, and neither the actuals after it
    # nor the callee run.  With the methods walked the outer CALL or PRIM used to replace the payload with
    # its own empty result and to apply its own catch rows to a throw that was not its callee's; the run
    # stopped at the kernel's "catch payload" invariant.  Controls: the same throw returned directly and
    # through a local.  Cases: an actual of a call, of an actual, of a named call inside a named call, between
    # two marked actuals (the trace says which ran), of a held callable's call (a PRIM), and of a callee
    # with a throw name of its own inside a block that catches both names (the outer call's row would
    # send the throw to the other handler: 53).  boom and wide keep their native word in the walked row:
    # a throw with a payload is machine text.  Kernel mutants (lmx_walk_catch_selftest kills all six;
    # this fixture's walked row in an isolated copy): the old code and the payload replaced, for CALL and
    # for PRIM -- the "catch payload" invariant, exit 3; the CALL's rows applied -- exit 89; the PRIM's
    # rows applied -- the selftest alone.
    [pscustomobject]@{ Name = 'unit_throw_nested_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        NativeMethods = @(0,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_throw_nested_actual_walk.lm2'; Source = 'unit_throw_nested_actual.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1,2,3,5,6,7,8,9,10,11,12,14,16,17); NativeMethods = @(4,15); Absent = @(); Debt = @() },
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
    # Cached first value2 and later explicit published field5 must yield25.
    [pscustomobject]@{ Name = 'unit_cache_struct_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 25;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_cache_struct_ref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 25; WalkMethods = $true; WalkedMethods = @(0,1,2);
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
    # Explicit merge copies a completed local definition and its callable state.
    # A shallow callable alias gives 1/2/3/4 instead of 1/1/2/2.
    [pscustomobject]@{ Name = 'unit_local_callable_explicit_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_callable_explicit_copy_walk.lm2'; Source = 'unit_local_callable_explicit_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    # Each registered source body resolves its own names; control bodies remain
    # in that method. Both twins execute the same source, including named actuals.
    [pscustomobject]@{ Name = 'unit_named_until_field_place.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_until_field_place_walk.lm2'; Source = 'unit_named_until_field_place.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_until_canonical_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_until_canonical_copy_walk.lm2'; Source = 'unit_named_until_canonical_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_until_copy_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_named_until_copy_call_walk.lm2'; Source = 'unit_named_until_copy_call.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # The call of a copy forms the hidden inputs of the body that copy holds:
    # A needs x, B needs y, same type and position. Natively and with both
    # procedures walked. A contract taken from another row's declaration would
    # hand rb the caller's x and exit 82.
    [pscustomobject]@{ Name = 'unit_copy_call_hidden_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalCopyCallPaths; Entry = 7; WalkRoot = $true; NativeRoot = 2; NativeMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_hidden_inputs_walk.lm2'; Source = 'unit_copy_call_hidden_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalCopyCallPaths; Entry = 7; WalkRoot = $true; NativeRoot = 2; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_hidden_inputs_input_mutant.lm2'; Source = 'unit_copy_call_hidden_inputs.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','2','14','5') + $criticalCopyCallPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_hidden_inputs_target_mutant.lm2'; Source = 'unit_copy_call_hidden_inputs.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','2','16','2') + $criticalCopyCallPaths; Entry = 7; Absent = @(); Debt = @() },
    # A genuinely missing input: the copied body needs z, which neither the
    # caller nor the copy's lexical parent has. Refused, located at the name.
    [pscustomobject]@{ Name = 'unit_copy_call_missing_input_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_copy_call_missing_input_refused.lm2:8:1: unbound dynamic input z'; Absent = @(); Debt = @() },
    # OPEN positive, red by design: a valid program whose copy's own row is
    # addressed before the call. The translator cannot yet prove the row's
    # current value and refuses the call as unsupported; the row stays a
    # required positive until the general actual-call boundary exists.
    [pscustomobject]@{ Name = 'unit_copy_call_addressed.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # OPEN positives, red by design: two more valid calls of a held copy whose
    # contract the translator cannot prove yet. Each is refused as unsupported
    # at its call; neither is an expected language refusal.
    [pscustomobject]@{ Name = 'unit_copy_call_from_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_other_owner.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    # The body a called copy holds, proved through more than one declaration: a
    # copy of a method's own Structure and a copy of a copy. Natively and walked.
    # Under --walk-methods the procedure of a method's own Structure keeps its
    # native word: the walked twin runs the method's EXEC in the interpreter and
    # the copied body natively, and says so.
    [pscustomobject]@{ Name = 'unit_copy_call_local_structure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; NativeMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_local_structure_walk.lm2'; Source = 'unit_copy_call_local_structure.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_of_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeMethods = @(0);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_of_copy_walk.lm2'; Source = 'unit_copy_call_of_copy.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0);
        Absent = @(); Debt = @() },
    # The chain with its inputs: rc is a copy of rb, rb of ra, ra of A; h copies
    # and calls its own C. A reads the free x and writes the unit's seen through
    # node, C reads the free x and h's base through node. Each call forms the
    # inputs from its caller -- h's local x, the root's changed x -- and runs
    # the called copy alone. A contract or a target taken from another row of
    # the chain exits 81 or 83; a copy that ran C itself, 82.
    [pscustomobject]@{ Name = 'unit_copy_call_chain_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalCopyChainPaths; Entry = 7; WalkRoot = $true; NativeMethods = @(0,1,2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_chain_inputs_walk.lm2'; Source = 'unit_copy_call_chain_inputs.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0') + $criticalCopyChainPaths; Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); NativeMethods = @(2);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_chain_inputs_source_mutant.lm2'; Source = 'unit_copy_call_chain_inputs.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','7','2','7') + $criticalCopyChainPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_copy_call_chain_inputs_target_mutant.lm2'; Source = 'unit_copy_call_chain_inputs.lm2'; Expect = 'shape-mutant'; Exit = 1; Needle = '';
        Args = @('0','mutate','null-path','3','8','8','2') + $criticalCopyChainPaths; Entry = 7; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_source_binding_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; NativeMethods = @(0,1,2,4);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_source_binding_context_walk.lm2'; Source = 'unit_local_source_binding_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 3; WalkMethods = $true; WalkedMethods = @(0,1,2,4);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_source_merge_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; NativeMethods = @(0,2,3);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_local_source_merge_context_walk.lm2'; Source = 'unit_local_source_merge_context.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; NativeRoot = 1; WalkMethods = $true; WalkedMethods = @(0,2,3);
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
    # Historical write-only fixtures: peek has no established input k, so its
    # unknown k:1 defines a Structure. Their exit alone does not prove hidden
    # assignment. The exact literal graph and established-input opposites
    # below distinguish those cases; caller spelling alone is insufficient.
    [pscustomobject]@{ Name = 'unit_free_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_write.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkMethods = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_free_write_literal_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = $criticalLiteralUnknownInput; Entry = 7; WalkRoot = $true; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_free_write_literal_refused.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; WalkMethods = $true;
        Args = $criticalLiteralUnknownInput; Entry = 7; WalkRoot = $true; WalkedMethods = @(0,1); Absent = @(); Debt = @() },
    # Unlike the old unknown-head row, these have an established primitive
    # binding. A literal write changes the callee's input, not a graph field.
    [pscustomobject]@{ Name = 'unit_graph_hidden_literal_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_graph_walk_hidden_literal_binding.lm2'; Source = 'unit_graph_hidden_literal_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_graph_formal_literal_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true;
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_graph_walk_formal_literal_binding.lm2'; Source = 'unit_graph_formal_literal_binding.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7; WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1);
        Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_graph_hidden_literal_no_field.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_graph_hidden_literal_no_field.lm2:7:11: unresolved name'; Absent = @(); Debt = @() },
    # HEAD-ROLE-UNESTABLISHED-ROWS (the author, 2026-10-05): a head `h: tail` is established by a formal, by a
    # declaration in sight, or by a read of h as a free name before the statement; then the statement assigns the
    # method's input, in its activation only.  The read is found by the scan of free names, run as a probe that
    # makes nothing and ends at the statement (l2_head_read_before).  A head nothing established defines a named
    # Structure: the statement's own tail, a later read, a caller's value of the same name, a named actual's
    # label, a dormant body and a declaration out of sight establish nothing.  The walked twins walk the method
    # whose head is written (its caller prints, and a C door keeps a method native).
    [pscustomobject]@{ Name = 'unit_head_established_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_established_read.lm2'; Source = 'unit_head_established_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_established_lexical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4 0'); NativeMethods = @(0,1,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_established_lexical.lm2'; Source = 'unit_head_established_lexical.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4 0'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,1); NativeMethods = @(2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_block_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_block_read.lm2'; Source = 'unit_head_block_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_initializer_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_initializer_read.lm2'; Source = 'unit_head_initializer_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_chain_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 13 4 4'); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_chain_read.lm2'; Source = 'unit_head_chain_read.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 13 4 4'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_unestablished_return_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_head_unestablished_return_refused.lm2:9:13: return value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_later_read_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_head_later_read_refused.lm2:8:12: a reference where a number is asked'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_label_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_head_label_refused.lm2:17:13: return value has incompatible type'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_head_shadow_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_head_shadow_refused.lm2:12:13: return value has incompatible type'; Absent = @(); Debt = @() },
    # The read is found past an empty definition: `note()` defines a named Structure, whose row the collection
    # makes before it asks the role of the head below it; the probe passes that statement and makes nothing.
    [pscustomobject]@{ Name = 'unit_head_after_empty_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); NativeMethods = @(0,2); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_head_after_empty_decl.lm2'; Source = 'unit_head_after_empty_decl.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 5 4'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0); NativeMethods = @(2); Absent = @(); Debt = @() },
    # OPEN, required before G5 (Codex, OPUS-CODEX-20261005-01, the HEAD checkpoint review): a limit of this
    # implementation and no rule, red until built (DORMANT-BODY-FREE-INPUT).  A named body never executed keeps
    # its free names (#construction): `y: z + 1` in make, nothing binds z, nothing calls y, make returns 7 and the
    # root says MADE 7.  The translator gives the body its own callable row with the input z, and types every
    # input of every row at the closure (l2_dyn_typed): z has no type, and the definition is refused at its
    # free name, 7:8 unresolved name.  With y called and no source of z the call fails, where the chain starts
    # (the root's call of make, as unit_held_call_required_input_unavailable_refused); today the definition is
    # refused first, 8:8.
    [pscustomobject]@{ Name = 'unit_dormant_free_body.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('MADE 7'); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_dormant_free_body_call_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_dormant_free_body_call_refused.lm2:13:10: unbound dynamic input z'; Absent = @(); Debt = @() },
    # FACTORY (FACTORY-RESULT-RECEIVER; the author, 2026-10-05; docs/LMX_semantics.en.md#factory-reference-result):
    # the receiver `@: h f(a)` evaluates the written call and stores the reference to the callable it returns; the
    # call binds its actuals as any call does, a named one included (receiver_named, in a method).  An unknown head
    # whose tail begins with a known method defines a named Structure and executes nothing, in every spelling
    # (short_dormant: neither `s: shout` nor `t: shout()` prints, natively and with the root and the methods walked;
    # the block spelling is unit_named_struct_call_body_retained); a bare method name in that body is its
    # application with no actual, and a method that requires one is refused in the body where it stands
    # (short_args_refused, the check of any call that misses a required argument).
    [pscustomobject]@{ Name = 'unit_factory_receiver_named.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 101 7'); NativeMethods = @(0,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_factory_receiver_named.lm2'; Source = 'unit_factory_receiver_named.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('OUTER 101 7'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(0,2); NativeMethods = @(3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_factory_short_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('DONE'); NativeMethods = @(0,1,2,3); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_walk_factory_short_dormant.lm2'; Source = 'unit_factory_short_dormant.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = ''; Args = @('0'); Entry = 7;
        Says = @('DONE'); WalkRoot = $true; WalkMethods = $true; WalkedMethods = @(2,3); NativeMethods = @(0,1); Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_factory_short_args_refused.lm2'; Expect = 'l2trans-refuses'; Exit = 0;
        Needle = 'unit_factory_short_args_refused.lm2:11:7: incompatible entry signature'; Absent = @(); Debt = @() },
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
    } elseif ($fx.PSObject.Properties['Source'] -and $fx.Source) {
        # A mutation row uses the exact same source bytes as its positive row;
        # only the driver's graph mutation and expected verdict differ.
        $source = Join-Path $sandbox ('tests\' + $fx.Source)
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
    if ($fx.Expect -eq 'eternal-runs' -or $fx.Expect -eq 'send-abort' -or $fx.Expect -eq 'walk-x1' -or $fx.Expect -eq 'shape-mutant') {
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

    if ($fx.Expect -eq 'eternal-runs' -or $fx.Expect -eq 'send-abort' -or $fx.Expect -eq 'walk-x1' -or $fx.Expect -eq 'shape-mutant') {
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
        # Explicit fixture support closure. No source-name dispatch, inferred
        # library search or prebuilt fallback: each listed body is translated
        # from this run's staged bytes and compiled with the same C flags.
        $linkObjects = @($driverO, $genO, $l2libcO)
        $supportFailed = $false
        if ($fx.PSObject.Properties['LinkSources']) {
            $supportIndex = 0
            foreach ($support in $fx.LinkSources) {
                $supportLabel = 'fixture.' + $stem + '.support' + $supportIndex
                $supportC = Join-Path $gen ($stem + '.support' + $supportIndex + '.c')
                $supportO = Join-Path $gen ($stem + '.support' + $supportIndex + '.o')
                if (-not (Test-Path -LiteralPath (Join-Path $src $support)) -or
                    -not (Step-Made ($supportLabel + '.translate') $Translator @($support, $supportC) $src $supportC)) {
                    Add-Row 'FAIL' ('fixture:' + $stem) ('support body did not translate: ' + $support)
                    $supportFailed = $true; break
                }
                $code = Invoke-Step ($supportLabel + '.compile') $gcc ($fixtureFlags + @('-c', $supportC, '-o', $supportO)) $root
                if ($code -ne 0 -or -not (Test-Path -LiteralPath $supportO)) {
                    Add-Row 'FAIL' ('fixture:' + $stem) ('support body did not compile: ' + $support)
                    $supportFailed = $true; break
                }
                $linkObjects += $supportO
                $supportIndex++
            }
        }
        if ($supportFailed) { continue }
        $code = Invoke-Step ('fixture.' + $stem + '.link') $gcc (@('-o', $exe) + $linkObjects) $root
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
        if ($fx.Expect -eq 'shape-mutant') {
            $mlog = Log-Text ('fixture.' + $stem + '.run')
            $facts = @($mlog -split "`r?`n" | Where-Object { $_ -match '^l2_eternal_driver: graph_shape ' })
            $factPattern = '^l2_eternal_driver: graph_shape mutation=(\d+) baseline=(\d+) setup=(\d+) compared=(\d+) setup_failures=(\d+) shape_failures=(\d+) other_failures=(\d+) exit=(-?\d+) expected=(-?\d+)$'
            if ($facts.Count -ne 1 -or $facts[0] -notmatch $factPattern) {
                Add-Row 'FAIL' ('fixture:' + $stem) 'missing unique structured graph-comparison evidence'
                continue
            }
            $mutation = [int]$Matches[1]; $baseline = [int]$Matches[2]; $setup = [int]$Matches[3]
            $compared = [int]$Matches[4]; $setupFailures = [int]$Matches[5]; $shapeFailures = [int]$Matches[6]
            $otherFailures = [int]$Matches[7]; $programExit = [int]$Matches[8]; $expectedExit = [int]$Matches[9]
            $entryExit = 0
            if ($fx.PSObject.Properties['Entry']) { $entryExit = [int]$fx.Entry }
            $sameExit = $ran -eq 1 -and $compared -eq 1 -and $otherFailures -eq 0 -and $programExit -eq $entryExit -and $expectedExit -eq $entryExit
            $detected = $sameExit -and $mutation -eq 1 -and $baseline -eq 1 -and $setup -eq 1 -and $setupFailures -eq 0 -and $shapeFailures -gt 0
            if ($fx.PSObject.Properties['MutationSetupMiss'] -and $fx.MutationSetupMiss) {
                if ($detected -or -not ($sameExit -and $mutation -eq 1 -and $baseline -eq 1 -and $setup -eq 0 -and $setupFailures -gt 0 -and $shapeFailures -eq 0)) {
                    Add-Row 'FAIL' ('fixture:' + $stem) 'missing-setup control did not reject false structural detection'
                    continue
                }
                Add-Row 'OK' ('fixture:' + $stem) 'setup failed; unchanged graph matched; rejected as structural detection'
                continue
            }
            if ($fx.PSObject.Properties['SourceOrderNegative'] -and $fx.SourceOrderNegative) {
                if ($detected -or -not ($sameExit -and $mutation -eq 0 -and $setup -eq 0 -and $setupFailures -eq 0 -and $shapeFailures -gt 0)) {
                    Add-Row 'FAIL' ('fixture:' + $stem) 'source-order negative control did not isolate the comparison failure'
                    continue
                }
                Add-Row 'OK' ('fixture:' + $stem) 'different source order rejected by comparison; no graph mutation claimed'
                continue
            }
            if (-not $detected) { Add-Row 'FAIL' ('fixture:' + $stem) ('graph mutant lacks successful baseline/setup and isolated comparison failure; driver exit ' + $ran); continue }
            Add-Row 'OK' ('fixture:' + $stem) 'baseline matched; mutation applied; structural comparison failed; same program exit'
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
        if ($fx.PSObject.Properties['Says']) {
            # Read physical line records: a blank program line is real output, while
            # splitting Raw text also invents a trailing empty record at final newline.
            $outputLog = Join-Path $logs ((Safe ('fixture.' + $stem + '.run')) + '.log')
            $printed = @(Get-Content -LiteralPath $outputLog | Where-Object { $_ -notmatch '^(command: |cwd: |exit: |l2_eternal_driver: )' -and $_ -notmatch '^﻿?command: ' })
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
        if ($fx.PSObject.Properties['Says']) { $what = ', said its ' + $fx.Says.Count + ' lines exactly (' }
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
