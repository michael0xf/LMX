try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot112 (fable_pc, after S1-S3 = tp110/tp111/tp112): a fresh source-only stage cold-boot112 with exactly the 159 selected
# inputs of stage cold-tp112 (source-tp112: source-full100 with the eight tp112 files -- types, intern, values, views,
# context, resolve, core, tools/build.lm2), i.e. the sources of fe112 + the G1 full100 kernel. No generated header, body,
# object or reuse set. Frozen tool E8150E60 for verify/stage-copy/manifest only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\boot112-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot112") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp112-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp112 stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\tp112-frontend-part.terminal.txt" -Pattern 'PartExit 0' -Quiet)) { throw 'fe112 not built' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp112.sha256", "$P2/cold-tp112")
  ,@('stage-copy', "$P2/pins/source-tp112.sha256", "$P2/cold-tp112", "$P2/cold-boot112")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot112", "$P2/pins/source-boot112.sha256")
  ,@('verify', "$P2/pins/source-boot112.sha256", "$P2/cold-boot112")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot112-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot112-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h112=ShaTp "$p\pins\source-tp112.sha256"
$hb=ShaTp "$p\pins\source-boot112.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp112 $h112 source-boot112 $hb") -Encoding utf8
if ($h112 -ne $hb) { throw 'source-boot112 differs from source-tp112' }
foreach ($g in @("$p\cold-boot112\headers", "$p\cold-boot112\src\l2src\lmx.h.lm1", "$p\cold-boot112\src\l1src\libc_abi.lm1", "$p\cold-boot112\src\l2src\l2_frontend_state.lm1", "$p\cold-boot112\quick112")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
