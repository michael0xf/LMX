try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 348 (M6 4c lowering). boot349: G1 against G2 (images by exe-same, which masks the PE stamp; generated texts and
# objects by raw sha256), the runtime G1 against rt76, and fehost19 (G0, source67) against the frontend G1.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$S="$P2/cold-graph309-codex01"
$b="$S/boot349"
$tool="$p\cold-graph309-codex01\tool45\lmxtool-tool.exe"
$log="$p\pins\opus348-compare-g1-g2.log"
$cwd="$p\runs\opus348"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $log) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '9378BE3E54549CD6FFACB40183945528D0F9D99985CA533062680DB2F1803ED8') { throw 'tool hash' }
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $log -Value ('CWD=' + (Get-Location).Path.Replace('\','/')) -Encoding utf8
foreach ($pair in @(@("$b/g1/frontend/l2trans.exe","$b/g2/frontend/l2trans.exe"), @("$b/g1/frontend/l1trans.exe","$b/g2/frontend/l1trans.exe"), @("$b/g1/tool/lmxtool-tool.exe","$b/g2/tool/lmxtool-tool.exe"), @("$S/fehost19/l2trans.exe","$b/g1/frontend/l2trans.exe"), @("$S/fehost19/l1trans.exe","$b/g1/frontend/l1trans.exe"))) {
  $so="$cwd\exe-same.out.txt"; $se="$cwd\exe-same.err.txt"
  $pr = Start-Process -FilePath $tool -ArgumentList @('0','entry','0','--','exe-same',$pair[0],$pair[1]) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $so -RedirectStandardError $se
  Add-Content -LiteralPath $log -Value ((Get-Content -Raw -LiteralPath $so) + (Get-Content -Raw -LiteralPath $se) + "exit=$($pr.ExitCode)").Trim() -Encoding utf8
}
function HashOf($x) { (Get-FileHash -Algorithm SHA256 -LiteralPath $x).Hash }
foreach ($rel in @('tool/lmxtool.lm1','tool/lmxtool.c','frontend/l2trans.lm1','frontend/l2trans.c','frontend/l2_libc.o','frontend/launch.txt','runtime/driver.c','runtime/driver.o','runtime/driver-observe.o')) {
  $a="$b/g1/$rel"; $c="$b/g2/$rel"
  if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $c)) { Add-Content -LiteralPath $log -Value ("ABSENT $rel") -Encoding utf8; continue }
  if ((HashOf $a) -eq (HashOf $c)) { $w='SAME' } else { $w='DIFFER' }
  Add-Content -LiteralPath $log -Value ("$w $rel") -Encoding utf8
}
foreach ($rel in @('driver.c','driver.o','driver-observe.o')) {
  $a="$S/rt76/$rel"; $c="$b/g1/runtime/$rel"
  if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $c)) { Add-Content -LiteralPath $log -Value ("ABSENT rt76/$rel") -Encoding utf8; continue }
  if ((HashOf $a) -eq (HashOf $c)) { $w='SAME' } else { $w='DIFFER' }
  Add-Content -LiteralPath $log -Value ("$w rt76/$rel = g1/runtime/$rel") -Encoding utf8
}
# fehost19 (G0, source67, built by the boot348 G2 frontend) and the frontend G1: their texts against each other.
foreach ($rel in @('l2trans.lm1','l2trans.c','launch.txt')) {
  $a="$S/fehost19/$rel"; $c="$b/g1/frontend/$rel"
  if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $c)) { Add-Content -LiteralPath $log -Value ("ABSENT fehost19/$rel") -Encoding utf8; continue }
  if ((HashOf $a) -eq (HashOf $c)) { $w='SAME' } else { $w='DIFFER' }
  Add-Content -LiteralPath $log -Value ("$w fehost19/$rel = g1/frontend/$rel") -Encoding utf8
}
Get-Content -LiteralPath $log
