Initial GNU --fuzz=0 replay applied all hunks but terminal assertion returned1.
The first patch headers used non-null filenames for deletions, leaving two empty old files.
This is a patch/replay metadata error, not surviving algorithm bodies or a build result.
Corrected patch uses /dev/null for the new-file old side and both deletion new sides.
Use a new replay directory from the same exact published231 archive; do not reuse the mutated first replay.
