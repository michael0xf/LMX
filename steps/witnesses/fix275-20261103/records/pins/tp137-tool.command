try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 275. rebuild tool of the stage cold-tp137 with the verified boot136a tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot136a\quick136a\lmxtool.exe"
$fe="$p\cold-boot136a\quick136a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot136a\quick136a\g2\runtime"
$term="$p\pins\tp137-tool-$try.terminal.txt"
$run="$p\tp137-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp137\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e3310451333d8016c93adf41507eadd3c2ef4b8c5db6ae52d9d9cca809faa340') { throw 'tool hash' }
if ((ShaTp $fe) -ne '0dfce2c902ca26646c5938e26f6109adcaa91c1170b9a13a89a635092b39e0c4') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '62ef3ff529e96cb363ebfbfff45ebcb0e05a230590d67d6d6991d1e6bd348a1a' -or (ShaTp "$rt\driver-observe.o") -ne '60ba941ae61a83b6729c9de95ecf7662e2e9d46367b2eb09b52ba947a0d0b09c') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp137\tools\build.lm2") + ' source-tp137 ' + (ShaTp "$p\pins\source-tp137.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp137" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot136a/quick136a/g2/frontend/l2trans.exe" "$P2/cold-boot136a/quick136a/g2/runtime" $label "$P2/cold-tp137/tests/smoke-kernel225.tsv" *> "$p\pins\tp137-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp137\$label\lmxtool-tool.exe", "$p\cold-tp137\$label\lmxtool.lm1", "$p\cold-tp137\$label\lmxtool.c", "$p\cold-tp137\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL137 ' + $label + ' exit=' + $e)
exit 0
