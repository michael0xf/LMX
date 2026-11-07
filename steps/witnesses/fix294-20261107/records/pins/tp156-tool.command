try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 294. `rebuild tool` of the stage cold-tp140 (its tools/build.lm2 exports lmx_call_bind_actuals in the
# walk_value_names list, 169 names) with the verified boot155a tuple. Parameters TP_LABEL (output directory under the stage)
# and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot155a\quick155a\lmxtool.exe"
$fe="$p\cold-boot155a\quick155a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot155a\quick155a\g2\runtime"
$term="$p\pins\tp156-tool-$try.terminal.txt"
$run="$p\tp156-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '179f0b3dc9b56f110ce4b018a8310be83637fa088d1234468071967c72aa8150') { throw 'tool hash' }
if ((ShaTp $fe) -ne '1901bf61787f5527f26f03815abb44c3c2ab8b659d9739a231068a8b8c929bd5') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '4135026a350b140a779e7877cf7f6ff5fd3c66474a79d56182aeb3e7de8abca9' -or (ShaTp "$rt\driver-observe.o") -ne 'abe916b86bfca50db7031f8a6ce78b19cf6ec35c76f3ebbf0a4cb24ac721887d') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp156-a01 ' + (ShaTp "$p\pins\source-tp156-a01.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot155a/quick155a/g2/frontend/l2trans.exe" "$P2/cold-boot155a/quick155a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp156-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL156 ' + $label + ' exit=' + $e)
exit 0
