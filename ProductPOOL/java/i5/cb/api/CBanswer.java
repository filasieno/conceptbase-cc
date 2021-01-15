/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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

package i5.cb.api;


/**
 * A class to represent IPC answers of the ConceptBase server.
 *
 * @author   Christoph Quix
 * @author   Rainer Hermanns
 * @version  0.2
 * @see      i5.cb.api.CBclient
 */

public class CBanswer
  implements java.io.Serializable
{
  /**
   * Value for completion
   */
  public final static int OK=0;

  /**
   * Value for completion
   */
  public final static int ERROR=1;

  /**
   * Value for completion
   */
  public final static int NOTIFICATION=2;

  /**
   * Value for completion
   */
  public final static int NOTHANDLED=3;

  /**
   * Constructs a CBanswer object from a IPC-Answer string
   *
   * @param sMsg the ipc answer send by the server
   * @exception CBMessageException is thrown if the answer can not be parsed.
   */
  public CBanswer(String sMsg) throws CBMessageException {

    assert sMsg!=null : "CBanswer.CBanswer(String)";

    try  {
      // Defaults, falls Fehler auftritt
      sSender=null;
      sResult=null;
      iCompletion=NOTHANDLED;

      CBterm cbtAns=new CBterm(sMsg);

      if(cbtAns.getFunctor().equals("ipcanswer") && cbtAns.getArgs().length==3) {
				// Sender
	sSender=CButil.decodeString(cbtAns.getArg(0).toString());

				// Setze iCompletion auf den dem String entsprechenden Wert
	String sCompletion=cbtAns.getArg(1).toString();
	if (sCompletion.compareTo("ok")==0)
	  iCompletion=OK;
	if (sCompletion.compareTo("error")==0)
	  iCompletion=ERROR;
	if (sCompletion.compareTo("notification")==0)
	  iCompletion=NOTIFICATION;


	sResult=CButil.decodeString(cbtAns.getArg(2).toString());
      }
    }  // try

    catch (Exception e) {
      throw new CBMessageException("CBMessageException in CBanswer.CBanswer(String):" +
	e.getMessage());

    }
    finally  {
      if (sSender==null)
	sSender="unknown";
      if ((iCompletion<OK) || (iCompletion> NOTHANDLED))
	iCompletion=NOTHANDLED;
      if (sResult==null)
	sResult="not handled";
    }

    assert (sSender!=null &&
      iCompletion >= CBanswer.OK &&
      iCompletion <= CBanswer.NOTHANDLED &&
      sResult!=null) : "CBanswer.CBanswer(String)";
  }  // ctor


  /**
   * Returns the responding tool of the answer
   *
   * @return the responding tool
   */
  public String getRespondingTool() {
    return sSender;
  }

  /**
   * Returns the completion of the answer
   *
   * @return the completion
   */
  public int getCompletion() {
    return iCompletion;
  }

  /**
   * Merges this CBanswer with another CBanswer old but combining the iCompletion; sResult and sSender are
   * not merged from old
   *
   * @param old the other CBanswer
   */
  public void mergeCBanswer(CBanswer old) {
    if (this != null && old != null)
      this.iCompletion = Math.max(this.iCompletion,old.iCompletion);
  }

  /**
   * Returns a string representation of the completion value
   * @return a String
   */
  public String getCompletionString() {
      switch(iCompletion) {
      case OK:
          return "OK";
      case ERROR:
          return "ERROR";
      case NOTIFICATION:
          return "NOTIFICATION";
      case NOTHANDLED:
          return "NOTHANDLED";
      }
      return "UNKNOWN_COMPLETION_VALUE";
  }

  /**
   * Returns the result of the answer
   *
   * @return the result
   */
  public String getResult() {
    return sResult;
  }


  public String toString()
  {
    return "completion: " + getCompletion() + " - result: " + getResult();
  }


  /* Private section */
  private String sSender;
  private int iCompletion;
  String sResult;

}  // class CBanswer
