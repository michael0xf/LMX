# fable_pc, slice 303. Detached launcher of the whole quick boot165 (the record runs in a child pwsh, its exit cannot end this
# launcher). Parameter TP_TRY.
$pwsh='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$pins='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01\pins'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$term="$pins\boot165$try-detached.terminal.txt"
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
& $pwsh -NoProfile -NonInteractive -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('$pins\boot165-quick.command')))" *>> $term
$code=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EXIT=' + $code) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
