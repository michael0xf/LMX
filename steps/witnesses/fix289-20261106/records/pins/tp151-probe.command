try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. Runs a named row list of fixtures on the stage cold-tp140 by the language suite (lmxtool suite); its log is
# the receipt (no PS filtering of it). Parameters: TP_TRY (attempt label), TP_LIST (a file under pins). TP_TOOL, TP_FE and
# TP_RT are optional overrides of the tool, the frontend executable and the runtime directory (paths relative to P), for a
# candidate tuple; the defaults are the working boot150a tool and its G2 frontend and runtime.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$Q="$P2/cold-boot150a/quick150a"
$try=$env:TP_TRY
$listName=$env:TP_LIST
if (-not $try -or -not $listName) { throw 'TP_TRY TP_LIST' }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
if ($env:TP_TOOL) { $tool=$p + '\' + ($env:TP_TOOL -replace '/','\') }
$fe="$Q/g2/frontend/l2trans.exe"
if ($env:TP_FE) { $fe="$P2/" + $env:TP_FE }
$rt="$Q/g2/runtime"
if ($env:TP_RT) { $rt="$P2/" + $env:TP_RT }
$term="$p\pins\tp151-probe-$try.terminal.txt"
$run="$p\tp151-probe-$try-run"
$out="$P2/tp151-probe/$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $run) -or (Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\tp151-probe\$try")) { throw 'exists' }
if ((Test-Path -LiteralPath $tool,($fe -replace '/','\'),(($rt -replace '/','\') + '\driver.o'),(($rt -replace '/','\') + '\driver-observe.o'),"$p\pins\$listName") -contains $false) { throw 'an input is missing' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
Copy-Item -LiteralPath "$p\pins\$listName" -Destination "$p\cold-tp140\tests\$listName"
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp "$rt/driver.o") + ' obs ' + (ShaTp "$rt/driver-observe.o") + ' list ' + (ShaTp "$p\pins\$listName") + ' PreVMKiB ' + $os.FreeVirtualMemory + ' PrePhysKiB ' + $os.FreePhysicalMemory) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- suite "$P2/cold-tp140/tests/$listName" $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" $fe "$rt/driver.o" $out "$rt/driver-observe.o" *> "$p\pins\tp151-probe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' SuiteExit ' + $e) -Encoding utf8
Write-Output ('PROBE151 exit=' + $e)
exit 0
