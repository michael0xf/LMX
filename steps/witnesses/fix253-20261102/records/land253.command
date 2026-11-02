try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot115f-tested source package into the tracked selfbuild/ (Codex, relayed answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate by the same rule: the whole source-tp115, after the actual successful boot115f). The exact
# 159 inputs bound by source-tp115.sha256 (48F66AF0...) are verified in cold-boot115f (whose source-boot115f.sha256 is the
# same bytes) and stage-copied over selfbuild/ (same path list); the package manifest is rewritten by the ordinary
# manifest command and verified, and the 65 sources that G1 and G2 retained in their consumed-input snapshots are
# verified against the landed files. Tool: the promoted working tool of boot115f (G2's, 8C5D66EA), fresh private
# CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot115f\quick115f\lmxtool.exe"
$term="$p\pins\land253.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '8C5D66EA0852864134B0DD98967F1AB1AB5FA17069D04CC82843FB913AE7CC44') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp115.sha256").Hash -ne '48F66AF0082628BE340DB193A3E943BE430E93739E796463C03E3DD86CB2D997') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot115f.sha256").Hash -ne '48F66AF0082628BE340DB193A3E943BE430E93739E796463C03E3DD86CB2D997') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot115f-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot115f did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot115f-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot115f did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$repo/selfbuild/inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 159) { throw ('inputs.list lines ' + $inputs.Count) }
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot115f\quick115f\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  if ($all.Count -ne 306) { throw ("$g consumed inputs " + $all.Count) }
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land253-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land253-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land253-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp115.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land253-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp115: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-boot115f")
  ,@('stage-copy', "$P2/pins/source-tp115.sha256", "$P2/cold-boot115f", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land253-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land253-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land253-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land253-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq '48F66AF0082628BE340DB193A3E943BE430E93739E796463C03E3DD86CB2D997')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp115.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp115.sha256' }
Write-Output ('LAND253 ' + $i + ' steps')
