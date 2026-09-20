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
#
# NEITHER TRANSLATOR SETS AN EXIT CODE ON A DIAGNOSTIC -- both print and return 0 (measured).  So
# a step here counts as done only if its OUTPUT FILE was produced, and the printed text is what
# names the reason when it was not.  Reading the exit code alone would call every refusal a pass.
#
# Artifacts go under build\, which is ignored; nothing here writes into the source tree, and
# nothing here reads C:\Nyasha_Planet\L1.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\l2_harness.ps1

param([string]$OutDir, [string]$Translator)
$ErrorActionPreference = 'Continue'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sandbox = Join-Path $root 'dev\l2src_sandbox'
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

$src = Join-Path $OutDir 'src'
$gen = Join-Path $OutDir 'gen'
$bin = Join-Path $OutDir 'bin'
$logs = Join-Path $OutDir 'logs'
foreach ($d in @($src, (Join-Path $src 'l2src'), (Join-Path $src 'l1src'), $gen, $bin, $logs)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
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
    $log = Join-Path $logs ((Safe $Label) + '.log')
    $here = (Get-Location).Path
    Set-Location $WorkDir
    $text = & $Exe @ArgList 2>&1 | Out-String
    $code = $LASTEXITCODE
    Set-Location $here
    $head = 'command: "' + $Exe + '" ' + ($ArgList -join ' ') + [Environment]::NewLine + 'cwd: ' + $WorkDir + [Environment]::NewLine + 'exit: ' + $code + [Environment]::NewLine
    Set-Content -LiteralPath $log -Value ($head + $text) -Encoding utf8
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
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l2src\' + $f.Name)) -Force; $staged++
}
foreach ($f in @(Get-ChildItem -LiteralPath (Join-Path $sandbox 'l1src') -File)) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $src ('l1src\' + $f.Name)) -Force; $staged++
}
Write-Output ('l2_harness: staged ' + $staged + ' files into ' + $src)

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
    Write-Output ''
    Write-Output ('l2_harness RED: l2trans itself did not build; evidence ' + $OutDir)
    exit 1
}

# ---- 3. the fixtures ------------------------------------------------------------------------
# `Expect` says how far this fixture is supposed to get, and each value is a claim about the
# translator, not about this script:
#   runs                 -- the whole chain, and the program's exit code is Exit.
#   l2trans-refuses      -- l2trans must REFUSE it; Needle must appear in what it printed.
#   translates-with-debt -- the whole translator chain succeeds, AND the generated L1 is then
#                           read: every string in Absent must be GONE from it and every string
#                           in Debt must still be THERE.  This is for a gap that no longer stops
#                           the toolchain but is not fixed, and the asymmetry is the point.
#
# WHY THIS FIXTURE READS THE GENERATED L1 AND NOT AN EXIT CODE.  A program whose eternal
# branch sits in the ordinary Message arena compiles and exits 0 exactly like one whose branch
# is in the permanent store: the difference is WHICH ARENA OWNS THE ADDRESS, and no exit code
# can see it.  So this fixture names both sides.  Absent are the strings that meant the old
# world; Debt is what must still be there, and it is written to be SPECIFIC -- the first
# version of this row asked only for "lmx_node_new_owned(l2_program_arena)" and passed while
# the emission had already moved, because the PROGRAM UNIT is built with that same call and
# always will be.  A needle that matches a line which is correct forever measures nothing.
#
# The rows now pin, by exact text: the eternal root, its reference slots and its cells built in
# lmx_perm_store_of(l2_program_arena); the program unit still built in l2_program_arena, which
# is the same-shape mutable control and must NOT move; and the one debt that genuinely remains,
# the branch not yet entered in R0's retention array.
#
# WHAT THIS STILL DOES NOT PROVE, exactly: that the generated branch classifies from a SECOND
# bound Message arena, that lmx_range_pool is null there, and that a collection leaves the
# store's bytes alone.  Those three are proven for the store itself by
# dev/l2src_sandbox/tests/lmx_perm_selftest.lm1 (60 checks), but not yet on a GENERATED
# program, and the reason is mechanical rather than semantic: generated C includes
# l2src/<unit>.lm1.h and must link the kernel's resolved object closure, so running one needs
# the symbol-by-symbol resolver that tools/build_l2src.ps1 already has at Resolve-Link. Sharing
# that resolver -- not copying it -- is the next step, and until it exists this row says what
# it checked and no more.
$fixtures = @(
    [pscustomobject]@{ Name = 'entry_return7.lm2'; Expect = 'runs'; Exit = 7; Needle = ''; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_eternal_branch.lm2'; Expect = 'translates-with-debt'; Exit = 0; Needle = '';
        Absent = @('lmx_owned_ranges',
                   'DEBT: eternal ranges/bootstrap-admit absent in new kernel',
                   'DEBT: eternal bootstrap-admit / eternal-ranges absent',
                   'DEBT: eternal array bootstrap-admit / eternal-ranges absent',
                   'l2_nsp[0]: lmx_node_new_owned(l2_program_arena)');
        Debt = @('predef: "l2src/lmx_perm.h.lm1"',
                 'l2_nsp[0]: lmx_node_new_owned(lmx_perm_store_of(l2_program_arena))',
                 'lmx_arena_refs_open_owned(lmx_perm_store_of(l2_program_arena), l2_nsp[0], 1U)',
                 'slot[0]: lmx_size_new_owned(lmx_perm_store_of(l2_program_arena))',
                 'unit: lmx_node_new_owned(l2_program_arena)',
                 'DEBT: nsp 0 is IN the permanent store, but not yet in R0''s retention array (49U)',
                 'lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 0U, 0U)') }
)

foreach ($fx in $fixtures) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($fx.Name)
    $source = Join-Path $sandbox ('tests\' + $fx.Name)
    if (-not (Test-Path -LiteralPath $source)) { Add-Row 'FAIL' ('fixture:' + $stem) 'fixture file is missing'; continue }
    $genLm1 = Join-Path $gen ($stem + '.lm1')
    $label = 'fixture.' + $stem + '.l2trans'
    $made = Step-Made $label $l2trans @($source, $genLm1) $src $genLm1

    if ($fx.Expect -eq 'l2trans-refuses') {
        if ($made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans ACCEPTED a fixture that must be refused'; continue }
        if ((Log-Text $label) -notmatch [regex]::Escape($fx.Needle)) { Add-Row 'FAIL' ('fixture:' + $stem) ('refused, but not with "' + $fx.Needle + '"'); continue }
        Add-Row 'OK' ('fixture:' + $stem) ('refused as expected: ' + $fx.Needle); continue
    }
    if (-not $made) { Add-Row 'FAIL' ('fixture:' + $stem) 'l2trans produced no L1; see the log'; continue }

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
        Add-Row 'OK' ('fixture:' + $stem) ('eternal in the store, mutable unmoved (' + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden)'); continue
    }
    if (-not $made2) { Add-Row 'FAIL' ('fixture:' + $stem) 'l1trans produced no C from the generated L1; see the log'; continue }

    $exe = Join-Path $bin ($stem + '.exe')
    $code = Invoke-Step ('fixture.' + $stem + '.compile') $gcc ($cflags + @('-o', $exe, $genC)) $root
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) { Add-Row 'FAIL' ('fixture:' + $stem) "gcc exit $code"; continue }
    $ran = Invoke-Step ('fixture.' + $stem + '.run') $exe @() $bin
    if ($ran -ne $fx.Exit) { Add-Row 'FAIL' ('fixture:' + $stem) ('ran, exit ' + $ran + ', expected ' + $fx.Exit); continue }
    Add-Row 'OK' ('fixture:' + $stem) ('end to end, exit ' + $ran)
}

foreach ($r in $rows) { Write-Output ($r.State.PadRight(5) + $r.Label.PadRight(34) + $r.Note) }
Write-Output ''
if ($red.Count -eq 0) {
    Write-Output ('l2_harness GREEN: ' + $rows.Count + ' targets, no failures; evidence ' + $OutDir)
    exit 0
}
Write-Output ('l2_harness RED: ' + $red.Count + ' of ' + $rows.Count + ' targets failed; evidence ' + $OutDir)
exit 1
