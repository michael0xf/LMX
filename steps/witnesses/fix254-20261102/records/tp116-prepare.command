try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 (fable_pc, semantic step B1 = design 4.5: the activation chain -- LmxActivation records of both executors chained
# from the arena, one shared resolver, a free input marked by its caller (LMX_WALK_VALUE_FREE) and resolved once at the
# callee's entry; the native frame's used own fields bound by their graph place; the driver's start-up self-check of the
# chain).  8 files over the landed source-tp116 package: four kernel modules (arena, call, walk_values) and the driver,
# three frontend modules (lower, core, emit) and tools/build.lm2 (records, the arena's anchor, the value kind, the
# prototypes, the export lists).  Stage cold-tp116 = the repo's selfbuild (inputs.sha256 = source-tp116, 48F66AF0) with
# the 8 files of variants/tp116 over it: sources only, no generated input.  Working tool 8C5D66EA (boot115f's G2),
# verify/manifest/stage-copy only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$term="$p\pins\tp116-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp116") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8c5d66ea0852864134b0dd98967f1ab1ab5fa17069d04cc82843fb913ae7cc44') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '48f66af0082628be340db193a3e943be430e93739e796463c03e3dd86cb2d997') { throw 'selfbuild inputs manifest is not source-tp116' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp116-changed.list")
if ($ok.Count -ne 8) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp116\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('manifest', "$P2/pins/tp116-changed.list", "$P2/variants/tp116", "$P2/pins/tp116-changed.sha256")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp116")
  ,@('stage-copy', "$P2/pins/tp116-changed.sha256", "$P2/variants/tp116", "$P2/cold-tp116")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp116", "$P2/pins/source-tp116.sha256")
  ,@('verify', "$P2/pins/source-tp116.sha256", "$P2/cold-tp116")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp116-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp116-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the 8 listed lines of the 159 differ from source-tp116.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp116.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 16) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-tp116\headers", "$p\cold-tp116\src\l2src\lmx.h.lm1", "$p\cold-tp116\src\l1src\libc_abi.lm1", "$p\cold-tp116\src\l2src\l2_frontend_state.lm1", "$p\cold-tp116\src\l2src\lmx_arena_refs.h.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp116 ' + (ShaTp "$p\pins\source-tp116.sha256") + ' changed ' + (ShaTp "$p\pins\tp116-changed.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
