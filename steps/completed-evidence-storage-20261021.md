# Completed evidence storage — recoverable deduplication

Scope:known,terminal old build outputs only. No source,WIP,logs,red
witnesses or then-live full112 outputs were removed. The forbidden
`l2_driver_launch.err` was never read,hashed,copied or selected.

## Exact immutable generated artifacts

`build/codex_completed_gen_dedup_114_01/results.json` records6778 completed
`.c/.lm1/.o` files in109/100/97/95 sharing backing with byte-identical103
files. SHA and streamed byte comparison were checked before and after.
All original paths and byte streams remain;logical duplicate bytes are
2,992,513,341. These are not measured free-space savings:concurrent full112
writes overlap capacity observations. **Never edit these linked completed
artifacts in-place;copy to a fresh path before any change.**

After full112 was terminal (never while live),the same transactional
procedure compared its generated artifacts with terminal109:
`build/codex_completed_gen_dedup_115_01/results.json`,1878 exact immutable
files,789,208,709 logical duplicate bytes. Every original112/109 path,byte
stream and pinned SHA remains. This later receipt is terminal0 too;do not
rerun either dedup recipe blindly.

## Old successful executables

Only original `OK fixture:` executables were selected from terminal100,
103,97 and95. Red witnesses,compilers,current pins and key returned-node/
third-candidate controls were excluded before archive creation. Each
version's manifest pins every original name,length and SHA. Archive creation
rehashes the source;verification streams every member and checks its length
and SHA,then an actual one-file restore proves recovery before deleting the
separate original successful executables.

| Version | Recoverable original executables | Original bytes | tar.xz bytes | Archive SHA256 |
| --- | ---: | ---: | ---: | --- |
| 100 | 1988 | 1089477338 | 33708668 | 2C990CCB5859717CCA443EB08B47EFE9D4F4C66996194CA29FF37716FCC8B155 |
| 103 | 1992 | 1091609452 | 33778216 | 3BC6FAF6192C0776B6E0CD393EFEE8374200BB3407F3801BE1DE16F8DBBB6645 |
| 97 | 1992 | 1091599724 | 33777268 | A79F1D185E8635C2CA58C6C1FECC8A2A68389A24121AC3C6DA2B681CE9065FB4 |
| 95 | 1969 | 1079254025 | 33420496 | 9035208499F1C4AEB030B84AE67779B3AABD6A7D1D03AC2BA0F6DE6425104F60 |

Total7941 old successful executable paths have been archived,not preserved
as loose files. Their bytes are recoverable. Source/generated C/L1/objects,
logs and failing binaries remain at their original paths. A later evidence
check requiring an archived binary must restore it first,not call its absent
loose path unchanged or count an archive as a new execution.

Archive/manifest/verified and completed receipts are under
`build/codex_completed_bins_archive_114_01/<version>/`.
Helper:`build/codex_completed_bins_archive_114.py`;recipe114_01 is terminal0.
Restore all absent100 binaries (no overwrites):

```powershell
python build/codex_completed_bins_archive_114.py restore C:/Nyasha_Planet/LMX/build/codex_completed_bins_archive_114_01/100/manifest.json
```

Use `--name unit_example.exe` for one exact manifest member;substitute the
version directory for another completed archive. No restoration is needed
for source/comparison work. The archive and restore-probe copies themselves
are preserved. Do not blindly rerun the archival recipe.
