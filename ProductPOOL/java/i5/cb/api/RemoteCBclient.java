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

package i5.cb.api;

import i5.cb.CBException;

import java.rmi.RemoteException;


/**
 * RMI server implementation for ICBclient. Forwards all methods to a LocalCBclient
 * object, which represents a direct connection to a CB server.
 * @see ICBclient
 *
 * @author Christoph Radig
 **/

public class RemoteCBclient
  extends java.rmi.server.UnicastRemoteObject
  implements ICBclient
{
  /**
   * this local CBclient object is used to establish a direct connection to 
   * a CB server.
   **/
  LocalCBclient impl = new LocalCBclient();


  public RemoteCBclient()
    throws RemoteException
  {
  }

  public CBanswer enrollMe( String sHost, int iPort, 
			    String sTool, String sUser ) 
    throws CBException, RemoteException
  {
    return impl.enrollMe( sHost, iPort, sTool, sUser );
  }

  public CBanswer cancelMe()
    throws CBException, RemoteException
  {
    return impl.cancelMe();
  }

  public CBanswer tell( String sFrames ) 
    throws CBException, RemoteException
  {
    return impl.tell( sFrames );
  }

  public CBanswer tellTransactions( String sTransactions ) 
    throws CBException, RemoteException
  {
    return impl.tellTransactions( sTransactions );
  }

  public CBanswer untell( String sFrames ) 
    throws CBException, RemoteException
  {
    return impl.untell( sFrames );
  }

  public CBanswer tellModel( String[] asFiles ) 
    throws CBException, RemoteException
  {
    return impl.tellModel( asFiles );
  }

  public CBanswer retell( String sUntellFrames, String sTellFrames ) 
    throws CBException, RemoteException
  {
    return impl.retell( sUntellFrames, sTellFrames );
  }

  public CBanswer ask( String sQuery, String sQueryFormat, String sAnswerRep, 
		       String sRollbackTime ) 
    throws CBException, RemoteException
  {
    return impl.ask( sQuery, sQueryFormat, sAnswerRep, sRollbackTime );
  }

  public CBanswer askFrames( String sQuery, String sAnswerRep, 
			     String sRollbackTime )
    throws CBException, RemoteException
  {
    return impl.askFrames( sQuery, sAnswerRep, sRollbackTime );
  }

  public CBanswer askObjNames( String sQuery, String sAnswerRep, 
			       String sRollbackTime )
    throws CBException, RemoteException
  {
    return impl.askObjNames( sQuery, sAnswerRep, sRollbackTime );
  }

  public CBanswer hypoAsk( String sFrames, String sQuery, String sQueryFormat, 
			   String sAnswerRep, String sRollbackTime )
    throws CBException, RemoteException
  {
    return impl.hypoAsk( sFrames, sQuery, sQueryFormat, sAnswerRep, 
			 sRollbackTime );
  }

  public String getObject( String sObjname ) 
    throws CBException, RemoteException
  {
    return impl.getObject( sObjname );
  }
  
  public String findInstances( String sObjname ) 
    throws CBException, RemoteException
  {
    return impl.findInstances( sObjname );
  }

  public CBanswer stopServer() 
    throws CBException, RemoteException
  {
    return impl.stopServer();
  }

  public CBanswer LPIcall( String lpicall )
    throws CBException, RemoteException
  {
    return impl.LPIcall( lpicall );
  }

  public CBanswer nextMessage( String sType )
    throws CBException, RemoteException
  {
    return impl.nextMessage( sType );
  }

  public String getErrorMessages() 
    throws CBException, RemoteException
  {
    return impl.getErrorMessages();
  }

  public boolean isConnected()
    throws RemoteException
  {
    return impl.isConnected();
  }

  public String getHostName()
    throws RemoteException
  {
    return impl.getHostName();
  }

  public int getPort()
    throws RemoteException
  {
    return impl.getPort();
  }

  public String getUserName()
    throws RemoteException
  {
    return impl.getUserName();
  }

  public String getToolName()
    throws RemoteException
  {
    return impl.getToolName();
  }

  public String getServerId()
    throws RemoteException
  {
    return impl.getServerId();
  }

  public String getClientId()
    throws RemoteException
  {
    return impl.getClientId();
  }

  public boolean setTimeOut( int iMilliSecs )
    throws RemoteException
  {
    return impl.setTimeOut( iMilliSecs );
  }
  
  public int getTimeOut()
    throws RemoteException
  {
    return impl.getTimeOut();
  }

  public CBanswer setModule( String sModule )
    throws CBException, RemoteException
  {
    return impl.setModule( sModule );
  }

  public String getModule()
    throws RemoteException
  {
    return impl.getModule();
  }

  public CBanswer getModulePath()
    throws RemoteException
  {
    return impl.getModulePath();
  }

  public String listModule( String sModule )
    throws CBException, RemoteException
  {
    return impl.listModule( sModule );
  }

  public CBanswer notificationRequest( String sAbout )
    throws CBException, RemoteException
  {
    return impl.notificationRequest( sAbout );
  }

  public CBanswer notificationRequest( String sAbout, String sTool )
    throws CBException, RemoteException
  {
    return impl.notificationRequest( sAbout, sTool );
  }

  public CBanswer getNotificationMessage( int iTimeOut )
    throws CBException, RemoteException
  {
    return impl.getNotificationMessage( iTimeOut );
  }

  public void setConnected(boolean connected) {
  impl.setConnected(connected);
  }


/* ----- Simplified interface with String results */

  public String connect(String sHost, int iPort, String sTool, String sUser) {
     return impl.connect(sHost, iPort, sTool, sUser);
  }

  public String disconnect() {
     return impl.disconnect();
  }

  public String pwd() {
     return impl.pwd();
  }

  public String cd( String newModule ) {
     return impl.cd(newModule);
  }

  public String mkdir( String newModule ) {
     return impl.mkdir(newModule);
  }

  public String untells( String sFrames) {
     return impl.untells(sFrames);
  }

  public String tells( String sFrames ) {
     return impl.tells(sFrames);
  }

  public String asks( String sQuery ) {
     return impl.asks(sQuery);
  }

  public String asks( String sQuery, String sFormat ) {
     return impl.asks(sQuery, sFormat);
  }

  
}  // class RemoteCBclient
