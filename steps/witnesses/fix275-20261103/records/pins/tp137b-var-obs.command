# Opus, slice 275. Clone of tp132c-var-obs with the boot137b names. Existing language-owned walker observation, same fixture and pipeline.
try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feLabel=$env:TP_FE; $rtLabel=$env:TP_RT; $try=$env:TP_TRY; $srcRel=$env:TP_SOURCE; $spec=$env:TP_SPEC; $entry=$env:TP_ENTRY
if (-not $feLabel -or -not $rtLabel -or -not $try -or -not $srcRel -or -not $spec -or -not $entry) { throw 'parameters TP_FE TP_RT TP_TRY TP_SOURCE TP_SPEC TP_ENTRY' }
$tool="$p\cold-boot137b\quick137b\lmxtool.exe"
$fe="$p\cold-boot137b\$feLabel\l2trans.exe"
$prod="$p\cold-boot137b\$rtLabel\driver.o"
$obs="$p\cold-boot137b\$rtLabel\driver-observe.o"
$source="$P2/cold-boot137b/tests/$srcRel"
$term="$p\pins\tp137b-obs-$try.terminal.txt"
$run="$p\tp137b-obs-$try-run-01"
$out="$P2/tp137b-obs/obs137b-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp137b-obs\obs137b-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3717f62bb0e65568bc187b59d6c316f16187c2bb9e405b7630c28f6c7659a507') { throw 'working tool hash' }
foreach ($f in @($fe, $prod, $obs, "$p\cold-boot137b\tests\$srcRel")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' source ' + $srcRel + ' ' + (ShaTp "$p\cold-boot137b\tests\$srcRel") + ' spec ' + $spec + ' entry ' + $entry) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- os-walk-witness $R "$P2/cold-boot137b" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot137b/$feLabel/l2trans.exe" "$P2/cold-boot137b/$rtLabel/driver.o" "$P2/cold-boot137b/$rtLabel/driver-observe.o" $source $out $entry $spec *> "$p\pins\tp137b-obs-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' WitnessExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp137b-obs\obs137b-$try\failures.tsv") { Get-Content -LiteralPath "$p\tp137b-obs\obs137b-$try\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp137b-obs-$try.log" | Select-String -Pattern '^(PASS|FAIL)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('OBS137B ' + $try + ' exit=' + $e)
exit $e
