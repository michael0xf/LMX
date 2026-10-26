Unified session45474 observed terminal exit0 after one whole SHORT.
Start 2026-10-26T09:20:14Z; terminal observed before 09:55:18Z.
No restart or duplicate compilation. Nine smoke rows,0failures.
G1 build/start/hash/replace, G1 actually builds G2/start/hash/replace;
BOOTSTRAP quick0failures,13checks0roots. G2/working raw pins equal
ee945db9150389966c8a25cd5e1ea7f309cfb18be11baf2edc63f606c39ebd1b.
Both G1 and G2 object pins are7b1faf85d327cddcf824341ecb4e61e2d105f4b7c5e1800bba8b6d9c0eb971f2.
G2 L1/C expected pins were saved before G2 completed. The object equality
is a post-completion observation, not a previously saved expectation.
FreeVirtualMemory311952KiB was observed near final compilation; no new
compiler launched. After terminal it recovered to966544KiB.
Read-only source review found no material regression. Pure shape readers
do not increment classified; invalid NAMED/order refs_out is now0, and
both callers consume refs only on OK. Common admission remains unchanged.
