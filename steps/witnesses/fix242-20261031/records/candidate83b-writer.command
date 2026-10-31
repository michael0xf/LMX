try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage83 (not yet used by any build) carries writer83b, the writer of its
# host tool83b: only tools/build.lm2 is replaced; the other 158 inputs and the
# reuse inputs/invariants stay as prepared (re-verified here).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate83b-writer.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate83\fe83") { throw 'stage83 already used' }
if (Test-Path -LiteralPath "$p\cold-candidate83\rt83") { throw 'stage83 already used' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-candidate83.sha256", "$P2/cold-candidate83")
  ,@('manifest', "$P2/pins/generator83-writer.list", "$P2/variants/frontend83", "$P2/pins/candidate83b-writer.sha256")
  ,@('stage-copy', "$P2/pins/candidate83b-writer.sha256", "$P2/variants/frontend83", "$P2/cold-candidate83")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate83", "$P2/pins/source-candidate83b.sha256")
  ,@('verify', "$P2/pins/source-candidate83b.sha256", "$P2/cold-candidate83")
  ,@('verify', "$P2/pins/candidate83-reuse-inputs.sha256", "$P2/cold-candidate83")
  ,@('verify', "$P2/pins/candidate83-reuse-artifacts.sha256", "$P2/cold-candidate83")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate83b-writer-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate83b-writer-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
