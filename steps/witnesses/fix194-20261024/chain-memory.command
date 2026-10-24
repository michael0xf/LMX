# The memory watchdog beside the chain, as run (Windows PowerShell 5.1, a background task started before the chain):
# every 3 s the free commit and cc1's private memory go to chain-memory.log; below 0.8 GiB of free commit cc1 is
# stopped; the loop ends 10 s after the last lmxtool process.
$log = 'C:\Nyasha_Planet\LMX\build2\opus_fix194\runs\chain-memory.log'
$seen = $false
for ($i = 0; $i -lt 3000; $i++) {
  $os = Get-CimInstance Win32_OperatingSystem
  $free = [math]::Round($os.FreeVirtualMemory / 1MB, 2)
  $cc1 = Get-Process cc1 -ErrorAction SilentlyContinue
  $mb = 0
  if ($cc1) { $mb = [math]::Round((($cc1 | Measure-Object -Property PrivateMemorySize64 -Sum).Sum) / 1MB) }
  ('{0} free-commit {1} GiB cc1 {2} MB' -f (Get-Date -Format HH:mm:ss), $free, $mb) | Out-File -Append -Encoding ascii $log
  if ($cc1 -and $free -lt 0.8) { $cc1 | Stop-Process -Force; 'killed cc1: free commit below 0.8 GiB' | Out-File -Append -Encoding ascii $log }
  $t = Get-Process lmxtool, lmxtool-tool -ErrorAction SilentlyContinue
  if ($t) { $seen = $true } elseif ($seen) { Start-Sleep -Seconds 10; $t = Get-Process lmxtool, lmxtool-tool -ErrorAction SilentlyContinue; if (-not $t) { break } }
  Start-Sleep -Seconds 3
}
'watchdog end' | Out-File -Append -Encoding ascii $log
