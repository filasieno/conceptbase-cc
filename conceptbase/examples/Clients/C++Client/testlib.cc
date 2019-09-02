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

#include <iostream>

#include "CBclient.h"

using namespace std;

int main() {

	CBclient cb;
	cb.enrollMe("localhost",4001,"libcb","someuser");

	if(cb.connected()) {

		cout << "connected, client name: " << cb.getClientName() << "\n";

		CBanswer* ans=cb.tell("xxx in C end yyy in D end");

		cout << "Tell 1:" << ans->getResult() << "\n\n";

		delete ans;

		CBerror* err=cb.getErrorMessages();
		if(err) {
			cout << "ErrorMessages: " << err->getAllErrorMessages();
			delete err;
		}
		else {
			cout << "No Error Messages received!";
		}

		ans=cb.tell("Class B end Class A end b in B end");
		cout << "Tell 2:" << ans->getResult() << "\n\n";
		delete ans;

		err=cb.getErrorMessages();

		if(err) {
			cout << "ErrorMessages: \n";
			cout << err->getAllErrorMessages();
			delete err;
		}
		else {
			cout << "No Error Messages received!\n";
		}

		ans=cb.untell("Individual A in Class end");
		cout << "Untell 1:" << ans->getResult() << "\n\n";
		delete ans;

		ans=cb.ask("","OBJNAMES","FRAME","Now");
		cout << "Answer 1:\n" << ans->getResult() << "\n\n";
		delete ans;

		ans=cb.ask("QueryClass Test1 isA B end","FRAMES","FRAME","Now");
		cout << "Answer 2:\n" << ans->getResult() << "\n\n";
		delete ans;

		ans=cb.askFrames("QueryClass Test2 isA B end","FRAME","Now");
		cout << "Answer 3:\n" << ans->getResult() << "\n\n";
		delete ans;

		ans=cb.hypoAsk("A end a in A end","QueryClass Test3 isA A end","FRAMES","FRAME","Now");
		cout << "Answer 4:\n" << ans->getResult() << "\n\n";
		delete ans;

		printf("Report clients (only two clients will be listed):\n\n");
		Clients* c=cb.reportClients();
		printf("First client: %s\n",c->client);
		printf("Second client: %s\n",c->next->client);
		freeClients(c); // Clients is a C-struct

		short res=cb.cancelMe();
		if(res==CB_OK) {
			cout << "disconnected!\n";
		}
		else {
			cout << "Error in disconnect!!\n";
		}
	}
	else {
		cout << "Unable to connect!!\n";
	}


	return 0;
}

