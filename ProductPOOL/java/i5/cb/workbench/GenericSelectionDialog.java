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
*   <b> GenericSelectionDialog for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/

package i5.cb.workbench;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

public class  GenericSelectionDialog extends JInternalFrame implements ActionListener {

    protected CBIva    CBI;
    protected CBIvaClient cbClient;

    protected JFrame         parent;
    protected RList          list;
    private Box buttonBox;

    /**
    *   <b> Constructor  </b><BR>
    *
    *   @param CBI parent CBIva
    *   @see i5.cb.workbench.CBIva
    */
    public GenericSelectionDialog(CBIva CBI, String title, String label, String[] buttonLabels, Object[] listElements) {
        super(title,true,false,true,true);
        Dimension dimSize=new Dimension(400,300);
        this.setPreferredSize(dimSize);
        this.setMinimumSize(new Dimension(350,150));
        this.setSize(dimSize);

        this.getContentPane().setLayout(new BorderLayout());

        this.CBI=CBI;
        this.cbClient=CBI.getCBClient();

        JPanel header=new JPanel();
        header.setLayout(new GridLayout(1,1));
        this.getContentPane().add(header, BorderLayout.NORTH);

        JLabel genLabel = new JLabel(label);
        header.add(genLabel);

        list = new RList();

        for(int i = 0; i < listElements.length; i++)
            list.addSort(listElements[i]);

        this.getContentPane().add(BorderLayout.CENTER,list.getOnScrollPane());

        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new BorderLayout());
        buttonBox = new Box(BoxLayout.X_AXIS);
        addButtons(buttonLabels);
        buttonPanel.add(BorderLayout.CENTER,buttonBox);
        this.getContentPane().add(BorderLayout.SOUTH,buttonPanel);
    }

    public void addButtons(String[] buttonLabels) {
        for(int i =0; i < buttonLabels.length; i++) {
            JButton bt = new JButton(buttonLabels[i]);
            buttonBox.add(bt);
            bt.addActionListener(this);
        }
    }

    /**
    *   Function: <b> Excecute the Commands </b> <BR>
    *
    *   @param event the ActionEvent for the Command
    *   @see java.awt.event.ActionEvent
    */
    public void actionPerformed(ActionEvent event) {
        Object source = event.getSource();
        if(source instanceof JButton)
            buttonPressed(((JButton)source).getText());
    }

    public void buttonPressed(String label) {
        if (label.equals("Cancel")) {
            setVisible(false);
            dispose();
        }
    }

}
