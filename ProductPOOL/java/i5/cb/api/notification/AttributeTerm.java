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

package i5.cb.api.notification;

import i5.cb.telos.frame.Label;
import i5.cb.telos.frame.ObjectName;


/**
 * representation of an attribute.
 * immutable.
 * @author Christoph Radig
 **/

public final class AttributeTerm
  extends Term
{
  Label attrCategory;
  ObjectName source;
  Label label;
  ObjectName destination;


  /**
   * called by the notification parser only.
   **/
  AttributeTerm( ObjectName objnameView, Label attrCategory, 
    ObjectName source, Label label, ObjectName destination )
  {
    super( objnameView );

    this.attrCategory = attrCategory;
    this.source = source;
    this.label = label;
    this.destination = destination;
  }  // ctor


  /**
   * @return the source of the attribute, as object name
   **/
  public final ObjectName getSource()
  {
    return source;
      // ObjectName is immutable
  }


  /**
   * @return the label of the attribute
   **/
  public final Label getLabel()
  {
    return label;
      // Label is immutable
  }


  /**
   * @return the destination of the attribute, as object name
   **/
  public final ObjectName getDestination()
  {
    return destination;
      // ObjectName is immutable
  }


  /**
   * @return the label of the attribute category
   **/
  public final Label getAttrCategory()
  {
    return attrCategory;
      // Label is immutable
  }


  public final String toString()
  {
    return getViewObjectName().toString() + 
      "(" + attrCategory.toString() + "," + 
      source.toString() + "," + label.toString() + "," + 
      destination.toString() + "))";
  }

}  // class AttributeTerm
