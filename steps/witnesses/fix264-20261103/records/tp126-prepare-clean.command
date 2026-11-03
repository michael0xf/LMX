try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Codex, slice 264. tp126-prepare.command uses the verified boot125a seed and the tp126 source candidate.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot125a\quick125a\lmxtool.exe"
$term="$p\pins\tp126-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '9e5798d8bd55e57a89242fdad0624c2af9bdf5ce27396624a79f72dcea0766ea') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '48951ca277b822ff35997a07d33aa72d44660044276de5a0a9b563a4316e6ec2') { throw 'selfbuild inputs manifest is not source-tp125' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp126-changed-fix05.list")
if ($ok.Count -ne 12) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp126\$o")) { throw ('variant file missing: ' + $o) } }
$fresh = -not (Test-Path -LiteralPath "$p\cold-tp126")
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if ($fresh) {
  $steps=@(
    ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
    ,@('manifest', "$P2/pins/tp126-changed-fix05.list", "$P2/variants/tp126", "$P2/pins/tp126-changed-$try.sha256")
    ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp126")
    ,@('stage-copy', "$P2/pins/tp126-changed-$try.sha256", "$P2/variants/tp126", "$P2/cold-tp126")
    ,@('manifest', "$P2/variants/tp126/inputs.list", "$P2/cold-tp126", "$P2/pins/source-tp126.sha256")
    ,@('verify', "$P2/pins/source-tp126.sha256", "$P2/cold-tp126")
  )
} else {
  $steps=@(
    ,@('manifest', "$P2/pins/tp126-changed-fix05.list", "$P2/variants/tp126", "$P2/pins/tp126-changed-$try.sha256")
    ,@('stage-copy', "$P2/pins/tp126-changed-$try.sha256", "$P2/variants/tp126", "$P2/cold-tp126")
    ,@('manifest', "$P2/variants/tp126/inputs.list", "$P2/cold-tp126", "$P2/pins/source-tp126.sha256")
    ,@('verify', "$P2/pins/source-tp126.sha256", "$P2/cold-tp126")
  )
  if (Test-Path -LiteralPath "$p\pins\source-tp126.sha256") { Move-Item -LiteralPath "$p\pins\source-tp126.sha256" -Destination "$p\pins\source-tp126-before-$try.sha256" }
}
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp126-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp126-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp125: two manifest lines per changed file.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp126.sha256")
if ($a.Count -ne 173 -or $b.Count -ne 173) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
if ($fresh) {
  foreach ($g in @("$p\cold-tp126\headers", "$p\cold-tp126\src\l2src\lmx.h.lm1", "$p\cold-tp126\src\l1src\libc_abi.lm1", "$p\cold-tp126\src\l2src\l2_frontend_state.lm1", "$p\cold-tp126\src\l2src\lmx_arena_refs.h.lm1")) {
    if (Test-Path -LiteralPath $g) { throw ('generated input exists: ' + $g) }
  }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp126 ' + (ShaTp "$p\pins\source-tp126.sha256") + ' changed ' + (ShaTp "$p\pins\tp126-changed-$try.sha256") + ' fresh ' + $fresh) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
