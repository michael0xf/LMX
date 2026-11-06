try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. land289 by lmxtool commands only (Codex, CODEX-OPUS-288-REVIEW-NEXT-20261106-01: no PS filter): the stage
# of the passed whole boot151<TP_TRY> against the source manifest source-tp151-<TP_SRC>; the bootstrap's stage manifest and
# the two generations' consumed inputs equal; the stage holds G2's consumed bytes; the 220-line inputs list and the sources
# copied into selfbuild; its manifest written, verified and equal to the source manifest. The working tool of the passed
# whole (its sha256 TP_TOOLSHA, read from the check record) runs every step.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$try=$env:TP_TRY; $src=$env:TP_SRC; $toolSha=$env:TP_TOOLSHA
if (-not $try -or -not $src -or -not $toolSha) { throw 'parameters TP_TRY TP_SRC TP_TOOLSHA' }
$stage="$P2/cold-boot151$try"
$Q="$stage/quick151$try"
$source="$P2/pins/source-tp151-$src.sha256"
$tool="$p\cold-boot151$try\quick151$try\lmxtool.exe"
$term="$p\pins\land289.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne $toolSha.ToUpperInvariant()) { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
function Step([string]$nn, [string[]]$words) {
  $cwd="$p\land289-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($words -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @words *> "$p\pins\land289-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Step '01' @('verify', $source, $stage)
Step '02' @('same', $source, "$P2/pins/source-boot151$try.sha256")
Step '03' @('same', "$Q/g1/consumed-inputs.sha256", "$Q/g2/consumed-inputs.sha256")
Step '04' @('verify', "$Q/g2/consumed-inputs.sha256", $stage)
Copy-Item -LiteralPath "$p\variants\tp151\inputs.list" -Destination 'C:\Nyasha_Planet\LMX\selfbuild\inputs.list' -Force
Step '05' @('same', "$P2/variants/tp151/inputs.list", "$repo/selfbuild/inputs.list")
Step '06' @('stage-copy', $source, $stage, "$repo/selfbuild")
Step '07' @('manifest', "$repo/selfbuild/inputs.list", "$repo/selfbuild", "$repo/selfbuild/inputs.sha256")
Step '08' @('verify', "$repo/selfbuild/inputs.sha256", "$repo/selfbuild")
Step '09' @('same', "$repo/selfbuild/inputs.sha256", $source)
Write-Output 'LAND289 9 steps'
