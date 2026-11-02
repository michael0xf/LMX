try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp118 rt (fable_pc): the isolated runtime build of the candidate's kernel (label TP_LABEL: rt118, rt118b, ...) before the long
# builds -- boot117a's G2 working tool (4E1D96D4; tools/build.lm2 is the landed one) with boot117a's G2 frontend (1113EE3B): the
# stage's declaration headers are rewritten first (decls_write_all), then the kernel's L2 modules (lmx_walk_values with the
# result place receiving references), the driver, the C headers and the driver objects, all under cold-tp118/<label>.  A refusal
# of the kernel's L2 or of its C compile is conclusive here in a minute.  Fresh CWD.  Parameters: TP_LABEL, TP_TRY (the
# terminal's suffix).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot117a\quick117a\lmxtool.exe"
$fe="$p\cold-boot117a\quick117a\g2\frontend\l2trans.exe"
$term="$p\pins\tp118-rt-$try.terminal.txt"
$run="$p\tp118-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp118\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4e1d96d4c939ceaa2721abd1413efaa93feb4cc5bb7e318eeaff87bb3af5aa68') { throw 'working tool hash' }
if ((ShaTp $fe) -ne '1113ee3b03b5e76895046078d8a4959bf34d6bb86bc26ac3e416553c09b39520') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\lmx_walk_values.lm2") + ' driver.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\l2_driver.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp118\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp118" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot117a/quick117a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp118-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp118\$label\driver.o", "$p\cold-tp118\$label\driver-observe.o", "$p\cold-tp118\src\l2src\lmx.h.lm1", "$p\cold-tp118\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp118\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp118\$label\record.txt" | Select-Object -Last 6 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('RT118 ' + $label + ' exit=' + $e)
exit $e
