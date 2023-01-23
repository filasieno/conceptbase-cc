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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/**
*   <b> FBCacheDialog for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import java.awt.BorderLayout;
import java.awt.Frame;

import javax.swing.*;


/**
*   Class:    <b> for CBIva  </b><BR>
*   Function: <b> Opens a dialogwindow to call edited Objects  </b> <BR>
*
*   @version 0.8 beta
*   @author    Rainer Langohr
*
*   @see i5.cb.workbench.FrameBrowser
*   @see i5.cb.workbench.CBIva
*/
public class FBCacheDialog extends JDialog {

    private RList lbCache;
    private JButton gbOk;

    /**
    *   public constant: OK  = 1
    */
    public final int OK=1;

    /**
    *   public constant: List =  2
    */
    public final int LIST=2;

    /**
    *   <b> Constructor  </b><BR>
    *
    *   Function: <b> Creates a CacheDialog </b> <BR>
    *
    *   @param target Parent FrameBrowser
    */
    public FBCacheDialog(FrameBrowser target) {
        super(new Frame(),"Select Class:",true);
        lbCache=new RList();
        gbOk= new JButton("Ok");
        gbOk.addActionListener(new FBCommand(FBCommand.OK_CACHE,this,target));
        JButton gbClear=new JButton("Clear");
        gbClear.addActionListener(new FBCommand(FBCommand.CLEAR_CACHE,this,target));
        /* JButton gbDelete=new JButton("Delete");
        gbDelete.addActionListener(new FBCommand(FBCommand.DELETE_CACHE,this,target)); */
        JPanel panButtons =new JPanel();
        panButtons.add(gbOk);
        panButtons.add(gbClear);
        // panButtons.add(gbDelete);
        getContentPane().setLayout(new BorderLayout(15,5));
        JScrollPane panList=new JScrollPane();
        panList.getViewport().setView(lbCache);
        getContentPane().add(panList,BorderLayout.CENTER);
        getContentPane().add(panButtons,BorderLayout.SOUTH);

        target.cacheDialog(this);

        setResizable(true);
        pack();
        setVisible(true);
    }


    /**
    *   @return the String of the selected Object
    */
    public String getObject() {
        if (lbCache.getSelectedIndex()!=-1)
            return (String)lbCache.getSelectedItem();
        else
            return new String("");
    }
    
    public RList getCacheList() {
    	return lbCache;
    }
}
