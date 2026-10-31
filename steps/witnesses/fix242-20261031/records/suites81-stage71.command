try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\suites81-stage71.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate81\fe81\l2trans.exe")) { throw 'nofe81' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$rows = @(
  ,@('owner-values73-hidden55', 'owner-values73-callable-hidden55.tsv')
  ,@('held-forward78', 'held-forward78.tsv')
)
foreach ($r in $rows) {
  $name="$($r[0])-fe81-stage71-suite"
  $out="$p\$name-01"
  $cwd="$p\$name-run-01"
  if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $cwd)) { throw "exists $name" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " start $name") -Encoding utf8
  & $tool 0 entry 0 -- suite "$P2/pins/$($r[1])" $R "$P2/cold-candidate71" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-candidate81/fe81/l2trans.exe" "$P2/cold-candidate71/rt71/driver.o" "$P2/$name-01" "$P2/cold-candidate71/rt71/driver-observe.o" *> "$p\pins\$name.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $name exit=$e") -Encoding utf8
}
Write-Output 'SUITES81 done'
