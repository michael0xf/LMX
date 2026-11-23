object Partial {
  final case class Callable[Inputs <: Tuple, Result](invoke: Inputs => Result)

  def partial[Prefix <: Tuple, Rest <: Tuple, Result](
      operation: Callable[Tuple.Concat[Prefix, Rest], Result],
      prefix: Prefix): Callable[Rest, Result] =
    Callable(rest => operation.invoke(prefix ++ rest))
}
