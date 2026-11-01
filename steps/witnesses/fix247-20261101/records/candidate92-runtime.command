try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# RT92: build-runtime of stage92 with the generator92 host (writer92: the
# lmx_value_owned export list carries lmx_value_loaded_context, so its
# generated header declares it before the walker and the programs consume it),
# BASE full48/g2/frontend, kernel translated by FE 49c as for RT87. Runs after
# FE92 in the same stage.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate92-runtime-run-01"
$host92="$p\cold-generator92\tool92-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host92)) { throw 'nohost92' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate92\fe92\l2trans.exe")) { throw 'nofe92' }
if (Test-Path -LiteralPath "$p\cold-candidate92\rt92") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate92-runtime-start.txt") { throw 'startexists' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate92-runtime-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host92).Hash),[Text.UTF8Encoding]::new($false))
& $host92 0 entry 0 -- build-runtime 'C:/Nyasha_Planet/LMX' "$p/cold-candidate92" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" rt92 *> "$p\pins\candidate92-runtime.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate92-runtime-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
