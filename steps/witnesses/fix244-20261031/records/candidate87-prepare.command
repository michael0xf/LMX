try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Stage87 = source85b (stage85 with the RT85b walker) with ONE source replaced:
# variants/coherent85 Lower87 -- draft79's lm_compiler_own_work_store_value
# filled the working-value name `wv` for every type and again in the pointer
# branch, so the pointer case emitted `l2_wvK_<n>l2_wvK_<n>` (FE85 + RT85b:
# held78 p.c:1128 and owner73c lib_m CC `undeclared`); the second fill is gone.
# Body-only: Lower's declarations do not change. Reuse: the 80b-era set of
# chain85 (from cold-candidate80b) plus FE85's Useplan/Core/Emit sources and
# outputs (from cold-candidate85); invariants = the 85 set plus those outputs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\candidate87-prepare.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath "$p\cold-candidate87") { throw 'stageexists' }
if (Test-Path -LiteralPath $term) { throw 'prepareterminalexists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/candidate87-frontend.list", "$P2/variants/coherent85", "$P2/pins/candidate87-frontend.sha256")
  ,@('verify', "$P2/pins/source-candidate85b.sha256", "$P2/cold-candidate85")
  ,@('stage-copy', "$P2/pins/source-candidate85b.sha256", "$P2/cold-candidate85", "$P2/cold-candidate87")
  ,@('stage-copy', "$P2/pins/candidate87-frontend.sha256", "$P2/variants/coherent85", "$P2/cold-candidate87")
  ,@('manifest', "$repo/selfbuild/inputs.list", "$P2/cold-candidate87", "$P2/pins/source-candidate87.sha256")
  ,@('manifest', "$P2/pins/candidate87-reuse80b.list", "$P2/cold-candidate80b", "$P2/pins/candidate87-reuse80b.sha256")
  ,@('manifest', "$P2/pins/candidate87-reuse85.list", "$P2/cold-candidate85", "$P2/pins/candidate87-reuse85.sha256")
  ,@('stage-copy', "$P2/pins/candidate87-reuse80b.sha256", "$P2/cold-candidate80b", "$P2/cold-candidate87")
  ,@('stage-copy', "$P2/pins/candidate87-reuse85.sha256", "$P2/cold-candidate85", "$P2/cold-candidate87")
  ,@('manifest', "$P2/pins/candidate87-reuse-inputs.list", "$P2/cold-candidate87", "$P2/pins/candidate87-reuse-inputs.sha256")
  ,@('manifest', "$P2/pins/candidate87-reuse-artifacts.list", "$P2/cold-candidate87", "$P2/pins/candidate87-reuse-artifacts.sha256")
  ,@('verify', "$P2/pins/source-candidate87.sha256", "$P2/cold-candidate87")
  ,@('verify', "$P2/pins/candidate87-reuse-inputs.sha256", "$P2/cold-candidate87")
  ,@('verify', "$P2/pins/candidate87-reuse-artifacts.sha256", "$P2/cold-candidate87")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\candidate87-prepare-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\candidate87-prepare-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Write-Output ('PREPARED ' + $i + ' steps')
