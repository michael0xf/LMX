# Working directory: C:/Nyasha_Planet/LMX
$ErrorActionPreference='Stop'; & 'C:/Python314/python.exe' -X utf8 'tools/check_docs.py' *> 'C:/Nyasha_Planet/LMX/steps/witnesses/fix236-20261026/docs-final-check.log'; $task236Docs=$LASTEXITCODE; Write-Output ('Final docs-check exit '+$task236Docs); exit $task236Docs
