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
#include <stdio.h>
#include "transform.h"

trans::trans() {
    name[0]=0;
}

void
trans::set(char *s,TOID c)
{
    strncpy(name,s,100);
    toid = c;
}

int
trans::equal(char *s)
{
 return !strcmp(name,s);
}

TOID
trans::get() {
  return toid;
}

extern "C" {
int main (int argc, char *argv[]) {
  char name[200];
  int i;

  TDB database;
  database.open("SYSTEM");

  if (argc == 2)
      {
	  strcpy(name,argv[1]);
      }
  else
      {
	  strcpy(name,"SML0.prop");
      }
  trans daten[500];
  int anz=0;
  char s[1024];
  char *id,*src,*lab,*dst;
  char *s1;
  TOID toid,stoid,dtoid;
  FILE *fp=fopen(name,"r");
  fgets(s,1024,fp);
  while (fgets(s,1024,fp)) {
    if (strncmp(s,"hP",2))
	continue;
    s1=s;
    while (*s1 != '(') s1++;
    id=++s1;
    if (*id == '\'') {
     for (s1++,id++;*s1!='\'';s1++)
	 {};
     *s1=0;
     s1++;
    }
    else {
     for (s1++;*s1!=',';s1++)
	 {};
     *s1=0;
    }

    src=++s1;
    if (*src == '\'') {
     for (s1++,src++;*s1!='\'';s1++){};
     *s1=0;
     s1++;
    }
    else {
     for (s1++;*s1!=',';s1++){};
     *s1=0;
    }

    lab=++s1;
    if (*lab == '\'') {
     for (s1++,lab++;*s1!='\'';s1++){};
     *s1=0;
     s1++;
    }
    else {
     for (s1++;*s1!=',';s1++){};
     *s1=0;
    }

    dst=++s1;
    if (*dst == '\'') {
     for (s1++,dst++;*s1!='\'';s1++){};
     *s1=0;
     s1++;
    }
    else {
     for (s1++;*s1!=',';s1++){};
     *s1=0;
    }


    if (!strcmp(id,src) && !strcmp(id,dst) && !strcmp(lab,"-"))
    {
	for (i=0;i<anz && !daten[i].equal(id);i++)
	    ;
	if (i == anz)
	{
	    toid = database.Create_node(id);
	    database.insert(toid);
	    daten[anz++].set(id,toid);
	}
	else
	{
	    database.create_name2toid(id,toid);
	}
    }
    else
    {
	for (i=0;i<anz && !daten[i].equal(src);i++)
	    ;
	if (i == anz)
	{
            stoid = database.Create_node(src);
            database.insert_implicit(stoid);
	    daten[anz++].set(src,stoid);
	}
	else
	{
	    stoid = daten[i].get();
	}

	for (i=0;i<anz && !daten[i].equal(dst);i++)
	    ;
	if (i == anz)
	{
            dtoid = database.Create_node(dst);
            database.insert_implicit(dtoid);
	    daten[anz++].set(dst,dtoid);
	}
	else
	{
	    dtoid = daten[i].get();
	}

	toid=database.Create_link(lab,stoid,dtoid);
	database.insert(toid);
	daten[anz++].set(id,toid);
    }

  }
  database.insert_commit();
  return 0;
} /* main */
} /* extern "C" */


