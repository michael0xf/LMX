try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate82-frontend-parts-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-candidate82\fe82") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate82-frontend-parts-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate82.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate82-frontend-parts-start.txt",[DateTime]::UtcNow.ToString('o'),[Text.UTF8Encoding]::new($false))
& "$p\cold-generator62\tool62-parts\lmxtool-tool.exe" 0 entry 0 -- build-frontend-part 'C:/Nyasha_Planet/LMX' "$p/cold-candidate82" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" fe82 'l2_frontend_lower' "$p/pins/candidate81-reuse-inputs.sha256" "$p/pins/candidate81-reuse-artifacts.sha256" *> "$p\pins\candidate82-frontend-parts.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate82-frontend-parts-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
