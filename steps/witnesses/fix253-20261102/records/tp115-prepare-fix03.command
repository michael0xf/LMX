try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 fix03 (fable_pc): boot115b's G1 runtime step translated every kernel module and the driver and failed their C compile
# (driver.c:2184: assignment to 'Lmx **' from 'void **', -Werror=incompatible-pointer-types): in lmx_range.lm2 a cast to
# `@@: Lmx` is rendered `void **` by the translator, so `entry\slot_owner: (cast: (@@: Lmx) c.calloc(...))` kept the field
# untyped. Every double-pointer cast of the new code now spells the C-door type (`(cast: (@@: c.Lmx) ...)`,
# `(cast: (@@: c.LmxCodeLink) ...)`, `(cast: (@: c.LmxCodeLink) ...)`), as the driver's own casts do. The stage cold-tp115
# takes the 19 files again from the variant (stage-copy over the existing stage), and tp115-changed.sha256 /
# source-tp115.sha256 are recomputed and verified. Working tool 6619A503 (boot114's G2), fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$R='C:/Nyasha_Planet/LMX'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\tp115-prepare-fix03.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp115")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
foreach ($g in @("$p\cold-tp115\rt115", "$p\cold-tp115\src\l2src\l2_frontend_state.lm1")) { if (Test-Path -LiteralPath $g) { throw ('must be absent: ' + $g) } }
if (-not (Test-Path -LiteralPath "$p\cold-tp115\tool115\lmxtool-tool.exe")) { throw 'tool115 missing (its recipe source is unchanged by fix02)' }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' before: changed ' + (ShaTp "$p\pins\tp115-changed.sha256") + ' source-tp115 ' + (ShaTp "$p\pins\source-tp115.sha256")) -Encoding utf8
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp115-changed.list", "$P2/variants/tp115", "$P2/pins/tp115-changed.sha256")
  ,@('stage-copy', "$P2/pins/tp115-changed.sha256", "$P2/variants/tp115", "$P2/cold-tp115")
  ,@('manifest', "$R/selfbuild/inputs.list", "$P2/cold-tp115", "$P2/pins/source-tp115.sha256")
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp115-prepare-fix03-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp115-prepare-fix03-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
$a=@(Get-Content -LiteralPath "$R/selfbuild/inputs.sha256")
$b=@(Get-Content -LiteralPath "$p\pins\source-tp115.sha256")
$d=@(Compare-Object -ReferenceObject $a -DifferenceObject $b)
if ($d.Count -ne 38) { throw ('manifest differences ' + $d.Count) }
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' after: changed ' + (ShaTp "$p\pins\tp115-changed.sha256") + ' source-tp115 ' + (ShaTp "$p\pins\source-tp115.sha256") + ' arena_refs.lm2 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx_arena_refs.lm2") + ' range.lm2 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx_range.lm2")) -Encoding utf8
Write-Output ('FIX01 ' + $i + ' steps')
