try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Relaunch of option (B) (CODEX-OPUS-87V63-20261031-ANSWER) after boot88's G1
# runtime stopped at lmx_pool.lm2:150:12 "assignment value has unknown type"
# (a required-path blocker, CODEX-OPUS-85FIND-20261031-ANSWER: fix it and
# continue): a fresh source-only stage of the green line -- the 159 selected
# inputs of stage84 (source-candidate84) with walker86 (candidate86w-walker)
# and ONLY green89's l2_frontend_resolve (candidate89g-frontend; FE89g with it
# translated all 36 kernel/driver modules, census89g-kernel). No generated
# header, body, object or reuse set.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\boot89-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-boot89") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84")
  ,@('verify', "$P2/pins/candidate86w-walker.sha256", "$P2/variants/walker86")
  ,@('verify', "$P2/pins/candidate89g-frontend.sha256", "$P2/variants/green89")
  ,@('stage-copy', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84", "$P2/cold-boot89")
  ,@('stage-copy', "$P2/pins/candidate86w-walker.sha256", "$P2/variants/walker86", "$P2/cold-boot89")
  ,@('stage-copy', "$P2/pins/candidate89g-frontend.sha256", "$P2/variants/green89", "$P2/cold-boot89")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-boot89", "$P2/pins/source-boot89.sha256")
  ,@('verify', "$P2/pins/source-boot89.sha256", "$P2/cold-boot89")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\boot89-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\boot89-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
foreach ($g in @("$p\cold-boot89\headers", "$p\cold-boot89\src\l2src\lmx.h.lm1", "$p\cold-boot89\src\l1src\libc_abi.lm1", "$p\cold-boot89\quick89")) {
  if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
}
Write-Output ('PREPARED ' + $i + ' steps')
