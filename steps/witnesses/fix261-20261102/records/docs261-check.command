try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The ordinary full docs check for slice261 (tp123: the address of a free name at any typed place by the kernel's own pointer
# code, received by a typed pointer place by the actual pointees at every level in both executors, P1-PTR-COVERAGE; boot123a)
# with the promoted working tool of boot123a (G2's, 1F12CDC1), the slice files in the Git index. Its fresh empty PRIVATE_OUT is
# created first (DOCS-CHECK-PRIVATE-OUT-SILENT stays open). Fresh private CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot123a\quick123a\lmxtool.exe"
$term="$p\pins\docs261-check.terminal.txt"
$cwd="$p\docs261-check-run-01"
$out="$p\docs261-out-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '1F12CDC16A5CE43200ABCF0B4E4BC43BC60B1232A6EF3CFEB7C135BE4D89D9DB') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check') -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs261-out-01" *> "$p\pins\docs261-check.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS261CHECK exit=' + $e)
exit $e
