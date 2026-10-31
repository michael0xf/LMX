try { [Console]::OutputEncoding=[System.Text.Encoding]::UTF8 } catch {}
# The unchanged tiny C-member machine module EF5C1D50 through FE82 (the 81 fix
# must survive in the Lower82 candidate). Support headers from stage82.
$p='C:\Nyasha_Planet\LMX\build2\codex_fix250generationchain01'
$P2='C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01'
$tool="$p\cold-generator62\tool62-parts\lmxtool-tool.exe"
$term="$p\pins\witness82-c-member.terminal.txt"
$fe="$p\cold-candidate82\fe82\l2trans.exe"
$w="$p\witness82-c-member-fe82"
$live=Get-CimInstance Win32_Process -Filter "Name = 'l2trans.exe' OR Name = 'l1trans.exe' OR Name = 'cc1.exe' OR Name = 'lmxtool-tool.exe'"
if ($live) { $live | Select-Object ProcessId,Name | Out-String | Write-Output; throw 'pipeline already live' }
if (-not (Test-Path -LiteralPath $fe)) { throw 'nofe82' }
if ((Test-Path -LiteralPath $term) -or (Test-Path -LiteralPath $w)) { throw 'exists' }
Remove-Item Env:CPATH,Env:C_INCLUDE_PATH,Env:CPLUS_INCLUDE_PATH,Env:LIBRARY_PATH -ErrorAction SilentlyContinue
function Note([string]$line) { Add-Content -LiteralPath $term -Value ([DateTime]::UtcNow.ToString('o') + ' ' + $line) -Encoding utf8 }
$st=@{ k = 0 }
function Tool([string[]]$a) {
  $st.k = $st.k + 1
  $nn='{0:D2}' -f $st.k
  $cwd="$p\witness82-c-member-run-$nn"
  if (Test-Path -LiteralPath $cwd) { throw "CWDexists $nn" }
  New-Item -ItemType Directory -Path $cwd | Out-Null
  Set-Location -LiteralPath $cwd
  & $tool 0 entry 0 -- @a *> "$p\pins\witness82-c-member-$nn.log"
  $e=$LASTEXITCODE
  Note ("tool $nn exit=$e " + ($a -join ' '))
  if ($e -ne 0) { throw "tool $nn exit $e" }
}
Tool @('manifest', "$P2/pins/witness81-c-member-support.list", "$P2/cold-candidate82", "$P2/pins/witness82-c-member-support.sha256")
Tool @('stage-copy', "$P2/pins/witness82-c-member-support.sha256", "$P2/cold-candidate82", "$P2/witness82-c-member-fe82")
Tool @('stage-copy', "$P2/pins/witness81-c-member-source.sha256", "$P2/variants/frontend81", "$P2/witness82-c-member-fe82/src/l2src")
Set-Location -LiteralPath "$w\src"
& $fe --library --machine probe --header l2src/unit_machine_c_member_receiving.h.lm1 l2src/unit_machine_c_member_receiving.lm2 l2src/convert.lm2 l2src/primitive.lm2 l2src/unit_machine_c_member_receiving.lm1 *> "$w\l2trans.log"
$e=$LASTEXITCODE
$feh=(Get-FileHash -Algorithm SHA256 -LiteralPath $fe).Hash
Note ("fe82 exit=$e fe=$feh cwd=$w\src")
foreach ($o in @('l2src\unit_machine_c_member_receiving.lm1','l2src\unit_machine_c_member_receiving.h.lm1')) {
  if (Test-Path -LiteralPath "$w\src\$o") { Note ("fe82 out " + (Get-FileHash -Algorithm SHA256 -LiteralPath "$w\src\$o").Hash + " $o") } else { Note ("fe82 out absent $o") }
}
Write-Output 'WITNESS82 done'
