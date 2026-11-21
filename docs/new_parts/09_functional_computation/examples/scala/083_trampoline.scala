import scala.util.control.TailCalls.*

object TrampolineExample {
  def evenStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(true) else tailcall(oddStep(n - 1))

  def oddStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(false) else tailcall(evenStep(n - 1))

  def demo: Boolean = evenStep(100001).result
}
