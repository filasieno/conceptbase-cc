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
#include <stdlib.h>
#include <string.h>

#include "CBclient.h"
#include "CButils.h"

/* CBclient::CBclient()
 * ++++++++++++++++++++
 * alles auf NULL setzen !!!
 */

CBclient::CBclient()  {

	this->server=NULL;
	this->port=0;
	this->host=NULL;
	this->userID=NULL;
	this->toolclass=NULL;
	this->serverID=NULL;
	this->clientID=NULL;
}


/* CBclient::CBclient(char* host,int port,char* user,char *tool)
 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * Initialisierung und enrollMe
 */

CBclient::CBclient(char *host,
				   int port,
				   char* tool,
				   char* user) {

	// Init variables
	this->server=NULL;
	this->userID=NULL;
	this->toolclass=NULL;
	this->serverID=NULL;
	this->clientID=NULL;
	this->port = port;
	this->host = new char[strlen(host)+1];
	strcpy (this->host, host);

	int res=enrollMe(host,port,tool,user);

	if(res!=CB_OK) {
		// Destroy the strings already allocated in enrollMe
		if (toolclass)
			delete[] toolclass;
		if (userID)
			delete[] userID;
		if (clientID)
			delete[] clientID;
		if (serverID)
			delete[] serverID;
	}
}



/* Destructor:
 * ===========
 * CBclient::~CBclient()
 * +++++++++++++++++++++
 * free shared-reserved memory
 */

CBclient::~CBclient() {

	if (connected())
		cancelMe();

	if (server)
		freeServer(server);

	if (toolclass)
		delete[] toolclass;
	if (userID)
		delete[] userID;
	if (clientID)
		delete[] clientID;
	if (serverID)
		delete[] serverID;

	if(host)
		delete[] host;

}


/* The General - Methods */

/* CBclient::tell(char* frames)
 * ++++++++++++++++++++++++++++
 * tell call wird an die C-library durchgereicht
 * unter Benutzung der server Struktur
 */

CBanswer* CBclient::tell(char* frames) {
  if (connected())
    return new CBanswer(::tellCB(server,frames));
  else
    return NULL;
}

/* CBclient::untell(char *frames)
 * ++++++++++++++++++++++++++++++
 * Untell Funktion wird an die C-library durchgereicht
 * unter Benutzung der server Struktur
 */

CBanswer* CBclient::untell(char* frames) {
  if (connected())
    return new CBanswer(::untell(server,
				 frames));
  else
    return NULL;
}


/* CBclient::tellModel(char** files, int num)
 * ++++++++++++++++++++++++++++++++++++++++++
 * tellModel - call an C-library durchreichen
 * unter Benutzung der server Struktur
 */

CBanswer* CBclient::tellModel(char** files) {
	if (connected())
    	return new CBanswer(::tell_model(server,files));
	else
    	return NULL;
}


/* CBclient::ask(char* query,
 *               char* format,
 *               char* answerrep,
 *               char* rollbacktime)
 * ++++++++++++++++++++++++++++++++++
 * ask - call an C - library durchreichen
 * unter Benutzung der server Struktur
 */

CBanswer* CBclient::ask(char* query,
			char* format,
			char* answerrep,
			char* rollbacktime) {

  if (connected())
    return new CBanswer(::ask(server,
			      query,
			      format,
			      answerrep,
			      rollbacktime));

  else
    return NULL;
}

/* CBanswer::hypoAsk(char* frames,
					 char* query,
 *                   char* format,
 *                   char* answerrep,
 *                   char* rollbacktime)
 * +++++++++++++++++++++++++++++++++++++
 * hypoAsk call an die C - library durchreichen
 * unter Benutzung der server Struktur
 */

CBanswer* CBclient::hypoAsk(char* frames,
				  char* query,
		  char* format,
		  char* answerrep,
		  char* rollbacktime) {
  if (connected())
    return new CBanswer(::hypo_ask(server,
				  frames,
				  query,
				  format,
				  answerrep,
				  rollbacktime));
  else
    return NULL;
}


/* CBanswer* CBclient::askObjNames(char* query,
 *                                 char* answerrep,
 *                                 char* rollbacktime)
 * +++++++++++++++++++++++++++++++++
 */

CBanswer* CBclient::askObjNames(char* query,
				char* answerrep,
				char* rollbacktime) {
  if (connected())
    return new CBanswer(::ask_objnames(server,
				      query,
				      answerrep,
				      rollbacktime));
  else
    return NULL;

}

/* CBanswer* CBclient::askFrames(char* query,
 *                               char* answerrep,
 *                               char* rollbacktime)
 * +++++++++++++++++++++++++++++++
 * Noch nicht komplett implementiert
 * RICHTIGE PARAMETER ???? --> ProgMan nachschauen !!!!!
 */

CBanswer* CBclient::askFrames(char* query,
			      char* answerrep,
			      char* rollbacktime) {
  if (connected())
    return new CBanswer(::ask_frames(server,
				    query,
				    answerrep,
				    rollbacktime));
  else
    return NULL;
}


// enrollMe -> ::connect_CB_server
// ********************************************
// CBanswer* CBclient::enrollMe(char *user,
//									  char *tool)
// ********************************************
int CBclient::enrollMe(char* host,
							 int port,
							 char *tool,
							 char *user)  {


	char *luser=new char[MAX_ID_LENGTH];
	char *ltool=new char[MAX_ID_LENGTH];

	// Cancel an existing connection
	if (connected())
		cancelMe();

	if (user)
		strcpy(luser,user);
	else {
		char *u=getenv("USER");
		char *h=getenv("HOST");

		if (u) {
			strcpy(luser,u);
			if(h)  {
				strcat(luser,"@");
				strcat(luser,h);
			}
		}
		else
			strcpy(luser,"unknown");
	}

	if (tool)
		strcpy(ltool,tool);
	else {
		strcpy(ltool,"C++Client");
	}

	// connect to server with c-lib
	int result = connect_CB_server (port, host, ltool, luser, &server);

	toolclass=new char[strlen(ltool)+1];
	userID=new char[strlen(luser)+1];

	strcpy(toolclass,ltool);
	strcpy(userID,luser);

	if(result==0) {
		serverID=::CBdecodeString(server->serverName);
		clientID=::CBdecodeString(server->client);
	}


	delete[] ltool;
	delete[] luser;

	return result;

}


/* CBanswer* CBclient::cancelMe()
 * ++++++++++++++++++++++++++++++
 * disconnect from CB-Server using C-library call
 */

int CBclient::cancelMe() {

	return ::disconnect_CB_server(server);

}


/* PRIVILEGED METHODS */
/* ++++++++++++++++++ */


/* CBanswer* CBclient::stopServer()
 * ++++++++++++++++++++++++++++++++
 * Stop CB-Server using C-library call
 */


CBanswer* CBclient::stopServer(char* password) {
	/*
	 stopServer an die C-library durchreichen....
	 */
	char cEmptystring[]= "";
	if (!password)
		password=cEmptystring;

	Answer* ans = ::stopServer(server, password);
	if (ans->completion == CB_OK) {
		server = NULL;  // disconnected
	}

	return new CBanswer(ans);
}



/* CBanswer* CBclient::reportClients()
 * +++++++++++++++++++++++++++++++++++
 * reportClients call an c - library durchreichen
 * unter benutzung der server Struktur
 */



Clients* CBclient::reportClients() {
	/*
	 reportClients an die C-library durchreichen....
	 */
	if (connected())  {
		return ::report_clients(server);
	}
	return NULL;
}


/* CBanswer* CBclient::nextMessage(char* method)
 * +++++++++++++++++++++++++++++++++++++++++++++
 */


CBanswer* CBclient::nextMessage(char* method) {

	return new CBanswer(::get_servermessage(server,method));

}


/* CBerror* CBclient::getErrorMessages()
 * ++++++++++++++++++++++++++++++++++++++
 * get error Message sent by CB-Server
 * using C - library
 */


CBerror* CBclient::getErrorMessages()  {

	Error_Messages* err=get_errormessages(server);
	if(err)
		return new CBerror(err);
	return NULL;

}


/* INTERNAL METHODS */
/* ++++++++++++++++ */

/* CBanswer* CBclient::LPICall(char* lpicall)
 * ++++++++++++++++++++++++++++++++++++++++++
 * send commands dircetly to CB-Server
 */

CBanswer* CBclient::LPICall(char* lpicall) {

  if (connected())
    return new CBanswer(::LPICall(server, lpicall));
  else
    return NULL;
}
