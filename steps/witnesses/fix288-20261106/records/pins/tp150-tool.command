try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 288. rebuild tool of the stage cold-tp140 with the verified boot149b tuple (tools/build.lm2 exports one more
# resolve name, so the frontend build needs this G0). Parameters TP_LABEL (output directory under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot149b\quick149b\lmxtool.exe"
$fe="$p\cold-boot149b\quick149b\g2\frontend\l2trans.exe"
$rt="$p\cold-boot149b\quick149b\g2\runtime"
$term="$p\pins\tp150-tool-$try.terminal.txt"
$run="$p\tp150-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3ffac1a49ddc133799bf13bd63f766e3ffb6c2de383825b815be7c3214161792') { throw 'tool hash' }
if ((ShaTp $fe) -ne '8e415dadbf1e2e6bc14e8551d342719fed0ab999f526ebdfc2b8af28a8e1c4bb') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '2cab6a2717653d4e89f87fb977ce61e75bf60b6c406917ddf4cde8c2d4f66b9a' -or (ShaTp "$rt\driver-observe.o") -ne '47f74b3b39de2cd98aa1103d515b511840035df6e90247c776ce9e8b5b2d43cf') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp150 ' + (ShaTp "$p\pins\source-tp150.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot149b/quick149b/g2/frontend/l2trans.exe" "$P2/cold-boot149b/quick149b/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp150-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c", "$p\cold-tp140\src\l2src\lmx_source_names.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL150 ' + $label + ' exit=' + $e)
exit 0
