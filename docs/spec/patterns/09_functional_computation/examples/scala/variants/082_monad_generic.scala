import MaybeValue.*

object MonadExample {
  def half(x: Int): Value[Int] =
    if (x % 2 == 0) some(x / 2) else none()
  def run(x: Int): Value[Int] = some(x).bind(half).bind(half)
}
