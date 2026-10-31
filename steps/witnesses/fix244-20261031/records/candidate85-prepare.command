try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage85 = source84 with the coherent kernel79 sources (variants/coherent85):
# draft79 (working-value79, Codex) merged three-way with the 82/83/84 fixes
# (base Core80/Lower81/Useplan72/Emit77/walker71/writer62); implements83;
# ValueOwned79; writer85. Reuse: the 80b-era set without the four frontend
# modules (all four are rebuilt), from cold-candidate80b.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate85-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate85") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/coherent85.list", "$P2/variants/coherent85", "$P2/pins/candidate85-coherent.sha256")
  ,@('verify', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84")
  ,@('stage-copy', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84", "$P2/cold-candidate85")
  ,@('stage-copy', "$P2/pins/candidate85-coherent.sha256", "$P2/variants/coherent85", "$P2/cold-candidate85")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate85", "$P2/pins/source-candidate85.sha256")
  ,@('manifest', "$P2/pins/candidate85-reuse-inputs.list", "$P2/cold-candidate80b", "$P2/pins/candidate85-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate85-reuse-artifacts.list", "$P2/cold-candidate80b", "$P2/pins/candidate85-reuse-artifacts.sha256")
  ,@('stage-copy', "$P2/pins/candidate85-reuse-inputs.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate85")
  ,@('verify', "$P2/pins/source-candidate85.sha256", "$P2/cold-candidate85")
  ,@('verify', "$P2/pins/candidate85-reuse-inputs.sha256", "$P2/cold-candidate85")
  ,@('verify', "$P2/pins/candidate85-reuse-artifacts.sha256", "$P2/cold-candidate85")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate85-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate85-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
