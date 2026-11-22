object Bounce {
  enum Value[+A] {
    case Done(answer: A)
    case More(next: () => Value[A])
  }
  def done[A](answer: A): Value[A] = Value.Done(answer)
  def more[A](next: () => Value[A]): Value[A] = Value.More(next)
  @annotation.tailrec
  def run[A](current: Value[A]): A = current match {
    case Value.Done(answer) => answer
    case Value.More(next) => run(next())
  }
}
