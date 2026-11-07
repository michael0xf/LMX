try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 301. build-runtime of the stage cold-tp140 (its kernel's lmx_walk_values: the one reception of a number by the
# formal a call selected, lmx_walk_receive_selected, with the routes of the native binder's arrays and of the walked NAMED
# operand) with the working boot162a tool and its G2 frontend (tools/build.lm2 is unchanged by 301). Parameters TP_LABEL
# (output directory under the stage), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot162a\quick162a\lmxtool.exe"
$fe="$p\cold-boot162a\quick162a\g2\frontend\l2trans.exe"
$term="$p\pins\tp163-rt-$try.terminal.txt"
$run="$p\tp163-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'c6deabf9f79476dd807a1ad9629edb5ff8691899136d2f54108a4bd4c815a6ee') { throw 'tool hash' }
if ((ShaTp $fe) -ne '089896a82695201927a3a3530d5a22c9a38f47f8176681e704047a60006eff4d') { throw 'frontend hash' }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' tool ' + (ShaTp $tool) + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\lmx_walk_values.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' PreVMKiB ' + $os.FreeVirtualMemory + ' PrePhysKiB ' + $os.FreePhysicalMemory) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot162a/quick162a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp163-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\driver.o", "$p\cold-tp140\$label\driver-observe.o", "$p\cold-tp140\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('RT163 ' + $label + ' exit=' + $e)
exit 0
