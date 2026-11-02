try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp120 prepare-fix01 (fable_pc): the changed set of candidate tp120 (pins/tp120-changed.list: the kernel module, the frontend
# modules resolve, lower and emit, the witness fixture and tests/full-suite.tsv) copied over the staged stage cold-tp120 after a
# fix.  The stage keeps its reused generated inputs (tp120-reuse); only the listed sources are copied over it.  Working tool
# 64AE29A0 (boot119a's G2), verify/manifest/stage-copy only, fresh CWDs.  Parameter: TP_TRY (fix01, fix02, ...).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY
if (-not $try) { throw 'parameter TP_TRY' }
$tool="$p\cold-boot119a\quick119a\lmxtool.exe"
$term="$p\pins\tp120-prepare-$try.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp120")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '64ae29a0d4e8b2ee22eec82724bcc410c4a4ffce906650698b9be52ccc660d01') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '900ab2840a04c4dbdf7e616a0246c035ae82933c848c80da0ff1089c42c82321') { throw 'selfbuild inputs manifest is not source-tp119' }
$ok=@(Get-Content -LiteralPath "$p\pins\tp120-changed.list")
if ($ok.Count -ne 6) { throw ('changed list lines ' + $ok.Count) }
foreach ($o in $ok) { if (-not (Test-Path -LiteralPath "$p\variants\tp120\$o")) { throw ('variant file missing: ' + $o) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('manifest', "$P2/pins/tp120-changed.list", "$P2/variants/tp120", "$P2/pins/tp120-changed-$try.sha256")
  ,@('stage-copy', "$P2/pins/tp120-changed-$try.sha256", "$P2/variants/tp120", "$P2/cold-tp120")
  ,@('manifest', "$P2/variants/tp120/inputs.list", "$P2/cold-tp120", "$P2/pins/source-tp120.sha256")
  ,@('verify', "$P2/pins/source-tp120.sha256", "$P2/cold-tp120")
)
if (Test-Path -LiteralPath "$p\pins\source-tp120.sha256") { Move-Item -LiteralPath "$p\pins\source-tp120.sha256" -Destination "$p\pins\source-tp120-before-$try.sha256" }
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp120-prepare-$try-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp120-prepare-$try-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly the listed lines differ from source-tp119: two manifest lines per changed file, one for the new fixture.
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp120.sha256")
if ($a.Count -ne 163 -or $b.Count -ne 164) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 2 * $ok.Count - 1) { throw ('manifest differences ' + $d.Count) }
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp120 ' + (ShaTp "$p\pins\source-tp120.sha256") + ' changed ' + (ShaTp "$p\pins\tp120-changed-$try.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
