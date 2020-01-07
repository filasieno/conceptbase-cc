/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
*   <b> RList for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.BorderLayout;
import java.awt.event.MouseEvent;
import java.util.Vector;

import javax.swing.*;

/**  <BR>
*   Class:    <b> RList for CBIva  </b><BR>
*   Function: <b> Creates a JList on a JScrollPane for FrameBrowser</b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see javax.swing.JList
*   @see javax.swing.JScrollPane
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
public class RList extends JList {

    private Vector vector = new Vector();

    private JPopupMenu popup=null;

    private JScrollPane parentJScrollPane=null;

    private JPanel main=new JPanel();



    /**
    *   <b> Constructor  </b><BR>
    */
    public RList(JPopupMenu popup) {
        super();
        this.setListData(vector);
        this.popup=popup;
    }

    /**
    *   <b> Constructor  </b><BR>
    */
    public RList() {
        super();
        this.setListData(vector);
    }

    /**
    */
    public void add
        (Object o) {
        this.vector.addElement(o);
        this.setListData(vector);
        this.repaint();
    }






    /**
     *   @param o Object to be added to the List
     */
    public void addSort(Object o) {
        int Anzahl=vector.size();
        int i;
        boolean insert=false;

        for (i=0; i<Anzahl; i++) {
            if
            (o.toString().compareTo(vector.elementAt(i).toString())<=0) {
                vector.insertElementAt(o, i);
                insert=true;
                break;
            }
        }
        if (!insert)
            vector.addElement(o);





        this.setListData(vector);

        this.repaint();

    }



    /**
    *   @return the selceted list-entry
    */
    public synchronized Object getSelectedItem() {
        return this.getSelectedValue();
    }

    public synchronized int[]
    getSelectedIndexes() {
        return this.getSelectedIndices();
    }


    /**
    *   Function: <b> remove all entries from the list </b> <BR>
    */
    public void removeAll() {
        vector = new Vector();
        this.setListData(vector);
        this.repaint();
    }

    /**
     *   @return all entries in the List 
     */
    public Object[] getItems() {
        int s = vector.size();
        int i;
        Object[] field = new Object[s];
        for (i=0; i<s; i++) {
            field[i]=vector.elementAt(i);
        }


        return field;
    }


    /**
     *   @return all selected entries in the List 
     */
    public Object[] getSelectedItems() {
        return this.getSelectedValues();
    }


    public void selectAll()  {
        this.setSelectionInterval(0,vector.size()-1);
        this.repaint();
    }

    public void deselectAll() {
        // There is an error with clearSelection. It only works, if
        // all items are selected.
        // So if the selection is not empty, we select all items
        // and then clear the selection.
        if (!this.isSelectionEmpty()) {
            this.setSelectionInterval(0,vector.size()-1);
            this.clearSelection();
        }

    }

    /**
     *   @param index the index to delete from the List
     */
    public void delItem(int index) {

        vector.removeElementAt(index);
        this.setListData(vector);
        this.repaint();
    }
 
    public JScrollPane getOnScrollPane()  {
        main.setLayout(new BorderLayout());
        main.add(this, "Center");
        this.parentJScrollPane=new JScrollPane(main);
        this.repaint();
        this.parentJScrollPane.repaint();

        return this.parentJScrollPane;
    }



    protected void processMouseEvent (MouseEvent e) {
        if ((e.isPopupTrigger()) | (e.getModifiers()==MouseEvent.BUTTON3_MASK))  {
            if (popup!=null)
                popup.show (e.getComponent(), e.getX(), e.getY());
        }
        else
            super.processMouseEvent (e);
    }


}
