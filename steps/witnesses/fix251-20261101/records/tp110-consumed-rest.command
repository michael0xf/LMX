try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, S1): the second `rebuild tool` on cold-tp110 passed the tool root's L1 step and failed in gcc --
# `fatal error: l2src/lmx_walk_values.lm1.h: No such file or directory` (cold-tp110/tool110-fail02/lmxtool.CC.log,
# pins/tp110-tool-fail02.*): the stage still lacked generated C headers (headers/l2src/*.lm1.h) and other generated
# files that G1 full100 consumed. G1's consumed-inputs snapshot (cold-full100/full100/g1/consumed-inputs/, manifest
# consumed-inputs.sha256, 306 files, F8826E9A) pins every file G1's steps read. This record stages every file of that
# manifest that cold-tp110 does not hold (pins/tp110-consumed-rest.list: all generated -- no .lm2 source among them),
# except the three the frontend part build regenerates and my prepare record asserted absent
# (src/l2src/l2_frontend_types.lm1, l2_frontend_intern.lm1, l2_frontend_state.lm1). Files the stage already holds are
# not touched (the three that differ from G1 are the tp110 sources types/intern and the tool-regenerated
# lmxtool_methods.lm1, whose unit prefix hashes the stage path). manifest/stage-copy/verify of the frozen tool
# (E8150E60), every tool run from a fresh CWD; each manifest line is checked against consumed-inputs.sha256.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp110-consumed-rest.terminal.txt"
$snap="$p\cold-full100\full100\g1\consumed-inputs"
$snapman="$p\cold-full100\full100\g1\consumed-inputs.sha256"
$list="$p\pins\tp110-consumed-rest.list"
$man="$p\pins\tp110-consumed-rest.sha256"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (Test-Path -LiteralPath $man) { throw 'manifestexists' }
if (Test-Path -LiteralPath "$p\cold-tp110\tool110") { throw 'tool110 exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp $snapman) -ne 'f8826e9a17eef45fc763dbf57251daad44d3119e4ab7595bddfd2ae4cef9301d') { throw 'snapshot manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-prepare.terminal.txt" -Pattern ' 10 exit=0 ' -Quiet)) { throw 'stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-runtime-outputs.terminal.txt" -Pattern ' 03 exit=0 verify ' -Quiet)) { throw 'runtime outputs not staged' }
$pins=@{}
foreach ($l in Get-Content -LiteralPath $snapman) { if ($l -cmatch '^([0-9a-f]{64})  (\S+)$') { $pins[$Matches[2]]=$Matches[1] } }
if ($pins.Count -ne 306) { throw ('snapshot manifest entries ' + $pins.Count) }
$want=@(Get-Content -LiteralPath $list)
if ($want.Count -lt 55 -or $want.Count -gt 64) { throw ('list lines ' + $want.Count) }
foreach ($w in $want) {
  if (-not $pins.ContainsKey($w)) { throw ('not a consumed input: ' + $w) }
  if ($w -like '*.lm2' -or $w -like 'tools/*' -or $w -like 'tests/*') { throw ('a source in the list: ' + $w) }
  if ($w -eq 'src/l2src/l2_frontend_types.lm1' -or $w -eq 'src/l2src/l2_frontend_intern.lm1' -or $w -eq 'src/l2src/l2_frontend_state.lm1') { throw ('regenerated file in the list: ' + $w) }
  if (Test-Path -LiteralPath "$p\cold-tp110\$w") { throw ('already in the stage: ' + $w) }
}
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' snapshot-manifest ' + (ShaTp $snapman) + ' list ' + (ShaTp $list) + ' files ' + $want.Count) -Encoding utf8
$steps=@(
  ,@('manifest', $list.Replace('\','/'), $snap.Replace('\','/'), $man.Replace('\','/'))
  ,@('stage-copy', $man.Replace('\','/'), $snap.Replace('\','/'), "$P2/cold-tp110")
  ,@('verify', $man.Replace('\','/'), "$P2/cold-tp110")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp110-rest-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp110-consumed-rest-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
  if ($i -eq 1) {
    $lines=@(Get-Content -LiteralPath $man)
    if ($lines.Count -ne $want.Count) { throw ('manifest lines ' + $lines.Count) }
    foreach ($l in $lines) { if (-not ($l -cmatch '^([0-9a-f]{64})  (\S+)$')) { throw ('manifest line: ' + $l) }; if ($pins[$Matches[2]] -ne $Matches[1]) { throw ('snapshot differs from its manifest: ' + $Matches[2]) } }
    Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' manifest ' + (ShaTp $man) + ' all ' + $lines.Count + ' equal to consumed-inputs.sha256') -Encoding utf8
  }
}
$still=@(); foreach ($l in Get-Content -LiteralPath $snapman) { if ($l -cmatch '^([0-9a-f]{64})  (\S+)$') { if (-not (Test-Path -LiteralPath "$p\cold-tp110\$($Matches[2])")) { $still+=$Matches[2] } } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' consumed inputs still absent in the stage: ' + $still.Count + ' (' + ($still -join ' ') + ')') -Encoding utf8
if ($still.Count -ne 3) { throw ('expected exactly the three regenerated files absent, found ' + $still.Count) }
Write-Output ('CONSUMED-REST STAGED ' + $i + ' steps')
