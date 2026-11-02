try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# slice251, profile BEFORE (Codex via lmx_uds, 2026-11-01 after full100's stop: causal profiling of the slow L2->L1
# translation, one selected module). The translation of l2_frontend_emit.lm2 (G1: 64.04 min) by full100's G1 frontend
# bf6d713e (source-full100 AA841167, built by quick98's G2 frontend; gcc -O2 -fno-strict-aliasing, record
# cold-full100/full100/g1/frontend/record.txt:386). argv = that record's line 253 (tools/build.lm2 bld_machine_module,
# stem l2_frontend_emit) with this binary; the inputs are the stage's, hash-pinned, so the source path (and with it the
# unit prefix) is G1's. CWD and outputs: the build runs the step from stage/src and writes the outputs there; the
# translator opens its predef headers by CWD-relative paths. So this run's CWD is the private tree perf251-emit-tree-03
# (pins/perf251-tree03-prepare.command: the stage as G1 held it when the step began, verified), and the two outputs
# are written into that tree at G1's relative paths. Measured: wall (process start/exit), CPU user/kernel
# (GetProcessTimes), peak working set and peak commit (GetProcessMemoryInfo after exit). Manual gdb snapshots pause it
# (wall only; CPU time does not count them).
# Attempt 01 (pid 15480, 19:17:56Z): stopped by Opus after 25.7 s; its hash helper `H` resolved to the alias h =
# Get-History, so its pins went unchecked (as run: perf251-emit-before-01*.command). Attempt 02 (pid 16812, 19:19:01Z):
# stopped by Opus after 182.0 s; its empty private CWD made every predef open fail (as run:
# perf251-emit-before-02*.command). Attempt 03 = this record.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$name='perf251-emit-before'
$try='03'
$fe="$p\cold-full100\full100\g1\frontend\l2trans.exe"
$rec="$p\cold-full100\full100\g1\frontend\record.txt"
$tree='perf251-emit-tree-03'
$out="$p\$name-$try"
$cwd="$p\$tree\src"
$term="$p\pins\$name-$try.terminal.txt"
if (Test-Path -LiteralPath $term) { throw 'terminal exists' }
if (Test-Path -LiteralPath $out) { throw "exists $out" }
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
function Sha251([string]$f) { (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLowerInvariant() }
if ((Sha251 $fe) -ne 'bf6d713e4be632a5be4d2334d388ca6658a0dd34b56c4c7fcc56dc87a412e6bc') { throw 'frontend hash' }
if ((Sha251 $rec) -ne '246272153bdb0ca9f534e29b7d11ba8bcc2eedd0e4e6171c8b80eaeb05c2eddf') { throw 'record hash' }
if ((Sha251 "$p\pins\$tree-all.sha256") -ne 'eddc401b5285bd337900fe340c440987267b7c0a06230b9feed415b3d2baafcf') { throw 'tree manifest hash' }
if (-not (Test-Path -LiteralPath "$p\pins\$tree-prepare.terminal.txt") -or -not (Select-String -LiteralPath "$p\pins\$tree-prepare.terminal.txt" -Pattern 'tree ready' -Quiet)) { throw 'tree not prepared' }
foreach ($g in @("$cwd\l2src\l2_frontend_emit.h.lm1", "$cwd\l2src\l2_frontend_emit.lm1")) { if (Test-Path -LiteralPath $g) { throw "output exists before the run: $g" } }
$pins=[ordered]@{
  "$p\cold-full100\src\l2src\l2_frontend_emit.lm2"='c35ce51a8792001dfa4a77bfcdd0c1ba722b270007795e0858ea7c52e3667a21'
  "$p\cold-full100\src\l2src\convert.lm2"='1e376cba102874857eac2279f0c6e14cce5ab009cb8764b03bd300f7e9746976'
  "$p\cold-full100\src\l2src\primitive.lm2"='cf9aac78f7347ae0b40e929752fc0400a67507ca302735655ca3be167db588c3'
}
foreach ($k in $pins.Keys) { if ((Sha251 $k) -ne $pins[$k]) { throw "input hash $k" } }
$line=(Get-Content -LiteralPath $rec)[252]
$tok=$line -split ' '
if ($tok[0] -ne '$' -or $tok[$tok.Count-1] -ne "$P2/cold-full100/src/l2src/l2_frontend_emit.lm1" -or $tok[$tok.Count-6] -ne '--header' -or $tok[$tok.Count-5] -ne "$P2/cold-full100/src/l2src/l2_frontend_emit.h.lm1" -or $tok[2] -ne '--library') { throw 'record line 253' }
$argv=@($tok[2..($tok.Count-1)])
$argv[$argv.Count-5]="$P2/$tree/src/l2src/l2_frontend_emit.h.lm1"
$argv[$argv.Count-1]="$P2/$tree/src/l2src/l2_frontend_emit.lm1"
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PerfMem251 {
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
$sha=[System.Security.Cryptography.SHA256]::Create()
$ah=([BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes(($argv -join ' '))))).Replace('-','').ToLowerInvariant()
Add-Content -LiteralPath $term -Value ('start ' + [DateTime]::UtcNow.ToString('o') + ' cpu ' + $cpu.Name.Trim() + ' logical ' + $cpu.NumberOfLogicalProcessors + ' freephysKiB ' + $os.FreePhysicalMemory + ' freevirtKiB ' + $os.FreeVirtualMemory) -Encoding utf8
Add-Content -LiteralPath $term -Value ('binary ' + $fe + ' sha256 bf6d713e4be632a5be4d2334d388ca6658a0dd34b56c4c7fcc56dc87a412e6bc cwd ' + $cwd + ' argv ' + $argv.Count + ' words sha256 ' + $ah) -Encoding utf8
$proc=Start-Process -FilePath $fe -ArgumentList $argv -WorkingDirectory $cwd -RedirectStandardOutput "$out\stdout.txt" -RedirectStandardError "$out\stderr.txt" -NoNewWindow -PassThru
$hnd=$proc.Handle
Add-Content -LiteralPath $term -Value ('pid ' + $proc.Id + ' started ' + $proc.StartTime.ToUniversalTime().ToString('o')) -Encoding utf8
$proc.WaitForExit()
$c=New-Object PerfMem251+PMC
$ok=[PerfMem251]::GetProcessMemoryInfo($hnd, [ref]$c, [uint32][Runtime.InteropServices.Marshal]::SizeOf([type][PerfMem251+PMC]))
$wall=($proc.ExitTime - $proc.StartTime).TotalSeconds
Add-Content -LiteralPath $term -Value ('exit ' + $proc.ExitCode + ' ended ' + $proc.ExitTime.ToUniversalTime().ToString('o') + ' wall_s ' + $wall.ToString('F1') + ' cpu_user_s ' + $proc.UserProcessorTime.TotalSeconds.ToString('F1') + ' cpu_kernel_s ' + $proc.PrivilegedProcessorTime.TotalSeconds.ToString('F1') + ' cpu_total_s ' + $proc.TotalProcessorTime.TotalSeconds.ToString('F1')) -Encoding utf8
Add-Content -LiteralPath $term -Value ('memory ok ' + $ok + ' peak_ws_bytes ' + $c.PeakWorkingSetSize + ' peak_commit_bytes ' + $c.PeakPagefileUsage + ' page_faults ' + $c.PageFaultCount) -Encoding utf8
foreach ($pair in @(@('l2_frontend_emit.h.lm1','3a007b19f5d4d861b595f7a0b82ec319670ddafdbdbb1c89bbdf97030e865e4c'), @('l2_frontend_emit.lm1','bc112cd8589878b2877ae9f63c93c98d39ca1eb58e9cd2e142d69a2c947887b4'))) {
  $f="$cwd\l2src\$($pair[0])"
  if (Test-Path -LiteralPath $f) { $h=Sha251 $f; $v='DIFF'; if ($h -eq $pair[1]) { $v='same-as-G1' }; Add-Content -LiteralPath $term -Value ('output ' + $pair[0] + ' ' + $h + ' ' + $v + ' bytes ' + (Get-Item -LiteralPath $f).Length) -Encoding utf8 }
  else { Add-Content -LiteralPath $term -Value ('output ' + $pair[0] + ' MISSING') -Encoding utf8 }
}
Add-Content -LiteralPath $term -Value ('stdout bytes ' + (Get-Item -LiteralPath "$out\stdout.txt").Length + ' stderr bytes ' + (Get-Item -LiteralPath "$out\stderr.txt").Length) -Encoding utf8
Add-Content -LiteralPath $term -Value ('done ' + [DateTime]::UtcNow.ToString('o')) -Encoding utf8
Write-Output 'PERF251 done'
