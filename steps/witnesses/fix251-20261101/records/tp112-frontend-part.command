try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp112 (fable_pc, S3): the development frontend fe112 -- l2_frontend_context (contract-source reader, own-name index),
# l2_frontend_resolve (contract index and ordinal writers) and l2_frontend_core (own_free generation, machine_validate
# order) translated by fe111 (3f174068, whose Lower/Core/Emit translations are byte-equal to G1's); every other generated
# file reused by tp112-reuse-inputs.sha256 (234 files: the 230 G1 files of tp111-reuse minus the core L1 body this
# build regenerates, plus fe110's types/intern L1 and fe111's values/views L1); the ABI manifest tp112-reuse-artifacts.sha256
# (the same 234 files, which must stay byte-identical, the three regenerated headers among them) is verified before and
# after. Host: tool112 (cold-tp112/tool112/lmxtool-tool.exe), whose tools/build.lm2 writes the 46 cells of tp110-tp112.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$host112="$p\cold-tp112\tool112\lmxtool-tool.exe"
$fe="$p\cold-tp111\fe111\l2trans.exe"
$term="$p\pins\tp112-frontend-part.terminal.txt"
$run="$p\tp112-frontend-part-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp112\fe112") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $host112)) { throw 'tool112 missing' }
if (-not (Select-String -LiteralPath "$p\pins\tp112-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool112 not built' }
if ((ShaTp $fe) -ne '3f1740682347153194045163f85636b45f4173ec3a4529039db79b166957bd1e') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp112-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp112 stage not prepared' }
foreach ($g in @("$p\cold-tp112\src\l2src\l2_frontend_context.lm1", "$p\cold-tp112\src\l2src\l2_frontend_resolve.lm1", "$p\cold-tp112\src\l2src\l2_frontend_core.lm1")) { if (Test-Path -LiteralPath $g) { throw ('output exists before the build: ' + $g) } }
$state="$p\cold-tp112\src\l2src\l2_frontend_state.lm1"
$stateBefore='absent'
if (Test-Path -LiteralPath $state) { $stateBefore=(ShaTp $state) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' host ' + (ShaTp $host112) + ' producer ' + (ShaTp $fe) + ' state-before ' + $stateBefore) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $host112 0 entry 0 -- build-frontend-part $R "$P2/cold-tp112" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-tp111/fe111/l2trans.exe" fe112 'l2_frontend_context,l2_frontend_resolve,l2_frontend_core' "$P2/pins/tp112-reuse-inputs.sha256" "$P2/pins/tp112-reuse-artifacts.sha256" *> "$p\pins\tp112-frontend-part.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' PartExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp112\fe112\l2trans.exe", "$p\cold-tp112\fe112\l1trans.exe", "$p\cold-tp112\fe112\l2_libc.o", "$p\cold-tp112\fe112\frontend.c", "$p\cold-tp112\src\l2src\l2_frontend_context.h.lm1", "$p\cold-tp112\src\l2src\l2_frontend_context.lm1", "$p\cold-tp112\src\l2src\l2_frontend_resolve.h.lm1", "$p\cold-tp112\src\l2src\l2_frontend_resolve.lm1", "$p\cold-tp112\src\l2src\l2_frontend_core.h.lm1", "$p\cold-tp112\src\l2src\l2_frontend_core.lm1", $state)) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE112 exit=' + $e)
exit $e
