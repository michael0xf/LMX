object CurryInt {
  def capture(binary: (Int, Int) => Int, first: Int): Int => Int =
    second => binary(first, second)
}
