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

package i5.cb.telos.object;


/**
 * represents an instantiation, specialization or attribute link.
 *
 * @author Christoph Radig
 **/

public abstract class TelosLink
extends TelosObject
implements java.io.Serializable{
    
    private TelosObject source;
    private TelosObject destination;
    private boolean bImplicit=false;
    public TelosLink(){}
    
    /**
     * @param destination  may be null for attributes
     **/
    TelosLink( TelosObject source, TelosObject destination ) {
        //PRE source != null
        
        this.source = source;
        this.destination = destination;
    }
    
    public final TelosObject getSource() {
        return source;
        //POST result != this
    }
    
    public final void setSource(TelosObject source){
        this.source = source;
    }
    
    public final TelosObject getDestination() {
        return destination;
    }
    
    public final void setDestination(TelosObject dest){
        this.destination = dest;
    }
    public void setImplicit(boolean b) {
        bImplicit=b;
    }
    
    /*
    public final TelosObject getPeer(TelosObject to){
        assert( (to == source) || (to == destination) );
        
        if(to == source) return destination
        else return source;
    }
    */
     
    public boolean isImplicit() {
        return bImplicit;
    }
}  // class TelosLink
