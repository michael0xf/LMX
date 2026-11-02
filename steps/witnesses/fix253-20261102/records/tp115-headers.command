try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 headers (fable_pc): the kernel declaration headers tool115's recipe wrote in boot115's G1 runtime step (decls_write_all:
# lmx.h.lm1 with LmxCodeLink and the LmxRange side fields, lmx_arena.h.lm1 with the lmx_range exports, the other 35) and the
# generated headers of the modules that step and the G1 frontend step translated -- the 82 `.h.lm1`/l1src `.lm1` of
# cold-boot115/src (pins/tp115-headers.list) -- are staged over the previous generation's copies in cold-tp115, so that the
# standalone translations of the kernel modules see the tp115 headers (the first boot115 run stopped at lmx_arena_refs:515, a
# path actual typed unknown; the refusal reproduces standalone only with these headers). They are this candidate's own G1
# outputs, no source among them. Working tool 6619A503, manifest/stage-copy/verify only, fresh CWDs.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-boot114\quick114\lmxtool.exe"
$term="$p\pins\tp115-headers.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath "$p\cold-tp115")) { throw 'stage missing' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $tool) -ne '6619a5036e02987fcd7d88bcf25029398f93c0c94b981d5d47eb48ba6f2a8027') { throw 'tool hash' }
if (-not (Select-String -LiteralPath "$p\pins\boot115-quick.log" -Pattern '^HEADERS 37 regenerated' -Quiet)) { throw 'boot115 G1 did not write the headers' }
$names=@(Get-Content -LiteralPath "$p\pins\tp115-headers.list")
if ($names.Count -ne 82) { throw ('headers list lines ' + $names.Count) }
$inputs=@(Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/selfbuild/inputs.list')
foreach ($n in $names) { if ($inputs -contains $n) { throw ('a source in the headers list: ' + $n) } }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
$steps = @(
  ,@('manifest', "$P2/pins/tp115-headers.list", "$P2/cold-boot115", "$P2/pins/tp115-headers.sha256")
  ,@('stage-copy', "$P2/pins/tp115-headers.sha256", "$P2/cold-boot115", "$P2/cold-tp115")
  ,@('verify', "$P2/pins/tp115-headers.sha256", "$P2/cold-tp115")
  ,@('verify', "$P2/pins/source-tp115.sha256", "$P2/cold-tp115")
)
$i=0
foreach ($s in $steps) {
  $i++
  $nn='{0:D2}' -f $i
  $cwd="$p\tp115-headers-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @s *> "$p\pins\tp115-headers-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e " + ($s -join ' ')) -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' headers ' + (ShaTp "$p\pins\tp115-headers.sha256") + ' lmx.h.lm1 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx.h.lm1") + ' lmx_arena.h.lm1 ' + (ShaTp "$p\cold-tp115\src\l2src\lmx_arena.h.lm1")) -Encoding utf8
Write-Output ('HEADERS ' + $i + ' steps')
