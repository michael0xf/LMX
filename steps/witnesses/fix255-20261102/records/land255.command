try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot117a-tested source package into the tracked selfbuild/ (the rule of Codex's answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate: the whole source-tp117, after the actual
# successful boot117a). The exact 161 inputs bound by source-tp117.sha256 (FC9659DF...) are verified in cold-boot117a (whose
# source-boot117a.sha256 is the same bytes) and stage-copied over selfbuild/ (same path list); the variant's inputs.list
# (161 lines: the new fixture tests/dyn/free_value_types.lm2) is copied into selfbuild/ by a one-line manifest first; the
# package manifest is rewritten by the ordinary manifest command and verified, and the 65 sources that G1 and G2 retained in
# their consumed-input snapshots are verified against the landed files. Tool: the promoted working tool of boot117a (G2's,
# 4E1D96D4), fresh private CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot117a\quick117a\lmxtool.exe"
$term="$p\pins\land255.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '4E1D96D4C939CEAA2721ABD1413EFAA93FEB4CC5BB7E318EEAFF87BB3AF5AA68') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp117.sha256").Hash -ne 'FC9659DF3F4E572FE13FDC3D23488FCFA9EBD41F423A39850B78157CA52D001B') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot117a.sha256").Hash -ne 'FC9659DF3F4E572FE13FDC3D23488FCFA9EBD41F423A39850B78157CA52D001B') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot117a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot117a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot117a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot117a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp117\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 161) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land255-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot117a\quick117a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land255-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land255-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land255-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp117.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land255-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp117: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp117.sha256", "$P2/cold-boot117a")
  ,@('stage-copy', "$P2/pins/source-tp117.sha256", "$P2/cold-boot117a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land255-inputs-list.list", "$P2/variants/tp117", "$P2/pins/land255-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land255-inputs-list.sha256", "$P2/variants/tp117", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land255-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land255-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land255-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land255-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'FC9659DF3F4E572FE13FDC3D23488FCFA9EBD41F423A39850B78157CA52D001B')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp117.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp117.sha256' }
Write-Output ('LAND255 ' + $i + ' steps')
