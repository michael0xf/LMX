import Partial.partial

object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val add5 = partial(add, 5)
    val add100 = partial(add, 100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
