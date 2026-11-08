try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 305 (CALL-ARGUMENT-ORDER-AXBY). `rebuild tool` of the stage cold-tp140 (its tools/build.lm2 exports the three phases of
# the kernel binder: lmx_call_bind_form, lmx_call_bind_receive, lmx_call_bind_finish, in place of lmx_call_bind_actuals) with the
# published boot167a tuple (the bootstrap of the 304 review). Parameters TP_LABEL (output directory under the stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot167a\quick167a\lmxtool.exe"
$fe="$p\cold-boot167a\quick167a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot167a\quick167a\g2\runtime"
$term="$p\pins\tp168-tool-$try.terminal.txt"
$run="$p\tp168-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '7e22036377f5f5d9a5b739b4674c2cbbb5637c89e182a44c9b459ca1f8cdb4c7') { throw 'tool hash' }
if ((ShaTp $fe) -ne '27a9b8a834c10c8b28d15978f15c9526ed01f4a19877c3ac8e577205f5167fa4') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'd7e7c4bf4d81dc6caadcfd1562c4b5409afa6054aa862f7983f9ec07392e4097' -or (ShaTp "$rt\driver-observe.o") -ne '857dcb0ccf7d48ee837c6fbd26944abc67a20afccf206ea4012e4210581c6734') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp168-a01 ' + (ShaTp "$p\pins\source-tp168-a01.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot167a/quick167a/g2/frontend/l2trans.exe" "$P2/cold-boot167a/quick167a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp168-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL168 ' + $label + ' exit=' + $e)
exit 0
