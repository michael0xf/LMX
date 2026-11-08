try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 308 (CALL-WHOLE-ARGUMENTS-STRUCTURE). `rebuild tool` of the stage cold-tp140 (its tools/build.lm2: the record field
# L2ApplicationActuals.whole, the walker op LMX_WALK_OP_WHOLE (OP_COUNT 66), the exports lmx_call_bind_whole, lmx_implements_view_name and
# lmx_callable_named_formal) with the published boot169a tuple (the bootstrap of slice 306). Parameters TP_LABEL (output directory under the
# stage) and TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $label -or -not $try) { throw 'parameters TP_LABEL TP_TRY' }
$tool="$p\cold-boot170b\quick170b\lmxtool.exe"
$fe="$p\cold-boot170b\quick170b\g2\frontend\l2trans.exe"
$rt="$p\cold-boot170b\quick170b\g2\runtime"
$term="$p\pins\tp171-tool-$try.terminal.txt"
$run="$p\tp171-tool-$try-run-01"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $run) { throw 'CWDexists' }
if (Test-Path -LiteralPath "$p\cold-tp140\$label") { throw 'outputexists' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '41fe7cbe3cb41c9f17eaa25431b59930832e037781f59d32bb35269e10790a8d') { throw 'tool hash' }
if ((ShaTp $fe) -ne '69e8c17dd46383d15e053cdcc1aa4a6fe4ab3e859af00c699e43c53507d24ea7') { throw 'frontend hash' }
if ((ShaTp "$rt\driver.o") -ne 'b6a65587ea1e5b6092178e7a03de164af4c2089c81862ed955e5919f13f748d6' -or (ShaTp "$rt\driver-observe.o") -ne '565b0a168fad2af9014e57cda91c572cbec292c411c1aaeba83863f1276b9935') { throw 'runtime objects hash' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
$phys=$os.FreePhysicalMemory
if ($free -lt 5600000 -or $phys -lt 4194304) { throw ('insufficient free memory for a tool compile: virtual ' + $free + ' KiB, physical ' + $phys + ' KiB') }
New-Item -ItemType Directory -Path $run | Out-Null
Set-Location -LiteralPath $run
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $phys + ' build.lm2 ' + (ShaTp "$p\cold-tp140\tools\build.lm2") + ' source-tp171-' + $try + ' ' + (ShaTp "$p\pins\source-tp171-$try.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '7200' $tool 0 entry 0 -- rebuild tool $R "$P2/cold-tp140" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot170b/quick170b/g2/frontend/l2trans.exe" "$P2/cold-boot170b/quick170b/g2/runtime" $label "$P2/cold-tp140/tests/smoke-kernel225.tsv" *> "$p\pins\tp171-tool-$try.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' RebuildExit ' + $e) -Encoding utf8
foreach ($f in @("$p\cold-tp140\$label\lmxtool-tool.exe", "$p\cold-tp140\$label\lmxtool.lm1", "$p\cold-tp140\$label\lmxtool.c")) {
  if (Test-Path -LiteralPath $f) { Add-Content -LiteralPath $term -Value ('out ' + (ShaTp $f) + ' ' + $f + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 } else { Add-Content -LiteralPath $term -Value ('out MISSING ' + $f) -Encoding utf8 }
}
Write-Output ('TOOL171 ' + $label + ' exit=' + $e)
exit 0
