try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot123t (fable_pc, slice 261; G0 = tool123 573B37F0): a fresh source-only stage cold-boot123<TP_TRY> with exactly the 167
# selected inputs of stage cold-tp123 (source-tp123: the landed source-tp123 with the 5 changed files of tp123 -- lmx_walk_values,
# l2_frontend_lower, l2_frontend_emit, tools/build.lm2, full-suite.tsv -- and the new fixture tests/dyn/free_graph_address.lm2;
# the variant's inputs.list names them).  No generated header, body, object or reuse set.  Tool: the candidate's tool123 for
# verify/stage-copy/manifest only, fresh CWDs.  Parameter: TP_TRY (a, b, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot123$try"
$tool="$p\cold-tp123\tool123\lmxtool-tool.exe"
$term="$p\pins\boot123$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '573b37f0211119d874c8bea82eca3509ea294faa1dfd0739d7611fdc6066716f') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp123\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 167) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp123.sha256", "$P2/cold-tp123")
  ,@('stage-copy', "$P2/pins/source-tp123.sha256", "$P2/cold-tp123", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp123/inputs.list", "$P2/$stage", "$P2/pins/source-boot123$try.sha256")
  ,@('verify', "$P2/pins/source-boot123$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot123$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot123$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp123.sha256"
$hb=ShaTp "$p\pins\source-boot123$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp123 $hsrc source-boot123$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot123 differs from source-tp123' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick123$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
