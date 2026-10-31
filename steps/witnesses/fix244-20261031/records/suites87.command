try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE87 with RT87 on their own stage87 (kernel declaration headers regenerated
# by RT87 from writer85): held78 first, then the two draft79 witnesses (FE85
# refused both at L2: a split-call pointer place, an unsupported body at a
# return), then owner73c (long compile).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator85\tool85-parts\lmxtool-tool.exe"
$term="$p\pins\suites87.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate87\fe87\l2trans.exe")) { throw 'nofe87' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate87\rt87\driver.o")) { throw 'nort87' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$suiteRows = @(
  ,@('held-forward78', 'held-forward78.tsv')
  ,@('no-candidate79', 'no-candidate79.tsv')
  ,@('computed-absence79', 'computed-absence79.tsv')
  ,@('owner-values73c-hidden55', 'owner-values73c-callable-hidden55.tsv')
)
foreach ($suiteRow in $suiteRows) {
  $name="$($suiteRow[0])-fe87-rt87-suite"
  $out="$p\$name-01"
  $cwd="$p\$name-run-01"
  if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
  $argv=@('suite', "$P2/pins/$($suiteRow[1])", $repo, "$P2/cold-candidate87", "$P2/cold-candidate48/full48/g2/frontend", "$P2/cold-candidate87/fe87/l2trans.exe", "$P2/cold-candidate87/rt87/driver.o", "$P2/$name-01", "$P2/cold-candidate87/rt87/driver-observe.o")
  if ($argv.Count -ne 9) { throw "argv $($argv.Count)" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name argv: 0 entry 0 -- " + ($argv -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @argv *> "$p\pins\$name-01.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
}
Write-Output 'SUITES87 done'
