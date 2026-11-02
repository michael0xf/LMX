try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot123a-tested source package into the tracked selfbuild/ (the rule of Codex's answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate: the whole source-tp123, after the actual
# successful boot123a). The exact 167 inputs bound by source-tp123.sha256 (CB155E7E...) are verified in cold-boot123a (whose
# source-boot123a.sha256 is the same bytes) and stage-copied over selfbuild/ (same path list); the variant's inputs.list
# (167 lines: the new fixture tests/dyn/free_graph_address.lm2) is copied into selfbuild/ by a one-line manifest first; the
# package manifest is rewritten by the ordinary manifest command and verified, and the 65 sources that G1 and G2 retained in
# their consumed-input snapshots are verified against the landed files. Tool: the promoted working tool of boot123a (G2's,
# 1F12CDC1), fresh private CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot123a\quick123a\lmxtool.exe"
$term="$p\pins\land261.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '1F12CDC16A5CE43200ABCF0B4E4BC43BC60B1232A6EF3CFEB7C135BE4D89D9DB') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp123.sha256").Hash -ne 'CB155E7E4E4D557B83A92164AA2066B32B68570307E2F6D0EA961632CBDD58B5') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot123a.sha256").Hash -ne 'CB155E7E4E4D557B83A92164AA2066B32B68570307E2F6D0EA961632CBDD58B5') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot123a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot123a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot123a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot123a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp123\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 167) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land261-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot123a\quick123a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land261-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land261-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land261-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp123.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land261-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp123: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp123.sha256", "$P2/cold-boot123a")
  ,@('stage-copy', "$P2/pins/source-tp123.sha256", "$P2/cold-boot123a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land261-inputs-list.list", "$P2/variants/tp123", "$P2/pins/land261-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land261-inputs-list.sha256", "$P2/variants/tp123", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land261-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land261-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land261-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land261-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'CB155E7E4E4D557B83A92164AA2066B32B68570307E2F6D0EA961632CBDD58B5')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp123.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp123.sha256' }
Write-Output ('LAND261 ' + $i + ' steps')
