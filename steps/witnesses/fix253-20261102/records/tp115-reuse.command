try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 reuse (fable_pc): the 232 generated inputs the previous candidates' stages carried (the names of tp114-reuse.list:
# headers/, the generated src/l1src and src/l2src .lm1/.h.lm1 of the landed generation) are taken from boot114's stage
# cold-boot114 -- the landed source-tp114 built by the bootstrap (G1 = G2) -- into cold-tp115, so that the standalone
# translations of the frontend modules see their predefs and the tool build (rebuild tool against boot114's G2 runtime)
# compiles against the headers of that runtime. They are the previous generation's text: the kernel headers among them
# predate tp115 and are rewritten by the first runtime build of the candidate (decls_write_all, bld_headers). Working tool
# 6619A503, manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\tp115-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp115")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp115-reuse.list") -ne (ShaTp "$p\pins\tp114-reuse.list")) { throw 'tp115-reuse.list is not the names of tp114-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-prepare-fix01.terminal.txt" -Pattern ' 04 exit=0 verify ' -Quiet)) { throw 'stage fix01 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp115\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp115-reuse.list", "$P2/cold-boot114", "$P2/pins/tp115-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp115-reuse-inputs.sha256", "$P2/cold-boot114", "$P2/cold-tp115")
  ,@('manifest', "$P2/pins/tp115-reuse.list", "$P2/cold-tp115", "$P2/pins/tp115-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp115-reuse-inputs.sha256", "$P2/cold-tp115")
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp115-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp115-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp115-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp115-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp115\src\l2src\l2_frontend_state.lm1", "$p\cold-tp115\src\l2src\lmxtool_methods.lm1", "$p\cold-tp115\tool115")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp115-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp115-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
