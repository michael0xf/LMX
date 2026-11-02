try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp122 (fable_pc, slice 260): the tool of candidate tp122 -- tools/build.lm2 with the lmx_walk_values export
# lmx_walk_value_receive_graph (146 -> 147 names: the one receive of a graph place by the actual pointee, which the native code
# calls for a runtime-typed value at a modelled place and the walker's ADMIT_AS calls before the admission) -- built by the
# maintained `rebuild tool` from the stage cold-tp122's tool sources with boot121a's G2 frontend (2537E3B3) and boot121a's G2
# runtime objects, exactly as tool122 was (tp122-tool); the recipe then runs the kernel smoke list with that frontend and runtime
# through the new tool.  Host tool: boot121a's promoted working tool (4DD5D706).  This tool, tool122, is the tool of the isolated
# builds after fix03 and the G0 of boot122: its recipe writes the tp122 kernel declaration headers and passes the export lists in
# G1's builds.  Parameter: TP_TRY (01, 02, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot121a\quick121a\lmxtool.exe"
$fe="$p\cold-boot121a\quick121a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot121a\quick121a\g2\runtime"
$term="$p\pins\tp122-tool-$try.terminal.txt"
$run="$p\tp122-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp122\tool122") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4dd5d70602596afcec73902eb83a8a986ffcd13b85f59f2e693ae44920138485') { throw 'tool hash' }
if ((ShaTp $fe) -ne '2537e3b3213e6a8d4fc169f19471bd796a73b27071d76d31a93fc28060b74dc6') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '5518fad8f244cb4d6e6d3959d0a3085980aa353c67d9a89eb4ac2ee28d8e607f' -or (ShaTp "$rt\driver-observe.o") -ne '42ead9436346cec6f482517e07d09fe7fd50a6aba24fcb60d1f472e172849311') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp122-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp122\tools\build.lm2") + ' source-tp122 ' + (ShaTp "$p\pins\source-tp122.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp122" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot121a/quick121a/g2/frontend/l2trans.exe" "$P2/cold-boot121a/quick121a/g2/runtime" tool122 "$P2/cold-tp122/tests/smoke-kernel225.tsv" *> "$p\pins\tp122-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp122\tool122\lmxtool-tool.exe", "$p\cold-tp122\tool122\lmxtool.lm1", "$p\cold-tp122\tool122\lmxtool.c", "$p\cold-tp122\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL122 exit=' + $e)
exit $e
