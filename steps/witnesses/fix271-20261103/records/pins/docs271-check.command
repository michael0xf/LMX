try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 271. docs271-check uses the verified boot133a working tool.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot133a\quick133a\lmxtool.exe"
$term="$p\pins\docs271-check.terminal.txt"
$cwd="$p\docs271-check-run-01"
$out="$p\docs271-out-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '743FA9D478DB1E18719140FD63A9E254B646BA28CD0762B9293470B2E2371850') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check') -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs271-out-01" *> "$p\pins\docs271-check.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS271CHECK exit=' + $e)
exit $e
