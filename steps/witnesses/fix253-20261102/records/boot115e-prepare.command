try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot115e (fable_pc, fifth attempt after fix05 -- boot115d passed and is the evidence of the frozen source-tp115 7E6203F5; Codex's review of that code opened P1-A (a departing Array descriptor left its owner marks and records in the live shared REF interval) and P1-B (an allocation failure after the physical write left a stale native word), both closed by fix05, whose tools/build.lm2 needs its own G0, tool115e; after tp115 = design 4.4: the kernel's code links and the native reset on a write of code, the arena
# passed to lmx_arena_ref_store by every caller): a fresh source-only stage cold-boot115e with exactly the 159 selected
# inputs of stage cold-tp115 (source-tp115: the landed source-tp114 with the 19 files of tp115 -- nine kernel modules,
# lmx_root, the driver, six frontend modules, the native_closure_values fixture, tools/build.lm2). No generated header,
# body, object or reuse set. Working tool 6619A503 (boot114's G2) for verify/stage-copy/manifest only, every tool run from
# a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\boot115e-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot115e") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-prepare-fix05.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'tp115 stage fix05 not verified' }
if ((ShaTp "$p\pins\source-tp115.sha256") -ne 'b8435de9edfc70426382fe7ce8395665bf19eb497919e922b993ef04a330fd0d') { throw 'source-tp115 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-tool-fix05.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool115e not built' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
  ,@('stage-copy', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115", "$P2/cold-boot115e")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot115e", "$P2/pins/source-boot115e.sha256")
  ,@('verify', "$P2/pins/source-boot115e.sha256", "$P2/cold-boot115e")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot115e-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot115e-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h115=ShaTp "$p\pins\source-tp115.sha256"
$hb=ShaTp "$p\pins\source-boot115e.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp115 $h115 source-boot115e $hb") -Encoding utf8
if ($h115 -ne $hb) { throw 'source-boot115e differs from source-tp115' }
foreach ($g in @("$p\cold-boot115e\headers", "$p\cold-boot115e\src\l2src\lmx.h.lm1", "$p\cold-boot115e\src\l1src\libc_abi.lm1", "$p\cold-boot115e\src\l2src\l2_frontend_state.lm1", "$p\cold-boot115e\quick115e")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
