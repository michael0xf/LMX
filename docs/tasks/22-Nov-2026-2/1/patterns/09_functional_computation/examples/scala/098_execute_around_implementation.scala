object Around {
  def bracket[R, A](acquire: () => R,
                   release: R => Unit,
                   action: R => A): A = {
    val resource = acquire()
    try action(resource)
    finally release(resource)
  }
}
