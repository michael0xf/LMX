try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 307 (CALL-WHOLE-ARGUMENTS-STRUCTURE). `rebuild tool` of the stage cold-tp140 (its tools/build.lm2: the record field
# L2ApplicationActuals.whole, the walker op LMX_WALK_OP_WHOLE (OP_COUNT 66), the exports lmx_call_bind_whole, lmx_implements_view_name and
# lmx_callable_named_formal) with the published boot169a tuple (the bootstrap of slice 306). Parameters TP_LABEL (output directory under the
# stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot169a\quick169a\lmxtool.exe"
$fe="$p\cold-boot169a\quick169a\g2\frontend\l2trans.exe"
$rt="$p\cold-boot169a\quick169a\g2\runtime"
$term="$p\pins\tp170-tool-$try.terminal.txt"
$run="$p\tp170-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3158d8dcfee9a35d5bc4747b98a6fdefbdf959ccda45c405ea38da569f9f253e') { throw 'tool hash' }
if ((ShaTp $fe) -ne '9e20bcb598afaaa433ecb8a89c76c35eac2452b446d6b2b55f56e71832e8e62b') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne '78b6e2b01cb6a957d0017cabd6e68e28e76c53b37c8c5eff831b561665a7da50' -or (ShaTp "$rt\driver-observe.o") -ne '63e2746fd6ab8090b11b8bbf57c214779ea9eab5429cc88ead5b697a60b73d86') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp170-' + $try + ' ' + (ShaTp "$p\pins\source-tp170-$try.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot169a/quick169a/g2/frontend/l2trans.exe" "$P2/cold-boot169a/quick169a/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp170-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL170 ' + $label + ' exit=' + $e)
exit 0
