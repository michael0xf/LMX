try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage82 = source81 with only Lower replaced by variants/frontend82 (D1 element
# pointer for the default-reader sentinel, D2 formal_raw spelling in
# emit_place_value_full). Reuse/invariant manifests are the unchanged 81 ones.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate82") { throw 'stageexists' }
if (Test-Path -LiteralPath "$p\pins\candidate82-prepare.terminal.txt") { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate81-lower.list", "$P2/variants/frontend82", "$P2/pins/candidate82-lower.sha256")
  ,@('stage-copy', "$P2/pins/source-candidate81.sha256", "$P2/cold-candidate81", "$P2/cold-candidate82")
  ,@('stage-copy', "$P2/pins/candidate82-lower.sha256", "$P2/variants/frontend82", "$P2/cold-candidate82")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate82", "$P2/pins/source-candidate82.sha256")
  ,@('stage-copy', "$P2/pins/candidate81-reuse-inputs.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate82")
  ,@('verify', "$P2/pins/source-candidate82.sha256", "$P2/cold-candidate82")
  ,@('verify', "$P2/pins/candidate81-reuse-inputs.sha256", "$P2/cold-candidate82")
  ,@('verify', "$P2/pins/candidate81-reuse-artifacts.sha256", "$P2/cold-candidate82")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate82-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate82-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath "$p\pins\candidate82-prepare.terminal.txt" -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
