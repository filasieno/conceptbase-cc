/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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

package i5.cb.api;

import i5.cb.Contract;

/** A static class with some utility functions for ConceptBase.
 * 
 * @author   Christoph Quix
 * @author   Rainer Hermanns
 * @version  1.0
 */

public class CButil  
{  
	/**
	 * decodes an ipc string
	 * 
	 * @param sMsg the string to decode
	 * @return the decoded string
	 */
	
	// Exception class: CBUtilException
	// exceptions that may occur:
	// =========================================================	
	// --> StringIndexOutOfBoundsException --> CBDecodeException
	// --> StringIndexOutOfBoundsException --> CBEncodeException
	// =========================================================	
	
	public static String decodeStringIfPossible(String sMsg) {
		if (!sMsg.startsWith("\"") || !sMsg.endsWith("\""))
		  return sMsg;
		else {
			try {
				return decodeString(sMsg);
			}
			catch(CBDecodeException e) {
				return sMsg;
			}
		}
	}
	
	
	public static String decodeString(String sMsg) 
	  throws CBDecodeException 
	 {	
		 assert sMsg != null : "CButil.CBdecodeString(String)";
		 
		 
		 StringBuffer sbMsg=new StringBuffer(sMsg.length());
		 String sRet;
		 
		 try  {
			 int iPos=1;
			 
			 
			 // read message and strip backslashes
			 
			 while(sMsg.charAt(iPos)!='\"') {
				 
				 // backslash is an escape character and can be skipped
				 
				 if (sMsg.charAt(iPos)=='\\')
				   iPos++;
				 sbMsg.append(sMsg.charAt(iPos));
				 iPos++;
			 }
			 sRet=sbMsg.toString();
		 }
		 
		 catch(StringIndexOutOfBoundsException e) {
			 throw new CBDecodeException("CButil.CBdecodeString(String): Cannot decode String" + e.getMessage());
			 
		 }
		 
		 Contract.ensures("CButil.CBdecodeString(String)",(sRet != null));
		 
		 return sRet;
	 }  // decodeString
	
	
	/**
	 * encodes an ipc string
	 * 
	 * @param sMsg the string to encode
	 * @return the encoded string
	 **/
	public static String encodeString(String sMsg) 
	 {	
		 assert sMsg != null : "CButil.CBencodeString(String)";
		 
		 StringBuffer sbMsg = new StringBuffer( (int)((float)sMsg.length() * 1.2) + 2 );
		 String sRet;
		 
		 try {
			 sbMsg.append('\"');
			 
			 for( int iPos=0; iPos < sMsg.length(); iPos++ ) {			
				 switch (sMsg.charAt(iPos)) {
				  case '\"':
				  case '\\':
					 sbMsg.append('\\');
				  default:
					 sbMsg.append(sMsg.charAt(iPos));
				 }
			 }  // for
			 
			 sbMsg.append('\"');
			 
			 sRet=sbMsg.toString();
		 }  // try
		 catch(StringIndexOutOfBoundsException e) {
			 throw new Error("CButil.CBencodeString(String): Cannot encode String " + 
							 e.getMessage());
			 // this would be a bug in encodeString()!
		 }
		 
		 Contract.ensures("CButil.CBencodeString(String)",(sRet != null));
		 
		 return sRet;
	 }  // encodeString
	
}  // class CButil




