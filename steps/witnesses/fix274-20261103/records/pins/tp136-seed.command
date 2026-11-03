try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 274. Seeds the working stage cold-tp136 and the candidate tree variants/tp136 from the published selfbuild 273
# with the verified boot135a tool, and reuses the 232 named generated support paths of boot135a (the names of tp133-reuse.list).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot135a\quick135a\lmxtool.exe"
$term="$p\pins\tp136-seed.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Test-Path -LiteralPath "$p\cold-tp136") -or (Test-Path -LiteralPath "$p\variants\tp136")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'edbba01de59e68f74038d6c67cd5d3d618357159189554c5c2f7011c19c307c2') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '985904fd0bf0d09b9011fd9b9c594484c3d1ede2474c489becfe16336ac16378') { throw 'selfbuild inputs manifest is not source273' }
[IO.File]::WriteAllText("$p\pins\tp136-inputs-list.list", "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/variants/tp136")
  ,@('manifest', "$P2/pins/tp136-inputs-list.list", "$R/selfbuild", "$P2/pins/tp136-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/tp136-inputs-list.sha256", "$R/selfbuild", "$P2/variants/tp136")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp136")
  ,@('manifest', "$P2/pins/tp133-reuse.list", "$P2/cold-boot135a", "$P2/pins/tp136-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp136-reuse-inputs.sha256", "$P2/cold-boot135a", "$P2/cold-tp136")
  ,@('verify', "$P2/pins/tp136-reuse-inputs.sha256", "$P2/cold-tp136")
  ,@('verify', "$R/selfbuild/inputs.sha256", "$P2/cold-tp136")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp136-seed-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp136-seed-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('SEEDED ' + $i + ' steps')
