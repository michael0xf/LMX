try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 269. tp131-reuse.command uses the verified boot130a seed and the tp131 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot130a\quick130a\lmxtool.exe"
$term="$p\pins\tp131-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp131")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '31d55441805a79a36a93e6bb7ff842370b034fbc6d1f440c3a9ecc9702e46f43') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp131-reuse.list") -ne (ShaTp "$p\pins\tp130-reuse.list")) { throw 'tp131-reuse.list is not the names of tp130-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp131-prepare-01.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp131 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp131\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp131-reuse.list", "$P2/cold-boot130a", "$P2/pins/tp131-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp131-reuse-inputs.sha256", "$P2/cold-boot130a", "$P2/cold-tp131")
  ,@('manifest', "$P2/pins/tp131-reuse.list", "$P2/cold-tp131", "$P2/pins/tp131-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp131-reuse-inputs.sha256", "$P2/cold-tp131")
  ,@('verify', "$P2/pins/source-tp131.sha256", "$P2/cold-tp131")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp131-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp131-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp131-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp131-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp131\src\l2src\l2_frontend_state.lm1", "$p\cold-tp131\src\l2src\lmxtool_methods.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp131-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp131-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
