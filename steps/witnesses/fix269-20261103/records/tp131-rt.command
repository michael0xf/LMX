# Codex, slice 269: runtime with the new tool131 generated unary-op header.
try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-tp131\tool131\lmxtool-tool.exe"
$fe="$p\cold-boot130a\quick130a\g2\frontend\l2trans.exe"
$term="$p\pins\tp131t-rt-$try.terminal.txt"
$run="$p\tp131t-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp131\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '16e0cdb8849a2d2b36ac89db560b88a9ec195ca51edb9b9f1ca2c410fcd099c4') { throw 'working tool hash' }
if ((ShaTp $fe) -ne 'ec3e0ae8a19f8f61114b425fc6374d9e46291b95891fe77029d2703dc7434e18') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp131\src\l2src\lmx_walk_values.lm2") + ' driver.lm2 ' + (ShaTp "$p\cold-tp131\src\l2src\l2_driver.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp131\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp131" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot130a/quick130a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp131t-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp131\$label\driver.o", "$p\cold-tp131\$label\driver-observe.o", "$p\cold-tp131\src\l2src\lmx.h.lm1", "$p\cold-tp131\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp131\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp131\$label\record.txt" | Select-Object -Last 6 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('RT131 ' + $label + ' exit=' + $e)
exit $e
