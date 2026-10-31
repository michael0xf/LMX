try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE82 (Lower82: D1 element-address sentinel, D2 formal_raw spelling) on the
# support stage71 with RT71. owner73b = owner73 with the two local observation
# bridges agreed in CODEX-OPUS-81ANS (BARE-DEREF-ACTUAL-MERGED stays OPEN).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\suites82-stage71.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate82\fe82\l2trans.exe")) { throw 'nofe82' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$suiteRows = @(
  ,@('owner-values73b-hidden55', 'owner-values73b-callable-hidden55.tsv')
  ,@('held-forward78', 'held-forward78.tsv')
)
foreach ($suiteRow in $suiteRows) {
  $name="$($suiteRow[0])-fe82-stage71-suite"
  $out="$p\$name-01"
  $cwd="$p\$name-run-01"
  if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
  $argv=@('suite', "$P2/pins/$($suiteRow[1])", $repo, "$P2/cold-candidate71", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-candidate82/fe82/l2trans.exe", "$P2/cold-candidate71/rt71/driver.o", "$P2/$name-01", "$P2/cold-candidate71/rt71/driver-observe.o")
  if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
}
Write-Output 'SUITES82 done'
