try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 279. land279 uses the verified boot141a working tool.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot141a\quick141a\lmxtool.exe"
$term="$p\pins\land279.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'F67E809B29CE15997E4CFF532688530BBFC85BC84A7BA7118F8EB30EAF2D4324') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp141.sha256").Hash -ne 'F1CDB8230F094AF59DC0153CA03117E7A5CC2307FB346F9AFD03AB92CFAF404F') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot141a.sha256").Hash -ne 'F1CDB8230F094AF59DC0153CA03117E7A5CC2307FB346F9AFD03AB92CFAF404F') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot141a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot141a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot141a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot141a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp141\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 203) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land279-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot141a\quick141a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land279-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land279-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land279-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp141.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land279-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp141: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp141.sha256", "$P2/cold-boot141a")
  ,@('stage-copy', "$P2/pins/source-tp141.sha256", "$P2/cold-boot141a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land279-inputs-list.list", "$P2/variants/tp141", "$P2/pins/land279-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land279-inputs-list.sha256", "$P2/variants/tp141", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land279-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land279-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land279-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land279-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'F1CDB8230F094AF59DC0153CA03117E7A5CC2307FB346F9AFD03AB92CFAF404F')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp141.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp141.sha256' }
Write-Output ('LAND279 ' + $i + ' steps')
