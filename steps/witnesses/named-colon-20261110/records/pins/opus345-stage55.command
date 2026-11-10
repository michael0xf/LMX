try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 345 (M6 4a). source55 = source54 + the graph fixtures named_tail (with .expected) and named_tail_unsuitable,
# no code change (this comment corrected after the run: a rename had made it read source53); source54 = source53 + the
# Structure tail of a named actual (lmx_graph_literal_fields, lmx_graph_literal_value, lmx_graph_named_value exported, graph_run_names 41; the emitted tail by the kernel); source53 = the repo at ada27247 + the binder (lmx_graph_run: the
# named actual, := refused, lmx_graph_named_actual exported; l2_graph_tool: the emitted named actual; lowering:
# lm_compiler_named_actual_frame, := refused), the export list (tools/build.lm2: graph_run_names 40), the fixtures
# migrated from := to a: value, the new rows named_assign_refused (dyn, graph).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$S="$P2/cold-graph309-codex01"
$tool="$p\cold-graph309-codex01\tool45\lmxtool-tool.exe"
$man="$P2/pins/opus345-source55.sha256"
$log="$p\pins\opus345-stage55.log"
$cwd="$p\runs\opus345"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $log) -or (Test-Path -LiteralPath "$p\pins\opus345-source55.sha256")) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '9378BE3E54549CD6FFACB40183945528D0F9D99985CA533062680DB2F1803ED8') { throw 'tool hash' }
Set-Location -LiteralPath $cwd
"CWD=$P2/runs/opus345" | Out-File -LiteralPath $log -Encoding utf8
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
Write-Output ('STAGE55 exit=' + $e)
exit $e
