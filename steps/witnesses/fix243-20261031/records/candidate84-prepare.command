try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage84 = source83b with three sources replaced from variants/frontend84:
#   Useplan84 (one activation publication table; group helpers take it and read
#   each place cast back to its exact address type; boundaries pass only it),
#   Core84 (work declarations register each published place right after it is
#   declared), writer84 (the Useplan export lm_compiler_emit_publish_table).
# Reuse: the 83 reuse set without Useplan72/Core80b, from cold-candidate80b, plus
# the actual FE83 Lower83/Emit83 outputs from cold-candidate83; both copied in,
# then one combined manifest pair over stage84 itself.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate84-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate84") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate84-frontend.list", "$P2/variants/frontend84", "$P2/pins/candidate84-frontend.sha256")
  ,@('verify', "$P2/pins/source-candidate83b.sha256", "$P2/cold-candidate83")
  ,@('stage-copy', "$P2/pins/source-candidate83b.sha256", "$P2/cold-candidate83", "$P2/cold-candidate84")
  ,@('stage-copy', "$P2/pins/candidate84-frontend.sha256", "$P2/variants/frontend84", "$P2/cold-candidate84")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate84", "$P2/pins/source-candidate84.sha256")
  ,@('manifest', "$P2/pins/candidate84-reuse80b.list", "$P2/cold-candidate80b", "$P2/pins/candidate84-reuse80b.sha256")
  ,@('manifest', "$P2/pins/candidate84-reuse83.list", "$P2/cold-candidate83", "$P2/pins/candidate84-reuse83.sha256")
  ,@('stage-copy', "$P2/pins/candidate84-reuse80b.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate84")
  ,@('stage-copy', "$P2/pins/candidate84-reuse83.sha256", "$P2/cold-candidate83", "$P2/cold-candidate84")
  ,@('manifest', "$P2/pins/candidate84-reuse-inputs.list", "$P2/cold-candidate84", "$P2/pins/candidate84-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate84-reuse-artifacts.list", "$P2/cold-candidate84", "$P2/pins/candidate84-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate84.sha256", "$P2/cold-candidate84")
  ,@('verify', "$P2/pins/candidate84-reuse-inputs.sha256", "$P2/cold-candidate84")
  ,@('verify', "$P2/pins/candidate84-reuse-artifacts.sha256", "$P2/cold-candidate84")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate84-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate84-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
