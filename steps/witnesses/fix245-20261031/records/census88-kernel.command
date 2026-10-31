try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Translation census of the kernel with boot88's G1 frontend (built from the
# green-line sources), after boot88 stopped at G1 runtime step 5 on
# lmx_pool.lm2:150:12 "assignment value has unknown type". The exact 36
# kernel/driver commands of RT86w3's record (same kernel sources as boot88,
# translated there by 49c) are rerun with ONLY the frontend executable
# replaced and the two outputs (--header and the .lm1) redirected into a
# private directory; the CWD is stage86w's src as in the recipe, so its
# generated headers are read and nothing in any stage is written. Records the
# exit and the first diagnostic of every module.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$fe="$P2/cold-boot88/quick88/g1/frontend/l2trans.exe"
$out="$p\census88-kernel-01"
$term="$p\pins\census88-kernel.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $term)) { throw 'exists' }
New-Item -ItemType Directory -Path $out | Out-Null
$lines = Get-Content -LiteralPath "$p\cold-candidate86w\rt86w3\record.txt" | Where-Object { $_.StartsWith('$ ') -and $_.Contains('fe49c/l2trans.exe') }
if ($lines.Count -ne 36) { throw ('commands ' + $lines.Count) }
Set-Location -LiteralPath "$p\cold-candidate86w\src"
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$k = 0
foreach ($line in $lines) {
  $k++
  $tok = $line.Substring(2).Split(' ')
  $argv = New-Object System.Collections.Generic.List[string]
  for ($i = 1; $i -lt $tok.Count; $i++) {
    $t = $tok[$i]
    if ($t -match '[\\/]src[\\/]l2src[\\/]([A-Za-z0-9_]+)\.(h\.lm1|lm1)$') {
      $argv.Add("$P2/census88-kernel-01/" + $Matches[1] + '.' + $Matches[2])
    } else {
      $argv.Add($t)
    }
  }
  $mod = ($tok | Where-Object { $_ -match '\.lm2$' } | Select-Object -First 1) -replace '^.*[\\/]',''
  $log = "$out\$k-$mod.log"
  & $fe @argv *> $log
  $e = $LASTEXITCODE
  $first = (Get-Content -LiteralPath $log -TotalCount 1)
  Add-Content -LiteralPath $term -Value ("{0:D2} {1} exit={2} {3}" -f $k, $mod, $e, $first) -Encoding utf8
}
Write-Output ('CENSUS88 ' + $k + ' modules')
