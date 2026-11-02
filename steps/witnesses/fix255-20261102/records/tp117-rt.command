try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp117 rt (fable_pc): the isolated runtime build of the candidate's kernel (label rt117) before the long builds -- tool117
# (CFD04412, tp117's tools/build.lm2: the lmx_walk_values exports lmx_walk_value_lit/receive/bin and the helpers' free-type
# exports) with boot116c's G2 frontend (25EDB0D0): the stage's declaration headers are rewritten first (decls_write_all), then
# the kernel's L2 modules (lmx_walk_values with the shared binary operation, the reception, the contextual literal and the
# untyped ARG place), the driver, the C headers and the driver objects, all under cold-tp117/rt117.  A refusal of the kernel's
# L2 or of its C compile is conclusive here in a minute; the frontend modules are checked by their standalone translations
# (tp117-selfcheck).  Fresh CWD.  Parameter: TP_LABEL (rt117, rt117b, ...) and TP_TRY (the terminal's suffix).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-tp117\tool117\lmxtool-tool.exe"
$fe="$p\cold-boot116c\quick116c\g2\frontend\l2trans.exe"
$term="$p\pins\tp117-rt-$try.terminal.txt"
$run="$p\tp117-rt-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp117\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'cfd04412bc01bae832d39b2fc77b70e27f363e6758e5ca9b3ff78b6fe3475723') { throw 'tool117 hash' }
if ((ShaTp $fe) -ne '25edb0d0f95b067df77ea78c8460648adb98d8169869eb00d5d10735b5918c9f') { throw 'frontend hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp117-tool.terminal.txt" -Pattern 'RebuildExit 0' -Quiet)) { throw 'tool117 not built' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' walk_values.lm2 ' + (ShaTp "$p\cold-tp117\src\l2src\lmx_walk_values.lm2") + ' driver.lm2 ' + (ShaTp "$p\cold-tp117\src\l2src\l2_driver.lm2") + ' build.lm2 ' + (ShaTp "$p\cold-tp117\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-runtime $R "$P2/cold-tp117" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot116c/quick116c/g2/frontend/l2trans.exe" $label *> "$p\pins\tp117-rt-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RuntimeExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp117\$label\driver.o", "$p\cold-tp117\$label\driver-observe.o", "$p\cold-tp117\src\l2src\lmx.h.lm1", "$p\cold-tp117\src\l2src\lmx_walk_values.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp117\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp117\$label\record.txt" | Select-Object -Last 6 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('RT117 ' + $label + ' exit=' + $e)
exit $e
