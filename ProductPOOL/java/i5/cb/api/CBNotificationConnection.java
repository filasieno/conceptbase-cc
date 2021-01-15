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

import i5.cb.CBException;

import java.rmi.RemoteException;


/**
 * A connection to a ConceptBase server via which the server sends notification
 * messages to the client. This class now <i>extends</i> CBConnection, 
 * though strictly, a notification connection <i>is not a</i> regular 
 * connection. The reason is that we want to pose a query on this connection
 * before view maintenance starts. Otherwise, we would have to open another
 * connection, which would be unnecessarily expensive.
 *
 * There is never a timeout on a CBNotificationConnection. Maybe this is the only
 * real difference to CBConnection.
 *
 * @author Christoph Radig
 **/

public class CBNotificationConnection
  extends CBConnection
{
  /**
   * opens a direct notification connection to a ConceptBase server.
   * There is no timeout on this connection.
   *
   * @param sHostName  name of the host where the server is running
   * @param iPortNo    portno under which the server is running
   * @param sToolName  name of the tool/client (optional)
   * @param sUserName  name of the user who wants to connect (optional)
   **/
  public CBNotificationConnection( String sHostName, int iPortNo,
				   String sToolName, String sUserName )
    throws CBException
  {
    super( sHostName, iPortNo, sToolName, sUserName );

    //POST isOpen()
    //POST getTimeOut() == 0
  }  // ctor


  /**
   * opens a notification connection to a ConceptBase server, 
   * either via a local or a remote
   * CBclient object, depending on <code>connData</code>.
   * There is no timeout on this connection.
   *
   * @see CBConnectionData
   **/
  public CBNotificationConnection( CBConnectionData connectionData )
    throws CBException, RemoteException, java.net.MalformedURLException,
      java.rmi.NotBoundException
  {
    super( connectionData );

    //POST isOpen()
    //POST getTimeOut() == 0
  }  // ctor


  /**
   * opens a notification connection to a ConceptBase server, 
   * either via a local or a remote
   * CBclient object, depending on <code>iUseCBclient</code>.
   *
   * @param sHostName  name of the host running CBserver
   * @param iPortNo   port number of the CBserver
   * @param sToolName  tool name used for registering this client
   * @param sUserName  user name for registering this client
   * @param iUseCBclient  (see USE_xxx constants)
   * @param sRMIServerHostName hostname of the RMI server
   * @param iRMIServerPortNo portno of the RMI server. If == -1, the default
   *   portno (1099) is used.
   **/
  public CBNotificationConnection( String sHostName, int iPortNo,
    String sToolName, String sUserName,
    int iUseCBclient, String sRMIServerHostName, int iRMIServerPortNo )
    throws CBException, RemoteException, java.net.MalformedURLException,
      java.rmi.NotBoundException
  {
    super( sHostName, iPortNo, sToolName, sUserName, 
	   iUseCBclient, sRMIServerHostName, iRMIServerPortNo );

    //POST isOpen()
    //POST getTimeOut() == 0
  }  // ctor


 /**
   * waits to receive a notification message. Blocks until a message 
   * is received or the timeout has been reached.
   * May be placed in a loop, running in a separate thread.
   * @return  the notification message
   **/
  public CBanswer getNotificationMessageWithTimeOut( int iTimeOut )
    throws CBException, java.io.IOException
  {
    //PRE isOpen()

    CBanswer result = super.getNotificationMessage( iTimeOut );

    if( result.getCompletion() != CBanswer.NOTIFICATION )
      throw new CBException( "getNotificationMesage() could not be handled " +
			     "by the server." );

    //POST result.getCompletion() == CBanswer.NOTIFICATION

    return result;
  }  // getNotificationMessageWithTimeOut


 /**
   * waits to receive a notification message. Blocks until a message 
   * is received (no timeout, blocks infinitely long).
   * May be placed in a loop, running in a separate thread.
   * @return  the notification message
   **/
  public CBanswer getNotificationMessage()
    throws CBException, java.io.IOException
  {
    //PRE isOpen()

    CBanswer result = super.getNotificationMessage( 0 );

    if( result.getCompletion() != CBanswer.NOTIFICATION )
      throw new CBException( "getNotificationMesage() could not be handled " +
			     "by the server." );

    //POST result.getCompletion() == CBanswer.NOTIFICATION

    return result;
  }  // getNotificationMessage

}  // class CBNotificationConnection
