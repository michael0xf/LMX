try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage85 walker swap after RT85 attempt 01 (label rt85) stopped translating
# the coherent85 walker: `lmx_walk_values.lm2:467:13: assignment value has
# unknown type` (draft79's lmx_walk_graph_value_ref returned `value\ref` of a
# by-value LmxWalkValue; the file's own form gives such a read its type by a
# cast, as `(cast: (@: void) saved\ref)` in lmx_walk_value_materialize).
# Only src/l2src/lmx_walk_values.lm2 is replaced. FE85 does not read the
# walker source (its kernel declarations are the 80b-era reuse invariants).
# The reuse sets are not re-verified: RT85 attempt 01 already regenerated the
# kernel modules translated before the walker, as any runtime build does.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate85b-walker.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if (Test-Path -LiteralPath "$p\cold-candidate85\rt85b") { throw 'rt85b exists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-candidate85.sha256", "$P2/cold-candidate85")
  ,@('manifest', "$P2/pins/candidate85b-walker.list", "$P2/variants/coherent85", "$P2/pins/candidate85b-walker.sha256")
  ,@('stage-copy', "$P2/pins/candidate85b-walker.sha256", "$P2/variants/coherent85", "$P2/cold-candidate85")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate85", "$P2/pins/source-candidate85b.sha256")
  ,@('verify', "$P2/pins/source-candidate85b.sha256", "$P2/cold-candidate85")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate85b-walker-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate85b-walker-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
