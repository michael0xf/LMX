try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. Stage of the whole quick: the checked source of cold-tp140, by lmxtool commands only. The stage operations
# run with the working boot150a tool. Parameters TP_TRY (the bootstrap's label: stage cold-boot151<try>) and TP_SRC (the
# prepare try whose pins/source-tp151-<TP_SRC>.sha256 is the source).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY; $src=$env:TP_SRC
if (-not $try -or -not $src) { throw 'parameters TP_TRY TP_SRC' }
$stage="cold-boot151$try"
$source="$P2/pins/source-tp151-$src.sha256"
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$term="$p\pins\boot151$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'eb11e493de980d1339cb9caa11236054adae37b63c78a07240d211b977bc3a2a') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
function Step([string]$nn, [string[]]$words) {
  $cwd="$p\boot151$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @words *> "$p\pins\boot151$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($words -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Step '01' @('verify', $source, "$P2/cold-tp140")
Step '02' @('stage-copy', $source, "$P2/cold-tp140", "$P2/$stage")
Step '03' @('manifest', "$P2/variants/tp151/inputs.list", "$P2/$stage", "$P2/pins/source-boot151$try.sha256")
Step '04' @('verify', "$P2/pins/source-boot151$try.sha256", "$P2/$stage")
Step '05' @('same', $source, "$P2/pins/source-boot151$try.sha256")
if ((Test-Path -LiteralPath "$p\$stage\headers","$p\$stage\src\l2src\lmx.h.lm1","$p\$stage\src\l1src\libc_abi.lm1","$p\$stage\src\l2src\l2_frontend_state.lm1","$p\$stage\quick151$try") -contains $true) { throw 'a generated input exists in the stage' }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source ' + (ShaTp ($source -replace '/','\')) + ' source-boot151' + $try + ' ' + (ShaTp "$p\pins\source-boot151$try.sha256")) -Encoding utf8
Write-Output ('PREPARED151 boot ' + $try)
