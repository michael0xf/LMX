try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage94 = stage93 (source-candidate93) with coherent94's two files: Lower (the
# raw native route checks the holder of every ordinary managed DEREF, the final
# read and the written place included, with the existing implicit interpreter
# throw) and Emit (the throw-channel effects classify a raw dereference write
# head the same way). writer93 is unchanged (no new export). Reuse: the other 19
# frontend modules' outputs from cold-candidate93 by exact manifests; Emit's
# .h.lm1 is in the ABI manifest, Lower's is not (emit_indirect_value takes mi and
# the classification). Tool: boot89's promoted working tool (7FD2E824).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\candidate94-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate94") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate93\fe93\l2trans.exe")) { throw 'nofe93' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate94-coherent.list", "$P2/variants/coherent94", "$P2/pins/candidate94-coherent.sha256")
  ,@('verify', "$P2/pins/source-candidate93.sha256", "$P2/cold-candidate93")
  ,@('stage-copy', "$P2/pins/source-candidate93.sha256", "$P2/cold-candidate93", "$P2/cold-candidate94")
  ,@('stage-copy', "$P2/pins/candidate94-coherent.sha256", "$P2/variants/coherent94", "$P2/cold-candidate94")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate94", "$P2/pins/source-candidate94.sha256")
  ,@('manifest', "$P2/pins/candidate94-reuse-fe93.list", "$P2/cold-candidate93", "$P2/pins/candidate94-reuse-fe93.sha256")
  ,@('stage-copy', "$P2/pins/candidate94-reuse-fe93.sha256", "$P2/cold-candidate93", "$P2/cold-candidate94")
  ,@('manifest', "$P2/pins/candidate94-reuse-inputs.list", "$P2/cold-candidate94", "$P2/pins/candidate94-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate94-reuse-artifacts.list", "$P2/cold-candidate94", "$P2/pins/candidate94-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate94.sha256", "$P2/cold-candidate94")
  ,@('verify', "$P2/pins/candidate94-reuse-inputs.sha256", "$P2/cold-candidate94")
  ,@('verify', "$P2/pins/candidate94-reuse-artifacts.sha256", "$P2/cold-candidate94")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate94-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate94-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
