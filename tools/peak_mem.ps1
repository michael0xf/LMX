# PEAK MEMORY OF A GATE'S STEPS (next_core_tasks.md §0, build memory, item 3).  Dot-sourced by
# tools\l2_harness.ps1 and tools\build_l2src.ps1.  A gate step runs gcc, whose compiler proper
# (cc1.exe) is a CHILD the step's own process object cannot see, so a background runspace samples
# the toolchain processes BY NAME every 100 ms -- cc1, gcc, as, ld, collect2, l1trans, l2trans and
# the executable the step itself started -- and charges each one's PeakWorkingSet64 (a peak only
# grows, so the last reading before exit is the peak) to the step the gate last named
# (Set-PeakStep).  By name means machine-wide: the rule of one gcc pipeline on the machine is what
# makes the attribution the gate's own.  A 100 ms sample can miss a process that lives less; such
# a process is small by the same token (a whole fixture compiles in about 0.1 s at 12-18 MB).
#   Start-PeakSampler; Set-PeakStep 'label' 'C:\path\tool.exe'; ...; $rows = Stop-PeakSampler
# Stop-PeakSampler returns one object per (step, process): Step, Process, MB.

$script:peakState = $null
$script:peakPs = $null
$script:peakHandle = $null

function Start-PeakSampler {
    $script:peakState = [hashtable]::Synchronized(@{ Step = ''; Exe = ''; Stop = $false; Peaks = [hashtable]::Synchronized(@{}) })
    $rs = [runspacefactory]::CreateRunspace()
    $rs.Open()
    $rs.SessionStateProxy.SetVariable('st', $script:peakState)
    $script:peakPs = [powershell]::Create()
    $script:peakPs.Runspace = $rs
    [void]$script:peakPs.AddScript({
        $tools = @('cc1', 'gcc', 'as', 'ld', 'collect2', 'l1trans', 'l2trans')
        while (-not $st.Stop) {
            $names = $tools
            if ($st.Exe -ne '') { $names = $tools + @($st.Exe) }
            foreach ($p in @(Get-Process -Name $names -ErrorAction SilentlyContinue)) {
                $peak = 0
                $name = ''
                try { $p.Refresh(); $peak = $p.PeakWorkingSet64; $name = $p.ProcessName } catch { continue }
                # A process that exited between the listing and the reading reads as nothing.
                if ($peak -le 0 -or $name -eq '') { continue }
                $key = $st.Step + "`t" + $name
                if (-not $st.Peaks.ContainsKey($key) -or $st.Peaks[$key] -lt $peak) { $st.Peaks[$key] = $peak }
            }
            Start-Sleep -Milliseconds 100
        }
    })
    $script:peakHandle = $script:peakPs.BeginInvoke()
}

function Set-PeakStep([string]$Step, [string]$Exe) {
    if ($null -eq $script:peakState) { return }
    $script:peakState.Step = $Step
    $name = ''
    if ($Exe) { $name = [System.IO.Path]::GetFileNameWithoutExtension($Exe) }
    $script:peakState.Exe = $name
}

function Stop-PeakSampler {
    if ($null -eq $script:peakState) { return @() }
    $script:peakState.Stop = $true
    try { [void]$script:peakPs.EndInvoke($script:peakHandle) } catch {}
    $script:peakPs.Runspace.Close()
    $script:peakPs.Dispose()
    $rows = @()
    foreach ($k in @($script:peakState.Peaks.Keys)) {
        $parts = $k -split "`t", 2
        $rows += [pscustomobject]@{ Step = $parts[0]; Process = $parts[1]; MB = [math]::Round($script:peakState.Peaks[$k] / 1MB, 1) }
    }
    $script:peakState = $null
    return @($rows | Sort-Object MB -Descending)
}

# The report a gate writes: the machine-wide peak per process, then the N heaviest steps.
function Format-PeakReport($Rows, [int]$Top = 10) {
    $lines = @()
    foreach ($g in @($Rows | Group-Object Process | Sort-Object { ($_.Group | Measure-Object MB -Maximum).Maximum } -Descending)) {
        $max = ($g.Group | Sort-Object MB -Descending | Select-Object -First 1)
        $lines += ('peak ' + $g.Name + ' ' + $max.MB + ' MB (' + $max.Step + ')')
    }
    foreach ($r in @($Rows | Select-Object -First $Top)) {
        $lines += ('step ' + $r.MB + ' MB ' + $r.Process + ' ' + $r.Step)
    }
    return $lines
}
