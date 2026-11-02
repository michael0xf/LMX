try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, slice S1 of optimization_design_from_fable.md): a fresh stage cold-tp110 = the 159 selected inputs of
# source-full100 (AA841167) with three files from variants/tp110 -- l2_frontend_types.lm2 (the predef declaration index),
# l2_frontend_intern.lm2 (pd_free resets that index), tools/build.lm2 (the index's nine state cells in the generated
# l2_frontend_state.lm1) -- plus the generated files a frontend-part build reuses, copied from G1 full100's consumed-input
# snapshot (the stage itself lost core/emit outputs and headers to the stopped G2). Tool: G1 full100's promoted working tool
# (E8150E60), manifest/verify/stage-copy only. Every tool run from its own fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp110-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp110") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp "$p\pins\source-full100.sha256") -ne 'aa84116779f5fcae9c25f551af1a2929fa8282e55129b6f9de7cb81945891d8e') { throw 'source-full100 manifest hash' }
if ((ShaTp "$p\cold-full100\full100\g1\consumed-inputs.sha256") -ne 'f8826e9a17eef45fc763dbf57251daad44d3119e4ab7595bddfd2ae4cef9301d') { throw 'snapshot manifest hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp110-changed.list", "$P2/variants/tp110", "$P2/pins/tp110-changed.sha256")
  ,@('stage-copy', "$P2/pins/source-full100.sha256", "$P2/cold-full100", "$P2/cold-tp110")
  ,@('stage-copy', "$P2/pins/tp110-changed.sha256", "$P2/variants/tp110", "$P2/cold-tp110")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp110", "$P2/pins/source-tp110.sha256")
  ,@('manifest', "$P2/pins/tp110-reuse-inputs.list", "$P2/cold-full100/full100/g1/consumed-inputs", "$P2/pins/tp110-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp110-reuse-inputs.sha256", "$P2/cold-full100/full100/g1/consumed-inputs", "$P2/cold-tp110")
  ,@('manifest', "$P2/pins/tp110-reuse-artifacts.list", "$P2/cold-tp110", "$P2/pins/tp110-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-tp110.sha256", "$P2/cold-tp110")
  ,@('verify', "$P2/pins/tp110-reuse-inputs.sha256", "$P2/cold-tp110")
  ,@('verify', "$P2/pins/tp110-reuse-artifacts.sha256", "$P2/cold-tp110")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp110-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp110-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly three lines of the 159 differ from source-full100: types, intern, build.
$a=@(Get-Content -LiteralPath "$p\pins\source-full100.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp110.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 6) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { if (-not ($x.InputObject -like '*  src/l2src/l2_frontend_types.lm2' -or $x.InputObject -like '*  src/l2src/l2_frontend_intern.lm2' -or $x.InputObject -like '*  tools/build.lm2')) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-tp110\src\l2src\l2_frontend_types.lm1", "$p\cold-tp110\src\l2src\l2_frontend_intern.lm1", "$p\cold-tp110\src\l2src\l2_frontend_state.lm1", "$p\cold-tp110\tp110")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the part build: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp110 ' + (ShaTp "$p\pins\source-tp110.sha256") + ' reuse-inputs ' + (ShaTp "$p\pins\tp110-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp110-reuse-artifacts.sha256") + ' changed ' + (ShaTp "$p\pins\tp110-changed.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
