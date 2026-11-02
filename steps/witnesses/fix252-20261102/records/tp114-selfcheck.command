try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp114 (fable_pc, S3c): standalone translation of one patched frontend module by fe113 before the long builds -- the
# argv of G1's record line for that module (found by the module's output path) with the input .lm2 taken from the
# stage cold-tp114 (the patched source) and the two outputs written to a private directory; CWD = the stage's src so
# predef paths resolve as in a build. Reported: exit, wall, the header's SHA-256 against G1's `out` (it must be
# byte-identical: no export changes) and the body's SHA-256. Parameters: TP_MODULE (stem), TP_TRY.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$module=$env:TP_MODULE; $try=$env:TP_TRY
if (-not $module -or -not $try) { throw 'parameters TP_MODULE TP_TRY' }
$fe="$p\cold-tp113\fe113\l2trans.exe"
$rec="$p\cold-full100\full100\g1\frontend\record.txt"
$out="$p\tp114-selfcheck\$module-$try"
$cwd="$p\cold-tp114\src"
$term="$p\pins\tp114-selfcheck-$module-$try.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminal exists' }
if (Test-Path -LiteralPath $out) { throw "exists $out" }
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $fe) -ne '6038f156b6cca0a2d0ca13a7f1b9c1f782be0f7b1124ab0d0126b7f5bbabd70e') { throw 'fe113 hash' }
if ((ShaTp $rec) -ne '246272153bdb0ca9f534e29b7d11ba8bcc2eedd0e4e6171c8b80eaeb05c2eddf') { throw 'record hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp114-prepare.terminal.txt" -Pattern ' 10 exit=0 verify ' -Quiet)) { throw 'tp114 stage not prepared' }
$lines=@(Get-Content -LiteralPath $rec)
$line=0
for ($k=0; $k -lt $lines.Count; $k++) { if ($lines[$k].StartsWith('$ ') -and $lines[$k].EndsWith("/cold-full100/src/l2src/$module.lm1")) { $line=$k+1; break } }
if ($line -eq 0) { throw "no record step for $module" }
$tok=$lines[$line-1] -split ' '
if ($tok[2] -ne '--library' -or $tok[$tok.Count-6] -ne '--header') { throw "record line $line shape" }
$g1=@{}
for ($i=$line; $i -lt $lines.Count -and -not $lines[$i].StartsWith('$ '); $i++) { if ($lines[$i] -cmatch '^  out ([0-9a-f]{64}) (\S+)$') { $g1[[IO.Path]::GetFileName($Matches[2])]=$Matches[1] } }
if ($g1.Count -ne 2) { throw ('expected two outputs in the record, found ' + $g1.Count) }
$argv=@($tok[2..($tok.Count-1)])
$inIdx=-1
for ($k=0; $k -lt $argv.Count; $k++) { if ($argv[$k] -eq "$P2/cold-full100/src/l2src/$module.lm2") { $inIdx=$k } }
if ($inIdx -lt 0) { throw 'input path not found in argv' }
$argv[$inIdx]="$P2/cold-tp114/src/l2src/$module.lm2"
if ((ShaTp "$p\cold-tp114\src\l2src\$module.lm2") -eq (ShaTp "$p\cold-full100\src\l2src\$module.lm2")) { throw 'the stage module is not patched' }
$argv[$argv.Count-5]="$P2/tp114-selfcheck/$module-$try/$module.h.lm1"
$argv[$argv.Count-1]="$P2/tp114-selfcheck/$module-$try/$module.lm1"
New-Item -ItemType Directory -Path $out | Out-Null
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' module ' + $module + ' record-line ' + $line + ' input ' + (ShaTp "$p\cold-tp114\src\l2src\$module.lm2") + ' cwd ' + $cwd) -Encoding utf8
$proc=Start-Process -FilePath $fe -ArgumentList $argv -WorkingDirectory $cwd -RedirectStandardOutput "$out\stdout.txt" -RedirectStandardError "$out\stderr.txt" -NoNewWindow -PassThru
$hnd=$proc.Handle
$proc.WaitForExit()
Add-Content -LiteralPath $term -Value ('exit ' + $proc.ExitCode + ' wall_s ' + ($proc.ExitTime - $proc.StartTime).TotalSeconds.ToString('F1') + ' cpu_s ' + $proc.TotalProcessorTime.TotalSeconds.ToString('F1')) -Encoding utf8
foreach ($nm in @("$module.h.lm1", "$module.lm1")) {
  $f="$out\$nm"
  if (Test-Path -LiteralPath $f) { $h=ShaTp $f; $v='DIFF'; if ($h -eq $g1[$nm]) { $v='same-as-G1' }; Add-Content -LiteralPath $term -Value ('output ' + $nm + ' ' + $h + ' ' + $v + ' bytes ' + (Get-Item -LiteralPath $f).Length + ' g1 ' + $g1[$nm]) -Encoding utf8 }
  else { Add-Content -LiteralPath $term -Value ('output ' + $nm + ' MISSING g1 ' + $g1[$nm]) -Encoding utf8 }
}
$errBytes=(Get-Item -LiteralPath "$out\stderr.txt").Length
Add-Content -LiteralPath $term -Value ('stderr bytes ' + $errBytes) -Encoding utf8
if ($errBytes -gt 0) { Get-Content -LiteralPath "$out\stderr.txt" -TotalCount 12 | ForEach-Object { Add-Content -LiteralPath $term -Value ('  ' + $_) -Encoding utf8 } }
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Write-Output ('SELFCHECK ' + $module + ' exit ' + $proc.ExitCode)
