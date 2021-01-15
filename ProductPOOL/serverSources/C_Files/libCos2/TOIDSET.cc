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
/**********************************************************************
*
*   TOIDSET.cc
*
*   Creation:      7.7.1993
*   Created by:    Thomas List
*   last Change:   14.7.1993
*   Changed by:    Thomas List
*   Version 1.0
*
*
**********************************************************************/

#include "TOIDSET.h"
#include "SYMID.h"
#include <stdio.h>




void TOIDSET::test() {
/*
*  shows the set on the screen with every 
*  toid shown as (ID,Source,Label,Destination)
*/
  long src,dst;
  Pix i = first();
  char *s;
  SYMID symid;
  TOID toid,empty;
  printf("[ ");
  while (i) {
    toid = (*this)(i);
    symid = toid.Lab();
    s = new char[symid.get_length()];
    symid.get_name(s);
    src = dst = -1;
    if (!(toid.Src() == empty)) src = toid.Src().GetId(); 
    if (!(toid.Dst() == empty)) dst = toid.Dst().GetId(); 
    printf("(%ld,%ld,%s,%ld) ",toid.GetId(),src,s,dst);
    delete s;
    next(i);
  }
  printf("]; \n");
}

void TOIDSET::test2() {
/*
*  shows the set on the screen with every 
*  toid shown as (ID,Source,Label,Destination)
*/
  long src,dst;
  Pix i = first();
  char *s;
  SYMID symid;
  TOID toid;
  printf("[ ");
  while (i) {
    toid = (*this)(i);
    symid = toid.Lab();
    s = new char[symid.get_length()];
    symid.get_name(s);
    src = toid.Src().get();
    dst = toid.Dst().get();
    printf("(%ld,%ld,%s,%ld) ",toid.GetId(),src,s,dst);
    delete s;
    next(i);
  }
  printf("]; ");
}


void TOIDSET::destruct() {
/*
*  clear set from memory (delete TObjects!)
*/
  Pix i = first();
  TOID toid;
  while (i) {
    toid = (*this)(i);
    toid.destroy();
    next(i);
  }
  clear();
}

void TOIDSET::update() {
  Pix ind,i = first();
  TOID toid,search,src,dst;
  search.create(0);
  long module;
  while (i) {
    toid = (*this)(i);
    search.SetId(toid.Src().get());
    ind = seek(search);
    src = (*this)(ind);
    search.SetId(toid.Dst().get());
    ind = seek(search);
    dst = (*this)(ind);
    toid.Update(src,dst);
    module = toid.GetModule().get();
    if (module) {
	search.SetId(module);
	ind = seek(search);
	toid.Update_Module((*this)(ind));
    }
    next(i);
  } 
  search.destroy();
  i = first();
  while (i) {
    toid = (*this)(i);
    if (!(toid == toid.Dst() && toid == toid.Src())) {
      toid.Connect();
    }
    next(i);
  }
}
