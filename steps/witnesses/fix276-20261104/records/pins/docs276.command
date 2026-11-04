try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 276. docs276 uses the verified boot138b working tool.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot138b\quick138b\lmxtool.exe"
$term="$p\pins\docs276.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '603B63979C585433832B6FF3810857FF371E2BC46F1AAA1880B1B37AF4D45D1F') { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$repo/steps/witnesses/fix276-20261104/evidence.list", $P2, "$repo/steps/witnesses/fix276-20261104/evidence.sha256")
  ,@('verify', "$repo/steps/witnesses/fix276-20261104/evidence.sha256", $P2)
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\docs276-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\docs276-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('DOCS276 ' + $i + ' steps')
