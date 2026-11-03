try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 265. boot127t-prepare uses the tp127 checked source and coherent boot126a G2 frontend.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot127$try"
$tool="$p\cold-tp127\tool127\lmxtool-tool.exe"
$term="$p\pins\boot127$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1af62ef3490069b5ce0553398c6e47b40d1c9fe9b8c83edd5a17fff0aa1932d9') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp127\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 179) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp127.sha256", "$P2/cold-tp127")
  ,@('stage-copy', "$P2/pins/source-tp127.sha256", "$P2/cold-tp127", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp127/inputs.list", "$P2/$stage", "$P2/pins/source-boot127$try.sha256")
  ,@('verify', "$P2/pins/source-boot127$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot127$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot127$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp127.sha256"
$hb=ShaTp "$p\pins\source-boot127$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp127 $hsrc source-boot127$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot127 differs from source-tp127' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick127$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
