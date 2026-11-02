try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp117 prepare-fix01 (fable_pc): the full changed set of candidate tp117 over the staged kernel-first stage cold-tp117 --
# the seven frontend modules (helpers: the FREE codes; values: the FREE kind; resolve: the kind absorbs an expression;
# context: no type-conflict refusal; core: the free predicate, the closure's entry-signature refusal lifted for free inputs,
# the free dynamic type set after the closure, the check guard; emit: the empty walked witness, no retained integer site over
# a runtime-typed operand; lower: the free name of a numeric lexical source, the record-only native read, the dynamic
# expression through lmx_walk_value_bin, the receiving funnel through lmx_walk_value_receive, the write through a free name,
# the runtime-typed condition, the located limits), the witness fixture tests/dyn/free_value_types.lm2 and its row in
# tests/full-suite.tsv; the kernel module and tools/build.lm2 stay as staged (tool117 built, rt117 passed).  The stage keeps
# its reused generated inputs (tp117-reuse); only the listed sources are copied over it.  Working tool 18C898AC,
# verify/manifest/stage-copy only, fresh CWDs.  Parameter: TP_TRY (fix01, fix02, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot116c\quick116c\lmxtool.exe"
$term="$p\pins\tp117-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp117")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '18c898ac3d86869e781a6dfee8bfff20c9892df572d9443d23bba280cc212ba3') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'dc4e8c62e5cbe8f9beb3f6a522e9aabd0e6a640cc2307ade0dab4de075d419b5') { throw 'selfbuild inputs manifest is not source-tp116' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp117-changed-full.list")
if ($ok.Count -ne 11) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp117\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('manifest', "$P2/pins/tp117-changed-full.list", "$P2/variants/tp117", "$P2/pins/tp117-changed-$try.sha256")
  ,@('stage-copy', "$P2/pins/tp117-changed-$try.sha256", "$P2/variants/tp117", "$P2/cold-tp117")
  ,@('manifest', "$P2/variants/tp117/inputs.list", "$P2/cold-tp117", "$P2/pins/source-tp117.sha256")
  ,@('verify', "$P2/pins/source-tp117.sha256", "$P2/cold-tp117")
)
if (Test-Path -LiteralPath "$p\pins\source-tp117.sha256") { Move-Item -LiteralPath "$p\pins\source-tp117.sha256" -Destination "$p\pins\source-tp117-before-$try.sha256" }
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp117-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp117-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp116: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp117.sha256")
if ($a.Count -ne 160 -or $b.Count -ne 161) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp117 ' + (ShaTp "$p\pins\source-tp117.sha256") + ' changed ' + (ShaTp "$p\pins\tp117-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
