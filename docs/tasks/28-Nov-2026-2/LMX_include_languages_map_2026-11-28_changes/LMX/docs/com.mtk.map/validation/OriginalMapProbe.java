// Verification of the supplied Java baseline, not an LMX implementation.
package com.mtk.map;
import java.lang.reflect.Modifier;
public final class OriginalMapProbe {
    private static int checks=0;
    private static void require(boolean ok,String label) {
        checks++;
        if(!ok) throw new AssertionError(label);
    }
    public static void main(String[] args) throws Exception {
        Branch root=new Branch((BaseRoot)null,7);
        Leaf shallow=new Leaf(root,0,3);
        Branch deepBranch=new Branch(root,1,5);
        Leaf deep=new Leaf(deepBranch,0,11);
        require(shallow.getLevel()==1,"shallow depth");
        require(deep.getLevel()==2,"deep depth");
        require(root.elementAt(0)==shallow && root.elementAt(1)==deepBranch,"same physical root");
        require("1.0.2".equals(deep.pathString(2)),"mixed-radix path");
        require(deep.getAddress(2)==57,"mixed-radix packed address");
        shallow.addElement("a");
        Cursor cursor=new Cursor(shallow,1);
        require(cursor.getIndex()==1,"initial cursor index");
        cursor.addPrev("b");
        require(cursor.getIndex()==2 && "b".equals(cursor.getPrev()),"cursor rebased after insert");
        require("b".equals(cursor.removePrev()) && cursor.getIndex()==1,"cursor rebased after erase");
        cursor.addNext("c");
        require("c".equals(cursor.getNext()),"next value");
        Leaf other=shallow.newBunch(9);
        require(other.getLength()==9 && !shallow.sameBunch(other),"isolated bunch");
        Leaf right=(Leaf)shallow.newNext();
        right.addElement("d");
        require(shallow.sameBunch(right),"linked bunch");
        shallow.cutAfter();
        require(shallow.getNext()==null && right.getPrev()==null && !shallow.sameBunch(right),"bunch cut");
        require(Modifier.isSynchronized(Branch.class.getMethod("insertElementAt",Object.class,int.class).getModifiers()),"branch monitor");
        require(Modifier.isSynchronized(Leaf.class.getMethod("newBunch",int.class).getModifiers()),"leaf monitor");
        Branch concurrentRoot=new Branch((BaseRoot)null,7);
        Leaf shared=new Leaf(concurrentRoot,0,2048);
        Thread one=new Thread(()->{for(int i=0;i<500;i++) shared.addElement("a"+i);});
        Thread two=new Thread(()->{for(int i=0;i<500;i++) shared.addElement("b"+i);});
        one.start(); two.start(); one.join(); two.join();
        require(shared.size()==1000,"two writers append without lost slots");
        System.out.println("{\"status\":\"PASS\",\"checks\":"+checks+",\"depths\":[1,2],\"capacities\":[7,3,5,11,9],\"concurrent_appends\":1000}");
    }
}
