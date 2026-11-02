try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot116c-tested source package into the tracked selfbuild/ (the rule of Codex's answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate: the whole source-tp116, after the actual
# successful boot116c). The exact 160 inputs bound by source-tp116.sha256 (DC4E8C62...) are verified in cold-boot116c (whose
# source-boot116c.sha256 is the same bytes) and stage-copied over selfbuild/ (same path list); the variant's inputs.list
# (160 lines: the new fixture tests/dyn/free_name_chain.lm2) is copied into selfbuild/ by a one-line manifest first; the
# package manifest is rewritten by the ordinary manifest command and verified, and the 65 sources that G1 and G2 retained in
# their consumed-input snapshots are verified against the landed files. Tool: the promoted working tool of boot116c (G2's,
# 18C898AC), fresh private CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot116c\quick116c\lmxtool.exe"
$term="$p\pins\land254.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '18C898AC3D86869E781A6DFEE8BFFF20C9892DF572D9443D23BBA280CC212BA3') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp116.sha256").Hash -ne 'DC4E8C62E5CBE8F9BEB3F6A522E9AABD0E6A640CC2307ADE0DAB4DE075D419B5') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot116c.sha256").Hash -ne 'DC4E8C62E5CBE8F9BEB3F6A522E9AABD0E6A640CC2307ADE0DAB4DE075D419B5') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot116c-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot116c did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot116c-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot116c did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp116\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 160) { throw ('inputs.list lines ' + $inputs.Count) }
$listOne="$p\pins\land254-inputs-list.list"
if (Test-Path -LiteralPath $listOne) { throw 'exists list' }
[IO.File]::WriteAllText($listOne, "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot116c\quick116c\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land254-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land254-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land254-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp116.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land254-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp116: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp116.sha256", "$P2/cold-boot116c")
  ,@('stage-copy', "$P2/pins/source-tp116.sha256", "$P2/cold-boot116c", "$repo/selfbuild")
  ,@('manifest', "$P2/pins/land254-inputs-list.list", "$P2/variants/tp116", "$P2/pins/land254-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/land254-inputs-list.sha256", "$P2/variants/tp116", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land254-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land254-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land254-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land254-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'DC4E8C62E5CBE8F9BEB3F6A522E9AABD0E6A640CC2307ADE0DAB4DE075D419B5')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp116.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp116.sha256' }
Write-Output ('LAND254 ' + $i + ' steps')
