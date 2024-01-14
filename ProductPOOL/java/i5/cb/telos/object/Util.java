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
package i5.cb.telos.object;


/**
 * This utility class contains
 * convenience methods for Telos objects and Telos object sets
 *
 * @author Christoph Radig
 **/

public class Util
{
  /**
   * convenience method for changing an attribute value.
   * removes attrOld and its destination and their classification links
   * from tos and inserts the given new destination, a new attribute link
   * and the corresponding new classification links.
   **/
  public static void changeAttribute( ITelosObjectSet tos, 
    Attribute attrOld, TelosObject toNewDestination )
  {
    // 1. removals:
    tos.remove( attrOld );
    tos.remove( attrOld.getDestination() );

    ITelosObjectSet tosOldClassificationsFromAttr =
      tos.getClassificationsOf( attrOld );
    ITelosObjectSet tosOldClassificationsFromDest =
      tos.getClassificationsOf( attrOld.getDestination() );

    tos.remove( tosOldClassificationsFromAttr );
    tos.remove( tosOldClassificationsFromDest );

    // 2. insertions:
    tos.add( toNewDestination );
    Attribute attrNew = TelosObject.getAttribute( 
      attrOld.getSource(), attrOld.getLabel(), toNewDestination );
    tos.add( attrNew );

    ITelosObjectSet tosNewClassificationsFromAttr =
      transformClassifications( tosOldClassificationsFromAttr, attrNew );
    ITelosObjectSet tosNewClassificationsFromDest =
      transformClassifications( tosOldClassificationsFromDest, 
        toNewDestination );
    
    tos.add( tosNewClassificationsFromAttr );
    tos.add( tosNewClassificationsFromDest );
  }  // changeAttribute


  static ITelosObjectSet transformClassifications( 
    ITelosObjectSet tosOldClassifications, TelosObject toNewSource )
  {
    ITelosObjectSet result = null;
    try {
      result = (ITelosObjectSet) 
        tosOldClassifications.getClass().newInstance();
    }
    catch( InstantiationException ex ) {
      throw new Error();
    }
    catch( IllegalAccessException ex ) {
      throw new Error();
    }

    java.util.Enumeration iter = tosOldClassifications.elements();
    while( iter.hasMoreElements() ) {
      TelosObject to = (TelosObject) iter.nextElement();
      Instantiation instNew = TelosObject.getInstantiation(
        toNewSource, to.getDestination() );
      result.add( instNew );
    }

    return result;
  }  // transformClassifications

}  // class Util
