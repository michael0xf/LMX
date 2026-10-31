try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage86w completion: RT83 ran on stage83 after FE83, whose outputs include
# seven generated declaration headers (five l1_backend_*, l2_frontend_emit,
# l2_frontend_lower) that neither source-candidate83b nor the 83 reuse inputs
# carry. RT86w attempt 01 stopped in bld_headers: l2_frontend_core.h.lm1
# imports l2src/l2_frontend_lower.h.lm1. The same seven files are copied from
# stage83 by an exact manifest; the sources stay as source-candidate86w.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate86w-prepare-03.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-candidate86w")) { throw 'nostage' }
if (Test-Path -LiteralPath "$p\cold-candidate86w\src\l2src\l2_frontend_lower.h.lm1") { throw 'headersexist' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate86w-fe83-headers.list", "$P2/cold-candidate83", "$P2/pins/candidate86w-fe83-headers.sha256")
  ,@('stage-copy', "$P2/pins/candidate86w-fe83-headers.sha256", "$P2/cold-candidate83", "$P2/cold-candidate86w")
  ,@('verify', "$P2/pins/candidate86w-fe83-headers.sha256", "$P2/cold-candidate86w")
  ,@('verify', "$P2/pins/source-candidate86w.sha256", "$P2/cold-candidate86w")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate86w-prepare-03-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate86w-prepare-03-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
