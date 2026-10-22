#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo='C:/Nyasha_Planet/LMX';$stage="$repo/build2/codex_application_values161"
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline; do not duplicate live checks'}
& "$stage/application.ps1" -Frontend frontend-05 -Label application-08
& "$stage/named-values.ps1" -Frontend frontend-05 -Label named-order-old-01 -CompilerPath "$repo/build2/codex_primary_children160/frontend-04/l2trans.exe" -SourceFile named-order.lm2 -ForcedBodies 28
& "$stage/named-values.ps1" -Frontend frontend-05 -Label named-order-01 -SourceFile named-order.lm2 -ForcedBodies 28
& "$stage/named-values.ps1" -Frontend frontend-05 -Label named-prefix-old-01 -CompilerPath "$repo/build2/codex_primary_children160/frontend-04/l2trans.exe" -SourceFile named-prefix.lm2 -ForcedBodies 3
& "$stage/named-values.ps1" -Frontend frontend-05 -Label named-prefix-01 -SourceFile named-prefix.lm2 -ForcedBodies 3
