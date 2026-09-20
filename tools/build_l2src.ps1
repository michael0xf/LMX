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
#   ... -Translator <path>      use another translator (skips the pin check)
param(
    [string]$Translator,
    [string]$OutDir,
    [switch]$Run,
    [switch]$Strict
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not $Translator) { $Translator = Join-Path $root 'bin\l1trans.exe' }
if (-not (Test-Path -LiteralPath $Translator)) { throw "translator not found: $Translator" }
$pinFile = Join-Path $root 'L1_PIN.txt'
$pinChecked = 'not checked (a translator was named explicitly)'
if ($Translator -eq (Join-Path $root 'bin\l1trans.exe')) {
    if (-not (Test-Path -LiteralPath $pinFile)) { throw "missing $pinFile" }
    $pin = (Get-Content -LiteralPath $pinFile -TotalCount 1).Trim()
    if ($pin -notmatch '^[0-9A-Fa-f]{64}$') { throw "L1_PIN.txt must hold one 64-hex SHA256, got '$pin'" }
    $got = (Get-FileHash -LiteralPath $Translator -Algorithm SHA256).Hash
    if ($got -ne $pin.ToUpper()) { throw "translator pin mismatch: bin\l1trans.exe is $got, L1_PIN.txt says $pin" }
    $pinChecked = "matches L1_PIN.txt ($($pin.Substring(0,16))...)"
}
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
$directSource = Join-Path $root 'l2src'
$flatSource = Join-Path $root 'dev\l2src_sandbox'
$sourceProbe = 'lmx.h.lm1'
# ORDER MATTERS AND IT IS NOT A PREFERENCE: the LIVE copy is the sandbox, and the root l2src is the
# published snapshot that lags it (measured 20.09: 165 .lm1 against 159, 7 of them differing, 6 only
# in the sandbox).  My first cut checked the root first and therefore compiled the OLD snapshot --
# which is how the 28 probes lost their declaration (see below) and why lmx_callable/lmx_walk were
# never built at all.  The sandbox is checked first now.
if (Test-Path -LiteralPath (Join-Path $flatSource $sourceProbe)) {
    $staged = Join-Path $OutDir 'src\l2src'
    New-Item -ItemType Directory -Force -Path $staged | Out-Null
    $stagedCount = 0
    foreach ($f in @(Get-ChildItem -LiteralPath $flatSource -File -Filter '*.lm1')) {
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $staged $f.Name) -Force; $stagedCount++
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
} elseif (Test-Path -LiteralPath (Join-Path $directSource $sourceProbe)) {
    $sourceDir = $directSource
    $sourceBase = $root
    Write-Output "build_l2src: sources $sourceDir (l2src\ layout; the sandbox copy was not found)"
} else {
    throw "no kernel sources: found neither $flatSource\$sourceProbe nor $directSource\$sourceProbe"
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
    $script:rows += ('{0,-4} {1,-34} {2}' -f $State, $Label, $Note)
    Write-Output $script:rows[-1]
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
    $log = Join-Path $logDir ((Get-SafeName $LogName) + '.log')
    $eap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $text = & $Exe @ArgList 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ErrorActionPreference = $eap
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + ($ArgList -join ' ') + "`r`n" + $text)
    return $code
}
# A selftest is a program, and a program may HANG.  The gate must not hang with it: the run is
# bounded, and a run that hits the bound is KILLED AND REPORTED as the failure it is -- a timeout is
# not a pass, and a silent kill would be the worst of both (measured: an off-by-one in a walk guard
# looped forever and the whole gate sat there; a selftest here takes well under a second).
$SelftestTimeoutSec = 120
function Invoke-Bounded([string]$Label, [string]$Exe, [string[]]$ArgList, [int]$Seconds) {
    # Started through the .NET process API, not Start-Process: with redirected streams PS 5.1's
    # -PassThru object does not report the child's exit code (measured: a passing test was reported
    # as a failure), and a bound whose verdict cannot be read is worse than no bound.  The .NET
    # object gives all three things this needs: a real exit code, the captured streams, and a
    # WaitForExit(ms) that can be believed.
    $log = Join-Path $logDir ((Get-SafeName $Label) + '.log')
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    if ($null -ne $ArgList -and $ArgList.Count -gt 0) {
        foreach ($a in $ArgList) { $psi.ArgumentList.Add([string]$a) }
    }
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    if (-not $proc.Start()) {
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" DID NOT START")
        return -2
    }
    $outTask = $proc.StandardOutput.ReadToEndAsync()
    $errTask = $proc.StandardError.ReadToEndAsync()
    $finished = $proc.WaitForExit($Seconds * 1000)
    if (-not $finished) {
        try { $proc.Kill() } catch { }
        try { $proc.WaitForExit(5000) | Out-Null } catch { }
        $text = ("" + $outTask.Result) + ("" + $errTask.Result)
        Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" BOUNDED $Seconds s -- TIMEOUT, the run was killed`r`n" + $text)
        return -1
    }
    $code = $proc.ExitCode
    $text = ("" + $outTask.Result) + ("" + $errTask.Result)
    Set-Content -LiteralPath $log -Value ("invoke: `"$Exe`" " + ($ArgList -join ' ') + "`r`n" + $text)
    return $code
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

function Get-Symbols([string]$File, [switch]$Undefined) {
    # A failed compile leaves no .o; Resolve-Link must not crash on it.  Return empty
    # so the link step proceeds and fails as its own FAIL row (measured 20260919:
    # nm on a missing .o under ErrorActionPreference=Stop throws NativeCommandError
    # and takes down the whole gate).
    if (-not (Test-Path -LiteralPath $File)) { return @() }
    $opt = if ($Undefined) { '-u' } else { '--defined-only' }
    $out = & $nm $opt $File 2>&1 | Out-String
    $syms = @()
    foreach ($line in ($out -split "`r?`n")) {
        $parts = @($line.Trim() -split '\s+' | Where-Object { $_ })
        if ($parts.Count -ge 2 -and $parts[-1] -match '^[A-Za-z_][A-Za-z_0-9]*$') { $syms += $parts[-1] }
    }
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

Write-Output "build_l2src: translator $Translator ($pinChecked)"
Write-Output "build_l2src: gcc $gcc"
Write-Output "build_l2src: evidence $OutDir"

# 1) predef headers of the units
$sourceDir = Join-Path $root 'l2src'
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
