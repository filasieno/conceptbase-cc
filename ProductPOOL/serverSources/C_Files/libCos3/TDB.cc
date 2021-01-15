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
/*********************************************************************
*
*   TDB.cc:
*
*   Creation:      5.1.1993
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   30.3.1994
*   Changed by:    Thomas List
*   Version 2.1a
*
*
**********************************************************************/

#include "TDB.h"


/***************************** TOIO **********************************/

TOIO::TOIO() {
  clear();
}

TOIO::TOIO(long id,long src,long dst, long label,long StartTime,short StartTimeU, long EndTime, short EndTimeU, long module, int set)
{
  long2string(id,idChar);
  long2string(src,srcChar);
  long2string(dst,dstChar);
  long2string(label,labelChar);
  long2string(StartTime,StartTimeChar);
  short2string(StartTimeU,StartTimeUChar);
  long2string(EndTime,EndTimeChar);
  short2string(EndTimeU,EndTimeUChar);
  long2string(module,moduleChar);
  long2string((long)set,setChar);
}


TOIO::TOIO(TOID toid,int set) {
/*
*  convert the toid to the string defined in TOIO
*  and replace the terminating 0 with the newline \n
*/

  long id,src,dst,label,StartTime,EndTime,module;
  short StartTimeU, EndTimeU;

  SYMID symid;
  id = toid.GetId();
  symid = toid.Lab();
  label = symid.getid();
  src = toid.Src().GetId();
  dst = toid.Dst().GetId();
  StartTime = toid.STime().GetTime();
  StartTimeU = toid.STime().GetUsec();
  EndTime = toid.ETime().GetTime();
  EndTimeU = toid.ETime().GetUsec();
  module = toid.GetModule().GetId();


      //Umwandeln der Werte in Byteketten
  long2string(id,idChar);
  long2string(src,srcChar);
  long2string(dst,dstChar);
  long2string(label,labelChar);
  long2string(StartTime,StartTimeChar);
  short2string(StartTimeU,StartTimeUChar);
  long2string(EndTime,EndTimeChar);
  short2string(EndTimeU,EndTimeUChar);
  long2string(module,moduleChar);
  long2string((long)set,setChar);

//  sprintf(out,"%10ld%10ld%10ld%10ld%14ld%4d%14ld%4d%2d%10ld",id,src,dst,label,StartTime,StartTimeU,EndTime,EndTimeU,set,module);

//  out[sizeof(TOIO)-1]='\n';
}

void TOIO::clear() {
/*
*  create a string that is "undefined"
*/
        //  out[sizeof(TOIO)-1]='\n';
        //sprintf(out,"%10d%10d%10d%10d%14d%4d%14d%4d%2d%10d",-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);

        //der wert -1 bedeutet undefined
    long2string(-1,idChar);
    long2string(-1,srcChar);
    long2string(-1,dstChar);
    long2string(-1,labelChar);
    long2string(-1,StartTimeChar);
    short2string(-1,StartTimeUChar);
    long2string(-1,EndTimeChar);
    short2string(-1,EndTimeUChar);
    long2string(-1,moduleChar);
    long2string(-1,setChar);

}

int TOIO::get(long &id, TOID &toid,long &label,int &setb)
{
/*
 *  get the information from a given toio
 *  the terminating '\n' is replaced by 0 for the sscanf-command
 */
    long src, dst, StartTime, EndTime, Module,dummy;
    short StartUsec, EndUsec;
/*
 *   out[sizeof(TOIO)-1]=0;
 *   sscanf(out,"%10ld%10ld%10ld%10ld%14ld%4d%14ld%4d%2d%10ld",&id,&src,&dst,&label,
 *          &StartTime,&StartUsec,
 *          &EndTime,&EndUsec,&set,&Module);
 *
 *   out[sizeof(TOIO)-1]='\n';
*/
    string2long(idChar,id);
    string2long(srcChar,src);
    string2long(dstChar,dst);
    string2long(labelChar,label);
    string2long(StartTimeChar,StartTime);
    string2short(StartTimeUChar,StartUsec);
    string2long(EndTimeChar,EndTime);
    string2short(EndTimeUChar,EndUsec);
    string2long(moduleChar,Module);
    string2long(setChar,dummy);setb=dummy;

    if (id == -1)
        return 0;

    toid.create(id);
    toid.Update_StartTime(TIMEPOINT(StartTime,StartUsec));
    toid.Update_EndTime(TIMEPOINT(EndTime,EndUsec));
    toid.Update(src,dst);
    toid.Update_Module(Module);

    //printf("Loaded TOID:[(%ld,%ld,%ld,%ld)]\n",toid.GetId(),src,label,dst);
    return 1;
}


void TOIO::long2string(long zahl, char* ziel)
{
    if (zahl>=0) {
         ziel[0]=(unsigned char) (zahl/(256*256*256)) % 256;
         ziel[1]=(unsigned char) (zahl/(256*256)) % 256;
         ziel[2]=(unsigned char) (zahl/(256)) % 256;
         ziel[3]=(unsigned char) zahl % 256;
    } else {
         ziel[0]=-1;
         ziel[3]=ziel[1]=ziel[2]=0;
    }
}

void TOIO::short2string(short zahl, char* ziel)
{
    if (zahl>=0) {
        ziel[0]=(unsigned char) (zahl/(256)) % 256;
        ziel[1]=(unsigned char) zahl % 256;
    } else {
        ziel[0]=-1;
        ziel[1]=0;
    }
}


void TOIO::string2long(char* daten,long& ziel)
{
    ziel=(unsigned char) daten[3];
    ziel+=((unsigned char) daten[2])*256;
    ziel+=((unsigned char) daten[1])*256*256;
    ziel+=((unsigned char) daten[0])*256*256*256;
    if (daten[0]==-1) ziel=-1;
}

void TOIO::string2short(char* daten,short& ziel)
{
    ziel=(unsigned char) daten[1];
    ziel+=((unsigned char) daten[0])*256;
    if (daten[0]==-1) ziel=-1;
}


fstream& operator << (fstream&s, TOIO toio) {
/*
*  stream-output operator
*  write the toio to disk (this is the string in toio)
*/
  char *c;
  c = (char*) &toio;		    // set the pointer to the first
  for (unsigned int i=0;i<sizeof(TOIO);i++)  // byte of the toid and read
      secure_put(s,*(c++));
  return s;
}

fstream& operator >> (fstream&s, TOIO& toio) {
/*
*  stream-input operator
*  read toio from disk (this is the string in toio)
*/
  char *c;
  c = (char*) &toio;		    // set the pointer to the first bye
  for ( unsigned int i=0;i<sizeof(TOIO) && s.get(*(c++));i++) {};
  if (!s) toio.clear();		    // of the toio and write byte by byte
  return s;
}




TDB::TDB () {
/*
*  Database-constructor
*  the MaxID counts the highest ID in the Database
*  -1 is used for undefined ID's
*/

  MaxID = 0;
  toidtable = new TOIDREFHashSet ();
  overrule_search_space = 0;
  system_module.create(0);
  next_module = system_module;
  is_overrule_module = 0;
  unused_ID.clear();
}

TDB::~TDB () {  //  Destruktor der TDB-Klasse
/*
*  Database-destructor:
*  close files and clear memory
*/
//  fclose(fp);

//    diese Fkt. funktionieren, sind aber zu langsam
/*
 * akt.destruct();
 * tmp1.destruct();
 * tmp2.destruct();
 * tmp3.destruct();
 * hist.destruct();
 * unused_ID.clear();
 * delete toidtable;
 */
// dieses destroy, fuehrt den destructor der symtbl aus, der das symfile nochmal ohne luecken schreibt
    Symbols.destroy();
}

int TDB::get_symb(char *s,SYMID& symid) {
/*
*  returns the symid of a string
*/
    return Symbols.get_symb(s,symid);
}

int TDB::toid2name( TOID toid, char* s) {
/*
*  returns the name of the object
*/

  return Symbols.get_name(toid.Lab(),s);
}

int TDB::name2toid(char *s, TOID &toid, TOID module)
{
  TOIDSETSTL *toidset;
  TOIDSetIterator ind;
  toidset=Symbols.name_uses(s);
  if (!toidset->empty())
  {
    /*
     *   pass 1: ohne imports
     */
    ind=toidset->begin();
    if(ind != toidset->end())
    	  toid=(*ind).second;
    while (ind != toidset->end() && (
	  !( toid== toid.Src() && toid==toid.Dst()) ||
	  !( toid.Valid().Is_In_Interval(next_search_time)) ||
	  !( toid.GetModule()==system_module || toid.GetModule()==module) ))
      {
	  ind++;
	  toid=(*ind).second;
      }
      if (ind != toidset->end())
      {
	  toid=(*ind).second;
	  return 1;
      }
      /*
       *   pass 2: imports
       */

      TOIDSETSTL &import = module.Import();   // Referenz auf die Import-Menge des aktuellen Moduls
      TOID current;
      if (import.length())      // das Modul importiert nichts => Abbruch
      {
	TOID module;
	TOIDSetIterator ind2;


	ind=toidset->begin();
	while (ind != toidset->end() )
	{
	  toid =(*ind).second;   // aktuelles Element mit gueltigem Label

	  if ( (toid==toid.Src() && toid==toid.Dst()) &&           // Check auf Individual
	       (toid.Valid().Is_In_Interval(next_search_time)) )   // Check auf den Zeitpunkt
	  {
	      module=toid.GetModule();   // Modul des aktuellen Elements
	      if (
		  (module.Valid().Is_In_Interval(next_search_time)) &&  // Check Modul auf Zeitpunkt
		  (module.Export().contains(toid)) )                    // Check ob Modul Element exportiert
	      {
		  for (ind2=import.begin();ind2!= import.end();ind2++)     // alle Import-Module von module
		  {
		      current=(*ind2).second;
		      if ( current.Dst() == module &&
			   current.Valid().Is_In_Interval(next_search_time) )
		      {
			  // toid enthaelt schon das gewollte Element
			  return 1;
		      } // if
		  } // for
	      } // if
	  } // if
	  ind++;
	} // while
      } // if
      /*
       *   pass 3: nested modules
       */
      if (!(module.GetModule() == system_module))
	return name2toid(s,toid,module.GetModule());

  }
  return 0;



}

int TDB::name2toid( char* s,TOID& toid) {
/*
*  returns an ID that points to an object with
*  label s
*  the object MUST be a node and be valid at the actual searchtime
*/


  return name2toid(s,toid,next_module);
}

int TDB::name2toidset( char *s, TOIDSETSTL &toidset) {
    TOIDSetIterator ind;
    TOIDSETSTL helpset;
    TOID current;
    if (!Symbols.star_search(s,helpset)) return 0;
    if (!helpset.empty()) {
	ind=helpset.begin();
	while (ind != helpset.end()) {
	    current=(*ind).second;
	    if (ind !=helpset.end()&& (
		( current== current.Src() && current==current.Dst()) &&
		( current.Valid().Is_In_Interval(next_search_time))) )
		{
		    toidset.add(current);
		}
	    ind++;
	}
    }
    return toidset.empty();
}

int TDB::create_name2toid( char* s,TOID& toid) {
/*
*  returns an ID that points to an object with
*  label s
*  the object MUST be a node and be valid at the actual searchtime
*  a node located in tmp3 is moved to tmp1
*/
  TOIDSETSTL toidset;
  TOID current;
  TOIDSetIterator ind;
  if (Symbols.name_uses(s,toidset)) {
    ind=toidset.begin();
    if (ind != toidset.end() )
    	current=(*ind).second;
    while (ind != toidset.end() && (
     !( current==current.Src() && current==current.Dst()) ||
     !( current.Valid().Is_In_Interval(next_search_time))) ) {
       ind++;
       current=(*ind).second;
    }
    if (ind != toidset.end()) {
      toid=(*ind).second;
      if (tmp3.contains(toid)) {
        tmp3.del(toid);
        tmp1.add(toid);
      }
    }
  }
  return 0;
}



void TDB::toid2oid( TOID toid, char* s) {
/*
*  returns a string-form of the toid
*/
  toid.GetOid(s);
}


int TDB::oid2toid( char* s,TOID& toid) {
/*
*  converts the string form into the toid
*/

  long l1;
  if (sscanf(s,"id_%ld",&l1) != 1) return 0;
  TOIDREF toidref(l1);
  toid=(*toidtable)(toidtable->seek(toidref)).GetToid();
  return 1;
}

int TDB::create_oid2toid( char* s,TOID& toid) {
/*
*  converts the string form into the toid
*  moves a toid from tpm3 to tmp1 if possible
*/

  long l1;
  if (sscanf(s,"id_%ld",&l1) != 1) return 0;
  TOIDREF toidref(l1);
  toid=(*toidtable)(toidtable->seek(toidref)).GetToid();

  #if DLEVEL >= 4
  printf("create_oid2toid.\n");
  #endif
  if (tmp3.contains(toid)) {
    #if DLEVEL >= 4
    printf("moving.....\n");
    #endif
    tmp3.del(toid);
    tmp1.add(toid);
  }
  return 1;
}



int TDB::select2toid(char *s,TOID& toid) {
 char *s1,*s2;
 char c,ende=0;
 s1=s;
 while (*s1 && *s1 != '!' && !((*s1=='-' || *s1=='=') && *(s1+1)=='>')) s1++;
 ende = *s1;
 *s1=0;
 TOID toid2;
 if (!name2toid(s,toid)) return 0;
 while (ende) {
   s1++;
   if (ende=='!') {
     TOIDSETSTL toidset;
     for (s2=s1;*s1 && *s1 != '!' && !((*s1=='-' || *s1=='=') && *(s1+1)=='>');s1++) {}
     ende=*s1;
     *s1=0;
     if (!Symbols.name_uses(s2,toidset)) return 0;
     toidset &= toid.AtrO();
     if (toidset.empty()) return 0;
     toid = toidset.first();
   }
   else {
     c=ende;
     s1++;
     for (s2=s1;*s1 && *s1 != '!' && !((*s1=='-' || *s1=='=') && *(s1+1)=='>');s1++) {}
     ende=*s1;
     *s1=0;
     if (!name2toid(s2,toid2)) return 0;
     TOIDSETSTL toidset;
     if (c=='=') {
       toidset |= toid.IsaO();
       toidset &= toid2.IsaI();
     }
     else {
       toidset |= toid.IofO();
       toidset &= toid2.IofI();
     }
     if (toidset.empty()) return 0;
     toid = toidset.first();
   }
 }
 return 1;
}


int TDB::toid2select(TOID toid,char* s) {
  s[0]=0;
  char *buffer;
  int typ;
  while (!(toid == toid.Src() && toid == toid.Dst())) {
   buffer = new char[strlen(s)+1];
   strcpy(buffer,s);
   s[0]=0;
   if ((typ = toid.Lab().get_type()) == NONE) {
     s[0]='!';
     toid.Lab().get_name(s+1);
     toid = toid.Src();
   }
   else {
    s[0] = (typ == INSTANCEOF ? '-':'=');
    s[1] = '>';
    toid.Dst().Lab().get_name(s+2);
    toid=toid.Src();
    }
   strcat(s,buffer);
   delete[] buffer;
  }
  buffer = new char[strlen(s)+1];
  strcpy(buffer,s);
  toid.Lab().get_name(s);
  strcat(s,buffer);
  delete[] buffer;
  return 1;
}

int TDB::check_implicit(TOID toid) {
  return tmp3.contains(toid);
}


void TDB::initialize_modules()
{
    char label[15];
    TOID toid,current;

    strcpy(label,"Module!exports");
    if (select2toid(label,toid))
    {
	TOIDSETSTL &toidset = toid.IofI();
	if (toidset.length())
	{
	    for (TOIDSetIterator ind=toidset.begin();ind != toidset.end();ind++)
	    {
	    	current=(*ind).second;
//		printf("id_%ld exports id_%ld.\n",toidset(ind).Src().Src().GetId(),toidset(ind).Src().GetId());
		current.Src().Src().NewExport(current.Src());
	    }
	}
    }
    strcpy(label,"Module!imports");
    if (select2toid(label,toid))
    {
	TOIDSETSTL toidset = toid.IofI();
	if (toidset.length())
	{
	    for (TOIDSetIterator ind=toidset.begin();ind != toidset.end();ind++)
	    {
	    	current=(*ind).second;
//		printf("id_%ld imports id_%ld.\n",toidset(ind).Src().Src().GetId(),toidset(ind).Src().GetId());
		current.Src().Src().NewImport(current.Src());
	    }
	}
    }
}


int TDB::open ( char* name ) {
/*
*  open (load) a given database from disk (via TOIO's)
*/
    TOIDSetIterator ind;
    char symbolname[200];
    char telosname[200];
    if (strlen(name)>190) {
        printf("Datenbankname laenger als 190!");
        return 0;
    }
    strcpy(symbolname,name);strcat(symbolname,".symbol");
    strcpy(telosname,name);strcat(telosname,".telos");

    int set;
    long id=-1,label;
    SYMID symid;
    TOID toid;
    TOIO toio;

    //printf("Symboltabelle soll geladen werden!\n");

    if (!Symbols.load(symbolname))
    {
        printf("Unable to load symbol table!\n");
        return 0;
    };
// loads the symbol-table


    telosfile.open(telosname,ios::in|ios::out|ios::binary);
    if (!telosfile) {
        printf("Unable to open file with telos objects: %s!\n",telosname);
        return 0;
    }


    char s[DISK_OFFSET+1]; // +1 for terminating null byte to avoid buffer overflow of ticket #223
    if (!telosfile.get(s,DISK_OFFSET,'\n'))
    {
        telosfile.clear(ios::goodbit);
        sprintf(s,VERSION_ID,MAJOR_VERSION,MINOR_VERSION); 
        for (int i=0;i<DISK_OFFSET;i++)
        {
            secure_put(telosfile,s[i]);
        }

    }
    else
    {
        int major_version,minor_version;
        if (sscanf(s,VERSION_ID,&major_version,&minor_version) != 2
            || (major_version != MAJOR_VERSION))
        {
            printf("Incorrect Version! major-version: %d minor-version: %d\n",major_version,minor_version);
            return 0;
        }
        TOIDREF toidref;
        telosfile.seekg(DISK_OFFSET);

        while (!(telosfile >> toio).eof()) {		    // while there are still files to read
			//    toio.get(id,src,dst,label,starttime,startusec,endtime,endusec,set,module);
            if (toio.get(id,toid,label,set) && set != UNUSED)
            {
                // mark the symbol as used by this toid
                if (!Symbols.use(label,toid,symid)) {
#ifdef CB_TRACE
        printf("TDB::open *** Datenbank nicht konsistent. SYMID von id=%ld nicht gefunden!\n",id);
#endif
                }
                toid.Update_Label(symid);
                if (set==ACTUAL_DB) akt.add(toid);    // and insert the toid
                else hist.add(toid);

                toidref.SetId(toid);
                toidtable->add(toidref);		    // update the entry in the hash-table
            }
            else {
#if DELEVEL >= 1
                printf("unused entry!\n");	    // if set is UNUSED
#endif
                unused_ID.add(id);		    // add the id into the unused set
                    // (this means the fileposition can be used by
                    // another object
            }
        }
    // printf("Datenbank geladen\n\n");
    }

    MaxID	= id+1;				    // compute the new MaxId as last read id (filepos) + 1
    TOIDSETSTL helpset;			    // create a set including both act and hist set


    helpset |= akt;
    helpset |= hist;

    helpset.update();			    // and update the links
        // both sets are needed in one because links from
                                            // an act-object to a temp-object are possible


        /*
         *
         * fuer Module
         *
         */
    TOID search;
    search.create(0);
    long system_mod = 0;
    char cSystem[] = "System";  // variable to hold string "System"

    ind = akt.seek(search);
    if (ind != akt.end()) {
    	TOID result=(*ind).second;
        system_mod = result.GetModule().get();
        if (system_mod) {
                /*
                 *  das Modul, das an Proposition haengt, wird als System-Modul
                 *  angenommen.
                 */
            system_module.destroy();
            system_module = result.GetModule();
            next_module = system_module;
           // printf("System Module gefunden\n");
        } else {
            system_module.destroy();

                /*
                 *  Das ist jetzt nichts anderes als ein name2id auf System,
                 *  nur dass hier die Modulzugehoerigkeit noch nicht ueber-
                 *  prueft wird.
                 *  Dieser Fall kann nur auftreten, wenn an Proposition das
                 *  Modul 0 haengt - also wenn eine neue Datenbank aus
                 *  SML0.prop aufgebaut wird.
                 */
            TOIDSETSTL *toidset;
            toidset=Symbols.name_uses(cSystem);
            if (toidset->empty()) {
                printf("System Module not found!\nPlease tell the Module-Structure with CB4 first!\n");
                exit(2);
            }

            ind=toidset->begin();
            TOID current=(*ind).second;
            while (ind != toidset->end() && !akt.contains(current))
                ind++;
                current=(*ind).second;
            if (ind == toidset->end()) {
                printf("System Module not valid!\n");
                exit(2);
            }

            toid=current;

            SystemModule(current);

        }

    }
    search.destroy();
    system_module.SetSystemModule(system_module);

    initialize_modules();

        /* Modul-Zusatz ende */

    Symbols.load_done();  // also intializes persistency_level
    return 1;
}


int TDB::close() {
/*
*
*/
  // not jet implemented
  return 0;
}

int TDB::rename(char *newname, char *oldname)
{
    SYMID symid;
    if (!Symbols.get_symb(oldname, symid)) return 0;
    return Symbols.rename(newname,symid);
}

TOID TDB::Create_node(char* s) {
/*
*  create a new node
*  ID is not set
*/
  TIMEPOINT endtime(TEMP_INFINITY,0);       // endtime id infinity (temp)
  TOID toid;
  SYMID symid;
  toid.create(-1);                  // create a new TOBJ via toid
                                    // with ID-entry newID
   // ask symbol-table for a symid
  if (!Symbols.create(s,symid)) {
#ifdef CB_TRACE
      printf("TDB::Create_node *** Can't create new symbolentry!\n");
      exit(2);
#endif
  }                                  // to label s
  toid.Update_Label(symid);
  toid.Update(toid,toid);           // update links (id=src=dst)
  toid.Update_StartTime(transaction_time);
  toid.Update_EndTime(endtime);     // set valid-time form now to
  toid.Update_Module(next_module);
  return toid;                      // infinity
}

TOID TDB::Create_link(char* s, TOID src, TOID dst) {
/*
*  create a new link from src to dst
*  ID is not set
*/
  TIMEPOINT endtime(TEMP_INFINITY,0);       // endtime id infinity
  TOID toid;
  SYMID symid;
  toid.create(-1);                  // create a new TOBJ via toid
                                    // with ID-entry newID
  Symbols.create(s,symid);     // ask symbol-table for a symid
                                    // to label s
  toid.Update_Label(symid);
  toid.Update(src,dst);             // update links (src->dst)
  toid.Update_StartTime(transaction_time);
  toid.Update_EndTime(endtime);     // set valid-time form now to
  toid.Update_Module(next_module);
  return toid;                      // infinity
}

void TDB::Destroy(TOID toid) {
/*
*  destroy a toid:
*    delete the SYMTBL-entry
*    delete toid from memory
*/
  Symbols.del(toid.Lab(),toid);    // the symbol
  toid.destroy();                  // the toid
}


long TDB::insert( TOID& toid ) {
/*
*  insert a new toid into the database
*  the toid is inserted into the tmp1-set
*/


  #if DLEVEL >= 1
  printf("insert(%s): ",toid.Lab().get_name());
  #endif
  long newID;
  if (Symbols.get_persistency_level() == PERSISTENT) telosfile.clear();		    // make sure seek works ok
                                    // find a new ID for
                                    // the object:
  if (unused_ID.empty()) {          // no unused ID:
    newID = MaxID++;
    if (Symbols.get_persistency_level() == PERSISTENT) telosfile.seekp(0,ios::end);
  }                                 // new ID (via MaxID)
  else {                            // else:
    newID = unused_ID.first();      // find ID in unused-set use it and
    unused_ID.del(newID);           // delete ID from unused-set
    if (Symbols.get_persistency_level() == PERSISTENT) telosfile.seekp(DISK_OFFSET+newID*sizeof(TOIO),ios::beg);
  }

  toid.SetId(newID);                // at this Point the ID is set

  TOIDREF toidref(toid);
  toidtable->add(toidref);	    // update the toid-table

  #if DLEVEL >= 1
  printf("NEW  %ld %ld %s %ld\n",
	 toid.GetId(),toid.Src().GetId(),toid.Lab().get_name(),toid.Dst().GetId());
  #endif
  Symbols.mark_use(toid,toid.Lab());
                                    // now the symid-uses-set

  tmp1.add(toid);		    // insert to tmp1
  toid.Connect();		    // connect the toid
  toid.SetTemp(TEMP_DB_TELL);
  TOIO toio(toid,UNUSED);	    // switch set to ACTUAL_DB in insert_commit()
  if (Symbols.get_persistency_level() == PERSISTENT) telosfile << toio;

  return newID;
}


long TDB::insert_implicit( TOID& toid ) {
/*
*  insert a new toid into the database
*  the toid is inserted into the tmp3-set
*/

  long newID;
  if (Symbols.get_persistency_level() == PERSISTENT) telosfile.clear();		    // make sure seek works ok
                                    // find a new ID for
                                    // the object:
  if (unused_ID.empty()) {          // no unused ID:
    newID = MaxID++;
    if (Symbols.get_persistency_level() == PERSISTENT) telosfile.seekp(0,ios::end);
  }                                 // new ID (via MaxID)
  else {                            // else:
    newID = unused_ID.first();      // find ID in unused-set use it and
    unused_ID.del(newID);           // delete ID from unused-set
    if (Symbols.get_persistency_level() == PERSISTENT) telosfile.seekp(DISK_OFFSET+newID*sizeof(TOIO),ios::beg);
  }
  toid.SetId(newID);                // at this Point the ID is set

  TOIDREF toidref(toid);
  toidtable->add(toidref);	    // update the toid-table

  #if DLEVEL >= 1
  printf("NEW (impl) %ld %ld %s %ld\n",
	 toid.GetId(),toid.Src().GetId(),toid.Lab().get_name(),toid.Dst().GetId());
  #endif

  Symbols.mark_use(toid,toid.Lab());
                                    // now the symid-uses-set

  tmp3.add(toid);		    // insert to tmp1
  toid.Connect();		    // connect the toid
  toid.SetTemp(TEMP_DB_TELL);
  TOIO toio(toid,UNUSED);	    // switch set to ACTUAL_DB in insert_commit()
  if (Symbols.get_persistency_level() == PERSISTENT) telosfile << toio;

  return newID;
}

int TDB::insert_commit() {
/*
*  move elements from tmp1 to akt
*/
  if (!tmp3.empty()) {
    printf("tmp3 not empty!\n");
  }
  TOID toid;
  TOIDSetIterator i;
  i=tmp1.begin();
  while (i != tmp1.end()) {
    toid = (*i).second;               // get the toid
    toid.Update_EndTime(TIMEPOINT(INFINITY,0));
    if (Symbols.get_persistency_level() == PERSISTENT) {
      telosfile.clear();
      telosfile.seekp(DISK_OFFSET+toid.GetId()*sizeof(TOIO),ios::beg);
      TOIO toio(toid,ACTUAL_DB);
      telosfile << toio;
    }
    // tmp1.del(toid);		    //  Element aus der tmp-Menge entfernen
    akt.add(toid);		    //  add Element to aktual-set
    toid.UnsetTemp();
    i++;
  }
//  akt |= tmp1;         // move elements from tmp1 to akt
  tmp1.clear();        // clear tmp1
  return 1;
}

void TDB::insert_abort() {
/*
*  delete tmp1 (abort insertion)
*/

  TOIDSetIterator i;
  TOID toid,current;
  TOIDREF toidref;

  i=tmp1.begin();
  while (i != tmp1.end()) {
    current=(*i).second;
    current.Disconnect();
    i++;
  }

  i=tmp3.begin();
  while (i != tmp3.end()) {
    TOID current= (*i).second;
    current.Disconnect();
    i++;
  }

  while (!tmp1.empty()) {        // while there is a first element
    i=tmp1.begin();
    toid = (*i).second;               // get the toid

    toidref.SetId(toid);
    toidtable->del(toidref);	  // update the toidtable

    unused_ID.add(toid.GetId());  // insert ID in unused-set
    tmp1.del(toid);		  // remove object from tmp-set
    Destroy(toid);		  // deallocate object
  }
  while (!tmp3.empty()) {        // while there is a first element
    i=tmp3.begin();              // get the toid
    toid=(*i).second;

    toidref.SetId(toid);
    toidtable->del(toidref);	  // update the toidtable

    unused_ID.add(toid.GetId());  // insert ID in unused-set
    tmp3.del(toid);		  // remove object from tmp-set
    Destroy(toid);		  // deallocate object
  }
}

int TDB::remove( TOID toid ) {
/*
*  move toid from akt to tmp2 (mark it as history)
*/
  if (!akt.contains(toid)) return 0;
  akt.del( toid );        //  remove toid from akt
  tmp2.add( toid );       //  insert toid to tmp2
  toid.SetTemp(TEMP_DB_UNTELL);
//  toid.Update_EndTime(transaction_time); // update endtime to now
  return 1;
}

int TDB::removetmp( TOID toid ) {
/*
*  remove toid from tmp1, object will no longer be defined afterwards
*  see also ticket #92
* Note that tmp1 is the set of objects that have been created in the
* current transaction. Hence, removetmp is a method to delete objects
* that are not yet commited to the database
* 
*/

  if (!tmp1.contains(toid)) return 0;
  tmp1.del( toid );        //  remove toid from tmp1
  toid.SetTemp(TEMP_DB_UNTELL);  // mark the object to be "deleted"
  return 1;
}


void TDB::remove_end() {
/*
*  move toids from tmp2 to hist (remove successfull)
*/
  TOIDSetIterator i=tmp2.begin();   // search all elements from tmp2
  while (i != tmp2.end()) {           // set EndTime to infinity
    TOID current=(*i).second;
    current.Update_EndTime(transaction_time);
    TOIO toio(current,HISTORY_DB);
    if (Symbols.get_persistency_level() == PERSISTENT) {
      telosfile.clear();
      telosfile.seekp(DISK_OFFSET+current.GetId()*sizeof(TOIO),ios::beg);
      telosfile << toio;
    }
    current.UnsetTemp();
    i++;
  }
  hist |= tmp2;
  tmp2.clear();
}

void TDB::remove_abort () {
/*
*  abort remove (move elements from tmp2 to akt
*  and reset endtime to infinity
*/
  TOIDSetIterator i=tmp2.begin();   // search all elements from tmp2
  while (i != tmp2.end()) {           // set EndTime to infinity
    TOID current = (*i).second;
    current.UnsetTemp();
    i++;
  }
  akt |= tmp2;
  tmp2.clear();
//  printf("remove_abort\n");fflush(stdout);   // trace the call of the method
}

void TDB::set_search_space( int whatset ) {
/*
* set search space for next query-operation
*/
  next_search_space = whatset;
}

void TDB::set_overrule_search_space( int whatset )
/*
* this is used for a single search request not using
* the global search space
*/
{
  overrule_search_space = whatset;
}

void TDB::delete_overrules()
{
    overrule_search_space = 0;
    is_overrule_module = 0;
}



void TDB::set_search_time( TIMEPOINT whattime ) {
/*
* set search time for next query-operation
*/
  next_search_time = whattime;
}


void TDB::start_seek (QUERY4a &descriptor, TOID id, TOID src, SYMID label,
                      char* slabel, TOID dst, int Pattern) {
/*
*  start a search-operation
*/



  int search_space;
  TOID module;

  if (overrule_search_space)
  {
      search_space = overrule_search_space;
      overrule_search_space = 0;
  }
  else search_space = next_search_space;

  /*
   *  Module:
   *  Dies ist Suchen im Modulkontext
   */


  if (is_overrule_module)
  {
      module = overrule_module;
      is_overrule_module = 0;
  }
  else module = next_module;

  descriptor.set(search_space,next_search_time,id,src,label,slabel,
                 dst,this,Pattern,module,0);
}

void TDB::start_seek (QUERY4a &descriptor, TOID id, TOID src, SYMID label,
                      char* slabel, TOID dst, int Pattern, TOID module) {
/*
*  start a search-operation
*/

  int search_space;

  if (overrule_search_space)
  {
      search_space = overrule_search_space;
      overrule_search_space = 0;
  }
  else search_space = next_search_space;


  /*
   *  Module:
   *  Dies ist Suchen ohne Modulkontext, dafuer mit Modulkomponente
   */

  descriptor.set(search_space,next_search_time,id,src,label,slabel,
                 dst,this,Pattern,module,1);
}




void TDB::start_Literal (QUERY2 &descriptor, TOID id1, TOID id2,
                         int Pattern, Literals WhatLit)
{
  int search_space;
  if (overrule_search_space)
     {
         search_space = overrule_search_space;
         overrule_search_space = 0;
      }
  else
      {
	  search_space = next_search_space;
      }

  TOID module;
  if (is_overrule_module)
  {
      module = overrule_module;
      is_overrule_module = 0;
  }
  else module = next_module;

  switch(WhatLit)
  {
  case Attr_s:
      descriptor.set(search_space,next_search_time,id1,id2,this,
                     Pattern, module, 0);
      break;
  case In_s:
      descriptor.set(search_space,next_search_time,id1,id2,this,
                     Pattern, module, 0);
      break;
  case In_i:
      descriptor.set(search_space,next_search_time,id1,id2,this,
                     Pattern, module, 0);
      break;
  case system_class:
      descriptor.set(search_space,next_search_time,id1,id2,this,
                     Pattern, module, 0);
  case Isa:
      descriptor.set(search_space,next_search_time,id1,id2,this,
                     Pattern, module, 0);
  default: break;
  }
}

void TDB::start_Literal3( QUERY3 &descriptor, TOID x,SYMID ml,char *mlhelp,TOID y,
			  int Pattern, Literals WhatLit)
{
    int search_space;
    if (overrule_search_space)
	{
	    search_space = overrule_search_space;
	    overrule_search_space = 0;
	}
    else
	{
	    search_space = next_search_space;
	}

    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;

    switch(WhatLit)
    {
    case ALit:
        descriptor.set(search_space, next_search_time, x, ml, mlhelp, y,
                       Pattern, module,0);
        break;
    default: break;
    }
}

void TDB::start_Literal4( QUERY4a &descriptor, TOID cc, TOID x,SYMID ml,char *mlhelp,TOID y,
			  int Pattern, Literals WhatLit)
{
    int search_space;
    if (overrule_search_space)
	{
	    search_space = overrule_search_space;
	    overrule_search_space = 0;
	}
    else
	{
	    search_space = next_search_space;
	}

    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;

    switch(WhatLit)
    {
    case Adot:
        descriptor.set(search_space, next_search_time, cc, x, ml, mlhelp, y,this,
                       Pattern, module, 0);
        break;
    case Aidot: 
        descriptor.set(search_space, next_search_time, cc, x, ml, mlhelp, y,this,
                       Pattern, module, 0);
        break;
    default: break;
    }
}

void TDB::start_Literal4( QUERY4b &descriptor, TOID x, SYMID ml,char *mlhelp,SYMID l,char *lhelp,TOID y,
			  int Pattern, Literals WhatLit)
{
    int search_space;
    if (overrule_search_space)
	{
	    search_space = overrule_search_space;
	    overrule_search_space = 0;
	}
    else
	{
	    search_space = next_search_space;
	}

    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;

    switch(WhatLit)
    {
    case ALabelLit:
        descriptor.set(search_space, next_search_time, x, ml, mlhelp,l,lhelp, y,
                       Pattern, module, 0);
        break;
    default: break;
    }
}

void TDB::start_star( QUERY1 &descriptor, char *label)
{
    int search_space;
    if (overrule_search_space)
    {
	search_space = overrule_search_space;
	overrule_search_space = 0;
    }
    else
    {
	search_space = next_search_space;
    }

    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;

    descriptor.set(search_space,next_search_time,label,&Symbols, module, 0);
}



int TDB::get_tuple(QUERY &descriptor, TOID &found) {
/*
*  get an item from a query-descripto
*/
  return descriptor.next(found);
}

//void TDB::end_seek(QUERY &descriptor) {
/*
* end search-operation (free descriptor)
*/
//  descriptor.done();
//}

void TDB::set_transaction_time( TIMEPOINT now ) {
/*
*  set the transaction-timepoint (used as 'now')
*/
  transaction_time = now;
}

TIMEPOINT TDB::query_start_time( TOID id )
/*
*  query the start time of id 
*/
{
    return id.STime();
}

TIMEPOINT TDB::query_end_time( TOID id )
/*
*  query the end time of id
*/
{
    return id.ETime();
}





void TDB::SystemModule(TOID system_mod) {
/*
*   setzt das System-Modul
*
*   --->>>> Achtung <<<<---
*
*  es gibt nur einen Grund, diese Methode aufzurufen:
*    Beim Aufbau der Datenbank von SML0.prop fehlt
*    am Anfang noch das System-Modul-Objekt. Wenn
*    dieses per tell eingefuegt wird, muessen alle
*    Modulzugehoerigkeiten gesetzt werden.
*    Ist das Systemmodul in der Datenbank bereits vorhanden,
*    werden die Modulzugehoerigkeiten bereits beim Laden
*    gesetzt und wuerden hier ueberschrieben werden!!!!
*
*/


  printf("TDB: Setting module tag of current database objects to System ...\n");


  TOID toid;
  TOIDSetIterator i;
  i=akt.begin();
  while (i != akt.end()) {
    toid = (*i).second;               // get the toid
    toid.Update_Module(system_mod);
    telosfile.clear();
    telosfile.seekp(DISK_OFFSET+toid.GetId()*sizeof(TOIO),ios::beg);
    TOIO toio(toid,ACTUAL_DB);
    telosfile << toio;
    i++;
  }
  i=hist.begin();
  while (i != hist.end()) {
    toid =(*i).second;               // get the toid
    toid.Update_Module(system_mod);
    telosfile.clear();
    telosfile.seekp(DISK_OFFSET+toid.GetId()*sizeof(TOIO),ios::beg);
    TOIO toio(toid,HISTORY_DB);
    telosfile << toio;
    i++;
  }

  system_module = system_mod;
  next_module = system_mod;
  system_module.SetSystemModule(system_module);
  printf("TDB: module tag set successfully \n");
}

void TDB::set_module(TOID toid) {
    next_module = toid;
}

void TDB::set_overrule_module(TOID toid) {
    is_overrule_module = 1;
    overrule_module = toid;
}

void TDB::initialize_module(TOID toid) {
    toid.SetModule();
}

int TDB::new_export(TOID toid) {
    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;


    return module.NewExport(toid);
}

int TDB::delete_export(TOID toid) {
    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;


    return module.DeleteExport(toid);
}

int TDB::new_import(TOID toid) {
    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;


    return module.NewImport(toid);
}

int TDB::delete_import(TOID toid) {
    TOID module;
    if (is_overrule_module)
    {
	module = overrule_module;
	is_overrule_module = 0;
    }
    else module = next_module;


    return module.DeleteImport(toid);
}

int TDB::get_zaehler(TOID toid, int box, long &count)
{
    return stats.get_zaehler(toid,box,count);
}


void TDB::update_zaehler(TOID toid, int box, long &count, int typ)
{
  int search_space;
  TOID current;
  if (overrule_search_space)
  {
      search_space = overrule_search_space;
      overrule_search_space = 0;
  }
  else
  {
      search_space = next_search_space;
  }

  char select[30];
  TOID sys;


  int c2 = 0;

  if (box == BOX_IN_I)
  {
      strcpy(select,"Individual");
      select2toid(select,sys);
      if (toid==sys) c2 = SYSTEM_CLASS_INDIVIDUAL;
      strcpy(select,"Proposition=>Proposition");
      select2toid(select,sys);
      if (toid==sys) c2 = SYSTEM_CLASS_ISA;
      strcpy(select,"Proposition->Proposition");
      select2toid(select,sys);
      if (toid==sys) c2 = SYSTEM_CLASS_INSTANCEOF;
      strcpy(select,"Proposition!attribute");
      select2toid(select,sys);
      if (toid==sys) c2 = SYSTEM_CLASS_ATTRIBUTE;
      strcpy(select,"Proposition");
      select2toid(select,sys);
      if (toid==sys) c2 = SYSTEM_CLASS_PROPOSITION;
  }

  if (c2)
  {
      TOIDSETSTL space, solution;
      SYMID symid;
      TOIDSetIterator ind;
      char cInstanceof[] = "*instanceof";
      char cIsa[] = "*isa";

      switch (c2) {
      case SYSTEM_CLASS_PROPOSITION:
	  if (search_space & ACTUAL_DB)
	      space |= akt;

	  if (search_space & TEMP_DB_TELL)
          {
	      space |= tmp1;
	      space |= tmp3;
	  }

          if (search_space & TEMP_DB_UNTELL)
              space |= tmp2;

	  if (search_space & HISTORY_DB)
	      space |= hist;
	  break;
      case SYSTEM_CLASS_INSTANCEOF:
	  if (Symbols.get_symb(cInstanceof,symid))
          {
	      space |= *(symid.get_uses());
	  }
	  break;
      case SYSTEM_CLASS_ISA:
	  if (Symbols.get_symb(cIsa,symid))
	  {
	      space |= *(symid.get_uses());
	  }
	  break;
      case SYSTEM_CLASS_ATTRIBUTE:
	  Symbols.get_attributes(space);
	  break;
      case SYSTEM_CLASS_INDIVIDUAL:
	  Symbols.get_individuals(space);
	  break;
      default:
	  break;
      }
      for (ind=space.begin();ind != space.end();ind++)
      {
      	   current=(*ind).second;
	  if (current.is_valid(next_search_time,search_space))
	      solution.add(current);
      }
      count = solution.length();
      stats.set_zaehler(toid,box,count);
  }
  else
  {
      if (typ == 1)
	  stats.update_zaehler(toid,box,count,next_search_time,search_space);
      else
	  stats.update_zaehler_wo_closure(toid,box,count,next_search_time,search_space);
  }
}


void TDB::update_histogramm(TOID toid, int dir)
{
  int search_space;
  if (overrule_search_space)
  {
      search_space = overrule_search_space;
      overrule_search_space = 0;
  }
  else
  {
      search_space = next_search_space;
  }
  stats.update_histogramm(toid,dir,next_search_time,search_space);
}

void TDB::update_histogramm(
    TOID toid, int dir,
    TOID src_restr, TOID dst_restr, int restr_dir)
{
  int search_space;
  if (overrule_search_space)
  {
      search_space = overrule_search_space;
      overrule_search_space = 0;
  }
  else
  {
      search_space = next_search_space;
  }
  stats.update_histogramm_with_class_restriction(
      toid,dir,src_restr,dst_restr,restr_dir,next_search_time,search_space);
}


Histogramm *TDB::get_histogramm(TOID toid, int dir)
{
    return stats.get_histogramm(toid,dir);
}


int TDB::delEntryOlderthan(TOIDSETSTL &toidset,TIMEPOINT deadline)
{
    int anzahl=0;
    TOID current;
    for (TOIDSetIterator i=toidset.begin();i != toidset.end();i++)
    {
    	current=(*i).second;
        if ((current.ETime()<deadline)||current.ETime()==deadline)
        {
            anzahl++;
                //printf("Clearing Entry %d (%s)...",anzahl,(toidset)(i).Lab().get_name());
            TOIDREF toidref;
            TOID toid=(*i).second;
            unused_ID.add(toid.GetId());  //ID als unused markieren
            Symbols.del(toid.Lab(),toid);  //toid-referenz aus symid (toid.lab) loeschen
            toidref.SetId(toid);
            toidtable->del(toidref);  // Hashtabelle aktualisieren
            if (!UnuseOnDisk(toid)) {printf("Unable to apply changes on disk!\n");return 0;}
            toid.destroy();
            toidset.del(toid);   // toid aus toidset loesche
                //printf("successful\n");
        }
    }
    return 1;
}


int TDB::updateStartTime(TOIDSETSTL &toidset,TIMEPOINT newtime,int setToUpdate)
{
    int anzahl=0;
    TOID current;
    TOIDSetIterator i;
    for (i=toidset.begin();i != toidset.end();i++)
    {
    	current=(*i).second;
            //Setzt die startzeiten auf newtime, falls stime<newtime
        if (current.STime() < newtime)
        {
            anzahl++;
            current.Update_StartTime(newtime);
            TOIO toio(current,setToUpdate);
            if (Symbols.get_persistency_level() == PERSISTENT)
            {
            telosfile.clear();
            telosfile.seekp(DISK_OFFSET+current.GetId()*sizeof(TOIO),ios::beg);
            telosfile << toio;
            }
        }
    }
//    printf("%d starttimes were changed in set %d.\n",anzahl,set);
    return 1;
}

int TDB::UnuseOnDisk(TOID toid)
{
    if (Symbols.get_persistency_level() == PERSISTENT) 
    {
      SYMID symid=toid.Lab();
//    printf("%s mit %d referenzen\n",toid.Lab().get_name(),symid.get_uses()->length());
      if (symid.empty())
      {
            //Loescht den Symid (wenn ohne referenzen)
            //aus der Symbolstabelle und aus dem File (ID=UNUSED)
          if (!Symbols.del(symid)) {printf("ups\n");return 0;}
      }
        //Loescht den Toid aus dem File (ID=UNUSED)
      int ID=toid.GetId();
      TOIO toio(toid,UNUSED);
      telosfile.clear();
      telosfile.seekp(DISK_OFFSET+ID*sizeof(TOIO),ios::beg);
      telosfile << toio;
    }
    return 1;
}


void TDB::delete_history_db(TIMEPOINT timepoint)
{
    delEntryOlderthan(hist,timepoint);
    updateStartTime(hist,timepoint,HISTORY_DB);
    updateStartTime(akt,timepoint,ACTUAL_DB);
}



/* persistency_level is maintained in SYMTBL
   ticket #319
*/
void TDB::set_persistency_level(int newlevel)
{
    Symbols.set_persistency_level(newlevel);

}







