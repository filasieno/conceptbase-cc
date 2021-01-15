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
/**
 *   <b> TelosEditor for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Color;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.Element;
import javax.swing.text.Document;

import javax.swing.*;
import java.net.*;
import java.io.*;


/**
 *   Class:    <b> TelosEditor for CBIva  </b><BR>
 *   Function: <b> Creates a TelosEditor for CBIva </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see i5.cb.workbench.CBIva
 */
public class TelosEditor extends JInternalFrame {

    private CBIva cbIva;
    private LogWindow logWindow;
    private JScrollPane jsp;
    private JTextArea linenumbers;
    private int oldLineCount = 1;  // memorize how many lines the TelosEditor text area contains
    private DocumentListener docListener;
    private String textFromUrl=null;

    private static String LINE_SEPARATOR = System.getProperty("line.separator");

    /**
     *  Textarea of the Telos-Editor
     *
     */
    private TETextArea taTelos;

    /**
     *   @return Parent CBIva
     */
    public CBIva getCBIva() {
        return cbIva;
    }

    /**
     *   @return LogWindow
     */
    public LogWindow getLogWindow() {
        return logWindow;
    }



    /**
     * @return taTelos the JTextArea of the TelosEditor
     *
     * @see javax.swing.JTextArea
     */
    public TETextArea getTelosTextArea() {
        return this.taTelos;
    }


    /**
     * set a new text to this TelosEditor. Also sets the caret position to the top.
     *
     * @param text the new text
     */

    public void setTelosText(String text) {
        this.getTelosTextArea().setText(text);
        this.getTelosTextArea().setCaretPosition(0);
    }


    /**
     *   <b> Constructor  </b><BR>
     *
     *  creates a TelosEditor with a LogWindow
     *
     *   @param cbIva Parent CBIva
     *   @param LogPanel the LogPanel of CBIva
     */
    public TelosEditor(CBIva cbIva, LogWindow LogPanel) {
        super("Display Instances",true,false,true,true);
        this.getContentPane().setLayout(new BorderLayout());
        this.cbIva=cbIva;
        JSplitPane splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, initTelosPanel(), LogPanel);
        this.getContentPane().add(splitPane,BorderLayout.CENTER);
        Dimension dimSize=new Dimension(600,450);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(400,300));
        this.setSize(dimSize);
        splitPane.setDividerLocation(0.7);
        splitPane.setResizeWeight(0.7);  // 70% of vertical space reserved for upper window (Telos editor)
        cbIva.add(this);
    }



    /**
     *   <b> Constructor  </b><BR>
     *
     *  creates a TelosEditor
     *
     *   @param cbIva Parent CBIva
     */
    public TelosEditor(CBIva cbIva) {
        super("Display Instances",true,true,true,true);

        this.getContentPane().setLayout(new BorderLayout());
        this.cbIva=cbIva;
        this.getContentPane().add(initTelosPanel(), BorderLayout.CENTER);

        Dimension dimSize=new Dimension(300,300);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(50,50));
        this.setSize(dimSize);
    }


    private JScrollPane initTelosPanel() {
        logWindow=cbIva.getLogWindow();

        jsp= new JScrollPane();

        this.setTitle("Telos Editor");

        taTelos=new TETextArea(this);
        taTelos.setMargin( new java.awt.Insets(0,3,0,0) );  // top,left,bottom,right

        jsp.getViewport().setView(this.taTelos);

        //this.setFocusObject(TETA);

        jsp.setPreferredSize(new Dimension(200,150));
        jsp.setMinimumSize(new Dimension(50,50));
        jsp.setSize(new Dimension(200,150));

        updateLineNumbers();  // display linenumbers column if configured
	jsp.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);

        return jsp;
    }


    /**
     *   Function: <b> Get line numbers text </b> <BR>
     *   @param doc the document to be indexed with a line numbers column
     *
     *  Produce a text column for the line numbers depending on the text in doc
     */

    public String getLinenumbersText(Document doc) {
      int caretPosition = doc.getLength();
      Element root = doc.getDefaultRootElement();
      String text = "1 " + LINE_SEPARATOR;
      for (int i = 2; i < root.getElementIndex( caretPosition ) + 2; i++){
        text += i + " " + LINE_SEPARATOR;
      }
      return text;
    }

    /**
     *   Function: <b> check whether the line count of doc has changed </b> <BR>
     *   @param doc the document to be checked
     *
     *  true if the last event to doc changed its line count; memorizes the old line count
     */

    private boolean lineCountChanged(Document doc) {
      int caretPosition = doc.getLength();
      Element root = doc.getDefaultRootElement();
      int newLineCount = 1 + root.getElementIndex(caretPosition);
      if (newLineCount != oldLineCount) {
         oldLineCount = newLineCount;
         return true;
      } else {
         return false;
      }
    }



    /**
     *   Function: <b> Update line numbers </b> <BR>
     *
     *  Depending on whether the flag getShowLineNumbers() is selected, a column with
     *  line numbers is added to the text area of this Telos editor. If the flag is
     *  de-selected, the linenumbers column is removed.
     *  We use numberOfLines to control whether the setText() method is called upon a document
     *  event. Only events that lead to a change in numberOfLines are leading to 
     *  a call of setText. Otherwise the linenumbers column gets currupted for an unknown reason.
     */
     // adapted from code sniplet of Chris Freaky; java programming forum


  public void updateLineNumbers() {
     updateLineNumbers(cbIva.getCBClient().getShowLineNumbers());
  }
  
  private void updateLineNumbers(boolean showLineNumbers) {
        if (showLineNumbers) {

	  linenumbers = new JTextArea("1 ");
          linenumbers.setFont(linenumbers.getFont().deriveFont(taTelos.getTextFontSize()));  // needs to be same font size as taTelos
	  linenumbers.setBackground(new Color(225,240,255));
	  linenumbers.setForeground(new Color(100,100,180));
	  linenumbers.setEditable(false);

          if (docListener == null) {
            docListener = new DocumentListener(){
              public void changedUpdate(DocumentEvent de) {
                if (lineCountChanged(taTelos.getDocument())) {
                   linenumbers.setText(getLinenumbersText(taTelos.getDocument()));
                }
                // realize drag&drop of file locations
                textFromUrl = checkReadUrl();
                if (textFromUrl != null)
                   // invokeLater is needed because the drag&drop of the file name changes the taTelos text
                   // we can only set the text to textFromUrl in a delayed thread
                   SwingUtilities.invokeLater(new Runnable() {
                       public void run() {
                         taTelos.setText(textFromUrl);
                       }
                     });
              }
              public void insertUpdate(DocumentEvent de) {
                if (lineCountChanged(taTelos.getDocument())) {
                   linenumbers.setText(getLinenumbersText(taTelos.getDocument()));
                }
                textFromUrl = checkReadUrl();
                if (textFromUrl != null)
                   SwingUtilities.invokeLater(new Runnable() {
                       public void run() {
                         taTelos.setText(textFromUrl);
                       }
                     });
              }
              public void removeUpdate(DocumentEvent de) {
                if (lineCountChanged(taTelos.getDocument()))
                   linenumbers.setText(getLinenumbersText(taTelos.getDocument()));
              }
            }; // end new expression
          }

	  taTelos.getDocument().addDocumentListener(docListener);

          // init the text of the linenumbers column
          linenumbers.setText(getLinenumbersText(taTelos.getDocument()));

	  jsp.setViewportView(taTelos);
	  jsp.setRowHeaderView(linenumbers);

        } else {  // no line numbers
          linenumbers = null;
          jsp.setRowHeaderView(linenumbers);
          if (docListener != null)
            taTelos.getDocument().removeDocumentListener(docListener);
        }

    }

    /**
     *   Read content of URL specified in the Telos Editor text area.
     *
     *  This method is used to realize a drag&drop of file/URL links into the text area
     *  of this TelosEditor. If this is done on an empty text area and the file/URL ends with
     * .sml or .sml.txt, then th contents of the file is fetched and returnedas a String.
     *
     *  @return the String representing the content of the URL; null if text area does not represnet a URL or access failes
     */
   private String checkReadUrl() {

      if (!cbIva.getCBClient().getShowLineNumbers() || oldLineCount > 2)
        return null;

      String taTelosText = taTelos.getText().trim();

      if (!taTelosText.startsWith("file://") && !taTelosText.startsWith("http://")) {
        return null;  
      }

      if (!taTelosText.endsWith(".sml") && !taTelosText.endsWith(".sml.txt")) {
        return null; 
      }

      try {
        StringBuffer filecontent = new StringBuffer();
        URL fileurl = new URL(taTelosText);
        BufferedReader in = new BufferedReader(new InputStreamReader(fileurl.openStream()));
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            filecontent.append(inputLine+"\n");
        }
        in.close();
        return filecontent.toString();  
     } catch (Exception e) {
       cbIva.getStatusBar().insertMessage("Reading from URL failed");
       return null;
     }
    
   }


}

