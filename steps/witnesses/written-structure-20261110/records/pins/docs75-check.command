try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 346 (M6 4c). docs75-check runs the language docs check on the staged index (slice 346 staged:
# kernel-implementation RU/EN, bugs_for_fixing, next_core_tasks_v3, steps/current.md, the witness
# written-structure-20261110) with tool48, the tool of the slice's tuple.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-graph309-codex01\tool48\lmxtool-tool.exe"
$term="$p\pins\docs75-check.terminal.txt"
$cwd="$p\docs75-check-run-01"
$out="$p\docs75-out-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'E395CA70BE82C82663D1D3381BD4F059D1A1CB390563ADC57378C7AFC52D9953') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check cwd=' + (Get-Location).Path) -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs75-out-01" *> "$p\pins\docs75-check.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS75CHECK exit=' + $e)
exit $e
