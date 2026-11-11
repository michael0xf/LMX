# A reading of the text, not the mechanism: the statements of the machine sources whose head stands before a
# colon-and-space outside brackets and quotes and is neither a word of the language, a receiver, a name the C door
# gives (c.NAME) nor a function or sub the sources define (a call written with a colon).  After the migration such a
# line may only be a form the census names as defining (kinds 6-10).
# usage: awk -f text-check.awk NAMES FILE...   NAMES holds one defined function or sub name per line.
BEGIN {
    n = split("if return int end fn while size_t const predef include sub unsigned char define ulong else os win default struct type prototype immutable table test call throw throws catch for send receive break continue external sizeof long short double float signed name columns import void fm var merge cast", w, " ")
    for (i = 1; i <= n; i++) word[w[i]] = 1
    calls = 0; doors = 0; left = 0; assigns = 0
}
NR == FNR { fn[$1] = 1; next }
{
    s = $0
    sub(/^[ \t]+/, "", s)
    if (s == "" || substr(s, 1, 1) == "#") next
    # the first colon-and-space at depth 0, outside a string
    depth = 0; q = 0; p = 0; len = length(s)
    for (i = 1; i < len; i++) {
        ch = substr(s, i, 1)
        if (q) { if (ch == "\\") { i++; continue } if (ch == "\"") q = 0; continue }
        if (ch == "\"") { q = 1; continue }
        if (ch == "(" || ch == "[") { depth++; continue }
        if (ch == ")" || ch == "]") { depth--; continue }
        if (ch == " " && depth == 0 && substr(s, i, 4) == " := ") { assigns++; p = -1; break }
        if (ch == ":" && depth == 0 && substr(s, i + 1, 1) == " ") { p = i; break }
    }
    if (p <= 0) next
    h = substr(s, 1, p - 1)
    c = substr(h, 1, 1)
    if (c == "@") next
    t = h
    sub(/[^A-Za-z0-9_].*$/, "", t)
    if (t in word) next
    if (t == "c" && substr(h, 2, 1) == ".") { doors++; next }
    if (h in fn) { calls++; next }
    left++
    f = FILENAME
    sub(/^selfbuild\//, "", f)
    printf "%s:%d: %s\n", f, FNR, h
}
END { printf "statements with := before any colon: %d; calls of a defined function or sub written with a colon: %d; C door heads: %d; other heads: %d\n", assigns, calls, doors, left }
