try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 headers after fix05 (fable_pc): boot115e's G1 runtime step wrote the fix05 kernel declaration headers (decls_write_all
# of tool115e's recipe, `HEADERS 37 regenerated`) before it refused lmx_range.lm2:944 (a path actual; fix06). Exactly two of
# the 72 `.h.lm1` of cold-boot115e/src/l2src differ from the copies staged in cold-tp115 by tp115-headers (boot115's G1):
# lmx.h.lm1 (LmxCodeLink `mark`/`work`, LmxRange `kind`) and lmx_arena.h.lm1 (LmxArena `reset_gen`, the lmx_range exports
# link_prepare/link_commit/link_abandon). They are staged over cold-tp115's copies (pins/tp115-headers-fix05.list), so the
# standalone translations of the fix05/fix06 modules see the fix05 declarations. G1 outputs of this candidate, no source
# among them. Working tool 6619A503, manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\tp115-headers-fix05.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp115")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot115e-quick.log" -Pattern '^HEADERS 37 regenerated' -Quiet)) { throw 'boot115e G1 did not write the headers' }
$names=@(Get-Content -LiteralPath "$p\pins\tp115-headers-fix05.list")
if ($names.Count -ne 2) { throw ('headers list lines ' + $names.Count) }
$inputs=@(Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/selfbuild/inputs.list')
foreach ($n in $names) { if ($inputs -contains $n) { throw ('a source in the headers list: ' + $n) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp115-headers-fix05.list", "$P2/cold-boot115e", "$P2/pins/tp115-headers-fix05.sha256")
  ,@('stage-copy', "$P2/pins/tp115-headers-fix05.sha256", "$P2/cold-boot115e", "$P2/cold-tp115")
  ,@('verify', "$P2/pins/tp115-headers-fix05.sha256", "$P2/cold-tp115")
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp115-headers-fix05-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp115-headers-fix05-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' headers ' + (ShaTp "$p\pins\tp115-headers-fix05.sha256") + ' lmx.h.lm1 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx.h.lm1") + ' lmx_arena.h.lm1 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx_arena.h.lm1")) -Encoding utf8
Write-Output ('HEADERS-FIX05 ' + $i + ' steps')
