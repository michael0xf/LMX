try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. One pass of copying the slice record's originals by lmxtool commands only (no PS text processing): the
# manifest of the P paths the hand-written list pins/evidence289-<TP_PASS>.list names, its check against P, then `stage-copy` of
# exactly those files into the record's records directory, each copy's hash verified, and the copies checked again. The
# copies hold the originals' bytes; git keeps text LF in its index. Pass 1 before the docs check, pass 2 for its receipts.
# Parameters TP_PASS, TP_TRY (the passed whole boot151<TP_TRY>), TP_TOOLSHA (its working tool's sha256).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$w="$repo/steps/witnesses/fix289-20261106"
$pass=$env:TP_PASS; $try=$env:TP_TRY; $toolSha=$env:TP_TOOLSHA
if (-not $pass -or -not $try -or -not $toolSha) { throw 'parameters TP_PASS TP_TRY TP_TOOLSHA' }
$tool="$p\cold-boot151$try\quick151$try\lmxtool.exe"
$list="$P2/pins/evidence289-$pass.list"
$man="$P2/pins/evidence289-$pass.sha256"
$term="$p\pins\docs289-archive-$pass.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath ($man -replace '/','\'))) { throw 'exists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne $toolSha.ToUpperInvariant()) { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
function Step([string]$nn, [string[]]$words) {
  $cwd="$p\docs289-archive-$pass-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($words -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @words *> "$p\pins\docs289-archive-$pass-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Step '01' @('manifest', $list, $P2, $man)
Step '02' @('verify', $man, $P2)
Step '03' @('stage-copy', $man, $P2, "$w/records")
Step '04' @('verify', $man, "$w/records")
Write-Output ('DOCS289ARCHIVE pass ' + $pass)
