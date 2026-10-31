try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE89g: ONLY l2_frontend_resolve of variants/green89 (stage89g), host tool84
# (the G0 of boot88, writer 3D4F4E71 export lists), explicit producer 49c and
# BASE full48/g2/frontend exactly as boot88's G1 frontend step; the other 20
# frontend modules are reused by exact manifests (candidate89g-reuse-*).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate89g-frontend-part-run-01"
$host84="$p\cold-generator84\tool84-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $host84).Hash -ne 'B9A2D857776B7BB3D8BFFFB386518CC05FB4F5D2651B77E4BD6ACBC5676A4D62') { throw 'tool84hash' }
if (Test-Path -LiteralPath "$p\cold-candidate89g\fe89g") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate89g-frontend-part-start.txt") { throw 'startexists' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate89g-frontend-part-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host84).Hash),[Text.UTF8Encoding]::new($false))
& $host84 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate89g" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe89g 'l2_frontend_resolve' "$p/pins/candidate89g-reuse-inputs.sha256" "$p/pins/candidate89g-reuse-artifacts.sha256" *> "$p\pins\candidate89g-frontend-part.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate89g-frontend-part-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
