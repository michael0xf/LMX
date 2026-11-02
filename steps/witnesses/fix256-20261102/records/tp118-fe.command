try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp118 fe (fable_pc): the isolated frontend build of the candidate (label TP_LABEL: fe118, fe118b, ...) before the long
# bootstrap -- boot117a's G2 working tool (4E1D96D4) builds the frontend from the stage cold-tp118 with boot117a's G2 frontend
# (1113EE3B) as the previous frontend: the frontend modules' headers are regenerated first, then every frontend module is
# translated in order, the backend and libc, and l2trans.exe is compiled.  A refusal of a patched module's L2 is conclusive here
# in minutes; the resulting l2trans.exe, with rt118's driver objects, then runs the focus suite (tp118-suite) before the
# bootstrap.  Fresh CWD.  Parameters: TP_LABEL, TP_TRY (the terminal's suffix).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot117a\quick117a\lmxtool.exe"
$fe="$p\cold-boot117a\quick117a\g2\frontend\l2trans.exe"
$term="$p\pins\tp118-fe-$try.terminal.txt"
$run="$p\tp118-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp118\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4e1d96d4c939ceaa2721abd1413efaa93feb4cc5bb7e318eeaff87bb3af5aa68') { throw 'working tool hash' }
if ((ShaTp $fe) -ne '1113ee3b03b5e76895046078d8a4959bf34d6bb86bc26ac3e416553c09b39520') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' lower.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\l2_frontend_lower.lm2") + ' core.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\l2_frontend_core.lm2") + ' emit.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\l2_frontend_emit.lm2") + ' helpers.lm2 ' + (ShaTp "$p\cold-tp118\src\l2src\l2_frontend_helpers.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp118" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot117a/quick117a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp118-fe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp118\$label\l2trans.exe", "$p\cold-tp118\$label\l1trans.exe", "$p\cold-tp118\$label\l2_libc.o", "$p\cold-tp118\src\l2src\l2_frontend_helpers.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp118\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp118\$label\record.txt" | Select-Object -Last 4 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('FE118 ' + $label + ' exit=' + $e)
exit $e
