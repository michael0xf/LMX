object MaybeValue {
  enum Value[+A] {
    case Absent extends Value[Nothing]
    case Present(value: A)
    def bind[B](next: A => Value[B]): Value[B] = this match {
      case Absent => Absent
      case Present(value) => next(value)
    }
  }
  def some[A](value: A): Value[A] = Value.Present(value)
  def none[A](): Value[A] = Value.Absent
}
