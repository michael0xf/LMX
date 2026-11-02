try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp119 prepare-fix01 (fable_pc): the changed set of candidate tp119 after fix01 (pins/tp119-changed-fix01.list: the kernel
# module, the frontend modules emit and lower, the witness fixture and tests/full-suite.tsv) copied over the staged stage
# cold-tp119 after a fix.  The stage keeps its reused generated inputs (tp119-reuse); only the listed sources are copied over
# it.  Working tool 3E5F1A18 (boot118a's G2), verify/manifest/stage-copy only, fresh CWDs.  Parameter: TP_TRY (fix01, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot118a\quick118a\lmxtool.exe"
$term="$p\pins\tp119-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp119")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '3e5f1a186ea1a548ddc81a2f8cd47b88750543b4a4b7fa20ea3716504420c0b2') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '1016f41ddf4ecb153e92fd8a93b47710a8963d9f892aad085d8bc712295b4454') { throw 'selfbuild inputs manifest is not source-tp118' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp119-changed-fix01.list")
if ($ok.Count -ne 5) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp119\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('manifest', "$P2/pins/tp119-changed-fix01.list", "$P2/variants/tp119", "$P2/pins/tp119-changed-$try.sha256")
  ,@('stage-copy', "$P2/pins/tp119-changed-$try.sha256", "$P2/variants/tp119", "$P2/cold-tp119")
  ,@('manifest', "$P2/variants/tp119/inputs.list", "$P2/cold-tp119", "$P2/pins/source-tp119.sha256")
  ,@('verify', "$P2/pins/source-tp119.sha256", "$P2/cold-tp119")
)
if (Test-Path -LiteralPath "$p\pins\source-tp119.sha256") { Move-Item -LiteralPath "$p\pins\source-tp119.sha256" -Destination "$p\pins\source-tp119-before-$try.sha256" }
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp119-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp119-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp118: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp119.sha256")
if ($a.Count -ne 162 -or $b.Count -ne 163) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp119 ' + (ShaTp "$p\pins\source-tp119.sha256") + ' changed ' + (ShaTp "$p\pins\tp119-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
