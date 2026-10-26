While G2's first strictCC is still running, compare the already completed
actual G1 executable with the currently selected working binary:
Get-FileHash SHA256 boot-quick-01/tool-g1/lmxtool-tool.exe
Get-FileHash SHA256 boot-quick-01/lmxtool.exe
GNU cmp boot-quick-01/tool-g1/lmxtool-tool.exe boot-quick-01/lmxtool.exe
Both actual raw hashes D9675405278E365A8ACCBD688A8DC2A5E1733B1136F9C4F1832E9424F4EEFC29;
rawcmp actual exit0. This is the first actual tool replacement, not S8.6.
