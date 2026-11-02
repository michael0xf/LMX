try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp114 (fable_pc, S3c): the development frontend fe114 -- l2_frontend_types (predef file index), l2_frontend_values (fact
# index, document-destroy helper), l2_frontend_context (owner memo without the tree re-check), l2_frontend_core and
# l2_frontend_emit (document-destroy helpers, the fact and snap generations) translated by fe113 (6038f156, whose
# Lower/Core/Emit translations are byte-equal to G1's); every other generated file reused by tp114-reuse-inputs.sha256
# (232 files: tp113-reuse minus the types L1 body this build regenerates); the ABI manifest tp114-reuse-artifacts.sha256
# (the same 232 files, which must stay byte-identical, the five regenerated headers among them) is verified before and
# after. Host: tool114 (cold-tp114/tool114/lmxtool-tool.exe), whose tools/build.lm2 writes the 85 cells of tp110-tp114.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$host114="$p\cold-tp114\tool114\lmxtool-tool.exe"
$fe="$p\cold-tp113\fe113\l2trans.exe"
$term="$p\pins\tp114-frontend-part.terminal.txt"
$run="$p\tp114-frontend-part-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp114\fe114") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $host114)) { throw 'tool114 missing' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool114 not built' }
if ((ShaTp $fe) -ne '6038f156b6cca0a2d0ca13a7f1b9c1f782be0f7b1124ab0d0126b7f5bbabd70e') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp114 stage not prepared' }
foreach ($g in @("$p\cold-tp114\src\l2src\l2_frontend_types.lm1", "$p\cold-tp114\src\l2src\l2_frontend_context.lm1", "$p\cold-tp114\src\l2src\l2_frontend_values.lm1", "$p\cold-tp114\src\l2src\l2_frontend_core.lm1", "$p\cold-tp114\src\l2src\l2_frontend_emit.lm1")) { if (Test-Path -LiteralPath $g) { throw ('output exists before the build: ' + $g) } }
$state="$p\cold-tp114\src\l2src\l2_frontend_state.lm1"
$stateBefore='absent'
if (Test-Path -LiteralPath $state) { $stateBefore=(ShaTp $state) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' host ' + (ShaTp $host114) + ' producer ' + (ShaTp $fe) + ' state-before ' + $stateBefore) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $host114 0 entry 0 -- build-frontend-part $R "$P2/cold-tp114" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp113/fe113/l2trans.exe" fe114 'l2_frontend_types,l2_frontend_values,l2_frontend_context,l2_frontend_core,l2_frontend_emit' "$P2/pins/tp114-reuse-inputs.sha256" "$P2/pins/tp114-reuse-artifacts.sha256" *> "$p\pins\tp114-frontend-part.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' PartExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp114\fe114\l2trans.exe", "$p\cold-tp114\fe114\l1trans.exe", "$p\cold-tp114\fe114\l2_libc.o", "$p\cold-tp114\fe114\frontend.c", "$p\cold-tp114\src\l2src\l2_frontend_types.h.lm1", "$p\cold-tp114\src\l2src\l2_frontend_types.lm1", "$p\cold-tp114\src\l2src\l2_frontend_context.h.lm1", "$p\cold-tp114\src\l2src\l2_frontend_context.lm1", "$p\cold-tp114\src\l2src\l2_frontend_values.h.lm1", "$p\cold-tp114\src\l2src\l2_frontend_values.lm1", "$p\cold-tp114\src\l2src\l2_frontend_core.h.lm1", "$p\cold-tp114\src\l2src\l2_frontend_core.lm1", "$p\cold-tp114\src\l2src\l2_frontend_emit.h.lm1", "$p\cold-tp114\src\l2src\l2_frontend_emit.lm1", $state)) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE114 exit=' + $e)
exit $e
