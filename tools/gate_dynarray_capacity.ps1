param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
$sandbox = Join-Path $Root 'dev\l2src_sandbox'
$bad = New-Object System.Collections.Generic.List[string]
$files = @()
$files += Get-ChildItem -LiteralPath $sandbox -File -Filter '*.lm1'
$tests = Join-Path $sandbox 'tests'
if (Test-Path -LiteralPath $tests) { $files += Get-ChildItem -LiteralPath $tests -File -Filter '*.lm1' }
foreach ($f in $files) {
  $rel = $f.FullName.Substring($sandbox.Length).TrimStart('\','/')
  $lines = Get-Content -LiteralPath $f.FullName
  $struct = $null
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*struct:\s+(\w+)') { $struct = $Matches[1]; continue }
    if ($struct -ne $null -and $line -match ("^\s*end:\s+" + [regex]::Escape($struct) + "\s*$")) { $struct = $null; continue }
    if ($null -eq $struct) { continue }
    if ($line -match '^\s*size_t:\s*capacity\b') {
      if ($struct -like '*DynamicArray') { continue }
      $bad.Add(("{0}:{1}: in struct {2}: {3}" -f $rel, ($i+1), $struct, $line.Trim())) | Out-Null
    }
  }
}

# Author 2026-09-24 / FABLE-140: LmxByteArray is a removed twin of LmxCharArray.
# Active sandbox sources and tests must not spell the old names (blog/plan history may).
$banned = @('LmxByteArray', 'LmxByteDynamicArray')
foreach ($f in $files) {
  $rel = $f.FullName.Substring($sandbox.Length).TrimStart('\','/')
  $i = 0
  foreach ($line in (Get-Content -LiteralPath $f.FullName)) {
    $i++
    foreach ($name in $banned) {
      if ($line.Contains($name)) {
        $bad.Add(("{0}:{1}: banned name {2}" -f $rel, $i, $name)) | Out-Null
      }
    }
  }
}
if ($bad.Count -gt 0) {
  Write-Output 'GATE FAIL: dynarray capacity / banned ByteArray names:'
  $bad | ForEach-Object { Write-Output ('  ' + $_) }
  exit 1
}
Write-Output 'GATE OK: capacity fields only on *DynamicArray; no LmxByteArray / LmxByteDynamicArray'
exit 0
