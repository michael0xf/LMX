try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp114 (fable_pc, S3c): the tool of candidate tp114 -- tools/build.lm2 with the 28 generation and index cells of tp114 over tp113's 57 in its
# generated l2_frontend_state.lm1 -- built by the maintained `rebuild tool` from the stage cold-tp114's tool sources, with
# boot112's G2 frontend (6a66b24e, the tested seed of the landed package; Codex, read-only monitoring 2026-11-02: the
# previous tool builds used full100's slow G1 frontend) and boot112's G2 runtime objects; the recipe then runs the smoke
# list with that frontend and runtime through the new tool. Host tool: boot112's promoted working tool (0E3ACE61). Nothing of this is a frontend
# yet: the new tool is what writes the state file of the following frontend-part build (tp114-frontend-part.command).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot112\quick112\lmxtool.exe"
$fe="$p\cold-boot112\quick112\g2\frontend\l2trans.exe"
$rt="$p\cold-boot112\quick112\g2\runtime"
$term="$p\pins\tp114-tool.terminal.txt"
$run="$p\tp114-tool-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp114\tool114") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '0e3ace61ef4dd9ded30cb86b5fe74c843235eea70766b5db48c9eeec24636182') { throw 'tool hash' }
if ((ShaTp $fe) -ne '6a66b24e3031b5b3c1b0023685cba6a0b4f740cffae7db462febb54dccb34396') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '40b84ecf2bf786e13b469571a25791c0d7e1395f6947a0bc6364655867af0da2' -or (ShaTp "$rt\driver-observe.o") -ne '16a0c54af7fde4d3f6a3c83c85ce020a1bed430f0a2a8729399475cd18a70112') { throw 'runtime objects hash' }
if (-not (Test-Path -LiteralPath "$rt\driver.o") -or -not (Test-Path -LiteralPath "$rt\driver-observe.o")) { throw 'runtime objects' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-prepare.terminal.txt" -Pattern ' 10 exit=0 ' -Quiet)) { throw 'stage not prepared' }
$free=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if ($free -lt 5600000) { throw ('insufficient free virtual memory for a tool compile: ' + $free + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp114" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot112/quick112/g2/frontend/l2trans.exe" "$P2/cold-boot112/quick112/g2/runtime" tool114 "$P2/cold-tp114/tests/smoke-kernel225.tsv" *> "$p\pins\tp114-tool.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp114\tool114\lmxtool-tool.exe", "$p\cold-tp114\tool114\lmxtool.lm1", "$p\cold-tp114\tool114\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL114 exit=' + $e)
exit $e
