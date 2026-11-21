import MaybeInt.*

object MonadExample {
  def half(x: Int): Value =
    if (x % 2 == 0) unit(x / 2) else none()
  def run(x: Int): Value = unit(x).bind(half).bind(half)
}
