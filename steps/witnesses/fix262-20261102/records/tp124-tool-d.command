try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 262. tp124-tool.command uses the verified boot123a seed and the tp124 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot123a\quick123a\lmxtool.exe"
$fe="$p\cold-boot123a\quick123a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot123a\quick123a\g2\runtime"
$term="$p\pins\tp124-tool-d-$try.terminal.txt"
$run="$p\tp124-tool-d-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp124\tool124d") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1f12cdc16a5ce43200abcf0b4e4bc43bc60b1232a6ef3cfeb7c135be4d89d9db') { throw 'tool hash' }
if ((ShaTp $fe) -ne '8dd841a0903f2e9e10edd54d91170d9ea8609bd439abcc7dfa2380af15160886') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'daf6d813e3b08b7e7b9e75d607589f33fe9e4ac6a7c0afddccaf16eb3b1f5274' -or (ShaTp "$rt\driver-observe.o") -ne 'ff6dcbd9aa1459b7c354592a897d9410aba07ca53bc771271ab31d31da47c988') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp124-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp124\tools\build.lm2") + ' source-tp124 ' + (ShaTp "$p\pins\source-tp124.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp124" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot123a/quick123a/g2/frontend/l2trans.exe" "$P2/cold-boot123a/quick123a/g2/runtime" tool124d "$P2/cold-tp124/tests/smoke-kernel225.tsv" *> "$p\pins\tp124-tool-d-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp124\tool124d\lmxtool-tool.exe", "$p\cold-tp124\tool124d\lmxtool.lm1", "$p\cold-tp124\tool124d\lmxtool.c", "$p\cold-tp124\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL124 exit=' + $e)
exit $e
