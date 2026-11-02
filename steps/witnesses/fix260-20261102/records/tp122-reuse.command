try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp122 reuse (fable_pc, slice 260): the 232 generated inputs the previous candidates' stages carried (the names of
# tp122-reuse.list = tp122-reuse.list) are taken from boot121a's stage cold-boot121a -- the landed source-tp122 built by the
# bootstrap (G1 = G2) -- into cold-tp122, so that the isolated builds see their predefs.  The kernel headers among them are the
# landed generation's (no tools change this slice; the runtime build rewrites them all the same).  Working tool 4DD5D706
# (boot121a's promoted G2), manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot121a\quick121a\lmxtool.exe"
$term="$p\pins\tp122-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp122")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4dd5d70602596afcec73902eb83a8a986ffcd13b85f59f2e693ae44920138485') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp122-reuse.list") -ne (ShaTp "$p\pins\tp121-reuse.list")) { throw 'tp122-reuse.list is not the names of tp121-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp122-prepare-fix01.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp122 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp122\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp122-reuse.list", "$P2/cold-boot121a", "$P2/pins/tp122-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp122-reuse-inputs.sha256", "$P2/cold-boot121a", "$P2/cold-tp122")
  ,@('manifest', "$P2/pins/tp122-reuse.list", "$P2/cold-tp122", "$P2/pins/tp122-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp122-reuse-inputs.sha256", "$P2/cold-tp122")
  ,@('verify', "$P2/pins/source-tp122.sha256", "$P2/cold-tp122")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp122-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp122-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp122-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp122-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp122\src\l2src\l2_frontend_state.lm1", "$p\cold-tp122\src\l2src\lmxtool_methods.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp122-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp122-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
