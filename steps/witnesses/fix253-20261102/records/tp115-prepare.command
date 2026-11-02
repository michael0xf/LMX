try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 (fable_pc, semantic step A = design 4.4: the kernel's code links, the native reset on a write of code, their
# lifetime with the index entry; lmx_arena_ref_store takes the arena and every actual and generated caller passes it;
# the driver's start-up self-check of the mechanism). 19 files over the landed source-tp114 package: nine kernel modules
# (arena_refs, range, arena, value_owned, walk_values, call, array_ref_owned, graph_copy_owned, thread), lmx_root, the
# driver, six frontend modules (emit, values, core, lower, useplan, consumer_uses), the C-door fixture
# tests/native_closure_values.lm2 and tools/build.lm2 (records, prototypes, export lists, the program-text scan).
# Stage cold-tp115 = the repo's selfbuild (inputs.sha256 = source-tp114, FE3FDA29) with the 19 files of variants/tp115
# over it: sources only, no generated input. Working tool 6619A503 (boot114's G2), verify/manifest/stage-copy only,
# every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\tp115-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp115") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'fe3fda29b2b6029db640717baf88e812f75f6ad3b8e64c54ff5bcf27bf31d6cf') { throw 'selfbuild inputs manifest is not source-tp114' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp115-changed.list")
if ($ok.Count -ne 19) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp115\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('manifest', "$P2/pins/tp115-changed.list", "$P2/variants/tp115", "$P2/pins/tp115-changed.sha256")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp115")
  ,@('stage-copy', "$P2/pins/tp115-changed.sha256", "$P2/variants/tp115", "$P2/cold-tp115")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp115", "$P2/pins/source-tp115.sha256")
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp115-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp115-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the 19 listed lines of the 159 differ from source-tp114.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp115.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 38) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-tp115\headers", "$p\cold-tp115\src\l2src\lmx.h.lm1", "$p\cold-tp115\src\l1src\libc_abi.lm1", "$p\cold-tp115\src\l2src\l2_frontend_state.lm1", "$p\cold-tp115\src\l2src\lmx_arena_refs.h.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp115 ' + (ShaTp "$p\pins\source-tp115.sha256") + ' changed ' + (ShaTp "$p\pins\tp115-changed.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
