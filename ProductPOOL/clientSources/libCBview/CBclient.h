/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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

#ifndef _CBCLIENT_H_
#define _CBCLIENT_H_

#include <iostream>

#include "CBviewDll.h"
#include "CBanswer.h"
#include "CBerror.h"
#include "CBinterface.h"

#define MAX_ID_LENGTH 255

/** A client class for ConceptBase
 *
 */

class LIBCBVIEW_API CBclient {

 public:

	/** Constructs an "empty" client which is not connected
	*/
	CBclient();

	/**
 	 * Constructs a new CBclient object and connect to the specified host
     */
	CBclient(char *host, int port,char *tool=(char*)NULL,char* user=(char*)NULL);

	/**
	 * Disconnects from the CBserver and deallocates the memory.
	 */
	virtual ~CBclient();


	/**
	 * Tells frames to the server
	 *
	 * @param char *frames the frames
	 * @return a CBanswer object containing the result and the completion
	 */

	CBanswer* tell(char *);

	/**
	 * Untells frames to the server
	 *
	 * @param char *frames the frames
	 * @return a CBanswer object containing the result and the completion
	 */


	CBanswer* untell(char *);

	/**
	 * Tells files containing frames to the server
	 *
	 * @param char** files an array of filenames
	 * @return a CBanswer object containing the result and the completion
	 */

	CBanswer* tellModel(char**);

	/**
	 * Sends a query to the ConceptBase server
	 *
	 * @param char *query the query
	 * @param char* format the format of the query (FRAMES or OBJNAMES)
	 * @param char* answerrep the format of the answer (FRAME)
	 * @param char* rollbacktime Rollback Time (e.g.\ "Now")
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* ask(char *query,char* format="OBJNAMES",char* answerrep="FRAME", char* rollbacktime="Now");

	/**
	 * Sends frames and a query to the ConceptBase server. The frames are told temporarely,
	 * the query is evaluated, and the temporarely objects are removed.
	 *
	 * @param char *frames frames to be told
	 * @param char *query the query
	 * @param char* format the format of the query (FRAMES or OBJNAMES)
	 * @param char* answerrep the format of the answer (FRAME)
	 * @param char* rollbacktime Rollback Time (e.g.\ "Now")
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* hypoAsk(char *frames,char *query,char* format="OBJNAMES",char* answerrep="FRAME", char* rollbacktime="Now");


	/**
	 * Sends a query to the ConceptBase server. Same as ask but with fixed query format (OBJNAMES).
	 *
	 * @param char *query the query
	 * @param char* answerrep the format of the answer (FRAME)
	 * @param char* rollbacktime Rollback Time (e.g.\ "Now")
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* askObjNames(char* query, char* answerrep="FRAME", char* rollbacktime="Now");

	/**
	 * Sends a query to the ConceptBase server. Same as ask but with fixed query format (FRAMES).
	 *
	 * @param char *query the query
	 * @param char* answerrep the format of the answer (FRAME)
	 * @param char* rollbacktime Rollback Time (e.g.\ "Now")
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* askFrames(char* query, char* answerrep="FRAME", char* rollbacktime="Now");



	/**
	 * Connects to a ConceptBase Server
	 * Return the return value of connect_CB_server (see CBinterface.h):
	 *   -1: if socket to specified can not be openend
	 *   0: ok
     *   other: a completion value (see CBinterface.h)
     *
	 * @param host hostname of the machine where the server runs
	 * @param port port number of server
	 * @param *user the name of the tool
	 * @param *tool the name of the user
	 */

	int enrollMe(char* host, int port, char *user=NULL,char *tool=NULL);

	/**
	 * Disconnects from a ConceptBase Server
	 *
	 * Return the return value of disconnect_CB_server (see CBinterface.h):
	 *   -1: error, not connected
	 *   0: ok
     *   other: a completion value (see CBinterface.h)
	 */
	int cancelMe();

	/**
	 * Stops the ConceptBase server. Note that a server may be stopped only
	 * by the user who has started it.
	 *
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* stopServer(char* password=NULL);


	/**
	 * Return a list of clients connected to the CB server.
	 * The result will be a list of Client objects as defined in libCB.
	 */
	Clients* reportClients();

	/**
	 * Gets a message from the server
	 *
	 * @param char* method the type of the message to be retrieved
	 * @return a CBanswer object containing the result and the completion
	 */
	CBanswer* nextMessage(char* method="");

	/**
	 * Gets the error messages from the server
	 *
	 * @return a string containing all error messages
	 */
	CBerror* getErrorMessages();

	/**
	 * Perform a LPI call on the server. A LPI call is a call of Prolog-predicate
	 * of the CBserver. This is mostly used for debugging.
	 */
	CBanswer* LPICall(char *);

	/**
	 * Check whether this client is connected
	 */
	inline int connected()  {
		return  (server && server->connected_to_CB_server);
	}

	/**
	 * The operator int checks also if the client is connected.
	 * @see connected
	 */
    inline operator int() {
		return  (server && server->connected_to_CB_server);
	}

	/**
	 * Return the name of the server
	 */
	char* getServerName() {
		return serverID;
	}

	/**
	 * Return the name of the client
	 */
	char* getClientName() {
		return clientID;
	}


 protected:
	char* serverID;
	char* clientID;


 private:

	char* userID;
	char* toolclass;
	char* host;
	int  port;

	// Server-Struktur zur Kommunikation mit der C-Library
	Server *server;
};

#endif
