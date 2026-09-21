#requires -Version 5.1
param(
    [ValidateSet('mir', 'wasm', 'riscv', 'all')]
    [string]$Target = 'all'
)

$ErrorActionPreference = 'Continue'
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot 'lm1\build\printTree.lm1.c'))) {
    Write-Error ("Not LMX repo root: {0}" -f $RepoRoot)
    exit 2
}
Set-Location -LiteralPath $RepoRoot

$OutRoot = Join-Path $RepoRoot 'build\vm_porting\smoke_runner'
New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Log = Join-Path $OutRoot ("run_{0}_{1}.txt" -f $Target, $Stamp)

function Write-Log([string]$Msg) {
    $Msg | Tee-Object -FilePath $Log -Append
}

function Test-Wsl {
    & wsl -e true 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Invoke-WslBash([string]$Label, [string]$BashBody) {
    $scriptPath = Join-Path $OutRoot ("_{0}.sh" -f $Label)
    $unix = $BashBody -replace "`r`n", "`n" -replace "`r", "`n"
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($scriptPath, $unix, $utf8)
    if ($scriptPath -match '^[Cc]:\\') {
        $wslPath = '/mnt/c/' + ($scriptPath.Substring(3) -replace '\\', '/')
    } else {
        $wslPath = $scriptPath
    }
    Write-Log ("CMD[{0}]: wsl bash {1}" -f $Label, $wslPath)
    $output = & wsl -e bash $wslPath 2>&1 | Out-String
    $rc = $LASTEXITCODE
    Write-Log $output.TrimEnd()
    Write-Log ("EXIT[{0}]={1}" -f $Label, $rc)
    return @{ Exit = $rc; Output = $output }
}

$results = @()
function Add-Result([string]$Name, [string]$Status, [int]$Code, [string]$Detail) {
    $script:results += [pscustomobject]@{ Target = $Name; Status = $Status; Exit = $Code; Detail = $Detail }
    Write-Log ("RESULT {0} {1} exit={2} {3}" -f $Name, $Status, $Code, $Detail)
}

Write-Log ("GROK-BOT-VM-PATHA-22 run_vm_patha_smoke Target={0}" -f $Target)
Write-Log ("RepoRoot={0} Log={1}" -f $RepoRoot, $Log)

function Run-Mir {
    $c2m = Join-Path $RepoRoot 'build\vm\mir-build\c2m'
    if (-not (Test-Path -LiteralPath $c2m)) { Add-Result 'mir' 'SKIP' 0 'missing c2m'; return }
    if (-not (Test-Wsl)) { Add-Result 'mir' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash',
        'set -e',
        'cd /mnt/c/Nyasha_Planet/LMX',
        'C2M=build/vm/mir-build/c2m',
        'OUT=build/vm_porting/smoke_runner',
        'mkdir -p "$OUT"',
        '"$C2M" lm1/build/printTree.lm1.c -ei',
        'echo PRINTTREE_EI=$?',
        '"$C2M" lm1/build/make.lm1.c -ei mkdir "$OUT/from_mir_make"',
        'echo MAKE_EI=$?',
        '"$C2M" lm1/build/make.lm1.c -S -o "$OUT/make.mir"',
        'build/vm/mir-build/m2b < "$OUT/make.mir" > "$OUT/make.bmir"',
        'build/vm/mir-build/b2m < "$OUT/make.bmir" > "$OUT/make.round.mir"',
        'echo ROUNDTRIP=$?',
        'wc -c "$OUT/make.mir" "$OUT/make.bmir"'
    ) -join $nl
    $r = Invoke-WslBash 'mir' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree' -and $r.Output -match 'MAKE_EI=0') {
        Add-Result 'mir' 'OK' 0 'printTree -ei + make -ei + m2b/b2m'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'mir' 'FAIL' $code 'see log'
    }
}

function Run-Wasm {
    $clang = Join-Path $RepoRoot 'build\vm\wasi-sdk-34.0-x86_64-linux\bin\clang'
    $wt = Join-Path $RepoRoot 'build\vm\wasmtime-v48.0.2-x86_64-linux\wasmtime'
    if (-not ((Test-Path $clang) -and (Test-Path $wt))) { Add-Result 'wasm' 'SKIP' 0 'missing wasi/wasmtime'; return }
    if (-not (Test-Wsl)) { Add-Result 'wasm' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash',
        'set -e',
        'cd /mnt/c/Nyasha_Planet/LMX',
        'CLANG=build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang',
        'WT=build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime',
        'OUT=build/vm_porting/smoke_runner',
        'mkdir -p "$OUT"',
        '"$CLANG" --target=wasm32-wasip1 -std=c99 -Wall -I. -Ilm1 -Il1src -o "$OUT/printTree.wasm" lm1/build/printTree.lm1.c',
        'echo CC=$?',
        '"$WT" "$OUT/printTree.wasm"',
        'echo RUN=$?',
        'wc -c "$OUT/printTree.wasm"'
    ) -join $nl
    $r = Invoke-WslBash 'wasm' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree') {
        Add-Result 'wasm' 'OK' 0 'printTree.wasm build+run'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'wasm' 'FAIL' $code 'see log'
    }
}

function Run-Riscv {
    $gcc = Join-Path $RepoRoot 'build\vm\riscv\bin\riscv64-unknown-linux-gnu-gcc'
    $qemu = Join-Path $RepoRoot 'build\vm\qemu-user-static-root\usr\bin\qemu-riscv64-static'
    if (-not ((Test-Path $gcc) -and (Test-Path $qemu))) { Add-Result 'riscv' 'SKIP' 0 'missing riscv/qemu'; return }
    if (-not (Test-Wsl)) { Add-Result 'riscv' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash',
        'set -e',
        'cd /mnt/c/Nyasha_Planet/LMX',
        'GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc',
        'QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static',
        'OUT=build/vm_porting/smoke_runner',
        'mkdir -p "$OUT"',
        'SYSROOT=$("$GCC" -print-sysroot)',
        '"$GCC" -std=c99 -Wall -O2 -I. -Ilm1 -Il1src -o "$OUT/printTree_rv.elf" lm1/build/printTree.lm1.c',
        'echo CC=$?',
        '"$QEMU" -L "$SYSROOT" "$OUT/printTree_rv.elf"',
        'echo RUN=$?',
        'wc -c "$OUT/printTree_rv.elf"'
    ) -join $nl
    $r = Invoke-WslBash 'riscv' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree') {
        Add-Result 'riscv' 'OK' 0 'printTree_rv.elf + qemu'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'riscv' 'FAIL' $code 'see log'
    }
}

switch ($Target) {
    'mir' { Run-Mir }
    'wasm' { Run-Wasm }
    'riscv' { Run-Riscv }
    'all' { Run-Mir; Run-Wasm; Run-Riscv }
}

Write-Log '=== SUMMARY ==='
$fail = $false
foreach ($row in $results) {
    Write-Log ("{0}`t{1}`texit={2}`t{3}" -f $row.Target, $row.Status, $row.Exit, $row.Detail)
    if ($row.Status -eq 'FAIL') { $fail = $true }
}
if ($fail) { Write-Log 'OVERALL=FAIL'; exit 1 }
Write-Log 'OVERALL=OK'
exit 0
