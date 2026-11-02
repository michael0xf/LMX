try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp115 (fable_pc, semantic step A): standalone translation of one patched module by boot114's G2 frontend before the long
# builds -- the argv of boot114's G1 record line for that module (TP_PART runtime: the kernel modules and the driver,
# g1/runtime/record.txt; frontend: the frontend modules, g1/frontend/record.txt), with the translator replaced by the G2
# l2trans, every stage path moved from cold-boot114 to cold-tp115 (the patched sources) and the outputs written to a private
# directory; CWD = the stage's src so predef paths resolve as in a build. Reported: exit, wall, the SHA-256 of each output
# against G1's `out` (a changed export list or body is expected here -- the point is a translation without refusal; the
# header of a module whose exports did not change must still be byte-identical). Parameters: TP_MODULE (stem), TP_TRY,
# TP_PART (runtime|frontend).
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$module=$env:TP_MODULE; $try=$env:TP_TRY; $part=$env:TP_PART
if (-not $module -or -not $try -or -not $part) { throw 'parameters TP_MODULE TP_TRY TP_PART' }
if ($part -ne 'runtime' -and $part -ne 'frontend') { throw 'TP_PART runtime|frontend' }
$fe="$p\cold-boot114\quick114\g2\frontend\l2trans.exe"
$rec="$p\cold-boot114\quick114\g1\$part\record.txt"
$out="$p\tp115-selfcheck\$module-$try"
$cwd="$p\cold-tp115\src"
$term="$p\pins\tp115-selfcheck-$module-$try.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminal exists' }
if (Test-Path -LiteralPath $out) { throw "exists $out" }
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $fe) -ne '17dfeea955facd7615002e45cf40995811d780739da300b04f7afa74dce72990') { throw 'G2 frontend hash' }
$recHash=@{ runtime='d5d3f730becffe91c5b401151ff2dfb1825b01ac8264b03213312c42f4ae1a56'; frontend='dae1e3e43fda14ab993f8a119f79eb75d2cc9f09dc6cc71e028881a6e0a5f6cb' }
if ((ShaTp $rec) -ne $recHash[$part]) { throw 'record hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp115-prepare.terminal.txt" -Pattern ' 06 exit=0 verify ' -Quiet)) { throw 'tp115 stage not prepared' }
$lines=@(Get-Content -LiteralPath $rec)
$line=0
for ($k=0; $k -lt $lines.Count; $k++) { if ($lines[$k].StartsWith('$ ') -and $lines[$k].EndsWith("/cold-boot114/src/l2src/$module.lm1")) { $line=$k+1; break } }
if ($line -eq 0) { throw "no record step for $module" }
$tok=$lines[$line-1] -split ' '
if ($tok[2] -ne '--library') { throw "record line $line shape" }
$g1=@{}
for ($i=$line; $i -lt $lines.Count -and -not $lines[$i].StartsWith('$ '); $i++) { if ($lines[$i] -cmatch '^  out ([0-9a-f]{64}) (\S+)$') { $g1[[IO.Path]::GetFileName($Matches[2])]=$Matches[1] } }
if ($g1.Count -lt 1) { throw 'no output in the record' }
$argv=@($tok[2..($tok.Count-1)])
$inIdx=-1
for ($k=0; $k -lt $argv.Count; $k++) { if ($argv[$k] -eq "$P2/cold-boot114/src/l2src/$module.lm2") { $inIdx=$k } }
if ($inIdx -lt 0) { throw 'input path not found in argv' }
if ((ShaTp "$p\cold-tp115\src\l2src\$module.lm2") -eq (ShaTp "$p\cold-boot114\src\l2src\$module.lm2")) { throw 'the stage module is not patched' }
for ($k=0; $k -lt $argv.Count; $k++) { $argv[$k]=$argv[$k].Replace("$P2/cold-boot114/src/", "$P2/cold-tp115/src/") }
$hIdx=-1
for ($k=0; $k -lt $argv.Count; $k++) { if ($argv[$k] -eq '--header') { $hIdx=$k } }
if ($hIdx -ge 0) { $argv[$hIdx+1]="$P2/tp115-selfcheck/$module-$try/$module.h.lm1" }
$argv[$argv.Count-1]="$P2/tp115-selfcheck/$module-$try/$module.lm1"
New-Item -ItemType Directory -Path $out | Out-Null
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' module ' + $module + ' part ' + $part + ' record-line ' + $line + ' header ' + ($hIdx -ge 0) + ' input ' + (ShaTp "$p\cold-tp115\src\l2src\$module.lm2") + ' cwd ' + $cwd) -Encoding utf8
Add-Content -LiteralPath $term -Value ('argv ' + ($argv -join ' ')) -Encoding utf8
$proc=Start-Process -FilePath $fe -ArgumentList $argv -WorkingDirectory $cwd -RedirectStandardOutput "$out\stdout.txt" -RedirectStandardError "$out\stderr.txt" -NoNewWindow -PassThru
$hnd=$proc.Handle
$proc.WaitForExit()
Add-Content -LiteralPath $term -Value ('exit ' + $proc.ExitCode + ' wall_s ' + ($proc.ExitTime - $proc.StartTime).TotalSeconds.ToString('F1') + ' cpu_s ' + $proc.TotalProcessorTime.TotalSeconds.ToString('F1')) -Encoding utf8
$names=@("$module.lm1")
if ($hIdx -ge 0) { $names=@("$module.h.lm1", "$module.lm1") }
foreach ($nm in $names) {
  $f="$out\$nm"
  if (Test-Path -LiteralPath $f) { $h=ShaTp $f; $v='DIFF'; if ($h -eq $g1[$nm]) { $v='same-as-G1' }; Add-Content -LiteralPath $term -Value ('output ' + $nm + ' ' + $h + ' ' + $v + ' bytes ' + (Get-Item -LiteralPath $f).Length + ' g1 ' + $g1[$nm]) -Encoding utf8 }
  else { Add-Content -LiteralPath $term -Value ('output ' + $nm + ' MISSING g1 ' + $g1[$nm]) -Encoding utf8 }
}
$errBytes=(Get-Item -LiteralPath "$out\stderr.txt").Length
Add-Content -LiteralPath $term -Value ('stderr bytes ' + $errBytes) -Encoding utf8
if ($errBytes -gt 0) { Get-Content -LiteralPath "$out\stderr.txt" -TotalCount 12 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_) -Encoding utf8 } }
$outBytes=(Get-Item -LiteralPath "$out\stdout.txt").Length
if ($outBytes -gt 0) { Get-Content -LiteralPath "$out\stdout.txt" -TotalCount 12 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  stdout: ' + $_) -Encoding utf8 } }
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Write-Output ('SELFCHECK ' + $module + ' exit ' + $proc.ExitCode)
