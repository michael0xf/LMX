try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot114-tested source package into the tracked selfbuild/ (Codex, relayed answer to
# FABLE-RESULT-S3-20261102T0100Z, choice (a), applied to the next candidate by the same rule: the whole source-tp114, after the actual successful boot114). The exact
# 159 inputs bound by source-tp114.sha256 (FE3FDA29...) are verified in cold-boot114 (whose source-boot114.sha256 is the
# same bytes) and stage-copied over selfbuild/ (same path list); the package manifest is rewritten by the ordinary
# manifest command and verified, and the 65 sources that G1 and G2 retained in their consumed-input snapshots are
# verified against the landed files. Tool: the promoted working tool of boot114 (G2's, 6619A503), fresh private
# CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\land252.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '6619A5036E02987FCD7D88BCF25029398F93C0C94B981D5D47EB48BA6F2A8027') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp114.sha256").Hash -ne 'FE3FDA29B2B6029DB640717BAF88E812F75F6AD3B8E64C54FF5BCF27BF31D6CF') { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot114.sha256").Hash -ne 'FE3FDA29B2B6029DB640717BAF88E812F75F6AD3B8E64C54FF5BCF27BF31D6CF') { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot114-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw 'boot114 did not pass' }
if (-not (Select-String -LiteralPath "$p\pins\boot114-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw 'boot114 did not pass' }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$repo/selfbuild/inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 159) { throw ('inputs.list lines ' + $inputs.Count) }
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot114\quick114\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  if ($all.Count -ne 306) { throw ("$g consumed inputs " + $all.Count) }
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land252-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land252-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land252-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp114.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land252-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp114: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp114.sha256", "$P2/cold-boot114")
  ,@('stage-copy', "$P2/pins/source-tp114.sha256", "$P2/cold-boot114", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land252-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land252-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land252-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land252-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq 'FE3FDA29B2B6029DB640717BAF88E812F75F6AD3B8E64C54FF5BCF27BF31D6CF')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp114.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp114.sha256' }
Write-Output ('LAND251 ' + $i + ' steps')
