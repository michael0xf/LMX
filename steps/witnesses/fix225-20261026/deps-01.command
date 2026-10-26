Serial GCC dependency-only readback AFTER actual wholeSHORT73839 terminal0.
No C compilation, linkage, runtime run, source rewrite or extra test campaign.
Tool C:/Qt/Tools/mingw1310_64/bin/gcc.exe SHA920A4FC669E98AD444151AFA558BBC71D1C4773AB136EE4C44374093A90C5ED1
cwd C:/Nyasha_Planet/LMX
Frontend source66C0DC22466DDBB84C915D4379CF7EF2D57DCCD12304CEF1A8E95BA1C261993D
Runtime source7BB692C53C30C6B347F2E9D003DF65CCDC84C8ACE7607B2B851FE108D229F888
Retain each actual compile's flags/include order; replace -c/-o by -MM/-MF.
Frontend includes coldheaders, BASE/includes, build2/includes, REPO,
REPO/lm1/build, coldsrc; runtime omits build2/includes as its actualrecipe did.
Outputs pins/deps-frontend-01.d and pins/deps-runtime-01.d are diagnostics,
not maintained headers, generated algorithms or another build runner.
