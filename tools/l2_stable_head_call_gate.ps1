# l2_stable_head_call_gate.ps1 -- narrowly scoped stable gate for
# GROKBOT-STABLE-HEAD-CALL-P1-20260922-81.
#
# UUT: committed l2src/l2trans.lm1 (+ l2src/l2_libc.lm1).
# Toolchain only (not UUT): pinned bin/l1trans.exe + staged copies of
#   dev/l2src_sandbox/l1src for predef resolution while building the UUT.
# Does NOT claim tools/l2_harness.ps1 (sandbox) as stable proof.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\l2_stable_head_call_gate.ps1
param([string]$OutDir)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root
if (-not $OutDir) {
    $OutDir = Join-Path $root ('build\l2_stable_head_call\' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
$src = Join-Path $OutDir 'src'
$gen = Join-Path $OutDir 'gen'
$bin = Join-Path $OutDir 'bin'
$logs = Join-Path $OutDir 'logs'
$fxOut = Join-Path $OutDir 'fixtures'
New-Item -ItemType Directory -Force -Path (Join-Path $src 'l2src') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $src 'l1src') | Out-Null
New-Item -ItemType Directory -Force -Path $gen | Out-Null
New-Item -ItemType Directory -Force -Path $bin | Out-Null
New-Item -ItemType Directory -Force -Path $logs | Out-Null
New-Item -ItemType Directory -Force -Path $fxOut | Out-Null

$l1 = Join-Path $root 'bin\l1trans.exe'
if (-not (Test-Path -LiteralPath $l1)) { throw "missing pinned translator: $l1" }
$pinFile = Join-Path $root 'L1_PIN.txt'
$pin = (Get-Content -LiteralPath $pinFile -TotalCount 1).Trim().ToUpper()
$l1Hash = (Get-FileHash -LiteralPath $l1 -Algorithm SHA256).Hash.ToUpper()
if ($l1Hash -ne $pin) { throw "l1trans pin mismatch: $l1Hash vs $pin" }

$uut = Join-Path $root 'l2src\l2trans.lm1'
$libc = Join-Path $root 'l2src\l2_libc.lm1'
if (-not (Test-Path -LiteralPath $uut)) { throw "missing UUT: $uut" }
if (-not (Test-Path -LiteralPath $libc)) { throw "missing $libc" }
$uutSha = (Get-FileHash -LiteralPath $uut -Algorithm SHA256).Hash.ToUpper()
Copy-Item -LiteralPath $uut -Destination (Join-Path $src 'l2src\l2trans.lm1') -Force
Copy-Item -LiteralPath $libc -Destination (Join-Path $src 'l2src\l2_libc.lm1') -Force
$sandboxL1 = Join-Path $root 'dev\l2src_sandbox\l1src'
if (-not (Test-Path -LiteralPath $sandboxL1)) { throw "missing toolchain l1src: $sandboxL1" }
Copy-Item -Recurse -Force (Join-Path $sandboxL1 '*') (Join-Path $src 'l1src')

$red = New-Object System.Collections.Generic.List[string]
function Add-Red([string]$m) { $script:red.Add($m) | Out-Null; Write-Output ("RED " + $m) }

Write-Output ("l2_stable_head_call_gate: UUT sha256=" + $uutSha)
Write-Output ("l2_stable_head_call_gate: evidence=" + $OutDir)
Write-Output ("l2_stable_head_call_gate: toolchain l1src from dev/l2src_sandbox/l1src (not UUT)")

$l2transC = Join-Path $gen 'l2trans.c'
$l2libcC = Join-Path $gen 'l2_libc.c'
$l2libcO = Join-Path $gen 'l2_libc.o'
$l2trans = Join-Path $bin 'l2trans.exe'
Push-Location $src
cmd /c "`"$l1`" l2src/l2trans.lm1 `"$l2transC`" > `"$logs\translate_l2trans.log`" 2>&1"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $l2transC)) {
    Pop-Location
    throw "UUT translate failed; see $logs\translate_l2trans.log"
}
cmd /c "`"$l1`" l2src/l2_libc.lm1 `"$l2libcC`" > `"$logs\translate_l2_libc.log`" 2>&1"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $l2libcC)) {
    Pop-Location
    throw "l2_libc translate failed; see $logs\translate_l2_libc.log"
}
Pop-Location

$sandbox = Join-Path $root 'dev\l2src_sandbox'
$cflags = @('-std=c99', '-I', $root, '-I', (Join-Path $root 'lm1\build'), '-I', $sandbox)
cmd /c "gcc $($cflags -join ' ') -c `"$l2libcC`" -o `"$l2libcO`" > `"$logs\compile_l2_libc.log`" 2>&1"
if ($LASTEXITCODE -ne 0) { throw "l2_libc compile failed; see $logs\compile_l2_libc.log" }
cmd /c "gcc $($cflags -join ' ') -o `"$l2trans`" `"$l2transC`" `"$l2libcO`" > `"$logs\link_l2trans.log`" 2>&1"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $l2trans)) { throw "l2trans link failed; see $logs\link_l2trans.log" }
Write-Output ("OK build:l2trans sha256=" + (Get-FileHash -LiteralPath $l2trans -Algorithm SHA256).Hash.Substring(0, 16))

# Assert COMPACT early-return is gone from UUT source (gate identity).
$uutText = Get-Content -Raw -LiteralPath $uut
if ($uutText -match '(?s)fn: l2_head_is_call.*?if: \(flags & c\.LM_P0_FRAME_COMPACT\) != 0U\s+return: 1') {
    Add-Red 'l2_head_is_call still has COMPACT early-return'
} else {
    Write-Output 'OK source: l2_head_is_call has no COMPACT early-return'
}

function Invoke-Fx {
    param(
        [string]$Name,
        [ValidateSet('translates-with-debt','l2trans-refuses')][string]$Expect,
        [string[]]$Debt = @(),
        [string]$Needle = ''
    )
    $lm2 = Join-Path $root ("l2src\tests\" + $Name + ".lm2")
    if (-not (Test-Path -LiteralPath $lm2)) { Add-Red ("missing fixture " + $lm2); return }
    $out = Join-Path $fxOut ($Name + ".lm1")
    $err = Join-Path $fxOut ($Name + ".err")
    $stdout = Join-Path $fxOut ($Name + ".out")
    Remove-Item $out, $err, $stdout -ErrorAction SilentlyContinue
    cmd /c "`"$l2trans`" `"$lm2`" `"$out`" 1> `"$stdout`" 2> `"$err`""
    $exists = Test-Path -LiteralPath $out
    $errText = ''
    if (Test-Path -LiteralPath $err) {
        $raw = Get-Content -Raw -LiteralPath $err -ErrorAction SilentlyContinue
        if ($null -ne $raw) { $errText = $raw }
    }
    if ($Expect -eq 'translates-with-debt') {
        if (-not $exists) {
            Add-Red ($Name + ' expected translate; err=' + (($errText -replace '\s+', ' ').Substring(0, [Math]::Min(160, ($errText -replace '\s+', ' ').Length))))
            return
        }
        $genText = Get-Content -Raw -LiteralPath $out
        foreach ($d in $Debt) {
            if ($genText -notmatch [regex]::Escape($d)) {
                Add-Red ($Name + " missing Debt '$d'")
                return
            }
        }
        Write-Output ("OK " + $Name + " translates-with-debt Debt=[" + ($Debt -join ',') + "]")
    } else {
        if ($exists) {
            Add-Red ($Name + ' expected l2trans-refuses but produced output')
            return
        }
        if ($Needle -and ($errText -notmatch [regex]::Escape($Needle))) {
            Add-Red ($Name + " expected Needle '$Needle' in stderr; got=" + (($errText -replace '\s+', ' ').Substring(0, [Math]::Min(160, ($errText -replace '\s+', ' ').Length))))
            return
        }
        Write-Output ("OK " + $Name + " l2trans-refuses Needle=" + $Needle)
    }
}

Invoke-Fx 'unit_head_call_method_compact' 'translates-with-debt' -Debt @('l2_m0')
Invoke-Fx 'unit_head_call_method_colon' 'translates-with-debt' -Debt @('l2_m0')
Invoke-Fx 'unit_head_call_unresolved_compact' 'l2trans-refuses' -Needle 'unsupported body'
Invoke-Fx 'unit_head_call_c_arg_compact' 'translates-with-debt' -Debt @('c.bogus')

# Persist identity
@(
    "uut_path=l2src/l2trans.lm1"
    "uut_sha256=$uutSha"
    "l1trans_sha256=$l1Hash"
    "evidence=$OutDir"
    "red_count=$($red.Count)"
) | Set-Content -LiteralPath (Join-Path $OutDir 'MANIFEST.txt') -Encoding ascii

if ($red.Count -gt 0) {
    Write-Output ("l2_stable_head_call_gate RED: " + $red.Count + " failure(s); evidence " + $OutDir)
    exit 1
}
Write-Output ("l2_stable_head_call_gate GREEN; evidence " + $OutDir)
exit 0

