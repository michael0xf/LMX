try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage86w = stage83 (source83 + the 83 reuse inputs) with ONLY the walker
# replaced by variants/walker86: lmx_walk_args_open_values widens the
# activation's inputs to the selected callee's own receiving interface (its fn
# args part); an input the caller did not hand is the frame's zero input,
# absent as one handed absent (RU section 12; the native trampoline receives
# into the same width). For the RT86w check with FE84 before the 85 chain.
# Attempt 02: stage83 is recorded by source-candidate83b (writer83b);
# attempt 01 verified the stale source-candidate83 and stopped at step 02.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate86w-prepare-02.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate86w") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate86w-walker.list", "$P2/variants/walker86", "$P2/pins/candidate86w-walker.sha256")
  ,@('verify', "$P2/pins/source-candidate83b.sha256", "$P2/cold-candidate83")
  ,@('stage-copy', "$P2/pins/source-candidate83b.sha256", "$P2/cold-candidate83", "$P2/cold-candidate86w")
  ,@('stage-copy', "$P2/pins/candidate83-reuse-inputs.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate86w")
  ,@('stage-copy', "$P2/pins/candidate86w-walker.sha256", "$P2/variants/walker86", "$P2/cold-candidate86w")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate86w", "$P2/pins/source-candidate86w.sha256")
  ,@('verify', "$P2/pins/source-candidate86w.sha256", "$P2/cold-candidate86w")
  ,@('verify', "$P2/pins/candidate83-reuse-inputs.sha256", "$P2/cold-candidate86w")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate86w-prepare-02-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate86w-prepare-02-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
