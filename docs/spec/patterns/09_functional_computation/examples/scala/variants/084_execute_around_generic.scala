import Around.bracket

object ExecuteAroundExample {
  final case class Resource(value: Int)
  final class ResourceFailure extends RuntimeException
  def run(mode: Int): Int = {
    var events = 0
    def note(n: Int): Unit = { events = events * 10 + n }
    try {
      val value = bracket(
        () => {
          note(1)
          if (mode == 2) throw new ResourceFailure
          Resource(42)
        },
        (_: Resource) => note(3),
        (resource: Resource) => {
          note(2)
          if (mode == 1) throw new ResourceFailure
          resource.value
        })
      value * 1000 + events
    } catch {
      case _: ResourceFailure => -events
    }
  }
}
