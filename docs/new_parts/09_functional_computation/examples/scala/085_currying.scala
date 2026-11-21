import CurryInt.capture

object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val add5 = capture(add, 5)
    val add100 = capture(add, 100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
