# tools\ps51_proc.ps1 -- one PowerShell 5.1-safe way to launch a child process with an argv ARRAY.
#
# WHY THIS FILE EXISTS (DEEPSEEK-PS51-PROC-HELPER-20260920-07, from audit
# DEEPSEEK-PS51-ARGUMENTLIST-AUDIT-20260920-02).  Windows PowerShell 5.1 runs on .NET Framework,
# where System.Diagnostics.ProcessStartInfo has NO ArgumentList property -- that is a .NET Core 2.1+
# addition.  Measured on this machine, ps 5.1.26100.9444 / clr 4.0.30319.42000: the property is
# absent, `$psi.ArgumentList` is $null, and
#     foreach ($a in @('x')) { $psi.ArgumentList.Add([string]$a) }
# throws "You cannot call a method on a null-valued expression."  tools\build_l2src.ps1:208 is
# exactly that line; it is latent only because both of its callers pass @().
#
# The other failure of this family is QUIET: `Start-Process -ArgumentList <array>` joins the elements
# with single spaces and adds NO quoting, so any element containing a space is split by the child's
# own command-line parsing.  Measured in this repo, not assumed
# (dev\mixa_sandbox\mixa_manager\mixa_share.txt:338-348): gcc received "Files:" and "(x86)\Windows:"
# as separate arguments instead of the single WinRT path "C:\Program Files (x86)\...".  It stays
# latent wherever every path happens to be space-free, which is why it survived in ~250 call sites.
#
# So callers pass argv as an ARRAY and the command line is BUILT HERE, once, with the quoting rule
# that Windows' own CommandLineToArgvW and every C runtime's startup parse.  Nothing else in this
# file: a quoter you can test on its own, and a bounded launcher that reports a trustworthy code.
#
#   ConvertTo-WinCommandLine [string[]] -> string   (pure; the MSVCRT/CommandLineToArgvW rule)
#   Invoke-ProcBounded -Exe -Argv [-TimeoutSec] [-Log]
#
# The exit code comes from a Process started through the .NET API, never from Start-Process -PassThru:
# with redirected streams PS 5.1's -PassThru object was measured NOT to report the child's exit code
# (tools\build_l2src.ps1:199-202, where a passing test was reported as a failure).  The handle is
# primed before WaitForExit -- the same trick this repo already uses at
# dev\l2src_sandbox\run_foreign_alloc.ps1:25 and dev\l2src_sandbox\tripwire_gate_bounds.ps1:56.
#
# USAGE from a script three levels down (e.g. dev\mixa_sandbox\tools\run_manager_smoke.ps1):
#   . (Join-Path $PSScriptRoot '..\..\..\tools\ps51_proc.ps1')
#   $r = Invoke-ProcBounded -Exe $exe -Argv @('--flag', $pathWithSpaces, '32') -TimeoutSec 60
#   if (-not $r.Started) { ... } elseif ($r.TimedOut) { ... } else { $r.Code; $r.Text }
#
# SELF-TEST:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\ps51_proc.ps1 -SelfTest
# It exercises exactly the cases the ticket names -- arguments and paths containing spaces and quotes,
# a nonzero exit, and a timeout that must KILL the child -- plus a real gcc compile whose -I and -o
# paths contain spaces (the exact shape mixa_share.txt:338 records as broken).  It exits 0 only if
# every case holds, and writes its own children under %TEMP%: nothing is committed but this file.
param([switch]$SelfTest)

function ConvertTo-WinCommandLine {
    # The rule Windows' CommandLineToArgvW and the C runtimes agree on:
    #   - an element with no space, tab or quote is passed through unchanged;
    #   - otherwise it is wrapped in quotes, and inside a backslash run is literal EXCEPT before a
    #     quote (doubled, and the quote escaped) and at the very end before the closing quote
    #     (doubled, or it would escape that quote);
    #   - an EMPTY element becomes "" so it arrives as one empty argument instead of vanishing.
    param([string[]]$Argv)
    if ($null -eq $Argv -or $Argv.Count -eq 0) { return '' }
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($element in $Argv) {
        $s = if ($null -eq $element) { '' } else { [string]$element }
        if ($s.Length -gt 0 -and $s -notmatch '[ \t"]') { $out.Add($s); continue }
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append('"')
        $backslashes = 0
        foreach ($ch in $s.ToCharArray()) {
            if ($ch -eq '\') { $backslashes++; continue }
            if ($ch -eq '"') {
                # 2n+1 backslashes then the quote: n literal, one escaping the quote.
                [void]$sb.Append('\' * ($backslashes * 2 + 1))
                $backslashes = 0
                [void]$sb.Append('"')
                continue
            }
            if ($backslashes -gt 0) { [void]$sb.Append('\' * $backslashes); $backslashes = 0 }
            [void]$sb.Append($ch)
        }
        if ($backslashes -gt 0) { [void]$sb.Append('\' * ($backslashes * 2)) }
        [void]$sb.Append('"')
        $out.Add($sb.ToString())
    }
    return ($out -join ' ')
}

function Invoke-ProcBounded {
    # Launch $Exe with $Argv as a real argv array, capture both streams, wait at most $TimeoutSec.
    # Returns: Started / TimedOut / Code / Text  (Text = stdout immediately followed by stderr,
    # untrimmed, exactly as the two ReadToEndAsync tasks completed -- the caller trims if it wants).
    #   Started=$false  -> the child could not be started; Code -2, Text ''.  DEVIATION, declared:
    #                      a missing or unlaunchable exe now REACHES the did-not-start branch that
    #                      callers already document, instead of throwing out of Process.Start().
    #   TimedOut=$true  -> the bound was hit and the child was KILLED; Code -1.  A timeout is never
    #                      a pass and is never reported as an exit code.
    #   otherwise       -> Code is the child's own exit code.
    # -Log, when given, receives Text verbatim.  The CALLER owns any header line, so a caller that
    # already writes "invoke: ..." plus its output keeps that format exactly.
    param(
        [Parameter(Mandatory=$true)][string]$Exe,
        [string[]]$Argv = @(),
        [int]$TimeoutSec = 0,
        [string]$Log
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    $psi.Arguments = ConvertTo-WinCommandLine $Argv
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $started = $false
    try { $started = $proc.Start() } catch { $started = $false }
    if (-not $started) {
        if ($Log) { Set-Content -LiteralPath $Log -Value '' }
        return [pscustomobject]@{ Started = $false; TimedOut = $false; Code = -2; Text = '' }
    }
    # Primed while the child is alive; the exit code is not reliable without it.
    try { $null = $proc.Handle } catch { }
    $outTask = $proc.StandardOutput.ReadToEndAsync()
    $errTask = $proc.StandardError.ReadToEndAsync()
    $finished = $true
    if ($TimeoutSec -gt 0) { $finished = $proc.WaitForExit($TimeoutSec * 1000) } else { $proc.WaitForExit() }
    if (-not $finished) {
        # KILL FIRST, READ AFTER -- the order is not cosmetic.  Reading ReadToEndAsync's .Result
        # blocks until the child CLOSES ITS STREAMS, i.e. until it exits: with that read placed
        # before the kill, the bound waits out the child's whole life, then kills a corpse, and the
        # child gets to finish its work and write its marker.  Measured by this file's own selftest
        # (the marker case, which failed exactly that way on the first draft of this file).  The
        # order here is tools\build_l2src.ps1's Invoke-Bounded order, kept deliberately.
        try { $proc.Kill() } catch { }
        try { $proc.WaitForExit(5000) | Out-Null } catch { }
        $killed = ("" + $outTask.Result) + ("" + $errTask.Result)
        if ($Log) { Set-Content -LiteralPath $Log -Value $killed }
        return [pscustomobject]@{ Started = $true; TimedOut = $true; Code = -1; Text = $killed }
    }
    $text = ("" + $outTask.Result) + ("" + $errTask.Result)
    $code = $proc.ExitCode
    if ($Log) { Set-Content -LiteralPath $Log -Value $text }
    return [pscustomobject]@{ Started = $true; TimedOut = $false; Code = $code; Text = $text }
}

function Invoke-SelfTest {
    $failures = New-Object System.Collections.Generic.List[string]
    function Assert-Equal([string]$Case, [string]$Actual, [string]$Expected) {
        if ($Actual -ceq $Expected) { Write-Output ('PASS ' + $Case) }
        else {
            $failures.Add($Case)
            Write-Output ('FAIL ' + $Case)
            Write-Output ('  expected: ' + $Expected)
            Write-Output ('  actual:   ' + $Actual)
        }
    }
    $psExe = (Get-Command powershell -ErrorAction Stop).Source

    # 1) The quoting rule, on its own.
    $quoteCases = @(
        @{ A = @('plain');                    E = 'plain' },
        @{ A = @('with space');               E = '"with space"' },
        @{ A = @('');                         E = '""' },
        @{ A = @('a', 'b');                   E = 'a b' },
        @{ A = @('with "quotes"');            E = '"with \"quotes\""' },
        @{ A = @('two words\');               E = '"two words\\"' },
        @{ A = @('back\slash"quote');         E = '"back\slash\"quote"' },
        @{ A = @('trailing\');                E = 'trailing\' },
        @{ A = @('--flag', 'C:\a b\c d.txt'); E = '--flag "C:\a b\c d.txt"' }
    )
    foreach ($c in $quoteCases) {
        Assert-Equal ('quote: ' + ($c.A -join '|')) (ConvertTo-WinCommandLine $c.A) $c.E
    }

    # Everything below runs real children under %TEMP%; nothing is written into the repository.
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('ps51_proc_selftest_' + $PID)
    $spaceDir = Join-Path $tmp 'dir with spaces'
    New-Item -ItemType Directory -Force -Path $spaceDir | Out-Null
    $childArgs = Join-Path $spaceDir 'child_args.ps1'
    Set-Content -LiteralPath $childArgs -Encoding utf8 -Value @'
foreach ($a in $args) { 'ARG[' + $a + ']' }
'@

    # 2) Round trip: what a Windows console program actually receives, element for element.
    $wanted = @('plain', 'with space', 'with "quotes"', 'two words\', 'back\slash"quote', '',
                'C:\dir with spaces\file.txt')
    $r = Invoke-ProcBounded -Exe $psExe -Argv (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $childArgs) + $wanted) -TimeoutSec 60
    $want = (($wanted | ForEach-Object { 'ARG[' + $_ + ']' }) -join "`r`n")
    $got = (($r.Text.Trim() -split "`r?`n") -join "`r`n")
    Assert-Equal 'round trip: argv arrives element for element (child script path contains spaces)' $got $want

    # 3) A nonzero exit is reported as the child's own code, and -Log holds its output.
    $childExit = Join-Path $spaceDir 'child_exit.ps1'
    Set-Content -LiteralPath $childExit -Encoding utf8 -Value @'
param([int]$Code = 7)
'SIDE_EFFECT_OK ' + $Code
exit $Code
'@
    $logFile = Join-Path $spaceDir 'exit.log'
    $r = Invoke-ProcBounded -Exe $psExe -Argv @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $childExit, '7') -TimeoutSec 60 -Log $logFile
    Assert-Equal 'nonzero exit: code is the child''s own' ([string]$r.Code) '7'
    Assert-Equal 'nonzero exit: -Log holds the output' ((Get-Content -LiteralPath $logFile -Raw).Trim()) 'SIDE_EFFECT_OK 7'

    # 4) The bound: the child must be KILLED, not merely abandoned -- so it never writes its marker.
    $marker = Join-Path $spaceDir 'sleep_marker.txt'
    $childSleep = Join-Path $spaceDir 'child_sleep.ps1'
    $sleepSrc = "Start-Sleep -Seconds 6`r`nSet-Content -LiteralPath '" + $marker + "' -Value done`r`n"
    Set-Content -LiteralPath $childSleep -Encoding utf8 -Value $sleepSrc
    $t0 = Get-Date
    $r = Invoke-ProcBounded -Exe $psExe -Argv @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $childSleep) -TimeoutSec 2
    $bounded = ((Get-Date) - $t0).TotalSeconds
    Assert-Equal 'timeout: reported as TimedOut' ([string]$r.TimedOut) 'True'
    Assert-Equal 'timeout: code is -1' ([string]$r.Code) '-1'
    if ($bounded -ge 6) { $failures.Add('timeout: the bound returned only after the child would have finished'); Write-Output 'FAIL timeout: bound did not return early' }
    Start-Sleep -Seconds 5
    Assert-Equal 'timeout: the child was killed (its marker was never written)' ([string](Test-Path -LiteralPath $marker)) 'False'

    # 5) The recorded failure shape itself: a real gcc whose -I, source and -o paths all contain spaces.
    $gcc = $null
    try { $gcc = (Get-Command gcc -ErrorAction Stop).Source } catch { }
    if (-not $gcc) { Write-Output 'SKIP gcc: not on PATH, the space-path compile was not exercised' }
    else {
        Set-Content -LiteralPath (Join-Path $spaceDir 'space_probe.h') -Encoding ascii -Value '#define SPACE_PROBE 42'
        $probeC = Join-Path $spaceDir 'space_probe.c'
        Set-Content -LiteralPath $probeC -Encoding ascii -Value "#include <space_probe.h>`r`nint main(void) { return SPACE_PROBE == 42 ? 0 : 1; }`r`n"
        $probeExe = Join-Path $spaceDir 'space_probe.exe'
        $r = Invoke-ProcBounded -Exe $gcc -Argv @('-std=c99', '-I', $spaceDir, '-o', $probeExe, $probeC) -TimeoutSec 120
        Assert-Equal 'gcc: -I/source/-o paths with spaces compile' ([string]$r.Code) '0'
        $r2 = Invoke-ProcBounded -Exe $probeExe -Argv @() -TimeoutSec 60
        Assert-Equal 'gcc: the program built from those paths runs' ([string]$r2.Code) '0'
    }

    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output ''
    if ($failures.Count -gt 0) {
        Write-Output ('ps51_proc selftest RED: ' + $failures.Count + ' case(s) failed')
        exit 1
    }
    Write-Output 'ps51_proc selftest GREEN: all cases hold'
    exit 0
}

if ($SelfTest) { Invoke-SelfTest }
