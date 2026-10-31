try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage86w completion 2: the remaining FE83 outputs stage83 held when RT83 ran:
# l1src/l1_backend_scratch.h.lm1 (imported by l2src/l1_backend_emit.h.lm1;
# RT86w2 stopped there in bld_headers), l1src/l1_backend_state.lm1 and the
# eight L1 bodies in l2src (five l1_backend_*, l2_frontend_emit, l2_frontend_lower,
# l2_libc). With prepare-03 stage86w then holds every stage83 file but the walker.
# Copied from stage83 by an exact manifest; the sources stay as source-candidate86w.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate86w-prepare-04.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate86w")) { throw 'nostage' }
if (Test-Path -LiteralPath "$p\cold-candidate86w\src\l1src\l1_backend_scratch.h.lm1") { throw 'outputsexist' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate86w-fe83-outputs.list", "$P2/cold-candidate83", "$P2/pins/candidate86w-fe83-outputs.sha256")
  ,@('stage-copy', "$P2/pins/candidate86w-fe83-outputs.sha256", "$P2/cold-candidate83", "$P2/cold-candidate86w")
  ,@('verify', "$P2/pins/candidate86w-fe83-outputs.sha256", "$P2/cold-candidate86w")
  ,@('verify', "$P2/pins/source-candidate86w.sha256", "$P2/cold-candidate86w")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate86w-prepare-04-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate86w-prepare-04-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
