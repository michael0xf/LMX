try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 fix01 (fable_pc): the variant after Codex's review of the WIP (lmx_uds, 2026-11-02 ~07:25Z; P1-B1-1, P1-B1-2):
# lmx_activation_record_find looks a record up in the book's order -- its written formals (a four-field args header
# entry), its own working cells (a native frame's bindings; a walker frame's rows loaded at entry), then the free inputs it
# inherited (a two-field entry) -- and the walker branch no longer scans the data node's fields; the driver's self-check
# gains the order and the walker-row cases; the fixture tests/dyn/free_name_chain.lm2 (free names through the chain,
# nearest binding first, an unused data field is no binding) with its full-suite.tsv row and its inputs.list line.  The
# stage cold-tp116 takes the 10 changed files again from the variant (stage-copy over the existing stage); source-tp116
# is recomputed with the variant's inputs.list (160 lines) and verified.  Working tool 8C5D66EA (boot115f's G2), fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$term="$p\pins\tp116-prepare-fix01.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp116")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8c5d66ea0852864134b0dd98967f1ab1ab5fa17069d04cc82843fb913ae7cc44') { throw 'tool hash' }
foreach ($g in @("$p\cold-tp116\rt116", "$p\cold-tp116\tool116")) { if (Test-Path -LiteralPath $g) { throw ('must be absent: ' + $g) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' before: changed ' + (ShaTp "$p\pins\tp116-changed.sha256") + ' source-tp116 ' + (ShaTp "$p\pins\source-tp116.sha256")) -Encoding utf8
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp116-changed.list", "$P2/variants/tp116", "$P2/pins/tp116-changed.sha256")
  ,@('stage-copy', "$P2/pins/tp116-changed.sha256", "$P2/variants/tp116", "$P2/cold-tp116")
  ,@('manifest', "$P2/variants/tp116/inputs.list", "$P2/cold-tp116", "$P2/pins/source-tp116.sha256")
  ,@('verify', "$P2/pins/source-tp116.sha256", "$P2/cold-tp116")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp116-prepare-fix01-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp116-prepare-fix01-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ok=@(Get-Content -LiteralPath "$p\pins\tp116-changed.list")
if ($ok.Count -ne 10) { throw ('changed list lines ' + $ok.Count) }
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp116.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
if ($d.Count -ne 21) { throw ('manifest differences ' + $d.Count) }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after: changed ' + (ShaTp "$p\pins\tp116-changed.sha256") + ' source-tp116 ' + (ShaTp "$p\pins\source-tp116.sha256") + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp116\src\l2src\lmx_walk_values.lm2") + ' fixture ' + (ShaTp "$p\cold-tp116\tests\dyn\free_name_chain.lm2")) -Encoding utf8
Write-Output ('FIX01 ' + $i + ' steps')
