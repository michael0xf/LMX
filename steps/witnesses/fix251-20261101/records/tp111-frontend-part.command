try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp111 (fable_pc, S2): the development frontend fe111 -- l2_frontend_values (dispose hook), l2_frontend_views (head-source
# memo), l2_frontend_context (owner memo) and l2_frontend_resolve (declaration map) translated by fe110 (63fd9e71, whose
# Lower translation is byte-equal to G1's); every other generated file reused by tp111-reuse-inputs.sha256 (233 files:
# the 231 G1 files of tp110-reuse-02 minus the four L1 bodies this build regenerates, plus fe110's l2_frontend_types.lm1
# and l2_frontend_intern.lm1); the ABI manifest tp111-reuse-artifacts.sha256 (the same 233 files, which must stay
# byte-identical, the four regenerated headers among them) is verified before and after. Host: tool111
# (cold-tp111/tool111/lmxtool-tool.exe), whose tools/build.lm2 writes the thirteen memo cells into l2_frontend_state.lm1.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$host111="$p\cold-tp111\tool111\lmxtool-tool.exe"
$fe="$p\cold-tp110\fe110\l2trans.exe"
$term="$p\pins\tp111-frontend-part.terminal.txt"
$run="$p\tp111-frontend-part-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp111\fe111") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $host111)) { throw 'tool111 missing' }
if (-not (Select-String -LiteralPath "$p\pins\tp111-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool111 not built' }
if ((ShaTp $fe) -ne '63fd9e71fffdefa7922592fc74b78793d7f27fb84ab91d3ad1123ac7a4ccbc1c') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp111-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp111 stage not prepared' }
foreach ($g in @("$p\cold-tp111\src\l2src\l2_frontend_values.lm1", "$p\cold-tp111\src\l2src\l2_frontend_views.lm1", "$p\cold-tp111\src\l2src\l2_frontend_context.lm1", "$p\cold-tp111\src\l2src\l2_frontend_resolve.lm1")) { if (Test-Path -LiteralPath $g) { throw ('output exists before the build: ' + $g) } }
$state="$p\cold-tp111\src\l2src\l2_frontend_state.lm1"
$stateBefore='absent'
if (Test-Path -LiteralPath $state) { $stateBefore=(ShaTp $state) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' host ' + (ShaTp $host111) + ' producer ' + (ShaTp $fe) + ' state-before ' + $stateBefore) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $host111 0 entry 0 -- build-frontend-part $R "$P2/cold-tp111" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp110/fe110/l2trans.exe" fe111 'l2_frontend_values,l2_frontend_views,l2_frontend_context,l2_frontend_resolve' "$P2/pins/tp111-reuse-inputs.sha256" "$P2/pins/tp111-reuse-artifacts.sha256" *> "$p\pins\tp111-frontend-part.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' PartExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp111\fe111\l2trans.exe", "$p\cold-tp111\fe111\l1trans.exe", "$p\cold-tp111\fe111\l2_libc.o", "$p\cold-tp111\fe111\frontend.c", "$p\cold-tp111\src\l2src\l2_frontend_values.h.lm1", "$p\cold-tp111\src\l2src\l2_frontend_values.lm1", "$p\cold-tp111\src\l2src\l2_frontend_views.h.lm1", "$p\cold-tp111\src\l2src\l2_frontend_views.lm1", "$p\cold-tp111\src\l2src\l2_frontend_context.h.lm1", "$p\cold-tp111\src\l2src\l2_frontend_context.lm1", "$p\cold-tp111\src\l2src\l2_frontend_resolve.h.lm1", "$p\cold-tp111\src\l2src\l2_frontend_resolve.lm1", $state)) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE111 exit=' + $e)
exit $e
