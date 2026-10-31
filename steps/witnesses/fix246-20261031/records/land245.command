try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Landing of the boot89-tested source package into the tracked selfbuild/
# (Codex CODEX-OPUS-245LAND-20261031-ANSWER, choice B). The exact 159 inputs
# bound by source-boot89.sha256 (9A5C12AC...) are verified in cold-boot89 and
# stage-copied over selfbuild/ (same path list); the package manifest is
# rewritten by the ordinary manifest command and verified, and the 65 sources
# that G1 and G2 retained in their consumed-input snapshots are verified
# against the landed files. Tool: the promoted working tool of boot89
# (G2's, 7FD2E824), fresh private CWDs. No compiler or test pipeline runs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot89\quick89\lmxtool.exe"
$term="$p\pins\land245.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne '7FD2E82475B24425B3FFDFC295CE2AC33F9529A4275D11423F57B78380714678') { throw 'tool hash' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath "$p\pins\source-boot89.sha256").Hash -ne '9A5C12AC46199B8038F39496846D4B3D91113C2CF838D601468648EB810C5FA5') { throw 'source manifest hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('verify', "$P2/pins/source-boot89.sha256", "$P2/cold-boot89")
  ,@('stage-copy', "$P2/pins/source-boot89.sha256", "$P2/cold-boot89", "$repo/selfbuild")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
  ,@('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land245-g1-consumed-sources.sha256", "$repo/selfbuild")
  ,@('verify', "$P2/pins/land245-g2-consumed-sources.sha256", "$repo/selfbuild")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\land245-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($s -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @s *> "$p\pins\land245-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=(Get-FileHash -Algorithm SHA256 -LiteralPath "$repo/selfbuild/inputs.sha256").Hash
$same = ($a -eq '9A5C12AC46199B8038F39496846D4B3D91113C2CF838D601468648EB810C5FA5')
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " selfbuild/inputs.sha256 $a equals source-boot89.sha256: $same") -Encoding utf8
if (-not $same) { throw 'package manifest differs from source-boot89.sha256' }
Write-Output ('LAND245 ' + $i + ' steps')
