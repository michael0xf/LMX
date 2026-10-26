Language stage-copy session23316 terminal1: STAGE-FAIL src/l2src/l2_frontend_helpers.lm2; STAGED6 files,1 failed.
The context6-03.raw.sha256 manifest was frozen before the helper-check03 source correction; it pins the preceding B740582D helper, while actual helper-check03 is BEE1432F. This is a stale preparation manifest, not an L2/C failure.
No compiler ran in helper-check04. Do not reuse this partial destination. Generate a new actual six-file manifest from helper-check03 and copy into fresh helper-check05.
