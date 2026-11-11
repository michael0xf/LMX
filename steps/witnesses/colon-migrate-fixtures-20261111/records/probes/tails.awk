# usage: awk -f tails.awk CENSUS   (run from the repo root; reads selfbuild/<path> for each site)
# One line per site: kinds(routes) TAB file:line TAB head TAB tail-class TAB the source line.
BEGIN { FS = "\t" }
{
    f = $3; sub(/.*\/fable-main01\//, "", f); sub(/^tests\/\.\.\//, "", f)
    k = f "\t" $4 "\t" $5
    if (!(k in seen)) { seen[k] = 1; order[++n] = k; head[k] = $9; hl[k] = $7 }
    kinds[k] = kinds[k] " " $1 ":" $2
}
END {
    for (i = 1; i <= n; i++) {
        k = order[i]; split(k, p, "\t")
        file = "selfbuild/" p[1]; line = p[2] + 0; col = p[3] + 0
        if (file != cur) { if (cur != "") close(cur); cur = file; ln = 0; delete text; while ((getline s < file) > 0) text[++ln] = s }
        s = text[line]
        rest = substr(s, col + hl[k])
        cls = "value"
        if (substr(rest, 1, 2) != ": ") { cls = "noncolon" }
        else {
            t = substr(rest, 3)
            if (t == "") cls = "block"
            else if (substr(t, 1, 1) == "(") cls = "paren"
            else if (t ~ /^[A-Z][A-Za-z0-9_]*$/) cls = "Atom"
            else if (t ~ /^[A-Z][A-Za-z0-9_\\]*$/) cls = "AtomPath"
        }
        if (substr(rest, 1, 1) == ":" && length(rest) == 1) cls = "block"
        u = kinds[k]; m = split(u, q, " "); delete uniq; out = ""
        for (j = 1; j <= m; j++) if (!(q[j] in uniq)) { uniq[q[j]] = 1; out = out " " q[j] }
        printf "%s\t%s:%d\t%s\t%s\t%s\n", substr(out, 2), p[1], line, head[k], cls, s
    }
}
