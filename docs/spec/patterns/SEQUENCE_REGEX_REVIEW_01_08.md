# Current sequence / Pattern / core review: groups 01–08

Date: 2026-11-22. All **91** current records were read against their full scenario and expected observations. Only current uploaded source was used.

## Selected shorter variants

Four ordinary Expression simplifications preserve all fields and observations. They introduce no unmeasured library dependency. Complete previous LMX listings remain in JSON, a separate Markdown code fence and commented standalone source.

| ID | Before | After | Saved |
| ---: | ---: | ---: | ---: |
| 007 | 354 | 342 | 12 |
| 070 | 158 | 149 | 9 |
| 075 | 278 | 266 | 12 |
| 078 | 184 | 175 | 9 |

## Why the other examples remain

No Pattern-based replacement was selected merely to insert the new API into an unrelated architectural example. The direct regex implementation and acceptance fixtures are linked in [REGEX_IMPLEMENTATION](LMX_Fn_Receivers/REGEX_IMPLEMENTATION.md). The serial/transport examples continue using Message and the documented HTTP ports. Local map/fold cannot substitute for their delivery, transaction, cancellation or acknowledgement protocols.

Status-based retry with exponential delay is not generic exception retry. A field-sharing Type Object is not a copy/derive operation. A persistent cache cannot be replaced by a computed DATA initializer that creates a fresh wrapper for each call. DTO projection must retain the exact named fields and exclude the secret and methods. Specification construction retains its explicitly copied owner; no unsupported assumption about node ownership is used to declare the existing code wrong.

The measured companion implementations remain implementations. Replacing their bodies with calls to a ready high-level library would move the comparison boundary. The 095 ownership-sensitive spelling was retained, and no previous variant or explanatory code was removed.

## Full decision record

[Machine-readable record for all 91 entries](validation/sequence_regex_review_01_08.json). It contains the considered APIs, concrete reason, source hash and selected count for every current entry. Full CSV/XLSX/PDF statistics must be regenerated afterwards by the existing publication tools. This review did not execute LMX or control programs.
