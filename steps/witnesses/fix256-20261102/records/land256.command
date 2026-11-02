try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot118a-tested source package into the tracked selfbuild/ (the rule of Codex's answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate: the whole source-tp118, after the actual
# successful boot118a). The exact 162 inputs bound by source-tp118.sha256 (1016F41D...) are verified in cold-boot118a (whose
# source-boot118a.sha256 is the same bytes) and stage-copied over selfbuild/ (same path list); the variant's inputs.list
# (162 lines: the new fixture tests/dyn/free_value_consumers.lm2) is copied into selfbuild/ by a one-line manifest first; the
# package manifest is rewritten by the ordinary manifest command and verified, and the 65 sources that G1 and G2 retained in
# their consumed-input snapshots are verified against the landed files. Tool: the promoted working tool of boot118a (G2's,
# 3E5F1A18), fresh private CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot118a\quick118a\lmxtool.exe"
$term="$p\pins\land256.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '3E5F1A186EA1A548DDC81A2F8CD47B88750543B4A4B7FA20EA3716504420C0B2') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp118.sha256").Hash -ne '1016F41DDF4ECB153E92FD8A93B47710A8963D9F892AAD085D8BC712295B4454') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot118a.sha256").Hash -ne '1016F41DDF4ECB153E92FD8A93B47710A8963D9F892AAD085D8BC712295B4454') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot118a-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot118a did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot118a-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot118a did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp118\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 162) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land256-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot118a\quick118a\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land256-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land256-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land256-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp118.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land256-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp118: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp118.sha256", "$P2/cold-boot118a")
  ,@('stage-copy', "$P2/pins/source-tp118.sha256", "$P2/cold-boot118a", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land256-inputs-list.list", "$P2/variants/tp118", "$P2/pins/land256-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land256-inputs-list.sha256", "$P2/variants/tp118", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land256-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land256-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land256-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land256-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq '1016F41DDF4ECB153E92FD8A93B47710A8963D9F892AAD085D8BC712295B4454')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp118.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp118.sha256' }
Write-Output ('LAND256 ' + $i + ' steps')
