try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 272. rebuild tool of the stage cold-tp134 with the verified boot133a tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot133a\quick133a\lmxtool.exe"
$fe="$p\cold-boot133a\quick133a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot133a\quick133a\g2\runtime"
$term="$p\pins\tp134-tool-$try.terminal.txt"
$run="$p\tp134-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp134\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '743fa9d478db1e18719140fd63a9e254b646ba28cd0762b9293470b2e2371850') { throw 'tool hash' }
if ((ShaTp $fe) -ne '71f8b555695cbf8195ad5105d22a795e3d1ca5f5577f5700afe608a2f0b744d9') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'b27649dc650501c116e4e1162739f3c6c8cbbec70e7e3390d95d0512dc9dbcd0' -or (ShaTp "$rt\driver-observe.o") -ne '9dd49f04fb886b14fa8b76b39ffa5f1affdd5a42e94a89a6d3c9ada4edb3c8a8') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp134\tools\build.lm2") + ' source-tp134 ' + (ShaTp "$p\pins\source-tp134.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp134" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot133a/quick133a/g2/frontend/l2trans.exe" "$P2/cold-boot133a/quick133a/g2/runtime" $label "$P2/cold-tp134/tests/smoke-kernel225.tsv" *> "$p\pins\tp134-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp134\$label\lmxtool-tool.exe", "$p\cold-tp134\$label\lmxtool.lm1", "$p\cold-tp134\$label\lmxtool.c", "$p\cold-tp134\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL134 ' + $label + ' exit=' + $e)
exit 0
