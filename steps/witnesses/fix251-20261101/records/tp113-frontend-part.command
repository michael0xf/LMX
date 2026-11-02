try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp113 (fable_pc, S3b): the development frontend fe113 -- l2_frontend_context (site_method over the method-name index),
# l2_frontend_values (find_method over it), l2_frontend_core (meth_free bumps the method-table generation) and
# l2_frontend_emit (the per-unit reset bumps it) translated by fe112 (46f3a974, whose Lower/Core/Emit translations are
# byte-equal to G1's); every other generated file reused by tp113-reuse-inputs.sha256 (233 files: the 229 G1 files of
# tp112-reuse minus the values and emit L1 bodies this build regenerates, plus fe110's types/intern L1, fe111's views L1
# and fe112's resolve L1); the ABI manifest tp113-reuse-artifacts.sha256 (the same 233 files, which must stay
# byte-identical, the four regenerated headers among them) is verified before and after. Host: tool113
# (cold-tp113/tool113/lmxtool-tool.exe), whose tools/build.lm2 writes the 57 cells of tp110-tp113.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$host113="$p\cold-tp113\tool113\lmxtool-tool.exe"
$fe="$p\cold-tp112\fe112\l2trans.exe"
$term="$p\pins\tp113-frontend-part.terminal.txt"
$run="$p\tp113-frontend-part-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp113\fe113") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $host113)) { throw 'tool113 missing' }
if (-not (Select-String -LiteralPath "$p\pins\tp113-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool113 not built' }
if ((ShaTp $fe) -ne '46f3a97471e26ce2a1587826ffb80deeb41f1bf039533d0611efd8076a03d207') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp113-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp113 stage not prepared' }
foreach ($g in @("$p\cold-tp113\src\l2src\l2_frontend_context.lm1", "$p\cold-tp113\src\l2src\l2_frontend_values.lm1", "$p\cold-tp113\src\l2src\l2_frontend_core.lm1", "$p\cold-tp113\src\l2src\l2_frontend_emit.lm1")) { if (Test-Path -LiteralPath $g) { throw ('output exists before the build: ' + $g) } }
$state="$p\cold-tp113\src\l2src\l2_frontend_state.lm1"
$stateBefore='absent'
if (Test-Path -LiteralPath $state) { $stateBefore=(ShaTp $state) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' host ' + (ShaTp $host113) + ' producer ' + (ShaTp $fe) + ' state-before ' + $stateBefore) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $host113 0 entry 0 -- build-frontend-part $R "$P2/cold-tp113" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp112/fe112/l2trans.exe" fe113 'l2_frontend_context,l2_frontend_values,l2_frontend_core,l2_frontend_emit' "$P2/pins/tp113-reuse-inputs.sha256" "$P2/pins/tp113-reuse-artifacts.sha256" *> "$p\pins\tp113-frontend-part.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' PartExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp113\fe113\l2trans.exe", "$p\cold-tp113\fe113\l1trans.exe", "$p\cold-tp113\fe113\l2_libc.o", "$p\cold-tp113\fe113\frontend.c", "$p\cold-tp113\src\l2src\l2_frontend_context.h.lm1", "$p\cold-tp113\src\l2src\l2_frontend_context.lm1", "$p\cold-tp113\src\l2src\l2_frontend_values.h.lm1", "$p\cold-tp113\src\l2src\l2_frontend_values.lm1", "$p\cold-tp113\src\l2src\l2_frontend_core.h.lm1", "$p\cold-tp113\src\l2src\l2_frontend_core.lm1", "$p\cold-tp113\src\l2src\l2_frontend_emit.h.lm1", "$p\cold-tp113\src\l2src\l2_frontend_emit.lm1", $state)) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE113 exit=' + $e)
exit $e
