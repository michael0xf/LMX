# Opus, slice 275. Detached launcher of one whole-list suite on the candidate tuple (the record runs in a child pwsh, its exit cannot end this launcher).
$pwsh='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$pins='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01\pins'
$term="$pins\tp137-full-detached.terminal.txt"
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$env:TP_TRY='f01'
$env:TP_LIST='fullsuite137.tsv'
$env:TP_FE='cold-tp137/fe137d/l2trans.exe'
$env:TP_TOOL='cold-tp137/tool137a/lmxtool-tool.exe'
$env:TP_RT='cold-tp137/rt137d'
& $pwsh -NoProfile -NonInteractive -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('$pins\tp137-probe.command')))" *>> $term
$code=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EXIT=' + $code) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
