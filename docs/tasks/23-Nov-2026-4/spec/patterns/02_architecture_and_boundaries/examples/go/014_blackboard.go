package main
type Board struct { Raw, Normalized, Result int }
func normalize(b *Board) int {
    if b.Normalized != 0 { return 0 }
    b.Normalized = b.Raw + 1
    return 1
}
func derive(b *Board) int {
    if b.Normalized == 0 || b.Result != 0 { return 0 }
    b.Result = b.Normalized * 2
    return 1
}
func demo() int {
    b := &Board{Raw: 4}
    changed := 1
    for changed != 0 { changed = derive(b) + normalize(b) }
    return b.Result
}
