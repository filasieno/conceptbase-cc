/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

package i5.cb.workbench;

import java.awt.FileDialog;
import java.awt.Frame;
import java.io.*;
import java.util.Enumeration;
import java.util.Vector;

import javax.swing.JOptionPane;


public class IOTool {

    private String Directory=null;

    public String getDirectory() {
        return this.Directory;
    }

    public void setDirectory(String s) {
        this.Directory=s;
    }

    private String endsWith=null;

    public String getEndsWith() {
        return this.endsWith;
    }

    public void setEndsWith(String s) {
        this.endsWith=s;
    }

    private Vector LoadVector=null;

    private boolean saved=false;

    private String sLastSaved="";

    private int id;

    public static int OTHER  = 99;

    public static int STRING = 1;


    public IOTool(String Directory, String endsWith) {
        this.Directory  = Directory;
        this.endsWith    = endsWith;
        this.id=OTHER;
    }

    public IOTool(String Directory, String endsWith, int id) {
        this.Directory  = Directory;
        this.endsWith    = endsWith;
        this.id=id;
    }


    public Vector getVector(String s) {
        Vector v=new Vector();
        v.addElement(s);
        return v;
    }

    public String getString(Vector v) {
        if ((v!=null) && (!v.isEmpty())) {
            Object obj=v.firstElement();
            if (obj instanceof String)
                return (String)obj;
        }
        return null;
    }

    public void save(String s) {
        save(getVector(s));
    }

    public void save(Vector saveVector) {
        sLastSaved=getString(saveVector);
        saved=false;
        FileDialog fdSave=new FileDialog(new Frame());
        fdSave.setDirectory(Directory);
        fdSave.setFile("*"+endsWith);
        fdSave.setMode(1);
        fdSave.setVisible(true);
        if (fdSave.getDirectory()!=null && fdSave.getFile()!=null) {
            this.Directory=fdSave.getDirectory();
            File file = new File(Directory,fdSave.getFile());
            // Save:
            if (id==OTHER)
                SaveOther(file, saveVector);
            else if (id==STRING)
                SaveString(file, saveVector);
        }
    }

    private void SaveOther(File file, Vector SaveVector) {
        try {
            FileOutputStream FOS=new FileOutputStream(file);
            ObjectOutputStream OOS=new ObjectOutputStream(FOS);
            if (SaveVector!=null) {
                Enumeration en=SaveVector.elements();
                while (en.hasMoreElements())
                    OOS.writeObject(en.nextElement());
                FOS.close();
            }
            saved=true;
        }
        catch(FileNotFoundException e) {
            System.out.println(e);
        }
        catch(IOException e) {
            System.out.println(e);
        }
    }

    private void SaveString(File file, Vector SaveVector) {
        try {
            FileOutputStream FOS=new FileOutputStream(file);
            DataOutputStream DOS=new DataOutputStream(FOS);
            if (SaveVector!=null) {
                Enumeration en=SaveVector.elements();
                while (en.hasMoreElements())
                    DOS.writeBytes(en.nextElement().toString());
                FOS.close();
            }
            saved=true;
        }
        catch(FileNotFoundException e) {
            System.out.println(e);
        }
        catch(IOException e) {
            System.out.println(e);
        }
    }





    public String askLoad(String SaveString) {
        if ((SaveString!=null) && (SaveString.equals(sLastSaved)))
            return loadString();
        else
            return getString(askLoad(getVector(SaveString)));
    }

    public Vector askLoad(Vector SaveVector) {
        int YES    =  0;
        int NO     =  1;

        int value = JOptionPane.showConfirmDialog(null,
                    "File not saved. \nSave it now?",
                    "Warning:",
                    JOptionPane.YES_NO_CANCEL_OPTION,
                    JOptionPane.WARNING_MESSAGE);

        if (value == YES) {
            save(SaveVector);
            if (saved)
                return load();
            else
                return askLoad(SaveVector);
        }
        else if (value == NO)
            return load();
        else
            return null;
    }


    public String loadString() {
        return getString(load());
    }

    /**
    *   Function: <b> load TelosFrames </b> <BR>
    */
    public Vector load() {
        LoadVector=null;
        FileDialog fdLoad=new FileDialog(new Frame());
        fdLoad.setDirectory(Directory);
        fdLoad.setMode(0);
        fdLoad.setFile("*"+endsWith);
        fdLoad.setVisible(true);
        String sDir  = fdLoad.getDirectory();
        String sFile = fdLoad.getFile();
        File file;
        try {
            file = new File(sDir, sFile);
            if (file.exists() && file.isFile())  {
                if (id==OTHER)
                    LoadOther(file);
                else if (id==STRING)
                    LoadStrings(file);

            } //if
            else {
                // Error Datei nicht vorhanden....
            } // else
        } //try
        catch (NullPointerException npe) {} //Falls Dateiname nicht vorhanden..

        sLastSaved=getString(LoadVector);
        return LoadVector;
    } // metode

    private void LoadOther(File file) {
        FileInputStream fis=null;
        Object obj=null;
        try {
            fis = new FileInputStream(file);
            LoadVector=new Vector();
            do {
                ObjectInputStream ois = new ObjectInputStream(fis);
                obj=null;
                try {
                    obj=ois.readObject();
                }
                catch (IOException e) {
                    obj=null;
                    System.out.println(e.getMessage());
                }
                catch (ClassNotFoundException cnfe) {}

                if (obj==null)
                    break;
                LoadVector.addElement(obj);
            }
            while (true);
        }// try
    catch (IOException e) {}
        finally {
            try {
                fis.close();
            }
            catch(IOException e) {}
            ;
        }

    }


    private void LoadStrings(File file) {
        FileInputStream fis=null;
        Object obj=null;
        try {
            fis = new FileInputStream(file);
            LoadVector=new Vector();
            String s="";
            do {
                BufferedReader dis = new BufferedReader(new InputStreamReader(fis));
// deprecated:                DataInputStream dis = new DataInputStream(fis);
                try {
                    obj=dis.readLine();
                }
                catch (IOException e) {
                    obj=null;
                    System.out.println(e.getMessage());
                }

                if (obj==null)
                    break;
                s+=(String)obj+"\n";
            }
            while (true);
            LoadVector.addElement(s);
        }// try
    catch (IOException e) {}
        finally {
            try {
                fis.close();
            }
            catch(IOException e) {}
            ;
        }

    }






} //class






