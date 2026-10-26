# Working directory: C:/Nyasha_Planet/LMX
$ErrorActionPreference='Stop'; & 'C:/Python314/python.exe' -X utf8 'tools/check_docs.py' *> 'C:/Nyasha_Planet/LMX/steps/witnesses/fix236-20261026/docs-docs-check-afterindex.log'; $taskResult=$LASTEXITCODE; Write-Output ('docs-check after staging removed input exit '+$taskResult); exit $taskResult
