final class Ready {
    private boolean ready;
    private int value;
    synchronized int awaitValue() throws InterruptedException {
        while (!ready) wait();
        return value;
    }
    synchronized void publish(int next) {
        value = next; ready = true; notifyAll();
    }
}
