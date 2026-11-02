try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp123 reuse (fable_pc, slice 261): the 232 generated inputs the previous candidates' stages carried (the names of
# tp123-reuse.list = tp123-reuse.list) are taken from boot122a's stage cold-boot122a -- the landed source-tp123 built by the
# bootstrap (G1 = G2) -- into cold-tp123, so that the isolated builds see their predefs.  The kernel headers among them are the
# landed generation's: tools/build.lm2 changes this slice (the type code LMX_TYPE_CELL_POINTER, the walker op RECEIVE, the export
# lmx_walk_value_receive_pointer), so the rebuilt tool (tp123-tool) and its runtime build rewrite them before any module sees the
# new names.  Working tool 1B9F2BA5 (boot122a's promoted G2), manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot122a\quick122a\lmxtool.exe"
$term="$p\pins\tp123-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp123")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1b9f2ba5751771e2fcb53f3db60b0e06b24e1abf1607a449796739d55fa522f6') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp123-reuse.list") -ne (ShaTp "$p\pins\tp122-reuse.list")) { throw 'tp123-reuse.list is not the names of tp122-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp123-prepare-01.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp123 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp123\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp123-reuse.list", "$P2/cold-boot122a", "$P2/pins/tp123-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp123-reuse-inputs.sha256", "$P2/cold-boot122a", "$P2/cold-tp123")
  ,@('manifest', "$P2/pins/tp123-reuse.list", "$P2/cold-tp123", "$P2/pins/tp123-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp123-reuse-inputs.sha256", "$P2/cold-tp123")
  ,@('verify', "$P2/pins/source-tp123.sha256", "$P2/cold-tp123")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp123-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp123-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp123-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp123-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp123\src\l2src\l2_frontend_state.lm1", "$p\cold-tp123\src\l2src\lmxtool_methods.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp123-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp123-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
