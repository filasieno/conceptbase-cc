/*
The ConceptBase.cc Copyright

Copyright 1987-2015 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/


#include "CBinterface.h"


int main() {

	Server* s;
	Answer* a;
	Clients* c;
	Error_Messages *err,*first;

	if(!connect_CB_server(4001,"localhost","libcb","someuser",&s)) {

		printf("connected, client name: %s\n",s->client);

		a=tellCB(s,"xxx in C end yyy in D end");
		printf("Tell 1:%s\n\n",a->return_data);
		freeAnswer(a);
		err=get_errormessages(s);
		if(!err) {
			printf("No error messages!?\n");
		}
		else {
			first=err;
			while(err) {
				printf("ErrorMessage: %s\n\n",err->errormessage);
				err=err->next;
			}
			freeErrorMessages(first);
		}



		a=tellCB(s,"Class B end Class A end b in B end");
		printf("Tell 2:%s\n\n",a->return_data);
		freeAnswer(a);

		err=get_errormessages(s);
		if(!err) {
			printf("No error messages!\n");
		}
		else {
			first=err;
			while(err) {
				printf("ErrorMessage: %s\n\n",err->errormessage);
				err=err->next;
			}
			freeErrorMessages(first);
		}


		a=untell(s,"Individual A in Class end");
		printf("Untell 1:%s\n\n",a->return_data);
		freeAnswer(a);

		a=ask(s,"","OBJNAMES","FRAME","Now");
		printf("Answer 1:\n%s\n\n",a->return_data);
		freeAnswer(a);

		a=ask(s,"QueryClass Test1 isA B end","FRAMES","FRAME","Now");
		printf("Answer 2:\n%s\n\n",a->return_data);
		freeAnswer(a);

		a=ask_frames(s,"QueryClass Test2 isA B end","FRAME","Now");
		printf("Answer 3:\n%s\n\n",a->return_data);
		freeAnswer(a);

		a=hypo_ask(s,"A end a in A end","QueryClass Test3 isA A end","FRAMES","FRAME","Now");
		printf("Answer 4:\n%s\n\n",a->return_data);
		freeAnswer(a);

		printf("Report clients (only two clients will be listed):\n\n");
		c=report_clients(s);
		printf("First client: %s\n",c->client);
		printf("Second client: %s\n",c->next->client);
		freeClients(c);

		if(!disconnect_CB_server(s)) {
			printf("disconnected!\n");
		}
		else {
			printf("Error in disconnect!!\n");
		}

		freeServer(s);
	}
	else {
		printf("Unable to connect!!\n");
	}


	return 0;
}

