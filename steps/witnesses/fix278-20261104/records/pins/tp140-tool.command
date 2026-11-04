try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 278. rebuild tool of the stage cold-tp140 with the verified boot139a tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot139a\quick139a\lmxtool.exe"
$fe="$p\cold-boot139a\quick139a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot139a\quick139a\g2\runtime"
$term="$p\pins\tp140-tool-$try.terminal.txt"
$run="$p\tp140-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'fe4b36561d357ab234936863ca3de990e29a0fdc65744ca20da9b98ced6f77df') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'da492cef1f750bf6690e2b63ca0eff7d519435f97cb533724609b62a186dc0e4') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '447cad4ab5c7a15f0583976404f551f2727b0650571dc981c1aba3cd379ff0fa' -or (ShaTp "$rt\driver-observe.o") -ne '18ae5a4bf1e263be22fd0a89d990f1d6ec7e7796fdb7554a9400f0223c7bdb67') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp140 ' + (ShaTp "$p\pins\source-tp140.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot139a/quick139a/g2/frontend/l2trans.exe" "$P2/cold-boot139a/quick139a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp140-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c", "$p\cold-tp140\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL140 ' + $label + ' exit=' + $e)
exit 0
