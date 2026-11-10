# full99 G1 against quick98 G2 from their own receipts (bash; P = build2/codex_fix250generationchain01).
# Every "<sha256>  <path>" line the bootstrap printed, the stage prefix removed and the generation directory
# (full99/g1, quick98/g2) written GEN; one "path hash" pair per line; joined on the path.
# Output: fixedpoint-full99g1-quick98g2.txt (path, full99 G1, quick98 G2, equal|DIFFER|only-...) and
# pe-cmp-full99g1-quick98g2.txt (every differing byte of the two frontend image pairs, 0-based offset, octal).
P=/c/Nyasha_Planet/LMX/build2/codex_fix250generationchain01
norm() { tr -d '\r' | grep -E '^[0-9a-f]{64}  ' | sed -E 's#C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/cold-(full99|boot98)/##; s#  (full99/g1|quick98/g2)/#  GEN/#'; }
norm < "$P/pins/full99.log" | awk '{print $2, $1}' | sort -u > f99g1.txt
norm < "$P/cold-boot98/quick98/g2-build.log" | awk '{print $2, $1}' | sort -u > q98g2.txt
join -a1 -a2 -e - -o 0,1.2,2.2 f99g1.txt q98g2.txt | awk '{s = ($2 == "-") ? "only-quick98-g2" : (($3 == "-") ? "only-full99-g1" : (($2 == $3) ? "equal" : "DIFFER")); print $1, $2, $3, s}' > fixedpoint-full99g1-quick98g2.txt
for x in l2trans.exe l1trans.exe; do echo "== GEN/frontend/$x"; cmp -l "$P/cold-full99/full99/g1/frontend/$x" "$P/cold-boot98/quick98/g2/frontend/$x" | awk '{printf "%d %s %s\n", $1 - 1, $2, $3}'; done > pe-cmp-full99g1-quick98g2.txt
# PE offsets of both images: e_lfanew (bytes 60-63) = 128, "PE\0\0" at 128, COFF TimeDateStamp 136-139, PE32+
# optional header (magic 0x20b) at 152, its CheckSum at 152 + 64 = 216-219.
