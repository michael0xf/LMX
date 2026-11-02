try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot121 (fable_pc, the short L3+L2 bootstrap of the optimization line after tp121 = design 4.5 B2b-2b: the bitwise and shift
# operators as executable operations of the kernel's one shared binary operation, the walker's five codes): a fresh source-only
# stage cold-boot121<TP_TRY> with exactly the 165 selected inputs of stage cold-tp121 (source-tp121: the landed source-tp120 with
# the 6 changed files of tp121 -- lmx_walk_values, l2_frontend_lower, l2_frontend_emit, tools/build.lm2, full-suite.tsv, the
# bits fixture's header -- and the new fixture tests/dyn/free_machine_ops.lm2; the variant's inputs.list names them).  No
# generated header, body, object or reuse set.  Tool: the candidate's tool121 (7F9C3DBB) for verify/stage-copy/manifest only,
# fresh CWDs.  Parameter: TP_TRY (the attempt: a, b, ... -- the stage is cold-boot121<TP_TRY>).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot121$try"
$tool="$p\cold-tp121\tool121\lmxtool-tool.exe"
$term="$p\pins\boot121$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '7f9c3dbbf9d59f7f1293605e6284c3b65f4be10bd86f6747e1e2ff22f5143995') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp121\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 165) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp121.sha256", "$P2/cold-tp121")
  ,@('stage-copy', "$P2/pins/source-tp121.sha256", "$P2/cold-tp121", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp121/inputs.list", "$P2/$stage", "$P2/pins/source-boot121$try.sha256")
  ,@('verify', "$P2/pins/source-boot121$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot121$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot121$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp121.sha256"
$hb=ShaTp "$p\pins\source-boot121$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp121 $hsrc source-boot121$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot121 differs from source-tp121' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick121$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
