try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage92 = stage90 (source-candidate90) with coherent92's six files: the
# kernel of mechanism (a) with ONE exported helper lmx_value_loaded_context
# (lmx_value_owned, lmx_walk_values, lmx_reparent), writer92 (value_names 62),
# Lower (the native typed dereference qualified by that helper) and Coords (the
# split-pointer data row). Reuse: FE90's other 19 frontend modules' outputs
# (Emit90 and resolve90 among them) from cold-candidate90 by exact manifests;
# Lower's and Coords' .h.lm1 are in the ABI manifest (body-only changes).
# Tool: boot89's promoted working tool (7FD2E824). Runs after FE90.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\candidate92-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate92") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate90\fe90\l2trans.exe")) { throw 'nofe90' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate92-coherent.list", "$P2/variants/coherent92", "$P2/pins/candidate92-coherent.sha256")
  ,@('verify', "$P2/pins/source-candidate90.sha256", "$P2/cold-candidate90")
  ,@('stage-copy', "$P2/pins/source-candidate90.sha256", "$P2/cold-candidate90", "$P2/cold-candidate92")
  ,@('stage-copy', "$P2/pins/candidate92-coherent.sha256", "$P2/variants/coherent92", "$P2/cold-candidate92")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate92", "$P2/pins/source-candidate92.sha256")
  ,@('manifest', "$P2/pins/candidate92-reuse-fe90.list", "$P2/cold-candidate90", "$P2/pins/candidate92-reuse-fe90.sha256")
  ,@('stage-copy', "$P2/pins/candidate92-reuse-fe90.sha256", "$P2/cold-candidate90", "$P2/cold-candidate92")
  ,@('manifest', "$P2/pins/candidate92-reuse-inputs.list", "$P2/cold-candidate92", "$P2/pins/candidate92-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate92-reuse-artifacts.list", "$P2/cold-candidate92", "$P2/pins/candidate92-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate92.sha256", "$P2/cold-candidate92")
  ,@('verify', "$P2/pins/candidate92-reuse-inputs.sha256", "$P2/cold-candidate92")
  ,@('verify', "$P2/pins/candidate92-reuse-artifacts.sha256", "$P2/cold-candidate92")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate92-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate92-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
