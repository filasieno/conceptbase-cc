/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

package i5.cb;

import java.io.*;
import java.util.HashSet;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class PrologPreProcessor {


    public static final int BIM=1;
    public static final int SWI=2;
    public static final int SICSTUS=4;

    public static int target=SWI;
    public static PrintStream output;
    public static int currentIf;

    public static HashSet importedModules=new HashSet();
    static boolean bIsFirstExport=true;
    static Stack ifStack=new Stack();

    public static void main(String[] argv) {
        String sTargetSystem=argv[0];
        String fileSuffix=null;
        if(sTargetSystem.equals("BIM")) {
            target=BIM;
            fileSuffix=".bim.pro";
        }
        else if(sTargetSystem.equals("SWI")) {
            target=SWI;
            fileSuffix=".swi.pl";
        }
        else if(sTargetSystem.equals("SICSTUS")) {
            target=SICSTUS;
            fileSuffix=".sicstus.pl";
        }
        else {
            System.out.println("Unknown target: " + argv[0]);
            System.exit(1);
        }
        try {
            for(int i=1;i<argv.length;i++) {
                String fileName=argv[i];
                int start=fileName.lastIndexOf('/')+1;
                String baseName=fileName.substring(start,fileName.lastIndexOf('.'));
                output=new PrintStream(new FileOutputStream(baseName + fileSuffix));
                readFile(argv[i]);
                output.close();
            }
        }
        catch(IOException e2) {
            System.out.println(e2.getMessage());
            System.exit(1);
        }
    }

    static void readFile(String fname) {

        String input=null;
        StringBuffer sb=new StringBuffer();
        try {
            FileReader fr=new FileReader(fname);
            while(fr.ready()) {
                sb.append((char) fr.read());
            }
            input=sb.toString();
        }
        catch(EOFException e) {
            input=sb.toString();
        }
        catch(IOException e2) {
            System.out.println(e2.getMessage());
            System.exit(1);
        }
        currentIf=BIM | SWI | SICSTUS;

        String regex="\\{[^\\}]*\\}|" + // comments
                    "^\\p{Blank}*\\#[^\\n]*$|" + // special preprocessing commands
                    "\\'[^\\']*\\'|" + // quoted atoms
                    "\\b[A-Z]\\w*\\b"; //  words with starting uppercase letters
        Pattern p=Pattern.compile(regex,Pattern.DOTALL | Pattern.MULTILINE);
        Matcher m=p.matcher(input);
        int prevMatchIndex=0;
        while(m.find()) {
            // System.out.println("Match:" + m.group());
            String cur="";
            if(m.start()>0)
                cur=input.substring(prevMatchIndex,m.start());
            prevMatchIndex=m.end();
            print(cur);
            if(m.group().startsWith("'")) // quoted atom
                print(m.group());
            else if(m.group().startsWith("{")) { // comment
                if(target==BIM)
                    print(m.group());
                else
                    print("/*" + m.group().substring(1,m.group().length()-1) + "*/");
            }
            else if(m.group().trim().startsWith("#"))
               handleSpecial(m.group().trim());
            else
               print("'" + m.group() + "'");
        }
        print(input.substring(prevMatchIndex));
    }

    static void handleSpecial(String match) {
        String cmd=match.substring(1,match.indexOf('(')).trim();
        if(cmd.equals("PLAIN")) {
            print(match.substring(match.indexOf('(')+1,match.lastIndexOf(')')));
            return;
        }
        String[] argv=match.substring(match.indexOf('(')+1,match.lastIndexOf(')')).split(",");
        if(cmd.equals("IMPORT"))
            handleImport(argv);
        else if(cmd.equals("EXPORT"))
            handleExport(argv);
        else if(cmd.equals("LOCAL"))
            handleLocal(argv);
        else if(cmd.equals("GLOBAL"))
            handleGlobal(argv);
        else if(cmd.equals("MODULE"))
            handleModule(argv);
        else if(cmd.equals("ENDMODDECL"))
            handleModuleEnd(argv);
        else if(cmd.equals("INCLUDE"))
            handleInclude(argv);
        else if(cmd.equals("IF"))
            handleIf(argv);
        else if(cmd.equals("ELSE"))
            handleElse(argv);
        else if(cmd.equals("ENDIF"))
            handleEndIf(argv);
        else if(cmd.equals("MODE"))
            handleMode(argv);
        else if(cmd.equals("DYNAMIC"))
            handleDynamic(argv);
        else {
            System.out.println("Error! Unknown Preprocessor command: " + match);
            System.exit(1);
        }
    }


    static void handleImport(String[] argv) {
    	switch(target) {
    	case BIM:
            print(":- import " + argv[0] + " from " + argv[1] + " .");
            break;
        case SWI:
            String mod=argv[1].trim();
            if(!importedModules.contains(mod)) {
                importedModules.add(mod);
                print(":- use_module('" + mod + ".swi.pl').");
            }
            break;
        case SICSTUS:
            print("/* :- use_module('" + argv[1].trim() + "',TODO_FILENAME,[" + quotePredName(argv[0]) + "]). */");
            break;
        }
    }

    static void handleExport(String[] argv) {
    	switch(target) {
    	case BIM:
            print("{ :- export " + argv[0] + " . }");
            break;
        case SWI:
        case SICSTUS:
            if(bIsFirstExport) {
                print(quotePredName(argv[0]));
                bIsFirstExport=false;
            }
            else
                print("," + quotePredName(argv[0]));
            break;
        }
    }

    static void handleLocal(String[] argv) {
    	switch(target) {
    	case BIM:
            print(":- local " + argv[0] + " .");
            break;
        }
    }

    static void handleGlobal(String[] argv) {
    	switch(target) {
    	case BIM:
            print(":- global " + argv[0] + " .");
            break;
        }
    }

    static void handleModule(String[] argv) {
    	switch(target) {
    	case BIM:
            print(":- module('" + argv[0] + "').");
            break;
        case SWI:
        case SICSTUS:
            print(":- module('" + argv[0] + "',[");
            bIsFirstExport=true;
            importedModules=new HashSet();
            break;
        }
    }

    static void handleModuleEnd(String[] argv) {
    	switch(target) {
    	case SWI:
    	case SICSTUS:
            print("]).\n");
            print(":- use_module('GlobalPredicates.swi.pl').\n");
            print(":- use_module('debug.swi.pl').");
            break;
        }
    }

    static void handleInclude(String[] argv) {
        readFile(argv[0]);
    }

    static void handleIf(String[] argv) {
        ifStack.push(new Integer(currentIf));
        currentIf=0;
        for(int i=0;i<argv.length;i++) {
            if(argv[i].equals("BIM"))
                currentIf=currentIf | BIM;
            if(argv[i].equals("SWI"))
                currentIf=currentIf | SWI;
            if(argv[i].equals("SICSTUS"))
                currentIf=currentIf | SICSTUS;
        }
    }

    static void handleElse(String[] argv) {
        int oldIf=currentIf;
        currentIf=0;
        if((oldIf & BIM)==0)
            currentIf=currentIf | BIM;
        if((oldIf & SWI)==0)
            currentIf=currentIf | SWI;
        if((oldIf & SICSTUS)==0)
            currentIf=currentIf | SICSTUS;
    }

    static void handleEndIf(String[] argv) {
        currentIf=((Integer) ifStack.pop()).intValue();
    }

    static void handleMode(String[] argv) {
    	switch(target) {
    	case BIM:
            print(":- mode(");
            for(int i=0;i<argv.length;i++) {
                if(i!=0)
                    print(",");
                print(argv[i]);
            }
            print(").");
            break;
        }
    }

    static void handleDynamic(String[] argv) {
        switch(target) {
    	case BIM:
    	case SWI:
    	case SICSTUS:
            print(":- dynamic " + quotePredName(argv[0]) + " .");
            break;
        }
    }

    static void print(String s) {
        if((currentIf & target)>0) {
            output.print(s);
        }
    }

    static String quotePredName(String pred) {
        if(pred.trim().startsWith("'"))
            return pred.trim();
        else
            return "'" + pred.substring(0,pred.indexOf("/")).trim() + "'" + pred.substring(pred.indexOf("/")).trim();
    }



}
