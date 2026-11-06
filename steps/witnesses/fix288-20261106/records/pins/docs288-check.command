try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 288. The language docs check with the verified working tool of the slice's whole (TP_BOOT names boot150<try>,
# TP_TOOLSHA its working tool's sha256). It reads the git index: run it only after `git add --pathspec-from-file` of the
# slice's exact allowlist (CODEX-OPUS-286-DOCS-ADDENDUM-20261106T0930Z-02). Parameter TP_TRY (a label of the run).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY; $boot=$env:TP_BOOT; $toolSha=$env:TP_TOOLSHA
if (-not $try -or -not $boot -or -not $toolSha) { throw 'parameters TP_TRY TP_BOOT TP_TOOLSHA' }
$tool="$p\cold-boot150$boot\quick150$boot\lmxtool.exe"
$term="$p\pins\docs288-check-$try.terminal.txt"
$cwd="$p\docs288-check-$try-run-01"
$out="$p\docs288-out-$try"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $cwd) -or (Test-Path -LiteralPath $out)) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne $toolSha.ToUpperInvariant()) { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $out | Out-Null
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' start docs check') -Encoding utf8
& $tool 0 entry 0 -- docs check $repo 'C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt' 'C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt' 'C:/Git/cmd/git.exe' "$P2/docs288-out-$try" *> "$p\pins\docs288-check-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " exit=$e") -Encoding utf8
Write-Output ('DOCS288CHECK ' + $try + ' exit=' + $e)
exit $e
