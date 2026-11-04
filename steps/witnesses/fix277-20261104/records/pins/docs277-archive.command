try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# Opus, slice 277. Copies the named text receipts into the slice record: decoded by their BOM, CRLF to LF, no BOM,
# no terminal colour sequences (a failed pwsh recipe prints them into a receipt), no trailing blanks, one final newline.
# Originals stay untouched and bound by evidence.sha256. Parameter: TP_LIST.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$rec='C:\Nyasha_Planet\LMX\steps\witnesses\fix277-20261104\records'
$list=$env:TP_LIST
if (-not $list) { throw 'TP_LIST' }
$enc=New-Object System.Text.UTF8Encoding $false
$n=0
foreach ($rel in @(Get-Content -LiteralPath $list | Where-Object { $_ -ne '' })) {
  if ($rel -like '*l2_driver_launch.err*') { throw 'protected basename' }
  $src=Join-Path $p ($rel -replace '/','\')
  if (-not (Test-Path -LiteralPath $src)) { throw ('missing ' + $rel) }
  $b=[IO.File]::ReadAllBytes($src)
  if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { $t=[Text.Encoding]::Unicode.GetString($b, 2, $b.Length - 2) }
  elseif ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $t=$enc.GetString($b, 3, $b.Length - 3) }
  else { $t=$enc.GetString($b) }
  $t=$t.Replace("`r`n","`n")
  $t=[regex]::Replace($t, '\x1b\[[0-9;]*m', '')
  $t=[regex]::Replace($t, '[ \t]+(?=\n|\z)', '')
  $t=$t.TrimEnd("`n") + "`n"
  $dst=Join-Path $rec ($rel -replace '/','\')
  $dir=[IO.Path]::GetDirectoryName($dst)
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if (Test-Path -LiteralPath $dst) { throw ('exists ' + $rel) }
  [IO.File]::WriteAllText($dst, $t, $enc)
  $n++
}
Write-Output ('ARCHIVE277 ' + $n + ' files')
