try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. Refreshes the working stage cold-tp140 with the changed files of the candidate variants/tp151 and pins its
# source manifest, by lmxtool commands only (Codex, CODEX-OPUS-288-REVIEW-NEXT-20261106-01: no PS comparison): the stage is
# verified against TP_BASE before the copy (the landed selfbuild/inputs.sha256 by default, else a manifest path under P),
# the changed files are pinned from the variants and copied, the source manifest is written over variants/tp151/inputs.list
# and verified. Uses the working boot150a tool. Parameter TP_TRY (a label), optional TP_BASE.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$base="$R/selfbuild/inputs.sha256"
if ($env:TP_BASE) { $base="$P2/" + $env:TP_BASE }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$term="$p\pins\tp151-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if (Test-Path -LiteralPath "$p\pins\source-tp151-$try.sha256") { throw 'manifestexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'eb11e493de980d1339cb9caa11236054adae37b63c78a07240d211b977bc3a2a') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start base ' + $base + ' ' + (ShaTp ($base -replace '/','\'))) -Encoding utf8
function Step([string]$nn, [string[]]$words) {
  $cwd="$p\tp151-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @words *> "$p\pins\tp151-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($words -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Step '01' @('verify', $base, "$P2/cold-tp140")
Step '02' @('manifest', "$P2/pins/tp151-changed.list", "$P2/variants/tp151", "$P2/pins/tp151-changed-$try.sha256")
Step '03' @('stage-copy', "$P2/pins/tp151-changed-$try.sha256", "$P2/variants/tp151", "$P2/cold-tp140")
Step '04' @('manifest', "$P2/variants/tp151/inputs.list", "$P2/cold-tp140", "$P2/pins/source-tp151-$try.sha256")
Step '05' @('verify', "$P2/pins/source-tp151-$try.sha256", "$P2/cold-tp140")
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp151-' + $try + ' ' + (ShaTp "$p\pins\source-tp151-$try.sha256") + ' changed ' + (ShaTp "$p\pins\tp151-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED151 ' + $try)
