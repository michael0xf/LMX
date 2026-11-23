interface Coordinator {
    int acquire(int id);
    void release(int id,int token);
}
interface Resource { boolean writeIfCurrent(int token,int id); }
final class Candidate {
    static boolean attempt(Coordinator c,Resource r,int id) {
        int token=c.acquire(id);
        if (token==0) return false;
        boolean result=r.writeIfCurrent(token,id);
        c.release(id,token);
        return result;
    }
}
