object CurryingExample {
  val add: (Int, Int) => Int = (saved, x) => saved + x
  val curried: Int => Int => Int = add.curried

  def demo: Int = {
    val add5 = curried(5)
    val add100 = curried(100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
