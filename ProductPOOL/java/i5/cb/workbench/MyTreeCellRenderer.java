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
*   <b> StatusBar for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.*;

import javax.swing.*;
import javax.swing.tree.TreeCellRenderer;

public class MyTreeCellRenderer extends JLabel implements TreeCellRenderer {
    /** Font used if the string to be displayed isn't a font. */
    static protected Font             defaultFont;
    /** Icon to use when the item is collapsed. */
    protected ImageIcon        collapsedIcon;
    /** Icon to use when the item is expanded. */
    protected ImageIcon        expandedIcon;

    public MyTreeCellRenderer(CBIva CBI)  {
        super();
        this.collapsedIcon = new ImageIcon(CBI.LoadImage("collapsed.gif"));
        this.expandedIcon = new ImageIcon(CBI.LoadImage("expanded.gif"));
        MyTreeCellRenderer.defaultFont = new Font("SansSerif", 0, 12);
    }


    /** Whether or not the item that was last configured is selected. */
    protected boolean            selected;

    /**
      * This is messaged from JTree whenever it needs to get the size
      * of the component or it wants to draw it.
      * This attempts to set the font based on value, which will be
      * a TreeNode.
      */
    public Component getTreeCellRendererComponent(JTree tree, Object value,
            boolean selected, boolean expanded,
            boolean leaf, int row,
            boolean hasFocus) {
        String          stringValue = tree.convertValueToText(value, selected,
                                      expanded, leaf, row, hasFocus);

        /* Set the text. */
        setText(stringValue);
        /* Tooltips used by the tree. */
        setToolTipText(stringValue);

        /* Set the image. */
        if(expanded)
            setIcon(expandedIcon);
        else if(!leaf)
            setIcon(collapsedIcon);
        else
            setIcon(null);

        setForeground(Color.blue);

        setBackground(Color.white);

        setFont(defaultFont);

        /* Update the selected flag for the next paint. */
        this.selected = selected;

        return this;
    }

    /**
      * paint is subclassed to draw the background correctly.  JLabel
      * currently does not allow backgrounds other than white, and it
      * will also fill behind the icon.  Something that isn't desirable.
      */
    public void paint(Graphics g) {
        Icon             currentI = getIcon();

        /* Pick background color up from parent (which will come from
        //       the JTree we're contained in). */
        //  if(selected)  bColor = SelectedBackgroundColor;
        //  else if(getParent() != null) bColor = getParent().getBackground();
        //  else bColor = getBackground();
        //
        //  g.setColor(bColor);

        if(currentI != null && getText() != null) {
            int          offset = (currentI.getIconWidth() + getIconTextGap());
            g.fillRect(offset, 0, getWidth() - 1 - offset,getHeight() - 1);
        }
        else
            g.fillRect(0, 0, getWidth()-1, getHeight()-1);
        super.paint(g);
    }
}
