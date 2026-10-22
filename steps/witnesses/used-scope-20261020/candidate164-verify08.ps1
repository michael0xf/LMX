#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_candidate_values164'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
$built=Get-Content -LiteralPath "$stage/frontend-08/results.json" -Raw|ConvertFrom-Json
foreach($case in @(@{Dir='model-08';Oracle='MODEL164: 45 checks, 0 failures'},@{Dir='reference-span-08';Oracle='REFSPAN164: 21 checks, 0 failures'})){
 $result=Get-Content -LiteralPath "$stage/$($case.Dir)/results.json" -Raw|ConvertFrom-Json
 if($result.Exit -ne 0 -or $result.FrontendCSha256 -cne $built.FrontendCSha256 -or $result.Diagnostic -notmatch [regex]::Escape($case.Oracle)){throw 'Exact completed source-model/reference fixture'}
}
& "$stage/routes.ps1" -Frontend frontend-08 -Label routes-08
& "$stage/named-refusals.ps1" -Frontend frontend-08 -Label named-refusals-08
& "$stage/values.ps1" -Frontend frontend-08 -Routes routes-08 -Label values-08
& "$stage/source-value.ps1" -Frontend frontend-08 -Label source-value-08
& "$stage/source-record.ps1" -Frontend frontend-08 -Label source-record-08
& "$stage/regress.ps1" -Frontend frontend-08 -Attempt 65 -SkipCorpus
foreach($case164 in @(@{Source='callable-current';Bodies=7},@{Source='callable-path';Bodies=5},@{Source='callable-deep';Bodies=11},@{Source='held-free-names';Bodies=23})){
 & "$stage/named-values.ps1" -Frontend frontend-08 -Label ($case164.Source+'-165') -SourceFile ($case164.Source+'.lm2') -ForcedBodies $case164.Bodies
}
& "$stage/regress-values.ps1" -Frontend frontend-08 -Attempt 65
& "$stage/source-route.ps1" -Frontend frontend-08 -Label source-route-08
Write-Output 'VERIFY164 frontend08 selected regressions TERMINAL;not whole closure'
