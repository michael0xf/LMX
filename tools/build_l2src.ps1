# build_l2src.ps1 -- translate the L2 sources under l2src\ to C and compile them.
#
# NOT a self-build. It never rebuilds the translator: it takes the pinned
# bin\l1trans.exe (sha256 checked against L1_PIN.txt) and uses it as given, exactly
# as lingvamyxa's module runners do (run_array_owned.ps1 and its siblings pass
# l2src\<name>.h.lm1 and l2src\<name>.lm1 to the same pinned l1trans.exe).
#
# What it does, per source:
#   l2src\<name>.h.lm1  ->  <out>\headers\l2src\<name>.lm1.h   (the unit's predef header)
#   l2src\<name>.lm1    ->  <out>\obj\<name>.c                 (gcc -c -> <out>\obj\<name>.o)
#   l2src\tests\*_selftest.lm1 and l2src\*_selftest.lm1
#                       ->  <out>\obj\..., linked with every module object into
#                           <out>\bin\<name>.exe; -Run executes them and records the
#                           exit code.
#   the vendored C under third_party\decNumber is compiled as it stands, and so
#   were the last hand-written C files before the L1 conversion; l2src\ has no
#   .c of its own now.
#
# Flags are the module runners' flags: -std=c99 -Wall -Wextra -Wpedantic -Werror
# -O2, -I <project root> (the sources include "l2src/lmx.h") and -I <headers>
# (they include "l2src/<name>.lm1.h").
#
# Verdicts are per target: OK / FAIL (with the log path) / SKIP (with the reason).
# A FAIL makes the script exit 1; SKIP does not.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_l2src.ps1
#   ... -Run                    also run every linked selftest
#   ... -Translator <path>      use another translator (requires -ExpectedTranslatorSha256)
#                               default bin\l1trans.exe still uses L1_PIN.txt
#   ... -ExpectedTranslatorSha256 <64-hex>  required for explicit non-default -Translator
param(
    [string]$Translator,
    [string]$OutDir,
    [switch]$Run,
    [switch]$Strict,
    # Required when -Translator names a non-default executable (same spelling as build_mixa).
    [string]$ExpectedTranslatorSha256
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$root = (Resolve-Path -LiteralPath $root).Path
Write-Output ("build_l2src: repository root=" + $root)
Set-Location $root

$defaultTranslator = Join-Path $root 'bin\l1trans.exe'
if (-not $Translator) { $Translator = $defaultTranslator }
if (-not (Test-Path -LiteralPath $Translator)) { throw "translator not found: $Translator" }
$Translator = (Resolve-Path -LiteralPath $Translator).Path
$defaultTranslatorFull = $null
if (Test-Path -LiteralPath $defaultTranslator) { $defaultTranslatorFull = (Resolve-Path -LiteralPath $defaultTranslator).Path }
$isDefaultTranslator = ($defaultTranslatorFull -and ($Translator -eq $defaultTranslatorFull)) -or ((-not $defaultTranslatorFull) -and ($Translator -eq $defaultTranslator))
$pinFile = Join-Path $root 'L1_PIN.txt'
$translatorHash = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash.ToUpper()
$pinChecked = 'not checked (a translator was named explicitly)'
if ($isDefaultTranslator) {
    if (-not (Test-Path -LiteralPath $pinFile)) { throw "missing $pinFile" }
    $pinFile = (Resolve-Path -LiteralPath $pinFile).Path
    Write-Output ("build_l2src: pin file path=" + $pinFile)
    $rootPinExpected = Join-Path $root 'L1_PIN.txt'
    if (Test-Path -LiteralPath $rootPinExpected) { $rootPinExpected = (Resolve-Path -LiteralPath $rootPinExpected).Path }
    if ($pinFile -ne $rootPinExpected) {
        throw ("build_l2src: pin file is not repository-root L1_PIN.txt: " + $pinFile + " (expected " + $rootPinExpected + ")")
    }
    if ($pinFile -match '(?i)[\\/]dev[\\/]l2src_sandbox[\\/]') {
        throw ("build_l2src: refuse pin under dev/l2src_sandbox: " + $pinFile)
    }
    $pin = (Get-Content -LiteralPath $pinFile -TotalCount 1).Trim()
    if ($pin -notmatch '^[0-9A-Fa-f]{64}$') { throw "L1_PIN.txt must hold one 64-hex SHA256, got '$pin'" }
    if ($translatorHash -ne $pin.ToUpper()) { throw "translator pin mismatch: bin\l1trans.exe is $translatorHash, L1_PIN.txt says $pin" }
    $pinChecked = "matches repository-root L1_PIN.txt ($($pin.Substring(0,16))...)"
    if ($ExpectedTranslatorSha256) {
        if ($ExpectedTranslatorSha256 -notmatch '^[0-9A-Fa-f]{64}$') { throw "ExpectedTranslatorSha256 must be 64 hex, got '$ExpectedTranslatorSha256'" }
        if ($translatorHash -ne $ExpectedTranslatorSha256.ToUpper()) {
            throw "build_l2src: ExpectedTranslatorSha256 mismatch before work: got $translatorHash expected $($ExpectedTranslatorSha256.ToUpper())"
        }
    }
} else {
    # Explicit non-default translator: ExpectedTranslatorSha256 only — never either pin file.
    if (-not $ExpectedTranslatorSha256) {
        throw "build_l2src: -Translator names a non-default executable; -ExpectedTranslatorSha256 (64 hex) is required"
    }
    if ($ExpectedTranslatorSha256 -notmatch '^[0-9A-Fa-f]{64}$') { throw "ExpectedTranslatorSha256 must be 64 hex, got '$ExpectedTranslatorSha256'" }
    if ($translatorHash -ne $ExpectedTranslatorSha256.ToUpper()) {
        throw "build_l2src: ExpectedTranslatorSha256 mismatch before work: got $translatorHash expected $($ExpectedTranslatorSha256.ToUpper())"
    }
    $pinChecked = 'explicit translator ExpectedTranslatorSha256 verified'
}
Write-Output ("build_l2src: translator path=" + $Translator)
Write-Output ("build_l2src: translator sha256=" + $translatorHash + " (" + $pinChecked + ")")
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if (-not $OutDir) { $OutDir = Join-Path $root "build\l2src\$stamp" }
$headers = Join-Path $OutDir 'headers'
$objDir = Join-Path $OutDir 'obj'
$binDir = Join-Path $OutDir 'bin'
$logDir = Join-Path $OutDir 'logs'
foreach ($d in @($headers, (Join-Path $headers 'l2src'), $objDir, $binDir, $logDir)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
$gcc = (Get-Command gcc -ErrorAction Stop).Source
$nm = (Get-Command nm -ErrorAction Stop).Source
# THE ONE 5.1-SAFE LAUNCHER (DEEPSEEK-PS51-PROC-HELPER-20260920-07), dot-sourced here beside the other
# tools this gate resolves so that a missing helper fails FAST AND BY NAME.  The first cut of this
# migration called Invoke-ProcBounded without loading it and died 168 rows in, at the first -Run
# selftest, with "The term 'Invoke-ProcBounded' is not recognized" and NO verdict line at all.
$ps51Proc = Join-Path $root 'tools\ps51_proc.ps1'
if (-not (Test-Path -LiteralPath $ps51Proc)) { throw "missing process helper: $ps51Proc" }
. $ps51Proc

# WHERE THE KERNEL SOURCES ARE, and why this is not a one-liner.  The sources reference each other
# as "l2src/<name>.lm1" -- that segment is HARDCODED IN THEIR TEXT -- so the build needs them
# reachable under a path segment named l2src.  In L1 they live in exactly such a directory
# (dev\l2src_sandbox\l2src).  In LMX they sit FLAT in dev\l2src_sandbox, and that tree is not mine
# to restructure (Grok owns it; his answer via Codex, LMX-L2-LOCAL-BUILD: "not taking mixa header
# adapter; DeepSeek owns that layout").  So the flat layout is STAGED into this run's evidence
# under a l2src\ segment and built from there: staging is a COPY, it is said out loud, and the
# stamped result is a snapshot either way -- which is what the port consumes.
# A trap named by the channel and confirmed by measurement: dev\l2src_sandbox\L1_PIN.txt holds a
# DIFFERENT, older pin (0B3D85B3..., 298308 bytes) than the root's (4E0B7F5D..., 300945).  This
# script reads the pin from $root, so it compares against the translator it actually uses.
$flatSource = Join-Path $root 'dev\l2src_sandbox'
$sourceProbe = 'lmx.h.lm1'
# The sources are the LIVE tree, the sandbox, and only it.  The root l2src is a copy of the sandbox
# kept in the old place, and nothing is built or tested there (author, 2026-09-26, Q8; -198; the
# former frozen twin is the tag l2src-twin-20260926).  (A first cut of this script checked the root
# first and compiled the old snapshot -- which is how the 28 probes lost their declaration, see
# below.)
if (Test-Path -LiteralPath (Join-Path $flatSource $sourceProbe)) {
    $staged = Join-Path $OutDir 'src\l2src'
    New-Item -ItemType Directory -Force -Path $staged | Out-Null
    $stagedCount = 0
    foreach ($f in @(Get-ChildItem -LiteralPath $flatSource -File -Filter '*.lm1')) {
        if ($f.Name -match '_(win32|posix)\.lm1$') { continue }
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $staged $f.Name) -Force; $stagedCount++
    }
    # -200: one logical body name, the host picks the file. This script is the Windows gate, so the body is the Win32 one, staged under the name every predef already uses.
    foreach ($logical in @('lmx_clock.lm1', 'lmx_process_deadline.lm1', 'lmx_manager_running.lm1', 'lmx_manager_running_lane.lm1')) {
        $physical = $logical -replace '\.lm1$', '_win32.lm1'
        Copy-Item -LiteralPath (Join-Path $flatSource $physical) -Destination (Join-Path $staged $logical) -Force; $stagedCount++
    }
    $flatTests = Join-Path $flatSource 'tests'
    if (Test-Path -LiteralPath $flatTests) {
        $stagedTests = Join-Path $staged 'tests'
        New-Item -ItemType Directory -Force -Path $stagedTests | Out-Null
        foreach ($f in @(Get-ChildItem -LiteralPath $flatTests -File -Filter '*.lm1')) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $stagedTests $f.Name) -Force; $stagedCount++
        }
    }
    # AND THE KERNEL-SIDE l1src, which is a DIFFERENT SET FROM THE TRANSLATOR'S -- two different files
    # both called l1src/libc_abi.lm1.  The probes say `predef: "l1src/libc_abi.lm1"` and need the
    # KERNEL-side one: it declares `fn: l1_stdout () @: FILE` (:51), while the translator's copy at
    # LMX\l1src does not declare it at all.  Without this the translator resolves the predef against
    # $root, finds the translator's copy, l1_stdout stays undeclared, C assumes it returns int, and
    # fputs(FILE*) fails under -Werror -- which is exactly the 28 probes.  Staged next to the sources
    # so that $sourceBase, not $root, is what resolves it.
    $flatL1 = Join-Path $flatSource 'l1src'
    if (Test-Path -LiteralPath $flatL1) {
        $stagedL1 = Join-Path (Split-Path -Parent $staged) 'l1src'
        New-Item -ItemType Directory -Force -Path $stagedL1 | Out-Null
        foreach ($f in @(Get-ChildItem -LiteralPath $flatL1 -File)) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $stagedL1 $f.Name) -Force; $stagedCount++
        }
    }
    $sourceDir = $staged
    $sourceBase = Split-Path -Parent $staged
    # THE TRANSLATOR RESOLVES `predef:` ITSELF, FROM THE WORKING DIRECTORY -- gcc's -I does not enter
    # into it.  With CWD left at $root, `predef: "l1src/libc_abi.lm1"` lands on LMX\l1src, which is
    # the TRANSLATOR's own source set and does NOT declare l1_stdout; the generated C then calls it
    # implicitly and -Werror=implicit-function-declaration kills the compile (measured: generated C
    # line 3934, `fputs(..., l1_stdout())`).  Standing in the staged root makes `l1src/` the
    # KERNEL-side set and `l2src/` the sources -- the same relationship L1's layout had, which is why
    # the kernel built there.  The relative source paths below are already "l2src/...", and targets
    # are absolute, so nothing else moves.
    Set-Location $sourceBase
    Write-Output "build_l2src: sources STAGED from $flatSource -> $staged ($stagedCount files, incl. kernel-side l1src); cwd moved to $sourceBase so predef paths resolve there"
} else {
    throw "no kernel sources: $flatSource\$sourceProbe not found"
}
# The default flags are the L2 port runners' shape: no -O level and -Werror on the
# four hard guards only. -Strict adds the module runners' blanket -Werror -O2; it
# is not the default because at -O2 a unit that the port runners build cleanly
# trips -Werror=maybe-uninitialized (measured on lmx_graph_copy_owned.c:411), which
# is a diagnostic about optimisation, not a defect this build is here to catch.
$decNumberDir = Join-Path $root 'third_party\decNumber\decNumber-icu-368'
$flags = @('-std=c99', '-Wall', '-Wextra', '-Wpedantic', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $sourceBase, '-I', $headers,
           '-I', $decNumberDir,
           '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
           '-Werror=implicit-function-declaration', '-Werror=implicit-int')
if ($Strict) { $flags += @('-Werror', '-O2') }

$rows = @()
$failed = @()
function Add-Row([string]$State, [string]$Label, [string]$Note) {
    # THE DISPLAY LINE MUST NOT TRAVEL THE SUCCESS STREAM (DEEPSEEK-GATE-ROW-ACCOUNTING-20260921-30).
    # This function is called from INSIDE the helpers the gate judges with: Convert-Source and
    # Compile-C both call it before returning their boolean.  A Write-Output here therefore put the
    # ROW INTO THEIR RETURN VALUE, and the caller's `if (-not (Compile-C ...))` captured
    # @(row, $false) -- non-empty, hence TRUTHY.  Three measured consequences, all from the RED run
    # of 20260921_001755: a target that failed to compile was NOT skipped (the link was attempted,
    # so one target contributed two rows); the unit pass added an OK ROW FOR A TARGET THAT DID NOT
    # BUILD (`unit:lmx_primitive` appeared in the OK rows and in the failure list of the same run);
    # and the verdict counted 231 rows while the captured output held 229 lines.
    #
    # THE EMITTER: Write-Host, so the display leaves the success stream WITHOUT leaving the logs.
    # The reason the display had to LEAVE THE SUCCESS STREAM is the paragraph above -- the row was
    # becoming part of the helper's return value, and that alone made the guards truthy.  WHICH
    # emitter is a separate question, and CAPTURE DOES NOT DECIDE IT: measured 20260921 with a real
    # script emitting all three forms, a CHILD PROCESS (how this gate runs) captures Write-Output,
    # Write-Host and Out-Host alike, while IN-process `& { ... } *>&1` captures Write-Output and
    # Write-Host but not Out-Host.  Write-Host is chosen because it is captured in BOTH shapes, so
    # nothing about the invocation has to be relied on -- not because Out-Host would lose rows here,
    # which it would not.  tools\gate_row_accounting_probe.ps1 asserts the child-process half (rows
    # still arrive in a captured log) and records the in-process half only as the observation that a
    # naive in-process experiment misleads about capture.
    $row = ('{0,-4} {1,-34} {2}' -f $State, $Label, $Note)
    $script:rows += $row
    Write-Host $row
    if ($State -eq 'FAIL') { $script:failed += $Label }
}
function Get-SafeName([string]$Name) {
    # A log name must be a file name: labels carry a ':' (header:, unit:, selftest:)
    # and Windows refuses it, which silently turned every redirect into a cmd error.
    return ($Name -replace '[:/\\*?"<>|]', '_')
}
function Invoke-Captured([string]$Label, [string]$Exe, [string[]]$ArgList, [string]$LogName) {
    # The parameter is NOT named $Args: that name is PowerShell's automatic
    # unbound-argument array, and it wins inside the body -- the tool was invoked
    # with no arguments at all and printed its usage line.
    # Invoke the tool directly and capture both streams ourselves. Going through
    # cmd /c with the command line wrapped in a second pair of quotes makes cmd
    # mangle the arguments ("The filename, directory name, or volume label syntax
    # is incorrect") -- measured here, not assumed; with the arguments unquoted it
    # passes them through, but then a path with a space would break. The native
    # call needs EAP Continue: under Stop, PS 5.1 turns a native stderr line into a
    # terminating error.
    #
    # THE OUTPUT IS NEVER HELD IN MEMORY.  It used to be `& $Exe @ArgList | Out-String`, which
    # builds the whole of a command's output as one .NET string and then a SECOND copy to prepend
    # the header -- and a full gate makes on the order of a thousand invocations.  Peak memory
    # therefore scaled with how chatty the run happened to be, which is why the same gate passed
    # at 3.8 GB free and was killed by the host at 3.3 GB (three kills on 20.09, one of them a
    # full L2 gate).  The header is written first and the child appends to the file itself, so
    # nothing accumulates in the PowerShell heap.  Found by deepseek in the sibling build_mixa.
    $log = Join-Path $logDir ((Get-SafeName $LogName) + '.log')
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + ($ArgList -join ' ')) -Encoding utf8
    $eap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    # `& $Exe @ArgList` passes argv as an ARRAY and must stay that way: every path here can
    # contain a space (the toolchain root, the staged stamp directory), and Start-Process
    # -ArgumentList would rejoin the array into one unquoted string and break exactly those.
    # `*>>` appends every stream as the lines arrive; $LASTEXITCODE is read immediately after,
    # before anything else can overwrite it.  EAP stays Continue across the call for the reason
    # above: under Stop, PS 5.1 turns a native stderr line into a terminating error.
    # `*>>` IS WRONG HERE AND WAS MEASURED WRONG: PS 5.1 appends through it in UTF-16LE
    # while the header above is UTF-8, so the log became a mixed-encoding file and every
    # diagnostic in it read as mojibake.  Out-File -Append streams the pipeline one record
    # at a time -- it does NOT accumulate like Out-String -- and honours -Encoding.
    & $Exe @ArgList 2>&1 | Out-File -LiteralPath $log -Append -Encoding utf8
    $code = $LASTEXITCODE
    $ErrorActionPreference = $eap
    return $code
}
# A selftest is a program, and a program may HANG.  The gate must not hang with it: the run is
# bounded, and a run that hits the bound is KILLED AND REPORTED as the failure it is -- a timeout is
# not a pass, and a silent kill would be the worst of both (measured: an off-by-one in a walk guard
# looped forever and the whole gate sat there; a selftest here takes well under a second).
$SelftestTimeoutSec = 120
function Test-ExpectedFatal([string]$Label, [string]$Exe, [string]$ArgvJoined, [int]$Seconds) {
    # ONE EXPECTED-FATAL CONTRACT, AND IT IS A CONTRACT RATHER THAN A WHITELIST.  Exactly one target
    # is allowed to die on purpose -- `lmx_close_watchdog_running_selftest`, whose subject is a lane
    # that never ends -- and the CALLER is what keys this to that name; nothing here inspects names.
    # SUCCESS REQUIRES ALL FIVE CLAUSES, and each failure names the clause that failed so a RED line
    # says which one broke rather than merely that something did:
    #   * the process started and did NOT hit this harness's own bound;
    #   * EXACT exit code 3;
    #   * stdout carries the armed marker;
    #   * stderr carries one documented close-deadline diagnostic from the accepted family;
    #   * stdout does NOT carry the returned-close line.
    # The log keeps the same name and the same header shape the ordinary -Run path writes, plus one
    # auditable line naming the verdict, so a later reader can see WHY this row is green.
    # DEEPSEEK-MAIL-CASCADE-FIX-20260921-82; author's ruling via Codex 2026-09-21.
    $log = Join-Path $logDir ((Get-SafeName $Label) + '.log')
    $run = Invoke-ProcBounded -Exe $Exe -Argv @() -TimeoutSec $Seconds
    if (-not $run.Started) {
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" DID NOT START")
        return "expected-fatal FAILED: the child did not start"
    }
    if ($run.TimedOut) {
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" BOUNDED $Seconds s -- TIMEOUT, the run was killed`r`n" + $run.Text)
        return "expected-fatal FAILED: TIMEOUT after $Seconds s -- the WATCHDOG was supposed to end this, not the harness"
    }
    $outText = "" + $run.Out
    $errText = "" + $run.Err
    $verdict = "expected-fatal contract: exit=$($run.Code), armed stdout=" +
               ([string]($outText -match 'PROBE-RUNNING armed:')) + ", deadline stderr=" +
               ([string]($errText -match 'the overall close deadline expired'))
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + $ArgvJoined + "`r`n" + $verdict + "`r`n" + $run.Text)
    if ($run.Code -ne 3) {
        return "expected-fatal FAILED: exit $($run.Code), expected exactly 3 (clause: exact exit code)"
    }
    if ($outText -notmatch 'PROBE-RUNNING armed:') {
        return "expected-fatal FAILED: the armed marker is missing from STDOUT (clause: stdout marker)"
    }
    if ($outText -match 'PROBE-RUNNING the close RETURNED') {
        return "expected-fatal FAILED: the close RETURNED -- this probe was supposed to die (clause: no returned close)"
    }
    if ($errText -notmatch 'the overall close deadline expired') {
        return "expected-fatal FAILED: no documented close-deadline diagnostic on STDERR (clause: stderr diagnostic)"
    }
    return ''
}

function Invoke-Bounded([string]$Label, [string]$Exe, [string[]]$ArgList, [int]$Seconds) {
    # Started through the .NET process API, not Start-Process: with redirected streams PS 5.1's
    # -PassThru object does not report the child's exit code (measured: a passing test was reported
    # as a failure), and a bound whose verdict cannot be read is worse than no bound.  The .NET
    # object gives all three things this needs: a real exit code, the captured streams, and a
    # WaitForExit(ms) that can be believed.
    #
    # THE LAUNCH ITSELF IS tools\ps51_proc.ps1's Invoke-ProcBounded (DEEPSEEK-PS51-PROC-HELPER-20260920-07):
    # $ArgList is passed as an ARRAY and the helper builds the command line, so this file no longer
    # touches ProcessStartInfo.ArgumentList -- which does not exist under Windows PowerShell 5.1 /
    # .NET Framework and threw "You cannot call a method on a null-valued expression" whenever a
    # caller passed a NONEMPTY argv (measured live against this function; latent only because both
    # callers pass @()).  KILL-BEFORE-READ is the helper's order and this function's requirement:
    # reading the captured streams before the kill would wait out the child and then kill a corpse
    # while still reporting TIMEOUT.
    # THE LOG IS COMPOSED HERE, byte for byte as before, from the helper's Started/TimedOut/Text --
    # the helper writes no log of its own, so every existing line keeps its exact bytes, including
    # the trailing space the empty-argv join leaves after the closing quote.
    $log = Join-Path $logDir ((Get-SafeName $Label) + '.log')
    $run = Invoke-ProcBounded -Exe $Exe -Argv $ArgList -TimeoutSec $Seconds
    if (-not $run.Started) {
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" DID NOT START")
        return -2
    }
    if ($run.TimedOut) {
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" BOUNDED $Seconds s -- TIMEOUT, the run was killed`r`n" + $run.Text)
        return -1
    }
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + ($ArgList -join ' ') + "`r`n" + $run.Text)
    return $run.Code
}
function Convert-Source([string]$Label, [string]$RelSource, [string]$Target) {
    # The LOG name is not the row label: translate, compile and link of ONE target must not share
    # a file, because Invoke-Captured writes logs with Set-Content (overwrite) and the label is
    # identical for all three -- which left only the LAST command visible (measured 20.09: the
    # failing probe's log held the link invoke and nothing else, so "was the compile even run?"
    # could not be answered from evidence).
    $code = Invoke-Captured $Label $Translator @($RelSource, $Target) ("translate_" + $Label)
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $Target)) {
        # NOT piped to Out-Null: the row IS the evidence, and swallowing it left a HOLE in the
        # log -- the target simply vanished from the listing while the summary still counted it
        # (measured 20260919: selftest:lmx_app_min_selftest failed to translate and no FAIL line
        # was printed anywhere).  The note also names the target's own log, not just the folder.
        Add-Row 'FAIL' $Label "translate exit $code; log $logDir\$(Get-SafeName $Label).log"
        return $false
    }
    return $true
}
function Compile-C([string]$Label, [string]$Source, [string]$Object) {
    $code = Invoke-Captured $Label $gcc ($flags + @('-c', $Source, '-o', $Object)) ("compile_" + $Label)
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $Object)) {
        Add-Row 'FAIL' $Label "gcc exit $code; log $logDir\$(Get-SafeName $Label).log"
        return $false
    }
    return $true
}

# Per-run symbol memo for Get-Symbols; see the note inside it. Script scope, never persisted.
$script:SymbolCache = @{}
function Get-Symbols([string]$File, [switch]$Undefined) {
    # A failed compile leaves no .o; Resolve-Link must not crash on it.  Return empty
    # so the link step proceeds and fails as its own FAIL row (measured 20260919:
    # nm on a missing .o under ErrorActionPreference=Stop throws NativeCommandError
    # and takes down the whole gate).
    if (-not (Test-Path -LiteralPath $File)) { return @() }
    $opt = if ($Undefined) { '-u' } else { '--defined-only' }
    # ONE nm PER (OBJECT, MODE) PER RUN.  Resolve-Link asks the same question of the same objects
    # in every round -- up to 32 rounds over the whole pool, once per program -- and each ask was
    # a process spawn plus a full Out-String copy of its output.  An object cannot change while
    # the gate runs (it is produced by an earlier phase and never rewritten), so the answer cannot
    # go stale inside one run.  The table is script-scoped and dies with the process: nothing is
    # cached across runs, where an object COULD differ.  Keyed by the resolved path, so two
    # spellings of the same file share one entry.
    $key = (Resolve-Path -LiteralPath $File).ProviderPath + '|' + $opt
    if ($script:SymbolCache.ContainsKey($key)) { return $script:SymbolCache[$key] }
    $syms = @()
    # Read nm's output line by line instead of building it as one string first: a big object's
    # symbol table is large, and this runs once per object per mode.
    foreach ($line in @(& $nm $opt $File 2>&1)) {
        $parts = @(([string]$line).Trim() -split '\s+' | Where-Object { $_ })
        if ($parts.Count -ge 2 -and $parts[-1] -match '^[A-Za-z_][A-Za-z_0-9]*$') { $syms += $parts[-1] }
    }
    $script:SymbolCache[$key] = $syms
    return $syms
}
function Resolve-Link([string]$SelftestObject, [string[]]$AllObjects) {
    # These units are not separately linkable modules: `predef:` pulls a whole SOURCE
    # in, so a unit carries its predef closure's code, and two units whose closures
    # overlap collide ("multiple definition" -- measured: lmx_int.o and the
    # lmx_own_selftest unit both define lmx_ranges_init). So the link set is resolved
    # by symbol instead of guessed: add only the objects that define a symbol the
    # program still lacks, in rounds, and let ld judge the result.
    $chosen = @()
    $selected = @{}
    for ($round = 0; $round -lt 32; $round++) {
        $need = @{}
        foreach ($s in @(Get-Symbols $SelftestObject -Undefined)) { $need[$s] = $true }
        foreach ($o in $chosen) { foreach ($s in @(Get-Symbols $o -Undefined)) { $need[$s] = $true } }
        $have = @{}
        # THE PROGRAM'S OWN OBJECT COUNTS AS A PROVIDER.  It IS linked into the result, so a symbol
        # it defines is not missing -- and treating it as missing made the resolver pick a module
        # object defining the same symbol, which ld then reported as "multiple definition"
        # (measured 20260920: 21 logs, 47 targets, once a new unit entered a closure that a selftest
        # already carried through its own predefs; the module object was always the DUPLICATE and the
        # selftest the "first defined here").  Seeding here is the same act every round, not a
        # special case for round 0: the selftest's definitions are this program's throughout.
        foreach ($s in @(Get-Symbols $SelftestObject)) { $have[$s] = $true }
        foreach ($o in $chosen) { foreach ($s in @(Get-Symbols $o)) { $have[$s] = $true } }
        $missing = @($need.Keys | Where-Object { -not $have.ContainsKey($_) })
        if ($missing.Count -eq 0) { break }
        $added = $false
        foreach ($o in $AllObjects) {
            if ($selected.ContainsKey($o)) { continue }
            $defs = @(Get-Symbols $o)
            foreach ($s in $missing) {
                if ($defs -contains $s) { $chosen += $o; $selected[$o] = $true; $added = $true; break }
            }
            if ($added) { break }
        }
        if (-not $added) { break }
    }
    return $chosen
}

# translator path/hash already printed after pin/ExpectedTranslatorSha256 check
Write-Output "build_l2src: gcc $gcc"
Write-Output "build_l2src: evidence $OutDir"

# 1) predef headers of the units
# $sourceDir was RESOLVED EARLIER (the staging block above chooses between the live sandbox and the
# published root, and prints which).  This line used to assign it unconditionally, which silently
# threw the staged tree away: the CWD stayed in the staged root, so `predef: "l1src/..."` resolved
# there and the l1_stdout fix took effect, while every SOURCE compiled from here on came from the
# root snapshot -- one tree for predefs, another for sources.  Measured consequence: the green stamp
# held 47 probe objects (the root's count) while 49 probes had been staged, and the two that exist
# only in the sandbox (lmx_walk_selftest, lmx_callable_selftest) had no log at all -- never
# enumerated.  Found by lmx_uds reading this file, not by me.  The header loop below uses the
# CWD-relative "l2src/<name>" path, so it follows whichever tree was resolved.
if (-not (Test-Path -LiteralPath (Join-Path $sourceDir 'lmx.h.lm1'))) {
    throw "no kernel headers under the resolved source dir: $sourceDir"
}
foreach ($h in @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.h.lm1' -File | Sort-Object Name)) {
    $base = $h.Name.Substring(0, $h.Name.Length - '.h.lm1'.Length)
    $target = Join-Path $headers "l2src\$base.lm1.h"
    if (Convert-Source "header:$base" "l2src/$($h.Name)" $target) { Add-Row 'OK' "header:$base" '' }
}

# 2) the units themselves
$objects = @()
$unitSources = @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.lm1' -File |
    Where-Object { $_.Name -notlike '*_selftest.lm1' } | Sort-Object Name)
# The tests\ tree carries units and header units of its own (fmt_buf, the two C
# drivers). Without this they were translated by nobody: the globs looked only at
# the top level, which is the gap the fmt_buf conversion reported.
$sourceTestsDir = Join-Path $sourceDir 'tests'
if (Test-Path -LiteralPath $sourceTestsDir) {
    foreach ($h in @(Get-ChildItem -LiteralPath $sourceTestsDir -Filter '*.h.lm1' -File | Sort-Object Name)) {
        $base = $h.Name.Substring(0, $h.Name.Length - '.h.lm1'.Length)
        $target = Join-Path $headers "l2src\tests\$base.lm1.h"
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
        if (Convert-Source "header:tests/$base" "l2src/tests/$($h.Name)" $target) { Add-Row 'OK' "header:tests/$base" '' }
    }
    $unitSources += @(Get-ChildItem -LiteralPath $sourceTestsDir -Filter '*.lm1' -File |
        Where-Object { $_.Name -notlike '*_selftest.lm1' -and $_.Name -notlike '*.h.lm1' } | Sort-Object Name)
}
foreach ($u in $unitSources) {
    $inTests = ($u.DirectoryName -eq $sourceTestsDir)
    $base = $u.Name.Substring(0, $u.Name.Length - '.lm1'.Length)
    if ($inTests) { $base = 'tests_' + $base }
    $rel = if ($inTests) { "l2src/tests/$($u.Name)" } else { "l2src/$($u.Name)" }
    $cFile = Join-Path $objDir "$base.c"
    $objFile = Join-Path $objDir "$base.o"
    if (-not (Convert-Source "unit:$base" $rel $cFile)) { continue }
    if (Compile-C "unit:$base" $cFile $objFile) { $objects += $objFile; Add-Row 'OK' "unit:$base" '' }
}

# 3) hand-written C, and the vendored library the decimal backend links against.
# decNumber is third-party C and is NOT touched or translated: it is compiled as it
# stands, and its objects join the pool the selftests resolve symbols from, so only
# the programs that really need decimal symbols pull them in.
$handObjects = @()
foreach ($c in @(Get-ChildItem -LiteralPath $sourceDir -Filter '*.c' -File | Sort-Object Name)) {
    $base = $c.Name.Substring(0, $c.Name.Length - '.c'.Length)
    $objFile = Join-Path $objDir "$base.o"
    if (Compile-C "handC:$base" (Join-Path $sourceDir $c.Name) $objFile) { $handObjects += $objFile; Add-Row 'OK' "handC:$base" '' }
}
$thirdPartyObjects = @()
foreach ($name in @('decNumber.c', 'decContext.c')) {
    $src = Join-Path $decNumberDir $name
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $base = $name.Substring(0, $name.Length - '.c'.Length)
    $objFile = Join-Path $objDir "tp_$base.o"
    if (Compile-C "thirdparty:$base" $src $objFile) { $thirdPartyObjects += $objFile; Add-Row 'OK' "thirdparty:$base" '' }
}

# 4) selftests: translate, link with every module object, optionally run
$selftests = @()
$selftests += @(Get-ChildItem -LiteralPath $sourceDir -Filter '*_selftest.lm1' -File)
$testsDir = Join-Path $sourceDir 'tests'
if (Test-Path -LiteralPath $testsDir) { $selftests += @(Get-ChildItem -LiteralPath $testsDir -Filter '*_selftest.lm1' -File) }
foreach ($t in @($selftests | Sort-Object Name)) {
    $base = $t.Name.Substring(0, $t.Name.Length - '.lm1'.Length)
    $rel = if ($t.DirectoryName -eq $testsDir) { "l2src/tests/$($t.Name)" } else { "l2src/$($t.Name)" }
    $cFile = Join-Path $objDir "$base.c"
    $exe = Join-Path $binDir "$base.exe"
    if (-not (Convert-Source "selftest:$base" $rel $cFile)) { continue }
    $testObj = Join-Path $objDir "$base.selftest.o"
    if (-not (Compile-C "selftest:$base" $cFile $testObj)) { continue }
    $linkObjects = Resolve-Link $testObj ($objects + $thirdPartyObjects)
    $link = $flags + @('-o', $exe, $testObj)
    # The tests\ fixtures count allocations through ld's malloc wrap, exactly as
    # lingvamyxa's runners do; a wrap is added only where the fixture uses it
    # (__wrap_X / __real_X), since a program without __wrap_X would fail to link.
    $testText = Get-Content -LiteralPath $cFile -Raw
    foreach ($fn in @('malloc', 'free', 'realloc', 'calloc')) {
        if ($testText -match ('__wrap_' + $fn + '|__real_' + $fn)) { $link += @("-Wl,--wrap=$fn") }
    }
    $link += $linkObjects
    $code = Invoke-Captured "selftest:$base" $gcc $link "selftest:$base"
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
        Add-Row 'FAIL' "selftest:$base" "link exit $code; log $logDir\$(Get-SafeName "selftest:$base").log"
        continue
    }
    if (-not $Run) { Add-Row 'OK' "selftest:$base" 'linked'; continue }
    if ($base -eq 'lmx_close_watchdog_running_selftest') {
        # THE ONE TARGET ALLOWED TO BE FATAL ON PURPOSE, and the only place its name appears.
        $why = Test-ExpectedFatal "run:selftest:$base" $exe "" $SelftestTimeoutSec
        if ($why -eq '') { Add-Row 'OK' "selftest:$base" "ran, expected-fatal: exit 3, armed stdout, deadline stderr; log $logDir\$(Get-SafeName "run:selftest:$base").log" }
        else { Add-Row 'FAIL' "selftest:$base" "$why; log $logDir\$(Get-SafeName "run:selftest:$base").log" }
        continue
    }
    $code = Invoke-Bounded "run:selftest:$base" $exe @() $SelftestTimeoutSec
    if ($code -eq 0) { Add-Row 'OK' "selftest:$base" 'ran, exit 0' }
    elseif ($code -eq -1) { Add-Row 'FAIL' "selftest:$base" "TIMEOUT after $SelftestTimeoutSec s (killed); log $logDir\$(Get-SafeName "run:selftest:$base").log" }
    elseif ($code -eq -2) { Add-Row 'FAIL' "selftest:$base" "did not start; log $logDir\$(Get-SafeName "run:selftest:$base").log" }
    else { Add-Row 'FAIL' "selftest:$base" "ran, exit $code; log $logDir\$(Get-SafeName "run:selftest:$base").log" }
}

# 5) selftests written in C (the kernel's own, e.g. the record's shape): the object
# was built with the other hand-written C above; link the symbols it really needs
# (the same nm resolver) and run it with -Run.
foreach ($c in @(Get-ChildItem -LiteralPath $sourceDir -Filter '*_selftest.c' -File | Sort-Object Name)) {
    $base = $c.Name.Substring(0, $c.Name.Length - '.c'.Length)
    $testObj = Join-Path $objDir "$base.o"
    $exe = Join-Path $binDir "$base.exe"
    if (-not (Test-Path -LiteralPath $testObj)) {
        # NOT a silent skip.  A C selftest whose object was never built used to vanish from the
        # record entirely -- the same class the Convert-Source comment warns about ("swallowing it
        # left a HOLE in the log"), found again on 20.09 by Grok Bot's read-only pass: this was the
        # one path where a failure gained no Add-Row, so $failed grew without a line to explain it.
        Add-Row 'FAIL' "cselftest:$base" "object never built: $testObj (see compile_* log for the C source)"
        continue
    }
    $linkObjects = Resolve-Link $testObj ($objects + $thirdPartyObjects)
    $link = $flags + @('-o', $exe, $testObj) + $linkObjects
    $code = Invoke-Captured "cselftest:$base" $gcc $link "cselftest:$base"
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
        Add-Row 'FAIL' "cselftest:$base" "link exit $code; log $logDir\$(Get-SafeName "cselftest:$base").log"
        continue
    }
    if (-not $Run) { Add-Row 'OK' "cselftest:$base" 'linked'; continue }
    $code = Invoke-Bounded "run:cselftest:$base" $exe @() $SelftestTimeoutSec
    if ($code -eq 0) { Add-Row 'OK' "cselftest:$base" 'ran, exit 0' }
    elseif ($code -eq -1) { Add-Row 'FAIL' "cselftest:$base" "TIMEOUT after $SelftestTimeoutSec s (killed); log $logDir\$(Get-SafeName "run:cselftest:$base").log" }
    else { Add-Row 'FAIL' "cselftest:$base" "ran, exit $code; log $logDir\$(Get-SafeName "run:cselftest:$base").log" }
}

Write-Output ''
if ($failed.Count -gt 0) {
    Write-Output ("build_l2src RED: {0} of {1} targets failed ({2}); evidence {3}" -f $failed.Count, $rows.Count, ($failed -join ', '), $OutDir)
    exit 1
}
Write-Output ("build_l2src GREEN: {0} targets, no failures; evidence {1}" -f $rows.Count, $OutDir)
exit 0
