try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage90 = the draft79 line's stage87 (source-candidate87) with TWO sources
# replaced, both body-only (their .h.lm1 are in the ABI manifest, verified
# before and after the part build):
# - Emit from variants/coherent89 (B9580244): lm_compiler_check_word_stmt
#   refuses a bare `return` only for a machine function with a result, the
#   exact complement of what Lower/Core lower by emit_empty_return
#   (DRAFT79-BARE-RETURN-CHECKER; Codex CODEX-OPUS-85FIND-20261031-ANSWER (c));
# - resolve from variants/green89 (25769A60): the arithmetic fold's raw-C
#   member contract (MACHINE-C-MEMBER-ARITHMETIC-UNKNOWN-TYPE, slice245); the
#   87 line carries the same receive route and source84's resolve 4553D128.
# Reuse: FE87's other 19 frontend modules' outputs from cold-candidate87 by
# exact manifests. Tool: boot89's promoted working tool (7FD2E824).
# Attempt 02: attempt 01 (candidate90-prepare.terminal.txt) stopped at its step 04,
# verify candidate87-reuse-artifacts.sha256 in cold-candidate87: 139 verified,
# 6 failed -- lmx_implements/lmx_walk/lmx_value_owned .h.lm1 and .lm1.h, which RT87
# regenerated after FE87 (its record holds the current hashes); kernel
# declarations are not inputs of a frontend part build (89g staged none), and
# the 40 frontend artifacts reused here were among the 139 verified.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\candidate90-prepare-02.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate90") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\variants\coherent89\src\l2src\l2_frontend_emit.lm2").Hash -notlike 'B9580244*') { throw 'emit hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\variants\green89\src\l2src\l2_frontend_resolve.lm2").Hash -notlike '25769A60*') { throw 'resolve hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/candidate90-frontend-emit.sha256", "$P2/variants/coherent89")
  ,@('verify', "$P2/pins/candidate90-frontend-resolve.sha256", "$P2/variants/green89")
  ,@('verify', "$P2/pins/source-candidate87.sha256", "$P2/cold-candidate87")
  ,@('stage-copy', "$P2/pins/source-candidate87.sha256", "$P2/cold-candidate87", "$P2/cold-candidate90")
  ,@('stage-copy', "$P2/pins/candidate90-frontend-emit.sha256", "$P2/variants/coherent89", "$P2/cold-candidate90")
  ,@('stage-copy', "$P2/pins/candidate90-frontend-resolve.sha256", "$P2/variants/green89", "$P2/cold-candidate90")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate90", "$P2/pins/source-candidate90.sha256")
  ,@('manifest', "$P2/pins/candidate90-reuse-fe87.list", "$P2/cold-candidate87", "$P2/pins/candidate90-reuse-fe87.sha256")
  ,@('stage-copy', "$P2/pins/candidate90-reuse-fe87.sha256", "$P2/cold-candidate87", "$P2/cold-candidate90")
  ,@('manifest', "$P2/pins/candidate90-reuse-inputs.list", "$P2/cold-candidate90", "$P2/pins/candidate90-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate90-reuse-artifacts.list", "$P2/cold-candidate90", "$P2/pins/candidate90-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate90.sha256", "$P2/cold-candidate90")
  ,@('verify', "$P2/pins/candidate90-reuse-inputs.sha256", "$P2/cold-candidate90")
  ,@('verify', "$P2/pins/candidate90-reuse-artifacts.sha256", "$P2/cold-candidate90")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate90-prepare-02-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate90-prepare-02-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
