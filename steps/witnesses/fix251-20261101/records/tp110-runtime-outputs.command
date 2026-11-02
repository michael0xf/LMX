try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, S1): the first `rebuild tool` on the stage cold-tp110 failed at the tool root's L1 step --
# `l1trans error: cannot read import l2src/lmx_walk_values.h.lm1` (pins/tp110-tool-fail01.log, cold-tp110/tool110-fail01/
# lmxtool.L1.log): the stage held only the staged sources and the frontend reuse set, not the kernel declarations and
# modules that the runtime step writes into src/l2src and that the tool root imports -- the same failure as
# candidate44's first `rebuild tool` on a fresh stage (pins/cold-candidate44-tool-rebuild-runtime.command, comment).
# The kernel sources of tp110 are G1 full100's (source-tp110 differs from source-full100 in types, intern, build only)
# and the frontend passed to `rebuild tool` is G1's, so the runtime step would write G1's bytes again: this record
# stages G1's runtime-step outputs instead -- the 46 files under src/l2src named by the `out` lines of
# cold-full100/full100/g1/runtime/record.txt (36 lmx_*.lm1 modules, 10 lmx_*.h.lm1 declarations), each hash-pinned by
# that record -- by manifest/stage-copy/verify of the frozen tool (E8150E60), every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp110-runtime-outputs.terminal.txt"
$rec="$p\cold-full100\full100\g1\runtime\record.txt"
$list="$p\pins\tp110-runtime-outputs.list"
$man="$p\pins\tp110-runtime-outputs.sha256"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (Test-Path -LiteralPath $man) { throw 'manifestexists' }
if (Test-Path -LiteralPath "$p\cold-tp110\tool110") { throw 'tool110 exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-prepare.terminal.txt" -Pattern ' 10 exit=0 ' -Quiet)) { throw 'stage not prepared' }
# the record's outs under src/l2src are exactly the list
$outs=@{}
foreach ($l in Get-Content -LiteralPath $rec) { if ($l -cmatch '^  out ([0-9a-f]{64}) (\S+)$') { $rel=$Matches[2] -replace '^C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-full100/',''; if ($rel -like 'src/l2src/*') { $outs[$rel]=$Matches[1] } } }
$want=@(Get-Content -LiteralPath $list)
if ($outs.Count -ne 46 -or $want.Count -ne 46) { throw ('runtime outs ' + $outs.Count + ' list ' + $want.Count) }
foreach ($w in $want) { if (-not $outs.ContainsKey($w)) { throw ('not a runtime out: ' + $w) } }
$missing=@($want | Where-Object { -not (Test-Path -LiteralPath "$p\cold-tp110\$_") })
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' record ' + (ShaTp $rec) + ' list ' + (ShaTp $list) + ' missing-before ' + $missing.Count) -Encoding utf8
$steps=@(
  ,@('manifest', $list.Replace('\','/'), "$P2/cold-full100", $man.Replace('\','/'))
  ,@('stage-copy', $man.Replace('\','/'), "$P2/cold-full100", "$P2/cold-tp110")
  ,@('verify', $man.Replace('\','/'), "$P2/cold-tp110")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp110-rt-outs-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp110-runtime-outputs-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
  if ($i -eq 1) {
    # every manifest line carries the record's hash of its file
    $lines=@(Get-Content -LiteralPath $man)
    if ($lines.Count -ne 46) { throw ('manifest lines ' + $lines.Count) }
    foreach ($l in $lines) { if (-not ($l -cmatch '^([0-9a-f]{64})  (\S+)$')) { throw ('manifest line: ' + $l) }; if ($outs[$Matches[2]] -ne $Matches[1]) { throw ('cold-full100 differs from the record: ' + $Matches[2]) } }
    Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' manifest ' + (ShaTp $man) + ' all 46 equal to the record') -Encoding utf8
  }
}
$still=@($want | Where-Object { -not (Test-Path -LiteralPath "$p\cold-tp110\$_") })
if ($still.Count -ne 0) { throw ('still missing ' + $still.Count) }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' staged; lmx_*.h.lm1 in cold-tp110/src/l2src: ' + @(Get-ChildItem -LiteralPath "$p\cold-tp110\src\l2src" -Filter 'lmx_*.h.lm1').Count) -Encoding utf8
Write-Output ('RUNTIME-OUTPUTS STAGED ' + $i + ' steps')
