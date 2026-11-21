object BounceBool {
  enum Bounce {
    case Done(answer: Boolean)
    case More(next: Int => Bounce, argument: Int)
  }
  def done(answer: Boolean): Bounce = Bounce.Done(answer)
  def more(next: Int => Bounce, argument: Int): Bounce =
    Bounce.More(next, argument)
  @annotation.tailrec
  def run(current: Bounce): Boolean = current match {
    case Bounce.Done(answer) => answer
    case Bounce.More(next, argument) => run(next(argument))
  }
}
