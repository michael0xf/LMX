try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp117 (fable_pc): the tool of candidate tp117 -- tools/build.lm2 with the lmx_walk_values exports lmx_walk_value_lit,
# lmx_walk_value_receive and lmx_walk_value_bin (141 -> 144 names) and the l2_frontend_helpers exports lm_compiler_free_own,
# lm_compiler_free_dt, lm_compiler_own_is_free and lm_compiler_ft_is_free (257 -> 261 names) -- built by the maintained
# `rebuild tool` from the stage cold-tp117's tool sources with boot116c's G2 frontend (25EDB0D0) and boot116c's G2 runtime
# objects, exactly as tool116 was (tp116-tool); the recipe then runs the kernel smoke list with that frontend and runtime
# through the new tool.  Host tool: boot116c's promoted working tool (18C898AC).  This tool, tool117, is G0 of boot117: its
# recipe writes the tp117 kernel declaration headers and passes the export lists in G1's builds.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot116c\quick116c\lmxtool.exe"
$fe="$p\cold-boot116c\quick116c\g2\frontend\l2trans.exe"
$rt="$p\cold-boot116c\quick116c\g2\runtime"
$term="$p\pins\tp117-tool.terminal.txt"
$run="$p\tp117-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp117\tool117") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '18c898ac3d86869e781a6dfee8bfff20c9892df572d9443d23bba280cc212ba3') { throw 'tool hash' }
if ((ShaTp $fe) -ne '25edb0d0f95b067df77ea78c8460648adb98d8169869eb00d5d10735b5918c9f') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'bcc59c4c603efaabb3d1de939fae078463b424dcb94c0b7f058a996649d37e54' -or (ShaTp "$rt\driver-observe.o") -ne 'aa418b42d36eda98e61343c55d76a82bb1de4ce8786a6b00c9534e9f87b96658') { throw 'runtime objects hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp117-prepare.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp117 not verified' }
if (-not (Select-String -LiteralPath "$p\pins\tp117-reuse.terminal.txt" -Pattern ' 05 exit=0 verify ' -Quiet)) { throw 'reuse set not staged' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' build.lm2 ' + (ShaTp "$p\cold-tp117\tools\build.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp117" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot116c/quick116c/g2/frontend/l2trans.exe" "$P2/cold-boot116c/quick116c/g2/runtime" tool117 "$P2/cold-tp117/tests/smoke-kernel225.tsv" *> "$p\pins\tp117-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp117\tool117\lmxtool-tool.exe", "$p\cold-tp117\tool117\lmxtool.lm1", "$p\cold-tp117\tool117\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL117 exit=' + $e)
exit $e
