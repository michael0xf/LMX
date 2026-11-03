try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 264. tp126-tool.command uses the verified boot125a seed and the tp126 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot125a\quick125a\lmxtool.exe"
$fe="$p\cold-boot125a\quick125a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot125a\quick125a\g2\runtime"
$term="$p\pins\tp126-tool-$try.terminal.txt"
$run="$p\tp126-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp126\tool126") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '9e5798d8bd55e57a89242fdad0624c2af9bdf5ce27396624a79f72dcea0766ea') { throw 'tool hash' }
if ((ShaTp $fe) -ne '567edce7d75b6c8a79ea245640fda2d7cda78e11dd5d2148e60b96cff14ae7a2') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'a05db426eecb50a079615944dcc23363b57438c9562ab194f721ed0dd26c68ac' -or (ShaTp "$rt\driver-observe.o") -ne '2ec4a637d0b7b6bf4523c7899557c4677d8b05bfdcfc91b4901d31967a271e33') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp126-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp126\tools\build.lm2") + ' source-tp126 ' + (ShaTp "$p\pins\source-tp126.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp126" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot125a/quick125a/g2/frontend/l2trans.exe" "$P2/cold-boot125a/quick125a/g2/runtime" tool126 "$P2/cold-tp126/tests/smoke-kernel225.tsv" *> "$p\pins\tp126-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp126\tool126\lmxtool-tool.exe", "$p\cold-tp126\tool126\lmxtool.lm1", "$p\cold-tp126\tool126\lmxtool.c", "$p\cold-tp126\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL125 exit=' + $e)
exit $e
