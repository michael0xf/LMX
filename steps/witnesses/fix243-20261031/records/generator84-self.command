try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# build-self of generator84 with the accepted GEN62 host (351D933F), as GEN62
# itself was built: BASE full48/g2/frontend, FE 49c, RT RT49j (old coherent ABI).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$run="$p\generator84-self-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-generator84\tool84-parts") { throw 'outputexists' }
if (Test-Path -LiteralPath "$p\pins\generator84-self-start.txt") { throw 'startexists' }
if (-not (Test-Path -LiteralPath "$p\pins\source-generator84.sha256")) { throw 'sourcemissing' }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
[IO.File]::WriteAllText("$p\pins\generator84-self-start.txt",[DateTime]::UtcNow.ToString('o'),[Text.UTF8Encoding]::new($false))
& "$p\cold-generator62\tool62-parts\lmxtool-tool.exe" 0 entry 0 -- build-self 'C:/Nyasha_Planet/LMX' "$P2/cold-generator84" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-candidate49c/fe49c/l2trans.exe" "$P2/cold-candidate49j/rt49j/driver.o" tool84-parts *> "$p\pins\generator84-self.log"
$actualExit=$LASTEXITCODE
[IO.File]::WriteAllText("$p\pins\generator84-self-terminal.txt",([DateTime]::UtcNow.ToString('o')+' exit='+$actualExit),[Text.UTF8Encoding]::new($false))
Write-Output ('ACTUAL EXIT '+$actualExit)
exit $actualExit
