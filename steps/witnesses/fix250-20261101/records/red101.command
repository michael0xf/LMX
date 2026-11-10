try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# RED side of the working-place sibling (Codex CODEX-OPUS-250-POINTER-20261101-ANSWER01): the witness
# pointer-copy101 (variants/working-pointer101/unit_pointer_context_copy.lm2: a pointer own's bare assignment by a
# literal and by a pointer step, then an own copy and an ordinary argument; a number formal and a pointer formal
# assigned, then copied into an own) with source-full100's own frontend and runtime (full100 G2), stage
# cold-full100, BASE full48/g2/frontend. Nothing is rebuilt. Expected if the sibling is real: native fails (81 or
# 91 or 101 or 111), forced gives 7. Tool: full100's promoted working tool. The first serial step after full100.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\red101.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
foreach ($x in @($tool, "$p\cold-full100\full100\g2\frontend\l2trans.exe", "$p\cold-full100\full100\g2\runtime\driver.o", "$p\cold-full100\full100\g2\runtime\driver-observe.o", "$p\cold-full100\headers")) {
  if (-not (Test-Path -LiteralPath $x)) { throw ('missing: ' + $x) }
}
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\variants\working-pointer101\unit_pointer_context_copy.lm2").Hash -ne '30EA66CE7205535A0E911C67DE09677533D3297935F91BE7F3D62C0310B094B1') { throw 'witness hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\pointer-copy101.tsv").Hash -ne '53E127027A95C7EE5B0443934F6E175B00D674712670B848F3EFBA31F2EA3618') { throw 'list hash' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$name='pointer-copy101-full100-suite'
$out="$p\$name-01"
$cwd="$p\$name-run-01"
if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
$argv=@('suite', "$P2/pins/pointer-copy101.tsv", $repo, "$P2/cold-full100", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-full100/full100/g2/frontend/l2trans.exe", "$P2/cold-full100/full100/g2/runtime/driver.o", "$P2/$name-01", "$P2/cold-full100/full100/g2/runtime/driver-observe.o")
if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name tool " + (Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash + " argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
& $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
Write-Output 'RED101 done'
