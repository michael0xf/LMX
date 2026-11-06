try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 287. Frontend of the stage cold-tp140 translated by the boot148b G2 frontend. Parameters TP_TOOL (a path under P),
# TP_LABEL, TP_TRY. With TP_PARTS, TP_REUSE and TP_ABI (lists under pins, pinned here into sha256 manifests of the stage before the
# build) only the named parts are retranslated; without them the whole frontend is built.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY; $parts=$env:TP_PARTS; $reuse=$env:TP_REUSE; $abi=$env:TP_ABI
if (-not $label -or -not $try -or -not $env:TP_TOOL) { throw 'parameters TP_TOOL TP_LABEL TP_TRY' }
$tool=$p + '\' + ($env:TP_TOOL -replace '/','\')
$fe="$p\cold-boot148b\quick148b\g2\frontend\l2trans.exe"
$term="$p\pins\tp149-fe-$try.terminal.txt"
$run="$p\tp149-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $fe) -ne '3480b4deb7495365ac146964e3813e82501821c39d2e6b68d7cd870faa9e049c') { throw 'frontend hash' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' parts ' + $parts + ' tool ' + (ShaTp $tool) + ' emit.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_emit.lm2")) -Encoding utf8
if ($parts) {
  if (-not $reuse -or -not $abi) { throw 'parameters TP_REUSE TP_ABI' }
  $reuseSha="$P2/pins/tp149-fe-$try-reuse.sha256"
  $abiSha="$P2/pins/tp149-fe-$try-abi.sha256"
  & $tool 0 entry 0 -- manifest "$P2/pins/$reuse" "$P2/cold-tp140" $reuseSha *> "$p\pins\tp149-fe-$try-pin-01.log"
  if ($LASTEXITCODE -ne 0) { throw 'reuse manifest' }
  & $tool 0 entry 0 -- manifest "$P2/pins/$abi" "$P2/cold-tp140" $abiSha *> "$p\pins\tp149-fe-$try-pin-02.log"
  if ($LASTEXITCODE -ne 0) { throw 'abi manifest' }
  & 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend-part $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot148b/quick148b/g2/frontend/l2trans.exe" $label $parts $reuseSha $abiSha *> "$p\pins\tp149-fe-$try.log"
} else {
  & 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot148b/quick148b/g2/frontend/l2trans.exe" $label *> "$p\pins\tp149-fe-$try.log"
}
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\l2trans.exe", "$p\cold-tp140\$label\l1trans.exe", "$p\cold-tp140\$label\l2_libc.o")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('FE149 ' + $label + ' exit=' + $e)
exit 0
