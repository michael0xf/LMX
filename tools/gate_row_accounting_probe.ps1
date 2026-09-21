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
    [string]$GateLog
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

if ($fails.Count -gt 0) {
    Write-Host ''
    Write-Host ('gate_row_accounting_probe RED: ' + $fails.Count + ' of ' + $checks + ' checks failed')
    exit 1
}
Write-Host ''
Write-Host ('gate_row_accounting_probe GREEN: ' + $checks + ' checks')
exit 0
