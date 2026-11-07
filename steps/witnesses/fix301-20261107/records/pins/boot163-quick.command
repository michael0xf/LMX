try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 301. Whole bootstrap quick of the checked source of the stage cold-boot163<TP_TRY>: G0 = the working boot162a
# tool, previous frontend = G2 of boot162a. The stage is verified again by lmxtool against its source manifest before the run.
# The guards below only refuse a changed input or a live pipeline; the bootstrap is one command of the tool. Parameter TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$stage="cold-boot163$try"
$label="quick163$try"
$tool="$p\cold-boot162a\quick162a\lmxtool.exe"
$term="$p\pins\boot163$try-quick.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'c6deabf9f79476dd807a1ad9629edb5ff8691899136d2f54108a4bd4c815a6ee') { throw 'changed bootstrap input: G0 tool' }
if ((ShaTp "$p\cold-boot162a\quick162a\g2\frontend\l2trans.exe") -ne '089896a82695201927a3a3530d5a22c9a38f47f8176681e704047a60006eff4d') { throw 'changed bootstrap input: previous l2trans' }
if ((ShaTp "$p\cold-boot162a\quick162a\g2\frontend\l1trans.exe") -ne 'f6e31a5e67444c7ee42c41f0e8d18bc3c69f21f91a99b709619edc92153a748c') { throw 'changed bootstrap input: previous l1trans' }
if ((ShaTp "$p\cold-boot162a\quick162a\g2\frontend\l2_libc.o") -ne 'af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37') { throw 'changed bootstrap input: previous l2_libc.o' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l2trans.exe") -ne 'e9873ebe8eff797200a6eb75b5211d88e1b708f742b19bce19608a7e63b3c246') { throw 'changed bootstrap input: base l2trans' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l1trans.exe") -ne '519a37a453b372427b70ca599f3dfb16f76fa552f2069ad4795bbf53a3d70aec') { throw 'changed bootstrap input: base l1trans' }
if ((ShaTp "$p\cold-candidate48\full48\g2\frontend\l2_libc.o") -ne 'af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37') { throw 'changed bootstrap input: base l2_libc.o' }
if ((ShaTp 'C:\Qt\Tools\mingw1310_64\bin\gcc.exe') -ne '920a4fc669e98ad444151afa558bbc71d1c4773ab136ee4c44374093a90c5ed1') { throw 'changed bootstrap input: gcc' }
if ((ShaTp 'C:\Git\usr\bin\timeout.exe') -ne '4b83b85f7b2afc718334f6669faced88b47a11c492e4325a97fb519beab401e4') { throw 'changed bootstrap input: timeout' }
if ((Test-Path -LiteralPath "$p\$stage\headers","$p\$stage\src\l2src\lmx.h.lm1","$p\$stage\src\l1src\libc_abi.lm1","$p\$stage\$label","$p\pins\boot163$try-quick.log") -contains $true) { throw 'an output or generated input exists' }
$os=Get-CimInstance Win32_OperatingSystem
$free=$os.FreeVirtualMemory
if ($free -lt 4194304 -or $os.FreePhysicalMemory -lt 4194304) { throw ('insufficient free memory: virtual ' + $free + ' KiB, physical ' + $os.FreePhysicalMemory + ' KiB') }
$cwd="$p\boot163$try-quick-run-01"
if (Test-Path -LiteralPath $cwd) { throw 'CWDexists' }
New-Item -ItemType Directory -Path $cwd | Out-Null
Set-Location -LiteralPath $cwd
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
& $tool 0 entry 0 -- verify "$P2/pins/source-boot163$try.sha256" "$P2/$stage" *> "$p\pins\boot163$try-quick-verify.log"
if ($LASTEXITCODE -ne 0) { throw 'stage not verified' }
Add-Content -LiteralPath $term -Value ('StartUTC ' + [DateTime]::UtcNow.ToString('o') + ' PreVMKiB ' + $free + ' PrePhysKiB ' + $os.FreePhysicalMemory + ' source-boot163' + $try + ' ' + (ShaTp "$p\pins\source-boot163$try.sha256")) -Encoding utf8
& 'C:\Git\usr\bin\timeout.exe' '172800' $tool 0 entry 0 -- bootstrap quick $repo "$P2/$stage" "$P2/cold-candidate48/full48/g2/frontend" "$P2/cold-boot162a/quick162a/g2/frontend/l2trans.exe" $label "$P2/$stage/tests/smoke-kernel225.tsv" *> "$p\pins\boot163$try-quick.log"
$e=$LASTEXITCODE
Add-Content -LiteralPath $term -Value ('EndUTC ' + [DateTime]::UtcNow.ToString('o') + ' BootstrapExit ' + $e) -Encoding utf8
Write-Output ('BOOT163' + $try + ' exit=' + $e)
exit $e
