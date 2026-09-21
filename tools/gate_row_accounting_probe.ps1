# tools\gate_row_accounting_probe.ps1 -- the negative control for the gate's row accounting
# (DEEPSEEK-GATE-ROW-ACCOUNTING-20260921-30).
#
# WHY THIS FILE EXISTS.  tools\build_l2src.ps1 emitted every result row through the SUCCESS stream
# from inside the helpers it judges with, so `if (-not (Compile-C ...))` captured @(row, $false) --
# non-empty, hence TRUTHY.  A target that failed to compile was therefore neither skipped nor
# reported honestly: the LINK was attempted, an OK row was printed for it, and the verdict's row
# count exceeded the lines in the captured log.  Measured on the RED run of build/l2src/20260921_001755:
# 231 rows counted against 229 row lines printed, and `unit:lmx_primitive` in the OK rows and in the
# failure list of the SAME run.
#
# HOW IT TESTS.  It loads Add-Row, Get-SafeName, Invoke-Captured, Convert-Source and Compile-C out of
# the gate BY AST -- the REAL definitions, not a copy of them -- because a rig that re-states what it
# tests is a rig that can lie (the Phase B lesson: a rig friendlier than production is a lying rig).
# The failures it forces are REAL gcc invocations that fail, not stubbed exit codes.
#
# RUN:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\gate_row_accounting_probe.ps1
#       ... -GateLog <a captured gate log>   also asserts rows counted == rows printed on that log
# Exit 0 when every assertion holds, 1 otherwise.  It writes only under %TEMP%.
param(
    [string]$Gate,
    [string]$GateLog,
    # The END-TO-END half: copy the whole tree under %TEMP%, break one unit and one selftest in the
    # COPY, and run the real gate on it.  Off by default because it is a full gate run (minutes, not
    # seconds) and it needs gcc, lm1/build and third_party; on request it proves the acceptance list's
    # last clauses -- RED verdict, exit 1, rows counted == rows printed on a FAILING run -- which no
    # function-level check can see.
    [switch]$GateFailRun
)
$ErrorActionPreference = 'Stop'
if (-not $Gate) { $Gate = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools\build_l2src.ps1' }
$gatePath = (Resolve-Path -LiteralPath $Gate).Path
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('gate_row_probe_' + $PID)
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
# The real functions read these from the script scope, exactly as they do in the gate.
$script:rows = @()
$script:failed = @()
$script:logDir = Join-Path $tmp 'logs'
New-Item -ItemType Directory -Force -Path $script:logDir | Out-Null

$checks = 0
$fails = New-Object System.Collections.Generic.List[string]
function Assert-That([string]$Case, [bool]$Ok) {
    $script:checks = $script:checks + 1
    if ($Ok) { Write-Host ('  ok   ' + $Case) } else { $fails.Add($Case); Write-Host ('  no   ' + $Case) }
}

# ---- the real definitions, loaded by AST (never re-implemented here) --------------------------
$ast = [System.Management.Automation.Language.Parser]::ParseFile($gatePath, [ref]$null, [ref]$null)
$wanted = @('Add-Row', 'Get-SafeName', 'Invoke-Captured', 'Convert-Source', 'Compile-C')
foreach ($fn in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
    if ($wanted -contains $fn.Name) { . ([scriptblock]::Create($fn.Extent.Text)) }
}
foreach ($w in $wanted) { Assert-That ('loaded the real ' + $w) ($null -ne (Get-Command $w -ErrorAction SilentlyContinue)) }

# ---- a REAL failing compile input, and the real gcc ------------------------------------------
# The input is a hard SYNTAX error, so it fails whatever the flags are -- and the flags are the
# gate's own four -Werror guards, because a control whose subject only fails under flags it does not
# carry is a control that proves nothing.  (This probe first used an implicit function declaration
# under bare -std=c99: gcc merely WARNS at that, compiled it, and every assertion below went red --
# the rig was friendlier than the failure it was supposed to force.  Measured, 20260921.)
$gcc = (Get-Command gcc -ErrorAction Stop).Source
$flags = @('-std=c99', '-Wall', '-Wextra', '-Wpedantic',
           '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
           '-Werror=implicit-function-declaration', '-Werror=implicit-int')
$brokenC = Join-Path $tmp 'probe_broken.c'
Set-Content -LiteralPath $brokenC -Encoding ascii -Value 'int main(void) { return 0 }'
$obj = Join-Path $tmp 'probe_broken.o'

# ---- CASE 1: a unit that fails to COMPILE ----------------------------------------------------
$before = $script:rows.Count
$captured = @(Compile-C 'unit:probe' $brokenC $obj)
Assert-That 'a failing unit compile adds exactly one row' (($script:rows.Count - $before) -eq 1)
Assert-That 'and that row is a FAIL row' ($script:rows[-1] -match '^FAIL')
Assert-That 'a failing compile produced no object' (-not (Test-Path -LiteralPath $obj))
Assert-That 'the helper returns exactly one scalar boolean, false' (($captured.Count -eq 1) -and ($captured[0] -is [bool]) -and ($captured[0] -eq $false))
# The gate's own unit guard: `if (Compile-C ...) { $objects += ...; Add-Row 'OK' ... }`
$okForFailedTarget = $false
if (Compile-C 'unit:probe2' $brokenC $obj) { $okForFailedTarget = $true }
Assert-That 'a failed unit is NOT taken for success by the gate guard (no false OK row)' (-not $okForFailedTarget)
Assert-That 'and its row is the FAIL row, not an OK one' ($script:rows[-1] -match '^FAIL')

# ---- CASE 2: a SELFTEST that fails to compile, and the link that must not follow -------------
$links = 0
$before = $script:rows.Count
if (-not (Compile-C 'selftest:probe' $brokenC $obj)) {
    # This is the gate's guard: `continue`.  Nothing else runs for this target -- the LINK in
    # particular, which is what produced the second row for one failing target in the RED run.
} else {
    $links = $links + 1
}
Assert-That 'a failed selftest compile adds exactly one row' (($script:rows.Count - $before) -eq 1)
Assert-That 'no link is attempted after a failed selftest compile' ($links -eq 0)
Assert-That 'and the guard saw one scalar false, not @(row, $false)' ($script:rows[-1] -match '^FAIL')

# ---- CASE 3: the TRANSLATE path, same contract (the other internal row emitter) --------------
$Translator = $gcc
$before = $script:rows.Count
$captured = @(Convert-Source 'unit:probe_tr' 'l2src/probe_missing.lm1' (Join-Path $tmp 'probe_tr.c'))
Assert-That 'a failing translate adds exactly one row, a FAIL' ((($script:rows.Count - $before) -eq 1) -and ($script:rows[-1] -match '^FAIL'))
Assert-That 'the translate helper returns exactly one scalar boolean, false' (($captured.Count -eq 1) -and ($captured[0] -is [bool]) -and ($captured[0] -eq $false))

# ---- CASE 4: the emission survives the invocation the gate ACTUALLY has ----------------------
# The gate runs as a CHILD PROCESS (`powershell -File build_l2src.ps1 ... *>&1 | Tee-Object`, or a
# captured background redirect), NOT in-process, and the two shapes do NOT behave alike.  Measured on
# this machine, 20260921, with a real .ps1 emitting all three forms: in a child process Write-Output,
# Write-Host and Out-Host are ALL captured, because that child's console host IS its stdout; in
# process, `& { ... } *>&1` captures Write-Output and Write-Host but NOT Out-Host.
#
# SO CAPTURE IS NOT THE REASON FOR THE EMITTER CHOICE, and this probe must not say it is.  The reason
# the display left the success stream is CASES 1-3 above: Write-Output put the row INTO THE HELPER'S
# RETURN VALUE and made the guards truthy.  What the child-process case asserts is the property the
# EVIDENCE needs: after the change the rows still arrive in a captured log.  The in-process case is
# kept only as the observation that a naive in-process experiment misleads about capture -- true, and
# about a context this gate is never in.  It is not the justification.
$childScript = Join-Path $tmp 'emit_forms.ps1'
Set-Content -LiteralPath $childScript -Encoding ascii -Value @'
Write-Output 'MARK-OUTPUT'
Write-Host 'MARK-HOST'
Out-Host -InputObject 'MARK-OUTHOST'
'@
$childLog = Join-Path $tmp 'child_capture.log'
& powershell -NoProfile -ExecutionPolicy Bypass -File $childScript *>&1 | Tee-Object -FilePath $childLog | Out-Null
$childText = Get-Content -LiteralPath $childLog -Raw
Assert-That 'the gate-shape invocation captures Write-Host rows (the emitter this fix uses)' ($childText -match 'MARK-HOST')
Assert-That 'and would have captured Write-Output too (capture was never the defect)' ($childText -match 'MARK-OUTPUT')
Assert-That 'and captures Out-Host in this shape as well: measured, and NOT why Out-Host was not used' ($childText -match 'MARK-OUTHOST')
$inProc = ((& { Write-Host 'MARK-HOST'; Out-Host -InputObject 'MARK-OUTHOST' } *>&1) | ForEach-Object { $_.ToString() }) -join "`n"
Assert-That 'observation: in-process, Write-Host is captured' ($inProc -match 'MARK-HOST')
Assert-That 'observation: in-process, Out-Host is not -- why a naive in-process experiment misleads' (-not ($inProc -match 'MARK-OUTHOST'))

# ---- CASE 5: rows counted == rows printed (the invariant whose violation caused the RED) -----
Assert-That 'every row this probe produced is accounted for' ($script:rows.Count -eq 4)
Assert-That 'and the failure list holds exactly the failing targets' (($script:failed.Count -eq 4) -and ($script:failed -contains 'unit:probe') -and ($script:failed -contains 'unit:probe2'))
if ($GateLog) {
    $lines = @(Get-Content -LiteralPath $GateLog)
    $rowLines = @($lines | Where-Object { $_ -match '^(OK|FAIL|SKIP)\s' })
    $verdict = @($lines | Where-Object { $_ -match '^build_l2src (GREEN|RED):' } | Select-Object -Last 1)
    Assert-That 'the gate log carries a verdict line' ($verdict.Count -eq 1)
    if ($verdict.Count -eq 1) {
        $m = [regex]::Match($verdict[0], '^build_l2src GREEN: (\d+) targets|^build_l2src RED: \d+ of (\d+) targets')
        $counted = 0
        if ($m.Groups[1].Success) { $counted = [int]$m.Groups[1].Value }
        if ($m.Groups[2].Success) { $counted = [int]$m.Groups[2].Value }
        Assert-That ('rows counted (' + $counted + ') == rows printed (' + $rowLines.Count + ')') ($counted -eq $rowLines.Count)
    }
}

if ($GateFailRun) {
    Write-Host ''
    Write-Host 'end-to-end: the real gate on a deliberately broken COPY of the tree'
    $repo = Split-Path -Parent (Split-Path -Parent $gatePath)
    $failRoot = Join-Path $tmp 'fail_root'
    $failTools = Join-Path $failRoot 'tools'
    $failDev = Join-Path $failRoot 'dev'
    New-Item -ItemType Directory -Force -Path $failRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $failDev | Out-Null
    # THE WHOLE tools DIRECTORY, not just the gate: the gate dot-sources tools\ps51_proc.ps1 and
    # refuses BY NAME when it is absent ("missing process helper: ..."), which is what this rig's
    # first run discovered -- its own incomplete copy, and the helper's fail-fast working end to end.
    Copy-Item -LiteralPath (Join-Path $repo 'tools') -Destination $failRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repo 'bin') -Destination $failRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repo 'L1_PIN.txt') -Destination $failRoot -Force
    Copy-Item -LiteralPath (Join-Path $repo 'lm1') -Destination $failRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repo 'third_party') -Destination $failRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repo 'dev\l2src_sandbox') -Destination $failDev -Recurse -Force
    # TWO AUTHENTIC BREAKAGES, both in the shape of the real RED run of 20260921_001755, so the rig
    # forces COMPILE failures of exactly the kind this ticket is about rather than a translator
    # refusal (which would stop at the translate step and exercise less of the accounting):
    # (1) a UNIT that loses a declaration its generated C needs -- one predef removed, so gcc fails
    #     under -Werror=implicit-function-declaration, which is how unit:lmx_primitive failed;
    $failUnit = Join-Path $failDev 'l2src_sandbox\lmx_primitive.lm1'
    $unitText = @(Get-Content -LiteralPath $failUnit) | Where-Object { $_ -notmatch 'lmx_arena_refs\.lm1' }
    Set-Content -LiteralPath $failUnit -Value $unitText -Encoding ascii
    # (2) a SELFTEST with an incompatible pointer argument: the very bug that made
    #     selftest:lmx_primitive_thread_selftest fail to compile, restored in the copy.
    $failTest = Join-Path $failDev 'l2src_sandbox\tests\lmx_primitive_thread_selftest.lm1'
    $testText = @(Get-Content -LiteralPath $failTest) | ForEach-Object { $_.Replace('lmx_child_reserve(t, pt_arena, pt_child_arena,', 'lmx_child_reserve(t, pt_arena, @ child,') }
    Set-Content -LiteralPath $failTest -Value $testText -Encoding ascii
    $failLog = Join-Path $tmp 'fail_gate.log'
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $failTools 'build_l2src.ps1') -Run *>&1 | Tee-Object -FilePath $failLog | Out-Null
    $failExit = $LASTEXITCODE
    $fl = @(Get-Content -LiteralPath $failLog)
    $flRows = @($fl | Where-Object { $_ -match '^(OK|FAIL|SKIP)\s' })
    $flVerdict = @($fl | Where-Object { $_ -match '^build_l2src RED:' } | Select-Object -Last 1)
    Assert-That 'a failing target produces a FAIL row' (@($fl | Where-Object { $_ -match '^FAIL\s' }).Count -gt 0)
    Assert-That 'the verdict is RED' ($flVerdict.Count -eq 1)
    $flCounted = 0
    if ($flVerdict.Count -eq 1) { $flCounted = [int]([regex]::Match($flVerdict[0], 'of (\d+) targets').Groups[1].Value) }
    Assert-That ('on a FAILING run too: rows counted (' + $flCounted + ') == rows printed (' + $flRows.Count + ')') ($flCounted -eq $flRows.Count)
    $flLabels = @()
    if ($flVerdict.Count -eq 1) {
        $verdictMatch = [regex]::Match($flVerdict[0], 'failed \((.+)\);')
        if ($verdictMatch.Success) {
            $labelText = $verdictMatch.Groups[1].Value
            $flLabels = @($labelText -split ',\s*')
        }
    }
    $falseOk = 0
    foreach ($l in $flLabels) {
        if (@($fl | Where-Object { $_ -match ('^OK\s+' + [regex]::Escape($l) + '\s') }).Count -gt 0) { $falseOk = $falseOk + 1 }
    }
    Assert-That 'no target the verdict failed also carries an OK row (no false OK, end to end)' ($falseOk -eq 0)
    Assert-That 'the gate exits 1 on the broken tree' ($failExit -eq 1)
    # NO LINK AFTER A FAILED SELFTEST COMPILE, end to end and by the gate's own evidence: the link log
    # exists only when the link ran, so its absence for the broken selftest is the proof.
    $stamps = @()
    $flBuild = Join-Path $failRoot 'build\l2src'
    if (Test-Path -LiteralPath $flBuild) { $stamps = @(Get-ChildItem -LiteralPath $flBuild -Directory | Sort-Object Name -Descending) }
    Assert-That 'the broken run left an evidence stamp' ($stamps.Count -ge 1)
    if ($stamps.Count -ge 1) {
        $flLogs = Join-Path $stamps[0].FullName 'logs'
        Assert-That 'the broken selftest was COMPILED (its compile log exists: the failure is a compile one)' (Test-Path -LiteralPath (Join-Path $flLogs 'compile_selftest_lmx_primitive_thread_selftest.log'))
        Assert-That 'and was NOT LINKED (no link log: the guard skipped it)' (-not (Test-Path -LiteralPath (Join-Path $flLogs 'selftest_lmx_primitive_thread_selftest.log')))
        Assert-That 'the broken unit failed the same way (its compile log exists)' (Test-Path -LiteralPath (Join-Path $flLogs 'compile_unit_lmx_primitive.log'))
    }
}

if ($fails.Count -gt 0) {
    Write-Host ''
    Write-Host ('gate_row_accounting_probe RED: ' + $fails.Count + ' of ' + $checks + ' checks failed')
    exit 1
}
Write-Host ''
Write-Host ('gate_row_accounting_probe GREEN: ' + $checks + ' checks')
exit 0
