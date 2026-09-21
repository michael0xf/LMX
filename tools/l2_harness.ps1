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

# ---- 2b. the kernel's headers and the driver of generated programs ----------------------------
# Generated C says #include "l2src/<unit>.lm1.h": every staged header is translated once, to
# <out>\headers\l2src\.  The driver is staged NEXT TO l2src\, not inside it: it is not a unit.
$headers = Join-Path $OutDir 'headers'
New-Item -ItemType Directory -Force -Path (Join-Path $headers 'l2src') | Out-Null
$kflags = @('-std=c99', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $src, '-I', $headers)
$driverSource = Join-Path $sandbox 'harness\l2_eternal_driver.lm1'
$driverC = Join-Path $gen 'l2_eternal_driver.c'
$driverO = Join-Path $gen 'l2_eternal_driver.o'
$driver = $true
$made = 0
foreach ($h in @(Get-ChildItem -LiteralPath (Join-Path $src 'l2src') -File -Filter '*.h.lm1' | Sort-Object Name)) {
    $base = $h.Name.Substring(0, $h.Name.Length - '.h.lm1'.Length)
    $target = Join-Path $headers ('l2src\' + $base + '.lm1.h')
    if (Step-Made ('header.' + $base) $Translator @(('l2src/' + $h.Name), $target) $src $target) { $made++ }
    else { Add-Row 'FAIL' ('header:' + $base) 'l1trans produced no header; see the log'; $driver = $false }
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
#   runs                 -- the whole chain, and the program's exit code is Exit.
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
#
# WHY THESE ROWS READ THE GENERATED L1 AS WELL AS RUN IT.  A program whose eternal branch sits
# in the ordinary Message arena compiles and exits 0 exactly like one whose branch is in the
# permanent store: the difference is WHICH ARENA OWNS THE ADDRESS.  The driver sees that from
# outside; the text pins HOW it came about -- and both are written to be SPECIFIC.  The first
# version of the text row asked only for "lmx_node_new_owned(l2_program_arena)" and passed while
# the emission had already moved, because the PROGRAM UNIT is built with that same call and
# always will be.  A needle that matches a line which is correct forever measures nothing.
#
# The text pins: the eternal root, its reference slots and its cells built in
# lmx_perm_store_of(l2_program_arena); the program unit still built in l2_program_arena, which
# is the same-shape mutable control and must NOT move; R0's eternal array sized with the COUNT
# of roots in lmx_root_open (FABLE-L2-R0-RETENTION-20260920-01 -- the method capacity beside it
# stays 0U, that contract is not this one); the array reached by one reference read from the
# graph the entry is handed; and each root stored into its own entry by its physical address.
# Forbidden: the old world's strings, the 49U debt line, and the unsized lmx_root_open.
#
# The run proves, on the GENERATED program and from outside it: the capacity is the count and
# not zero; R0's graph holds the array's address; the array and every root are owned by the
# store, are Structures by R0's ranges, are not owned by R0's arena, and have node = 0; the
# declared values identify each entry as THAT branch, in lexical order; a reference field that
# names a branch IS the retained root's address and a cross-reference IS the other branch's
# member; a collection over R0's arena -- instrument first -- leaves the store byte for byte and
# every entry the same physical root; and the invariants still hold after a further turn.
#
# WHAT THIS STILL DOES NOT PROVE, exactly: that the generated branch classifies from a SECOND
# bound Message arena (dev/l2src_sandbox/tests/lmx_perm_selftest.lm1 and
# tests/lmx_walk_perm_selftest.lm1 prove that for the store, not on a generated program: a
# generated program has no second Message yet).  And one thing the driver PRINTS rather than
# asserts, because it is a debt of the entry and not of retention: a further turn of R0 runs
# the generated entry AGAIN, which builds the branches again in the store and republishes new
# roots.  The generated main takes exactly one turn, so it is latent today.
#
# Sharing tools/build_l2src.ps1's Resolve-Link with this script is still the way to run a
# generated program against the kernel's separate OBJECTS; the driver does not replace that, it
# makes the question answerable before it exists.
$fixtures = @(
    [pscustomobject]@{ Name = 'entry_return7.lm2'; Expect = 'runs'; Exit = 7; Needle = ''; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'entry_ret_tr_bad.lm2'; Expect = 'l2trans-refuses'; Exit = 0; Needle = 'unsupported body'; Absent = @(); Debt = @() },
    [pscustomobject]@{ Name = 'unit_eternal_branch.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('1', 'size', '0', '0', '7');
        Absent = @('lmx_owned_ranges',
                   'DEBT: eternal ranges/bootstrap-admit absent in new kernel',
                   'DEBT: eternal bootstrap-admit / eternal-ranges absent',
                   'DEBT: eternal array bootstrap-admit / eternal-ranges absent',
                   'l2_nsp[0]: lmx_node_new_owned(l2_program_arena)',
                   'not yet in R0''s retention array',
                   'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('predef: "l2src/lmx_perm.h.lm1"',
                 'l2_nsp[0]: lmx_node_new_owned(lmx_perm_store_of(l2_program_arena))',
                 'lmx_arena_refs_open_owned(lmx_perm_store_of(l2_program_arena), l2_nsp[0], 1U)',
                 'slot[0]: lmx_size_new_owned(lmx_perm_store_of(l2_program_arena))',
                 'unit: lmx_node_new_owned(l2_program_arena)',
                 'lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 1U, 0U)',
                 'l2_retained: lmx_arena_ref_struct(node, c.LMX_ROOT_ETERNAL_SLOT)',
                 'if: l2_retained\len != 1',
                 'if: lmx_arena_ref_store(l2_retained, 0U, (cast: (@: void) l2_nsp[0])) != 0',
                 'if: lmx_arena_ref_value(l2_retained, 0U) != (cast: (@: void) l2_nsp[0])') },
    [pscustomobject]@{ Name = 'unit_eternal_two.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('2', 'size', '0', '0', '7', 'size', '1', '0', '9');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 2U, 0U)',
                 'if: l2_retained\len != 2',
                 'if: lmx_arena_ref_store(l2_retained, 0U, (cast: (@: void) l2_nsp[0])) != 0',
                 'if: lmx_arena_ref_store(l2_retained, 1U, (cast: (@: void) l2_nsp[1])) != 0') },
    # Seventy roots: the capacity is the COUNT.  Sizing by a root's INDEX -- the trap the two
    # tables invite, l2_ns_eternal[k] beside l2_ebr_n -- would pass every smaller fixture's text.
    [pscustomobject]@{ Name = 'unit_eternal_many.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('70', 'size', '0', '0', '1', 'size', '35', '0', '36', 'size', '69', '0', '70');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 70U, 0U)',
                 'if: l2_retained\len != 70',
                 'if: lmx_arena_ref_store(l2_retained, 69U, (cast: (@: void) l2_nsp[69])) != 0') },
    # A nested member, a reference to the branch itself, a reference to the OTHER branch, and a
    # mutable Holder beside them: two roots are retained, the nested member and Holder are not.
    [pscustomobject]@{ Name = 'unit_eternal_shape.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('2', 'size', '0', '0', '7', 'size', '0', '4', '13', 'same', '0', '3', '0', 'same', '1', '0', '0', 'size', '1', '1', '17');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 2U, 0U)',
                 'if: l2_retained\len != 2') },
    # A cross-reference INTO another branch: F\into is E's member `deep`, not a copy of it.
    [pscustomobject]@{ Name = 'unit_eternal_xref.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('2', 'slot', '1', '0', '0', '0', 'size', '0', '1', '7', 'size', '1', '1', '23');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 2U, 0U)',
                 'if: l2_retained\len != 2') },
    # The other fixtures that happen to declare eternal branches: array fields whose record and
    # backing are built in the store, and merge sites naming a branch.  Count and ownership only.
    [pscustomobject]@{ Name = 'unit_array_empty.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('1');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 1U, 0U)') },
    [pscustomobject]@{ Name = 'unit_array_field.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('1');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 1U, 0U)') },
    [pscustomobject]@{ Name = 'unit_merge_site.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('3');
        Absent = @('not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 3U, 0U)') },
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
    # WHAT THE RUN DOES AND DOES NOT PROVE.  It proves the generated C compiles unchanged, links
    # against the kernel closure, takes its turn through merge-in-method without dying and closes
    # its root once.  It does NOT prove the source program's own result: lmx_thread_dispatch_native
    # drops the entry's return, so `return: 81`, the throw status 70 and the merge shape codes
    # 71..80 are all mute and the process exits 0 regardless.  Two of the three declare no eternal
    # branch; the driver is given 0 and checks that the array exists and is empty.
    # `l2_out_throw[0]: node` is pinned as it IS, not as it should be: what the failure payload
    # ought to be is an open question of the model, and this row must change with that answer.
    [pscustomobject]@{ Name = 'unit_merge_in_method.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('1', 'size', '0', '0', '7');
        Absent = @('Lmx node; @: Lmx node', 'not yet in R0''s retention array', 'l2_program_entry, 5000U, 0U, 0U)');
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m1 (@: Lmx node) int',
                 'fn: l2_m2 (@: Lmx node; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'fn: l2_m3 (@: Lmx node; @: Lmx l2_msg; @@: Lmx l2_out_throw) int',
                 'l2_m3(lmx_arena_ref_struct(node\node, 3U), l2_msg, @ l2_te0)',
                 'l2_m0(lmx_arena_ref_struct(node\node, 0U), l2_msg, @ l2_t1, @ l2_te1)',
                 'l2_m2(lmx_arena_ref_struct(unit, 2U), node, @ l2_t0, @ l2_te0)',
                 'l2_out_throw[0]: node',
                 'lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 1U, 0U)') },
    [pscustomobject]@{ Name = 'unit_throwing_callable.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('Lmx node; @: Lmx node');
        Debt = @('fn: l2_m0 (@: Lmx node; @: Lmx l2_msg; @: int l2_out_result; @@: Lmx l2_out_throw) int',
                 'l2_m0(l2_pst, node, @ l2_t0, @ l2_te0)',
                 'l2_out_throw[0]: node',
                 'lmx_root_open(@ l2_program_root, l2_program_entry, 5000U, 0U, 0U)') },
    [pscustomobject]@{ Name = 'unit_recursion.lm2'; Expect = 'eternal-runs'; Exit = 0; Needle = '';
        Args = @('0');
        Absent = @('Lmx node; @: Lmx node', 'l2_p2_0; @: Lmx node');
        Debt = @('fn: l2_m2 (@: Lmx node; size_t: l2_p2_0; @: Lmx l2_msg; @: size_t l2_out_result; @@: Lmx l2_out_throw) int',
                 'l2_q7, l2_msg, @ l2_t0, @ l2_te0)',
                 '2U, node, @ l2_t2, @ l2_te2)',
                 'l2_out_throw[0]: node',
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

    if ($fx.Expect -eq 'eternal-runs') {
        $l1 = (Get-Content -LiteralPath $genLm1 -Raw)
        $why = ''
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
        # The generated C is compiled AS IT IS; the two renames are what hands its root to the driver.
        $code = Invoke-Step ('fixture.' + $stem + '.compile') $gcc ($kflags + @('-Dmain=l2_generated_main', '-Dlmx_root_close=l2_driver_root_close', '-c', $genC, '-o', $genO)) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $genO)) { Add-Row 'FAIL' ('fixture:' + $stem) "gcc exit $code on the generated C"; continue }
        $code = Invoke-Step ('fixture.' + $stem + '.link') $gcc @('-o', $exe, $driverO, $genO, $l2libcO) $root
        if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) { Add-Row 'FAIL' ('fixture:' + $stem) "link exit $code"; continue }
        $ran = Invoke-Step ('fixture.' + $stem + '.run') $exe $fx.Args $bin
        $said = ((Log-Text ('fixture.' + $stem + '.run')) -split "`r?`n" | Where-Object { $_ -match '^l2_eternal_driver: \d+ checks' } | Select-Object -Last 1)
        if ($ran -ne $fx.Exit -or -not $said) { Add-Row 'FAIL' ('fixture:' + $stem) ('ran under the driver, exit ' + $ran + '; see the log'); continue }
        # A row that declares 0 roots proved no retention and no collection, and must not say so.
        $what = ', retained in R0, survives a collection ('
        if ($fx.Args[0] -eq '0') { $what = ', no eternal branch: compiled unchanged, linked to the kernel closure, ran to its one close (' }
        Add-Row 'OK' ('fixture:' + $stem) (($said -replace '^l2_eternal_driver: ', '') + $what + $fx.Debt.Count + ' required, ' + $fx.Absent.Count + ' forbidden in the text)'); continue
    }

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
