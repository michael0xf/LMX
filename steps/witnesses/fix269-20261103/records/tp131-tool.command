try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 269. tp131-tool.command uses the verified boot130a seed and the tp131 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot130a\quick130a\lmxtool.exe"
$fe="$p\cold-boot130a\quick130a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot130a\quick130a\g2\runtime"
$term="$p\pins\tp131-tool-$try.terminal.txt"
$run="$p\tp131-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp131\tool131") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '31d55441805a79a36a93e6bb7ff842370b034fbc6d1f440c3a9ecc9702e46f43') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'ec3e0ae8a19f8f61114b425fc6374d9e46291b95891fe77029d2703dc7434e18') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'e617e95da4019c90a4b47adcb62ddfc79d9818d0729c4bb43b7ba7164a581c96' -or (ShaTp "$rt\driver-observe.o") -ne '84ef7a8471496a0225482985e773f856cf89f075b29ffcd0ff12409dc68bc774') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp131-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp131\tools\build.lm2") + ' source-tp131 ' + (ShaTp "$p\pins\source-tp131.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp131" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot130a/quick130a/g2/frontend/l2trans.exe" "$P2/cold-boot130a/quick130a/g2/runtime" tool131 "$P2/cold-tp131/tests/smoke-kernel225.tsv" *> "$p\pins\tp131-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp131\tool131\lmxtool-tool.exe", "$p\cold-tp131\tool131\lmxtool.lm1", "$p\cold-tp131\tool131\lmxtool.c", "$p\cold-tp131\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL131 exit=' + $e)
exit $e
