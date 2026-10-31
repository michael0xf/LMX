try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE84: ONLY Useplan84 and Core84 with the generator84 host (writer84 export
# lists), explicit producer 49c; reuse FE83's Lower83/Emit83 outputs and the
# rest of the 80b-era reuse set by exact manifests (candidate84-reuse-*).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate84-frontend-parts-run-01"
$host84="$p\cold-generator84\tool84-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host84)) { throw 'nohost84' }
if (Test-Path -LiteralPath "$p\cold-candidate84\fe84") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate84-frontend-parts-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate84.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate84-frontend-parts-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host84).Hash),[Text.UTF8Encoding]::new($false))
& $host84 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate84" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe84 'l2_frontend_useplan,l2_frontend_core' "$p/pins/candidate84-reuse-inputs.sha256" "$p/pins/candidate84-reuse-artifacts.sha256" *> "$p\pins\candidate84-frontend-parts.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate84-frontend-parts-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
