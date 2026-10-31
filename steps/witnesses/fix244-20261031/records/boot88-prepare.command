try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Option (B) of OPUS-CODEX-87V63-20261031T1400Z, launch only on Codex's
# answer: a fresh source-only stage of the green line -- the 159 selected
# inputs of stage84 (source-candidate84: stage83's sources + Useplan84, Core84,
# writer84) with walker86 (candidate86w-walker), exactly the FE84 + RT86w3 pair
# where held78 and owner73c gave 7 in all four modes. No generated header,
# body, object or reuse set.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\boot88-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot88") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84")
  ,@('verify', "$P2/pins/candidate86w-walker.sha256", "$P2/variants/walker86")
  ,@('stage-copy', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84", "$P2/cold-boot88")
  ,@('stage-copy', "$P2/pins/candidate86w-walker.sha256", "$P2/variants/walker86", "$P2/cold-boot88")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot88", "$P2/pins/source-boot88.sha256")
  ,@('verify', "$P2/pins/source-boot88.sha256", "$P2/cold-boot88")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot88-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot88-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
foreach ($g in @("$p\cold-boot88\headers", "$p\cold-boot88\src\l2src\lmx.h.lm1", "$p\cold-boot88\src\l1src\libc_abi.lm1", "$p\cold-boot88\quick88")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
