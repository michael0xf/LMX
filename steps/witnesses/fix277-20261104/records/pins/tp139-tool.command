try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 277. rebuild tool of the stage cold-tp139 with the verified boot138b tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot138b\quick138b\lmxtool.exe"
$fe="$p\cold-boot138b\quick138b\g2\frontend\l2trans.exe"
$rt="$p\cold-boot138b\quick138b\g2\runtime"
$term="$p\pins\tp139-tool-$try.terminal.txt"
$run="$p\tp139-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp139\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '603b63979c585433832b6ff3810857ff371e2bc46f1aaa1880b1b37af4d45d1f') { throw 'tool hash' }
if ((ShaTp $fe) -ne '484d37f330df5bcecde2f604702b409cb3e21d135dfcf6e9fd36377ca827acf2') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'c7299a3ce8202d22285258ff97873123f34aea3f410c0ac7a6870016d855df63' -or (ShaTp "$rt\driver-observe.o") -ne 'ab1e79736e67e01bc8b2981923b05136c3058818e796ab2fb00841aa25a49be4') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp139\tools\build.lm2") + ' source-tp139 ' + (ShaTp "$p\pins\source-tp139.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp139" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot138b/quick138b/g2/frontend/l2trans.exe" "$P2/cold-boot138b/quick138b/g2/runtime" $label "$P2/cold-tp139/tests/smoke-kernel225.tsv" *> "$p\pins\tp139-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp139\$label\lmxtool-tool.exe", "$p\cold-tp139\$label\lmxtool.lm1", "$p\cold-tp139\$label\lmxtool.c", "$p\cold-tp139\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL139 ' + $label + ' exit=' + $e)
exit 0
