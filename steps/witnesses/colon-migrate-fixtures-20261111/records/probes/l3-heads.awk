# A reading of fixture text: statements `head: tail` (colon and space outside brackets and quotes, a tail on the
# line) whose head is no word of the language and no receiver.  Candidates for the eye, not a mechanism.
# usage: awk -f l3-heads.awk FILE...
BEGIN {
    n = split("if return int end fn while size_t const predef include sub unsigned char define ulong else os win default struct type prototype immutable table test call throw throws catch for send receive break continue external sizeof long short double float signed name columns import void fm var merge cast elif uint8_t uint16_t uint32_t uint64_t int8_t int16_t int32_t int64_t", w, " ")
    for (i = 1; i <= n; i++) word[w[i]] = 1
}
{
    s = $0
    sub(/^[ \t]+/, "", s)
    if (s == "" || substr(s, 1, 1) == "#") next
    depth = 0; q = 0; p = 0; len = length(s)
    for (i = 1; i < len; i++) {
        ch = substr(s, i, 1)
        if (q) { if (ch == "\\") { i++; continue } if (ch == "\"") q = 0; continue }
        if (ch == "\"") { q = 1; continue }
        if (ch == "(" || ch == "[") { depth++; continue }
        if (ch == ")" || ch == "]") { depth--; continue }
        if (ch == " " && depth == 0 && substr(s, i, 4) == " := ") { p = -1; break }
        if (ch == ":" && depth == 0 && substr(s, i + 1, 1) == " ") { p = i; break }
    }
    if (p <= 0) next
    h = substr(s, 1, p - 1)
    c = substr(h, 1, 1)
    if (c == "@" || c == "[") next
    t = h
    sub(/[^A-Za-z0-9_].*$/, "", t)
    if (t in word) next
    if (t == "c" && substr(h, 2, 1) == ".") next
    f = FILENAME
    sub(/^selfbuild\//, "", f)
    printf "%s:%d: %s\n", f, FNR, s
}
