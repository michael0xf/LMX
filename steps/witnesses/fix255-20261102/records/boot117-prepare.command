try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot117 (fable_pc, the short L3+L2 bootstrap of the optimization line after tp117 = design 4.5 B2a: the runtime-typed free
# value -- the kernel's one binary operation and reception, the contextual literal, the ARG place without a static witness; the
# frontend's FREE kind, the empty walked witness, the record-only native read, the dynamic expression and the receiving funnel;
# the witness tests/dyn/free_value_types.lm2): a fresh source-only stage cold-boot117 with exactly the 161 selected inputs of
# stage cold-tp117 (source-tp117: the landed source-tp116 with the 10 changed files of tp117 -- lmx_walk_values, seven frontend
# modules, tools/build.lm2, full-suite.tsv -- and the new fixture; the variant's inputs.list names them).  No generated header,
# body, object or reuse set.  Working tool 18C898AC (boot116c's G2) for verify/stage-copy/manifest only, fresh CWDs.
# Parameter: TP_TRY (the attempt: a, b, ... -- the stage is cold-boot117<TP_TRY>).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot117$try"
$tool="$p\cold-boot116c\quick116c\lmxtool.exe"
$term="$p\pins\boot117$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '18c898ac3d86869e781a6dfee8bfff20c9892df572d9443d23bba280cc212ba3') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp117-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool117 not built' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp117\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 161) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp117.sha256", "$P2/cold-tp117")
  ,@('stage-copy', "$P2/pins/source-tp117.sha256", "$P2/cold-tp117", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp117/inputs.list", "$P2/$stage", "$P2/pins/source-boot117$try.sha256")
  ,@('verify', "$P2/pins/source-boot117$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot117$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot117$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h117=ShaTp "$p\pins\source-tp117.sha256"
$hb=ShaTp "$p\pins\source-boot117$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp117 $h117 source-boot117$try $hb") -Encoding utf8
if ($h117 -ne $hb) { throw 'source-boot117 differs from source-tp117' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick117$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
