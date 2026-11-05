try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 284. rebuild tool of the stage cold-tp140 with the verified boot145a tuple. Parameters TP_LABEL (output directory
# under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot145a\quick145a\lmxtool.exe"
$fe="$p\cold-boot145a\quick145a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot145a\quick145a\g2\runtime"
$term="$p\pins\tp146-tool-$try.terminal.txt"
$run="$p\tp146-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6d0c44248c1e5b2de37990ea1875d29591c8f475391dc4f4dc7e011f8efbe0a2') { throw 'tool hash' }
if ((ShaTp $fe) -ne '568b28408d93a51f69182d259e6bbc0eacb00a5b22d232a8c12023f275575281') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '194a251fd9815647a9f1e8643613f0429d78f75d5295e532710462ee9e9f68de' -or (ShaTp "$rt\driver-observe.o") -ne '9a8e1e053cd0de000920953a3d3d3c83a0090a6fca66b9d0a9d6ca69788a3eab') { throw 'runtime objects hash' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp146 ' + (ShaTp "$p\pins\source-tp146.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot145a/quick145a/g2/frontend/l2trans.exe" "$P2/cold-boot145a/quick145a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp146-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c", "$p\cold-tp140\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL146 ' + $label + ' exit=' + $e)
exit 0
