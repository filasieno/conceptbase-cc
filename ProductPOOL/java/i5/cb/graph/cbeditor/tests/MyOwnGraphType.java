/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
package i5.cb.graph.cbeditor.tests;

import i5.cb.graph.cbeditor.CBUserObject;

import java.awt.Component;
import java.awt.Shape;

import javax.swing.*;

/**
 * An example for a user defined CBUserObject
 */

public class MyOwnGraphType extends CBUserObject {

    JPanel jPanel=null;
    JTextArea jTxtArea=null;
    JButton jButton=null;

    public MyOwnGraphType() {
    }

    public Component getSmallComponent() {
        if(jButton==null) {
            jButton=new JButton(this.getTelosObject().toString());
            //if(hasProperty("bgcolor"))
            //    jButton.setBackground(CBUtil.stringToColor(getProperty("bgcolor")));
        }
        return jButton;
    }

    public Component getComponent() {
       /* if(jPanel==null) {
            jPanel=new JPanel();
            jPanel.add(new JLabel("This is my own Graphical Type"));
            String sFrame=this.getObi().ask("get_object["+this.getTelosObject().toString()+"/objname]","FRAME");
            jTxtArea=new JTextArea(sFrame);
            if(hasProperty("fgcolor"))
                jTxtArea.setForeground(CBUtil.stringToColor(getProperty("fgcolor")));
            if(hasProperty("bgcolor"))
                jTxtArea.setBackground(CBUtil.stringToColor(getProperty("bgcolor")));
            jPanel.add(jTxtArea);
            JButton jbInst=new JButton("Show Instances");
            jbInst.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                   //CBUtil.createAndAddNewDiagramObjects(GEConstants.S_POSITION,getObi().getExplicitInstancesOf(getTelosObject()),getCBFrame(),getDiagramNode());
                }
            });
            jPanel.add(jbInst);
            JButton jbAttr=new JButton("Show Attributes");
            jbAttr.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                   //CBUtil.createAndAddNewDiagramObjects(GEConstants.E_POSITION,getObi().getExplicitAttributeValuesOf(getTelosObject()),getCBFrame(),getDiagramNode());
                }
            });
            jPanel.add(jbAttr);
            JButton jbSpec=new JButton("Show Subclasses");
            jbSpec.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {

                  // CBUtil.createAndAddNewDiagramObjects(GEConstants.S_POSITION,getObi().getAllSubclassesOf(getTelosObject()),getCBFrame(),getDiagramNode());
              }
            });
            jPanel.add(jbSpec);
            jPanel.setSize(jPanel.getPreferredSize());
        }
*/
        return jPanel;
    }

    public Shape getShape() {
        return null;
    }

    public JPopupMenu getPopupMenu() {
        return null;
    }
}
