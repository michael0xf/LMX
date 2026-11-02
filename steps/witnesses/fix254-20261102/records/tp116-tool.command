try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp116 (fable_pc): the tool of candidate tp116 -- tools/build.lm2 with the LmxActivationBinding/LmxActivation records, the
# LmxArena `activation` anchor, LMX_WALK_VALUE_FREE, the lmx_call exports lmx_activation_push/pop/bind (18 names) and the
# lmx_walk_values exports lmx_activation_resolve/resolve_input and lmx_walk_value_free_mark (141 names) -- built by the
# maintained `rebuild tool` from the stage cold-tp116's tool sources with boot115f's G2 frontend (EBCADAE2) and boot115f's
# G2 runtime objects, exactly as tool116 was (tp116-tool); the recipe then runs the kernel smoke list with that
# frontend and runtime through the new tool.  Host tool: boot115f's promoted working tool (8C5D66EA).  This tool, tool116,
# is G0 of boot116: its recipe writes the tp116 kernel declaration headers in G1's runtime build.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$fe="$p\cold-boot115f\quick115f\g2\frontend\l2trans.exe"
$rt="$p\cold-boot115f\quick115f\g2\runtime"
$term="$p\pins\tp116-tool.terminal.txt"
$run="$p\tp116-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp116\tool116") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '8c5d66ea0852864134b0dd98967f1ab1ab5fa17069d04cc82843fb913ae7cc44') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'ebcadae22999740d01235b8776379362db05baea5772c95dada7f4448db243a8') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'd87bac18cfa2d4739d2c1d0f0bb14615693148a3471a42fac7bf7d3253cabe15' -or (ShaTp "$rt\driver-observe.o") -ne '807aae8623fe9a8ca3e4422c7f3450b40c00a1bbd929154b5b669a423b3ae596') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-prepare.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp116 not verified' }
if (-not (Select-String -LiteralPath "$p\pins\tp116-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp116" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot115f/quick115f/g2/frontend/l2trans.exe" "$P2/cold-boot115f/quick115f/g2/runtime" tool116 "$P2/cold-tp116/tests/smoke-kernel225.tsv" *> "$p\pins\tp116-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp116\tool116\lmxtool-tool.exe", "$p\cold-tp116\tool116\lmxtool.lm1", "$p\cold-tp116\tool116\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL116 exit=' + $e)
exit $e
