try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The FULL of the draft79 line after full99's failure (slice250): a fresh
# source-only stage cold-full100 = the 159 selected inputs of stage94
# (source-candidate94, 1F374773) with coherent100's one file: Lower, whose
# context store of a number or char also renews the field's working Value
# (l2_wv), so a full-Value read (call argument, own copy) no longer forwards
# the entry Value (full99: sha256_vectors native, case 81). No generated
# header, body, object or reuse set. Tool: boot89's promoted working tool
# (7FD2E824) for manifest/verify/stage-copy only.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\full100-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-full100") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-candidate94.sha256").Hash -ne '1F374773C376E18D6D0129606408413BE30CF3F389844BF7C82B156C4CEBB9A4') { throw 'source94 manifest hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate100-coherent.list", "$P2/variants/coherent100", "$P2/pins/candidate100-coherent.sha256")
  ,@('verify', "$P2/pins/source-candidate94.sha256", "$P2/cold-candidate94")
  ,@('stage-copy', "$P2/pins/source-candidate94.sha256", "$P2/cold-candidate94", "$P2/cold-full100")
  ,@('stage-copy', "$P2/pins/candidate100-coherent.sha256", "$P2/variants/coherent100", "$P2/cold-full100")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-full100", "$P2/pins/source-full100.sha256")
  ,@('verify', "$P2/pins/source-full100.sha256", "$P2/cold-full100")
  ,@('verify', "$P2/pins/candidate100-coherent.sha256", "$P2/cold-full100")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\full100-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\full100-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h94=(Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-candidate94.sha256").Hash
$h100=(Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-full100.sha256").Hash
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-candidate94 $h94 source-full100 $h100") -Encoding utf8
# Exactly one line of the 159 differs from source-candidate94: the Lower.
$a=@(Get-Content -LiteralPath "$p\pins\source-candidate94.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-full100.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { if (-not ($x.InputObject -like '*  src/l2src/l2_frontend_lower.lm2')) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-full100\headers", "$p\cold-full100\src\l2src\lmx.h.lm1", "$p\cold-full100\src\l1src\libc_abi.lm1", "$p\cold-full100\full100")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
