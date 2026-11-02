try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp119 (fable_pc, slice 257 = design 4.5 B2b, P1-RET of Codex's answer to FABLE-RESULT-TP118: the walker's result place
# receives every present NUMBER or REFERENCE value by the kernel's one admission -- a number where a pointer is declared and a
# pointer where an int is declared are the implicit `convert`, no blanket pass).  Stage cold-tp119 = the repo's selfbuild
# (inputs.sha256 = source-tp119, 1016F41D) with the listed files of variants/tp119 over it (the kernel module lmx_walk_values,
# the witness tests/dyn/free_result_convert.lm2 and its row in tests/full-suite.tsv; the variant's inputs.list names the
# fixture): sources only, no generated input.  tools/build.lm2 is the landed one, so boot118a's G2 working tool 3E5F1A18 is the
# tool of every step; verify/manifest/stage-copy only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot118a\quick118a\lmxtool.exe"
$term="$p\pins\tp119-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp119") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3e5f1a186ea1a548ddc81a2f8cd47b88750543b4a4b7fa20ea3716504420c0b2') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '1016f41ddf4ecb153e92fd8a93b47710a8963d9f892aad085d8bc712295b4454') { throw 'selfbuild inputs manifest is not source-tp118' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp119-changed.list")
if ($ok.Count -ne 3) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp119\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('manifest', "$P2/pins/tp119-changed.list", "$P2/variants/tp119", "$P2/pins/tp119-changed.sha256")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp119")
  ,@('stage-copy', "$P2/pins/tp119-changed.sha256", "$P2/variants/tp119", "$P2/cold-tp119")
  ,@('manifest', "$P2/variants/tp119/inputs.list", "$P2/cold-tp119", "$P2/pins/source-tp119.sha256")
  ,@('verify', "$P2/pins/source-tp119.sha256", "$P2/cold-tp119")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp119-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp119-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp118: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp119.sha256")
if ($a.Count -ne 162 -or $b.Count -ne 163) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
foreach ($g in @("$p\cold-tp119\headers", "$p\cold-tp119\src\l2src\lmx.h.lm1", "$p\cold-tp119\src\l1src\libc_abi.lm1", "$p\cold-tp119\src\l2src\l2_frontend_state.lm1", "$p\cold-tp119\src\l2src\lmx_arena_refs.h.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp119 ' + (ShaTp "$p\pins\source-tp119.sha256") + ' changed ' + (ShaTp "$p\pins\tp119-changed.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
