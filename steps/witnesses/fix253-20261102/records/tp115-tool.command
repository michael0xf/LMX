try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 (fable_pc, semantic step A): the tool of candidate tp115 -- tools/build.lm2 with the LmxCodeLink record, the five
# LmxRange side fields, the seven lmx_range and five lmx_arena_refs exports and the program-text scan of the new store
# spelling -- built by the maintained `rebuild tool` from the stage cold-tp115's tool sources with boot114's G2 frontend
# (17DFEEA9, the landed source-tp114's self-built frontend) and boot114's G2 runtime objects; the recipe then runs the
# kernel smoke list with that frontend and runtime through the new tool. Host tool: boot114's promoted working tool
# (6619A503). Nothing of this is a runtime yet: the new tool's recipe is what writes the tp115 kernel headers in the
# first runtime build (tp115-runtime) and the bootstrap (boot115).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$fe="$p\cold-boot114\quick114\g2\frontend\l2trans.exe"
$rt="$p\cold-boot114\quick114\g2\runtime"
$term="$p\pins\tp115-tool.terminal.txt"
$run="$p\tp115-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp115\tool115") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if ((ShaTp $fe) -ne '17dfeea955facd7615002e45cf40995811d780739da300b04f7afa74dce72990') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '40b84ecf2bf786e13b469571a25791c0d7e1395f6947a0bc6364655867af0da2' -or (ShaTp "$rt\driver-observe.o") -ne '16a0c54af7fde4d3f6a3c83c85ce020a1bed430f0a2a8729399475cd18a70112') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-prepare-fix01.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage fix01 not verified' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp115" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot114/quick114/g2/frontend/l2trans.exe" "$P2/cold-boot114/quick114/g2/runtime" tool115 "$P2/cold-tp115/tests/smoke-kernel225.tsv" *> "$p\pins\tp115-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp115\tool115\lmxtool-tool.exe", "$p\cold-tp115\tool115\lmxtool.lm1", "$p\cold-tp115\tool115\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL115 exit=' + $e)
exit $e
