try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# FE93: ONLY Lower (lm_compiler_indirect_managed) and Emit (the throw-channel
# effects of the native typed dereference) on stage93, with the generator93
# host (writer93: Lower exports 443), explicit producer 49c, BASE
# full48/g2/frontend; the other 19 frontend modules are reused by exact
# manifests (candidate93-reuse-*); Emit's .h.lm1 is in the ABI manifest, Lower's
# is regenerated (one appended export).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate93-frontend-parts-run-01"
$host93="$p\cold-generator93\tool93-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host93)) { throw 'nohost93' }
if (Test-Path -LiteralPath "$p\cold-candidate93\fe93") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate93-frontend-parts-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate93.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate93-frontend-parts-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host93).Hash),[Text.UTF8Encoding]::new($false))
& $host93 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate93" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe93 'l2_frontend_lower,l2_frontend_emit' "$p/pins/candidate93-reuse-inputs.sha256" "$p/pins/candidate93-reuse-artifacts.sha256" *> "$p\pins\candidate93-frontend-parts.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate93-frontend-parts-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
