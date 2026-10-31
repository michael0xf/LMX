try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Generator83b = frozen source-generator62 with ONLY tools/build.lm2 replaced by
# writer83b (variants/frontend83): writer83 (the Lower export
# lm_compiler_emit_native_input_entry, the implements export
# lmx_callable_source_receiving with its prototype, the bind_written prototype
# with contract_inputs) plus the program compile in bld_program_k bounded by
# bld_step_t 3600000U (CODEX-OPUS-83CCTIME-20261031-ANSWER). Generator83
# (writer83 without that bound) is superseded, kept as built. The same 56 old
# coherent bootstrap headers (from cold-candidate49j).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\generator83b-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-generator83b") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-generator62.sha256", "$P2/cold-generator62")
  ,@('manifest', "$P2/pins/generator83-writer.list", "$P2/variants/frontend83", "$P2/pins/generator83b-writer.sha256")
  ,@('stage-copy', "$P2/pins/source-generator62.sha256", "$P2/cold-generator62", "$P2/cold-generator83b")
  ,@('stage-copy', "$P2/pins/generator83b-writer.sha256", "$P2/variants/frontend83", "$P2/cold-generator83b")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-generator83b", "$P2/pins/source-generator83b.sha256")
  ,@('stage-copy', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-candidate49j", "$P2/cold-generator83b")
  ,@('verify', "$P2/pins/source-generator83b.sha256", "$P2/cold-generator83b")
  ,@('verify', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-generator83b")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\generator83b-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\generator83b-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
