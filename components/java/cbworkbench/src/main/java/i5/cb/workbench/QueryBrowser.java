
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


package i5.cb.workbench;

import javax.swing.JLayeredPane;
import java.awt.*;

public class  QueryBrowser extends GenericSelectionDialog {


    public QueryBrowser(CBIva CBI, String[] buttons,String[] queries, String wintitle) {
        super(CBI, wintitle, "Select one ...", buttons, queries,true) ;  // single selection set to true
        this.setSize(260,560);
        if (CBI.getMainQueryBrowser() == null) 
          CBI.setMainQueryBrowser(this);
    }

    public void buttonPressed(String label) {

        if (label.equals("Ask") || label.equals("Call")) {
            String selectedItem = list.getSelectedItem().toString();

            QueryDialog qd=new QueryDialog(CBI,selectedItem);
            CBI.add(qd,JLayeredPane.MODAL_LAYER);
            qd.setLocation(220,5);
            try { qd.setSelected(false); qd.setSelected(true); } catch(Exception ex) {};
            return;
        }

        if (label.equals("Telos Editor")) {
            String selectedItem = list.getSelectedItem().toString();

            CBI.getActiveTelosEditor().getTelosTextArea().setText(CBI.getCBClient().getObject(selectedItem));
            return;
        }

        // else
        super.buttonPressed(label);
    }


}









