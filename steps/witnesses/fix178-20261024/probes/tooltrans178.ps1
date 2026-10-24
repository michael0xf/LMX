# Slice 178's translation-only check of the tools recipe (memory too low for the tool's compile): the stage's tools
# sources, as bld_self lists them, translated by FRONTEND (L2 -> L1, cwd = the stage's src) and by repo's
# bin/l1trans.exe (L1 -> C) into runs/LABEL; no gcc. Each step's exit, seconds and peak commit go to LABEL/steps.txt;
# a step is stopped (and recorded so) when the system's free commit falls below 0.8 GiB.
# Usage: tooltrans178.ps1 LABEL [FRONTEND]
param([string]$Label, [string]$Frontend = 'C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/fe-probe-04/l2trans.exe')
$ErrorActionPreference = 'Stop'
$S = 'C:/Nyasha_Planet/LMX/build2/opus_fix178'
$B = 'C:/Nyasha_Planet/LMX/buold_temp'
$Out = "$S/runs/$Label"
if (Test-Path $Out) { 'refused: an output exists'; exit 1 }
New-Item -ItemType Directory -Path $Out | Out-Null
$fe = $Frontend
$t = "$S/tools"
$l2args = @("$t/lmxtool.lm2", "$t/text.lm2", "$t/winargs.lm2", "$t/sha256.lm2", "$t/replay.lm2", "$t/build.lm2", "$t/suite.lm2",
    "$B/l2_harness/codex_consumer49_full_01/src/convert.lm2", "$B/l2_harness/codex_consumer49_full_01/src/primitive.lm2", "$Out/lmxtool.lm1")
$steps = @(
    @{ name = 'L2'; exe = $fe; args = $l2args },
    @{ name = 'L1'; exe = 'C:/Nyasha_Planet/LMX/bin/l1trans.exe'; args = @("$Out/lmxtool.lm1", "$Out/lmxtool.c") }
)
function FreeCommitGiB {
    $c = (Get-Counter '\Memory\Committed Bytes', '\Memory\Commit Limit').CounterSamples
    return ($c[1].CookedValue - $c[0].CookedValue) / 1GB
}
foreach ($st in $steps) {
    $quoted = $st.args | ForEach-Object { '"' + $_ + '"' }
    "$ $($st.exe) $($st.args -join ' ')" | Out-File -Append -Encoding ascii "$Out/steps.txt"
    $t0 = Get-Date
    $p = Start-Process -FilePath $st.exe -ArgumentList $quoted -WorkingDirectory "$S/src" -NoNewWindow -PassThru `
        -RedirectStandardOutput "$Out/lmxtool.$($st.name).log" -RedirectStandardError "$Out/lmxtool.$($st.name).err"
    # Windows PowerShell keeps a started process's exit code only when its handle was taken while it ran.
    $null = $p.Handle
    $peak = 0; $minFree = 99.0; $stopped = $false
    while (-not $p.HasExited) {
        try { $p.Refresh(); if ($p.PagedMemorySize64 -gt $peak) { $peak = $p.PagedMemorySize64 } } catch {}
        $f = FreeCommitGiB
        if ($f -lt $minFree) { $minFree = $f }
        if ($f -lt 0.8) { Stop-Process -Id $p.Id -Force; $stopped = $true; break }
        Start-Sleep -Milliseconds 500
    }
    $p.WaitForExit()
    $secs = ((Get-Date) - $t0).TotalSeconds
    $line = "  {0} exit {1} seconds {2:N1} peak-commit-MiB {3:N0} min-free-commit-GiB {4:N2} stopped {5}" -f $st.name, $p.ExitCode, $secs, ($peak / 1MB), $minFree, $stopped
    $line | Out-File -Append -Encoding ascii "$Out/steps.txt"
    $line
    if ($stopped -or $p.ExitCode -ne 0) { exit 1 }
}
exit 0
