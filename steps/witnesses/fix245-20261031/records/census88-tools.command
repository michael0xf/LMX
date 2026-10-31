try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Translation census of the tool sources with boot88's G1 frontend (built from
# the green-line sources), companion of census88-kernel. The two l2trans
# commands of generator85's tool record (methods part, then lmxtool.lm2) are
# rerun with ONLY the frontend executable replaced, the inputs taken from the
# boot88 stage (its tools differ from generator85's only in build.lm2), and the
# outputs redirected into a private directory. The CWD is the census's own
# src, so the only predef of the tool sources (l2src/lmxtool_methods.lm1,
# lmxtool.lm2) resolves to the census's first output; nothing in any stage is
# written. Records the exit and the first diagnostic of both commands.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$fe="$P2/cold-boot88/quick88/g1/frontend/l2trans.exe"
$out="$p\census88-tools-01"
$term="$p\pins\census88-tools.terminal.txt"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe' OR Name = 'lmxtool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if ((Test-Path -LiteralPath $out) -or (Test-Path -LiteralPath $term)) { throw 'exists' }
New-Item -ItemType Directory -Path "$out\src\l2src" | Out-Null
$rec = Get-Content -LiteralPath "$p\cold-generator85\tool85-parts\record.txt"
$lines = $rec | Where-Object { $_.StartsWith('$ ') -and $_.Contains('fe49c/l2trans.exe') }
if ($lines.Count -ne 2) { throw ('commands ' + $lines.Count) }
Set-Location -LiteralPath "$out\src"
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
$k = 0
foreach ($line in $lines) {
  $k++
  $tok = $line.Substring(2).Split(' ')
  $argv = New-Object System.Collections.Generic.List[string]
  for ($i = 1; $i -lt $tok.Count; $i++) {
    $t = $tok[$i]
    if ($t -match '/cold-generator85/src/l2src/(lmxtool_methods\.(h\.lm1|lm1))$') {
      $argv.Add("$P2/census88-tools-01/src/l2src/" + $Matches[1])
    } elseif ($t -match '/cold-generator85/tool85-parts/(lmxtool\.lm1)$') {
      $argv.Add("$P2/census88-tools-01/" + $Matches[1])
    } elseif ($t -match '/cold-generator85/((tools|src/l2src)/[A-Za-z0-9_]+\.lm2)$') {
      $argv.Add("$P2/cold-boot88/" + $Matches[1])
    } elseif ($t.StartsWith('-') -or $t -eq 'tool_main') {
      $argv.Add($t)
    } else {
      throw ('unmapped ' + $t)
    }
  }
  $mod = ($tok | Where-Object { $_ -match '\.lm2$' } | Select-Object -First 1) -replace '^.*[\\/]',''
  if ($k -eq 2 -and -not (Test-Path -LiteralPath "$out\src\l2src\lmxtool_methods.lm1")) {
    # The methods part did not translate: lmxtool.lm2 is still censused, against
    # generator85's methods L1 (written by 49c) as a stand-in predef.
    Copy-Item -LiteralPath "$p\cold-generator85\src\l2src\lmxtool_methods.lm1" -Destination "$out\src\l2src\lmxtool_methods.lm1"
    $h = (Get-FileHash -Algorithm SHA256 -LiteralPath "$out\src\l2src\lmxtool_methods.lm1").Hash
    Add-Content -LiteralPath $term -Value ('stand-in predef lmxtool_methods.lm1 from generator85 ' + $h) -Encoding utf8
  }
  $log = "$out\$k-$mod.log"
  $t0 = [DateTime]::UtcNow
  & $fe @argv *> $log
  $e = $LASTEXITCODE
  $s = [int]([DateTime]::UtcNow - $t0).TotalSeconds
  $first = (Get-Content -LiteralPath $log -TotalCount 1)
  Add-Content -LiteralPath $term -Value ("{0:D2} {1} exit={2} {3}s {4}" -f $k, $mod, $e, $s, $first) -Encoding utf8
}
Write-Output ('CENSUS88-TOOLS ' + $k + ' commands')
