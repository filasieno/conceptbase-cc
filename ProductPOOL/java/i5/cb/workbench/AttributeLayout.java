/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
*   <b> TelosEditor for CBIva 02.98  (ConceptBase) </b>
*
*   @see i5.cb.workbench.CBIva
*/
package i5.cb.workbench;

import javax.swing.JComponent;


/** AttributeLayout
*/

public abstract class AttributeLayout {
    protected String sPrompt;
    protected String sAttribute;
    protected int iType;
    protected int iFlag;
    protected String sQuery;
    protected String[] asValues;


    public AttributeLayout(String sPrompt, String sAttribute, int iType,
                           int iFlag, String sQuery, String[] asValues) {
        //            this.setMinimumSize(new Dimension(400,20));


        this.sPrompt    = sPrompt;
        this.sAttribute = sAttribute;
        this.iType    = iType;
        this.sQuery    = sQuery;
        this.asValues  = asValues;
        this.iFlag= iFlag;
        // Rahmen und Titel erzeugen... Titel = sPrompt



    }


    public abstract JComponent getComponent();

    public void init() {}


    public static final int NECESSARY = 1;
    public static final int MULTI     = 2;
    public static final int STRING    = 4;
    public static final int INTEGER   = 8;

    public static final int TEXTFIELD = 0;
    public static final int TEXTAREA  = 1;
    public static final int CHOICEBOX = 2;
    public static final int LISTBOX   = 3;
    public static final int COMBOBOX  = 4;

    public abstract String CheckAttribute(int iAttribute);

    public void setEditable(boolean b) {}

    public abstract String getText();
}


