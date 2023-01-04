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
package i5.cb.workbench;

import java.awt.Dimension;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.JLayeredPane;

public class  ModuleDialog extends GenericSelectionDialog implements MouseListener {



    public ModuleDialog(CBIva CBI,String module, String[] buttons,String[] modules) {
        super(CBI, "Change Module", "Current Module is:  " + module,buttons,modules) ;
        list.addMouseListener(this);
    }

    public void buttonPressed(String label) {
        // Hier muessen die einzelnen Actions eingetragen werden
        if (label.equals("Change")) {
            String selectedItem = list.getSelectedItem().toString();

            cbClient.setModule(selectedItem);
            this.setVisible(false);
            this.dispose();
        }
        else {
            this.setVisible(false);
            this.dispose();
        }
    }

    public void mouseClicked(MouseEvent e) {
        if(e.getClickCount()>1) {
            String selectedItem = list.getSelectedItem().toString();
            cbClient.setModule(selectedItem);
            Dimension dim=this.getSize();
            Point pt=this.getLocation();
            this.dispose();

            String[] buttonLabels = {"Change", "Cancel"};
            String result=CBI.getCBClient().findModules();
            String[] listElements=CBI.getCBClient().asParseObjectNames(result);

            ModuleDialog dlg = new ModuleDialog(CBI,CBI.getCBClient().getModule(),buttonLabels,listElements);
            dlg.setVisible(true);
            CBI.add(dlg,JLayeredPane.MODAL_LAYER);
            dlg.setSize(dim);
            dlg.setLocation(pt);
        }
    }
    public void mouseEntered(MouseEvent e) {}
    public void mouseExited(MouseEvent e) {}
    public void mousePressed(MouseEvent e) {}
    public void mouseReleased(MouseEvent e) {}


}
