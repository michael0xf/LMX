try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 350 (M6 4b, part 2). source72 = source71 with the needles of the six P0 refusal rows written as the
# translator prints a parse error of the main file: `parse error 33 at L:C: the operator := is removed: ...` (no file
# name; low350 measured the messages and positions).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$tool="$p\cold-graph309-codex01\tool45\lmxtool-tool.exe"
$man="$P2/pins/opus350-source72.sha256"
$log="$p\pins\opus350-stage72.log"
$cwd="$p\runs\opus350"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $log) -or (Test-Path -LiteralPath "$p\pins\opus350-source72.sha256")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '9378BE3E54549CD6FFACB40183945528D0F9D99985CA533062680DB2F1803ED8') { throw 'tool hash' }
Set-Location -LiteralPath $cwd
"CWD=$P2/runs/opus350" | Out-File -LiteralPath $log -Encoding utf8
& $tool 0 entry 0 -- manifest "$R/selfbuild/inputs.list" "$R/selfbuild" $man *>> $log
$e=$LASTEXITCODE
"manifest exit $e" | Out-File -LiteralPath $log -Append -Encoding utf8
if ($e -ne 0) { exit $e }
& $tool 0 entry 0 -- stage-copy $man "$R/selfbuild" $S *>> $log
$e=$LASTEXITCODE
"stage-copy exit $e" | Out-File -LiteralPath $log -Append -Encoding utf8
if ($e -ne 0) { exit $e }
& $tool 0 entry 0 -- verify $man $S *>> $log
$e=$LASTEXITCODE
"verify exit $e" | Out-File -LiteralPath $log -Append -Encoding utf8
Write-Output ('STAGE72 exit=' + $e)
exit $e
