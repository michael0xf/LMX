try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Generator85 = frozen source-generator62 with ONLY tools/build.lm2 replaced by
# writer85 (variants/coherent85): draft79 writer67839B11 merged with writer84 (exports
# Lower442, Useplan151, ValueOwned61, walkValues138, implements59 + prototypes, CC bound).
# Kernel79 (draft79) coherent with the 82/83/84 fixes.
# The same 56 old coherent bootstrap headers (from cold-candidate49j).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\generator85-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-generator85") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-generator62.sha256", "$P2/cold-generator62")
  ,@('manifest', "$P2/pins/generator83-writer.list", "$P2/variants/coherent85", "$P2/pins/generator85-writer.sha256")
  ,@('stage-copy', "$P2/pins/source-generator62.sha256", "$P2/cold-generator62", "$P2/cold-generator85")
  ,@('stage-copy', "$P2/pins/generator85-writer.sha256", "$P2/variants/coherent85", "$P2/cold-generator85")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-generator85", "$P2/pins/source-generator85.sha256")
  ,@('stage-copy', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-candidate49j", "$P2/cold-generator85")
  ,@('verify', "$P2/pins/source-generator85.sha256", "$P2/cold-generator85")
  ,@('verify', "$P2/pins/generator52-bridge-headers.sha256", "$P2/cold-generator85")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\generator85-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\generator85-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
