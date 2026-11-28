import java.nio.file.*;
import java.util.*;
import javax.tools.*;
import com.sun.source.tree.*;
import com.sun.source.util.*;
public class MapJavaInventory {
 static String q(String s) {return "\""+s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t")+"\"";}
 public static void main(String[] args) throws Exception {
  JavaCompiler c=ToolProvider.getSystemJavaCompiler(); var fm=c.getStandardFileManager(null,null,null);
  List<Path> files=new ArrayList<>(); try(var walk=Files.walk(Path.of(args[0]))) {walk.filter(p->p.toString().endsWith(".java")).sorted().forEach(files::add);}
  var tasks=(JavacTask)c.getTask(null,fm,d->{},List.of("-proc:none"),null,fm.getJavaFileObjectsFromPaths(files));
  var trees=Trees.instance(tasks); boolean[] first={true}; System.out.println("[");
  for(var cu:tasks.parse()) {String source=cu.getSourceFile().getCharContent(true).toString(); var pos=trees.getSourcePositions();
   new TreePathScanner<Void,Void>() {Deque<String> names=new ArrayDeque<>();
    @Override public Void visitClass(ClassTree node,Void v) {String n=node.getSimpleName().toString(); if(n.isEmpty())n="<anonymous@"+cu.getLineMap().getLineNumber(pos.getStartPosition(cu,node))+">"; names.addLast(n); super.visitClass(node,v); names.removeLast(); return null;}
    @Override public Void visitMethod(MethodTree node,Void v) {long begin=pos.getStartPosition(cu,node),end=pos.getEndPosition(cu,node); long b=node.getBody()==null?end:pos.getStartPosition(cu,node.getBody());
     String sig=source.substring((int)begin,(int)Math.max(begin,b)).replaceAll("\\s+"," ").trim(); String path=Path.of(cu.getSourceFile().toUri()).toString();
     if(!first[0])System.out.println(","); first[0]=false;
     System.out.print("{\"source_path\":"+q(path)+",\"class\":"+q(String.join(".",names))+",\"name\":"+q(node.getName().toString())+",\"line\":"+cu.getLineMap().getLineNumber(begin)+",\"end_line\":"+cu.getLineMap().getLineNumber(end)+",\"signature\":"+q(sig)+",\"modifiers\":"+q(node.getModifiers().getFlags().toString())+",\"body\":"+q(node.getBody()==null?"":source.substring((int)b,(int)end))+"}");
     return super.visitMethod(node,v); }
   }.scan(cu,null);
  } System.out.println("\n]");
 }
}
