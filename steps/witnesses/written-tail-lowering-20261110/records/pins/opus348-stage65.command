try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 348 (M6 4c lowering, route (a)). source65 = the repo at bb79d31a + try 1 of the ready written Structure tail
# among the actuals (binder structured 2, the check and scan skips, lm_compiler_rw_ready_tail in the code construction,
# lm_compiler_emit_ready_tail in the native actuals).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$tool="$p\cold-graph309-codex01\tool45\lmxtool-tool.exe"
$man="$P2/pins/opus348-source65.sha256"
$log="$p\pins\opus348-stage65.log"
$cwd="$p\runs\opus348"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $log) -or (Test-Path -LiteralPath "$p\pins\opus348-source65.sha256")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '9378BE3E54549CD6FFACB40183945528D0F9D99985CA533062680DB2F1803ED8') { throw 'tool hash' }
Set-Location -LiteralPath $cwd
"CWD=$P2/runs/opus348" | Out-File -LiteralPath $log -Encoding utf8
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
Write-Output ('STAGE65 exit=' + $e)
exit $e
