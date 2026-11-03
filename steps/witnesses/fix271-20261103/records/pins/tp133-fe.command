try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 271. tp133-fe.command uses the verified boot132c seed and the tp133 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-tp133\tool133\lmxtool-tool.exe"
$fe="$p\cold-boot132c\quick132c\g2\frontend\l2trans.exe"
$term="$p\pins\tp133-fe-$try.terminal.txt"
$run="$p\tp133-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp133\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1c4b0ba8423564d78e95130a687b71a6ed61604c7e85920bef4e528a691a1d84') { throw 'working tool hash' }
if ((ShaTp $fe) -ne 'fa22765b71e99c1e2f5b4eb0f01588eec5859e9d30405945492a73dece09b99d') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' lower.lm2 ' + (ShaTp "$p\cold-tp133\src\l2src\l2_frontend_lower.lm2") + ' core.lm2 ' + (ShaTp "$p\cold-tp133\src\l2src\l2_frontend_core.lm2") + ' emit.lm2 ' + (ShaTp "$p\cold-tp133\src\l2src\l2_frontend_emit.lm2") + ' helpers.lm2 ' + (ShaTp "$p\cold-tp133\src\l2src\l2_frontend_helpers.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp133" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot132c/quick132c/g2/frontend/l2trans.exe" $label *> "$p\pins\tp133-fe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp133\$label\l2trans.exe", "$p\cold-tp133\$label\l1trans.exe", "$p\cold-tp133\$label\l2_libc.o", "$p\cold-tp133\src\l2src\l2_frontend_helpers.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
if (Test-Path -LiteralPath "$p\cold-tp133\$label\record.txt") { Get-Content -LiteralPath "$p\cold-tp133\$label\record.txt" | Select-Object -Last 4 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  record: ' + $_) -Encoding utf8 } }
Write-Output ('FE132 ' + $label + ' exit=' + $e)
exit $e
