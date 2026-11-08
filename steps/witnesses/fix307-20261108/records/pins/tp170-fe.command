try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 307 (CALL-WHOLE-ARGUMENTS-STRUCTURE). The whole frontend of the stage cold-tp140 (the binder marking one Structure actual as a
# whole candidate, CHECK deciding on its static shape -- lm_compiler_whole_decide --, the native and walked emission of the whole call)
# translated by the published boot169a G2 frontend with the stage's tool (tool170a of a01, tool170b of a09, tool170c of a12, tool170d of a13, tool170e of a23; tools/build.lm2 changed by this slice). Parameters TP_LABEL
# (the output directory under the stage), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-tp140\tool170e\lmxtool-tool.exe"
$fe="$p\cold-boot169a\quick169a\g2\frontend\l2trans.exe"
$term="$p\pins\tp170-fe-$try.terminal.txt"
$run="$p\tp170-fe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '91da2e20b1a93e3e943918ffed5a9ab78882b995f49f8c4c728abe23114b5013') { throw 'tool hash' }
if ((ShaTp $fe) -ne '9e20bcb598afaaa433ecb8a89c76c35eac2452b446d6b2b55f56e71832e8e62b') { throw 'frontend hash' }
$os=Get-CimInstance Win32_OperatingSystem
if ($os.FreeVirtualMemory -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $os.FreeVirtualMemory + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' label ' + $label + ' fe ' + (ShaTp $fe) + ' lower.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_lower.lm2") + ' emit.lm2 ' + (ShaTp "$p\cold-tp140\src\l2src\l2_frontend_emit.lm2") + ' PreVMKiB ' + $os.FreeVirtualMemory + ' PrePhysKiB ' + $os.FreePhysicalMemory) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- build-frontend $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot169a/quick169a/g2/frontend/l2trans.exe" $label *> "$p\pins\tp170-fe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' FrontendExit ' + $e) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l2trans.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l1trans.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/l2_libc.o"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
Write-Output ('FE170 ' + $label + ' exit=' + $e)
exit 0
