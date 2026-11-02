try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp121 (fable_pc, slice 259): the tool of candidate tp121 -- tools/build.lm2 with the walker's five machine op codes
# (LMX_WALK_OP_BAND 58, BOR 59, BXOR 60, SHL 61, SHR 62; LMX_WALK_OP_COUNT 63) in the generated kernel declaration header
# lmx_walk.h.lm1 -- built by the maintained `rebuild tool` from the stage cold-tp121's tool sources with boot120a's G2 frontend
# (F616D36F) and boot120a's G2 runtime objects, exactly as tool120 was (tp120-tool); the recipe then runs the kernel smoke list
# with that frontend and runtime through the new tool.  Host tool: boot120a's promoted working tool (51F4F022).  This tool,
# tool121, is the tool of the isolated builds and the G0 of boot121: its recipe writes the tp121 kernel declaration headers and
# passes the export lists in G1's builds.  Parameter: TP_TRY (01, 02, ... -- the terminal's suffix; the output tool121 must be
# absent, so a repeat first moves the previous tool121 aside by hand under a recorded name).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot120a\quick120a\lmxtool.exe"
$fe="$p\cold-boot120a\quick120a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot120a\quick120a\g2\runtime"
$term="$p\pins\tp121-tool-$try.terminal.txt"
$run="$p\tp121-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp121\tool121") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '51f4f0225cb7964168ada529a3660b0e6471479983f341a98dab3b83a04c0622') { throw 'tool hash' }
if ((ShaTp $fe) -ne 'f616d36f78bd602e1ce6a17bc255c912fce229aa8f66c66c284d2ad9df05a594') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '989cd46f3917218c51c05e8cbe7de19d88df3750c0149a3a3cb9189e74602842' -or (ShaTp "$rt\driver-observe.o") -ne '711dd60069761bd0f406e2e89d65233bcb0f10dd85b17e8cf60d9e099a93011b') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp121-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp121\tools\build.lm2") + ' source-tp121 ' + (ShaTp "$p\pins\source-tp121.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp121" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot120a/quick120a/g2/frontend/l2trans.exe" "$P2/cold-boot120a/quick120a/g2/runtime" tool121 "$P2/cold-tp121/tests/smoke-kernel225.tsv" *> "$p\pins\tp121-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp121\tool121\lmxtool-tool.exe", "$p\cold-tp121\tool121\lmxtool.lm1", "$p\cold-tp121\tool121\lmxtool.c", "$p\cold-tp121\src\l2src\lmx_walk.h.lm1")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL121 exit=' + $e)
exit $e
