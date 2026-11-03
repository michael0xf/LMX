try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 274. rebuild tool of the stage cold-tp136 with the verified boot135a tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot135a\quick135a\lmxtool.exe"
$fe="$p\cold-boot135a\quick135a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot135a\quick135a\g2\runtime"
$term="$p\pins\tp136-tool-$try.terminal.txt"
$run="$p\tp136-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp136\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'edbba01de59e68f74038d6c67cd5d3d618357159189554c5c2f7011c19c307c2') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'e53a3b0142b1306a6a55c0bbfb628a4acaebc7277723c39ec85c1d0c68da8518') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '2417e433153a9b4a7ffb6531d1dbdb92800a228cb9e01ec68abb90d3171a0248' -or (ShaTp "$rt\driver-observe.o") -ne '5ba219c73c9724c620de322e4dbba98ac4340213d53bd26b37fcba16f5970c0c') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp136\tools\build.lm2") + ' source-tp136 ' + (ShaTp "$p\pins\source-tp136.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp136" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot135a/quick135a/g2/frontend/l2trans.exe" "$P2/cold-boot135a/quick135a/g2/runtime" $label "$P2/cold-tp136/tests/smoke-kernel225.tsv" *> "$p\pins\tp136-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp136\$label\lmxtool-tool.exe", "$p\cold-tp136\$label\lmxtool.lm1", "$p\cold-tp136\$label\lmxtool.c", "$p\cold-tp136\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL136 ' + $label + ' exit=' + $e)
exit 0
