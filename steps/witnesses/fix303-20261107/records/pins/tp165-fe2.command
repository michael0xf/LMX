try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, the := slice (after 302). The whole frontend of the stage cold-tp140 (P0 with the token := as a Frame flagged
# LM_P0_FRAME_ASSIGN; the binder naming a formal by that Frame only; := as the write of a known place) translated by the
# boot164a G2 frontend with the stage's tool tool165b (its build.lm2 writes the P0 header with the flag and exports the helper).
# Parameters TP_LABEL (the output directory under the stage), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-tp140\tool165b\lmxtool-tool.exe"
$fe="$p\cold-boot164a\quick164a\g2\frontend\l2trans.exe"
$term="$p\pins\tp165-fe-$try.terminal.txt"
$run="$p\tp165-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '850707ed202034e22b9b9e316a2ec4c4767f17b0061f051c118f723f7348d917') { throw 'tool hash' }
if ((ShaTp $fe) -ne '0213ad799179b30f95d52a785bc7159cf1b13d7e90ce77231ab23f5b81018ab6') { throw 'frontend hash' }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' values.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\p0_parser.lm2") + ' core.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_core.lm2") + ' emit.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_emit.lm2") + ' lower.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_lower.lm2") + ' PreVMKiB ' + $os.FreeVirtualMemory + ' PrePhysKiB ' + $os.FreePhysicalMemory) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot164a/quick164a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp165-fe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l2trans.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l1trans.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l2_libc.o"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
Write-Output ('FE165 ' + $label + ' exit=' + $e)
exit 0
