package pipecomparison
func Pipe[A,B,C any](first func(A) B, second func(B) C) func(A) C {
    if first == nil || second == nil { panic("nil pipeline stage") }
    return func(value A) C { return second(first(value)) }
}
