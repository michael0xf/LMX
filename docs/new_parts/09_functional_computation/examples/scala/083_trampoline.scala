import BounceBool.*

object TrampolineExample {
  def evenStep(n: Int): Bounce =
    if (n == 0) done(true) else more(oddStep, n - 1)
  def oddStep(n: Int): Bounce =
    if (n == 0) done(false) else more(evenStep, n - 1)
  def parity(n: Int): Boolean = run(evenStep(n))
}
