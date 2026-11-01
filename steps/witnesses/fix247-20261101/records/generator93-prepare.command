try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Generator93 = frozen source-generator85 with ONLY tools/build.lm2 replaced by
# writer93 (variants/coherent93): writer92 with frontend_lower_names 442 -> 443,
# the new export lm_compiler_indirect_managed of l2_frontend_lower (the native
# typed dereference's classification, shared with the throw-channel analysis).
# The same 56 bridge headers (from cold-candidate49j) as generator85/92.
# Tool: GEN62 as for generator85/92.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\generator93-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-generator93") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\variants\coherent93\tools\build.lm2").Hash -notlike '1C6A9974*') { throw 'writer93 hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-generator85.sha256", "$P2/cold-generator85")
  ,@('manifest', "$P2/pins/generator93-writer.list", "$P2/variants/coherent93", "$P2/pins/generator93-writer.sha256")
  ,@('stage-copy', "$P2/pins/source-generator85.sha256", "$P2/cold-generator85", "$P2/cold-generator93")
  ,@('stage-copy', "$P2/pins/generator93-writer.sha256", "$P2/variants/coherent93", "$P2/cold-generator93")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-generator93", "$P2/pins/source-generator93.sha256")
  ,@('stage-copy', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-candidate49j", "$P2/cold-generator93")
  ,@('verify', "$P2/pins/source-generator93.sha256", "$P2/cold-generator93")
  ,@('verify', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-generator93")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\generator93-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\generator93-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
