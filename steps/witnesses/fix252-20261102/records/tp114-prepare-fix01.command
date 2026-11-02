try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp114 fix01 (fable_pc): the first self-check of l2_frontend_values refused `r: lm_compiler_pfi_first(mi, first\value)`
# ("assignment value has unknown type, atom=first"); the variant now passes the argument through the explicit const cast
# the other call sites use. The stage cold-tp114 takes the nine tp114 files again from the variant (stage-copy over the
# existing stage), and tp114-changed.sha256 / source-tp114.sha256 are recomputed and verified; the reuse manifests are
# untouched (no generated input changed). Frozen tool E8150E60, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp114-prepare-fix01.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp114")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
foreach ($g in @("$p\cold-tp114\tool114", "$p\cold-tp114\fe114", "$p\cold-tp114\src\l2src\l2_frontend_state.lm1")) { if (Test-Path -LiteralPath $g) { throw ('must be absent: ' + $g) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' before: changed ' + (ShaTp "$p\pins\tp114-changed.sha256") + ' source-tp114 ' + (ShaTp "$p\pins\source-tp114.sha256")) -Encoding utf8
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp114-changed.list", "$P2/variants/tp114", "$P2/pins/tp114-changed.sha256")
  ,@('stage-copy', "$P2/pins/tp114-changed.sha256", "$P2/variants/tp114", "$P2/cold-tp114")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp114", "$P2/pins/source-tp114.sha256")
  ,@('verify', "$P2/pins/source-tp114.sha256", "$P2/cold-tp114")
  ,@('verify', "$P2/pins/tp114-reuse-artifacts.sha256", "$P2/cold-tp114")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp114-prepare-fix01-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp114-prepare-fix01-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=@(Get-Content -LiteralPath "$p\pins\source-full100.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp114.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
if ($d.Count -ne 18) { throw ('manifest differences ' + $d.Count) }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after: changed ' + (ShaTp "$p\pins\tp114-changed.sha256") + ' source-tp114 ' + (ShaTp "$p\pins\source-tp114.sha256") + ' values.lm2 ' + (ShaTp "$p\cold-tp114\src\l2src\l2_frontend_values.lm2")) -Encoding utf8
Write-Output ('FIX01 ' + $i + ' steps')
