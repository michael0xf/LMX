try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp112 (fable_pc, S3): the tool of candidate tp112 -- tools/build.lm2 with 24 index cells of tp112 over tp111's 22 in its
# generated l2_frontend_state.lm1 -- built by the maintained `rebuild tool` from the stage cold-tp112's tool sources, with
# G1 full100's frontend (bf6d713e) and G1 full100's runtime objects; the recipe then runs the smoke list with that frontend
# and runtime through the new tool. Host tool: G1 full100's promoted working tool (E8150E60). Nothing of this is a frontend
# yet: the new tool is what writes the state file of the following frontend-part build (tp112-frontend-part.command).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$fe="$p\cold-full100\full100\g1\frontend\l2trans.exe"
$rt="$p\cold-full100\full100\g1\runtime"
$term="$p\pins\tp112-tool.terminal.txt"
$run="$p\tp112-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp112\tool112") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'bf6d713e4be632a5be4d2334d388ca6658a0dd34b56c4c7fcc56dc87a412e6bc') { throw 'frontend hash' }
if (-not (Test-Path -LiteralPath "$rt\driver.o") -or -not (Test-Path -LiteralPath "$rt\driver-observe.o")) { throw 'runtime objects' }
if (-not (Select-String -LiteralPath "$p\pins\tp112-prepare.terminal.txt" -Pattern ' 10 exit=0 ' -Quiet)) { throw 'stage not prepared' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp112" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-full100/full100/g1/frontend/l2trans.exe" "$P2/cold-full100/full100/g1/runtime" tool112 "$P2/cold-tp112/tests/smoke-kernel225.tsv" *> "$p\pins\tp112-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp112\tool112\lmxtool-tool.exe", "$p\cold-tp112\tool112\lmxtool.lm1", "$p\cold-tp112\tool112\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL112 exit=' + $e)
exit $e
