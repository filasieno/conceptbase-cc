/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
#include "TDB.h"
#include <string.h>

SYMTBL symbols;

int openTelos ( char* name,int anzahl) {

    fstream telosfile;

/*    char symbolname[200];
 *   char telosname[200];
 *   if (strlen(name)>190) {
 *       printf("Datenbankname laenger als 190!");
 *       return 0;
 *   }
 *   strcpy(symbolname,name);strcat(symbolname,".symbol");
 *   strcpy(telosname,name);strcat(telosname,".telos");
 */

    TOIO toio;
    telosfile.open(name,ios::in|ios::binary);


    if (!telosfile) {
        printf("Telosfile kann nicht geoeffnet werden!");
        return 0;
    }

    char s[DISK_OFFSET];
    if (!telosfile.get(s,DISK_OFFSET,'\n'))
    {
        printf("Kein Header im Telosfile!\n");
        return 0;

    }
    int major_version,minor_version;
    sscanf(s,VERSION_ID,&major_version,&minor_version);
    printf("major-version: %d minor-version: %d\n",major_version,minor_version);

    long id,label;
    int set;
    TOID toid;
    int ms,sec,min,std,day,mon,year;
    TIMEPOINT timepointStart,timepointEnd;
    SYMID symid;
    telosfile.clear();
    if (anzahl)
        telosfile.seekp(-anzahl*sizeof(TOIO),ios::end);
    else
        telosfile.seekp(DISK_OFFSET,ios::beg);
    while (!(telosfile >> toio).eof()) {
        toio.get(id,toid,label,set);
        symbols.use(label,toid,symid);
        char* sLab = new char[ symid.get_length()+1 ];

        symid.get_name( sLab );

        timepointStart.SetTime(toid.STime().GetTime(),toid.STime().GetUsec());
        timepointEnd.SetTime(toid.ETime().GetTime(),toid.ETime().GetUsec());
        printf("id=%6ld label=%6ld (%s) src=%6ld dst=%6ld",id,label,sLab, (long) toid.Src().get(), (long) toid.Dst().get());
        timepointStart.GetTime(ms,sec,min,std,day,mon,year);
        if (toid.STime().GetTime()!=-1)
            printf(" STime: %02d:%02d:%02d,%04d %02d.%02d.%04d",std,min,sec,ms,day,mon,year);
        else
            printf(" STime: --:--:--,---- --.--.----");
        timepointEnd.GetTime(ms,sec,min,std,day,mon,year);
        if (toid.ETime().GetTime()!=-1)
            printf(" ETime: %02d:%02d:%02d,%04d %02d.%02d.%04d",std,min,sec,ms,day,mon,year);
        else
            printf(" ETime: --:--:--,---- --.--.----");

        printf(" modul: %6ld set: %2d\n",toid.GetModule().get(),set);

        delete[] sLab;
    }
    return 1;
}

int openSymbol ( char* name)
{
    symbols.load(name);
    return 1;
}

int closeSymbol()
{
    symbols.destroy();
    return 1;
}


int main(int argc, char *argv[])
{
    char *name;
    char telosname[200];
    int anzahl=0;
    printf("Auslesen...\n");
    openSymbol("OB.symbol");

    //Standartfile OB.telos wird benutzt, wenn nichts uebergeben wird
    if (argc<2) name="./OB.telos";
       else {
           name=argv[1];
       }
        //wird ein 2.parameter uebergeben, so wird er als zeileanzahl interpretiert,
        //die angibt, wieviele zeilen von hinten ausgegeben werden sollen
    if (argc==3) anzahl=atoi(argv[2]);
        //wird ein Filename ohne "." eingegeben, wird ".telos" angehaengt
    for (unsigned int a=0;a<=strlen(name);a++) {
        if (name[a]=='.') { openTelos(name,anzahl);break;}
        if (name[a]==0) {
            strcpy(telosname,name);strcat(telosname,"/OB.telos");
            openTelos(telosname,anzahl);
            break;
        }
    }
    closeSymbol();
	return 0;
}
// g++ -c -o auslesen.o auslesen.cc -I. -Isrc -I/home/prolog/BIM/BIM_4.0/sparc/include
