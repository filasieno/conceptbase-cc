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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import javax.swing.plaf.*;
import java.awt.Color;

import javax.swing.*;

public class CBinstaller extends JFrame implements ActionListener {

    JTextField jtfArchive;
    JTextField jtfDestDir;
    JTextField jtfInfo;

    JCheckBox jcbDoc;
    JCheckBox jcbExam;
    JCheckBox jcbWin;
    JCheckBox jcbLin;
    JCheckBox jcbLin64;
    JCheckBox jcbLinArm;
    JCheckBox jcbMac;
    JCheckBox jcbSolSPARC;
    JCheckBox jcbSolPC;
    Color defaultButtonColor;

    JButton jbHelp;
    JButton jbExtract;
    JButton jbDownloadFile;
    JButton jbSelectFile;

    String helpURL = "http://conceptbase.sourceforge.net/CB-Download.html";
    String cblatestURL = "http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d3191820/cb-latest.zip";
    String curDir=System.getProperty("user.dir");
    String downloadDir=getDownloadDir(curDir);
    String cbInstallerPath = curDir + File.separator + "CBinstaller.jar";

    Cursor oldCursor;

    boolean bExtractFromJar = false;  // true if the binaries are being extracted from CBinstaller.jar itself

    public CBinstaller() {
        super("CBinstaller for ConceptBase (2019-11-07)");

        UIManager.put("Label.font", new FontUIResource(new Font("Dialog", Font.PLAIN, 16)));
        UIManager.put("Button.font", new FontUIResource(new Font("Dialog", Font.PLAIN, 18)));
        UIManager.put("TextField.font", new FontUIResource(new Font("Dialog", Font.PLAIN, 16)));

        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel jp1=new JPanel(new GridLayout(3,2));


        jbDownloadFile=new JButton("Download cb-latest.zip");
        jbDownloadFile.setActionCommand("DownloadFile");
        jp1.add(jbDownloadFile);
        jbDownloadFile.addActionListener(this);
        defaultButtonColor = jbDownloadFile.getBackground();

        jtfInfo=new JTextField("... from CB-Forum",60);
        jtfInfo.setEditable(false);
        jp1.add(jtfInfo);


        jbSelectFile=new JButton("Select Installation Archive");
        jbSelectFile.setActionCommand("SelectFile");
        jp1.add(jbSelectFile);
        jbSelectFile.addActionListener(this);

        jtfArchive=new JTextField(downloadDir + File.separator + "cb-latest.zip",60);
        jtfArchive.setEditable(false);
        jp1.add(jtfArchive);


        JButton jbSelectDir=new JButton("Select Installation Directory");
        jbSelectDir.setActionCommand("SelectDir");
        jp1.add(jbSelectDir);
        jbSelectDir.addActionListener(this);

        jtfDestDir=new JTextField(getInstallationDir(curDir),60);
        jtfDestDir.setEditable(false);
        jp1.add(jtfDestDir);



        this.getContentPane().add(jp1,BorderLayout.NORTH);

        JPanel jpOptions=new JPanel(new GridLayout(3,3));
        jpOptions.setBorder(BorderFactory.createTitledBorder("Installation Options"));
        jcbDoc=new JCheckBox("Documentation",true);
        jcbExam=new JCheckBox("Examples",true);
        jcbWin=new JCheckBox("CBserver MS Windows",false);
        jcbLin=new JCheckBox("CBserver Linux (32bit)",true);
        jcbLin64=new JCheckBox("CBserver Linux (64bit)",true);
        jcbLinArm=new JCheckBox("CBserver Linux (ARMV7)",false);
        jcbMac=new JCheckBox("CBserver Mac",false);
        jcbSolSPARC=new JCheckBox("CBserver SolarisSPARC",false);
        jcbSolPC=new JCheckBox("CBserver Solaris PC",false);

        jpOptions.add(jcbDoc);
        jpOptions.add(jcbExam);
        jpOptions.add(jcbLin);
        jpOptions.add(jcbLin64);
        jpOptions.add(jcbLinArm);
// these platforms are not fully supported:
        jpOptions.add(jcbSolSPARC);
        jpOptions.add(jcbWin);
        jpOptions.add(jcbMac);
        jpOptions.add(jcbSolPC);

        this.getContentPane().add(jpOptions,BorderLayout.CENTER);

        JPanel jpButtons=new JPanel(new GridLayout(1,3));

        jbHelp=new JButton("Help");
        jbHelp.addActionListener(this);
        jbHelp.setActionCommand("Help");
        jpButtons.add(jbHelp);

        jbExtract=new JButton("Install");
        jbExtract.addActionListener(this);
        jbExtract.setActionCommand("Extract");
        jpButtons.add(jbExtract);

        checkFatCBinstaller();

        if(new File(jtfArchive.getText()).exists()) {
            jbExtract.setBackground(Color.GREEN);
            jbExtract.setEnabled(true);
        } else {
            jbDownloadFile.setBackground(Color.GREEN);
            jbExtract.setEnabled(false);
        }

        JButton jbCancel=new JButton("Cancel");
        jbCancel.addActionListener(this);
        jbCancel.setActionCommand("Cancel");
        jpButtons.add(jbCancel);

        this.getContentPane().add(jpButtons,BorderLayout.SOUTH);

        this.setSize(650,240);
        this.setVisible(true);
        // the following variants are de-selected and we hide the options to select them
        // until we can compile their binaries und include them in the cb*.zip archive
        jcbMac.setVisible(false);
        jcbWin.setVisible(false);
        jcbSolPC.setVisible(false);
        jcbSolSPARC.setVisible(false);

        if (System.getProperty("os.name").indexOf("Linux") < 0) {
          jcbLin.setSelected(false);
  // install linux64 by default
  //        jcbLin64.setSelected(false);
          jcbLinArm.setSelected(false);
        }

        oldCursor = this.getCursor();

    }


   /**
   If the CBinstaller.jar file contains the ConceptBase binaries, then we use this file as the installation
   archive.
   */
   public void checkFatCBinstaller() {

        // we can pack the installation archive cb-latest.zip into CBinstaller.jar 
        // cbInstallerPath contains the file location of CBinstaller.jar
        try {
          String path = CBinstaller.class.getProtectionDomain().getCodeSource().getLocation().getPath();
          cbInstallerPath = java.net.URLDecoder.decode(path, "UTF-8");

        } catch (Exception e) { }

        File cbInstallerFile = new File(cbInstallerPath);

        if (cbInstallerFile.exists()) {
           if (cbInstallerFile.length() > 100000)  {  // larger than 100000 bytes means that CBinstaller.jar is "fat"
              jtfArchive.setText(cbInstallerPath);
              jtfArchive.setVisible(false);
              jbSelectFile.setText("To be extracted");
              jbSelectFile.setEnabled(false);
              jbSelectFile.setVisible(false);
              jbDownloadFile.setText("Self-extracting archive");
              jbDownloadFile.setEnabled(false);
              jbDownloadFile.setVisible(false);
              jtfArchive.setEnabled(false);
              jtfArchive.setVisible(false);
              jtfInfo.setText("");
              jtfInfo.setEnabled(false);
              jtfInfo.setVisible(false);
              bExtractFromJar = true;
           }
        }
   }

    public void showWebPageWithoutBrowser(String sUrl) {

        JEditorPane editorPane = new JEditorPane();
        editorPane.setEditable(false);

        try {
            java.net.URL helpURL = new java.net.URL(sUrl);
            editorPane.setPage(helpURL);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,"Could not open URL: " + sUrl +
                "\n" + e.getMessage(),"Error",JOptionPane.ERROR_MESSAGE);
        }
        JScrollPane jsp=new JScrollPane(editorPane);
        JFrame jfHelp=new JFrame(sUrl);  // use sUrl as window title
        jfHelp.getContentPane().add(jsp);
        jfHelp.setSize(750,550);
        jfHelp.setVisible(true);
    }

    private void downloadCBLATEST(String address, String localFileName) {

        OutputStream out = null;
        java.net.URLConnection conn = null;
        InputStream in = null;
        int numRead;
        long numWritten = 0;
        oldCursor = this.getCursor();

        try {
            jtfInfo.setText(" ... downloading ");
            this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            jtfInfo.repaint();
            java.net.URL url = new java.net.URL(address);
            out = new BufferedOutputStream(new FileOutputStream(localFileName));
            conn = url.openConnection();
            in = conn.getInputStream();
            byte[] buffer = new byte[1024];



            while ((numRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, numRead);
                numWritten += numRead;
            }

            this.setCursor(oldCursor);
        } 
        catch (Exception exception) { 
           jtfInfo.setText(" ... download failed");
        } 
        finally {
            try {
                if (in != null) 
                    in.close();
                if (out != null) 
                    out.close();
                if(new File(localFileName).exists()) {
                   jtfInfo.setText(" ... downloaded successfully " + numWritten + " bytes");
                   jtfArchive.setText(localFileName);
                   jbExtract.setBackground(Color.GREEN);
                   jbExtract.setEnabled(true);
                   jbDownloadFile.setBackground(defaultButtonColor);
                } else
                   jbExtract.setEnabled(false);
            } 
            catch (IOException ioe) {
               jtfInfo.setText(" ... download failed");
            }
        }
    }


    private void selectDestinationDirectory() {
        JFileChooser fc = new JFileChooser();

        fc.setCurrentDirectory(new File(jtfDestDir.getText()));
        fc.setDialogType(JFileChooser.OPEN_DIALOG);
        fc.setDialogTitle("Select destination directory for extracting ConceptBase");
        fc.setMultiSelectionEnabled(false);

        fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

        if (fc.showOpenDialog(this)!= JFileChooser.APPROVE_OPTION) {
            return;  //only when user select valid dir, it can return approve_option
        }
        jtfDestDir.setText(fc.getSelectedFile().toString());

    }

    private String getInstallationDir(String defaultDir) {
      try {
         if ( System.getProperty("os.name").indexOf("Windows") >=0 ) {
           return "c:\\conceptbase";
         } else  {
            return System.getProperty("user.home") + "/conceptbase";
         } 
      } catch (Exception e) {
        return defaultDir;
      }
    }

    private String getDownloadDir(String defaultDir) {
      try {
         String homeDir = System.getProperty("user.home");
         if (new File(homeDir + File.separator + "Downloads").exists())
           return homeDir + File.separator + "Downloads";
         else if (new File(defaultDir + File.separator + "Downloads").exists()) 
           return defaultDir + File.separator + "Downloads";
         else
           return defaultDir;
      } catch (Exception e) {
        return defaultDir;
      }
    }


    private void selectInstallationFile() {
        JFileChooser fc = new JFileChooser();

        fc.setCurrentDirectory(new File(jtfArchive.getText()).getParentFile());
        fc.setDialogType(JFileChooser.OPEN_DIALOG);
        fc.setDialogTitle("Select archive for installation");
        fc.setMultiSelectionEnabled(false);
        fc.setFileFilter(new CBFileFilter());

        if (fc.showOpenDialog(this)!= JFileChooser.APPROVE_OPTION) {
            return;  //only when user select valid dir, it can return approve_option
        }
        jtfArchive.setText(fc.getSelectedFile().toString());
        if(fc.getSelectedFile().exists()) {
            jbExtract.setBackground(java.awt.Color.GREEN);
            jbExtract.setEnabled(true);
        }
    }


    private boolean acceptLicense() {

        String licenseText = "The ConceptBase.cc Copyright\n"+
     "Copyright 1987-2023 The ConceptBase Team. All rights reserved.\n\n" +
     "Redistribution and use in source and binary forms, with or without modification, are permitted\n" +
     "provided that the following conditions are met:\n\n" +
     "1. Redistributions of source code must retain the above copyright notice, this list of\n"+
     "conditions and the following disclaimer.\n" +
     "2. Redistributions in binary form must reproduce the above copyright notice, this list of\n" +
     "conditions and the following disclaimer in the documentation and/or other materials\n" +
     "provided with the distribution.\n\n" +

      "THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,\n" +
      "INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A\n" +
      "PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE\n" +
      "LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES\n" +
      "(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,\n" +
      "OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN\n" +
      "CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT\n" +
      "OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n\n" +

      "The views and conclusions contained in the software and documentation are those of the authors\n" +
      "and should not be interpreted as representing official policies, either expressed or implied,\n" +
      "of the ConceptBase Team.\n";

        JTextArea textArea = new JTextArea(26, 65);
        textArea.setText(licenseText);
        textArea.setEditable(false);

        jbExtract.setBackground(Color.LIGHT_GRAY);
        jbExtract.setEnabled(false);
        this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        this.repaint();

        Object[] options = {"Decline", "Accept"};
        int result = JOptionPane.showOptionDialog(null,textArea,"Accept License?",
                                     JOptionPane.YES_NO_OPTION,JOptionPane.QUESTION_MESSAGE,null,options,options[0]);

        
        return (result == 1);
 
    }

    private void extract() {

        if (!acceptLicense()) {
           this.setVisible(false);
           this.dispose();
           System.exit(0);  // exit CBinstaller without installing
        }

        

        Cursor oldCursor = this.getCursor();

        File currentArchive = new File(jtfArchive.getText());
        File outputDir = new File(jtfDestDir.getText());

        byte[] buf = new byte[1024];
        boolean overwrite = false;

        ZipFile zf = null;
        FileOutputStream out = null;
        InputStream in = null;
        try {
            zf = new ZipFile(currentArchive);

            int size = zf.size();
            int extracted = 0;

            Enumeration entries = zf.entries();

            boolean bInstallUnix=jcbLin.isSelected() || jcbLin64.isSelected() || jcbLinArm.isSelected() || jcbMac.isSelected() || jcbSolSPARC.isSelected() || jcbSolPC.isSelected();
            boolean bInstallSolaris=jcbSolSPARC.isSelected() || jcbSolPC.isSelected();
            boolean bInstallWindows=jcbWin.isSelected();

            for (int i=0; i<size; i++) {


                ZipEntry entry = (ZipEntry) entries.nextElement();
                if(entry.isDirectory())
                    continue;
                String filename = entry.getName();

// skip the CBinstaller.jar program files
                if(filename.startsWith("i5/"))
                    continue;
                if(filename.startsWith("META-INF/"))
                    continue;

                if(filename.startsWith("doc/") && !jcbDoc.isSelected())
                    continue;
                if(filename.startsWith("example/") && !jcbExam.isSelected())
                    continue;
                if(filename.startsWith("windows/") && !jcbWin.isSelected())
                    continue;
                if(filename.startsWith("linux/") && !jcbLin.isSelected())
                    continue;
                if(filename.startsWith("linux64/") && !jcbLin64.isSelected()) 
                    continue;
                if(filename.startsWith("linuxarm/") && !jcbLinArm.isSelected())
                    continue;
                if(filename.startsWith("mac/") && !jcbMac.isSelected())
                    continue;
                if(filename.startsWith("sun4/") && !jcbSolSPARC.isSelected())
                    continue;
                if(filename.startsWith("i86pc/") && !jcbSolPC.isSelected())
                    continue;

                if(filename.startsWith("bin/") && filename.endsWith(".bat") && !bInstallWindows)
                    continue;
                if(filename.startsWith("bin/") && !filename.endsWith(".bat") && !bInstallUnix)
                    continue;
                if(filename.startsWith("man/") && !bInstallUnix)
                    continue;
                if(filename.startsWith("lib/") && !filename.startsWith("lib/classes") 
                   && !filename.startsWith("lib/system") && !filename.endsWith(".gel") && !bInstallSolaris)
                    continue;

                System.out.println("Extracting " + filename);

                extracted++;

                in = zf.getInputStream(entry);
                File outFile = new File(outputDir, filename);
                Date archiveTime = new Date(entry.getTime());
                overwrite = true; // skip warning on files to be overwritten
                this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

                if(overwrite==false) {
                    if(outFile.exists()) {
                        Object[] options = {"Yes", "Yes To All", "No"};
                        String msg = "Overwrite existing file " + outFile.getName() + " with new file from archive?";
                        int result = JOptionPane.showOptionDialog(this,msg, "Warning",
                                JOptionPane.DEFAULT_OPTION,JOptionPane.WARNING_MESSAGE, null, options,options[0]);
                        if(result == 2) // No
                        {
                            continue;
                        }
                        else if( result == 1) //YesToAll
                        {
                            overwrite = true;
                        }
                    }
                }



                File parent = new File(outFile.getParent());
                if (parent != null && !parent.exists()) {
                    parent.mkdirs();
                }

                out = new FileOutputStream(outFile);

                while (true) {
                    int nRead = in.read(buf, 0, buf.length);
                    if (nRead <= 0)
                        break;
                    out.write(buf, 0, nRead);
                }

                out.close();
                outFile.setLastModified(archiveTime.getTime());
            }

            zf.close();
            boolean bWindows = (System.getProperty("os.name").indexOf("Windows")>=0);
            boolean bLinux = (System.getProperty("os.name").indexOf("Linux")>=0);
            boolean bResult=setCbHome(outputDir);
            if (bInstallUnix)  // also copies SystemDB
                setExecutableFlag(outputDir);
            String msg="Extracted " + extracted + " files from " + jtfArchive.getText() + " into the directory\n" + outputDir.getPath() + "\n\n";

            this.setCursor(oldCursor);


            if (bResult) {
                if (bWindows && !bExtractFromJar &&
                   (jcbLin.isSelected() || jcbLin64.isSelected() || jcbLinArm.isSelected() || jcbMac.isSelected() || jcbSolPC.isSelected() || jcbSolSPARC.isSelected()))
                    msg = msg + "The batch files for Windows have been configured, but you will have to edit the following scripts for Unix manually!\n\n" +
                           outputDir.getAbsolutePath() + "\\cbserver\n" +
                           outputDir.getAbsolutePath() + "\\cbiva\n" +
                           outputDir.getAbsolutePath() + "\\cbshell\n" +
                           outputDir.getAbsolutePath() + "\\cbgraph\n";
                else if (!bWindows && !bExtractFromJar && jcbWin.isSelected())
                    msg = msg + "The scripts for Unix have been configured, but you will have to edit the following batch files for Windows manually!\n\n" +
                            outputDir.getAbsolutePath() + "/cbserver.bat\n" +
                            outputDir.getAbsolutePath() + "/cbiva.bat" +
                            outputDir.getAbsolutePath() + "/cbshell.bat\n" +
                            outputDir.getAbsolutePath() + "/cbgraph.bat\n";
                else
                    msg = msg + "The paths in the batch/script files have been configured.\n";
            }
            else
                msg = msg + "The batch/script files could not be updated!\nYou will have to edit the files in " + outputDir.getAbsolutePath() + File.separator + "bin manually!\n";


            if (!bLinux)
                msg = msg + "\nThis ConceptBase installation may use the public CBserver at cbserver.iit.his.se, port number 4001,\n"
                          + "by default. You may have to open this outgoing port in your home network/firewall.\n"
                          + "DO NOT USE the public CBserver for processing confidential information!\n"
                          + "Read ConceptBase.cc User Manual, section Public CBservers for details!\n"
                          + "If you are using Windows 10, then consider to install the Linux sub-system to be able to\n" 
                          + "run the CBserver locally, see http://conceptbase.sourceforge.net/CB-WinLinux.html.";

            msg = msg + "\n\nSee " + outputDir.getAbsolutePath() +  File.separator + 
                      "doc" + " for ConceptBase.cc documentation."
                  + "\nSee http://conceptbase.sourceforge.net/quick-start.html for first steps to use ConceptBase.cc!";


            JTextArea textArea = new JTextArea(14, 55);
            textArea.setText(msg);
            textArea.setEditable(false);

            JOptionPane.showMessageDialog(null,textArea,"Installation successful",JOptionPane.INFORMATION_MESSAGE);



        }

        catch (Exception e) {
            Thread.dumpStack();
            System.out.println(e);
            if(zf!=null) { try { zf.close(); } catch(IOException ioe) {;} }
            if(out!=null) { try {out.close();} catch(IOException ioe) {;} }
            if(in!=null) { try { in.close(); } catch(IOException ioe) {;} }
        }

        /* Exit CBinstaller when the message about the extracted files has been read */
        this.setVisible(false);
        this.dispose();
        System.exit(0);

    }

    private boolean setCbHome(File installationDir) {
        boolean bIsWindows=false;
        boolean bResult=false;

        if(System.getProperty("os.name").indexOf("Windows")>=0) {
            bIsWindows=true;
        }

        String filename=null;
        String linePrefix=null;
        String replacement=null;


/* These files are legacy files that do not need to be configured anymore:

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\bin\\CBserver.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/bin/CBserver";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\bin\\CBjavaInterface.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/bin/CBjavaInterface";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\bin\\CBshell.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/bin/CBshell";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

*/

	// for the scripts in root of the installation directory: cbshell,cbserver,cbiva
        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\cbshell.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/cbshell";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\cbserver.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/cbserver";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\cbiva.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/cbiva";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(bIsWindows) {
            filename=installationDir.getAbsolutePath() + "\\cbgraph.bat";
            linePrefix="if not defined CB_HOME set CB_HOME";
            replacement="if not defined CB_HOME set CB_HOME=" + installationDir.getAbsolutePath();
        }
        else {
            filename=installationDir.getAbsolutePath() + "/cbgraph";
            linePrefix="CB_HOME=${CB_HOME:=";
            replacement="CB_HOME=${CB_HOME:=" + installationDir.getAbsolutePath() + "}";
        }

        System.out.println("Configuring " + filename);
        bResult=replaceInFile(filename,linePrefix,replacement);
        if(!bResult) {
            JOptionPane.showMessageDialog(this,"Could not update CB_HOME in " + filename + "\nYou will have to edit this file manually!",
                    "Error!",JOptionPane.ERROR_MESSAGE);
            return false;
        }

        if(!bIsWindows) {


            filename=installationDir.getAbsolutePath() + "/cbiva.desktop";
            System.out.println("Configuring " + filename);
            linePrefix="Icon=/home/jeusfeld/CBPOOL/conceptbase/cbiva-logo.png";
            replacement="Icon=" + installationDir.getAbsolutePath() + "/cbiva-logo.png";
            bResult=replaceInFile(filename,linePrefix,replacement);

            filename=installationDir.getAbsolutePath() + "/cbiva.desktop";
            linePrefix="Exec=/home/jeusfeld/CBPOOL/conceptbase/cbiva";
            replacement="Exec=" + installationDir.getAbsolutePath() + "/cbiva";
            bResult=replaceInFile(filename,linePrefix,replacement);

            filename=installationDir.getAbsolutePath() + "/cbgraph.desktop";
            System.out.println("Configuring " + filename);
            linePrefix="Icon=/home/jeusfeld/CBPOOL/conceptbase/cbgraph-logo.png";
            replacement="Icon=" + installationDir.getAbsolutePath() + "/cbgraph-logo.png";
            bResult=replaceInFile(filename,linePrefix,replacement);

            filename=installationDir.getAbsolutePath() + "/cbgraph.desktop";
            linePrefix="TryExec=/home/jeusfeld/CBPOOL/conceptbase/cbgraph";
            replacement="TryExec=" + installationDir.getAbsolutePath() + "/cbgraph";
            bResult=replaceInFile(filename,linePrefix,replacement);

            filename=installationDir.getAbsolutePath() + "/cbgraph.desktop";
            linePrefix="Exec=/home/jeusfeld/CBPOOL/conceptbase/cbgraph %f";
            replacement="Exec=" + installationDir.getAbsolutePath() + "/cbgraph %f";
            bResult=replaceInFile(filename,linePrefix,replacement);
        }


        return true;
    }


    private boolean replaceInFile(String filename, String linePrefix, String replacement) {

        try {
            FileReader fr=new FileReader(filename);
            BufferedReader br=new BufferedReader(fr);
            Vector vLines=new Vector();
            try {
                String sLine=br.readLine();
                while(sLine!=null) {
                    vLines.add(sLine);
                    sLine=br.readLine();
                }
            }
            catch(EOFException e) {}
            br.close();
            fr.close();
            Iterator it=vLines.iterator();
            FileWriter fw=new FileWriter(filename);
            PrintWriter pw=new PrintWriter(fw);
            while(it.hasNext()) {
                String sLine=(String) it.next();
                if(sLine.startsWith(linePrefix))
                    pw.println(replacement);
                else
                    pw.println(sLine);
            }
            pw.close();
            fw.close();
        }
        catch(Exception e) {
            return false;
        }
        return true;
    }

    private void setExecutableFlag(File dir) {

        String cmd=null;
        String[] cmds= { "CBserver", "CBjavaInterface", "CBvariant", "CBworkbench", "CBshell" };
        String[] unixcmds = { "cbRTexec", "CBserver" };
        String[] startcmds = { "cbshell", "cbserver", "cbiva", "cbgraph" };
        String[] sysfiles = {"SYSTEM.SWI.telos", "SYSTEM.SWI.symbol", "SYSTEM.SWI.rule", "SYSTEM.SWI.ruleinfo", "SYSTEM.SWI.ecarule"};
        String[] obfiles  = {"OB.telos",         "OB.symbol",         "OB.rule",         "OB.ruleinfo",         "OB.ecarule"};

        if(System.getProperty("os.name").indexOf("Windows")>=0) {
           try {
              /* copy system database files to lib\SystemDB */
              String sypath = dir.getAbsolutePath() + "\\lib\\system\\";
              String obpath = dir.getAbsolutePath() + "\\lib\\SystemDB\\";
              File theDir = new File(obpath);
              System.out.println("Doing " + "md " + obpath);
              if (!theDir.exists())
                 Runtime.getRuntime().exec("cmd.exe /C md " + obpath);
              for(int i=0;i<sysfiles.length;i++) {
                  cmd ="copy " + sypath + sysfiles[i] + " "  + obpath + obfiles[i];
                  System.out.println("Doing " + cmd);
                  Runtime.getRuntime().exec("cmd.exe /C "+ cmd);
              }
            }
            catch(Exception e) {
            System.out.println("Exception: " + e.getMessage());
            }
            return;
        }

        try {
            for(int i=0;i<cmds.length;i++) {
                cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/bin/" + cmds[i];
                System.out.println("Doing " + cmd);
                Runtime.getRuntime().exec(cmd);
            }

            /* cb* scripts also need to get their executable flag set */
            for(int i=0;i<startcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/" + startcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
            }
            if(jcbSolSPARC.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/sun4/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
               }
            }
            if(jcbSolPC.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/i86pc/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
                }
           }
            if(jcbLin.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/linux/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
                }
           }
            if(jcbLin64.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/linux64/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
                }
           }
            if(jcbLinArm.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/linuxarm/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
                }
           }
            if(jcbMac.isSelected()) {
                for(int i=0;i<unixcmds.length;i++) {
                    cmd="/bin/chmod 755 " + dir.getAbsolutePath() + "/mac/bin/" + unixcmds[i];
                    System.out.println("Doing " + cmd);
                    Runtime.getRuntime().exec(cmd);
                }
           }

           /* copy system database files to lib/SystemDB */
           String sypath = dir.getAbsolutePath() + "/lib/system/";
           String obpath = dir.getAbsolutePath() + "/lib/SystemDB/";
           File theDir = new File(obpath);
           if (!theDir.exists())
              Runtime.getRuntime().exec("/bin/mkdir " + obpath);
           for(int i=0;i<sysfiles.length;i++) {
               cmd ="/bin/cp " + sypath + sysfiles[i] + " "  + obpath + obfiles[i];
               System.out.println("Doing " + cmd);
               Runtime.getRuntime().exec(cmd);
           }
           

        }
        catch(Exception e) {
            System.out.println("Exception: " + e.getMessage());
        }
    }

    public void actionPerformed(ActionEvent e) {
        if(e.getActionCommand().equals("Extract")) {
            extract();
        }
        if(e.getActionCommand().equals("SelectFile")) {
            selectInstallationFile();
        }
        if(e.getActionCommand().equals("SelectDir")) {
            selectDestinationDirectory();
        }
        if(e.getActionCommand().equals("DownloadFile")) {
            downloadCBLATEST(cblatestURL, downloadDir + File.separator + "cb-latest.zip");
        }
        if(e.getActionCommand().equals("Help")) {
            showWebPageWithoutBrowser(helpURL);
        }
        if(e.getActionCommand().equals("Cancel")) {
            this.setVisible(false);
            this.dispose();
            System.exit(0);
        }
    }


    public static void main(String[] args) {
        new CBinstaller();
    }
}


class CBFileFilter extends javax.swing.filechooser.FileFilter {

    public boolean accept(File f) {
        return (f.getName().endsWith(".zip") && f.getName().startsWith("cb")) || f.isDirectory();
    }
    public String getDescription() {
        return "ConceptBase ZIP files (cb*.zip)";
    }

}
