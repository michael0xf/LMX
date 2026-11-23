object MonadExample {
  def half(x: Int): Option[Int] =
    if (x % 2 == 0) Some(x / 2) else None
  def run(x: Int): Option[Int] = Some(x).flatMap(half).flatMap(half)
}
