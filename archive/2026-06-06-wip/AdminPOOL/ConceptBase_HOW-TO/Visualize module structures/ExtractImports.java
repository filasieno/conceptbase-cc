/* This program is derived from
   PrologPreProcessor.java
   which is part of the ConceptBase sources.
*/



/*
The ConceptBase.cc Copyright

Copyright 1987-2012 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class ExtractImports {


    public static void main(String[] argv) {

         readFile(argv[0]);
    }

    static void readFile(String fname) {

        String moduleName=fname.substring(0,fname.lastIndexOf('.'));

        System.out.println(moduleName + " in ProgramModule end");

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
           if(m.group().trim().startsWith("#"))
               handleSpecial(moduleName, m.group().trim());
        }
    }

    static void handleImport(String moduleName, String[] argv) {
        System.out.println(argv[1] + " in ProgramModule end");
        System.out.println(moduleName + " with imports " 
                             + "\\\"" + argv[0] + "\\\"" + ": " + argv[1] + " end");
    }


    static void handleSpecial(String moduleName, String match) {
        String cmd=match.substring(1,match.indexOf('(')).trim();
        String[] argv=match.substring(match.indexOf('(')+1,match.lastIndexOf(')')).split(",");
        if(cmd.equals("IMPORT"))
            handleImport(moduleName, argv);
        else
            return;
    }



}
