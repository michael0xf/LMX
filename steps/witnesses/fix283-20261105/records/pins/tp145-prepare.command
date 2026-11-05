try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 283. Refreshes the working stage cold-tp140 with the changed files of the candidate variants/tp145 and pins its
# source manifest. Uses the verified boot144b tool. Parameter TP_TRY (a label). Exactly the listed files may differ from source282.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot144b\quick144b\lmxtool.exe"
$term="$p\pins\tp145-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e7c5cec1d2042c47fd54cb82643d97fe24fdef12b28c565a7a980b2dc0db1398') { throw 'tool hash' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp145-changed.list" | Where-Object { $_ -ne '' })
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp145\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath "$p\pins\source-tp145.sha256") { Move-Item -LiteralPath "$p\pins\source-tp145.sha256" -Destination "$p\pins\source-tp145-before-$try.sha256" }
$steps=@(
  ,@('manifest', "$P2/pins/tp145-changed.list", "$P2/variants/tp145", "$P2/pins/tp145-changed-$try.sha256")
  ,@('stage-copy', "$P2/pins/tp145-changed-$try.sha256", "$P2/variants/tp145", "$P2/cold-tp140")
  ,@('manifest', "$P2/variants/tp145/inputs.list", "$P2/cold-tp140", "$P2/pins/source-tp145.sha256")
  ,@('verify', "$P2/pins/source-tp145.sha256", "$P2/cold-tp140")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp145-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp145-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp145.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp145 ' + (ShaTp "$p\pins\source-tp145.sha256") + ' inputs ' + $b.Count + ' changed ' + (ShaTp "$p\pins\tp145-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps, inputs ' + $b.Count)
