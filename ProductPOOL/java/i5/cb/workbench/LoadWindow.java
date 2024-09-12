/*
The ConceptBase+ Copyright

Copyright 2024-2024 Norgald AB. All rights reserved.

ConceptBase+ is derived from ConceptBase.cc (http://conceptbase.cc). See
[ProductPool]/doc/ExternalLicenses for details.

ConceptBase.cc is free software distributed under a FreeBSD-style license.
ConceptBase+ is a fork of ConceptBase.cc and adds functions for the
management of large enterprise architecture models to support various
methods for analyzing such models.

Contact: info@norgald.com

2024-03-05
*/


/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
 *   <b> AboutWindow for CBIva 02.98  (ConceptBase) </b>
 *
 *   @see i5.cb.workbench.CBIva
 */
package i5.cb.workbench;

import java.awt.BorderLayout;

import javax.swing.*;

/**
 *   Class:    <b> AboutWindow for CBIva  </b><BR>
 *   Function: <b> Creates an AboutWindow for CBIva </b> <BR>
 *
 *   @version 0.8 beta
 *   @author    Rainer Langohr
 *
 *   @see javax.swing.JFrame
 *   @see i5.cb.workbench.CBIva
 */
public class LoadWindow extends JFrame {

    private JTextField text=new JTextField();

    public void setText(String s) {
        this.text.setText("Loading "+s+" please wait.");
    }



    /**
     *   <b> Constructor  </b><BR>
     *
     *   Function: <b> creates a AboutWindow for CBIva with an Image </b> <BR>
     *
     *   @param CBI Parent CBIva
     */
    public LoadWindow(CBIva CBI) {
        this.setIconImage((new ImageIcon(CBI.LoadImage("CBIvaS.gif"))).getImage());
        this.setLocation(200,200);
        this.setSize(100,200);
        this.getContentPane().setLayout(new BorderLayout());
        ImageIcon ICBIva = new ImageIcon(CBI.LoadImage("CBIva.gif"));
        JLabel LCBIva=new JLabel(ICBIva);
        this.getContentPane().add(LCBIva, "Center");
        JPanel panSouth = new JPanel();
        panSouth.setLayout(new BorderLayout());
        panSouth.add(new JLabel("ConceptBase+ User Interface in Java",JLabel.CENTER),"North");
        panSouth.add(new JLabel("Copyright 2024-2024 by Norgald AB. All rights reserved.",JLabel.CENTER),"Center");
        panSouth.add(new JLabel("Based on the sources of ConceptBase.cc, copyrighted by The ConceptBase Team",JLabel.CENTER),"South");

        this.getContentPane().add(text,"North");
        this.getContentPane().add(panSouth, "South");
        text.setEditable(false);
        this.setResizable(false);
        this.setVisible(true);
        this.pack();
    }
}
