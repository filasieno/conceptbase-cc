/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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

package i5.cb.telos.object;

import java.io.ObjectStreamException;

/**
 * Telos Individual
 * @author Christoph Radig
 **/

public final class Individual
extends TelosObject
implements java.io.Serializable {
    /**
     * this object's label
     **/
    private String sLabel;

    public Individual(){
    }

    /**
     * Individuals may not be created directly. Use TelosObject.getIndividual()
     * instead.
     **/
    Individual( String sLabel ) {
        //PRE sLabel != null
        this.sLabel = sLabel;
    }

    public final int getSystemClass() {
        return INDIVIDUAL;
    }

    public final String getSystemClassName() {
        return "Individual";
    }

    public final TelosObject getSource() {
        return this;

        //POST result == this
    }

    public final TelosObject getDestination() {
        return this;

        //POST result == this
    }

    public final String getLabel() {
        return sLabel;

        //POST result != null
    }

    public final void setLabel(String label){
        sLabel = label;
    }

    /**
     * Required for correct Serialization: All TelosObjects are stored in
     * a static hashtable (@see i5.cb.telos.object.TelosObject). The normal serialization
     * method creates the TelosObject without checking if it already exists
     * in the hashtable. Therefore, we sometimes have different "Java Objects" that
     * represent the same "TelosObject". Overwriting the readResolve() method solves
     * this problem. It is called by the readObject-method of ObjectInputStream.
     * The "this" object is in this case the object which has just been read
     * from the ObjectInputStream.
     */
    public Object readResolve() throws ObjectStreamException {
        String sLabel=this.getLabel();
        Individual ind=TelosObject.lookupIndividual(sLabel);
        if(ind!=null)
            return ind;
        else {
            m_dictAllTelosObjects.put(this.getLabel(),this);
            return this;
        }
    }

}  // class Individual
