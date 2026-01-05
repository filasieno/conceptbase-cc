/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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



package i5.cb.graph;

import javax.swing.*;
import javax.swing.filechooser.FileView;
import javax.swing.text.DefaultStyledDocument;

    /**
   IMGFileChooser is like JFileChooser but allows to specify how the clip rectangle for the IMG export is determined
    */
    

public class IMGFileChooser extends JFileChooser {

    JRadioButton exportDiagramButton = null;
    JRadioButton exportCanvasButton = null;

    IMGFileChooser() {
      super();  // no-arg version is just like JFileChooser
    }

    IMGFileChooser(boolean exportAsDiagram) {

      super();

      exportDiagramButton = new JRadioButton("Whole diagram");
      exportDiagramButton.setSelected(exportAsDiagram);

      exportCanvasButton = new JRadioButton("Visible canvas");
      exportCanvasButton.setSelected(!exportAsDiagram);

      // Group the radio buttons so only one can be selected
      ButtonGroup group = new ButtonGroup();
      group.add(exportDiagramButton);
      group.add(exportCanvasButton);

      // Create a panel to hold both radio buttons
      JPanel radioPanel = new JPanel();
      radioPanel.setLayout(new BoxLayout(radioPanel, BoxLayout.Y_AXIS));
      radioPanel.setBorder(BorderFactory.createTitledBorder("Export Options"));
      
      // Add radio buttons to the panel, which is then set as accessory of the file chooser
      radioPanel.add(exportDiagramButton);
      radioPanel.add(exportCanvasButton);
      this.setAccessory(radioPanel);

      this.setDialogTitle("Export Image");

    }

    // return true if the user wants to export the whole diagram (all nodes and edges)
    // this is also the default
    public boolean diagramChosen() {
      if (exportDiagramButton == null)
         return true;
      else
         return(exportDiagramButton.isSelected());
    }

    // return true if the user wants to export the currently visiable canvas in which
    // parts or all of the diagram is visible
    public boolean canvasChosen() {
      if (exportCanvasButton == null)
         return false;
      else
         return(exportCanvasButton.isSelected());
    }


}



