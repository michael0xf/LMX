import scala.util.control.{ControlThrowable, NonFatal}

object Around {
  private def severity(error: Throwable): Int = error match {
    case _: VirtualMachineError => 5
    case _: LinkageError => 4
    case _: InterruptedException | _: ThreadDeath => 3
    case _: ControlThrowable => 1
    case NonFatal(_) => 0
    case _ => 2
  }
  private def combine(first: Throwable, second: Throwable): Throwable = {
    val (primary, secondary) =
      if (severity(second) > severity(first)) (second, first)
      else (first, second)
    if (primary ne secondary) primary.addSuppressed(secondary)
    primary
  }
  def bracket[R, A](acquire: () => R,
                    release: R => Unit,
                    action: R => A): A = {
    val resource = acquire()
    if (resource == null) throw new NullPointerException("resource")
    var primary: Throwable = null
    try action(resource)
    catch {
      case error: Throwable => primary = error; throw error
    } finally {
      try release(resource)
      catch {
        case cleanup: Throwable =>
          if (primary == null) throw cleanup
          else throw combine(primary, cleanup)
      }
    }
  }
}
