try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, S1): the development frontend fe110 -- only l2_frontend_types (the predef declaration index) and
# l2_frontend_intern (pd_free resets it) translated by G1 full100's frontend (bf6d713e); every other generated file
# reused from G1 full100 by the manifest tp110-reuse-02-inputs.sha256 (235 generated files = every generated file of
# G1's consumed-inputs snapshot except the three this build regenerates and the tool's lmxtool_methods files; the
# first pair of manifests, 135 files from the candidate81 precedent, lacked Lower's L1 -- pins/tp110-reuse-02.command);
# the ABI manifest tp110-reuse-02-artifacts.sha256 (the same 235 files, which must stay byte-identical, the types and
# intern headers among them) is verified before and after. Host: the tool of tp110 (cold-tp110/tool110/lmxtool-tool.exe), whose
# tools/build.lm2 writes the nine new state cells into l2_frontend_state.lm1; the recipe is the maintained build-frontend-part.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$host110="$p\cold-tp110\tool110\lmxtool-tool.exe"
$fe="$p\cold-full100\full100\g1\frontend\l2trans.exe"
$term="$p\pins\tp110-frontend-part.terminal.txt"
$run="$p\tp110-frontend-part-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp110\fe110") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if (-not (Test-Path -LiteralPath $host110)) { throw 'tool110 missing' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool110 not built' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-reuse-02.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'reuse-02 manifests not verified' }
if ((ShaTp $fe) -ne 'bf6d713e4be632a5be4d2334d388ca6658a0dd34b56c4c7fcc56dc87a412e6bc') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-prepare.terminal.txt" -Pattern ' 10 exit=0 ' -Quiet)) { throw 'stage not prepared' }
foreach ($g in @("$p\cold-tp110\src\l2src\l2_frontend_types.lm1", "$p\cold-tp110\src\l2src\l2_frontend_intern.lm1")) { if (Test-Path -LiteralPath $g) { throw ('output exists before the build: ' + $g) } }
$state="$p\cold-tp110\src\l2src\l2_frontend_state.lm1"
$stateBefore='absent'
if (Test-Path -LiteralPath $state) { $stateBefore=(ShaTp $state) }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' host ' + (ShaTp $host110) + ' state-before ' + $stateBefore) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $host110 0 entry 0 -- build-frontend-part $R "$P2/cold-tp110" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-full100/full100/g1/frontend/l2trans.exe" fe110 'l2_frontend_types,l2_frontend_intern' "$P2/pins/tp110-reuse-02-inputs.sha256" "$P2/pins/tp110-reuse-02-artifacts.sha256" *> "$p\pins\tp110-frontend-part.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' PartExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp110\fe110\l2trans.exe", "$p\cold-tp110\fe110\l1trans.exe", "$p\cold-tp110\fe110\l2_libc.o", "$p\cold-tp110\fe110\frontend.c", "$p\cold-tp110\src\l2src\l2_frontend_types.h.lm1", "$p\cold-tp110\src\l2src\l2_frontend_types.lm1", "$p\cold-tp110\src\l2src\l2_frontend_intern.h.lm1", "$p\cold-tp110\src\l2src\l2_frontend_intern.lm1", $state)) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE110 exit=' + $e)
exit $e
