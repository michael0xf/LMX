try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp120 reuse (fable_pc): the 232 generated inputs the previous candidates' stages carried (the names of tp120-reuse.list =
# tp120-reuse.list: headers/, the generated src/l1src and src/l2src .lm1/.h.lm1 of the landed generation) are taken from
# boot119a's stage cold-boot119a -- the landed source-tp120 built by the bootstrap (G1 = G2) -- into cold-tp120, so that the
# isolated builds see their predefs.  They are the previous generation's text: the kernel headers among them predate tp120 and
# are rewritten by the first runtime build of the candidate (decls_write_all, bld_headers).  Working tool 64AE29A0 (boot119a's
# G2), manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot119a\quick119a\lmxtool.exe"
$term="$p\pins\tp120-reuse.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp120")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '64ae29a0d4e8b2ee22eec82724bcc410c4a4ffce906650698b9be52ccc660d01') { throw 'tool hash' }
if ((ShaTp "$p\pins\tp120-reuse.list") -ne (ShaTp "$p\pins\tp119-reuse.list")) { throw 'tp120-reuse.list is not the names of tp119-reuse.list' }
if (-not (Select-String -LiteralPath "$p\pins\tp120-prepare.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'stage tp120 not verified' }
if (Test-Path -LiteralPath "$p\cold-tp120\headers") { throw 'generated inputs already staged' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp120-reuse.list", "$P2/cold-boot119a", "$P2/pins/tp120-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp120-reuse-inputs.sha256", "$P2/cold-boot119a", "$P2/cold-tp120")
  ,@('manifest', "$P2/pins/tp120-reuse.list", "$P2/cold-tp120", "$P2/pins/tp120-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/tp120-reuse-inputs.sha256", "$P2/cold-tp120")
  ,@('verify', "$P2/pins/source-tp120.sha256", "$P2/cold-tp120")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp120-reuse-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp120-reuse-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$ri=@(Get-Content -LiteralPath "$p\pins\tp120-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp120-reuse-artifacts.sha256")
if ($ri.Count -ne 232 -or $ra.Count -ne 232) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp120\src\l2src\l2_frontend_state.lm1", "$p\cold-tp120\src\l2src\lmxtool_methods.lm1")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' reuse-inputs ' + (ShaTp "$p\pins\tp120-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp120-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('REUSE ' + $i + ' steps')
