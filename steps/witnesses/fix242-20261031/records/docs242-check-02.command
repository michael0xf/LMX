try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Attempt 02 of the ordinary full docs check with the working G2 tool (FULL48,
# A6D5EC40). Attempt 01 (docs242-check.command) gave exit1 without any
# diagnostic after 18 s: its PRIVATE_OUT directory did not exist, and the EOL
# phase cannot create docs-eol.stdout there (slice241 had created its
# docs241-out-01 before the run). Here the fresh empty directory is created
# first, as there. Fresh private CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-candidate48\full48\lmxtool.exe"
$term="$p\pins\docs242-check-02.terminal.txt"
$cwd="$p\docs242-check-run-02"
$out="$p\docs242-out-02"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check') -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs242-out-02" *> "$p\pins\docs242-check-02.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS242CHECK02 exit=' + $e)
exit $e
