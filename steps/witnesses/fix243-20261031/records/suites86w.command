try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE84 with RT86w (walker86: the activation takes the callee's own input
# width; an input the caller did not hand is absent) on its own support
# stage86w (the kernel declaration headers RT86w regenerated). held78 first
# (the hidden-input entry witness, cheap), then owner73c (owner73b with the
# V64 in-place cell write).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator84\tool84-parts\lmxtool-tool.exe"
$term="$p\pins\suites86w.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate84\fe84\l2trans.exe")) { throw 'nofe84' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate86w\rt86w\driver.o")) { throw 'nort86w' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$suiteRows = @(
  ,@('held-forward78', 'held-forward78.tsv')
  ,@('owner-values73c-hidden55', 'owner-values73c-callable-hidden55.tsv')
)
foreach ($suiteRow in $suiteRows) {
  $name="$($suiteRow[0])-fe84-rt86w-suite"
  $out="$p\$name-01"
  $cwd="$p\$name-run-01"
  if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
  $argv=@('suite', "$P2/pins/$($suiteRow[1])", $repo, "$P2/cold-candidate86w", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-candidate84/fe84/l2trans.exe", "$P2/cold-candidate86w/rt86w/driver.o", "$P2/$name-01", "$P2/cold-candidate86w/rt86w/driver-observe.o")
  if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
}
Write-Output 'SUITES86W done'
