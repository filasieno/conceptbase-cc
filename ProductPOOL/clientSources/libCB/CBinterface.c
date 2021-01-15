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

#include <stdlib.h>
#include <string.h>


#include "CBdebug.h"
#include "CBipc.h"
#include "CBinterface.h"
#include "CButils.h"
#include "CBterm.h"

/*********************************/
/*   Functions                   */
/*********************************/

LIBCB_API Answer* STDCALL send_message(Server* server,
					char* method,
					char* data) {

	unsigned int l,len;
	char* msg;
	char* lenstr;
	char* ans;
	cbterm* ansterm;
	Answer* a;
	unsigned char lenbuf[5];

	a=(Answer*) malloc(sizeof(Answer));
	a->sender=NULL;
	a->completion=CB_OTHER_ERROR;
	a->return_data=NULL;

	msg=(char*) malloc(strlen(method)+
					   strlen(data)+
					   strlen(server->serverName)+
					   strlen(server->client)+100);

	sprintf(msg,"ipcmessage(%s,%s,%s,[%s]).\n",server->client,server->serverName,method,data);

	CBdebug1(10,"send_message: %s\n",msg);

    len=strlen(msg);
    lenbuf[0]='X';
    lenbuf[1]=(len / (256 * 256 * 256)) % 256;
    lenbuf[2]=(len / (256 * 256)) % 256;
    lenbuf[3]=(len / 256) % 256;
    lenbuf[4]=len % 256;
    l=write_socket(server->socket,lenbuf,5);
	if (l<5) {
		CBdebug(5,"send_message: Unable to write message\n");
		return a;
	}

	l=write_socket(server->socket,msg,len);
	if (l<len) {
		CBdebug(5,"send_message: Unable to write message\n");
		return a;
	}
	free(msg);

	/* Read length of answer */
	lenstr=read_string_until_char_or_timeout(server->socket,'\n',TIMEOUT_TIME);

	if(lenstr) {
		len=atoi(lenstr);
		free(lenstr);
		ans=(char*) malloc(len+2);
		if(read_socket_with_timeout(server->socket,ans,len+1,TIMEOUT_TIME)) {
			CBdebug1(10,"received message:%s\n",ans);
			ansterm=parse_term(ans);
			if (!ansterm || ansterm->error) {
				CBdebug(5,"send_message: Answer unparseable\n");
				a->completion=CB_CONN_BROKEN;
				return a;
			}
			free(ans);

			a->sender=strdup(get_arg(ansterm,1)->pFunctor);
			CBdebug1(10,"sender:%s\n",a->sender);

			if(!strcmp("ok",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_OK;
			if(!strcmp("error",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_ERROR;
			if(!strcmp("not_handled",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_NOT_HANDLED;
			if(!strcmp("notification",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_NOTIFICATION;

			a->return_data=CBdecodeString(get_arg(ansterm,3)->pFunctor);
			CBdebug1(10,"data:%s\n",a->return_data);
			delete_term(ansterm);
			CBdebug1(10,"return of send_message: %d\n",a);
			return a;
		}
		else {
			a->completion=CB_TIMEOUT;
			return a;
		}
	}
	else {
		a->completion=CB_TIMEOUT;
		return a;
	}

}



LIBCB_API int STDCALL connect_CB_server(int portnr,
                      char* hostname,
					  char* clientname,
					  char* username,
					  Server** server) {

	SOCKET s;
	char* msg;
	char* encuser;
	char* encclient;
	Answer* ans;
	int compl;

	s=open_socket(hostname,portnr);
	if (!s) {
		CBdebug(5,"connect_CB_server: open_socket failed!\n");
		return (-1);
	}

	/* Initialize Server structure */
	(*server)=(Server*) malloc(sizeof(Server));
	if(!(*server)) {
		CBdebug(5,"connect_CB_server: Out of memory!\n");
		return 99;
	}

	(*server)->serverName=strdup("\"\"");
	(*server)->client=strdup("\"\"");
	(*server)->socket=s;

	/* Connection is established, now enroll to CBserver */
	encuser=CBencodeString(username);
	encclient=CBencodeString(clientname);

	msg=(char*) malloc(strlen(encclient)+strlen(encuser)+10);

	sprintf(msg,"%s,%s",encclient,encuser);

	free(encuser);
	free(encclient);

	CBdebug1(10,"connect_CB_server: Enrolling to CBserver: %s\n",msg);

	ans=send_message((*server),"ENROLL_ME",msg);

	free(msg);

	switch (ans->completion) {
	 case CB_OK:
		free((*server)->serverName);
		free((*server)->client);

		(*server)->serverName=strdup(ans->sender);
		/* Client string is encoded here, so we don't have to this later every time */
		(*server)->client=CBencodeString(ans->return_data);
		(*server)->connected_to_CB_server=1;
		(*server)->socket=s;

	 default:
	    compl=ans->completion;
	    freeAnswer(ans);
		return compl;
	}
}


LIBCB_API int STDCALL disconnect_CB_server(Server* server)  {

	Answer* ans;

	if(server && server->connected_to_CB_server) {

		ans=send_message(server,"CANCEL_ME","");

		switch (ans->completion) {
		 case CB_OK:
			free(server->serverName);
			free(server->client);
			server->serverName=NULL;
			server->client=NULL;
			server->connected_to_CB_server=0;
			close_socket(server->socket);
		 default:
			return ans->completion;
		}
	}

	CBdebug(5,"disconnect_CB_server: Error!\n");
	return (-1);

}



LIBCB_API Answer* STDCALL tellCB(Server* server,
				char* objects) {

	char* encobj;
	Answer* ans;

	if (server && server->connected_to_CB_server) {
		encobj=CBencodeString(objects);

		ans=send_message(server,"TELL",encobj);

		free(encobj);
		return ans;
	}

	return NULL;
}


LIBCB_API Answer* STDCALL tell_model(Server* server,
					  char** models) {

	int len,i;
	char* encmod;
	char* encfiles;
	Answer* ans;

	if (server && server->connected_to_CB_server) {
		len=0;
		i=0;
		while(models[i]) {
			len+=strlen(models[i]);
			i++;
		}

		encfiles=(char*) malloc(len+i*10+200);
		encfiles[0]=0;

		i=0;
		while(models[i]) {
			encmod=CBencodeString(models[i]);
			strcat(encfiles,encmod);
			if(models[i+1])
				strcat(encfiles,",");
			i++;
			free(encmod);
		}

		ans=send_message(server,"TELL_MODEL",encfiles);
		free (encfiles);
		return ans;
	}

	return NULL;
}






LIBCB_API Answer* STDCALL untell(Server* server,
				char* objects) {

	char* encobj;
	Answer* ans;

	if (server && server->connected_to_CB_server) {
		encobj=CBencodeString(objects);

		ans=send_message(server,"UNTELL",encobj);

		free(encobj);
		return ans;
	}

	return NULL;
}


LIBCB_API Answer* STDCALL ask(Server* server,
		  char* szQuery,
		  char* szAskFormat,
		  char* szAnsFormat,
		  char* szRBTime) {


	char* msg;
	char* encquery;
	char* encRBTime;
	char* encanswerrep;
	Answer* ans;

	if (server && server->connected_to_CB_server) {
		encquery=CBencodeString(szQuery);
		encRBTime=CBencodeString(szRBTime);
		encanswerrep=CBencodeString(szAnsFormat);
		msg=(char*) malloc(strlen(encanswerrep)+
						   strlen(encRBTime)+
						   strlen(encquery)+
						   strlen(szAskFormat)+10);

		if (msg) {
			sprintf(msg,"%s,%s,%s,%s",szAskFormat,encquery,encanswerrep,encRBTime);

			free(encquery);
			free(encanswerrep);
			free(encRBTime);

			CBdebug1(10,"Asking message: %s",msg);
			ans=send_message(server,"ASK",msg);

			free(msg);

		return ans;
		}
	}

	CBdebug(5,"ask: Unknown error!\n");
	return NULL;
}


LIBCB_API Answer* STDCALL ask_frames(Server* pServer,
				 char* szQuery,
		         char* szFormat,
				 char* szRBTime) {

	return ask(pServer,szQuery,"FRAMES",szFormat,szRBTime);
}


LIBCB_API Answer* STDCALL ask_objnames(Server* pServer,
				   char* szQuery,
				   char* szFormat,
				   char* szRBTime)  {

	return ask(pServer,szQuery,"OBJNAMES",szFormat,szRBTime);
}



LIBCB_API Answer* STDCALL hypo_ask(Server* server,
		  char* szFrames,
		  char* szQuery,
		  char* szAskFormat,
		  char* szAnsFormat,
		  char* szRBTime) {


	char* msg;
	char* encframes;
	char* encquery;
	char* encRBTime;
	char* encanswerrep;
    Answer* ans;

	if (server && server->connected_to_CB_server) {
		encframes=CBencodeString(szFrames);
		encquery=CBencodeString(szQuery);
		encRBTime=CBencodeString(szRBTime);
		encanswerrep=CBencodeString(szAnsFormat);

		msg=(char*) malloc(strlen(encframes)+
						   strlen(encanswerrep)+
						   strlen(encRBTime)+
						   strlen(encquery)+
						   strlen(szAskFormat)+10);

		if (msg) {
			sprintf(msg,"%s,%s,%s,%s,%s",encframes,szAskFormat,encquery,encanswerrep,encRBTime);

			free(encframes);
			free(encquery);
			free(encanswerrep);
			free(encRBTime);

			ans=send_message(server,"HYPO_ASK",msg);

		return ans;

		}
	}

	CBdebug(5,"hypo_ask: Unknown error!\n");
	return NULL;
}




LIBCB_API Error_Messages* STDCALL get_errormessages(Server* server)  {

	Answer* a;
	Error_Messages* first;
	Error_Messages* last;
	Error_Messages* curr;
	cbterm* t;

	first=NULL;
	last=NULL;
	curr=NULL;
	a=get_servermessage(server,"ERROR_REPORT");

	while (a && a->return_data && strcmp(a->return_data,EMPTY_QUEUE)) {
		curr=(Error_Messages*) malloc(sizeof(Error_Messages));

		t=parse_term(a->return_data);
		t=get_arg(t,4);
		if(is_list(t)) {
			t=get_arg(t,1);
		}
		/* it should be ok now to get the string representation of the term */
		curr->errormessage=CBdecodeString(t->string);

		delete_term(t);

		if (last)
			last->next=curr;

		if (!first)
			first=curr;

		curr->next=NULL;

		last=curr;
		freeAnswer(a);
		a=get_servermessage(server,"ERROR_REPORT");
	}

	return first;
}



LIBCB_API Clients* STDCALL report_clients(Server* server) {

	Answer* a;
	Clients* first;
	Clients* curr;
	Clients* last;
	cbterm* t;
	cbterm* told;

	first=NULL;
	curr=NULL;
	last=NULL;
	a=send_message(server,"REPORT_CLIENTS","");

	if (a && a->completion==CB_OK) {
		CBdebug1(5,"REPORT_CLIENTS returns: %s\n",a->return_data);
		t=parse_term(a->return_data);
		CBdebug(5,"REPORT_CLIENTS: result parsed");
		told=t;
		if(is_list(t)) {
			t=get_arg(t,1);
			while(t && get_arg(t,3)) {
				curr=(Clients*) malloc(sizeof(Clients));
				curr->client=strdup(get_arg(t,1)->pFunctor);
				curr->toolclass=strdup(get_arg(t,2)->pFunctor);
				curr->username=strdup(get_arg(t,3)->pFunctor);
				curr->next=NULL;

				if (last)
					last->next=curr;

				if (!first)
					first=curr;
				last=curr;
				t=t->pNext;
			}
		}
		delete_term(told);
	}
	freeAnswer(a);

	return first;

}

LIBCB_API Answer* STDCALL get_servermessage(Server* server, char* type)  {

	return send_message(server,"NEXT_MESSAGE",type);

}

LIBCB_API Answer* STDCALL notificationRequest(Server* server, char* data) {

	return send_message(server,"NOTIFICATION_REQUEST",data);
}


LIBCB_API Answer* STDCALL get_notification(Server* server, int timeout)  {

	char* lenstr;
	int len;
	char* ans;
	cbterm* ansterm;
	Answer* a;


	a=(Answer*) malloc(sizeof(Answer));
	a->sender=NULL;
	a->completion=CB_OTHER_ERROR;
	a->return_data=NULL;

	/* Read length of answer */
	lenstr=read_string_until_char_or_timeout(server->socket,'\n',timeout);

	if(lenstr) {
		len=atoi(lenstr);
		free(lenstr);
		ans=(char*) malloc(len+2);
		if(read_socket_with_timeout(server->socket,ans,len+1,TIMEOUT_TIME)) {
			ansterm=parse_term(ans);
			if (!ansterm || ansterm->error) {
				CBdebug(5,"get_notification: Answer unparseable\n");
				a->completion=CB_CONN_BROKEN;
				return a;
			}
			free(ans);

			a->sender=strdup(get_arg(ansterm,1)->pFunctor);

			if(!strcmp("ok",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_OK;
			if(!strcmp("error",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_ERROR;
			if(!strcmp("not_handled",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_NOT_HANDLED;
			if(!strcmp("notification",get_arg(ansterm,2)->pFunctor))
				a->completion=CB_NOTIFICATION;

			a->return_data=CBdecodeString(get_arg(ansterm,3)->pFunctor);
			delete_term(ansterm);
			return a;
		}
		else {
			a->completion=CB_TIMEOUT;
			return a;
		}
	}
	else {
		a->completion=CB_TIMEOUT;
		return a;
	}

}


LIBCB_API Answer* STDCALL stopServer(Server* server, char* password)  {

	Answer* ans;

	ans=send_message(server,"STOP_SERVER",password);

	switch (ans->completion) {
	 case CB_OK:
		free(server->serverName);
		free(server->client);
		server->serverName=NULL;
		server->client=NULL;
		server->connected_to_CB_server=0;
		close_socket(server->socket);
	 default:
		return ans;
	}
}


LIBCB_API Answer* STDCALL LPICall(Server* server, char* lpicall) {

	return send_message(server,"LPI_CALL",lpicall);
}


/** Frees the memory allocated by the answer structure
 * @param ans the pointer to the answer structure
 * */
LIBCB_API void STDCALL freeAnswer(Answer* ans) {
	if(ans) {
		if(ans->return_data)
			free(ans->return_data);
		if(ans->sender)
			free(ans->sender);
	}
}

/** Frees the memory allocated by the server structure
 * @param srv the pointer to the server structure
 * */
LIBCB_API void STDCALL freeServer(Server* srv) {
	if(srv) {
		if(srv->client)
			free(srv->client);
		if(srv->serverName)
			free(srv->serverName);
	}
}



/** Frees the memory allocated by the Clients structure
 * @param c the pointer to the Clients structure
 * */
LIBCB_API void STDCALL freeClients(Clients* c) {
	Clients* next;
	next=c;
	while(next) {
		c=next;
		next=c->next;
		if(c->client)
			free(c->client);
		if(c->toolclass)
			free(c->toolclass);
		if(c->username)
			free(c->username);
		free(c);
	}
}

/** Frees the memory allocated by the Error_Messages structure
 * @param err the pointer to the Error_Messages structure
 * */
LIBCB_API void STDCALL freeErrorMessages(Error_Messages* err) {
	Error_Messages* next;
	next=err;
	while(next) {
		err=next;
		next=err->next;
		if(err->errormessage)
			free(err->errormessage);
		free(err);
	}
}



