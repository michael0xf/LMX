try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 265. tp127-tool.command uses the verified boot126a seed and the tp127 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot126a\quick126a\lmxtool.exe"
$fe="$p\cold-boot126a\quick126a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot126a\quick126a\g2\runtime"
$term="$p\pins\tp127-tool-$try.terminal.txt"
$run="$p\tp127-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp127\tool127") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'ce43e24f740d7083c2c5d524deaec1a6fc8253ae2039420adda860a566b2efd2') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'bdcc42ff6c9ca0aa895dd7d0197a623fc0f7cecdc0d7775bffc839ab2228ae1c') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '1db4884783710cd4424f2fcf23a32a7a015beb77ebd88bfb371b23bd7f4dbb1a' -or (ShaTp "$rt\driver-observe.o") -ne 'f4eafb53512301bfb64baa0cc53d1884cb87d014ecbaf8dc0bd10b94803fb756') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp127-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp127\tools\build.lm2") + ' source-tp127 ' + (ShaTp "$p\pins\source-tp127.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp127" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot126a/quick126a/g2/frontend/l2trans.exe" "$P2/cold-boot126a/quick126a/g2/runtime" tool127 "$P2/cold-tp127/tests/smoke-kernel225.tsv" *> "$p\pins\tp127-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp127\tool127\lmxtool-tool.exe", "$p\cold-tp127\tool127\lmxtool.lm1", "$p\cold-tp127\tool127\lmxtool.c", "$p\cold-tp127\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL127 exit=' + $e)
exit $e
