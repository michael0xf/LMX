try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 289. docs289 binds the slice record's originals: the evidence manifest of the P paths the record's evidence.list
# names, then its check against P and against the record's copies, with the working tool of the passed whole (TP_TRY names
# boot151<try>, TP_TOOLSHA its working tool's sha256). TP_RUN labels the run: 1 after the first archive pass (before the docs
# check), 2 after the second (the list then holds both passes).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$repo='C:/Nyasha_Planet/LMX'
$w="$repo/steps/witnesses/fix289-20261106"
$try=$env:TP_TRY; $toolSha=$env:TP_TOOLSHA; $runLabel=$env:TP_RUN
if (-not $try -or -not $toolSha -or -not $runLabel) { throw 'parameters TP_TRY TP_TOOLSHA TP_RUN' }
$tool="$p\cold-boot151$try\quick151$try\lmxtool.exe"
$term="$p\pins\docs289-$runLabel.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (Test-Path -LiteralPath $term) { throw 'terminalexists' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tool).Hash -ne $toolSha.ToUpperInvariant()) { throw 'tool hash' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
function Step([string]$nn, [string[]]$words) {
  $cwd="$p\docs289-$runLabel-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn start " + ($words -join ' ')) -Encoding utf8
  & $tool 0 entry 0 -- @words *> "$p\pins\docs289-$runLabel-$nn.log"
  $e=$LASTEXITCODE
  Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + " $nn exit=$e") -Encoding utf8
  if ($e -ne 0) { throw "step $nn exit $e" }
}
Step '01' @('manifest', "$w/evidence.list", $P2, "$w/evidence.sha256")
Step '02' @('verify', "$w/evidence.sha256", $P2)
Step '03' @('verify', "$w/evidence.sha256", "$w/records")
Write-Output ('DOCS289 run ' + $runLabel)
