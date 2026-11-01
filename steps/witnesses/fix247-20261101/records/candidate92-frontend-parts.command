try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE92: ONLY Lower (the native typed dereference qualified by the shared
# lmx_value_loaded_context) and Coords (the split-pointer data row) on stage92,
# with the generator92 host (writer92), explicit producer 49c, BASE
# full48/g2/frontend; FE90's other 19 frontend modules are reused by exact
# manifests (candidate92-reuse-*); both changed modules' .h.lm1 are in the ABI
# manifest (body-only changes).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate92-frontend-parts-run-01"
$host92="$p\cold-generator92\tool92-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host92)) { throw 'nohost92' }
if (Test-Path -LiteralPath "$p\cold-candidate92\fe92") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate92-frontend-parts-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate92.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate92-frontend-parts-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host92).Hash),[Text.UTF8Encoding]::new($false))
& $host92 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate92" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe92 'l2_frontend_lower,l2_frontend_coords' "$p/pins/candidate92-reuse-inputs.sha256" "$p/pins/candidate92-reuse-artifacts.sha256" *> "$p\pins\candidate92-frontend-parts.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate92-frontend-parts-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
