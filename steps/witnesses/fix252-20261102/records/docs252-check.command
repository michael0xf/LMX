try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The ordinary full docs check for slice252 (full99's failure, the fix coherent100 and full100 in build2) with the
# promoted working tool of boot114 (G2's, 6619A503), the slice files in the Git
# index. Its fresh empty PRIVATE_OUT is created first
# (DOCS-CHECK-PRIVATE-OUT-SILENT stays open). Fresh private CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\docs252-check.terminal.txt"
$cwd="$p\docs252-check-run-01"
$out="$p\docs252-out-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '6619A5036E02987FCD7D88BCF25029398F93C0C94B981D5D47EB48BA6F2A8027') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check') -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs252-out-01" *> "$p\pins\docs252-check.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS252CHECK exit=' + $e)
exit $e
