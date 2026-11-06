try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. The existing language-owned walker observation (lmxtool os-walk-witness) of one fixture of the stage
# cold-tp140; its log and its own output directory are the receipt (no PS filtering). Parameters: TP_FE (frontend executable,
# path under P), TP_RT (runtime directory under P), TP_TRY, TP_SOURCE (a path under the stage's tests), TP_SPEC
# (name=count,...), TP_ENTRY. The working boot150a tool runs it.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feRel=$env:TP_FE; $rtRel=$env:TP_RT; $try=$env:TP_TRY; $srcRel=$env:TP_SOURCE; $spec=$env:TP_SPEC; $entry=$env:TP_ENTRY
if (-not $feRel -or -not $rtRel -or -not $try -or -not $srcRel -or -not $spec -or -not $entry) { throw 'parameters TP_FE TP_RT TP_TRY TP_SOURCE TP_SPEC TP_ENTRY' }
$tool="$p\cold-boot150a\quick150a\lmxtool.exe"
$fe="$P2/$feRel"
$prod="$P2/$rtRel/driver.o"
$obs="$P2/$rtRel/driver-observe.o"
$source="$P2/cold-tp140/tests/$srcRel"
$term="$p\pins\tp151-obs-$try.terminal.txt"
$run="$p\tp151-obs-$try-run-01"
$out="$P2/tp151-obs/obs151-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp151-obs\obs151-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'eb11e493de980d1339cb9caa11236054adae37b63c78a07240d211b977bc3a2a') { throw 'working tool hash' }
if ((Test-Path -LiteralPath ($fe -replace '/','\'),($prod -replace '/','\'),($obs -replace '/','\'),($source -replace '/','\')) -contains $false) { throw 'an input is missing' }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' source ' + $srcRel + ' ' + (ShaTp $source) + ' spec ' + $spec + ' entry ' + $entry) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- os-walk-witness $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" $fe $prod $obs $source $out $entry $spec *> "$p\pins\tp151-obs-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' WitnessExit ' + $e) -Encoding utf8
Write-Output ('OBS151 ' + $try + ' exit=' + $e)
exit $e
