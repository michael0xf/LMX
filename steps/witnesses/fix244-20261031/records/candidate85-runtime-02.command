try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# RT85 attempt 02 (label rt85b): build-runtime of stage85 with the walker of
# candidate85b-walker (source-candidate85b; implements83, ValueOwned79, their
# declaration headers regenerated from writer85) with the generator85 host,
# as RT71: BASE full48/g2/frontend, FE 49c. Attempt 01 (rt85) stopped at
# lmx_walk_values.lm2:467 (assignment value has unknown type).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$run="$p\candidate85-runtime-02-run-01"
$host85="$p\cold-generator85\tool85-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (-not (Test-Path -LiteralPath $host85)) { throw 'nohost85' }
if (Test-Path -LiteralPath "$p\cold-candidate85\rt85b") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\candidate85-runtime-02-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-candidate85b.sha256")) { throw 'nosource85b' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\candidate85-runtime-02-start.txt",([DateTime]::UtcNow.ToString('o')+' host='+(Get-FileHash -Algorithm SHA256 -LiteralPath $host85).Hash),[Text.UTF8Encoding]::new($false))
& $host85 0 entry 0 -- build-runtime 'C:/Nyasha_Planet/LMX' "$p/cold-candidate85" "$p/cold-candidate48/full48/g2/frontend" "$p/cold-candidate49c/fe49c/l2trans.exe" rt85b *> "$p\pins\candidate85-runtime-02.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\candidate85-runtime-02-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
