try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp112 (fable_pc, S3 = the contract index behind lm_compiler_contract_source_node (resolve writes, context reads), the
# own-name index behind the six own lookups (context), own_free bumping l2_own_gen and machine_validate testing the
# name first (core), 24 state cells (tools/build.lm2); types, intern, values, views as in tp111). Stage cold-tp112 =
# source-full100 with the eight tp112 files over it, plus the 234 generated inputs the frontend part build reuses, all
# taken from cold-tp111 (230 G1 files verified there, fe110's types/intern L1 and fe111's values/views L1). Frozen tool
# E8150E60, manifest/stage-copy/verify only, every tool run from a fresh CWD.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-full100\full100\lmxtool.exe"
$term="$p\pins\tp112-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-tp112") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne 'e8150e6005beaf7929c014c712602a8d09dfa6fde9f93aaeefc54df25a5dfca0') { throw 'tool hash' }
if ((ShaTp "$p\pins\source-full100.sha256") -ne 'aa84116779f5fcae9c25f551af1a2929fa8282e55129b6f9de7cb81945891d8e') { throw 'source-full100 manifest hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp111-frontend-part.terminal.txt" -Pattern 'PartExit 0' -Quiet)) { throw 'fe111 not built' }
foreach ($f in @('l2_frontend_types','l2_frontend_intern','l2_frontend_values','l2_frontend_views')) { if (-not (Test-Path -LiteralPath "$p\cold-tp111\src\l2src\$f.lm1")) { throw "reused L1 missing: $f.lm1" } }
if ((ShaTp "$p\cold-tp111\src\l2src\l2_frontend_types.lm1") -ne 'edf97255c3cef3f754f8ee39aa47e772ef2b4e5ea5be79cbeb3975db8ed63f36') { throw 'types.lm1 is not fe110 output' }
if ((ShaTp "$p\cold-tp111\src\l2src\l2_frontend_intern.lm1") -ne '0992ab7c59ca1701e91526caf11c617a268be6aaf18cd4714890e40b10f85585') { throw 'intern.lm1 is not fe110 output' }
if ((ShaTp "$p\cold-tp111\src\l2src\l2_frontend_values.lm1") -ne '60ce51d295aff0bc677ac09046fed6824a12f397a98e728a1f9605387aceadb0') { throw 'values.lm1 is not fe111 output' }
if ((ShaTp "$p\cold-tp111\src\l2src\l2_frontend_views.lm1") -ne '4e3f42123663f2773d49d4b9e7a5b72d635008c78213ab5db098bfa35d4ad25a') { throw 'views.lm1 is not fe111 output' }
$steps=@(
  ,@('manifest', "$P2/pins/tp112-changed.list", "$P2/variants/tp112", "$P2/pins/tp112-changed.sha256")
  ,@('stage-copy', "$P2/pins/source-full100.sha256", "$P2/cold-full100", "$P2/cold-tp112")
  ,@('stage-copy', "$P2/pins/tp112-changed.sha256", "$P2/variants/tp112", "$P2/cold-tp112")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp112", "$P2/pins/source-tp112.sha256")
  ,@('manifest', "$P2/pins/tp112-reuse.list", "$P2/cold-tp111", "$P2/pins/tp112-reuse-inputs.sha256")
  ,@('stage-copy', "$P2/pins/tp112-reuse-inputs.sha256", "$P2/cold-tp111", "$P2/cold-tp112")
  ,@('manifest', "$P2/pins/tp112-reuse.list", "$P2/cold-tp112", "$P2/pins/tp112-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-tp112.sha256", "$P2/cold-tp112")
  ,@('verify', "$P2/pins/tp112-reuse-inputs.sha256", "$P2/cold-tp112")
  ,@('verify', "$P2/pins/tp112-reuse-artifacts.sha256", "$P2/cold-tp112")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp112-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp112-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
# Exactly eight lines of the 159 differ from source-full100: types, intern, values, views, context, resolve, core, build.
$a=@(Get-Content -LiteralPath "$p\pins\source-full100.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp112.sha256")
if ($a.Count -ne 159 -or $b.Count -ne 159) { throw ('manifest lines ' + $a.Count + ' ' + $b.Count) }
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
$d | ForEach-Object { Add-Content -LiteralPath $term -Value ($_.SideIndicator + ' ' + $_.InputObject) -Encoding utf8 }
if ($d.Count -ne 16) { throw ('manifest differences ' + $d.Count) }
$ok=@('src/l2src/l2_frontend_types.lm2','src/l2src/l2_frontend_intern.lm2','src/l2src/l2_frontend_values.lm2','src/l2src/l2_frontend_views.lm2','src/l2src/l2_frontend_context.lm2','src/l2src/l2_frontend_resolve.lm2','src/l2src/l2_frontend_core.lm2','tools/build.lm2')
foreach ($x in $d) { $hit=$false; foreach ($o in $ok) { if ($x.InputObject -like ('*  ' + $o)) { $hit=$true } }; if (-not $hit) { throw ('unexpected difference: ' + $x.InputObject) } }
# the reuse manifests are one and the same content (230 G1 files + fe110's two + fe111's two), and the regenerated files are absent
$ri=@(Get-Content -LiteralPath "$p\pins\tp112-reuse-inputs.sha256"); $ra=@(Get-Content -LiteralPath "$p\pins\tp112-reuse-artifacts.sha256")
if ($ri.Count -ne 234 -or $ra.Count -ne 234) { throw ('reuse manifest lines ' + $ri.Count + ' ' + $ra.Count) }
if (@(Compare-Object -ReferenceObject $ri -DifferenceObject $ra).Count -ne 0) { throw 'reuse manifests differ' }
foreach ($g in @("$p\cold-tp112\src\l2src\l2_frontend_context.lm1", "$p\cold-tp112\src\l2src\l2_frontend_resolve.lm1", "$p\cold-tp112\src\l2src\l2_frontend_core.lm1", "$p\cold-tp112\src\l2src\l2_frontend_state.lm1", "$p\cold-tp112\tool112", "$p\cold-tp112\fe112")) {
  if (Test-Path -LiteralPath $g) { throw ('must be absent before the builds: ' + $g) }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' source-tp112 ' + (ShaTp "$p\pins\source-tp112.sha256") + ' changed ' + (ShaTp "$p\pins\tp112-changed.sha256") + ' reuse-inputs ' + (ShaTp "$p\pins\tp112-reuse-inputs.sha256") + ' reuse-artifacts ' + (ShaTp "$p\pins\tp112-reuse-artifacts.sha256")) -Encoding utf8
Write-Output ('PREPARED ' + $i + ' steps')
