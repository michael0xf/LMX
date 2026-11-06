# Opus, slice 286. Detached launcher of the second whole quick, after the throws admission (the record runs in a child pwsh,
# its exit cannot end this launcher).
$pwsh='C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe'
$pins='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01\pins'
$term="$pins\boot148b-detached.terminal.txt"
Add-Content -LiteralPath $term -Value ('launcher ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
$env:TP_TRY='b'
& $pwsh -NoProfile -NonInteractive -Command "& ([ScriptBlock]::Create([IO.File]::ReadAllText('$pins\boot148-quick.command')))" *>> $term
$code=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EXIT=' + $code) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
