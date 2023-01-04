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
/**
*   <b> StatusBar for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import javax.swing.*;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;



/**  <BR>
*   Class:    <b> StatusBar for CBIva  </b><BR>
*   Function: <b> Creates the StatusBar for CBIva </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JPanel
*   @see i5.cb.workbench.CBIva
*/


public class FETextArea extends AttributeLayout {
    private JTextArea text=new JTextArea(4,55);
    private JScrollPane panel;

    public FETextArea(String sPrompt, String sAttribute,
                      int iFlag, String sQuery, String[] asValues) {
        super(sPrompt, sAttribute, TEXTAREA, iFlag, sQuery, asValues) ;

        if (asValues != null)
            for(int j=0; j < asValues.length; j++)
                text.append(asValues[j]+"\n");

        panel=new JScrollPane(text);
        panel.setBorder(new TitledBorder(LineBorder.createGrayLineBorder(), this.sPrompt));
    }


    public String CheckAttribute(int iAttribute) {
        StringBuffer sbError = new StringBuffer("Item '" + sPrompt +"'");
        boolean bError=false;

        if ((this.iFlag & AttributeLayout.NECESSARY) != 0) {
            if ((text.getText()).length() == 0) {
                sbError.append(" is necessary\n");
                bError=true;
            }
        }
        if ((this.iFlag & AttributeLayout.INTEGER) != 0) {
            try {
                new Integer(text.getText());
            }
            catch (NumberFormatException exception) {
                sbError.append(" must be an integer\n");
                bError=true;
            }
        }

        if (bError)
            return sbError.toString();
        else
            return null;

    }

    public String getText() {
        return this.text.getText();
    }

    public JComponent getComponent() {
        return panel;
    }


}





