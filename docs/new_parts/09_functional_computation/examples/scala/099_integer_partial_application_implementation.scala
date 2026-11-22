object Partial {
  def partial[A, B, R](binary: (A, B) => R, first: A): B => R =
    second => binary(first, second)
}
