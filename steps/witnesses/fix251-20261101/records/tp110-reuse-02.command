try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, S1): second reuse manifests for the frontend part build fe110. The first pair (tp110-reuse-inputs/
# -artifacts.sha256, 135 files) was derived from the candidate81 precedent, which built Lower itself and therefore
# listed no l2_frontend_lower.lm1/.h.lm1/.lm1.h -- fe110 (parts types,intern) reuses Lower and would have consumed it
# unrecorded. This pair lists every generated file G1 full100 consumed (consumed-inputs.sha256, 306 entries, minus the
# 65 .lm2 sources, minus the three files the part build regenerates -- types.lm1, intern.lm1, state.lm1 -- minus the
# three tool-regenerated lmxtool_methods files): 235 files, all now in cold-tp110 with G1's bytes (stage-copy records
# tp110-prepare, tp110-runtime-outputs, tp110-consumed-rest). Both manifests are produced from the stage by the frozen
# tool (E8150E60) from fresh CWDs; every line is checked against consumed-inputs.sha256; both are verified.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp110-reuse-02.terminal.txt"
$snapman="$p\cold-full100\full100\g1\consumed-inputs.sha256"
$list="$p\pins\tp110-reuse-02.list"
$manIn="$p\pins\tp110-reuse-02-inputs.sha256"
$manAbi="$p\pins\tp110-reuse-02-artifacts.sha256"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Test-Path -LiteralPath $manIn) -or (Test-Path -LiteralPath $manAbi)) { throw 'manifestexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp $snapman) -ne 'f8826e9a17eef45fc763dbf57251daad44d3119e4ab7595bddfd2ae4cef9301d') { throw 'snapshot manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-consumed-rest.terminal.txt" -Pattern ' 03 exit=0 verify ' -Quiet)) { throw 'consumed rest not staged' }
$pins=@{}
foreach ($l in Get-Content -LiteralPath $snapman) { if ($l -cmatch '^([0-9a-f]{64})  (\S+)$') { $pins[$Matches[2]]=$Matches[1] } }
$want=@(Get-Content -LiteralPath $list)
if ($want.Count -ne 235) { throw ('list lines ' + $want.Count) }
foreach ($w in $want) {
  if (-not $pins.ContainsKey($w)) { throw ('not a consumed input: ' + $w) }
  if ($w -like '*.lm2' -or $w -like '*lmxtool_methods*' -or $w -eq 'src/l2src/l2_frontend_types.lm1' -or $w -eq 'src/l2src/l2_frontend_intern.lm1' -or $w -eq 'src/l2src/l2_frontend_state.lm1') { throw ('excluded file in the list: ' + $w) }
  if (-not (Test-Path -LiteralPath "$p\cold-tp110\$w")) { throw ('not in the stage: ' + $w) }
}
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' list ' + (ShaTp $list) + ' files ' + $want.Count) -Encoding utf8
$steps=@(
  ,@('manifest', $list.Replace('\','/'), "$P2/cold-tp110", $manIn.Replace('\','/'))
  ,@('manifest', $list.Replace('\','/'), "$P2/cold-tp110", $manAbi.Replace('\','/'))
  ,@('verify', $manIn.Replace('\','/'), "$P2/cold-tp110")
  ,@('verify', $manAbi.Replace('\','/'), "$P2/cold-tp110")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp110-reuse02-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp110-reuse-02-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
foreach ($m in @($manIn, $manAbi)) {
  $lines=@(Get-Content -LiteralPath $m)
  if ($lines.Count -ne 235) { throw ('manifest lines ' + $lines.Count + ' in ' + $m) }
  foreach ($l in $lines) { if (-not ($l -cmatch '^([0-9a-f]{64})  (\S+)$')) { throw ('manifest line: ' + $l) }; if ($pins[$Matches[2]] -ne $Matches[1]) { throw ('stage differs from G1 for ' + $Matches[2]) } }
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' manifest ' + (ShaTp $m) + ' ' + $m + ' all 235 equal to consumed-inputs.sha256') -Encoding utf8
}
Write-Output ('REUSE-02 MANIFESTS ' + $i + ' steps')
