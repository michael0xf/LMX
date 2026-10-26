Base published2251817ad625b231055c239d98b64bbfb1c378e9596, five existing
paths selected by git archive: compiler, implements, walk_values, recipe,
runtime.list. New receiving_source is introduced by the exact staged patch.
The initial GNU tar invocation treated C: as a remote host and returned128;
an unguarded subsequent patch in empty base returned1 after creating only
the new module. That failed base is preserved, not claimed as replay PASS.
Corrected fresh target build2/codex_fix226replay01/base02:
tar --force-local -xf ../base225.tar -C base02 (actual exit0)
patch --batch --fuzz=0 -p1 -i REPO/steps/witnesses/fix226-20261026/source226-from225.patch
sha256sum --check COMPONENT03/pins/canonical-source6.sha256
Both corrected replay and six raw byte checks actual exit0. No build/run.
