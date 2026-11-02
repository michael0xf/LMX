try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot116 (fable_pc, the short L3+L2 bootstrap of the optimization line after tp116 = design 4.5 B1: the activation chain --
# LmxActivation records of both executors chained from the arena, one shared resolver in the book's order, a free input
# marked by its caller and resolved once at the callee's entry, the native frame's used own fields bound by their graph
# place, the driver's start-up self-check of the chain, the fixture tests/dyn/free_name_chain.lm2; after Codex's review of
# the WIP, P1-B1-1/P1-B1-2): a fresh source-only stage cold-boot116 with exactly the 160 selected inputs of stage cold-tp116
# (source-tp116: the landed source-tp116 with the 10 changed files of tp116 -- lmx_arena, lmx_call, lmx_walk_values, the
# driver, three frontend modules, tools/build.lm2, full-suite.tsv -- and the new fixture; the variant's inputs.list names
# them). No generated header, body, object or reuse set. Working tool 8C5D66EA (boot116's G2) for verify/stage-copy/manifest
# only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$term="$p\pins\boot116-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot116") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8c5d66ea0852864134b0dd98967f1ab1ab5fa17069d04cc82843fb913ae7cc44') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-prepare-fix05.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'tp116 stage fix02 not verified' }
if ((ShaTp "$p\pins\source-tp116.sha256") -ne 'dfe9a5ab2a58fd823cdad45a7926117ff3182bc78cada82f8b728ab6259a3549') { throw 'source-tp116 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool116 not built' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp116.sha256", "$P2/cold-tp116")
  ,@('stage-copy', "$P2/pins/source-tp116.sha256", "$P2/cold-tp116", "$P2/cold-boot116")
  ,@('manifest', "$P2/variants/tp116/inputs.list", "$P2/cold-boot116", "$P2/pins/source-boot116.sha256")
  ,@('verify', "$P2/pins/source-boot116.sha256", "$P2/cold-boot116")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot116-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot116-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h116=ShaTp "$p\pins\source-tp116.sha256"
$hb=ShaTp "$p\pins\source-boot116.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp116 $h116 source-boot116 $hb") -Encoding utf8
if ($h116 -ne $hb) { throw 'source-boot116 differs from source-tp116' }
foreach ($g in @("$p\cold-boot116\headers", "$p\cold-boot116\src\l2src\lmx.h.lm1", "$p\cold-boot116\src\l1src\libc_abi.lm1", "$p\cold-boot116\src\l2src\l2_frontend_state.lm1", "$p\cold-boot116\quick116")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
