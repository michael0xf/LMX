object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val curried = (add _).curried
    val add5 = curried(5)
    val add100 = curried(100)
    val saved = 1000
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
