try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 284. land284 uses the verified boot146a working tool.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot146a\quick146a\lmxtool.exe"
$term="$p\pins\land284.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'BA82E4988EA88B8BDA09A018818467B8F691B20F8CC1B9FAF9D5A5148E4B4F13') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp146.sha256").Hash -ne '2A1D385A7F06AAEDDAD60305F356698EEBDF62BA48A6E095BC36C237C095BA1A') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot146a.sha256").Hash -ne '2A1D385A7F06AAEDDAD60305F356698EEBDF62BA48A6E095BC36C237C095BA1A') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot146a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot146a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot146a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot146a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp146\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 214) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land284-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot146a\quick146a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land284-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land284-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land284-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp146.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land284-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp146: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp146.sha256", "$P2/cold-boot146a")
  ,@('stage-copy', "$P2/pins/source-tp146.sha256", "$P2/cold-boot146a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land284-inputs-list.list", "$P2/variants/tp146", "$P2/pins/land284-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land284-inputs-list.sha256", "$P2/variants/tp146", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land284-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land284-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land284-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land284-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq '2A1D385A7F06AAEDDAD60305F356698EEBDF62BA48A6E095BC36C237C095BA1A')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp146.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp146.sha256' }
Write-Output ('LAND284 ' + $i + ' steps')
