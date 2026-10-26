Corrected warm diagnostic context, same source4420D037/FE2B96E69A/13exports as check05.
Checks01–05 incorrectly ran with a fresh empty working directory: relative
predef paths containing l2src/ are NOT rebased by l2_predef_import; snapshot
reader fopen uses CWD. Missing ABI headers made fnptr locals unrecognised.
This is a diagnostic setup error, not proof that ordinary recipe has that defect.
Recipe bld_machine_module uses src as cwd. Reproduce it in a fresh run-context:
existing language stage-copy64 seeded declarations to runs/driver-check06/src;
copy exact maintained src/l1src/libc_abi.lm1 as an additional declared ABI input.
No header edits or implicit repo fallback. Fresh cwd runs/driver-check06/src.
FE --library [same13 machine exports] --header pins/driver-check06.h.lm1
src/l2src/l2_driver.lm2 src/l2src/convert.lm2 src/l2src/primitive.lm2 pins/driver-check06.lm1
Only this L2 translation; no C/runtime/whole-bootstrap result.
