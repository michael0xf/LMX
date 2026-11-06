try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 288. land288 uses the verified working tool of the slice's whole (parameter TP_TRY names boot150<try>; its working
# tool's sha256 is TP_TOOLSHA, read from the compare record), and the frozen source-tp150.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY; $toolSha=$env:TP_TOOLSHA; $srcSha=$env:TP_SRCSHA
if (-not $try -or -not $toolSha -or -not $srcSha) { throw 'parameters TP_TRY TP_TOOLSHA TP_SRCSHA' }
$tool="$p\cold-boot150$try\quick150$try\lmxtool.exe"
$term="$p\pins\land288.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne $toolSha.ToUpperInvariant()) { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-tp150.sha256").Hash -ne $srcSha.ToUpperInvariant()) { throw 'source manifest hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot150$try.sha256").Hash -ne $srcSha.ToUpperInvariant()) { throw 'stage manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot150$try-quick.terminal.txt" -Pattern 'BootstrapExit 0' -Quiet)) { throw ('boot150' + $try + ' did not pass') }
if (-not (Select-String -LiteralPath "$p\pins\boot150$try-quick.log" -Pattern '^BOOTSTRAP quick 0 failures' -Quiet)) { throw ('boot150' + $try + ' did not pass') }
# the generations' consumed-input snapshots restricted to the package's selected paths (the sources; tools and tests are
# not consumed by the tool build): both subsets must hold 65 lines and be the same lines
$inputs=@(Get-Content -LiteralPath "$p\variants\tp150\inputs.list" | Where-Object { $_ -ne '' })
if ($inputs.Count -ne 218) { throw ('inputs.list lines ' + $inputs.Count) }
foreach ($g in @('g1','g2')) {
  $all=@(Get-Content -LiteralPath "$p\cold-boot150$try\quick150$try\$g\consumed-inputs.sha256" | Where-Object { $_ -ne '' })
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $g consumed inputs " + $all.Count) -Encoding utf8
  $sub=@($all | Where-Object { $inputs -contains ($_ -split '  ',2)[1] })
  if ($sub.Count -ne 65) { throw ("$g consumed sources " + $sub.Count) }
  $f="$p\pins\land288-$g-consumed-sources.sha256"
  if (Test-Path -LiteralPath $f) { throw ('exists ' + $f) }
  [IO.File]::WriteAllText($f, (($sub -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
}
if (@(Compare-Object -ReferenceObject @(Get-Content -LiteralPath "$p\pins\land288-g1-consumed-sources.sha256") -DifferenceObject @(Get-Content -LiteralPath "$p\pins\land288-g2-consumed-sources.sha256")).Count -ne 0) { throw 'G1 and G2 consumed sources differ' }
$src=@(Get-Content -LiteralPath "$p\pins\source-tp150.sha256")
foreach ($l in @(Get-Content -LiteralPath "$p\pins\land288-g1-consumed-sources.sha256")) { if ($src -notcontains $l) { throw ('consumed source not in source-tp150: ' + $l) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-tp150.sha256", "$P2/cold-boot150$try")
  ,@('stage-copy', "$P2/pins/source-tp150.sha256", "$P2/cold-boot150$try", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land288-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land288-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land288-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land288-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq $srcSha.ToUpperInvariant())
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-tp150.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-tp150.sha256' }
Write-Output ('LAND288 ' + $i + ' steps')
