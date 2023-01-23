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

package i5.cb.telos.examples;

import i5.cb.api.*;
import i5.cb.telos.frame.*;

import java.io.StringReader;

public class ExampleParser  {
	
 public static void main(String argv[]) {
	 // Test Parser
	 test1(argv);
	 
	 // Test Construction of a frame
	 test2();
	 
 }
	
	/* This examples shows the usage of the TelosParser
	 * and the access of the generated TelosFrame objects.
	 * Due to some name conflicts with standard java classes
	 * (Label, Enumeration, ...) we sometimes have to use the full
	 * class name. 
	 * 
	 * The program connects to a ConceptBase server 
	 * (remember to change host, port and user name when you try it)
	 * and then retrieves an object. The output (a string)
	 * is parsed and then each component of the object
	 * is printed on standard output.
	 * 
	 * */
 public static void test1(String argv[]) {
	 
	 if (argv.length<1) {
		 System.out.println("Usage: java ExampleParser <object>");
		 System.exit(1);
	 }
	 
	 
	 try{
		 CBclient cbClient=new CBclient("localhost",4001,"ExampleParser","user");
		 
		 // Get the object as string
		 
		 String sFrame=cbClient.getObject(argv[0]);
		 cbClient.cancelMe();
		 
		 // Create the TelosParser
		 TelosParser tpParser=new TelosParser(new StringReader(sFrame));
		 
		 // Parse the object
		 TelosFrames tfsFrames=null;
		 tfsFrames=tpParser.telosFrames();
		 
		 /* Instead of calling tpParser.telosFrames() which parses a list 
		  * of objects you can call telosFrame() which parses a single frame.
		  * (getObject returns everytime a single frame).
		  * 
		  * TelosFrame tfrFrame=tpParser.telosFrame();
		  * */
		 
		 // Get the first TelosFrame out of the set (that is the only one)
		 java.util.Enumeration eFrames=tfsFrames.elements();
		 TelosFrame tfrFrame=(TelosFrame) eFrames.nextElement();
		 
		 // Re-convert it into a string
		 System.out.println(tfrFrame.toString());
		 
		 // Print the object name
		 System.out.println("Object name:" + tfrFrame.objectName().toString());
		 
		 // The classes
		 if(tfrFrame.hasInOmegaSpec())
		 	 System.out.println("InOmega: " + tfrFrame.inOmegaSpec().toString());
		 
		 if(tfrFrame.hasInSpec()) {
			 java.util.Enumeration eInClasses=tfrFrame.inSpec().elements();
			 while (eInClasses.hasMoreElements()) 
			 	 System.out.println("In: " + ((ObjectName) eInClasses.nextElement()).toString());
		 }
		 
		 // Superclasses
		 if(tfrFrame.hasIsaSpec()) {
			 java.util.Enumeration eIsaClasses=tfrFrame.isaSpec().elements();
			 while (eIsaClasses.hasMoreElements()) 
			 	 System.out.println("Isa: " + ((ObjectName) eIsaClasses.nextElement()).toString());
		 }
		 
		 
		 // Get all attribute categories ...
		 if (tfrFrame.hasWithSpec()) { 
			 java.util.Enumeration eCategories=tfrFrame.getCategories().elements();
			 while(eCategories.hasMoreElements()) {
				 // This Label is in i5.cb.telos, not in java.awt !
				 Label labCategory=(Label) eCategories.nextElement();
				 System.out.println("Attributkategorie:" + labCategory.toString());
				 
				 // ... and get all the properties for one attribute category
				 java.util.Enumeration eProperties=tfrFrame.getPropertiesInCategory(labCategory).elements();
				 
				 // Print each property
				 while (eProperties.hasMoreElements()) {
					 Property prpAttribute=(Property) eProperties.nextElement();
					 
					 System.out.println("Label: " +prpAttribute.getLabel().toString());
					 System.out.println("Target: " +prpAttribute.getTarget().toString());
				 }
			 }
		 }
	 }
	 // Simple exception handling
	 catch(Exception e) {
		 System.out.println("Exception: "+e.getMessage());
		 System.exit(1);
	 }
 }
	
	/* The second method constructs a TelosFrame object and tries 
	 * to insert it into the object base.
	 * */
 public static void test2() {
	 
	 // Create the InOmegaSpec 
	 ObjectName onInOmega=new Label("Class");
	 
	 // Create the Object name
	 ObjectName onObject=new Label("Employee");
	 
	 // We dont have any classes or super classes
	 ObjectNames onsIn=new ObjectNames();
	 ObjectNames onsIsa=new ObjectNames();
	 
	 // Construct the frame without attributes (empty WithSpec), they are added later
	 TelosFrame tfrFrame=new TelosFrame(onInOmega,onObject,onsIn,onsIsa,new WithSpec());
	 
	 /* Add an attribute
	  * Attributecategory is attribute 
	  * Attributelabel is salary
	  * Attributevalue is Integer
	  * */
	 tfrFrame.addAttribute(new Label("attribute"),new Label("salary"),new Label("Integer"));
	 
	 /* Another Attribute, now with two attribute categories
	  * Attributecategories are attribute and necessary
	  * Attributelabel is name
	  * Attributevalue is String
	  * */
	 AttrCategories acs=new AttrCategories();
	 acs=acs.appendedBy(new Label("attribute"));
	 acs=acs.appendedBy(new Label("necessary"));
	 tfrFrame.addAttribute(acs,new Label("name"),new Label("String"));
	 
	 // Print out the frame 
	 System.out.println(tfrFrame.toString());
	 
	 try{
		 // Get a connection to a server
		 CBclient cbClient=new CBclient("localhost",4001,"ExampleParser","user");
		 
		 // and try to tell the frame
		 CBanswer cbaTellAnswer=cbClient.tell(tfrFrame.toString());
		 
		 // And what is the result?
		 if (cbaTellAnswer.getCompletion()==CBanswer.OK)
		 	 System.out.println("tell successful");
		 else
		 	 System.out.println("Error:"+cbClient.getErrorMessages());
		 
		 
		 // Insert an instance of Employee
		 onInOmega=null;
		 onObject=new Label("John");
		 onsIn=onsIn.appendedBy(new Label("Employee"));
		 // onsIsa is still empty
		 
		 tfrFrame=new TelosFrame(onInOmega,onObject,onsIn,onsIsa,new WithSpec());
		 
		 tfrFrame.addAttribute(new Label("name"),new Label("nj"),new Label(CButil.encodeString("John Smith")));
		 tfrFrame.addAttribute(new Label("salary"),new Label("js"),new Label("12345"));
		 
		 // Print out the frame
		 System.out.println(tfrFrame.toString());
		 
		 // and try to tell the frame
		 cbaTellAnswer=cbClient.tell(tfrFrame.toString());
		 
		 // And what is the result?
		 if (cbaTellAnswer.getCompletion()==CBanswer.OK)
		 	 System.out.println("tell successful");
		 else
		 	 System.out.println("Error:"+cbClient.getErrorMessages());
		 
		 // Close connection
		 cbClient.cancelMe();
		 
	 }
	 // Simple exception handling
	 catch(Exception e) {
		 System.out.println("Exception: "+e.getMessage());
		 System.exit(1);
	 }
	 
 }
}
	
	
	
	
