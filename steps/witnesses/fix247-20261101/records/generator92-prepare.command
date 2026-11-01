try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Generator92 = frozen source-generator85 with ONLY tools/build.lm2 replaced by
# writer92 (variants/coherent92): writer85 with value_names 61 -> 62, the new
# export lmx_value_loaded_context of lmx_value_owned (Codex
# CODEX-OPUS-V63A-20261031-ANSWER01 route (1)). The same 56 bridge headers
# (from cold-candidate49j) as generator85. Tool: GEN62 as for generator85.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\generator92-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-generator92") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\variants\coherent92\tools\build.lm2").Hash -notlike 'C46B3A57*') { throw 'writer92 hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-generator85.sha256", "$P2/cold-generator85")
  ,@('manifest', "$P2/pins/generator92-writer.list", "$P2/variants/coherent92", "$P2/pins/generator92-writer.sha256")
  ,@('stage-copy', "$P2/pins/source-generator85.sha256", "$P2/cold-generator85", "$P2/cold-generator92")
  ,@('stage-copy', "$P2/pins/generator92-writer.sha256", "$P2/variants/coherent92", "$P2/cold-generator92")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-generator92", "$P2/pins/source-generator92.sha256")
  ,@('stage-copy', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-candidate49j", "$P2/cold-generator92")
  ,@('verify', "$P2/pins/source-generator92.sha256", "$P2/cold-generator92")
  ,@('verify', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-generator92")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\generator92-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\generator92-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
