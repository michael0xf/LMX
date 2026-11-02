try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Slice259 evidence: the raw manifest of the listed originals under P and its
# verify, with the promoted working tool of boot121a (G2's, 4DD5D706), fresh
# private CWDs. The full docs check follows separately (docs259-check.command)
# once the slice files are in the Git index.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot121a\quick121a\lmxtool.exe"
$term="$p\pins\docs259.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '4DD5D70602596AFCEC73902EB83A8A986FFCD13B85F59F2E693AE44920138485') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$repo/steps/witnesses/fix259-20261102/evidence.list", $P2, "$repo/steps/witnesses/fix259-20261102/evidence.sha256")
  ,@('verify', "$repo/steps/witnesses/fix259-20261102/evidence.sha256", $P2)
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\docs259-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\docs259-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('DOCS259 ' + $i + ' steps')
