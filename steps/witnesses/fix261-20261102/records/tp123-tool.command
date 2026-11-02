try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp123 (fable_pc, slice 261): the tool of candidate tp123 -- tools/build.lm2 with the kernel type code LMX_TYPE_CELL_POINTER
# (the kernel's own pointer code for the address of a cell no pointer code of the table expresses), the walker op
# LMX_WALK_OP_RECEIVE (63; OP_COUNT 64) and the lmx_walk_values export lmx_walk_value_receive_pointer (147 -> 148 names: the one
# receive of a runtime-typed reference by a pointer place by the actual pointees, which the native code calls and the walker's
# RECEIVE frame calls) -- built by the maintained `rebuild tool` from the stage cold-tp123's tool sources with boot122a's G2
# frontend (7795D04D) and boot122a's G2 runtime objects, exactly as tool123 was (tp123-tool); the recipe then runs the kernel
# smoke list with that frontend and runtime through the new tool.  Host tool: boot122a's promoted working tool (1B9F2BA5).  This
# tool, tool123, is the tool of the isolated builds and the G0 of boot123: its recipe writes the tp123 kernel declaration headers
# and passes the export lists in G1's builds.  Parameter: TP_TRY (01, 02, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot122a\quick122a\lmxtool.exe"
$fe="$p\cold-boot122a\quick122a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot122a\quick122a\g2\runtime"
$term="$p\pins\tp123-tool-$try.terminal.txt"
$run="$p\tp123-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp123\tool123") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1b9f2ba5751771e2fcb53f3db60b0e06b24e1abf1607a449796739d55fa522f6') { throw 'tool hash' }
if ((ShaTp $fe) -ne '7795d04dd1807f45dde3fec7fef92d670099169372e4beb7b72866d6c419e784') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '3cd1c22e5e51c2121e498a8deba3e89e69c210cf6d05f297d5a827b3c5410ef1' -or (ShaTp "$rt\driver-observe.o") -ne '999163a255fe20335953ee60e3006bde89560a35d92f841768e9c5c3d6499b9f') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp123-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp123\tools\build.lm2") + ' source-tp123 ' + (ShaTp "$p\pins\source-tp123.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp123" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot122a/quick122a/g2/frontend/l2trans.exe" "$P2/cold-boot122a/quick122a/g2/runtime" tool123 "$P2/cold-tp123/tests/smoke-kernel225.tsv" *> "$p\pins\tp123-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp123\tool123\lmxtool-tool.exe", "$p\cold-tp123\tool123\lmxtool.lm1", "$p\cold-tp123\tool123\lmxtool.c", "$p\cold-tp123\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL123 exit=' + $e)
exit $e
