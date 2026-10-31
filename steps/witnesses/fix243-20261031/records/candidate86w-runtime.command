try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# RT86w: build-runtime of stage86w (stage83 with walker86) with the same
# generator83b host as RT83: BASE full48/g2/frontend, FE 49c. The kernel
# declaration headers are regenerated from writer83b (unchanged; the new
# walker helper is module-internal).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate86w-runtime-run-01"
$host83="$p\cold-generator83b\tool83b-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host83)) { throw 'nohost83' }
if (Test-Path -LiteralPath "$p\cold-candidate86w\rt86w") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate86w-runtime-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate86w.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate86w-runtime-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host83).Hash),[Text.UTF8Encoding]::new($false))
& $host83 0 entry 0 -- build-runtime 'C:/Nyasha_Planet/LMX' "$p/cold-candidate86w" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" rt86w *> "$p\pins\candidate86w-runtime.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate86w-runtime-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
