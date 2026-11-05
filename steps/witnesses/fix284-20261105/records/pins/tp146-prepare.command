try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 284. Refreshes the working stage cold-tp140 with the changed files of the candidate variants/tp146 and pins its
# source manifest. Uses the verified boot145a tool. Parameter TP_TRY (a label). Exactly the listed files may differ from source283.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot145a\quick145a\lmxtool.exe"
$term="$p\pins\tp146-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6d0c44248c1e5b2de37990ea1875d29591c8f475391dc4f4dc7e011f8efbe0a2') { throw 'tool hash' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp146-changed.list" | Where-Object { $_ -ne '' })
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp146\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath "$p\pins\source-tp146.sha256") { Move-Item -LiteralPath "$p\pins\source-tp146.sha256" -Destination "$p\pins\source-tp146-before-$try.sha256" }
$steps=@(
  ,@('manifest', "$P2/pins/tp146-changed.list", "$P2/variants/tp146", "$P2/pins/tp146-changed-$try.sha256")
  ,@('stage-copy', "$P2/pins/tp146-changed-$try.sha256", "$P2/variants/tp146", "$P2/cold-tp140")
  ,@('manifest', "$P2/variants/tp146/inputs.list", "$P2/cold-tp140", "$P2/pins/source-tp146.sha256")
  ,@('verify', "$P2/pins/source-tp146.sha256", "$P2/cold-tp140")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp146-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp146-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp146.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp146 ' + (ShaTp "$p\pins\source-tp146.sha256") + ' inputs ' + $b.Count + ' changed ' + (ShaTp "$p\pins\tp146-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps, inputs ' + $b.Count)
