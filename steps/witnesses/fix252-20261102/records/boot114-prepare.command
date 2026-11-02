try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# boot114 (fable_pc, after tp113 = the method-name index and tp114 = the owner memo without the tree re-check, the predef
# file index and the fact index): a fresh source-only stage cold-boot114 with exactly the 159 selected inputs of stage
# cold-tp114 (source-tp114: source-full100 with the nine files of tp110-tp114 -- types, intern, values, views, context,
# resolve, core, emit, tools/build.lm2), i.e. the sources of fe114 + the G1 full100 kernel. No generated header, body,
# object or reuse set. Frozen tool E8150E60 for verify/stage-copy/manifest only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\boot114-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot114") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp114 stage not prepared' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-prepare-fix02.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'tp114 stage fix02 not verified' }
if ((ShaTp "$p\pins\source-tp114.sha256") -ne 'fe3fda29b2b6029db640717baf88e812f75f6ad3b8e64c54ff5bcf27bf31d6cf') { throw 'source-tp114 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-frontend-part.terminal.txt" -Pattern 'PartExit 0' -Quiet)) { throw 'fe114 not built' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp114.sha256", "$P2/cold-tp114")
  ,@('stage-copy', "$P2/pins/source-tp114.sha256", "$P2/cold-tp114", "$P2/cold-boot114")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot114", "$P2/pins/source-boot114.sha256")
  ,@('verify', "$P2/pins/source-boot114.sha256", "$P2/cold-boot114")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot114-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot114-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$h112=ShaTp "$p\pins\source-tp114.sha256"
$hb=ShaTp "$p\pins\source-boot114.sha256"
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " source-tp114 $h112 source-boot114 $hb") -Encoding utf8
if ($h112 -ne $hb) { throw 'source-boot114 differs from source-tp114' }
foreach ($g in @("$p\cold-boot114\headers", "$p\cold-boot114\src\l2src\lmx.h.lm1", "$p\cold-boot114\src\l1src\libc_abi.lm1", "$p\cold-boot114\src\l2src\l2_frontend_state.lm1", "$p\cold-boot114\quick114")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
