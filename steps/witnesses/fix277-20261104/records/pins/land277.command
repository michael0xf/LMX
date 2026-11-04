try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 277. land277 uses the verified boot139a working tool.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot139a\quick139a\lmxtool.exe"
$term="$p\pins\land277.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'FE4B36561D357AB234936863CA3DE990E29A0FDC65744CA20DA9B98CED6F77DF') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp139.sha256").Hash -ne 'A82F39AC50798A66D8614DA34F849ADD46406861F62ECA8CD0D8290EC7CECBD1') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot139a.sha256").Hash -ne 'A82F39AC50798A66D8614DA34F849ADD46406861F62ECA8CD0D8290EC7CECBD1') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot139a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot139a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot139a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot139a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp139\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 200) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land277-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot139a\quick139a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land277-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land277-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land277-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp139.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land277-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp139: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp139.sha256", "$P2/cold-boot139a")
  ,@('stage-copy', "$P2/pins/source-tp139.sha256", "$P2/cold-boot139a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land277-inputs-list.list", "$P2/variants/tp139", "$P2/pins/land277-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land277-inputs-list.sha256", "$P2/variants/tp139", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land277-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land277-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land277-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land277-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'A82F39AC50798A66D8614DA34F849ADD46406861F62ECA8CD0D8290EC7CECBD1')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp139.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp139.sha256' }
Write-Output ('LAND277 ' + $i + ' steps')
