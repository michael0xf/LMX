try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 rt-fix02 (fable_pc): the isolated runtime build again (label rt116c) after fix04 -- rt116b passed lmx_call and refused
# lmx_walk_values.lm2:5818 (a path actual of an L2 call).  The rt-fix01 text follows.
# tp116 rt-fix01 (fable_pc): the isolated runtime build again (label rt116c) after fix03 -- rt116 refused lmx_call.lm2:225
# (`length` is a word of the language: a program cannot bind it) before any other kernel module of the candidate was
# reached; the standalone translations then showed lmx_walk_values.lm2:5771 (the same word) and l2_driver.lm2:813 (a local
# array declaration `[]: LmxWalkValue vals 2`, unsupported in L2).  The same tool116 (E8AD9AA2) and frontend (EBCADAE2); the
# stage's declaration headers are rewritten first (decls_write_all), then the kernel's L2 modules, the driver, the C headers
# and the driver objects, all under cold-tp116/rt116c.  Fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-tp116\tool116\lmxtool-tool.exe"
$fe="$p\cold-boot115f\quick115f\g2\frontend\l2trans.exe"
$term="$p\pins\tp116-rt-fix02.terminal.txt"
$run="$p\tp116-rt-fix02-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp116\rt116c") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8ad9aa2f2f275cac1bfd2d13a75c5e7da71e55f85e926f73661a9e48dc865c4') { throw 'tool116 hash' }
if ((ShaTp $fe) -ne 'ebcadae22999740d01235b8776379362db05baea5772c95dada7f4448db243a8') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-prepare-fix04.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage fix04 not verified' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool116 not built' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp116\src\l2src\lmx_walk_values.lm2") + ' call.lm2 ' + (ShaTp "$p\cold-tp116\src\l2src\lmx_call.lm2") + ' driver.lm2 ' + (ShaTp "$p\cold-tp116\src\l2src\l2_driver.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp116\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp116" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot115f/quick115f/g2/frontend/l2trans.exe" rt116c *> "$p\pins\tp116-rt-fix02.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp116\rt116c\driver.o", "$p\cold-tp116\rt116c\driver-observe.o", "$p\cold-tp116\src\l2src\lmx.h.lm1", "$p\cold-tp116\src\l2src\lmx_call.h.lm1", "$p\cold-tp116\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp116\rt116c\record.txt") { Get-Content -LiteralPath "$p\cold-tp116\rt116c\record.txt" | Select-Object -Last 6 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('RT116C exit=' + $e)
exit $e
