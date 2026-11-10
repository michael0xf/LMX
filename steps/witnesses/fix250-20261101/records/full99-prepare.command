try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The FULL of the draft79 line (after slice249): a fresh source-only stage
# cold-full99 with exactly the 159 selected inputs of stage94
# (source-candidate94, the sources of FE94 + RT92 that boot98 built), so the
# FULL builds the same bytes boot98 did. No generated header, body, object or
# reuse set. Tool: boot89's promoted working tool (7FD2E824) for
# verify/stage-copy/manifest only.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\full99-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-full99") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-candidate94.sha256").Hash -ne '1F374773C376E18D6D0129606408413BE30CF3F389844BF7C82B156C4CEBB9A4') { throw 'source94 manifest hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-candidate94.sha256", "$P2/cold-candidate94")
  ,@('stage-copy', "$P2/pins/source-candidate94.sha256", "$P2/cold-candidate94", "$P2/cold-full99")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-full99", "$P2/pins/source-full99.sha256")
  ,@('verify', "$P2/pins/source-full99.sha256", "$P2/cold-full99")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\full99-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\full99-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h94=(Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-candidate94.sha256").Hash
$h99=(Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-full99.sha256").Hash
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-candidate94 $h94 source-full99 $h99") -Encoding utf8
if ($h94 -ne $h99) { throw 'source-full99 differs from source-candidate94' }
foreach ($g in @("$p\cold-full99\headers", "$p\cold-full99\src\l2src\lmx.h.lm1", "$p\cold-full99\src\l1src\libc_abi.lm1", "$p\cold-full99\full99")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
