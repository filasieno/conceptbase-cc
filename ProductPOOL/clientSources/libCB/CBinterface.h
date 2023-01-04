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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

#ifndef _CBINTERFACE_H_
#define _CBINTERFACE_H_

#include <stdio.h>

#include "CBipc.h"

#include "CBdll.h"

#ifdef  __cplusplus
extern "C" {
#endif

/*********************************/
/*   Constants                   */
/*********************************/

/** Indicates no more messages, when using get\_servermessage
 * @see get_servermessage
 * */
#define EMPTY_QUEUE   "empty_queue"

/** Timeout time in seconds for all methods.*/
#define TIMEOUT_TIME 240

/*********************************/
/*   Data types                  */
/*********************************/


/** Enumeration for completion.
 * @see answer */
typedef enum {
	/** No errors */
	CB_OK=0,
	/** An error occured */
	CB_ERROR,
	/** Notification message */
	CB_NOTIFICATION,
	/** Answer was not handled by the server (probably communication error) */
	CB_NOT_HANDLED,
	/** Timeout occured */
	CB_TIMEOUT,
	/** Connection broken (server crashed or network problem) */
	CB_CONN_BROKEN,
	/** Other error */
	CB_OTHER_ERROR
} Completion;

/** The type definition for compl.
 * @see compl */
/* typedef enum compl Completion; */


/** Structure for the answer returned by the ConceptBase Server. */
struct answer {
	/** String for the ID of the sender (usually ConceptBase Server)*/
	char* sender;

	/** the completion value of the answer*/
	Completion completion;

	/** the result returned by the server*/
	char* return_data;
};

/** The type definition for answer.
 * @see answer */
typedef struct answer Answer;

/** Structure for the server. */
struct server {
	/** String for the ID of the server */
	char* serverName;

	/** String for the ID of the client */
	char* client;

	/** Non-Zero when connected to server */
	int connected_to_CB_server;

	/** File descriptor of the socket */
	SOCKET socket;
};

/** The type definition for the server.
 * @see server */
typedef struct server Server;

/** Structure for a list of clients.
 * @see report_clients */
struct clients {
	/** The ID of the client */
	char* client;

	/** The tool class of the client */
	char* toolclass;

	/** The name of the user using the client */
	char* username;

	/** Pointer to the next client (NULL when there is no more client) */
	struct clients* next;
};

/** The type definition for the clients.
 * @see clients */
typedef struct clients Clients;

/** Structure for a list of error messages.
 * @see get_errormessages */
struct errormessages {
	char* errormessage;
	struct errormessages* next;
};

/** Type definition for errormessages.
 * @see errormessages */
typedef struct errormessages Error_Messages;


/*********************************/
/*   Functions                   */
/*********************************/

/** Connects to a ConceptBase server.
 * @param portnr the port number
 * @param hostname the hostname
 * @param clientname a client name (may be anything)
 * @param username the name of the user
 * @param server a pointer to a pointer to a server structure
 * @return \begin{description}
 *   \item[-1] if socket to specified can not be openend
 *   \item[0] ok
 *   \item[other] a Completion value
 * \end{description}
 * */
LIBCB_API int STDCALL connect_CB_server(int portnr,
                      char* hostname,
					  char* clientname,
					  char* username,
					  Server** server);

/** Disconnects from a ConceptBase Server
 * @param server a pointer to a server structure
 * @return \begin{description}
 *   \item[-1] error, not connected
 *   \item[0] ok
 *   \item[other] a Completion value
 * \end{description}
 * */
LIBCB_API int STDCALL disconnect_CB_server(Server* server);

/** Tells the given objects to the server
 * @param server a pointer to a server structure
 * @param objects a string containing Telos frames
 * @return pointer to Answer object or NULL if the client is not connected to a server
 * */
LIBCB_API Answer* STDCALL tellCB(Server* server,
				char* objects);

/** Tells the given files to the server
 * @param server a pointer to a server structure
 * @param models an array of filenames
 * @return the completion
 * */
LIBCB_API Answer* STDCALL tell_model(Server* server,
					  char** models);

/** Deletes the given objects from the server
 * @param server a pointer to a server structure
 * @param objects a string containing Telos frames
 * @return the completion
 * */
LIBCB_API Answer* STDCALL untell(Server* server,
				  char* objects);

/** Sends the query to the server
 * @param pServer a pointer to a server structure
 * @param szQuery the query
 * @param szAskFormat the format of the query (FRAMES or OBJNAMES)
 * @param szAnsFormat the format of the answer (e.g. FRAME, LABEL,...)
 * @param szRBTime rollback time (e.g. Now)
 * @return the answer (return_data may be "nil")
 * @see ask_frames
 * @see ask_objnames
 * */
LIBCB_API Answer* STDCALL ask(Server* pServer,
		  char* szQuery,
		  char* szAskFormat,
		  char* szAnsFormat,
		  char* szRBTime);

/** Sends a query in FRAMES format to the server (e.g. "QueryClass Bla isA ...")
 * @param pServer a pointer to a server structure
 * @param szQuery the query
 * @param szAnsFormat the format of the answer (e.g. FRAME, LABEL,...)
 * @param szRBTime rollback time (e.g. Now)
 * @return the answer (return_data may be "nil")
 * @see ask
 * */
LIBCB_API Answer* STDCALL ask_frames(Server* pServer,
				 char* szQuery,
		         char* szFormat,
				 char* szRBTime);

/** Sends a query in OBJNAMES format to the server (e.g. "get\_object[Class/objname]")
 * @param pServer a pointer to a server structure
 * @param szQuery the query
 * @param szAnsFormat the format of the answer (e.g. FRAME, LABEL,...)
 * @param szRBTime rollback time (e.g. Now)
 * @return the answer (return_data may be "nil")
 * @see ask
 * */
LIBCB_API Answer* STDCALL ask_objnames(Server* pServer,
				   char* szQuery,
				   char* szFormat,
				   char* szRBTime);


/** Tells the frames to the server, performs the query and then deletes the told frames from the object base
 * @param pServer a pointer to a server structure
 * @param szFrames the Telos frames
 * @param szQuery the query
 * @param szAskFormat the format of the query (FRAMES or OBJNAMES)
 * @param szAnsFormat the format of the answer (e.g. FRAME, LABEL,...)
 * @param szRBTime rollback time (e.g. Now)
 * @return the answer (return_data may be "nil")
 * @see ask
 * @see tell
 * */
LIBCB_API Answer* STDCALL hypo_ask(Server* pServer,
		  char* szFrames,
		  char* szQuery,
		  char* szAskFormat,
		  char* szAnsFormat,
		  char* szRBTime);

/** Returns the error messages from the server. To be called
 * after a method returned an error.
 * @param server a pointer to a server structure
 * @return a list of error messages
 * */
LIBCB_API Error_Messages* STDCALL get_errormessages(Server* server);

/** Returns a list of clients currently connected to the server
 * @param server a pointer to a server structure
 * @return a list of clients
 * */
LIBCB_API Clients* STDCALL report_clients(Server* server);

/** Gets a message from the server for the client. This function
 * is called by get\_errormessages().
 * @param server a pointer to a server structure
 * @param type type of the message to be retrieved (e.g. ERROR_REPORT)
 * @return an answer object with the message in the result or EMPTY_QUEUE
 * @see EMPTY_QUEUE
 * */
LIBCB_API Answer* STDCALL get_servermessage(Server* server, char* type);

/** Looks for a notification message.
 * @param server a pointer to a server structure
 * @param timeout time to wait for a message
* @return an answer object with completion CB_NOTIFICATION when message was received, otherwise a completion value
 * */
LIBCB_API Answer* STDCALL get_notification(Server* server, int timeout);

/** Stops the server.
 * @param server a pointer to a server structure
 * @param password a password (may be empty)
 * @return the result of the method
 * */
LIBCB_API Answer* STDCALL stopServer(Server* server, char* password);

/** Performs a LPI-Call at the server. With LPI (Logic Programming Interface)
 * one can call ProLog predicates defined in an LPI-Module.
 * @param server a pointer to a server structure
 * @param lpicall the predicate to be called
 * @return the result of the method
 * */
LIBCB_API Answer* STDCALL LPICall(Server* server, char* lpicall);

/** Frees the memory allocated by the answer structure
 * @param ans the pointer to the answer structure
 * */
LIBCB_API void STDCALL freeAnswer(Answer* ans);

/** Frees the memory allocated by the server structure
 * @param srv the pointer to the server structure
 * */
LIBCB_API void STDCALL freeServer(Server* srv);

/** Frees the memory allocated by the Clients structure
 * @param c the pointer to the Clients structure
 * */
LIBCB_API void STDCALL freeClients(Clients* c);

/** Frees the memory allocated by the Error_Messages structure
 * @param err the pointer to the Error_Messages structure
 * */
LIBCB_API void STDCALL freeErrorMessages(Error_Messages* err);


/** Sends a message to the server. This function is used by all other
 * functions to communicate with the server.
 * @param server a pointer to a server structure
 * @param method the method
 * @param data the data for the method
 * @return the answer to the message
 * */
LIBCB_API Answer* STDCALL send_message(Server* server,
					char* method,
					char* data);

#ifdef  __cplusplus
}
#endif

#endif
