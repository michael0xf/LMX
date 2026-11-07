try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# fable_pc, slice 302. Whole bootstrap quick of the checked source of the stage cold-boot164<TP_TRY>: G0 = the stage's tool
# tool164a (tools/build.lm2 is changed by 302, so the working tool of boot163a cannot be G0), previous frontend = G2 of
# boot163a. The stage is verified again by lmxtool against its source manifest before the run.
# The guards below only refuse a changed input or a live pipeline; the bootstrap is one command of the tool. Parameter TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot164$try"
$label="quick164$try"
$tool="$p\cold-tp140\tool164a\lmxtool-tool.exe"
$term="$p\pins\boot164$try-quick.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '059c4603626ffe9c37ce66f7d068206e282463a1857aeb49494b6cde0ec14796') { throw 'changed bootstrap input: G0 tool' }
if ((ShaTp "$p\cold-boot163a\quick163a\g2\frontend\l2trans.exe") -ne '57ad3f2e8a05b4262c6a690c5e7dc4751611d5a486c77801d6c4d8390da69ffb') { throw 'changed bootstrap input: previous l2trans' }
if ((ShaTp "$p\cold-boot163a\quick163a\g2\frontend\l1trans.exe") -ne '85b0c8c4cc29f2d802f99ec6f6dbc52c78afa6668dc642dcf2abaddf3105ac6d') { throw 'changed bootstrap input: previous l1trans' }
if ((ShaTp "$p\cold-boot163a\quick163a\g2\frontend\l2_libc.o") -ne 'af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37') { throw 'changed bootstrap input: previous l2_libc.o' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l2trans.exe") -ne 'e9873ebe8eff797200a6eb75b5211d88e1b708f742b19bce19608a7e63b3c246') { throw 'changed bootstrap input: base l2trans' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l1trans.exe") -ne '519a37a453b372427b70ca599f3dfb16f76fa552f2069ad4795bbf53a3d70aec') { throw 'changed bootstrap input: base l1trans' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l2_libc.o") -ne 'af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37') { throw 'changed bootstrap input: base l2_libc.o' }
if ((ShaTp 'C:\Qt\Tools\mingw1310_64\bin\gcc.exe') -ne '920a4fc669e98ad444151afa558bbc71d1c4773ab136ee4c44374093a90c5ed1') { throw 'changed bootstrap input: gcc' }
if ((ShaTp 'C:\Git\usr\bin\timeout.exe') -ne '4b83b85f7b2afc718334f6669faced88b47a11c492e4325a97fb519beab401e4') { throw 'changed bootstrap input: timeout' }
if ((Test-Path -LiteralPath "$p\$stage\headers","$p\$stage\src\l2src\lmx.h.lm1","$p\$stage\src\l1src\libc_abi.lm1","$p\$stage\$label","$p\pins\boot164$try-quick.log") -contains $true) { throw 'an output or generated input exists' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
if ($free -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $free + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
$cwd="$p\boot164$try-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
& $tool 0 entry 0 -- verify "$P2/pins/source-boot164$try.sha256" "$P2/$stage" *> "$p\pins\boot164$try-quick-verify.log"
if ($LASTEXITCODE -ne 0) { throw 'stage not verified' }
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $os.FreePhysicalMemory + ' source-boot164' + $try + ' ' + (ShaTp "$p\pins\source-boot164$try.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' $tool 0 entry 0 -- bootstrap quick $repo "$P2/$stage" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot163a/quick163a/g2/frontend/l2trans.exe" $label "$P2/$stage/tests/smoke-kernel225.tsv" *> "$p\pins\boot164$try-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT164' + $try + ' exit=' + $e)
exit $e
