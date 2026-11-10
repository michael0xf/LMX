try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 345 (M6 4a). named345b: the suite rows of opus345-named2.tsv (the fixtures migrated from := to a: value and
# named_assign_refused; stage source58) by fehost15 with rt73, before the bootstrap.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$B="$P2/cold-candidate48/full48/g2/frontend"
$tool="$p\cold-graph309-codex01\tool47\lmxtool-tool.exe"
$fe="$S/fehost15/l2trans.exe"
$term="$p\pins\opus345-named345b.terminal.txt"
$cwd="$p\runs\opus345"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath "$p\cold-graph309-codex01\named345b")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '4C9F7B184EA7B7F24A55D1727F7D2F4ECEFEA40FE11C6B96F05BB9DF273328DD') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start suite named345b cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- suite "$P2/pins/opus345-named2.tsv" $R $S $B $fe "$S/rt73/driver.o" "$S/named345b" "$S/rt73/driver-observe.o" *> "$p\pins\opus345-named345b.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('NAMED345B exit=' + $e)
exit $e
