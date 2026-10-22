#requires -Version 7.0
$ErrorActionPreference='Stop'
$stage='C:/Nyasha_Planet/LMX/build2/codex_application_sites162'
if(Get-Process -Name gcc,cc1 -ErrorAction SilentlyContinue){throw 'One GCC pipeline'}
& "$stage/routes.ps1" -Frontend frontend-24 -Label routes-124
& "$stage/values.ps1" -Frontend frontend-24 -Label values-124 -Routes routes-124 -First 27 -Last 27
& "$stage/root-test.ps1" -Frontend frontend-24 -Label root-124 -OnlyCurrent
& "$stage/call-route.ps1" -Frontend frontend-24 -Label call-route-124 -Sources @('named-order','named-prefix','named-held','named-callable','pending-call','pending-composite','callable-current','callable-path','callable-deep')
