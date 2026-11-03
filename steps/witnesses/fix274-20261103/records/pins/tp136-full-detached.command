# Opus, slice 274. Detached launcher of one whole-list suite on the candidate tuple (the record runs in a child pwsh, its exit cannot end this launcher).
$pwsh='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$pins='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01\pins'
$term="$pins\tp136-full-detached.terminal.txt"
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$env:TP_TRY='full01'
$env:TP_LIST='fullsuite136.tsv'
$env:TP_FE='cold-tp136/fe136a/l2trans.exe'
$env:TP_TOOL='cold-tp136/tool136b/lmxtool-tool.exe'
$env:TP_RT='cold-tp136/rt136e'
& $pwsh -NoProfile -NonInteractive -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('$pins\tp136-probe.command')))" *>> $term
$code=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EXIT=' + $code) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
