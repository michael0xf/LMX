try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 263. tp125-reuse.command uses the verified boot124a seed and the tp125 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot124a\quick124a\lmxtool.exe"
$term="$p\pins\tp125-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp125")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '62df51cf4749013af111d1916c24419493ad0582aa5c20b3ff18dd7b003d2d3f') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp125-reuse.list") -ne (ShaTp "$p\pins\tp124-reuse.list")) { throw 'tp125-reuse.list is not the names of tp124-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp125-prepare-01.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp125 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp125\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp125-reuse.list", "$P2/cold-boot124a", "$P2/pins/tp125-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp125-reuse-inputs.sha256", "$P2/cold-boot124a", "$P2/cold-tp125")
  ,@('manifest', "$P2/pins/tp125-reuse.list", "$P2/cold-tp125", "$P2/pins/tp125-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp125-reuse-inputs.sha256", "$P2/cold-tp125")
  ,@('verify', "$P2/pins/source-tp125.sha256", "$P2/cold-tp125")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp125-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp125-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp125-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp125-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp125\src\l2src\l2_frontend_state.lm1", "$p\cold-tp125\src\l2src\lmxtool_methods.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp125-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp125-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
