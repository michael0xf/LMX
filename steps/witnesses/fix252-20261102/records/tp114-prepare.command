try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp114 (fable_pc, S3c = the owner memo trusted by three generations instead of a tree walk (context; l2_doc_gen bumped by
# every document destroy of core/emit/types/values through per-module helpers), the predef file index behind the define
# and result-type lookups (types; l2_snap_gen bumped by snap_free in emit), the fact index behind use_fact_find (values;
# l2_pf_gen bumped by bound_free in core), 28 state cells (tools/build.lm2); intern, views, resolve as in tp113). Stage
# cold-tp114 = source-full100 with the nine tp114 files over it, plus the 232 generated inputs the frontend part build
# reuses, all taken from cold-tp113 (229 G1 files verified there, fe110's intern L1, fe111's views L1, fe112's resolve
# L1). Frozen tool E8150E60, manifest/stage-copy/verify only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp114-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp114") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp "$p\pins\source-full100.sha256") -ne 'aa84116779f5fcae9c25f551af1a2929fa8282e55129b6f9de7cb81945891d8e') { throw 'source-full100 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp113-frontend-part.terminal.txt" -Pattern 'PartExit 0' -Quiet)) { throw 'fe113 not built' }
foreach ($f in @('l2_frontend_intern','l2_frontend_views','l2_frontend_resolve')) { if (-not (Test-Path -LiteralPath "$p\cold-tp113\src\l2src\$f.lm1")) { throw "reused L1 missing: $f.lm1" } }
if ((ShaTp "$p\cold-tp113\src\l2src\l2_frontend_intern.lm1") -ne '0992ab7c59ca1701e91526caf11c617a268be6aaf18cd4714890e40b10f85585') { throw 'intern.lm1 is not fe110 output' }
if ((ShaTp "$p\cold-tp113\src\l2src\l2_frontend_resolve.lm1") -ne 'e9259b75c7879759b50c712496fdfc1404ebb3633f9313e6b588297dd3c0b8a1') { throw 'resolve.lm1 is not fe112 output' }
if ((ShaTp "$p\cold-tp113\src\l2src\l2_frontend_views.lm1") -ne '4e3f42123663f2773d49d4b9e7a5b72d635008c78213ab5db098bfa35d4ad25a') { throw 'views.lm1 is not fe111 output' }
$steps=@(
  ,@('manifest', "$P2/pins/tp114-changed.list", "$P2/variants/tp114", "$P2/pins/tp114-changed.sha256")
  ,@('stage-copy', "$P2/pins/source-full100.sha256", "$P2/cold-full100", "$P2/cold-tp114")
  ,@('stage-copy', "$P2/pins/tp114-changed.sha256", "$P2/variants/tp114", "$P2/cold-tp114")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp114", "$P2/pins/source-tp114.sha256")
  ,@('manifest', "$P2/pins/tp114-reuse.list", "$P2/cold-tp113", "$P2/pins/tp114-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp114-reuse-inputs.sha256", "$P2/cold-tp113", "$P2/cold-tp114")
  ,@('manifest', "$P2/pins/tp114-reuse.list", "$P2/cold-tp114", "$P2/pins/tp114-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-tp114.sha256", "$P2/cold-tp114")
  ,@('verify', "$P2/pins/tp114-reuse-inputs.sha256", "$P2/cold-tp114")
  ,@('verify', "$P2/pins/tp114-reuse-artifacts.sha256", "$P2/cold-tp114")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp114-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp114-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly nine lines of the 159 differ from source-full100: types, intern, values, views, context, resolve, core, emit, build (as in tp113).
$a=@(Get-Content -LiteralPath "$p\pins\source-full100.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp114.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 18) { throw ('manifest differences ' + $d.Count) }
$ok=@('src/l2src/l2_frontend_types.lm2','src/l2src/l2_frontend_intern.lm2','src/l2src/l2_frontend_values.lm2','src/l2src/l2_frontend_views.lm2','src/l2src/l2_frontend_context.lm2','src/l2src/l2_frontend_resolve.lm2','src/l2src/l2_frontend_core.lm2','src/l2src/l2_frontend_emit.lm2','tools/build.lm2')
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
# the reuse manifests are one and the same content (229 G1 files + fe110's intern + fe111's views + fe112's resolve), and the regenerated files are absent
$ri=@(Get-Content -LiteralPath "$p\pins\tp114-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp114-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp114\src\l2src\l2_frontend_types.lm1", "$p\cold-tp114\src\l2src\l2_frontend_context.lm1", "$p\cold-tp114\src\l2src\l2_frontend_values.lm1", "$p\cold-tp114\src\l2src\l2_frontend_core.lm1", "$p\cold-tp114\src\l2src\l2_frontend_emit.lm1", "$p\cold-tp114\src\l2src\l2_frontend_state.lm1", "$p\cold-tp114\tool114", "$p\cold-tp114\fe114")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp114 ' + (ShaTp "$p\pins\source-tp114.sha256") + ' changed ' + (ShaTp "$p\pins\tp114-changed.sha256") + ' reuse-inputs ' + (ShaTp "$p\pins\tp114-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp114-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
