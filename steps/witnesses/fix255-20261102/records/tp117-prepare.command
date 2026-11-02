try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp117 (fable_pc, semantic step B2a = design 4.5 revision 13: the runtime-typed free value -- the kernel's one binary operation
# of both executors (lmx_walk_value_bin), the reception of a value by a typed place (lmx_walk_value_receive, the implicit
# `convert` throw as the named refusal), the contextual literal (lmx_walk_value_lit), an ARG place without a static witness typed
# by its value; then the frontend's FREE kind, the empty walked witness, the record-only native read, the dynamic expression and
# the receiving funnel).  First stage: the kernel module lmx_walk_values and tools/build.lm2 (the export lists: 3 kernel names,
# 4 helper names) over the landed source-tp116 package; the frontend modules, the fixture and the suite row follow as fix01
# of this stage.  Stage cold-tp117 = the repo's selfbuild (inputs.sha256 = source-tp116, DC4E8C62) with the listed files of
# variants/tp117 over it: sources only, no generated input.  Working tool 18C898AC (boot116c's G2), verify/manifest/stage-copy
# only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot116c\quick116c\lmxtool.exe"
$term="$p\pins\tp117-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp117") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '18c898ac3d86869e781a6dfee8bfff20c9892df572d9443d23bba280cc212ba3') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'dc4e8c62e5cbe8f9beb3f6a522e9aabd0e6a640cc2307ade0dab4de075d419b5') { throw 'selfbuild inputs manifest is not source-tp116' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp117-changed.list")
if ($ok.Count -ne 2) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp117\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('manifest', "$P2/pins/tp117-changed.list", "$P2/variants/tp117", "$P2/pins/tp117-changed.sha256")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp117")
  ,@('stage-copy', "$P2/pins/tp117-changed.sha256", "$P2/variants/tp117", "$P2/cold-tp117")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp117", "$P2/pins/source-tp117.sha256")
  ,@('verify', "$P2/pins/source-tp117.sha256", "$P2/cold-tp117")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp117-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp117-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines of the 160 differ from source-tp116 (two manifest lines per changed file).
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp117.sha256")
if ($a.Count -ne 160 -or $b.Count -ne 160) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-tp117\headers", "$p\cold-tp117\src\l2src\lmx.h.lm1", "$p\cold-tp117\src\l1src\libc_abi.lm1", "$p\cold-tp117\src\l2src\l2_frontend_state.lm1", "$p\cold-tp117\src\l2src\lmx_arena_refs.h.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp117 ' + (ShaTp "$p\pins\source-tp117.sha256") + ' changed ' + (ShaTp "$p\pins\tp117-changed.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
