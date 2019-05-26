/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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

package i5.cb.workbench;

import i5.cb.telos.frame.*;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.StringReader;
import java.util.Vector;

import javax.swing.*;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.TableModel;

/**
 * Fenster mit Anzeige des Anfrageergebnisses
 */
public class QueryResultWindow extends JInternalFrame implements ActionListener {


    private JButton bTelos, bClose;

    private JTable table=new JTable();
    private CBIva CBI;
    private String sFrames;
    private TelosFrames tfsFrames;

    public QueryResultWindow(String sFrames, CBIva cbi) {
        super("Result of Ask Query",true,false,true,true);

        this.CBI=cbi;
        this.sFrames=sFrames;

        if (CBI.useQueryResultWindow()) {
            JScrollPane p1,p2;
            p1= new JScrollPane();
            p2= new JScrollPane();

            p1.setMinimumSize(new Dimension(0,0));

            Dimension dimSize=new Dimension(500,500);
            this.setPreferredSize(dimSize);
            this.setSize(dimSize);


            i5.cb.telos.frame.Label labCategory;
            java.util.Enumeration eFrames;
            java.util.Enumeration eCategories;
            Vector vAttributeCategories;
            Vector vLineVector;
            Vector vColumnVector;
            TelosFrame tfrFrame;
            TelosParser tpParser;
            String sText;
            int iZeile, iSpalte;

            this.getContentPane().setLayout(new BorderLayout(15, 15));


            // Text-Area fuer Result ohne weitere Bearbeitung
            JTextArea taResult = new JTextArea(sFrames);
            taResult.setBackground(Color.white);
            p1.getViewport().setView(taResult);


            // sFrames parsen
            tpParser = new TelosParser(new StringReader(sFrames));
            tfsFrames = null;
            try {
                tfsFrames = tpParser.telosFrames(); // throws Parser Error
                final int rows=tfsFrames.size();   // Anzahl der Zeilen

                // Frames-Enumeration aus dem Telos-Frames-Objekt holen
                eFrames = tfsFrames.elements();
                tfrFrame = (TelosFrame)eFrames.nextElement();

                // Vektor fuer Spaltenueberschriften
                vAttributeCategories = new Vector();
                vAttributeCategories.addElement("Objectname");

                // Nun holen wir alle Attributkategorien
                if (tfrFrame.hasWithSpec()) {
                    eCategories = tfrFrame.getCategories().elements();
                    while(eCategories.hasMoreElements()) {
                        labCategory = (i5.cb.telos.frame.Label)eCategories.nextElement();
                        vAttributeCategories.addElement(labCategory.toString());
                    }
                }


                final int columns = vAttributeCategories.size(); // Anzahl der Spalten

                // die Titelzeile der Tabelle
                final String [] asTableTop = new String[columns];

                // jetzt kann das Tabellen Feld angelegt werden:
                final String [][] asTable = new String[rows][columns];

                // und die Spaltenbreite:
                final int [] aiColumnWidth = new int[columns];


                // jetzt - endlich - koennen wir die Tabelle - Zeile fuer Zeile - ausgeben

                iSpalte = 0;
                iZeile  = 0;
                // Titelzeile uebertragen
                eCategories = vAttributeCategories.elements();
                while (eCategories.hasMoreElements()) {
                    asTableTop[iSpalte] = (String)eCategories.nextElement();
                    aiColumnWidth[iSpalte] = FontWidth(asTableTop[iSpalte]); // Zeilenbreite initialisieren
                    iSpalte++;
                }


                // Eintragen der einzelnen Textbestandteile in eine zweidimensionale Struktur
                // Fuer jeden Frame wird ein Vektor angelegt, der die einzelnen Spalten enthaelt
                // Jede Spalte ist wieder ein Vektor, der die Attribute enthaelt
                for (eFrames = tfsFrames.elements(); eFrames.hasMoreElements(); ) {

                    tfrFrame = (TelosFrame)eFrames.nextElement();

                    vLineVector = new Vector();
                    vColumnVector = new Vector();
                    vColumnVector.addElement((tfrFrame.objectName()).toString());
                    vLineVector.addElement(vColumnVector);
                    // Nun holen wir alle Attributkategorien
                    if (tfrFrame.hasWithSpec()) {
                        eCategories = tfrFrame.getCategories().elements();
                        while (eCategories.hasMoreElements()) {
                            vColumnVector = new Vector();
                            labCategory = (i5.cb.telos.frame.Label)eCategories.nextElement();
                            java.util.Enumeration eProperties = tfrFrame.getPropertiesInCategory(labCategory).elements();
                            while (eProperties.hasMoreElements()) {
                                Property prpAttribute = (Property)eProperties.nextElement();
                                sText = prpAttribute.getLabel().toString() + ": " + prpAttribute.getTarget().toString();
                                vColumnVector.addElement(sText);
                            }
                            vLineVector.addElement(vColumnVector);
                        }
                    }

                    // hier kommt jetzt das Aufdroeseln der zweidimensionalen Vektor-Struktur in einzelne
                    // Zeilen...
                    boolean ZeileFertig = false;
                    // Zeile loeschen und Zeilenbreite zuruecksetzen
                    for (int i=0; i<columns; i++ )
                        asTable[iZeile][i] = "";


                    while (!ZeileFertig) { // Fertig, wenn alle Spalten leer
                        ZeileFertig = true;
                        for(iSpalte = 0; iSpalte <= vLineVector.size() - 1; iSpalte++) {
                            vColumnVector = (Vector)vLineVector.elementAt(iSpalte);
                            if (vColumnVector.size() > 0) {
                                if (asTable[iZeile][iSpalte].equals(""))
                                    asTable[iZeile][iSpalte] = (String)vColumnVector.elementAt(0);
                                else
                                    asTable[iZeile][iSpalte] += "; " + (String)vColumnVector.elementAt(0);
                                int iLength = FontWidth(asTable[iZeile][iSpalte]);

                                if (aiColumnWidth[iSpalte] < iLength)
                                    aiColumnWidth[iSpalte] = iLength;

                                vColumnVector.removeElementAt(0);
                                vLineVector.setElementAt(vColumnVector, iSpalte);
                                ZeileFertig = false;
                            }
                        }
                    }
                    iZeile++;
                } //for


                // das TableModel:

                TableModel TM = new AbstractTableModel()  {
                                    public int    getColumnCount()         {
                                        return columns;
                                    }
                                    public int    getRowCount()            {
                                        return rows;
                                    }
                                    public Object getValueAt(int x, int y) {
                                        return asTable[x][y];
                                    }
                                    public String getColumnName(int x)     {
                                        return asTableTop[x];
                                    }

                                };

                table=new JTable(TM);

                // FontMetrics FM = new FontMetrics(table.getFont());

                // System.out.println(">>"+table.getFont().toString()+"<<");

                table.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);

                for (int i=0; i<columns; i++)
                    table.getColumn(asTableTop[i]).setWidth(max(aiColumnWidth[i]+5,100));

                p2 = new JScrollPane(table);

                p1.setMinimumSize(new Dimension(0,0));
                p2.setMinimumSize(new Dimension(0,0));

                p1.setSize(new Dimension(500,200));
                p1.setPreferredSize(new Dimension(500,200));

                p2.setSize(new Dimension(500,200));
                p2.setPreferredSize(new Dimension(500,200));

                JSplitPane VS = new JSplitPane(JSplitPane.VERTICAL_SPLIT, p1, p2);

                VS.setSize(new Dimension(500,500));

                VS.resetToPreferredSizes();

                this.getContentPane().add(VS, BorderLayout.CENTER);

                JPanel p3=new JPanel();
                p3.setLayout(new FlowLayout());

                // Telos-Button
                bTelos = new JButton("Telos Editor");
                bTelos.addActionListener(this);
                p3.add(bTelos);

                // Close-Button
                bClose = new JButton("Close");
                bClose.addActionListener(this);
                p3.add(bClose);
                this.getContentPane().add(BorderLayout.SOUTH, p3);
                CBI.add(this);
            }
            catch(ParseException er)  {
                CBI.getStatusBar().insertMessage("ParseException:" +er.getMessage());
                this.dispose();
            }
            catch (TokenMgrError tme) {
                CBI.getStatusBar().insertMessage("ParseException:" +tme.getMessage());
                this.dispose();
            }
        }
        else {
            this.dispose();
        }
/*
        CBI.getActiveTelosEditor().getTelosTextArea().setText(sFrames);
        CBI.getActiveTelosEditor().getTelosTextArea().setCaretPosition(0);
        CBI.getActiveTelosEditor().updateLineNumbers();
*/
        CBI.getActiveTelosEditor().setTelosText(sFrames);
        if(!CBI.useQueryResultWindow()) {
            try {
                CBI.getActiveTelosEditor().setSelected(true);
            }
            catch(java.beans.PropertyVetoException pve) {}
        }
    }

    private FontMetrics FM = Toolkit.getDefaultToolkit().getFontMetrics(table.getFont());


    private int FontWidth(String s)  {
        return FM.stringWidth(s);
    }


    private int max(int x, int y)  {
        if (x>y)
            return x;
        else
            return y;
    }





    /**
     * @see ActionListener#actionPerformed
     *
     * For bClose and bTelos
     */
    public void actionPerformed(ActionEvent e) {
        Object source = e.getSource();
        if (source == bClose) {
            this.dispose();
        }
        else if (source == bTelos)  {
            if(table.getSelectedRowCount()==0)
                CBI.getActiveTelosEditor().getTelosTextArea().setText(sFrames);
            else {
                int[] rows=table.getSelectedRows();
                StringBuffer sbTelosEditorText=new StringBuffer();
                for(int i=0;i<rows.length;i++) {
                    int j=0;
                    java.util.Enumeration enFrames=tfsFrames.elements();
                    while(j<rows[i]) {
                        enFrames.nextElement();
                        j++;
                    }
                    sbTelosEditorText.append(((TelosFrame) enFrames.nextElement()).toString());
                    sbTelosEditorText.append('\n');
                }
                CBI.getActiveTelosEditor().getTelosTextArea().setText(sbTelosEditorText.toString());
            }
        }
    }
}

