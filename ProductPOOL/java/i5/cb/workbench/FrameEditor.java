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

/** FrameEditor
 * zum Editieren von Objekten einer bestimmten Klassen.
 * Das Layout des FrameEditors wird durch die LayoutDefinition
 * vorgegeben. Diese Komponente ist nicht in CBIva integriert,
 * koennte aber fuer andere Anwendungen nuetzlich sein.
 */

package i5.cb.workbench;

import i5.cb.CBException;
import i5.cb.api.*;
import i5.cb.telos.frame.*;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.StringReader;
import java.util.Enumeration;
import java.util.Random;

import javax.swing.*;



public class FrameEditor extends JFrame
    implements ActionListener {
    // array for references to created form-components
    // is needed to check out the component contents
    // private Component[] aAttributes;

    // array for attributes. is initialized to all attributelayouts in order.
    // prevents the same field index for aAtributes and aLayouts.
    // needed to check easily the attribute-flags
    private AttributeLayout[] aLayout;


    public boolean isGenerated = false; // flag for generated objectname

    private int attribIndex = 0; // index of the form-component
    private JLabel   laClassName,laPrompt;  // JLabel
    private JButton  buTell,buCancel;          // JButtons
    private JPanel   paTop,paBottom;
    private GridBagLayout      bottomLayout;
    private GridBagConstraints bottomConstraints;
    private LayoutDefinition      ldLayout;
    private CBclient  cbClient;

    /** Constructs the FrameEditor
     *  @param cbClient  the ConceptBase client
     *  @param ldLayout  the LayoutDefinition
     */

    public FrameEditor(CBclient cbClient,LayoutDefinition ldLayout) {
        super();
        this.setTitle("Frame Editor");
        this.getContentPane().setLayout(new BorderLayout());   // main panel layout

        this.ldLayout = ldLayout;
        this.cbClient = cbClient;

        // Graphical components
        int i;

        // determine count of attributes
        //    if(ldLayout.alObjectName != null) attribIndex++;
        attribIndex = 1; // objectname is always there
        if(ldLayout.aalAttributes != null)
            attribIndex += ldLayout.aalAttributes.length;




        paTop = new JPanel();
        // paCenter  = new JPanel();
        paBottom = new JPanel();

        laPrompt     = new JLabel(ldLayout.sPrompt);
        laClassName  = new JLabel(ldLayout.sClassName);
        laClassName.setFont(new Font("SansSerif", Font.BOLD + Font.ITALIC, 16));
        laPrompt.setFont(new Font("SansSerif", Font.PLAIN, 14));

        buTell = new JButton("Tell");
        buCancel = new JButton("Cancel");


        bottomLayout = new GridBagLayout();
        bottomConstraints = new GridBagConstraints();  // the button constraints
        bottomConstraints.fill = GridBagConstraints.BOTH;
        bottomConstraints.insets = new Insets(10,30,5,30); // top,left,bottom,right
        bottomConstraints.weightx = 0.0;  // dont resize buttons
        bottomConstraints.weighty = 0.0;  // dont resize buttons
        bottomConstraints.gridwidth = 1;
        bottomConstraints.gridheight = 1;
        bottomConstraints.ipadx = 60;  // internal padding
        bottomLayout.setConstraints(buTell,bottomConstraints);
        bottomLayout.setConstraints(buCancel,bottomConstraints);

        paTop.setLayout(new GridLayout(2,1)); // two rows, one column for the top panel
        paBottom.setLayout(bottomLayout);

        aLayout = new AttributeLayout [attribIndex];  // create layout array

        int j = 0;
        if (ldLayout.alObjectName != null) {
            aLayout[j] = ldLayout.alObjectName;

            j++;
        }
        else {
            String[] asValues = new String [1];
            asValues[0] = strRanInt(ldLayout.sClassName);
            aLayout[j] = new FETextArea("Objectname",null,0,null,asValues);
            isGenerated = true;
            j++;
        }

        // copy the attributelayouts into the local array
        int tmp;
        for (tmp=0; tmp < ldLayout.aalAttributes.length; tmp++) {
            if (ldLayout.aalAttributes != null) {
                aLayout[j] = ldLayout.aalAttributes[tmp];
                j++;
            }
        }

        // send sQuery
        if(attribIndex != 0) {
            for(i=0;i < attribIndex ;i++) {
                if (aLayout[i].sQuery != null) {
                    String sAsk=null;
                    try {
                        sAsk = cbClient.ask(aLayout[i].sQuery,"OBJNAMES","LABEL","Now").getResult();
                    }
                    catch (CBException cbe) {
                        System.out.println("Error in connection with CB server:\n" + cbe.getMessage());
                    }
                    catch (java.rmi.RemoteException e2)  {
                        System.out.println("RMI Exception:" +e2.getMessage());
                    }
                    aLayout[i].asValues = asParseObjectNames(sAsk);
                    aLayout[i].init();
                }
            }
        }



        Box box= new Box(BoxLayout.Y_AXIS);

        if(attribIndex != 0) {
            for(i=0;i < attribIndex ;i++) {
                box.add(aLayout[i].getComponent());
            }
        }
        // paCenter.setMinimumSize(new Dimension(400,400));


        // paCenter.add(box);


        // if the objectname is generated, it is not editable
        if (isGenerated) {
            aLayout[0].setEditable(false);
        };

        buTell.addActionListener(this);
        buCancel.addActionListener(this);

        paTop.add(laClassName);
        paTop.add(laPrompt);

        paBottom.add(buTell);
        paBottom.add(buCancel);

        //   JScrollPane paScroll=new JScrollPane(ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
        JScrollPane paScroll=new JScrollPane();
        paScroll.getViewport().setView(box);


        getContentPane().add(BorderLayout.NORTH,paTop);
        getContentPane().add(BorderLayout.CENTER,paScroll);
        getContentPane().add(BorderLayout.SOUTH,paBottom);

        this.setSize(450,450);
    }



    private String[] asParseObjectNames(String sObjectNames) {
        TelosParser tpParser=new TelosParser(new StringReader(sObjectNames));

        ObjectNames on;
        try {
            on=tpParser.objectNames();
        }
        catch (ParseException pe) {
            System.out.println("Error in FrameEditor: Telos Parser Error:"+pe.getMessage());
            return null;
        }
        catch (TokenMgrError te) {
            System.out.println("Error in FrameEditor: Telos Parser Error:"+te.getMessage());
            return null;
        }

        Enumeration e=on.elements();
        Enumeration f=on.elements();

        int count=0;

        while (f.hasMoreElements()) {
            f.nextElement();
            count++;
        }

        String[] s= new String[count];

        for (int i=0; i<count; i++)
            s[i]=(e.nextElement()).toString();

        return s;
    }



    private String strRanInt (String sInput) {
        Random random = new Random();
        int zufZahl = random.nextInt();
        if (zufZahl < 0) {
            zufZahl = -1*zufZahl;
        } // remove the annoying hyphen
        return sInput + Integer.toString(zufZahl);
    }


    // Listener methods

    public void actionPerformed(ActionEvent event) {
        Object source = event.getSource();

        // Ok button

        if(source == buTell) {
            // check out everything and construct TelosFrame-object

            String[] aStrings = new String[attribIndex];
            boolean errorOccured = false;
            for (int i=0; i < attribIndex; i++) {
                aStrings[i] = aLayout[i].CheckAttribute(i);
                if (aStrings[i] != null) {
                    errorOccured = true;
                }
            }
            if (errorOccured) {
                StringBuffer sbErrorMsg=new StringBuffer("Error while checking input\n");
                for(int iStr=0;iStr<aStrings.length;iStr++)  {
                    if (aStrings[iStr] !=null)
                        sbErrorMsg.append(aStrings[iStr]);
                }
                JOptionPane.showMessageDialog(this, sbErrorMsg.toString());
            }
            else {
                String tmpString=aLayout[0].getText();


                if ((aLayout[0].iFlag & AttributeLayout.STRING) != 0) {
                    tmpString=CButil.encodeString(tmpString);
                }

                TelosFrame tfObject= new TelosFrame(new i5.cb.telos.frame.Label(ldLayout.sClassName),
                                                    new i5.cb.telos.frame.Label(tmpString),
                                                    new ObjectNames(),new ObjectNames(),new WithSpec());

                for (int i=1; i < attribIndex; i++) {

                    tmpString = aLayout[i].getText();
                    if (tmpString!=null) {
                        int tmpAttributeNumber=1;
                        do  {
                            if ((aLayout[i].iFlag & AttributeLayout.STRING) != 0) {
                                tmpString=CButil.encodeString(tmpString);
                            }



                            tfObject.addAttribute(
                                new i5.cb.telos.frame.Label(((AttributeLayout)aLayout[i]).sAttribute),
                                new i5.cb.telos.frame.Label( ((AttributeLayout)aLayout[i]).sAttribute + tmpAttributeNumber),
                                new i5.cb.telos.frame.Label(tmpString));
                            tmpString=aLayout[i].getText();
                            tmpAttributeNumber++;
                        }
                        while ((tmpString!=null) && ((aLayout[i].iFlag & AttributeLayout.MULTI)!=0));
                    }
                }


                CBanswer ans=null;
                try  {
                    ans=cbClient.tell(tfObject.toString());
                }
                catch(CBException cbe) {
                    JOptionPane.showMessageDialog(this, "An communication error occured while inserting this object:\n"+cbe.getMessage());
                    return;
                }
                catch (java.rmi.RemoteException e2)  {
                    JOptionPane.showMessageDialog(this,
                                                  "RMI Exception",
                                                  "Error",
                                                  JOptionPane.ERROR_MESSAGE);
                    return;
                }
                if (ans.getCompletion()!=CBanswer.OK) {
                    try  {
                        JOptionPane.showMessageDialog(this,
                                                      "The object could not be told.\n Error message of ConceptBase:\n"+ cbClient.getErrorMessages(),
                                                      "Error",
                                                      JOptionPane.ERROR_MESSAGE);
                    }
                    catch(CBException cbe) {
                        JOptionPane.showMessageDialog(this,
                                                      "The object could not be told and\n ConceptBase did not send any error messages!",
                                                      "Error",
                                                      JOptionPane.ERROR_MESSAGE);
                    }
                    catch (java.rmi.RemoteException e2)  {
                        JOptionPane.showMessageDialog(this,
                                                      "RMI Exception",
                                                      "Error",
                                                      JOptionPane.ERROR_MESSAGE);
                    }
                }
                else  { // Answer ok
                    JOptionPane.showMessageDialog(this,
                                                  "Successfully told object\n"+tfObject.toString(),
                                                  "Success",
                                                  JOptionPane.INFORMATION_MESSAGE);
                }
            }
        }

        // Cancel button

        else if(source == buCancel) {
            setVisible(false);
            this.dispose();
        }
    }

} // End FrameEditor







