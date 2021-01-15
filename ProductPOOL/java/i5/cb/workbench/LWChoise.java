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
 *   <b> LWChoise for CBIva 11.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import java.awt.*;

import javax.swing.*;

/**
 *   Class:    <b> LWChoise for CBIva  </b><BR>
 *   Function: <b> Creates a Choise-List to Redo the List </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see javax.swing.JFrame
 *   @see i5.cb.workbench.CBIva
 */
public class LWChoise extends JInternalFrame {

    private LogCmd[] alcList;

    private LogWindow LW;

    private JTextArea TA=new JTextArea(5,40);




    /**
     *   <b> Constructor  </b><BR>
     *
     *   Function: <b> creates a LWChoise for CBIva</b> <BR>
     *
     *   @param LW LogWindow
     */

    public LWChoise(LogWindow LW) {

        super("Redo History Commands",true,false,true,true);
        this.LW=LW;
        LWLog Log=LW.getLog();

        this.setLocation(200,200);
        this.getContentPane().setLayout(new BorderLayout());

        TA.setMinimumSize(new Dimension(0,0));
        TA.setEditable(false);
        TA.setLineWrap(true);


        JScrollPane SP1= new JScrollPane(ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);

        SP1.getViewport().setView(TA);

        //  SP1.setSize(new Dimension(20,20));

        this.getContentPane().add(SP1,BorderLayout.NORTH);

        JPanel List = new JPanel(new GridLayout(0,1));

        this.alcList=Log.getList();

        int z=alcList.length;

        for(int i=0; i<z; i++) {
            JCheckBox JCB = alcList[i].getCheckBox();
            alcList[i].setLWChoise(this);
            List.add(JCB);

        }

        JScrollPane SP2= new JScrollPane(List);

        this.getContentPane().add(SP2, BorderLayout.CENTER);

        LWCCommand RedoCmd = new LWCCommand(LWCCommand.REDO,this);
        LWCCommand ExitCmd = new LWCCommand(LWCCommand.EXIT,this);

        JPanel panButtons = new JPanel();

        panButtons.setLayout(new GridLayout(1,0));

        JButton butRedo = new JButton("Redo");
        butRedo.setToolTipText("Redo selected Commands");
        panButtons.add(butRedo);
        butRedo.addActionListener(RedoCmd);

        /*
         JButton butClear = new JButton("Clear");
         butClear.setToolTipText("Clear selected Commands");
         panButtons.add(butClear);
         butClear.addActionListener(ClearCmd);
         */

        JButton butExit  = new JButton("Cancel");
        butExit.setToolTipText("Close Window");
        panButtons.add(butExit);
        butExit.addActionListener(ExitCmd);

        this.getContentPane().add(panButtons, BorderLayout.SOUTH);
        this.setResizable(true);
        Dimension dimSize=new Dimension(400,400);
        this.setPreferredSize(dimSize);
        this.setSize(dimSize);
    }

    public void setText(LogCmd LC) {
        this.TA.setText(LC.getText());
    }

    public void RedoButton() {
        int z=alcList.length;

        for(int i=0; i<z; i++) {
            alcList[i].Redo(LW);

        }
    }

    public void ExitButton() {
        this.dispose();
    }

    public void ClearButton() {}


}
