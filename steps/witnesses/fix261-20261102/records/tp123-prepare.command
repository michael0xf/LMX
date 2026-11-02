try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp123 (fable_pc, slice 261 = design 4.5 B2b-2d, P1-PTR-COVERAGE at the address level: the address of a free name whose place is a
# graph or Array reference cell, a pointer cell of a translator code or an element place -- the kernel's own pointer code
# LMX_TYPE_CELL_POINTER, the pointee read from the cell; the receive of such an address by a typed pointer place by the ACTUAL
# pointees at any depth, in both executors: lmx_walk_value_receive_pointer natively and through the walker's RECEIVE frame).  Stage
# cold-tp123 = the repo's selfbuild (inputs.sha256 = source-tp123, 8F34D77F) with the listed files of variants/tp123 over it (the
# kernel module lmx_walk_values, the frontend modules lower and emit, tools/build.lm2 (the type code, the walker op RECEIVE, the
# export), tests/full-suite.tsv, the witness tests/dyn/free_graph_address.lm2; the variant's inputs.list names the fixture):
# sources only, no generated input.  Working tool 1B9F2BA5 (boot122a's promoted G2) for verify/manifest/stage-copy only, fresh
# CWDs.  A fresh stage runs the six steps, a refresh (TP_TRY fix02, ...) the four.  Parameter: TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot122a\quick122a\lmxtool.exe"
$term="$p\pins\tp123-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1b9f2ba5751771e2fcb53f3db60b0e06b24e1abf1607a449796739d55fa522f6') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '8f34d77f064f00e41e1012df3973815f4921192307bc065e1dd4ce0c22b4f7a0') { throw 'selfbuild inputs manifest is not source-tp122' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp123-changed.list")
if ($ok.Count -ne 6) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp123\$o")) { throw ('variant file missing: ' + $o) } }
$fresh = -not (Test-Path -LiteralPath "$p\cold-tp123")
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if ($fresh) {
  $steps=@(
    ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
    ,@('manifest', "$P2/pins/tp123-changed.list", "$P2/variants/tp123", "$P2/pins/tp123-changed-$try.sha256")
    ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp123")
    ,@('stage-copy', "$P2/pins/tp123-changed-$try.sha256", "$P2/variants/tp123", "$P2/cold-tp123")
    ,@('manifest', "$P2/variants/tp123/inputs.list", "$P2/cold-tp123", "$P2/pins/source-tp123.sha256")
    ,@('verify', "$P2/pins/source-tp123.sha256", "$P2/cold-tp123")
  )
} else {
  $steps=@(
    ,@('manifest', "$P2/pins/tp123-changed.list", "$P2/variants/tp123", "$P2/pins/tp123-changed-$try.sha256")
    ,@('stage-copy', "$P2/pins/tp123-changed-$try.sha256", "$P2/variants/tp123", "$P2/cold-tp123")
    ,@('manifest', "$P2/variants/tp123/inputs.list", "$P2/cold-tp123", "$P2/pins/source-tp123.sha256")
    ,@('verify', "$P2/pins/source-tp123.sha256", "$P2/cold-tp123")
  )
  if (Test-Path -LiteralPath "$p\pins\source-tp123.sha256") { Move-Item -LiteralPath "$p\pins\source-tp123.sha256" -Destination "$p\pins\source-tp123-before-$try.sha256" }
}
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp123-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp123-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp122: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp123.sha256")
if ($a.Count -ne 166 -or $b.Count -ne 167) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
if ($fresh) {
  foreach ($g in @("$p\cold-tp123\headers", "$p\cold-tp123\src\l2src\lmx.h.lm1", "$p\cold-tp123\src\l1src\libc_abi.lm1", "$p\cold-tp123\src\l2src\l2_frontend_state.lm1", "$p\cold-tp123\src\l2src\lmx_arena_refs.h.lm1")) {
    if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
  }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp123 ' + (ShaTp "$p\pins\source-tp123.sha256") + ' changed ' + (ShaTp "$p\pins\tp123-changed-$try.sha256") + ' fresh ' + $fresh) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
