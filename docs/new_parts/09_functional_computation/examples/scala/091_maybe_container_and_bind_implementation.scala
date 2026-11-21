object MaybeInt {
  enum Value {
    case Absent
    case Present(value: Int)
    def bind(next: Int => Value): Value = this match {
      case Absent => Absent
      case Present(value) => next(value)
    }
  }
  def unit(value: Int): Value = Value.Present(value)
  def none(): Value = Value.Absent
}
