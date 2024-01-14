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
/** A class for parsing simple prolog-like terms.
* 
* The grammar for parsing simple prolog term 
* <pre>
* 1 term        -> identifier identTerm
* 2             |  []
* 3             |  [ termList ]
* 
* 4 identTerm   -> EMPTY
* 5             | ()
* 6             | ( termList )
* 
* 7 termList    -> term termList2
* 
* 8 termList2   -> , termList
* 9             |  EMPTY
* </pre>
*
* An identifier is a either an alphanumeric string ([a-zA-Z0-9]* and some special characters)
* or any string enclosed in "" or $$.
* 
* Tokens in the grammar refer to methods of the class.
* term  return a CBterm.
* identTerm, termList and termList2 return CBterm[].
* identifier returns a String.
* 
* */


package i5.cb.api;

public class CBterm  {
	
	
	/** Construct a CBterm out of the given string. 
	 * The String is parsed and the members of the resulting CBterm
	 * are initialized according to the contents of the string.
	 * 
	 * @param term the string to parse
	 * @exception CBtermParserException is thrown if an error occurs during parsing 
	 * */
 public CBterm(String term) throws CBtermParserException  {
	 String[] rest={ "" };
	 initialize(term,rest);
 }
	
	/** Gets the functor of the term. 
	 * @return the functor as string or null if the term has no functor
	 * */
 public String getFunctor() {
	 return sFunctor;
 }
	
	/** Gets the arguments of the term.
	 * @return the arguments stored in an array of CBterm (may have length=0 if there are no arguments)
	 * */
 public CBterm[] getArgs()  {
	 return ctArgs;
 }
	
	 /** Gets one argument of the term.
	  * @param i the argument position.
	  * @return the argument
	  * @exception ArrayIndexOutOfBoundsException if i is greater than the number of arguments
	  * */
 public CBterm getArg(int i) {
	 return ctArgs[i];
 }
	
	/** Test if the term is a list.
	 * @return true if the term is a list.
	 * */
 public boolean isList() {
	 return  sFunctor.equals(CBlistFunctor);
 }
	
	/** Test if the term is a constant (a functor with no arguments).
	 * @return true if the term is a functor.
	 * */
 public boolean isConstant() {
	 return  (ctArgs.length==0);
 }
	
	/** Get the length of the list, if the term is a list.
	 * @return the length of the list, or -1 if the term is not a list.
	 * */
 public int getListLength() {
	 if (!isList())
	 	 return (-1);
	 else 
	 	 return ctArgs.length;
 }
	
	/** Get the string representation of the term.
	 * @return the string
	 * */
 public String toString() {
	 return sTerm;
 }
	
	
	/* ============ PRIVATE METHODS ================ */
	
	/** Construct a term out of the given string and return the rest
	 * of the string which is not part of the parsed term.
	 * @param term the string to parse
	 * @param restout a string array with one element, which is the unparsed rest of the input string
	 * @exception CBtermParserException is thrown, if the term can not be parsed
	 * */
 private CBterm(String term,String[] restout) throws CBtermParserException {
	 initialize(term,restout);
 }

	/** Construct a term out of the given string and return the rest
	 * of the string which is not part of the parsed term.
	 * @param term the string to parse
	 * @param restout a string array with one element, which is the unparsed rest of the input string
	 * @exception CBtermParserException is thrown, if the term can not be parsed
	 * */
 private void initialize(String term,String[] restout) throws CBtermParserException {
	 
	 String[] rest={ "" };
	 ctArgs=ctEmptyArgs;
	 sFunctor=null;
	 
	 if (term!=null) {
		 // Rule 1
		 if (term.charAt(0)!='[') {
			 String tmp=identifier(term,rest);
			 
			 // Special case: "nil" is the same as empty list
			 if(tmp.equals("nil")) {
				 sFunctor=CBlistFunctor;
				 ctArgs=ctEmptyArgs;
				 restout[0]=rest[0];
			 }
			 else {
				 ctArgs=identTerm(rest[0],restout);
				 sFunctor=tmp;
			 }
		 }
		 else {
			 // Rule 2
			 if (term.charAt(1)==']') {
				 sFunctor=CBlistFunctor;
				 ctArgs=ctEmptyArgs;
				 restout[0]=term.substring(2);
			 }
			 // Rule 3
			 else  {
				 sFunctor=CBlistFunctor;
				 ctArgs=termList(term.substring(1),rest);
				 if (!rest[0].equals("") && rest[0].charAt(0)==']') {
					 restout[0]=rest[0].substring(1);
				 }
				 else {
					 throw new CBtermParserException("] expected.");
				 }
			 }
		 }
	 }
	 else
	 	 throw new CBtermParserException("Input expected. String ended before term was complete.");
	 
	 // Set the string representation to the parsed part of the input string
	 int len=term.length() - restout[0].length();
	 sTerm=term.substring(0,len);
 }
	
	
	/** Parse an indentifier.
	 * @param term the input string
	 * @param rest a string array with one element containing the rest of the term without the identifier
	 * @exception CBtermParserException is thrown, if the identifier can not be parsed
	 * */
 private String identifier(String term,String[] rest) throws CBtermParserException {
	 
	 if (term==null)
	 	 throw new CBtermParserException("Identifier expected.");
	 
	 int i=0;
	 String retstr=null;
	 
	 // Parsing a quoted identifier
	 if (term.charAt(0)=='"') {
		 i++;
		 while(i<term.length() && (term.charAt(i) !='"')) {
			 if (term.charAt(i) == '\\')
			 	 i++;
			 i++;
		 }
		 if (i<term.length()) {
			 retstr=term.substring(0,i+1);
			 rest[0]=term.substring(i+1);
			 return retstr;
		 }
		 else
		 	 throw new CBtermParserException("String ended while looking for closing \".");
	 }
	 
	 // Parsing an assertion string
	 if (term.charAt(0)=='$') {
		 i++;
		 while(i<term.length() && (term.charAt(i) !='$')) {
			 if (term.charAt(i) == '\\')
			 	 i++;
			 i++;
		 }
		 if (i<term.length()) {
			 retstr=term.substring(0,i+1);
			 rest[0]=term.substring(i+1);
			 return retstr;
		 }
		 else
		 	 throw new CBtermParserException("String ended while looking for closing $."); 
	 }
	 
	 // Parsing a normal identifier
	 while(i<term.length() && isIdentChar(term.charAt(i))) {
		 i++;
	 }
	 
	 retstr=term.substring(0,i);
	 rest[0]=term.substring(i);
	 return retstr;
 }
	
	
	/** Parse a identterm. Rule 4-6 of the grammar.
	 * @param term the input string
	 * @param rest a string array with one element containing the rest of the term without the identterm
	 * @exception CBtermParserException is thrown, if the identterm can not be parsed
	 * */
 private CBterm[] identTerm(String in,String[] rest) throws CBtermParserException {
	 
	 // Rule 4
	 if (in.length()==0 || in.charAt(0)!='(') {
		 rest[0]=in;
		 return ctEmptyArgs;
	 }
	 else {
		 // Rule 5
		 if (in.length()>0 && in.charAt(1)==')') {
			 rest[0]=in.substring(2);
			 return ctEmptyArgs;
		 }
		 // Rule 6
		 else  {
			 CBterm[] tmp=termList(in.substring(1),rest);
			 if (rest[0].charAt(0)==')') {
				 rest[0]=rest[0].substring(1);
				 return tmp;
			 }
			 else {
				 throw new CBtermParserException(") expected.");
			 }
		 }
	 }
 }
	
	
	/** Parse a term list. Rule 7 of the grammar.
	 * @param term the input string
	 * @param rest a string array with one element containing the rest of the term without the term list.
	 * @exception CBtermParserException is thrown, if the term list can not be parsed
	 * */
 private CBterm[] termList(String in, String[] rest) throws CBtermParserException {
	 
	 String[] restout={ "" };
	 
	 // Rule 7
	 CBterm ctTmp;
	 CBterm[] actTmp;
	 
	 ctTmp=new CBterm(in,restout);
	 actTmp=termList2(restout[0],rest);
	 
	 CBterm actTmp2[]=new CBterm[actTmp.length+1];
	 
	 for(int i=0;i<actTmp.length;i++)
	 	 actTmp2[i+1]=actTmp[i];
	 actTmp2[0]=ctTmp;
	 return actTmp2;
 }
	
	
	/** Parse a term list. Rule 8+9 of the grammar.
	 * @param term the input string
	 * @param rest a string array with one element containing the rest of the term without the term list.
	 * @exception CBtermParserException is thrown, if the term list can not be parsed
	 * */
 private CBterm[] termList2(String in, String[] rest) throws CBtermParserException {
	 
	 // Rule 8
	 if (in.charAt(0)==',') {
		 CBterm[] tmp=termList(in.substring(1),rest);
		 return tmp;
	 }
	 // Rule 9
	 else {
		 rest[0]=in;
		 return ctEmptyArgs;
	 }
 }
	
	
	/** Test if the character can be used in identifiers.
	 * @param the character
	 * @return true if the character may be used in identifiers, false otherwise.
	 * */
 private boolean isIdentChar(char c) {
	 for (int i=0;i<sIdentChars.length();i++) {
		 if (sIdentChars.charAt(i)==c) 
		 	 return true;
	 }
	 return false;
 }
	
	/// The functor of the term 
 private String sFunctor;
	
	/// The argument list of the term
 private CBterm[] ctArgs;
	
	/// The string representation of the term
 private String sTerm;
	
	/// A static variable for the functor of list
 private static String CBlistFunctor="[]";
	
	/// A static variable with all characters that are allowed in an identifier
 private static String sIdentChars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_#@%&*+?-=>.|^!";

	/// A static variable for an empty argument list
 private static CBterm[] ctEmptyArgs= {};
	

	/** Main Method for testing only 
	 * @param argv a term as string
	 * */
 public static void main(String[] argv) throws Exception {
	 
	 try  {
		 CBterm term=new CBterm(argv[0]);
		 
		 System.out.println(term.getFunctor());
		 for (int i=0;i<term.getArgs().length;i++)
		 	 System.out.println(i+ ".:" + term.getArg(i).toString());
	 }
	 catch(Exception e) {
		 System.out.println(e.getMessage());
		 Thread.dumpStack();
	 }
 }
}


