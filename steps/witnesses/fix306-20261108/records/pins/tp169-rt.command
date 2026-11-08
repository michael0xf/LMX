try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 306 (CALL-ENTRY-ADMISSION-ORDER). build-runtime of the stage cold-tp140 (its kernel: lmx_call_receive_formal -- the reception of
# every non-number actual by the selected formal at the call site, called by the walker's static and selected calls and by lmx_call_bind_receive)
# with the published boot168a tool (tools/build.lm2 unchanged) and the published boot168a G2 frontend. Parameters TP_LABEL (output directory
# under the stage), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot168a\quick168a\lmxtool.exe"
$fe="$p\cold-boot168a\quick168a\g2\frontend\l2trans.exe"
$term="$p\pins\tp169-rt-$try.terminal.txt"
$run="$p\tp169-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '66e2cfa6d461aa5c32d6fb2583175e6db38bc534ebedfd22ed9198b58ed71c70') { throw 'tool hash' }
if ((ShaTp $fe) -ne '10e57567e82b09295255df6d6e533af72ac52e979f20a17f94dd3839a064ca68') { throw 'frontend hash' }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\lmx_walk_values.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' PreVMKiB ' + $os.FreeVirtualMemory + ' PrePhysKiB ' + $os.FreePhysicalMemory) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot168a/quick168a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp169-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\driver.o", "$p\cold-tp140\$label\driver-observe.o", "$p\cold-tp140\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('RT169 ' + $label + ' exit=' + $e)
exit 0
