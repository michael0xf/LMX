# Compare two files line by line: every changed line must be the old line with one `: ` turned into ` := `.
BEGIN { changed = 0; bad = 0 }
{
    old = $0
    if ((getline new < newfile) <= 0) { bad++; next }
    if (old == new) next
    changed++
    i = index(new, " := ")
    ok = 0
    while (i > 0) {
        cand = substr(new, 1, i - 1) ": " substr(new, i + 4)
        if (cand == old) { ok = 1; break }
        j = index(substr(new, i + 1), " := ")
        if (j == 0) break
        i = i + j
    }
    if (!ok) { bad++; if (bad <= 5) print FILENAME ":" FNR ": " old " -> " new }
}
END { if ((getline extra < newfile) > 0) bad++; printf "%d %d\n", changed, bad }
