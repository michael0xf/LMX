try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE87: ONLY Lower87 of coherent85 with the generator85 host (writer85 export
# lists), explicit producer 49c; FE85's Useplan/Core/Emit and the 80b-era set
# are reused by exact manifests (candidate87-reuse-*).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate87-frontend-parts-run-01"
$host85="$p\cold-generator85\tool85-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host85)) { throw 'nohost85' }
if (Test-Path -LiteralPath "$p\cold-candidate87\fe87") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate87-frontend-parts-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate87.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate87-frontend-parts-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host85).Hash),[Text.UTF8Encoding]::new($false))
& $host85 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate87" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe87 'l2_frontend_lower' "$p/pins/candidate87-reuse-inputs.sha256" "$p/pins/candidate87-reuse-artifacts.sha256" *> "$p\pins\candidate87-frontend-parts.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate87-frontend-parts-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
