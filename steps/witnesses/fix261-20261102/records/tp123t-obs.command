try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp123t observed walk of one fixture (fable_pc, slice 261): `lmxtool os-walk-witness` of TP_SOURCE on the candidate's isolated
# frontend (TP_FE) and runtime objects (TP_RT), run by tool123 (573B37F0) from the stage cold-tp123; the observed forced run's
# log says `LMX_OBSERVE WALK_BODY <name>` at every walked body's entry.  TP_SPEC is the name=count list (at most 16 names).
# Fresh CWD.  Parameters: TP_FE, TP_RT, TP_TRY, TP_SOURCE (relative to the stage's tests/), TP_SPEC, TP_ENTRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$feLabel=$env:TP_FE; $rtLabel=$env:TP_RT; $try=$env:TP_TRY; $srcRel=$env:TP_SOURCE; $spec=$env:TP_SPEC; $entry=$env:TP_ENTRY
if (-not $feLabel -or -not $rtLabel -or -not $try -or -not $srcRel -or -not $spec -or -not $entry) { throw 'parameters TP_FE TP_RT TP_TRY TP_SOURCE TP_SPEC TP_ENTRY' }
$tool="$p\cold-tp123\tool123\lmxtool-tool.exe"
$fe="$p\cold-tp123\$feLabel\l2trans.exe"
$prod="$p\cold-tp123\$rtLabel\driver.o"
$obs="$p\cold-tp123\$rtLabel\driver-observe.o"
$source="$P2/cold-tp123/tests/$srcRel"
$term="$p\pins\tp123t-obs-$try.terminal.txt"
$run="$p\tp123t-obs-$try-run-01"
$out="$P2/tp123t-obs/obs123-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\tp123t-obs\obs123-$try") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '573b37f0211119d874c8bea82eca3509ea294faa1dfd0739d7611fdc6066716f') { throw 'working tool hash' }
foreach ($f in @($fe, $prod, $obs, "$p\cold-tp123\tests\$srcRel")) { if (-not (Test-Path -LiteralPath $f)) { throw ('missing: ' + $f) } }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' tool ' + (ShaTp $tool) + ' fe ' + (ShaTp $fe) + ' prod ' + (ShaTp $prod) + ' obs ' + (ShaTp $obs) + ' source ' + $srcRel + ' ' + (ShaTp "$p\cold-tp123\tests\$srcRel") + ' spec ' + $spec + ' entry ' + $entry) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- os-walk-witness $R "$P2/cold-tp123" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp123/$feLabel/l2trans.exe" "$P2/cold-tp123/$rtLabel/driver.o" "$P2/cold-tp123/$rtLabel/driver-observe.o" $source $out $entry $spec *> "$p\pins\tp123t-obs-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' WitnessExit ' + $e) -Encoding utf8
if (Test-Path -LiteralPath "$p\tp123t-obs\obs123-$try\failures.tsv") { Get-Content -LiteralPath "$p\tp123t-obs\obs123-$try\failures.tsv" | ForEach-Object { Add-Content -LiteralPath $term -Value ('  failure: ' + $_) -Encoding utf8 } }
Get-Content -LiteralPath "$p\pins\tp123t-obs-$try.log" | Select-String -Pattern '^(PASS|FAIL)' | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_.Line) -Encoding utf8 }
Write-Output ('OBS123 ' + $try + ' exit=' + $e)
exit $e
