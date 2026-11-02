try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp122 (fable_pc, slice 260 = design 4.5 B2b-2c + Codex's P1-NUMERIC-KIND: a runtime-typed value received by a place WITH a
# receiving model -- a modelled own and a modelled formal -- admitted at run time by the one receive and the typed program's
# admission; the kernel's one binary/unary operation refusing a PRESENT operand of another kind by the named implicit convert,
# a contextual 0 beside a reference the null test).  Stage cold-tp122 = the repo's selfbuild (inputs.sha256 = source-tp122,
# BBCCB259) with the listed files of variants/tp122 over it (the kernel module lmx_walk_values, the frontend modules lower and
# emit, tests/full-suite.tsv, the slice-259 fixture free_machine_ops.lm2 extended, the witness tests/dyn/free_model_admit.lm2;
# the variant's inputs.list names the fixture): sources only, no generated input.  Working tool 4DD5D706 (boot121a's promoted
# G2; tools/build.lm2 is the landed one, so no tool rebuild this slice) for verify/manifest/stage-copy only, fresh CWDs.
# Parameter: TP_TRY (fix01, fix02, ...); the first run creates the stage, a later run copies the changed set over it.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot121a\quick121a\lmxtool.exe"
$term="$p\pins\tp122-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4dd5d70602596afcec73902eb83a8a986ffcd13b85f59f2e693ae44920138485') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'bbccb25929eff89f1c7352c39a70b06f1ce1bbbb8aaafbf23f05af51972196de') { throw 'selfbuild inputs manifest is not source-tp121' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp122-changed.list")
if ($ok.Count -ne 6) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp122\$o")) { throw ('variant file missing: ' + $o) } }
$fresh = -not (Test-Path -LiteralPath "$p\cold-tp122")
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if ($fresh) {
  $steps=@(
    ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
    ,@('manifest', "$P2/pins/tp122-changed.list", "$P2/variants/tp122", "$P2/pins/tp122-changed-$try.sha256")
    ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp122")
    ,@('stage-copy', "$P2/pins/tp122-changed-$try.sha256", "$P2/variants/tp122", "$P2/cold-tp122")
    ,@('manifest', "$P2/variants/tp122/inputs.list", "$P2/cold-tp122", "$P2/pins/source-tp122.sha256")
    ,@('verify', "$P2/pins/source-tp122.sha256", "$P2/cold-tp122")
  )
} else {
  $steps=@(
    ,@('manifest', "$P2/pins/tp122-changed.list", "$P2/variants/tp122", "$P2/pins/tp122-changed-$try.sha256")
    ,@('stage-copy', "$P2/pins/tp122-changed-$try.sha256", "$P2/variants/tp122", "$P2/cold-tp122")
    ,@('manifest', "$P2/variants/tp122/inputs.list", "$P2/cold-tp122", "$P2/pins/source-tp122.sha256")
    ,@('verify', "$P2/pins/source-tp122.sha256", "$P2/cold-tp122")
  )
  if (Test-Path -LiteralPath "$p\pins\source-tp122.sha256") { Move-Item -LiteralPath "$p\pins\source-tp122.sha256" -Destination "$p\pins\source-tp122-before-$try.sha256" }
}
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp122-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp122-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp121: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp122.sha256")
if ($a.Count -ne 165 -or $b.Count -ne 166) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
if ($fresh) {
  foreach ($g in @("$p\cold-tp122\headers", "$p\cold-tp122\src\l2src\lmx.h.lm1", "$p\cold-tp122\src\l1src\libc_abi.lm1", "$p\cold-tp122\src\l2src\l2_frontend_state.lm1", "$p\cold-tp122\src\l2src\lmx_arena_refs.h.lm1")) {
    if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
  }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp122 ' + (ShaTp "$p\pins\source-tp122.sha256") + ' changed ' + (ShaTp "$p\pins\tp122-changed-$try.sha256") + ' fresh ' + $fresh) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
