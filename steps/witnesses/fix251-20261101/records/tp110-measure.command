try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# tp110 (fable_pc, S1, design 7): one measured L2->L1 translation of one frontend module by one frontend, from the private
# tree tp110-tree-01 (= G1 full100's stage as it stood before the emit step; manifest perf251-emit-tree-03-all.sha256,
# eddc401b), with the argv of G1's record line for that step (inputs = the stage's hash-pinned files, so the unit prefix is
# G1's) and the two outputs written into a private output directory instead of the tree. Measured: wall (process
# start/exit), CPU user/kernel (GetProcessTimes), peak working set and peak commit (GetProcessMemoryInfo after exit); then
# the outputs' SHA-256 against the `out` lines of the record (same-as-G1 or DIFF). Parameters (environment):
#   TP_MODULE  the module stem (l2_frontend_useplan | l2_frontend_lower | l2_frontend_core | l2_frontend_emit)
#   TP_LINE    the 1-based line of the step's `$` command in G1's frontend record (193 | 205 | 241 | 253)
#   TP_FE      the frontend executable to measure
#   TP_LABEL   its label in file names (g1 | fe110 | ...)
#   TP_TRY     the attempt number (01, 02, ...)
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$module=$env:TP_MODULE; $line=[int]$env:TP_LINE; $fe=$env:TP_FE; $label=$env:TP_LABEL; $try=$env:TP_TRY
if (-not $module -or $line -lt 1 -or -not $fe -or -not $label -or -not $try) { throw 'parameters TP_MODULE TP_LINE TP_FE TP_LABEL TP_TRY' }
$rec="$p\cold-full100\full100\g1\frontend\record.txt"
$tree='tp110-tree-01'
$name="tp110-measure-$module-$label-$try"
$out="$p\tp110-measure\$module-$label-$try"
$cwd="$p\$tree\src"
$term="$p\pins\$name.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminal exists' }
if (Test-Path -LiteralPath $out) { throw "exists $out" }
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
function ShaTp([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((ShaTp $rec) -ne '246272153bdb0ca9f534e29b7d11ba8bcc2eedd0e4e6171c8b80eaeb05c2eddf') { throw 'record hash' }
if (-not (Select-String -LiteralPath "$p\pins\tp110-tree-01-verify.log" -Pattern 'VERIFIED 211 files, 0 failed' -Quiet)) { throw 'tree not verified' }
$lines=@(Get-Content -LiteralPath $rec)
$cmd=$lines[$line-1]
$tok=$cmd -split ' '
if ($tok[0] -ne '$' -or $tok[2] -ne '--library' -or $tok[$tok.Count-1] -ne "$P2/cold-full100/src/l2src/$module.lm1" -or $tok[$tok.Count-6] -ne '--header' -or $tok[$tok.Count-5] -ne "$P2/cold-full100/src/l2src/$module.h.lm1") { throw "record line $line is not the $module step" }
# the record's input pins and expected outputs for this step
$g1=@{}
for ($i=$line; $i -lt $lines.Count -and -not $lines[$i].StartsWith('$ '); $i++) {
  $l=$lines[$i]
  if ($l -cmatch '^  in ([0-9a-f]{64}) (\S+)$') { if ((ShaTp $Matches[2]) -ne $Matches[1]) { throw ('input changed: ' + $Matches[2]) } }
  if ($l -cmatch '^  out ([0-9a-f]{64}) (\S+)$') { $g1[[IO.Path]::GetFileName($Matches[2])]=$Matches[1] }
}
if ($g1.Count -ne 2) { throw ('expected two outputs in the record, found ' + $g1.Count) }
$argv=@($tok[2..($tok.Count-1)])
$argv[$argv.Count-5]="$P2/tp110-measure/$module-$label-$try/$module.h.lm1"
$argv[$argv.Count-1]="$P2/tp110-measure/$module-$label-$try/$module.lm1"
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PerfMemTp110 {
  [StructLayout(LayoutKind.Sequential)]
  public struct PMC {
    public uint cb; public uint PageFaultCount; public UIntPtr PeakWorkingSetSize; public UIntPtr WorkingSetSize;
    public UIntPtr QuotaPeakPagedPoolUsage; public UIntPtr QuotaPagedPoolUsage; public UIntPtr QuotaPeakNonPagedPoolUsage;
    public UIntPtr QuotaNonPagedPoolUsage; public UIntPtr PagefileUsage; public UIntPtr PeakPagefileUsage;
  }
  [DllImport("psapi.dll", SetLastError=true)]
  public static extern bool GetProcessMemoryInfo(IntPtr h, out PMC c, uint cb);
}
'@
New-Item -ItemType Directory -Path $out | Out-Null
$os=Get-CimInstance Win32_OperatingSystem
$cpu=Get-CimInstance Win32_Processor | Select-Object -First 1
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH,Env:OBJC_INCLUDE_PATH -ErrorAction SilentlyContinue
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' module ' + $module + ' label ' + $label + ' cpu ' + $cpu.Name.Trim() + ' logical ' + $cpu.NumberOfLogicalProcessors + ' freephysKiB ' + $os.FreePhysicalMemory + ' freevirtKiB ' + $os.FreeVirtualMemory) -Encoding utf8
Add-Content -LiteralPath $term -Value ('binary ' + $fe + ' sha256 ' + (ShaTp $fe) + ' cwd ' + $cwd + ' record-line ' + $line + ' argv ' + $argv.Count + ' words') -Encoding utf8
$proc=Start-Process -FilePath $fe -ArgumentList $argv -WorkingDirectory $cwd -RedirectStandardOutput "$out\stdout.txt" -RedirectStandardError "$out\stderr.txt" -NoNewWindow -PassThru
$hnd=$proc.Handle
Add-Content -LiteralPath $term -Value ('pid ' + $proc.Id + ' started ' + $proc.StartTime.ToUniversalTime().ToString('o')) -Encoding utf8
$proc.WaitForExit()
$c=New-Object PerfMemTp110+PMC
$ok=[PerfMemTp110]::GetProcessMemoryInfo($hnd, [ref]$c, [uint32][Runtime.InteropServices.Marshal]::SizeOf([type][PerfMemTp110+PMC]))
$wall=($proc.ExitTime - $proc.StartTime).TotalSeconds
Add-Content -LiteralPath $term -Value ('exit ' + $proc.ExitCode + ' ended ' + $proc.ExitTime.ToUniversalTime().ToString('o') + ' wall_s ' + $wall.ToString('F1') + ' cpu_user_s ' + $proc.UserProcessorTime.TotalSeconds.ToString('F1') + ' cpu_kernel_s ' + $proc.PrivilegedProcessorTime.TotalSeconds.ToString('F1') + ' cpu_total_s ' + $proc.TotalProcessorTime.TotalSeconds.ToString('F1')) -Encoding utf8
Add-Content -LiteralPath $term -Value ('memory ok ' + $ok + ' peak_ws_bytes ' + $c.PeakWorkingSetSize + ' peak_commit_bytes ' + $c.PeakPagefileUsage + ' page_faults ' + $c.PageFaultCount) -Encoding utf8
foreach ($nm in @("$module.h.lm1", "$module.lm1")) {
  $f="$out\$nm"
  if (Test-Path -LiteralPath $f) { $h=ShaTp $f; $v='DIFF'; if ($h -eq $g1[$nm]) { $v='same-as-G1' }; Add-Content -LiteralPath $term -Value ('output ' + $nm + ' ' + $h + ' ' + $v + ' bytes ' + (Get-Item -LiteralPath $f).Length + ' g1 ' + $g1[$nm]) -Encoding utf8 }
  else { Add-Content -LiteralPath $term -Value ('output ' + $nm + ' MISSING g1 ' + $g1[$nm]) -Encoding utf8 }
}
Add-Content -LiteralPath $term -Value ('stdout bytes ' + (Get-Item -LiteralPath "$out\stdout.txt").Length + ' stderr bytes ' + (Get-Item -LiteralPath "$out\stderr.txt").Length) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Write-Output ('MEASURE ' + $name + ' exit ' + $proc.ExitCode)
