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


import i5.cb.api.CBclient;
import i5.cb.telos.Transform;
import i5.cb.telos.frame.TelosFrames;
import i5.cb.telos.frame.TelosParser;

import java.io.DataOutputStream;
import java.io.StringReader;




public class Test {
	
	static String sFrames="Class Blubber with attribute bla : Integer end";
	static String sFrames2="Bla in Blubber with bla bb : 4 end";
	
	public static void main(String argv[]) throws Exception {
		// Test.test1();
		Test.test2();
	}
	
	public static void test1() throws Exception {
		
		TelosParser tp=new TelosParser(new StringReader(sFrames));
		
		ITelosObjectSet tos=Transform.toTelosObjectSet(tp.telosFrames());
		
		System.out.println(Transform.toObjectNamedPropositions(tos));
		
		TelosParser tp2=new TelosParser(new StringReader(sFrames2));
		
		TelosFrames tfs=tp2.telosFrames();
		tfs.writeTelos(new DataOutputStream(System.out));
		
		Transform.addFramesToTelosObjectSet(tfs,tos);
		
		System.out.println("\n\n");
		
		System.out.println(Transform.toObjectNamedPropositions(tos));

		Transform.addFramesToTelosObjectSet(tfs,tos);
		
		System.out.println("\n\n");
		
		System.out.println(Transform.toObjectNamedPropositions(tos));

	}
	
	public static void test2() throws Exception {
	
		CBclient cbClient=new CBclient("dix",4723,null,null);
		
		ObjectBaseInterface obi=new ObjectBaseInterface(cbClient);

		TelosObject cls=obi.getIndividual("Class");
		System.out.println("getIndividual(Class)=\n" + Transform.toObjectNamedProposition(cls));

		TelosObject prop=obi.getIndividual("Proposition");
		System.out.println("getIndividual(Proposition)=\n" + Transform.toObjectNamedProposition(prop));
		
		TelosObject qcls=obi.getIndividual("QueryClass");
		System.out.println("getIndividual(QueryClass)=\n" + Transform.toObjectNamedProposition(qcls));

		TelosObject gqcls=obi.getIndividual("GenericQueryClass");
		System.out.println("getIndividual(GenericQueryClass)=\n" + Transform.toObjectNamedProposition(gqcls));

		if(obi.contains(cls)) 
		  System.out.println("contains(Class)=true");
		else
		  System.out.println("*** contains(Class)=false");

		System.out.println("Number of Propositions: " + obi.size());
		
		System.out.println("getInstantiation(Class,Class)=\n" + Transform.toObjectNamedProposition(obi.getInstantiation(cls,cls)));

		System.out.println("getSpecialization(QueryClass,Class)=\n" + Transform.toObjectNamedProposition(obi.getSpecialization(qcls,cls)));
		
		System.out.println("getAttribute(Class!rule)=\n" + Transform.toObjectNamedProposition(obi.getAttribute(cls,"rule")));
		
		System.out.println("getObject(QueryClass,in,Class)=\n" + Transform.toObjectNamedProposition(obi.getObject(qcls,TelosObject.INLABEL,cls)));
		
		System.out.println("getInstantiationsOf(GenericQueryClass)=\n" + Transform.toObjectNamedPropositions(obi.getInstantiationsOf(gqcls)));
		
		System.out.println("getSpecializationsFrom(GenericQueryClass)=\n" + Transform.toObjectNamedPropositions(obi.getSpecializationsFrom(gqcls)));
		
		System.out.println("getClassificationsOf(GenericQueryClass)=\n" + Transform.toObjectNamedPropositions(obi.getClassificationsOf(gqcls)));
		
		System.out.println("getGeneraliztionsFrom(GenericQueryClass)=\n" + Transform.toObjectNamedPropositions(obi.getGeneralizationsFrom(gqcls)));
		
		System.out.println("getAttributesOf(Class)=\n" + Transform.toObjectNamedPropositions(obi.getAttributesOf(cls)));

		System.out.println("getAttributesTo(Class)=\n" + Transform.toObjectNamedPropositions(obi.getAttributesTo(cls)));
		
		System.out.println("getAttributesOfCategory(Class,Proposition!graphtype)=\n" + 
						   Transform.toObjectNamedPropositions(obi.getAttributesOfCategory(cls,obi.getAttribute(prop,"graphtype"))));
		
		System.out.println("getAttributesOfExplicitCategory(Class,Proposition!graphtype)=\n" + 
						   Transform.toObjectNamedPropositions(obi.getAttributesOfExplicitCategory(cls,obi.getAttribute(prop,"graphtype"))));
		
		System.out.println("getOutgoingLinksOf(Class)=\n" +
						   Transform.toObjectNamedPropositions(obi.getOutgoingLinksOf(cls)));
		
		System.out.println("getIncomingLinksOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getIncomingLinksOf(qcls)));
		
		System.out.println("getExplicitClassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getExplicitClassesOf(qcls)));
		
		System.out.println("getExplicitInstancesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getExplicitInstancesOf(qcls)));
		
		System.out.println("getExplicitSuperclassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getExplicitSuperclassesOf(qcls)));
		
		System.out.println("getExplicitSubclassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getExplicitSubclassesOf(qcls)));
		
		System.out.println("getAllClassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getAllClassesOf(qcls)));
		
		System.out.println("getAllInstancesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getAllInstancesOf(qcls)));
		
		System.out.println("getAllSuperclassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getAllSuperclassesOf(qcls)));
		
		System.out.println("getAllSubclassesOf(QueryClass)=\n" +
						   Transform.toObjectNamedPropositions(obi.getAllSubclassesOf(qcls)));
		
		System.out.println("getLinks(QueryClass,Proposition)=\n" +
						   Transform.toObjectNamedPropositions(obi.getLinks(qcls,prop)));

		System.out.println("getLinks(QueryClass,Proposition,Attribute)=\n" +
						   Transform.toObjectNamedPropositions(obi.getLinks(qcls,prop,obi.getIndividual("Attribute"))));
						   
        cbClient.cancelMe();
		
	}
	
}





