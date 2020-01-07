/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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


/// Idee: spezielle exception mit zusaetzlichem Argument, das die frames
/// aufnimmt. Dann koennte man einen speziellen Dialog aufrufen, der 
/// einen Knopf "More Info" enthaelt. Auf Knopfdruck koennen dann die 
/// Argumente in einem eigenen Fenster angezeigt werden (die Frames
/// koennen riesig sein und nicht auf den Schirm passen).
/// Das kann man im Prinzip bei allen aehnlichen exceptions so machen!!
///
/// Ist inzwischen in i5.cb.CBException verwirklicht worden.

/**
 * represents an RMI-able connection to a ConceptBase server
 *
 * @author Christoph Radig
 **/
public class CBConnection
extends CBclient
{
	CBConnectionData connectionData;
	
	/**
	 * opens a direct connection to a ConceptBase server, via a local CBclient object.
	 * There is no timeout on this connection by default, since the server sometimes
	 * computes for minutes or hours, and we don't want to miss the results... ;-)
	 *
	 * @param sHostName  name of the host where the server is running
	 * @param iPortNo    portno under which the server is running
	 * @param sToolName  name of the tool/client (optional)
	 * @param sUserName  name of the user who wants to connect (optional)
	 **/
	public CBConnection( String sHostName, int iPortNo,
						String sToolName, String sUserName )
	  throws CBException
	 {
		 super( sHostName, iPortNo, sToolName, sUserName );
		 
		 connectionData =
		   new CBConnectionData( sHostName, iPortNo, sToolName, sUserName );
		 
		 try {
			 setTimeOut( 0 );
			 // no timeout on a notification connection
		 }
		 catch( RemoteException ex ) {
			 // cannot occur here
			 //CHECK_FALSE
		 }
		 
		 //POST isOpen()
		 //POST getTimeOut() == 0
	 }  // ctor
	
	
	/**
	 * opens a connection to a ConceptBase server, either via a local or a remote
	 * CBclient object, depending on <code>connData</code>.
	 * There is no timeout on this connection by default, since the server sometimes
	 * computes for minutes or hours, and we don't want to miss the results... ;-)
	 *
	 * @see CBConnectionData
	 **/
	public CBConnection( CBConnectionData connData )
	  throws CBException, RemoteException, java.net.MalformedURLException,
	java.rmi.NotBoundException
	 {
		 super( connData.sHostName, connData.iPortNo, connData.sToolName,
			   connData.sUserName, connData.iUseCBclient,
			   connData.sRMIServerHostName, connData.iRMIServerPortNo );
		 
		 this.connectionData = connData;
		 
		 setTimeOut( 0 );
		 
		 //POST isOpen()
		 //POST getTimeOut() == 0
	 }  // ctor
	
    
	/**
	 * opens a connection to a ConceptBase server, either via a local or a remote
	 * CBclient object, depending on <code>iUseCBclient</code>.
	 * There is no timeout on this connection by default, since the server sometimes
	 * computes for minutes or hours, and we don't want to miss the results... ;-)
	 *
	 * @param sHostName name of the host running CBserver to connect to
	 * @param iPortNo port number under which the CBserver offers its services
	 * @param sToolName tool name under which this client will connect
	 * @param sUserName user name for registering to the CBserver
	 * @param iUseCBclient  (see USE_xxx constants)
	 * @param sRMIServerHostName hostname of the RMI server
	 * @param iRMIServerPortNo portno of the RMI server. If == -1, the default
	 *   portno (1099) is used.
	 **/
	public CBConnection( String sHostName, int iPortNo,
						String sToolName, String sUserName,
						int iUseCBclient, String sRMIServerHostName, int iRMIServerPortNo )
	  throws CBException, RemoteException, java.net.MalformedURLException,
	java.rmi.NotBoundException
	 {
		 this( new CBConnectionData( sHostName, iPortNo, sToolName, sUserName, 
									iUseCBclient, sRMIServerHostName, iRMIServerPortNo ) );
		 
		 //POST isOpen()
		 //POST getTimeOut() == 0
	 }  // ctor
	
	
	/**
	 * is the connection open at the moment?
	 **/
	public boolean isOpen()
	  throws RemoteException
	 {
		 return isConnected();
	 }
	
	
	/**
	 * closes the connection if it is still open
	 **/
	protected void finalize()
	  throws Throwable
	 {
		 if( isOpen() ) {
			 try {
				 close();
			 }
			 catch( Exception ex ) {
				 System.out.println( "CBConnection.finalize: Closing " + 
									this.toString() + " failed. Exception thrown:" + ex.toString() );
				 ex.printStackTrace();
			 }  // catch
		 }  // if
		 
		 super.finalize();
		 
		 //POST !isOpen()
	 }  // finalize
	
	
	/**
	 * closes the connection
	 **/
	public void close()
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer answer = cancelMe();
		 if( answer.getCompletion() != CBanswer.OK )
		   throw new CBException( "Could not disconnect from server.", 
								 "CB server returns " + answer.toString() );
		 
		 //POST !isOpen()
	 }  // close
	
	
	/**
	 * @return the connection information
	 **/
	public final CBConnectionData getConnectionData()
	 {
		 return connectionData;
	 }
	
	
	/**
	 * @return  name of the host on which the server is running
	 **/
	public final String getHostName()
	 {
		 return connectionData.sHostName;
	 }
	
	
	/**
	 * @return  portno under which the server is running
	 **/
	public final int getPortNo()
	 {
		 return connectionData.iPortNo;
	 }
	
	
	/**
	 * @return  name of the tool/client
	 **/
	public final String getToolName()
	 {

		 return connectionData.sToolName;
	 }
	
	
	/**
	 * @return  name of the user who established the connection
	 **/
	public final String getUserName()
	 {
		 return connectionData.sUserName;
	 }
	
	
	/**
	 * tells Telos frames to the server
	 * @param sFrames  Telos frames (as string)
	 **/
	public CBanswer tell( String sFrames )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = super.tell( sFrames );
		 
		 if( result.getCompletion() == CBanswer.NOTHANDLED )
		   throw new CBException( "TELL could not be handled by the CB Server.", 
								 "answer: " + result.toString() );
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // tell
	
	
	/**
	 * untells Telos frames to the server
	 * @param sFrames  Telos frames (as string)
	 **/
	public CBanswer untell( String sFrames )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = super.untell( sFrames );
		 
		 if( result.getCompletion() == CBanswer.NOTHANDLED )
		   throw new CBException( "UNTELL could not be handled by the CB Server." );
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // untell
	
	
	/**
	 * retells Telos frames to the server, i.e. untells untellFrames and tells
	 * tellFrames in one transaction.
	 * @param sUntellFrames  Telos frames to untell
	 * @param sTellFrames  Telos frames to tell
	 **/
	public CBanswer retell( String sUntellFrames, String sTellFrames )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = super.retell( sUntellFrames, sTellFrames );
		 
		 if( result.getCompletion() == CBanswer.NOTHANDLED )
		   throw new CBException( "RETELL could not be handled by the CB Server.",
								 "answer: " + result.toString() );
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // retell
	
	
	/**
	 * asks the server something. An empty answer is represented as "nil".
	 * In contrast to CBclient.ask, if answerRep == "FRAME" or
	 * answerRep == "LABEL", an empty answer is represented by the 
	 * empty string (""), rather than the string "nil". In all other cases, 
	 * an empty answer is represented as "nil".
	 * Because of a conceptual error in ConceptBase, when using the answer
	 * representation "LABEL", an empty answer cannot be distinguished 
	 * from the answer containing only the object nil. 
	 * This function cannot fix this. The only solution is to avoid using 
	 * the object called nil in the database.
	 *
	 * @param sQuery  the query to ask
	 * @param sQueryFormat  the format of the query (must be FRAMES or OBJNAMES)
	 * @param sAnswerRep  the desired answer representation, 
	 *   e.g. FRAME, LABEL, VIEW
	 * @param sRollbackTime  the rollback time (e.g. Now)
	 *
	 * @see #askFrame( String, String )
	 * @see #askObjectName( String, String )
	 **/
	public CBanswer ask( String sQuery, String sQueryFormat, 
						String sAnswerRep, String sRollbackTime )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = 
		   super.ask( sQuery, sQueryFormat, sAnswerRep, sRollbackTime );
		 
		 if( result.getCompletion() == CBanswer.NOTHANDLED )
		   throw new CBException( "ASK could not be handled by the CB Server.\n" +
								 "Query: " + sQuery );
		 
		 // workaround for CB server bug:
		 if( result.getResult().equals( "nil" ) )
		   if( sAnswerRep.equals( "FRAME" ) || sAnswerRep.equals( "LABEL" ) )
			 result.sResult = "";
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // ask
	
	
	/**
	 * ask query as frame; rollbacktime is "Now".
	 *
	 * @param sQueryAsFrame  the query as a Telos frame
	 * @param sAnswerRep  the desired answer representation
	 **/
	public CBanswer askFrame( String sQueryAsFrame, String sAnswerRep )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = ask( sQueryAsFrame, "FRAMES", sAnswerRep, "Now" );
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // askFrame
	
	
	/**
	 * ask query as objectname; rollbacktime is "Now".
	 *
	 * @param sQueryAsObjectName  the query as an objectname (must be told before)
	 * @param sAnswerRep  the desired answer representation
	 **/
	public CBanswer askObjectName( String sQueryAsObjectName, String sAnswerRep )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = ask( sQueryAsObjectName, "OBJNAMES", sAnswerRep, "Now" );
		 
		 //POST result.getCompletion() != CBanswer.NOTHANDLED
		 
		 return result;
	 }  // askObjectName
	
	
	/**
	 * asks for the frame representation of an object. 
	 * (Calls the builtin query get_object.)
	 * @param sObjectName  name of the object
	 * @return  the frame representation of the object
	 **/
	public String getFrame( String sObjectName )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 String result = getObject( sObjectName );
		 if( result.equals( "error" ) )
		   throw new CBException( "CBConnection.getFrame(" +
								 sObjectName + ") failed." );
		 
		 return result;
	 }  // getFrame
	
	
	/**
	 * gets the error messages concerning the last operation.
	 * This should be called when CBanswer.getCompletion() == CBanswer.ERROR
	 * @return  the error message(s) from the server
	 **/
	public final String getErrorMessages()
	  throws CBException, RemoteException
	 {
		 return super.getErrorMessages();
	 }  // getErrorMessages
	
	
	/**
	 * stops the server. This is only allowed for the same user who started the server,
	 * and on the host where the server was started.
	 * @return  can be ignored. If the server can't be stopped, an exception is thrown.
	 *   We have to return an CBanswer though, because our superclass does.
	 **/
	public CBanswer stopServer()
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = super.stopServer();
		 
		 if( result.getCompletion() != CBanswer.OK )
		   throw new CBException( "Could not stop server. Must be the right user " +
								 "on the right host." );
		 
		 //POST !isOpen()
		 //POST result.getCompletion() == CBanswer.OK
		 
		 return result;
	 }  // stopServer
	
	
	/**
	 * tells the server to start sending notification messages about a
	 * certain issue on a certain notification connection.
	 * [Wahrscheinlich sollte hier void returned werden!]
	 *
	 * @param sIssue  must have the form <tt>type(name)</tt>, 
	 *          e.g. <tt>view(MyView)</tt>
	 * @param notifConn  the notification connection
	 **/
	public CBanswer startNotifyingAbout( String sIssue, 
										CBNotificationConnection notifConn )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 CBanswer result = notificationRequest( sIssue, notifConn.getClientId() );
		 
		 if( result.getCompletion() != CBanswer.OK )
		   throw new CBException( "Notification request could not be handled " +
								 "by the server." );
		 
		 // System.out.println( "THE RESULT IS: " + result.getResult() );
		 
		 //POST result.getCompletion() == CBanswer.OK
		 
		 return result;
	 }  // startNotifyingAbout
	
	
	/**
	 * tells the server to stop sending notification messages about a 
	 * particular issue.
	 * @param sIssue  must have the form <tt>type(name)</tt>, 
	 *          e.g. <tt>view(MyView)</tt>
	 * @param notifConn  the notification connection
	 **/
	public CBanswer stopNotifyingAbout( String sIssue,
									   CBNotificationConnection notifConn )
	  throws CBException, RemoteException
	 {
		 //PRE isOpen()
		 
		 String sDelIssue = "delete(" + sIssue + ")";
		 
		 CBanswer result = 
		   notificationRequest( sDelIssue, notifConn.getClientId() );
		 
		 if( result.getCompletion() != CBanswer.OK )
		   throw new CBException( "Notification request (stop) could not be handled " +
								 "by the server." );
		 
		 //POST result.getCompletion() == CBanswer.OK
		 
		 return result;
	 }  // stopNotifyingAbout
	
	
	/**
	 * tells the server to start sending notification messages about a
	 * certain view on a certain notification connection.
	 *
	 * @param sViewName  object name of a view
	 * @param notifConn  the notification connection
	 **/
	public CBanswer startNotifyingAboutView( String sViewName,
											CBNotificationConnection notifConn )
	  throws CBException, RemoteException
	 {
		 return startNotifyingAbout( "view(" + sViewName + ")", notifConn );
	 }
	
	
	/**
	 * tells the server to stop sending notification messages about a
	 * certain view on a certain notification connection.
	 *
	 * @param sViewName  object name of a view
	 * @param notifConn  the notification connection
	 **/
	public CBanswer stopNotifyingAboutView( String sViewName,
										   CBNotificationConnection notifConn )
	  throws CBException, RemoteException
	 {
		 return stopNotifyingAbout( "view(" + sViewName + ")", notifConn );
	 }
	
}  // class CBConnection
