try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot115 (fable_pc, after tp115 = design 4.4: the kernel's code links and the native reset on a write of code, the arena
# passed to lmx_arena_ref_store by every caller): a fresh source-only stage cold-boot115 with exactly the 159 selected
# inputs of stage cold-tp115 (source-tp115: the landed source-tp114 with the 19 files of tp115 -- nine kernel modules,
# lmx_root, the driver, six frontend modules, the native_closure_values fixture, tools/build.lm2). No generated header,
# body, object or reuse set. Working tool 6619A503 (boot114's G2) for verify/stage-copy/manifest only, every tool run from
# a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\boot115-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot115") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-prepare-fix01.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'tp115 stage fix01 not verified' }
if ((ShaTp "$p\pins\source-tp115.sha256") -ne 'd92183430cc3c6aba92e1eb0d8607a51e35aedbccfbfbf18ce3a319280eca3b1') { throw 'source-tp115 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool115 not built' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
  ,@('stage-copy', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115", "$P2/cold-boot115")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot115", "$P2/pins/source-boot115.sha256")
  ,@('verify', "$P2/pins/source-boot115.sha256", "$P2/cold-boot115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot115-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot115-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h115=ShaTp "$p\pins\source-tp115.sha256"
$hb=ShaTp "$p\pins\source-boot115.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp115 $h115 source-boot115 $hb") -Encoding utf8
if ($h115 -ne $hb) { throw 'source-boot115 differs from source-tp115' }
foreach ($g in @("$p\cold-boot115\headers", "$p\cold-boot115\src\l2src\lmx.h.lm1", "$p\cold-boot115\src\l1src\libc_abi.lm1", "$p\cold-boot115\src\l2src\l2_frontend_state.lm1", "$p\cold-boot115\quick115")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
