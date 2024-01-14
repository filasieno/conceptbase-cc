/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
/**
 *   <b> GenericSelectionDialog for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */

package i5.cb.workbench;

import i5.cb.telos.frame.*;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.StringReader;
import java.util.Vector;

import javax.swing.*;

public class  QueryDialog extends JInternalFrame implements ActionListener {

    protected CBIva    cbIva;
    protected CBIvaClient cbClient;
    private Vector vjcbParams;
    private Vector vsParams;
    private Vector vjcbTypes;
    private String sQuery;
    private JComboBox jcbFormat;

    public QueryDialog(CBIva cbiva, String query) {

        super("Specify Parameters for  " + query,true,false,true,true);

        this.getContentPane().setLayout(new BorderLayout());

        this.cbIva=cbiva;
        this.cbClient=cbiva.getCBClient();

        Box mainBox=new Box(BoxLayout.Y_AXIS);

        this.sQuery=query;
        String sQueryFrame=cbClient.getObject(query);

        TelosFrame tfr;

        try {
            TelosParser tp=new TelosParser(new StringReader(sQueryFrame));
            tfr=tp.telosFrame();
        }
        catch(ParseException e) {
            cbIva.getStatusBar().insertMessage("TelosParser error");
            this.dispose();
            return;
        }

        com.objectspace.jgl.Set setProperties=tfr.getPropertiesInCategory(new i5.cb.telos.frame.Label("parameter"));
        int len=setProperties.size();

        // If query has no parameters, execute query directly
        /* if(len==0) {
        	//this.setVisible(false);
        	this.dispose();
        	cbClient.ask(query,"OBJNAMES","FRAME",cbIva.getActiveTelosEditor());
        	return;
        } */

        java.util.Enumeration en=setProperties.elements();
        vjcbParams=new Vector(len);
        vjcbTypes=new Vector(len);
        vsParams=new Vector(len);

        String[] asTypes={"substitute","specialize"};


        while(en.hasMoreElements()) {
            Property prop=(Property) en.nextElement();

            Box paramBox=new Box(BoxLayout.X_AXIS);
            paramBox.add(new JLabel(prop.getLabel().toString()));
            vsParams.addElement(prop.getLabel().toString());

            JComboBox jcbParam=new JComboBox();
            jcbParam.setSize(100,20);
            jcbParam.setEditable(true);
            paramBox.add(jcbParam);
            vjcbParams.addElement(jcbParam);

            JComboBox jcbType=new JComboBox(asTypes);
            jcbType.setEditable(false);
            paramBox.add(jcbType);
            vjcbTypes.addElement(jcbType);

            JButton btValues=new JButton("Show Values");
            btValues.addActionListener(new QueryDialogValueButtonListener(jcbParam,prop.getTarget().toString(),cbClient));
            paramBox.add(btValues);

            mainBox.add(paramBox);
        }

        String[] asAnswerFormats=cbClient.asParseObjectNames(cbClient.findInstances("AnswerFormat"));
        String[] allAnswerFormats=new String[asAnswerFormats.length+5];
        allAnswerFormats[0]="default";
        allAnswerFormats[1]="FRAME";
        allAnswerFormats[2]="LABEL";
        allAnswerFormats[3]="FRAGMENTswi";
        allAnswerFormats[4]="JSONIC";
        for(int i=0;i<asAnswerFormats.length;i++)
            allAnswerFormats[i+5]=asAnswerFormats[i];

        Box formatBox=new Box(BoxLayout.X_AXIS);
        formatBox.add(new JLabel("Answer Format"));

        jcbFormat=new JComboBox(allAnswerFormats);
        jcbFormat.setSize(100,20);
        jcbFormat.setEditable(true);
        formatBox.add(jcbFormat);

        mainBox.add(formatBox);

        this.getContentPane().add(mainBox,BorderLayout.CENTER);

        JButton jbAsk=new JButton("Ask");
        jbAsk.setActionCommand("Ask");
        jbAsk.addActionListener(this);

        JButton jbCancel=new JButton("Cancel");
        jbCancel.setActionCommand("Cancel");
        jbCancel.addActionListener(this);

        Box buttonBox=new Box(BoxLayout.X_AXIS);
        buttonBox.add(jbAsk);
        buttonBox.add(jbCancel);

        this.getContentPane().add(buttonBox,BorderLayout.SOUTH);

        Dimension dimSize=new Dimension(500,len*30+80);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(200,100));
        this.setSize(dimSize);
        this.setVisible(true);
    }

    public void actionPerformed(ActionEvent e) {

        if(e.getActionCommand().equals("Ask")) {

            StringBuffer sbQuery=new StringBuffer(sQuery);
            boolean bHasParams=false;

            for(int i=0;i<vjcbParams.size();i++) {
                JComboBox jcbParam=(JComboBox) vjcbParams.elementAt(i);
                JComboBox jcbType=(JComboBox) vjcbTypes.elementAt(i);

                String sParam=null;
                Object obj=jcbParam.getSelectedItem();
                if(obj!=null)
                    sParam=obj.toString();

                String sType=null;
                obj=jcbType.getSelectedItem();
                if(obj!=null)
                    sType=obj.toString();

                if(sParam!=null && !sParam.equals("")) {
                    if(!bHasParams) {
                        bHasParams=true;
                        sbQuery.append("[");
                    }
                    else
                        sbQuery.append(",");

                    if(sType.equals("substitute"))
                        sbQuery.append(sParam + "/" + (String) vsParams.elementAt(i));
                    else
                        sbQuery.append((String) vsParams.elementAt(i) + ":" + sParam);
                }
            }

            if(bHasParams)
                sbQuery.append("]");

            cbIva.getStatusBar().setStatus("ASK");
            cbClient.ask(sbQuery.toString(),"OBJNAMES",(String)jcbFormat.getSelectedItem(),cbIva.getActiveTelosEditor());
            cbIva.getStatusBar().setStatus(true);

            this.dispose();
        }
        if (e.getActionCommand().equals("Cancel")) {
            this.setVisible(false);
            this.dispose();
        }
    }
}



class QueryDialogValueButtonListener implements ActionListener {

    private JComboBox jcbBox;
    private String sClass;
    private CBIvaClient cbClient;

    public QueryDialogValueButtonListener(JComboBox jcbParam,String classname,CBIvaClient cb) {

        this.jcbBox=jcbParam;
        this.sClass=classname;
        this.cbClient=cb;

    }

    public void actionPerformed(ActionEvent e) {

        String sResult=cbClient.ask("find_instances["+ sClass + "/class]", "OBJNAMES","LABEL");

        TelosParser tp=new TelosParser(new StringReader(sResult));

        ObjectNames onInst;

        try {
            onInst=tp.objectNames();
        }
        catch(ParseException ex) {
            return;
        }

        java.util.Enumeration enInst=onInst.elements();

        while(enInst.hasMoreElements()) {
            String sObject=enInst.nextElement().toString();
            boolean bInserted=false;
            for(int i=0;i<jcbBox.getItemCount();i++) {
                if (jcbBox.getItemAt(i).toString().compareTo(sObject)>0) {
                    jcbBox.insertItemAt(sObject,i);
                    bInserted=true;
                    break;
                }
            }
            if(!bInserted)
                jcbBox.addItem(sObject);
        }
    }
}



