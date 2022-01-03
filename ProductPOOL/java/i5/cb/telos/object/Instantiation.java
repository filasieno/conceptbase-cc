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
 * Telos instantiation link, that is an instance of the InstanceOf system
 * class.
 *
 * @author Christoph Radig
 **/

public final class Instantiation
  extends TelosLink
  implements java.io.Serializable
{
  /**
   * You cannot create Instantiation instances directly.
   * Use TelosObject.getInstantiation() instead.
   **/
  Instantiation( TelosObject source, TelosObject destination )
  {
    super( source, destination );

    //PRE source != null
    //PRE destination != null
  }

  public Instantiation() {
  }

  public final int getSystemClass()
  {
    return INSTANTIATION;
  }

  public final String getSystemClassName()
  {
    return "InstanceOf";
  }

  public final String getLabel()
  {
    return TelosObject.INLABEL;
  }

  /**
   * Required for correct Serialization (@see i5.cb.telos.object.Individual.readResolve)
   */
  public Object readResolve() throws ObjectStreamException {
    TelosObject toSrc=this.getSource();
    TelosObject toDst=this.getDestination();
    Instantiation inst=TelosObject.lookupInstantiation(toSrc,toDst);
    if(inst!=null)
        return inst;
    else {
        m_dictAllTelosObjects.put(TelosObject.getKey(this.getSource(),this.getLabel(),this.getDestination()),this);
        return this;
    }

  }

}  // class Instantiation
