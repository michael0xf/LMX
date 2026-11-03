try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 272. Seeds the working stage cold-tp134 and the candidate tree variants/tp134 from the published selfbuild 271
# with the verified boot133a tool, and reuses the 232 named generated support paths of boot133a (the names of tp133-reuse.list).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot133a\quick133a\lmxtool.exe"
$term="$p\pins\tp134-seed.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Test-Path -LiteralPath "$p\cold-tp134") -or (Test-Path -LiteralPath "$p\variants\tp134")) { throw 'exists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '743fa9d478db1e18719140fd63a9e254b646ba28cd0762b9293470b2e2371850') { throw 'tool hash' }
if ((ShaTp "$R/selfbuild/inputs.sha256") -ne '66b15db1b3ba4543c11cf99cd49f27c10677302e45b97f0b756fa38f0c43b5c8') { throw 'selfbuild inputs manifest is not source271' }
[IO.File]::WriteAllText("$p\pins\tp134-inputs-list.list", "inputs.list`n", (New-Object System.Text.UTF8Encoding $false))
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps=@(
  ,@('verify', "$R/selfbuild/inputs.sha256", "$R/selfbuild")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/variants/tp134")
  ,@('manifest', "$P2/pins/tp134-inputs-list.list", "$R/selfbuild", "$P2/pins/tp134-inputs-list.sha256")
  ,@('stage-copy', "$P2/pins/tp134-inputs-list.sha256", "$R/selfbuild", "$P2/variants/tp134")
  ,@('stage-copy', "$R/selfbuild/inputs.sha256", "$R/selfbuild", "$P2/cold-tp134")
  ,@('manifest', "$P2/pins/tp133-reuse.list", "$P2/cold-boot133a", "$P2/pins/tp134-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp134-reuse-inputs.sha256", "$P2/cold-boot133a", "$P2/cold-tp134")
  ,@('verify', "$P2/pins/tp134-reuse-inputs.sha256", "$P2/cold-tp134")
  ,@('verify', "$R/selfbuild/inputs.sha256", "$P2/cold-tp134")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp134-seed-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp134-seed-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('SEEDED ' + $i + ' steps')
