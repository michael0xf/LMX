try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 275. build-runtime of the stage cold-tp137 with the candidate tool and the boot136a G2 frontend. Parameters TP_TOOL
# (a path under P), TP_LABEL (output directory under the stage), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try -or -not $env:TP_TOOL) { throw 'parameters TP_TOOL TP_LABEL TP_TRY' }
$tool=$p + '\' + ($env:TP_TOOL -replace '/','\')
$fe="$p\cold-boot136a\quick136a\g2\frontend\l2trans.exe"
$term="$p\pins\tp137-rt-$try.terminal.txt"
$run="$p\tp137-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp137\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $fe) -ne '0dfce2c902ca26646c5938e26f6109adcaa91c1170b9a13a89a635092b39e0c4') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' tool ' + (ShaTp $tool) + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp137\src\l2src\lmx_walk_values.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp137\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp137" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot136a/quick136a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp137-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp137\$label\driver.o", "$p\cold-tp137\$label\driver-observe.o", "$p\cold-tp137\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('RT137 ' + $label + ' exit=' + $e)
exit 0
