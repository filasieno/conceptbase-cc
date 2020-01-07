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
import i5.cb.CBConfiguration;

import java.rmi.Naming;
import java.rmi.RemoteException;



/**
 * represents an optionally RMI-able connection to a ConceptBase server.
 *
 * @author Christoph Radig
 **/
public class CBclient
implements ICBclient
{
	/**
	 * use local CBclient object. This is the fastest option, which can be
	 * used when there is no firewall in the way.
	 **/
	public final static int USE_LOCAL_CBCLIENT = 1;

	/**
	 * use remote CBclient object, via RMI. This works even through firewalls,
	 * via HTTP connections.
	 **/
	public final static int USE_REMOTE_CBCLIENT = 2;

	/**
	 * first try to connect to the server directly, via the local CBclient
	 * object. If this fails, use the remote object.
	 **/
	public final static int USE_REMOTE_CBCLIENT_IF_NEEDED = 3;


	private ICBclient client;

        /** Utility field used by bound properties. */
        private java.beans.PropertyChangeSupport propertyChangeSupport =  new java.beans.PropertyChangeSupport(this);

	/**
	 * for compatibility only
	 * @Deprecated
	 **/
	public CBclient()
	  throws CBException
	 {
                 client = new LocalCBclient();
		 // this( "", 0, "", "" );
	 }  // ctor


	/**
	 * opens a direct connection to a ConceptBase server, via a LocalCBclient
	 * object.
	 *
	 * @param sHostName  name of the host where the server is running
	 * @param iPortNo    portno under which the server is running
	 * @param sToolName  name of the tool/client (optional)
	 * @param sUserName  name of the user who wants to connect (optional)
	 **/
	public CBclient( String sHostName, int iPortNo,
					String sToolName, String sUserName ) throws CBException {

		 try {
			 init( sHostName, iPortNo, sToolName, sUserName,
				  USE_LOCAL_CBCLIENT, null, 0 );
		 }
		 catch( RemoteException ex ) {
			 // kann nicht auftreten
			 //CHECK_FALSE
		 }
		 catch( java.net.MalformedURLException ex ) {
			 // kann nicht auftreten
			 //CHECK_FALSE
		 }
		 catch( java.rmi.NotBoundException ex ) {
			 // kann nicht auftreten
			 //CHECK_FALSE
		 }
	 }  // ctor


	/**
	 * opens a connection to a ConceptBase server, either via a local or a remote
	 * CBclient object, depending on <code>iUseCBclient</code>.
	 *
	 * @param sHostName  name of the host where the server is running
	 * @param iPortNo    portno under which the server is running
	 * @param sToolName  name of the tool/client (optional)
	 * @param sUserName  name of the user who wants to connect (optional)
	 * @param iUseCBclient  (see USE_xxx constants)
	 * @param sRMIServerHostName hostname of the RMI server
	 * @param iRMIServerPortNo portno of the RMI server. If == -1, the default
	 *   portno (1099) is used.
	 **/
	public CBclient( String sHostName, int iPortNo,
					String sToolName, String sUserName,
					int iUseCBclient, String sRMIServerHostName, int iRMIServerPortNo )
	  throws CBException, RemoteException, java.net.MalformedURLException,
	java.rmi.NotBoundException
	 {
		 init( sHostName, iPortNo, sToolName, sUserName,
			  iUseCBclient, sRMIServerHostName, iRMIServerPortNo );
		 // wg. Abfangen der exceptions im ersten ctor.
	 }  // ctor


	/**
	 * common constructor part. necessary because of exception handling.
	 *
	 * @param sHostName  name of the host where the server is running
	 * @param iPortNo    portno under which the server is running
	 * @param sToolName  name of the tool/client (optional)
	 * @param sUserName  name of the user who wants to connect (optional)
	 * @param iUseCBclient  (see USE_xxx constants)
	 * @param sRMIServerHostName hostname of the RMI server
	 * @param iRMIServerPortNo portno of the RMI server. If == -1, the default
	 *   portno (1099) is used.
	 **/
	void init( String sHostName, int iPortNo, String sToolName, String sUserName,
			  int iUseCBclient, String sRMIServerHostName, int iRMIServerPortNo )
	  throws CBException, RemoteException, java.net.MalformedURLException,
	java.rmi.NotBoundException
	 {
		 // System.out.println( "CBclient.init: opening CBclient type " +
		 // iUseCBclient );

		 CBanswer answer = null;

		 if( iRMIServerPortNo == -1 )
		   iRMIServerPortNo = 1099;
		 // default RMI portno

		 String sURL_RMIServer =
		   "//" + sRMIServerHostName + ":" + iRMIServerPortNo + "/" +
		   RemoteCBclientFactory.getRMIServerName();

		 switch( iUseCBclient )
		  {
		   case USE_LOCAL_CBCLIENT:
			  client = new LocalCBclient();
			  // System.out.println("CBclient.init 10");
			  answer = client.enrollMe( sHostName, iPortNo, sToolName, sUserName );
			  // System.out.println("CBclient.init 11");
			  break;


		   case USE_REMOTE_CBCLIENT:
			   {
				   // System.out.println("CBclient.init 1");
				   IRemoteCBclientFactory factory =
					 (IRemoteCBclientFactory) Naming.lookup( sURL_RMIServer );

				   // System.out.println("CBclient.init 2");
				   client = factory.createCBclient();
				   // System.out.println("CBclient.init 3");
				   answer = client.enrollMe( sHostName, iPortNo, sToolName, sUserName );
				   // System.out.println("CBclient.init 4");
				   break;
			   }  // case USE_REMOTE_CBCLIENT


		   case USE_REMOTE_CBCLIENT_IF_NEEDED:
			   {
				   System.out.println( "creating local CBclient" );
				   client = new LocalCBclient();

				   TryDirectConnect tc =
					 new TryDirectConnect( sHostName, iPortNo, sToolName, sUserName );
				   Thread t = new Thread( tc );
				   t.start();
				   System.out.println( "trying connect on local CBclient" );
				   final int iConnectionTimeOut = 10000;
				   try {
					   t.join( iConnectionTimeOut );  // max. 6 Sekunden warten
				   }
				   catch( InterruptedException ex ) {
				   }

				   if( tc.client != null ) {
					   client = tc.client;
					   System.out.println( "Direct connection established." );
				   }
				   else
					{
						// connection via local CBclient object failed.
						// So we try the remote object.
						System.out.println( "Direct connection could not be established. " );

						IRemoteCBclientFactory factory =
						  (IRemoteCBclientFactory) Naming.lookup( sURL_RMIServer );

						client = factory.createCBclient();
						answer = client.enrollMe( sHostName, iPortNo, sToolName, sUserName );

						if( answer.getCompletion() != CBanswer.OK ) {
							throw new CBException( "Could not connect to server on host " +
												  sHostName + " port " + iPortNo + ".",
												  "CB server returns " + answer.toString() );
						}
					}  // else
				   break;
			   }  // case USE_REMOTE_CBCLIENT_IF_NEEDED
		   default:
			  //CHECK_FALSE
		  }  // switch
		 // System.out.println("} CBclient.init");
		 //POST isOpen()
	 }  // init


	class TryDirectConnect
	  implements Runnable
	 {
		 /**
		  * != null, if connection was established
		  **/
		 public LocalCBclient client;

		 private String sHostName;
		 private int iPortNo;
		 private String sToolName;
		 private String sUserName;


		 public TryDirectConnect( String sHostName, int iPortNo,
								 String sToolName, String sUserName )
		  {
			  this.sHostName = sHostName;
			  this.iPortNo = iPortNo;
			  this.sToolName = sToolName;
			  this.sUserName = sUserName;
		  }

		 public void run()
		  {
			  try {
				  client = new LocalCBclient( sHostName, iPortNo, sToolName, sUserName );
			  }
			  catch( Exception ex ) {
				  System.out.println( "Direct connect failed. " + ex.getMessage() );
				  client = null;
				  // Fehlermeldungen hier ignorieren
			  }
		  }  // run
	 }  // inner class TryDirectConnect


	public CBanswer enrollMe( String sHost, int iPort, String sTool, String sUser )
	  throws CBException, RemoteException
	 {
		 return client.enrollMe( sHost, iPort, sTool, sUser );
	 }


	public CBanswer cancelMe()
	  throws CBException, RemoteException
	 {
		 return client.cancelMe();
	 }

	public CBanswer tell( String sFrames )
	  throws CBException, RemoteException
	 {
		 return client.tell( sFrames );
	 }

	public CBanswer tellTransactions( String sFrames )
	  throws CBException, RemoteException
	 {
		 return client.tellTransactions( sFrames );
	 }


	public CBanswer untell( String sFrames )
	  throws CBException, RemoteException
	 {
		 return client.untell( sFrames );
	 }

	public CBanswer tellModel( String[] asFiles )
	  throws CBException, RemoteException
	 {
		 return client.tellModel( asFiles );
	 }

	public CBanswer retell( String sUntellFrames, String sTellFrames )
	  throws CBException, RemoteException
	 {
		 return client.retell( sUntellFrames, sTellFrames );
	 }

	public CBanswer ask( String sQuery, String sQueryFormat, String sAnswerRep,
						String sRollbackTime )
	  throws CBException, RemoteException
	 {
		 return client.ask( sQuery, sQueryFormat, sAnswerRep, sRollbackTime );
	 }

	public CBanswer askFrames( String sQuery, String sAnswerRep,
							  String sRollbackTime )
	  throws CBException, RemoteException
	 {
		 return client.askFrames( sQuery, sAnswerRep, sRollbackTime );
	 }

	public CBanswer askObjNames( String sQuery, String sAnswerRep,
								String sRollbackTime )
	  throws CBException, RemoteException
	 {
		 return client.askObjNames( sQuery, sAnswerRep, sRollbackTime );
	 }

	public CBanswer hypoAsk( String sFrames, String sQuery, String sQueryFormat,
							String sAnswerRep, String sRollbackTime )
	  throws CBException, RemoteException
	 {
		 return client.hypoAsk( sFrames, sQuery, sQueryFormat, sAnswerRep,
							   sRollbackTime );
	 }

	public String getObject( String sObjname )
	  throws CBException, RemoteException
	 {
		 return client.getObject( sObjname );
	 }

	public String findInstances( String sObjname )
	  throws CBException, RemoteException
	 {
		 return client.findInstances( sObjname );
	 }

	public CBanswer stopServer()
	  throws CBException, RemoteException
	 {
		 return client.stopServer();
	 }

	public CBanswer LPIcall( String lpicall )
	  throws CBException, RemoteException
	 {
		 return client.LPIcall( lpicall );
	 }

	public CBanswer nextMessage( String sType )
	  throws CBException, RemoteException
	 {
		 return client.nextMessage( sType );
	 }

	public String getErrorMessages()
	  throws CBException, RemoteException
	 {
		 return client.getErrorMessages();
	 }



	public String getHostName()
	  throws RemoteException
	 {
		 return client.getHostName();
	 }

	public int getPort()
	  throws RemoteException
	 {
		 return client.getPort();
	 }

	public String getUserName()
	  throws RemoteException
	 {
		 return client.getUserName();
	 }

	public String getToolName()
	  throws RemoteException
	 {
		 return client.getToolName();
	 }

	public String getServerId()
	  throws RemoteException
	 {
		 return client.getServerId();
	 }

	public String getClientId()
	  throws RemoteException
	 {
		 return client.getClientId();
	 }

	public boolean setTimeOut( int iMilliSecs )
	  throws RemoteException
	 {
		 return client.setTimeOut( iMilliSecs );
	 }

	public int getTimeOut()
	  throws RemoteException
	 {
		 return client.getTimeOut();
	 }

	public CBanswer setModule( String sModule )
	  throws CBException, RemoteException
	 {
		 return client.setModule( sModule );
	 }

	public String getModule()
	  throws RemoteException
	 {
		 return client.getModule();
	 }

	public CBanswer getModulePath()
	  throws RemoteException
	 {
		 return client.getModulePath();
	 }

	public String  listModule(String sModule)
	  throws CBException, RemoteException
	 {
		 return client.listModule(sModule);
	 }

	public CBanswer notificationRequest( String sAbout )
	  throws CBException, RemoteException
	 {
		 return client.notificationRequest( sAbout );
	 }

	public CBanswer notificationRequest( String sAbout, String sTool )
	  throws CBException, RemoteException
	 {
		 return client.notificationRequest( sAbout, sTool );
	 }

	public CBanswer getNotificationMessage( int iTimeOut )
	  throws CBException, RemoteException
	 {
		 return client.getNotificationMessage( iTimeOut );
	 }

        /** Adds a PropertyChangeListener to the listener list.
         * @param l The listener to add.
         */
        public void addPropertyChangeListener(java.beans.PropertyChangeListener l) {
            propertyChangeSupport.addPropertyChangeListener(l);
        }

        /** Removes a PropertyChangeListener from the listener list.
         * @param l The listener to remove.
         */
        public void removePropertyChangeListener(java.beans.PropertyChangeListener l) {
            propertyChangeSupport.removePropertyChangeListener(l);
        }

        /** Getter for property connected.
         * @return Value of property connected.
         */
       public boolean isConnected()
	  throws RemoteException
	 {
		 return client.isConnected();
	 }


        /** Setter for property connected.
         * @param connected New value of property connected.
         */
       public void setConnected(boolean connected) {
            try{
            boolean oldConnected = client.isConnected();
            client.setConnected(connected);
            propertyChangeSupport.firePropertyChange("connected", new Boolean(oldConnected), new Boolean(connected));
            }catch(RemoteException re){
            System.out.println("CBClient.setConnected: caught RemoteException: "+ re.getMessage());
            }
        }


/* ----- Simplified interface with String results */


  public String connect( String sHost, int iPort, String sTool, String sUser ) {
     return client.connect(sHost, iPort, sTool, sUser);
  }


  public String disconnect() {
     return client.disconnect();
  }

  public String pwd() {
     return client.pwd();
  }

  public String cd( String newModule ) {
     return client.cd(newModule);
  }

  public String mkdir( String newModule ) {
     return client.mkdir(newModule);
  }

  public String untells( String sFrames) {
     return client.untells(sFrames);
  }

  public String tells( String sFrames ) {
     return client.tells(sFrames);
  }

  public String asks( String sQuery ){
     return client.asks(sQuery);
  }

  public String asks( String sQuery, String sFormat ) {
     return client.asks(sQuery, sFormat);
  }


     /** Start a local 'slave' CBserver in single user mode; slave mode means that the
     * CBserver will automatically shutdown when the last client (normally this CBFrame)
     * disconnects from it
     *
     * @param sPort  : the portnumber that the CBserver shall listen to
     * @return false if the execution of the command to start the CBserver failed
     */

   public static boolean startLocalCBserver(String sPort) {

      String CBserverCmd = CBConfiguration.getCBserverCmd();
      
      // command to start a single user CBserver in slave mode with no terminal output
      String[] cmdarray= {CBserverCmd, "-port",  sPort,
                          "-sm", "slave", "-t", "silent", "-mu", "disabled"};
      try {
        Process p=Runtime.getRuntime().exec(cmdarray);
        long waittime = 300L;  // to let CBserver start (in millisec)
        Thread.sleep(waittime);  // wait for CBserver to be up and running
      } catch (Exception e) {
         java.util.logging.Logger.getLogger("global").warning("Starting local CBserver failed!\n" + e.getMessage());
         return false;
      }

      // System.out.println("Attempt to connect ...");
      boolean alive = false;
      LocalCBclient lclient = new LocalCBclient();  // only used for pinging
      long waittime = 150L;  // millisec
      int iPort = 4001;
      iPort = Integer.parseInt(sPort);
      for (int i=1; i<=25; i++) {
        alive = lclient.pingCBserver("localhost", iPort);
        // System.out.println("Attempt to connect "+i);
        if (alive) {
          break;
        }
        try {
          Thread.sleep(waittime);
        } catch (Exception e) {}
        waittime = waittime + (int) (waittime/3);
      }

      return alive;
   }





}  // class CBclient
