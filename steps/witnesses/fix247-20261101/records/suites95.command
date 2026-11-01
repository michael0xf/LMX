try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE94 (unchanged, chain94) with RT92 on stage92: no-candidate95 only -- the
# null holder written through by a method with no handler of its own (the raw
# store; the caller's handler takes it), read through the raw native route and
# stored through the checked route, each caught; the non-null split pointer.
# The other four suites already ran on this FE94 (suites94). Tool: generator93.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator93\tool93-parts\lmxtool-tool.exe"
$term="$p\pins\suites95.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate94\fe94\l2trans.exe")) { throw 'nofe94' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate92\rt92\driver.o")) { throw 'nort92' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$suiteRows = @(
  ,@('no-candidate95', 'no-candidate95.tsv')
)
foreach ($suiteRow in $suiteRows) {
  $name="$($suiteRow[0])-fe94-rt92-suite"
  $out="$p\$name-01"
  $cwd="$p\$name-run-01"
  if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
  $argv=@('suite', "$P2/pins/$($suiteRow[1])", $repo, "$P2/cold-candidate92", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-candidate94/fe94/l2trans.exe", "$P2/cold-candidate92/rt92/driver.o", "$P2/$name-01", "$P2/cold-candidate92/rt92/driver-observe.o")
  if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
}
Write-Output 'SUITES95 done'
