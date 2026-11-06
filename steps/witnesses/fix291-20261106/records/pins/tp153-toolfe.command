try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 291. With a CANDIDATE frontend (TP_FE, a path under P) and the boot152a G2 runtime (no kernel source changed):
# `rebuild tool` of the stage cold-tp140 (its tools/lmxtool_methods.lm2 passes every word of a list line, and has echo-words)
# with the kernel smoke list, then `build-child` -- the self-test's child. Run by the working boot152a tool. Parameters TP_FE,
# TP_LABEL (output directory under the stage; the child goes to TP_LABEL-child) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY; $feRel=$env:TP_FE
if (-not $label -or -not $try -or -not $feRel) { throw 'parameters TP_FE TP_LABEL TP_TRY' }
$tool="$p\cold-boot152a\quick152a\lmxtool.exe"
$fe=$p + '\' + ($feRel -replace '/','\')
$rt="$p\cold-boot152a\quick152a\g2\runtime"
$term="$p\pins\tp153-toolfe-$try.terminal.txt"
$run="$p\tp153-toolfe-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if ((Test-Path -LiteralPath "$p\cold-tp140\$label") -or (Test-Path -LiteralPath "$p\cold-tp140\$label-child")) { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '4f1c90094408fe98925cbc07aa446b3f86a911a2c81a4856ebedae43d4d41837') { throw 'tool hash' }
if (-not (Test-Path -LiteralPath $fe)) { throw ('missing frontend: ' + $fe) }
if ((ShaTp "$rt\driver.o") -ne '2cab6a2717653d4e89f87fb977ce61e75bf60b6c406917ddf4cde8c2d4f66b9a' -or (ShaTp "$rt\driver-observe.o") -ne '47f74b3b39de2cd98aa1103d515b511840035df6e90247c776ce9e8b5b2d43cf') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' fe ' + (ShaTp $fe) + ' methods ' + (ShaTp "$p\cold-tp140\tools\lmxtool_methods.lm2")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" ($P2 + '/' + $feRel) "$P2/cold-boot152a/quick152a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp153-toolfe-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label/lmxtool-tool.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '3600' $tool 0 entry 0 -- build-child $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" ($P2 + '/' + $feRel) "$P2/cold-boot152a/quick152a/g2/runtime/driver.o" "$P2/cold-tp140/$label-child" *> "$p\pins\tp153-toolfe-$try-child.log"
$c=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' ChildExit ' + $c) -Encoding utf8
$h=& $tool 0 entry 0 -- sha256 "$P2/cold-tp140/$label-child/lmxchild-prod.exe"
Add-Content -LiteralPath $term -Value ('out exit=' + $LASTEXITCODE + ' ' + $h) -Encoding utf8
Write-Output ('TOOLFE153 ' + $label + ' exit=' + $e + ' child=' + $c)
exit 0
