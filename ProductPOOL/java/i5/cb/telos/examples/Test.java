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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

package i5.cb.telos.examples;

import i5.cb.telos.frame.*;

import java.io.*;

import com.objectspace.jgl.*;
import com.objectspace.jgl.algorithms.Applying;
import com.objectspace.jgl.algorithms.Finding;
import com.objectspace.jgl.functions.Print;
import com.objectspace.jgl.predicates.BindSecondPredicate;


public class Test
{
  public static TelosFrames parse()
    throws ParseException, java.io.IOException
  {
    TelosParser parser = new TelosParser( System.in );
    TelosFrames frames = parser.telosFrames();

    System.out.println( "Telos frames successfully parsed." );

    System.out.println( "Ausgabe als Telos-Frames: (in String)\n\n" );
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    DataOutputStream dos = new DataOutputStream( bos );
    frames.writeTelos( dos );
    System.out.println( "Ausgabe des Strings:" );
    System.out.println( bos.toString() );

    /*
    System.out.println( "Ausgabe als Telos-Frames: (direkt)\n\n" );
    dos = new DataOutputStream( System.out );
    frames.writeTelos( dos );
    */

    /* Ergebnis: 
       Ausgabe in Stream mit writeTelos() ist VIEL schneller als das sukzessive
       Erzeugen eines Strings.
       Auch jetzt kann ein String aufgebaut werden, indem in einen ByteArrayOutputStream
       geschrieben wird. Dies ist aber VIEL schneller!
       Wird direkt auf die Standardausgabe bzw. in eine Datei geschrieben, wird gar
       kein zusaetzlicher Speicher benoetigt!
    */

    // System.out.println( "Ausgabe als SML-Fragmente:\n\n" + 
    //   frames.toSMLFragments() );

    return frames;
  }


  /*
  public static void linearParse()
    throws ParseException, java.io.IOException
  {
    TelosParser parser = new TelosParser( System.in );

    ByteArrayOutputStream bos1 = new ByteArrayOutputStream();
    DataOutputStream dos1 = new DataOutputStream( bos1 );

    SList objNames = new SList();

    while( true )
    {
      TelosFrame frame = parser.optionalTelosFrame();
      if( frame == null )
	break;

      frame.writeTelos( dos1 );

      if( frame.withSpec != null )
      {
	Set attributes = frame.withSpec.getPropertiesInCategory( new Label( "attribute" ) );
	dos1.writeBytes( "attributes: " );
	dos1.print( attributes );
	dos1.writeBytes( "\n\n" );
      }

      objNames.add( frame.objectName() );
    }  // while

    System.out.println( bos1.toString() );

    ByteArrayOutputStream bos2 = new ByteArrayOutputStream();
    DataOutputStream dos2 = new DataOutputStream( bos2 );

    dos2.writeBytes( "ObjectNames: [" );
    ForwardIterator iter = objNames.start();
    while( iter.hasMoreElements() )
    {
      ( (ObjectName) iter.nextElement() ).writeTelos( dos2 );
      if( iter.hasMoreElements() )
        dos2.writeBytes( ", " );
    }
    dos2.writeBytes( "]" );

    System.out.println( bos2.toString() );
  }  // linearParse
  */


 public static void serializeOut( TelosFrames _frames )
    throws java.io.IOException
  {
    System.out.print( "writing frames...");

    FileOutputStream f = new FileOutputStream( "frames.ser" );
    ObjectOutput s = new ObjectOutputStream( f );
    s.writeObject( _frames );
    s.close();

    System.out.println( "OK" );
  }

  public static TelosFrames serializeIn()
    throws java.io.IOException, java.lang.ClassNotFoundException
  {
    System.out.print( "reading frames...");

    FileInputStream f = new FileInputStream( "frames.ser" );
    ObjectInput s = new ObjectInputStream( f );
    
    TelosFrames result = (TelosFrames) s.readObject();
    s.close();

    System.out.println( "OK" );

    return result;
  }

  public static void serializeTest( TelosFrames _frames )
    throws java.io.IOException, java.lang.ClassNotFoundException
  {
    serializeOut( _frames );

    TelosFrames framesRead = serializeIn();
    
    System.out.println( "Gelesene Frames:" );
    DataOutputStream dos = new DataOutputStream( System.out );
    framesRead.writeTelos( dos );

    System.out.print( "Geschriebene und gelesene Frames sind " );
    if( _frames.equals( framesRead ) )
      System.out.println( "gleich." );
    else
      System.out.println( "verschieden." );    
  }  // serializeTest


  public static void cloneTest1( TelosFrames frames )
    throws java.io.IOException
    // test cloning of single frame
  {
    System.out.println( "cloneTest1" );

    TelosFrame firstFrameOld = (TelosFrame) frames.elements().nextElement();
    TelosFrame firstFrameNew = (TelosFrame) firstFrameOld.clone();

    firstFrameNew.setInOmegaSpec( new Label( "Individual" ) );

    DataOutputStream dos = new DataOutputStream( System.out );

    System.out.println( "alt:" );
    firstFrameOld.writeTelos( dos );

    System.out.println( "neu:" );
    firstFrameNew.writeTelos( dos );

    System.out.println( "alte Liste:" );
    frames.writeTelos( dos );
  }  // cloneTest1


  public static void cloneTest2( TelosFrames framesOld )
    throws java.io.IOException
    // test cloning of list of frames
  {
    System.out.println( "cloneTest2" );

    DataOutputStream dos = new DataOutputStream( System.out );

    System.out.println( "alt (1):" );
    framesOld.writeTelos( dos );

    TelosFrames framesNew = (TelosFrames) framesOld.clone();
    TelosFrame firstFrameNew = (TelosFrame) framesNew.elements().nextElement();

    firstFrameNew.setInOmegaSpec( new Label( "Individual" ) );

    System.out.println( "alt (2):" );
    framesOld.writeTelos( dos );

    System.out.println( "neu:" );
    framesNew.writeTelos( dos );    
  }  // cloneTest2


  public static TelosFrame findLastJohn( TelosFrames frames )
    throws java.io.IOException
  {
    TelosFrame result = null;

    DataOutputStream dos = new DataOutputStream( System.out );

    // find the frame with object name John
    
    class HasObjectName implements BinaryPredicate
    {
      public boolean execute( Object fst, Object objname )
      {
	TelosFrame frame = (TelosFrame) fst;
	
	return frame.objectName().equals( (ObjectName) objname );
      }
    }  // class HasObjectName
 
    UnaryPredicate isJohn =
      new BindSecondPredicate( new HasObjectName(), new Label( "John" ) );

    // InputIterator iter = Finding.detect( frames, isJohn );

    TelosFrame frame = (TelosFrame) Finding.detect( frames, isJohn );

    if( frame != null ) {
      System.out.println( "First Telos frame found:" );
      frame.writeTelos( dos );
    }

    InputIterator iter = Finding.findIf( frames, isJohn );
    System.out.println( "Telos frames found:" );
    if( iter.atEnd() )
      System.out.println( "<none>" );
    else { 
      while( !iter.atEnd() ) 
      {
	iter = Finding.findIf( iter, frames.finish(), isJohn );
	if( !iter.atEnd() ) 
	{
	  ( result = (TelosFrame) iter.get() ).writeTelos( dos );
	  iter.advance();
	}
      }  // while
    }

    /* Fazit: Ja, man kann so suchen. Es sieht annaehernd funktional aus.
       ABER: Es ist super-umstaendlich. Kein Vergleich zu Gofer!
     */
    
    return result;
  }  // findLastJohn


  public static void findTest2( TelosFrame johnFrame )
    throws java.io.IOException
  {
    DataOutputStream dos = new DataOutputStream( System.out );

    // find Attribute johnsCorrectName in Frame John:
    PropertyTarget jcn = johnFrame.getTargetOf( new Label( "johnsCorrectName" ) );
    System.out.print( "Johns correct name is " );
    jcn.writeTelos( dos );
    System.out.println();

    // find Attribute johnEarns in Frame John:
    jcn = johnFrame.getTargetOf( new Label( "johnEarns" ) );
    System.out.print( "Johns earns " );
    jcn.writeTelos( dos );
    System.out.println();

    // print all properties in category name:
    Set names = johnFrame.getPropertiesInCategory( new Label( "name" ) );
    Applying.forEach( names, new Print() );

    // print all categories that johnsCorrectName is in:
    Set categories = johnFrame.getCategoriesOf( new Label( "johnsCorrectName" ) );
    Applying.forEach( categories, new Print() );

  }  // findTest2


  public static void testSetFunctions( TelosFrames frames )
  {
    // Die Set-basierten functions sollten eher in eine separate Klasse rein! 

    System.out.println( "Test set functions: " );
    System.out.println();

    java.util.Enumeration en = frames.elements();

    while( en.hasMoreElements() ) 
    {
      TelosFrame frame = (TelosFrame) en.nextElement();
      System.out.println( "Categories of firstName " + frame.objectName() + ": " + 
			  frame.getCategoriesOf( new Label( "firstName" ) ) );
			  
      System.out.println( "Categories of " + frame.objectName() + ": " + 
			  frame.getCategories() );
    }  // while
  }  // testSetFunctions


  public static void main( String args[] )
    throws ParseException, java.io.IOException, java.lang.ClassNotFoundException
  {
    TelosFrames frames = parse();

    // serializeTest( frames );

    // linearParse();

    // cloneTest1( frames );
    // cloneTest2( frames );

    // TelosFrame johnFrame = findLastJohn( frames );
    // findTest2( johnFrame );

    testSetFunctions( frames );
  }  // main

}  // class Test

