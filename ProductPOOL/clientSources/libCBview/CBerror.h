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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/

#ifndef _CBERROR_H_
#define _CBERROR_H_

#include <iostream>

#include "CBviewDll.h"
#include "CBinterface.h"

/**
 * C++ Wrapper of Error_Messages struct in libCB.
 * This class represents a list of error messages.
 */

class LIBCBVIEW_API CBerror  {

 public:
 	/** Construct a CBerror object from a list of Error_Messages
 	 * @param e pointer to the Error_Messages
   	 */
	CBerror(Error_Messages* e);


	/**
	 * Deallocate the memory of a CBerror object
	 */
	~CBerror();

    /**
     * Get the error message of this object. This will return only
     * the first error message of the list.
     */
	char* getErrorMessage() {
		return error_msg;
	}

	/**
	 * This method will return all error messages of the list. The method
	 * will allocate a new string, thus the resulting string has to be freed
	 * by the calller.
	 */
	char* getAllErrorMessages();

	/**
	 * Get the next error message in the list.
	 */
	CBerror* getNextError()  {
		return nextError;
	}

 protected:
	char* error_msg;
	CBerror* nextError;

};


#endif
