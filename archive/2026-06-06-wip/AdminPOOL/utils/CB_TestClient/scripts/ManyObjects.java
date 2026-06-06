

import java.util.*;
import java.io.*;



public class ManyObjects {

    public static final int NUMOBJS=50000;
    public static final int NUMLINKS=25000;
    public static final int MAXCLUSTER=5000;


    public static void main(String argv[]) throws Exception {

        Random r=new Random();

        PrintStream out=new PrintStream(new FileOutputStream("ManyObjects.cbs"));
        int curObj=0;

        out.println("# Dieses Skript wurde automatisch erstellt");
        out.println("# Siehe Java-Source in ManyObjects.java");
        out.println("startServer -d ManyObjects -u nonpersistent");
        out.println("tell \"Class ManyObjects with attribute ref : ManyObjects end\"");
        out.println("result OK yes");
        while(curObj<NUMOBJS) {
            out.print("tell \"");
            int num=r.nextInt(MAXCLUSTER);
            for(int i=0;i<num;i++) {
                curObj++;
                out.println("obj" + curObj + " in ManyObjects end");
            }
            out.println("\"");
            out.println("result OK yes");
            if(r.nextInt(100)<30) {
                int obj=r.nextInt(curObj);
                out.println("ask get_object[obj"+obj+"/objname] OBJNAMES FRAME Now");
                if(obj>0) {
                    out.println("result OK \"Individual obj"+obj+" in ManyObjects\nend\"");
                }
                else {
                    out.println("result ERROR nil");
                }
            }
            if(r.nextInt(100)<15) {
                out.println("ask find_instances[ManyObjects/class] OBJNAMES LABEL Now");
                out.println("result OK \"_\"");
            }
            if(r.nextInt(100)<8) {
                out.println("ask find_instances[ManyObjects/class] OBJNAMES FRAME Now");
                out.println("result OK \"_\"");
            }
        }
        int maxObj=curObj;
        int curLink=0;
        while(curLink<NUMLINKS) {
            out.print("tell \"");
            int num=r.nextInt(MAXCLUSTER);
            for(int i=0;i<num;i++) {
                curLink++;
                int objSrc=r.nextInt(maxObj)+1;
                int objDst=r.nextInt(maxObj)+1;
                out.println("obj" + objSrc + " with ref ref" + curLink + " : obj" + objDst + " end");
            }
            out.println("\"");
            out.println("result OK yes");
            if(r.nextInt(100)<30) {
                int obj=r.nextInt(maxObj);
                out.println("ask get_object[obj"+obj+"/objname] OBJNAMES FRAME Now");
                if(obj>0) {
                    out.println("result OK \"_\"");
                }
                else {
                    out.println("result ERROR nil");
                }
            }
            if(r.nextInt(100)<15) {
                out.println("ask find_instances[ManyObjects!ref/class] OBJNAMES LABEL Now");
                out.println("result OK \"_\"");
            }
            if(r.nextInt(100)<7) {
                out.println("ask find_instances[ManyObjects!ref/class] OBJNAMES FRAME Now");
                out.println("result OK \"_\"");
            }
        }

        out.close();


    }

}
