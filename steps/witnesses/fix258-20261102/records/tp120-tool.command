try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp120 (fable_pc, slice 258): the tool of candidate tp120 -- tools/build.lm2 with the lmx_walk_values exports
# lmx_walk_value_deref_actual and lmx_walk_place_address (144 -> 146 names: the runtime-typed deref and address a generated
# program calls through the one kernel) -- built by the maintained `rebuild tool` from the stage cold-tp120's tool sources with
# boot119a's G2 frontend (1249DB48) and boot119a's G2 runtime objects, exactly as tool120 was (tp120-tool); the recipe then runs
# the kernel smoke list with that frontend and runtime through the new tool.  Host tool: boot119a's promoted working tool
# (64AE29A0).  This tool, tool120, is the tool of the isolated builds and the G0 of boot120: its recipe writes the tp120 kernel
# declaration headers and passes the export lists in G1's builds.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot119a\quick119a\lmxtool.exe"
$fe="$p\cold-boot119a\quick119a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot119a\quick119a\g2\runtime"
$term="$p\pins\tp120-tool.terminal.txt"
$run="$p\tp120-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp120\tool120") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '64ae29a0d4e8b2ee22eec82724bcc410c4a4ffce906650698b9be52ccc660d01') { throw 'tool hash' }
if ((ShaTp $fe) -ne '1249db487b9c8f0e63130793dc17b356739c07f14f1066418bca9376957c3ac0') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '83295baf39a29815254cfbe8e740845595544a4f19d85ae6b9ef36e2ac04d386' -or (ShaTp "$rt\driver-observe.o") -ne 'eaeb5f997b3925962ae0f032229226b858c294763328c89006f8d1b50c61fb00') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp120-prepare.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp120 not verified' }
if (-not (Select-String -LiteralPath "$p\pins\tp120-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp120\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp120" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot119a/quick119a/g2/frontend/l2trans.exe" "$P2/cold-boot119a/quick119a/g2/runtime" tool120 "$P2/cold-tp120/tests/smoke-kernel225.tsv" *> "$p\pins\tp120-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp120\tool120\lmxtool-tool.exe", "$p\cold-tp120\tool120\lmxtool.lm1", "$p\cold-tp120\tool120\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL120 exit=' + $e)
exit $e
