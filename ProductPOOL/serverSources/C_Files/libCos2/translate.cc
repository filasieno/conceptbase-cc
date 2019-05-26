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
#include "translate.h"


TOIOalt::TOIOalt() 
{}

int TOIOalt::get(long &id, TOID &toid,long &label,int &set)
{
/*
 *  get the information from a given toio
 *  the terminating '\n' is replaced by 0 for the sscanf-command
 */
    long src, dst, StartTime, EndTime, Module;
    int StartUsec, EndUsec;
    
    sscanf(out,"%10ld%10ld%10ld%10ld%14ld%4d%14ld%4d%2d%10ld",&id,&src,&dst,&label,
           &StartTime,&StartUsec,
           &EndTime,&EndUsec,&set,&Module);

    out[sizeof(TOIOalt)-1]='\n';

    if (id == -1)
        return 0;
    
    toid.create(id);
    toid.Update_StartTime(TIMEPOINT(StartTime,StartUsec));
    toid.Update_EndTime(TIMEPOINT(EndTime,EndUsec));
    toid.Update(src,dst);
    toid.Update_Module(Module);

    return 1;
}

fstream& operator >> (fstream&s, TOIOalt& toio) {
/*
*  stream-input operator
*  read toio from disk (this is the string in toio)
*/
  char *c;
  c = (char*) &toio;		    // set the pointer to the first bye
  for (int i=0;i<sizeof(TOIOalt) && s.get(*(c++));i++) {};
  return s;
}



int translate ( char* source, char* ziel) {
    
    fstream telosfileSource, telosfileZiel;
    
    telosfileSource.open(source,ios::in|ios::binary);
    telosfileZiel.open(ziel,ios::out|ios::binary);

    char s[DISK_OFFSET];
    
    
    if (!telosfileSource) {
        printf("Can not open source-file '%s'!\n",source);
        return 0;
    }

    if (!telosfileZiel) {
        printf("Can not open destination-file '%s'!\n",ziel);
        return 0;
    }
    
    if (!telosfileSource.get(s,DISK_OFFSET,'\n'))
    {
        printf("There is no valid header in source-file! File could be corrupt.\n");
        return 0;    
    }

    if (strcmp(s+DISK_OFFSET-5,"2. 1")!=0) {
        printf("Source-file has not version 2.1, but %s\n",s+DISK_OFFSET-5);
        return 0;
    }

    printf("---translate %s to %s ...\n",source,ziel);
    s[DISK_OFFSET-5]='3';
    
    for (int a=0;a<DISK_OFFSET-1;a++) telosfileZiel.put(s[a]);
    telosfileZiel.put('\n');
  /*
   * int major_version,minor_version;
   * sscanf(s,VERSION_ID,&major_version,&minor_version);
   * printf("major-version: %d minor-version: %d\n",major_version,minor_version);
  */

    telosfileSource.seekg(DISK_OFFSET);    
    long id,label;
    int set;
    TOID toid;
    TOIOalt toioAlt;
    while (telosfileSource >> toioAlt) {
        toioAlt.get(id,toid,label,set);        
        TOIO toio(id,toid.Src().get(),toid.Dst().get(),label,toid.STime().GetTime(),toid.STime().GetUsec(),toid.ETime().GetTime(),toid.ETime().GetUsec(),toid.GetModule().get(),set);
        telosfileZiel << toio;
    }
    telosfileSource.close();
    telosfileZiel.close();
    return 1;
}



int main(int argc, char *argv[0])
{
    if (argc==1) {
        if (translate("OB.telos","OB.telos3.1")!=1) printf("There was an error! Translation not successful.\n");
        else printf("No errors. Translation successful.\n");
        return 0;
    } else {
        if (argc==3) {
            if (translate(argv[1],argv[2])!=1) printf("There was an error! Translation not successful.\n");
        else printf("No errors. Translation successful.\n");
            return 0;
        } else {
            printf("Please use the syntax: translate2.1-3.1 <source-file> <destination-file>\n");
            printf("or without any parameters to use defaults: translate2.1-3.1 OB.telos OB.telos3.1\n");
        }
        
    }
}

