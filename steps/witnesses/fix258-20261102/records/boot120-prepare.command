try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot120 (fable_pc, the short L3+L2 bootstrap of the optimization line after tp120 = design 4.5 B2b-2a: the runtime-typed
# deref, write-through and address of a free name): a fresh source-only stage cold-boot120<TP_TRY> with exactly the 164
# selected inputs of stage cold-tp120 (source-tp120: the landed source-tp120 with the 5 changed files of tp120 --
# lmx_walk_values, l2_frontend_resolve, l2_frontend_lower, l2_frontend_emit, full-suite.tsv -- and the new fixture
# tests/dyn/free_pointer_paths.lm2; the variant's inputs.list names them).  No generated header, body, object or reuse set.
# Working tool 64AE29A0 (boot119a's G2) for verify/stage-copy/manifest only, fresh CWDs.  Parameter: TP_TRY (the attempt: a, b,
# ... -- the stage is cold-boot120<TP_TRY>).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot120$try"
$tool="$p\cold-boot119a\quick119a\lmxtool.exe"
$term="$p\pins\boot120$try-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\$stage") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '64ae29a0d4e8b2ee22eec82724bcc410c4a4ffce906650698b9be52ccc660d01') { throw 'tool hash' }
$inputs=@(Get-Content -LiteralPath "$p\variants\tp120\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 164) { throw ('inputs.list lines ' + $inputs.Count) }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp120.sha256", "$P2/cold-tp120")
  ,@('stage-copy', "$P2/pins/source-tp120.sha256", "$P2/cold-tp120", "$P2/$stage")
  ,@('manifest', "$P2/variants/tp120/inputs.list", "$P2/$stage", "$P2/pins/source-boot120$try.sha256")
  ,@('verify', "$P2/pins/source-boot120$try.sha256", "$P2/$stage")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot120$try-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot120$try-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$hsrc=ShaTp "$p\pins\source-tp120.sha256"
$hb=ShaTp "$p\pins\source-boot120$try.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp120 $hsrc source-boot120$try $hb") -Encoding utf8
if ($hsrc -ne $hb) { throw 'source-boot120 differs from source-tp120' }
foreach ($g in @("$p\$stage\headers", "$p\$stage\src\l2src\lmx.h.lm1", "$p\$stage\src\l1src\libc_abi.lm1", "$p\$stage\src\l2src\l2_frontend_state.lm1", "$p\$stage\quick120$try")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
