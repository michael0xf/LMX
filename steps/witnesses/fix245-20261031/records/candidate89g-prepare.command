try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage89g = source-boot88 (source-candidate84 + walker86, the green line)
# with ONE source replaced: variants/green89 l2_frontend_resolve.lm2. boot88's
# G1 runtime stopped at lmx_pool.lm2:150:12 "assignment value has unknown
# type" (census88-kernel: 6 modules, all arithmetic over a member of a c.*
# struct pointer). The fold's operand typer now gives a path on an opaque C
# root the -12 contract the numeric receiver, CHECK and emission already give
# the same path alone. Body-only: resolve's declarations do not change (its
# .h.lm1 is in the ABI manifest, verified before and after the part build).
# Reuse: the other 20 frontend modules' .lm1/.h.lm1 of boot88's G1 frontend
# build (all 42 module outputs in cold-boot88 equal that record's out hashes,
# checked 2026-10-31 17:10Z); the part build regenerates every generated
# declaration, the backend, libc and the root itself.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator84\tool84-parts\lmxtool-tool.exe"
$term="$p\pins\candidate89g-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate89g") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne 'B9A2D857776B7BB3D8BFFFB386518CC05FB4F5D2651B77E4BD6ACBC5676A4D62') { throw 'tool84hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate89g-frontend.list", "$P2/variants/green89", "$P2/pins/candidate89g-frontend.sha256")
  ,@('verify', "$P2/pins/source-boot88.sha256", "$P2/cold-boot88")
  ,@('stage-copy', "$P2/pins/source-boot88.sha256", "$P2/cold-boot88", "$P2/cold-candidate89g")
  ,@('stage-copy', "$P2/pins/candidate89g-frontend.sha256", "$P2/variants/green89", "$P2/cold-candidate89g")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate89g", "$P2/pins/source-candidate89g.sha256")
  ,@('manifest', "$P2/pins/candidate89g-reuse-boot88.list", "$P2/cold-boot88", "$P2/pins/candidate89g-reuse-boot88.sha256")
  ,@('stage-copy', "$P2/pins/candidate89g-reuse-boot88.sha256", "$P2/cold-boot88", "$P2/cold-candidate89g")
  ,@('manifest', "$P2/pins/candidate89g-reuse-inputs.list", "$P2/cold-candidate89g", "$P2/pins/candidate89g-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate89g-reuse-artifacts.list", "$P2/cold-candidate89g", "$P2/pins/candidate89g-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate89g.sha256", "$P2/cold-candidate89g")
  ,@('verify', "$P2/pins/candidate89g-reuse-inputs.sha256", "$P2/cold-candidate89g")
  ,@('verify', "$P2/pins/candidate89g-reuse-artifacts.sha256", "$P2/cold-candidate89g")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate89g-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate89g-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
