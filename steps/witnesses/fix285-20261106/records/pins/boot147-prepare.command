try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 285. Stage of the whole quick: the checked source of cold-tp140, G0 = tool147a.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot147$try"
$tool="$p\cold-tp140\tool147a\lmxtool-tool.exe"
$term="$p\pins\boot147$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '0a8e456d0fdec6c74ff44eb185027ba737b4a0cd46c309d7ba46b750c125d660') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp147\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 216) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp147.sha256", "$P2/cold-tp140")
  ,@('stage-copy', "$P2/pins/source-tp147.sha256", "$P2/cold-tp140", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp147/inputs.list", "$P2/$stage", "$P2/pins/source-boot147$try.sha256")
  ,@('verify', "$P2/pins/source-boot147$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot147$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot147$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp147.sha256"
$hb=ShaTp "$p\pins\source-boot147$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp147 $hsrc source-boot147$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot147 differs from source-tp147' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick147$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
