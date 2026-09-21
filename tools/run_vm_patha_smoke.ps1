#requires -Version 5.1
param(
    [ValidateSet('mir', 'wasm', 'riscv', 'all')]
    [string]$Target = 'all',
    [ValidateSet('printTree', 'own', 'parser', 'l1trans')]
    [string]$Fixture = 'printTree'
)

$ErrorActionPreference = 'Continue'
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot 'lm1\build\printTree.lm1.c'))) {
    Write-Error ("Not LMX repo root: {0}" -f $RepoRoot)
    exit 2
}
if ($Fixture -eq 'own' -and -not (Test-Path -LiteralPath (Join-Path $RepoRoot 'include_languages\vm\own_harness_main.c'))) {
    Write-Error 'Missing include_languages/vm/own_harness_main.c'
    exit 2
}
if ($Fixture -eq 'parser' -and -not (Test-Path -LiteralPath (Join-Path $RepoRoot 'include_languages\vm\parser_harness_main.c'))) {
    Write-Error 'Missing include_languages/vm/parser_harness_main.c'
    exit 2
}
if ($Fixture -eq 'l1trans' -and -not (Test-Path -LiteralPath (Join-Path $RepoRoot 'lm1\build\l1trans.lm1.c'))) {
    Write-Error 'Missing lm1/build/l1trans.lm1.c'
    exit 2
}
Set-Location -LiteralPath $RepoRoot

$OutRoot = Join-Path $RepoRoot 'build\vm_porting\smoke_runner'
New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Log = Join-Path $OutRoot ("run_{0}_{1}_{2}.txt" -f $Fixture, $Target, $Stamp)

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

Write-Log ("GROK-BOT-VM-PATHA-22 run_vm_patha_smoke Fixture={0} Target={1}" -f $Fixture, $Target)
Write-Log ("RepoRoot={0} Log={1}" -f $RepoRoot, $Log)

function Run-Mir-PrintTree {
    $c2m = Join-Path $RepoRoot 'build\vm\mir-build\c2m'
    if (-not (Test-Path -LiteralPath $c2m)) { Add-Result 'mir' 'SKIP' 0 'missing c2m'; return }
    if (-not (Test-Wsl)) { Add-Result 'mir' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'C2M=build/vm/mir-build/c2m','OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$C2M" lm1/build/printTree.lm1.c -ei','echo PRINTTREE_EI=$?',
        '"$C2M" lm1/build/make.lm1.c -ei mkdir "$OUT/from_mir_make"','echo MAKE_EI=$?',
        '"$C2M" lm1/build/make.lm1.c -S -o "$OUT/make.mir"',
        'build/vm/mir-build/m2b < "$OUT/make.mir" > "$OUT/make.bmir"',
        'build/vm/mir-build/b2m < "$OUT/make.bmir" > "$OUT/make.round.mir"',
        'echo ROUNDTRIP=$?','wc -c "$OUT/make.mir" "$OUT/make.bmir"'
    ) -join $nl
    $r = Invoke-WslBash 'mir' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree' -and $r.Output -match 'MAKE_EI=0') {
        Add-Result 'mir' 'OK' 0 'printTree -ei + make -ei + m2b/b2m'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'mir' 'FAIL' $code 'see log'
    }
}

function Run-Wasm-PrintTree {
    $clang = Join-Path $RepoRoot 'build\vm\wasi-sdk-34.0-x86_64-linux\bin\clang'
    $wt = Join-Path $RepoRoot 'build\vm\wasmtime-v48.0.2-x86_64-linux\wasmtime'
    if (-not ((Test-Path $clang) -and (Test-Path $wt))) { Add-Result 'wasm' 'SKIP' 0 'missing wasi/wasmtime'; return }
    if (-not (Test-Wsl)) { Add-Result 'wasm' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'CLANG=build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang',
        'WT=build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$CLANG" --target=wasm32-wasip1 -std=c99 -Wall -I. -Ilm1 -Il1src -o "$OUT/printTree.wasm" lm1/build/printTree.lm1.c',
        'echo CC=$?','"$WT" "$OUT/printTree.wasm"','echo RUN=$?','wc -c "$OUT/printTree.wasm"'
    ) -join $nl
    $r = Invoke-WslBash 'wasm' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree') {
        Add-Result 'wasm' 'OK' 0 'printTree.wasm build+run'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'wasm' 'FAIL' $code 'see log'
    }
}

function Run-Riscv-PrintTree {
    $gcc = Join-Path $RepoRoot 'build\vm\riscv\bin\riscv64-unknown-linux-gnu-gcc'
    $qemu = Join-Path $RepoRoot 'build\vm\qemu-user-static-root\usr\bin\qemu-riscv64-static'
    if (-not ((Test-Path $gcc) -and (Test-Path $qemu))) { Add-Result 'riscv' 'SKIP' 0 'missing riscv/qemu'; return }
    if (-not (Test-Wsl)) { Add-Result 'riscv' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc',
        'QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SYSROOT=$("$GCC" -print-sysroot)',
        '"$GCC" -std=c99 -Wall -O2 -I. -Ilm1 -Il1src -o "$OUT/printTree_rv.elf" lm1/build/printTree.lm1.c',
        'echo CC=$?','"$QEMU" -L "$SYSROOT" "$OUT/printTree_rv.elf"','echo RUN=$?','wc -c "$OUT/printTree_rv.elf"'
    ) -join $nl
    $r = Invoke-WslBash 'riscv' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: printTree') {
        Add-Result 'riscv' 'OK' 0 'printTree_rv.elf + qemu'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'riscv' 'FAIL' $code 'see log'
    }
}

function Run-Mir-Own {
    $c2m = Join-Path $RepoRoot 'build\vm\mir-build\c2m'
    if (-not (Test-Path -LiteralPath $c2m)) { Add-Result 'mir' 'SKIP' 0 'missing c2m'; return }
    if (-not (Test-Wsl)) { Add-Result 'mir' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'C2M=build/vm/mir-build/c2m','OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$C2M" -I. -Ilm1/build include_languages/vm/own_harness_main.c lm1/build/own.lm1.c -ei','echo OWN_EI=$?'
    ) -join $nl
    $r = Invoke-WslBash 'mir_own' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_OWN_OK checks=') { Add-Result 'mir' 'OK' 0 'own harness -ei' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'mir' 'FAIL' $code 'see log' }
}

function Run-Wasm-Own {
    $clang = Join-Path $RepoRoot 'build\vm\wasi-sdk-34.0-x86_64-linux\bin\clang'
    $wt = Join-Path $RepoRoot 'build\vm\wasmtime-v48.0.2-x86_64-linux\wasmtime'
    if (-not ((Test-Path $clang) -and (Test-Path $wt))) { Add-Result 'wasm' 'SKIP' 0 'missing wasi/wasmtime'; return }
    if (-not (Test-Wsl)) { Add-Result 'wasm' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'CLANG=build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang',
        'WT=build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$CLANG" --target=wasm32-wasip1 -std=c99 -Wall -O2 -I. -Ilm1/build -o "$OUT/own.wasm" include_languages/vm/own_harness_main.c lm1/build/own.lm1.c',
        'echo CC=$?','"$WT" "$OUT/own.wasm"','echo RUN=$?'
    ) -join $nl
    $r = Invoke-WslBash 'wasm_own' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_OWN_OK checks=') { Add-Result 'wasm' 'OK' 0 'own.wasm build+run' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'wasm' 'FAIL' $code 'see log' }
}

function Run-Riscv-Own {
    $gcc = Join-Path $RepoRoot 'build\vm\riscv\bin\riscv64-unknown-linux-gnu-gcc'
    $qemu = Join-Path $RepoRoot 'build\vm\qemu-user-static-root\usr\bin\qemu-riscv64-static'
    if (-not ((Test-Path $gcc) -and (Test-Path $qemu))) { Add-Result 'riscv' 'SKIP' 0 'missing riscv/qemu'; return }
    if (-not (Test-Wsl)) { Add-Result 'riscv' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc',
        'QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SYSROOT=$("$GCC" -print-sysroot)',
        '"$GCC" -std=c99 -Wall -O2 -I. -Ilm1/build -o "$OUT/own_rv.elf" include_languages/vm/own_harness_main.c lm1/build/own.lm1.c',
        'echo CC=$?','"$QEMU" -L "$SYSROOT" "$OUT/own_rv.elf"','echo RUN=$?'
    ) -join $nl
    $r = Invoke-WslBash 'riscv_own' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_OWN_OK checks=') { Add-Result 'riscv' 'OK' 0 'own_rv.elf + qemu' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'riscv' 'FAIL' $code 'see log' }
}

function Run-Mir-Parser {
    $c2m = Join-Path $RepoRoot 'build\vm\mir-build\c2m'
    if (-not (Test-Path -LiteralPath $c2m)) { Add-Result 'mir' 'SKIP' 0 'missing c2m'; return }
    if (-not (Test-Wsl)) { Add-Result 'mir' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'C2M=build/vm/mir-build/c2m','OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$C2M" -I. -Ilm1/build include_languages/vm/parser_harness_main.c lm1/build/parser.lm1.c -ei','echo PARSER_EI=$?'
    ) -join $nl
    $r = Invoke-WslBash 'mir_parser' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_PARSER_OK checks=') { Add-Result 'mir' 'OK' 0 'parser harness -ei' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'mir' 'FAIL' $code 'see log' }
}

function Run-Wasm-Parser {
    $clang = Join-Path $RepoRoot 'build\vm\wasi-sdk-34.0-x86_64-linux\bin\clang'
    $wt = Join-Path $RepoRoot 'build\vm\wasmtime-v48.0.2-x86_64-linux\wasmtime'
    if (-not ((Test-Path $clang) -and (Test-Path $wt))) { Add-Result 'wasm' 'SKIP' 0 'missing wasi/wasmtime'; return }
    if (-not (Test-Wsl)) { Add-Result 'wasm' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'CLANG=build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang',
        'WT=build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        '"$CLANG" --target=wasm32-wasip1 -std=c99 -Wall -Wno-unused-parameter -O2 -I. -Ilm1/build -o "$OUT/parser.wasm" include_languages/vm/parser_harness_main.c lm1/build/parser.lm1.c',
        'echo CC=$?','"$WT" "$OUT/parser.wasm"','echo RUN=$?'
    ) -join $nl
    $r = Invoke-WslBash 'wasm_parser' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_PARSER_OK checks=') { Add-Result 'wasm' 'OK' 0 'parser.wasm build+run' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'wasm' 'FAIL' $code 'see log' }
}

function Run-Riscv-Parser {
    $gcc = Join-Path $RepoRoot 'build\vm\riscv\bin\riscv64-unknown-linux-gnu-gcc'
    $qemu = Join-Path $RepoRoot 'build\vm\qemu-user-static-root\usr\bin\qemu-riscv64-static'
    if (-not ((Test-Path $gcc) -and (Test-Path $qemu))) { Add-Result 'riscv' 'SKIP' 0 'missing riscv/qemu'; return }
    if (-not (Test-Wsl)) { Add-Result 'riscv' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc',
        'QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SYSROOT=$("$GCC" -print-sysroot)',
        '"$GCC" -std=c99 -Wall -Wno-unused-parameter -O2 -I. -Ilm1/build -o "$OUT/parser_rv.elf" include_languages/vm/parser_harness_main.c lm1/build/parser.lm1.c',
        'echo CC=$?','"$QEMU" -L "$SYSROOT" "$OUT/parser_rv.elf"','echo RUN=$?'
    ) -join $nl
    $r = Invoke-WslBash 'riscv_parser' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'VM_PARSER_OK checks=') { Add-Result 'riscv' 'OK' 0 'parser_rv.elf + qemu' }
    else { $code = $r.Exit; if ($code -eq 0) { $code = 1 }; Add-Result 'riscv' 'FAIL' $code 'see log' }
}


function Run-Mir-L1trans {
    $c2m = Join-Path $RepoRoot 'build\vm\mir-build\c2m'
    if (-not (Test-Path -LiteralPath $c2m)) { Add-Result 'mir' 'SKIP' 0 'missing c2m'; return }
    if (-not (Test-Wsl)) { Add-Result 'mir' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'C2M=build/vm/mir-build/c2m','OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SRC=dev/l2src_sandbox/tests/own_array_count_define.h.lm1',
        'set +e',
        '"$C2M" -I. -Ilm1/build lm1/build/l1trans.lm1.c -ei','echo USAGE_EI=$?',
        'rm -f "$OUT/l1trans_mir_tiny.out.c"',
        '"$C2M" -I. -Ilm1/build lm1/build/l1trans.lm1.c -ei "$SRC" "$OUT/l1trans_mir_tiny.out.c"','echo TRANS_EI=$?',
        'grep -q "L2_TEST_OWN_COUNT 8" "$OUT/l1trans_mir_tiny.out.c" && echo TRANS_OK=1 || echo TRANS_OK=0'
    ) -join $nl
    $r = Invoke-WslBash 'mir_l1trans' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: l1trans' -and $r.Output -match 'TRANS_EI=0' -and $r.Output -match 'TRANS_OK=1') {
        Add-Result 'mir' 'OK' 0 'l1trans -ei usage + tiny translate'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'mir' 'FAIL' $code 'see log'
    }
}

function Run-Wasm-L1trans {
    $clang = Join-Path $RepoRoot 'build\vm\wasi-sdk-34.0-x86_64-linux\bin\clang'
    $wt = Join-Path $RepoRoot 'build\vm\wasmtime-v48.0.2-x86_64-linux\wasmtime'
    if (-not ((Test-Path $clang) -and (Test-Path $wt))) { Add-Result 'wasm' 'SKIP' 0 'missing wasi/wasmtime'; return }
    if (-not (Test-Wsl)) { Add-Result 'wasm' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'CLANG=build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang',
        'WT=build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SRC=dev/l2src_sandbox/tests/own_array_count_define.h.lm1',
        '"$CLANG" --target=wasm32-wasip1 -std=c99 -Wall -Wno-unused-variable -O2 -I. -Ilm1/build -o "$OUT/l1trans.wasm" lm1/build/l1trans.lm1.c',
        'echo CC=$?','set +e',
        '"$WT" --dir=. "$OUT/l1trans.wasm"','echo USAGE=$?',
        'mkdir -p "$OUT/l1trans_unit"',
        'cp -f "$SRC" "$OUT/l1trans_unit/tiny.lm1"',
        'rm -f "$OUT/l1trans_wasm_tiny.out.c"',
        '"$WT" --dir=. "$OUT/l1trans.wasm" "$OUT/l1trans_unit/tiny.lm1" "$OUT/l1trans_wasm_tiny.out.c"','echo TRANS=$?',
        'grep -q "L2_TEST_OWN_COUNT 8" "$OUT/l1trans_wasm_tiny.out.c" && echo TRANS_OK=1 || echo TRANS_OK=0'
    ) -join $nl
    $r = Invoke-WslBash 'wasm_l1trans' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: l1trans' -and $r.Output -match 'TRANS=0' -and $r.Output -match 'TRANS_OK=1') {
        Add-Result 'wasm' 'OK' 0 'l1trans.wasm usage + tiny translate'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'wasm' 'FAIL' $code 'see log'
    }
}

function Run-Riscv-L1trans {
    $gcc = Join-Path $RepoRoot 'build\vm\riscv\bin\riscv64-unknown-linux-gnu-gcc'
    $qemu = Join-Path $RepoRoot 'build\vm\qemu-user-static-root\usr\bin\qemu-riscv64-static'
    if (-not ((Test-Path $gcc) -and (Test-Path $qemu))) { Add-Result 'riscv' 'SKIP' 0 'missing riscv/qemu'; return }
    if (-not (Test-Wsl)) { Add-Result 'riscv' 'SKIP' 0 'WSL required'; return }
    $nl = [char]10
    $body = @(
        '#!/bin/bash','set -e','cd /mnt/c/Nyasha_Planet/LMX',
        'GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc',
        'QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static',
        'OUT=build/vm_porting/smoke_runner','mkdir -p "$OUT"',
        'SRC=dev/l2src_sandbox/tests/own_array_count_define.h.lm1',
        'SYSROOT=$("$GCC" -print-sysroot)',
        '"$GCC" -std=c99 -Wall -Wno-unused-variable -O2 -I. -Ilm1/build -o "$OUT/l1trans_rv.elf" lm1/build/l1trans.lm1.c',
        'echo CC=$?','set +e',
        '"$QEMU" -L "$SYSROOT" "$OUT/l1trans_rv.elf"','echo USAGE=$?',
        'rm -f "$OUT/l1trans_riscv_tiny.out.c"',
        '"$QEMU" -L "$SYSROOT" "$OUT/l1trans_rv.elf" "$SRC" "$OUT/l1trans_riscv_tiny.out.c"','echo TRANS=$?',
        'grep -q "L2_TEST_OWN_COUNT 8" "$OUT/l1trans_riscv_tiny.out.c" && echo TRANS_OK=1 || echo TRANS_OK=0'
    ) -join $nl
    $r = Invoke-WslBash 'riscv_l1trans' $body
    if ($r.Exit -eq 0 -and $r.Output -match 'usage: l1trans' -and $r.Output -match 'TRANS=0' -and $r.Output -match 'TRANS_OK=1') {
        Add-Result 'riscv' 'OK' 0 'l1trans_rv.elf + qemu usage + tiny translate'
    } else {
        $code = $r.Exit; if ($code -eq 0) { $code = 1 }
        Add-Result 'riscv' 'FAIL' $code 'see log'
    }
}
function Run-Mir {
    if ($Fixture -eq 'own') { Run-Mir-Own }
    elseif ($Fixture -eq 'parser') { Run-Mir-Parser }
    elseif ($Fixture -eq 'l1trans') { Run-Mir-L1trans }
    else { Run-Mir-PrintTree }
}
function Run-Wasm {
    if ($Fixture -eq 'own') { Run-Wasm-Own }
    elseif ($Fixture -eq 'parser') { Run-Wasm-Parser }
    elseif ($Fixture -eq 'l1trans') { Run-Wasm-L1trans }
    else { Run-Wasm-PrintTree }
}
function Run-Riscv {
    if ($Fixture -eq 'own') { Run-Riscv-Own }
    elseif ($Fixture -eq 'parser') { Run-Riscv-Parser }
    elseif ($Fixture -eq 'l1trans') { Run-Riscv-L1trans }
    else { Run-Riscv-PrintTree }
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
