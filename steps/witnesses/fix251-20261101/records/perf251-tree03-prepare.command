try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# slice251: the private working tree of the emit translation, as G1's stage held it when that step began. The
# translator opens its predef headers by CWD-relative paths (l2_frontend_emit.lm2:3-19 `predef: "l1src/p0.h.lm1"`,
# `"l2src/..."`; lm_compiler_snap_read fopen(path); nested ones by lm_compiler_predef_import relative to the including
# header) and the build runs the step from stage/src (tools/build.lm2 bld_machine_module: bld_step_t(..., src, ...)).
# Attempt 02 ran from an empty private CWD, so every predef open failed: neither faithful nor a profile of the build.
# Tree = the 159 inputs of source-full100 (AA841167; the stage was fresh) + every path the G1 frontend record
# (246272153b...) notes before the emit step (lines 1-252: the L3 declarations and each earlier step's outputs), with
# the record's hash. Copied by the maintained tool (boot89's 7FD2E824): from G1's consumed-input snapshot where it holds
# the file with that hash, else from cold-full100; then verified whole. The emit step's own outputs stay absent: the
# translation writes them into this tree at the same relative paths, as G1 wrote them into its CWD tree.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$rec="$p\cold-full100\full100\g1\frontend\record.txt"
$snap="$p\cold-full100\full100\g1\consumed-inputs.sha256"
$name='perf251-emit-tree-03'
$T="$p\$name"
$term="$p\pins\$name-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $T) { throw 'tree exists' }
if (Test-Path -LiteralPath $term) { throw 'terminal exists' }
function Sha251([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((Sha251 $tool) -ne '7fd2e82475b24425b3ffdfc295ce2ac33f9529a4275d11423f57b78380714678') { throw 'tool hash' }
if ((Sha251 $rec) -ne '246272153bdb0ca9f534e29b7d11ba8bcc2eedd0e4e6171c8b80eaeb05c2eddf') { throw 'record hash' }
if ((Sha251 $snap) -ne 'f8826e9a17eef45fc763dbf57251daad44d3119e4ab7595bddfd2ae4cef9301d') { throw 'snapshot manifest hash' }
if ((Sha251 "$p\pins\source-full100.sha256") -ne 'aa84116779f5fcae9c25f551af1a2929fa8282e55129b6f9de7cb81945891d8e') { throw 'source manifest hash' }
$exp=[ordered]@{}
foreach ($l in @(Get-Content -LiteralPath "$p\pins\source-full100.sha256")) {
  if ($l -cmatch '^([0-9a-f]{64})  (\S+)$') { $exp[$Matches[2]]=$Matches[1] } else { throw "source line: $l" }
}
if ($exp.Count -ne 159) { throw ('source entries ' + $exp.Count) }
$pre='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-full100/'
$lines=@(Get-Content -LiteralPath $rec)
if (-not $lines[252].StartsWith('$ ') -or -not $lines[252].EndsWith("$($pre)src/l2src/l2_frontend_emit.lm1")) { throw 'record line 253 is not the emit step' }
$noted=0
for ($i=0; $i -lt 252; $i++) {
  $l=$lines[$i]
  if ($l.StartsWith('$ ')) { continue }
  if ($l -cmatch '^([0-9a-f]{64})  (\S+)$' -or $l -cmatch '^  out ([0-9a-f]{64}) (\S+)$') {
    $h=$Matches[1]; $a=$Matches[2]
    if (-not $a.StartsWith($pre)) { continue }
    $exp[$a.Substring($pre.Length)]=$h; $noted++
  }
}
foreach ($k in @($exp.Keys)) { if ($k -like '*l2_frontend_emit.h.lm1' -or $k -like '*l2_frontend_emit.lm1') { throw "emit output noted: $k" } }
$snapmap=@{}
foreach ($l in @(Get-Content -LiteralPath $snap)) { if ($l -cmatch '^([0-9a-f]{64})  (\S+)$') { $snapmap[$Matches[2]]=$Matches[1] } }
$fromSnap=New-Object System.Collections.Generic.List[string]
$fromStage=New-Object System.Collections.Generic.List[string]
$all=New-Object System.Collections.Generic.List[string]
foreach ($k in @($exp.Keys | Sort-Object -CaseSensitive)) {
  $ln=$exp[$k] + '  ' + $k
  $all.Add($ln)
  if ($snapmap.ContainsKey($k) -and $snapmap[$k] -eq $exp[$k]) { $fromSnap.Add($ln) } else { $fromStage.Add($ln) }
}
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText("$p\pins\$name-all.sha256", (($all -join "`n") + "`n"), $utf8)
[IO.File]::WriteAllText("$p\pins\$name-from-snapshot.sha256", (($fromSnap -join "`n") + "`n"), $utf8)
[IO.File]::WriteAllText("$p\pins\$name-from-stage.sha256", (($fromStage -join "`n") + "`n"), $utf8)
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' tree entries ' + $all.Count + ' (record notes ' + $noted + ') from-snapshot ' + $fromSnap.Count + ' from-stage ' + $fromStage.Count) -Encoding utf8
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps=New-Object System.Collections.Generic.List[object]
$steps.Add(@('stage-copy', "$P2/pins/$name-from-snapshot.sha256", "$P2/cold-full100/full100/g1/consumed-inputs", "$P2/$name"))
if ($fromStage.Count -gt 0) { $steps.Add(@('stage-copy', "$P2/pins/$name-from-stage.sha256", "$P2/cold-full100", "$P2/$name")) }
$steps.Add(@('verify', "$P2/pins/$name-all.sha256", "$P2/$name"))
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\$name-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\$name-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
foreach ($g in @("$T\src\l2src\l2_frontend_emit.h.lm1", "$T\src\l2src\l2_frontend_emit.lm1", "$T\headers")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' tree ready; all.sha256 ' + (Sha251 "$p\pins\$name-all.sha256")) -Encoding utf8
Write-Output ('TREE03 ready ' + $all.Count + ' files')
