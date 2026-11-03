try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 274. Stage of the whole quick: the checked source of cold-tp136, G0 = tool136b.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot136$try"
$tool="$p\cold-tp136\tool136b\lmxtool-tool.exe"
$term="$p\pins\boot136$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'd49b9f99a2e136675ca98178d15e517014a2aa01d480b08aa201be083c07731c') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp136\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 190) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp136.sha256", "$P2/cold-tp136")
  ,@('stage-copy', "$P2/pins/source-tp136.sha256", "$P2/cold-tp136", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp136/inputs.list", "$P2/$stage", "$P2/pins/source-boot136$try.sha256")
  ,@('verify', "$P2/pins/source-boot136$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot136$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot136$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp136.sha256"
$hb=ShaTp "$p\pins\source-boot136$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp136 $hsrc source-boot136$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot136 differs from source-tp136' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick136$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
