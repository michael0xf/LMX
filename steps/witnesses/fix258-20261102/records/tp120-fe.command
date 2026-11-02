try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp120 fe (fable_pc): the isolated frontend build of the candidate (label TP_LABEL: fe120, fe120b, ...) before the long
# bootstrap -- boot119a's G2 working tool (64AE29A0) builds the frontend from the stage cold-tp120 with boot119a's G2 frontend
# (1249DB48) as the previous frontend: the frontend modules' headers are regenerated first, then every frontend module is
# translated in order, the backend and libc, and l2trans.exe is compiled.  A refusal of a patched module's L2 is conclusive here
# in minutes; the resulting l2trans.exe, with rt120's driver objects, then runs the focus suite (tp120-suite) before the
# bootstrap.  Fresh CWD.  Parameters: TP_LABEL, TP_TRY (the terminal's suffix).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot119a\quick119a\lmxtool.exe"
$fe="$p\cold-boot119a\quick119a\g2\frontend\l2trans.exe"
$term="$p\pins\tp120-fe-$try.terminal.txt"
$run="$p\tp120-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp120\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '64ae29a0d4e8b2ee22eec82724bcc410c4a4ffce906650698b9be52ccc660d01') { throw 'working tool hash' }
if ((ShaTp $fe) -ne '1249db487b9c8f0e63130793dc17b356739c07f14f1066418bca9376957c3ac0') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' lower.lm2 ' + (ShaTp "$p\cold-tp120\src\l2src\l2_frontend_lower.lm2") + ' core.lm2 ' + (ShaTp "$p\cold-tp120\src\l2src\l2_frontend_core.lm2") + ' emit.lm2 ' + (ShaTp "$p\cold-tp120\src\l2src\l2_frontend_emit.lm2") + ' helpers.lm2 ' + (ShaTp "$p\cold-tp120\src\l2src\l2_frontend_helpers.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp120" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot119a/quick119a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp120-fe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp120\$label\l2trans.exe", "$p\cold-tp120\$label\l1trans.exe", "$p\cold-tp120\$label\l2_libc.o", "$p\cold-tp120\src\l2src\l2_frontend_helpers.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp120\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp120\$label\record.txt" | Select-Object -Last 4 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('FE120 ' + $label + ' exit=' + $e)
exit $e
