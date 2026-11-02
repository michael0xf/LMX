try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 fix04 (fable_pc): the variant after rt116b refused `lmx_walk_values.lm2:5818:69: assignment value has unknown type, atom=record`
# (the path actual `record\code` of two L2 calls in lmx_activation_inputs_find goes through a local, the rule met in tp114/tp115);
# the same 10 files staged again over cold-tp116, the counts of fix02 (19).  The fix03 text follows.
# tp116 fix03 (fable_pc): the variant after the first isolated runtime build rt116 refused `lmx_call.lm2:225:69: length is a
# word of the language: a program cannot bind it` (and lmx_walk_values.lm2:5771 the same; l2_driver.lm2:813 `unsupported
# own array declaration` for `[]: LmxWalkValue vals 2`): every `length` parameter/local of the activation functions is `len`,
# the LmxActivationBinding field `size`, the self-check's input arrays heap cells. The same 10 files are staged again over
# cold-tp116 (whose declaration headers rt116 wrote stay until rt116c rewrites them); the counts are those of fix02 (19).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$term="$p\pins\tp116-prepare-fix04.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp116")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8c5d66ea0852864134b0dd98967f1ab1ab5fa17069d04cc82843fb913ae7cc44') { throw 'tool hash' }
foreach ($g in @("$p\cold-tp116\rt116c")) { if (Test-Path -LiteralPath $g) { throw ('must be absent: ' + $g) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' before: changed ' + (ShaTp "$p\pins\tp116-changed.sha256") + ' source-tp116 ' + (ShaTp "$p\pins\source-tp116.sha256")) -Encoding utf8
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp116-changed.list", "$P2/variants/tp116", "$P2/pins/tp116-changed.sha256")
  ,@('stage-copy', "$P2/pins/tp116-changed.sha256", "$P2/variants/tp116", "$P2/cold-tp116")
  ,@('manifest', "$P2/variants/tp116/inputs.list", "$P2/cold-tp116", "$P2/pins/source-tp116.sha256")
  ,@('verify', "$P2/pins/source-tp116.sha256", "$P2/cold-tp116")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp116-prepare-fix04-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp116-prepare-fix04-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ok=@(Get-Content -LiteralPath "$p\pins\tp116-changed.list")
if ($ok.Count -ne 10) { throw ('changed list lines ' + $ok.Count) }
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp116.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
if ($d.Count -ne 19) { throw ('manifest differences ' + $d.Count) }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after: changed ' + (ShaTp "$p\pins\tp116-changed.sha256") + ' source-tp116 ' + (ShaTp "$p\pins\source-tp116.sha256") + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp116\src\l2src\lmx_walk_values.lm2") + ' fixture ' + (ShaTp "$p\cold-tp116\tests\dyn\free_name_chain.lm2")) -Encoding utf8
Write-Output ('FIX01 ' + $i + ' steps')
