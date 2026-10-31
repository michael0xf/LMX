try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage83 = source82 with five sources replaced:
#   variants/frontend83: Lower83 (lm_compiler_emit_native_input_entry: a consumed
#     hidden input is held at activation entry, semantics RU §9 :464-466),
#     Emit83 (its call before the own entry loads), writer83 (exports and the
#     two implements prototypes);
#   variants/kernel83: implements83 (lmx_callable_bind_written binds the
#     normalized suffix by its Consumer contract input name), walker83 (the
#     suffix is evaluated, scattered with occupancy 2, and an absent one
#     travels as an absent full Value with ref 0).
# Reuse/invariant manifests = the 81 ones without the Emit outputs (Emit is
# rebuilt with Lower); hashes recomputed over cold-candidate80b.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate83-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate83") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate83-frontend.list", "$P2/variants/frontend83", "$P2/pins/candidate83-frontend.sha256")
  ,@('manifest', "$P2/pins/candidate83-kernel.list", "$P2/variants/kernel83", "$P2/pins/candidate83-kernel.sha256")
  ,@('verify', "$P2/pins/source-candidate82.sha256", "$P2/cold-candidate82")
  ,@('stage-copy', "$P2/pins/source-candidate82.sha256", "$P2/cold-candidate82", "$P2/cold-candidate83")
  ,@('stage-copy', "$P2/pins/candidate83-frontend.sha256", "$P2/variants/frontend83", "$P2/cold-candidate83")
  ,@('stage-copy', "$P2/pins/candidate83-kernel.sha256", "$P2/variants/kernel83", "$P2/cold-candidate83")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate83", "$P2/pins/source-candidate83.sha256")
  ,@('manifest', "$P2/pins/candidate83-reuse-inputs.list", "$P2/cold-candidate80b", "$P2/pins/candidate83-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate83-reuse-artifacts.list", "$P2/cold-candidate80b", "$P2/pins/candidate83-reuse-artifacts.sha256")
  ,@('stage-copy', "$P2/pins/candidate83-reuse-inputs.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate83")
  ,@('verify', "$P2/pins/source-candidate83.sha256", "$P2/cold-candidate83")
  ,@('verify', "$P2/pins/candidate83-reuse-inputs.sha256", "$P2/cold-candidate83")
  ,@('verify', "$P2/pins/candidate83-reuse-artifacts.sha256", "$P2/cold-candidate83")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate83-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate83-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
