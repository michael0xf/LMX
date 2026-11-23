import scala.util.Using

object ExecuteAroundExample {
  final case class Resource(value: Int)
  final class ResourceFailure extends RuntimeException
  def run(mode: Int): Int = {
    var events = 0
    def note(n: Int): Unit = { events = events * 10 + n }
    given Using.Releasable[Resource] with {
      def release(resource: Resource): Unit = note(3)
    }
    def acquire(): Resource = {
      note(1)
      if (mode == 2) throw new ResourceFailure
      Resource(42)
    }
    try {
      val value = Using.resource(acquire()) { resource =>
        note(2)
        if (mode == 1) throw new ResourceFailure
        resource.value
      }
      value * 1000 + events
    } catch {
      case _: ResourceFailure => -events
    }
  }
}
