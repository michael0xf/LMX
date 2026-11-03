try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 262. tp124-prepare.command uses the verified boot123a seed and the tp124 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot123a\quick123a\lmxtool.exe"
$term="$p\pins\tp124-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '1f12cdc16a5ce43200abcf0b4e4bc43bc60b1232a6ef3cfeb7c135be4d89d9db') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'cb155e7e4e4d557b83a92164aa2066b32b68570307e2f6d0ea961632cbdd58b5') { throw 'selfbuild inputs manifest is not source-tp123' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp124-changed-fix12.list")
if ($ok.Count -ne 10) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp124\$o")) { throw ('variant file missing: ' + $o) } }
$fresh = -not (Test-Path -LiteralPath "$p\cold-tp124")
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if ($fresh) {
  $steps=@(
    ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
    ,@('manifest', "$P2/pins/tp124-changed-fix12.list", "$P2/variants/tp124", "$P2/pins/tp124-changed-$try.sha256")
    ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp124")
    ,@('stage-copy', "$P2/pins/tp124-changed-$try.sha256", "$P2/variants/tp124", "$P2/cold-tp124")
    ,@('manifest', "$P2/variants/tp124/inputs.list", "$P2/cold-tp124", "$P2/pins/source-tp124.sha256")
    ,@('verify', "$P2/pins/source-tp124.sha256", "$P2/cold-tp124")
  )
} else {
  $steps=@(
    ,@('manifest', "$P2/pins/tp124-changed-fix12.list", "$P2/variants/tp124", "$P2/pins/tp124-changed-$try.sha256")
    ,@('stage-copy', "$P2/pins/tp124-changed-$try.sha256", "$P2/variants/tp124", "$P2/cold-tp124")
    ,@('manifest', "$P2/variants/tp124/inputs.list", "$P2/cold-tp124", "$P2/pins/source-tp124.sha256")
    ,@('verify', "$P2/pins/source-tp124.sha256", "$P2/cold-tp124")
  )
  if (Test-Path -LiteralPath "$p\pins\source-tp124.sha256") { Move-Item -LiteralPath "$p\pins\source-tp124.sha256" -Destination "$p\pins\source-tp124-before-$try.sha256" }
}
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp124-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp124-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp123: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp124.sha256")
if ($a.Count -ne 167 -or $b.Count -ne 169) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 2) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
if ($fresh) {
  foreach ($g in @("$p\cold-tp124\headers", "$p\cold-tp124\src\l2src\lmx.h.lm1", "$p\cold-tp124\src\l1src\libc_abi.lm1", "$p\cold-tp124\src\l2src\l2_frontend_state.lm1", "$p\cold-tp124\src\l2src\lmx_arena_refs.h.lm1")) {
    if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
  }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp124 ' + (ShaTp "$p\pins\source-tp124.sha256") + ' changed ' + (ShaTp "$p\pins\tp124-changed-$try.sha256") + ' fresh ' + $fresh) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
