try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 271. tp133-tool.command uses the verified boot132c seed and the tp133 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot132c\quick132c\lmxtool.exe"
$fe="$p\cold-boot132c\quick132c\g2\frontend\l2trans.exe"
$rt="$p\cold-boot132c\quick132c\g2\runtime"
$term="$p\pins\tp133-tool-$try.terminal.txt"
$run="$p\tp133-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp133\tool133b") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '2e936543ab9c36c842b03c489052b44a6bcaa3110f8018851f2ee07f7f49ba26') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'fa22765b71e99c1e2f5b4eb0f01588eec5859e9d30405945492a73dece09b99d') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '5a39a205a07e4e40b185251811ac2897b1ff22660d1224f04637f25deef06ada' -or (ShaTp "$rt\driver-observe.o") -ne '60ff05dd4bff4c1567775b10c4ec5348a4f614a2eb697756fca2e38cd1b99adb') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp133-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp133\tools\build.lm2") + ' source-tp133 ' + (ShaTp "$p\pins\source-tp133.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp133" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot132c/quick132c/g2/frontend/l2trans.exe" "$P2/cold-boot132c/quick132c/g2/runtime" tool133b "$P2/cold-tp133/tests/smoke-kernel225.tsv" *> "$p\pins\tp133-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp133\tool133b\lmxtool-tool.exe", "$p\cold-tp133\tool133b\lmxtool.lm1", "$p\cold-tp133\tool133b\lmxtool.c", "$p\cold-tp133\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL132 exit=' + $e)
exit $e
