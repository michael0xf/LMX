try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 275. Seeds the working stage cold-tp137 and the candidate tree variants/tp137 from the published selfbuild 274
# with the verified boot136a tool, and reuses the 232 named generated support paths of boot136a (the names of tp133-reuse.list).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot136a\quick136a\lmxtool.exe"
$term="$p\pins\tp137-seed.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Test-Path -LiteralPath "$p\cold-tp137") -or (Test-Path -LiteralPath "$p\variants\tp137")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e3310451333d8016c93adf41507eadd3c2ef4b8c5db6ae52d9d9cca809faa340') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne 'c1dc96bba7fce6ce11057f36e078d7522f9278736c2296fb5b3af0f546877c04') { throw 'selfbuild inputs manifest is not source274' }
[IO.File]::WriteAllText("$p\pins\tp137-inputs-list.list", "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/variants/tp137")
  ,@('manifest', "$P2/pins/tp137-inputs-list.list", "$R/selfbuild", "$P2/pins/tp137-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/tp137-inputs-list.sha256", "$R/selfbuild", "$P2/variants/tp137")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp137")
  ,@('manifest', "$P2/pins/tp133-reuse.list", "$P2/cold-boot136a", "$P2/pins/tp137-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp137-reuse-inputs.sha256", "$P2/cold-boot136a", "$P2/cold-tp137")
  ,@('verify', "$P2/pins/tp137-reuse-inputs.sha256", "$P2/cold-tp137")
  ,@('verify', "$R/selfbuild/inputs.sha256", "$P2/cold-tp137")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp137-seed-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp137-seed-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('SEEDED ' + $i + ' steps')
