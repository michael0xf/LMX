$ErrorActionPreference = 'Stop'
$lmxDevRepo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$lmxDevVenv = Join-Path $lmxDevRepo 'build2/lmx_dev/venv'
$lmxDevPython = Join-Path $lmxDevVenv 'Scripts/python.exe'
if (-not (Test-Path -LiteralPath $lmxDevPython)) {
    python -m venv $lmxDevVenv
    if ($LASTEXITCODE -ne 0) { throw 'venv creation failed' }
}
& $lmxDevPython -m pip install -r (Join-Path $PSScriptRoot 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'dependency installation failed' }
Write-Host "Installed. MCP stdio: $lmxDevPython $PSScriptRoot/entry.py serve"
Write-Host 'Compiler actions remain closed until the lead grants a window.'
