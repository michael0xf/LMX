try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 270. tp132g-tool.command uses the verified boot132b seed and the tp132 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot132b\quick132b\lmxtool.exe"
$fe="$p\cold-boot132b\quick132b\g2\frontend\l2trans.exe"
$rt="$p\cold-boot132b\quick132b\g2\runtime"
$term="$p\pins\tp132g-tool-$try.terminal.txt"
$run="$p\tp132g-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp132\tool132g") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4aae5f226b61d9e87643db2c9909babb8d1de369d779ed74bc7e0b7a94167ce6') { throw 'tool hash' }
if ((ShaTp $fe) -ne '8a41861fb97a5282baa055ddb5fa26619fb229d0bcf0722a762a4963cb364ecf') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '738e187f401a22571ac9cec0b794f716793e57ae2fb22530ce9c902fb6c8a672' -or (ShaTp "$rt\driver-observe.o") -ne 'df8cd15198bd47338a5ce3baff9894c6b4da360f9fb46f438082a727046711a4') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp132-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp132\tools\build.lm2") + ' source-tp132 ' + (ShaTp "$p\pins\source-tp132.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp132" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot132b/quick132b/g2/frontend/l2trans.exe" "$P2/cold-boot132b/quick132b/g2/runtime" tool132g "$P2/cold-tp132/tests/smoke-kernel225.tsv" *> "$p\pins\tp132g-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp132\tool132g\lmxtool-tool.exe", "$p\cold-tp132\tool132g\lmxtool.lm1", "$p\cold-tp132\tool132g\lmxtool.c", "$p\cold-tp132\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL132 exit=' + $e)
exit $e
