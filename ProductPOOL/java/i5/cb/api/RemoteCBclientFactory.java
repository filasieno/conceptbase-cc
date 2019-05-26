/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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

import java.rmi.*;
import java.rmi.server.UnicastRemoteObject;
import java.util.Vector;


/**
 * RMI server implementation of IRemoteCBclientFactory,
 * which is able to dynamically create RemoteCBclient objects.
 * @see IRemoteCBclientFactory
 *
 * @author Christoph Radig
 **/

public class RemoteCBclientFactory
  extends UnicastRemoteObject
  implements IRemoteCBclientFactory
{
  private static final String sClassName = "i5.cb.api.RemoteCBclientFactory";

  /**
   * stores the connection objects so they are not garbage collected.
   **/
  Vector vConnections = new Vector();


  public RemoteCBclientFactory()
    throws RemoteException
  {
  }


  /**
   * @return the name of the RMI server
   **/
  public static String getRMIServerName()
  {
    return sClassName;
  }


  public ICBclient createCBclient()
    throws RemoteException
  {
    ICBclient result = new RemoteCBclient();

    vConnections.addElement( result );
      // to prevent gc

    return result;
  }  // createCBclient


  public void destroyCBclient( ICBclient remoteCBclient )
    throws RemoteException
  {
    vConnections.removeElement( remoteCBclient );
      // now gc is okay
  }  // destroyCBclient


  /**
   * binds an instance of RemoteCBclientFactory to an RMI registry.
   * Usage: RemoteCBclientFactory [-u] [<hostname> <portno>]
   **/
  public static void main( String[] args )
    throws Exception
  {
    System.setSecurityManager( new RMISecurityManager() );

    boolean bUnbind = false;

    String sURL = getRMIServerName();  // default

    int iArg = 0;
    while( args.length > iArg ) {
      if( args[iArg].equals( "-u" ) ) {
	bUnbind = true;
        ++iArg;
      }
      else if( args.length >= iArg + 2 ) {
        String sHost = args[iArg++];
        String sPortNo = args[iArg++];
        sURL = "rmi://" + sHost + ":" + sPortNo + "/" + getRMIServerName();
      }
      else {
	System.out.println( "Usage: " + sClassName + 
          " [-u] [<hostname> <portno>]" );
	System.out.println( "(-u to unbind from registry)" );
	System.exit( 0 );
      }
    }  // if

    if( bUnbind ) {
      Naming.unbind( sURL );
      System.out.println( getRMIServerName() + " removed from registry." );
    }
    else {
      Naming.rebind( sURL, new RemoteCBclientFactory() );
      System.out.println( "RMI server started and registered as " + 
			  getRMIServerName() );
    }
  }  // main

}  // class RemoteCBclientFactory

