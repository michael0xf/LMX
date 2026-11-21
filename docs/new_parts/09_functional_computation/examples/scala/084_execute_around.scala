object ExecuteAroundExample {
  def around[R](acquire: () => R,
                release: R => Unit,
                action: R => Int): Int = {
    val resource = acquire()
    try action(resource)
    finally release(resource)
  }
}
