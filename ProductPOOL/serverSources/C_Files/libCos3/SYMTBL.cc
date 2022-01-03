/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
/****************************************************************
*
*   SYMTBL.cc
*
*   Creation:      15.5.1993
*   Created by:    Thomas List
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   Version 0.1
*
*
****************************************************************/

#include "SYMTBL.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
using namespace std;

#define SIZE 1024
#define IDSIZE 4

/***********************   SYMTBL  *****************************/


/* an empty set for error-results! */
static TOIDSETSTL empty_set;

SYMTBL::SYMTBL(char* filename) {
	open = 0;
	idtable = NULL;
	nextID=0;
	load(filename);
}


SYMTBL::SYMTBL() {
	open = 0;
	idtable = NULL;
	nextID=0;
}

SYMTBL::~SYMTBL() {
/*
*  destructor: clears memory from all dynamically allocated
*              memory
*
*  if (idtable) delete idtable;
*  symbols.clear();	    // delete sets from memory
*  unused_filepos.clear();
*  delete symfilename;
	*/
}

void SYMTBL::destroy()
{
	//Die SaveMethode hat ein Problem, wenn ein File OB.symbol.A (oder in der Folge OB.symbol.B..Z) exitiert
	//in diesem Fall kommt eine Fehlermeldung, wenn das File schreibgeschuetzt ist
    symfile.close();
    if (100-(int)((float)unused_filepos.length()/(float)symbols.length()*100)<100)
    {
		//        printf("Symbols use %f percent of OB.symbol\n",100-((float)unused_filepos.length()/(float)symbols.length()*100));
        printf("packing of OB.Symbol...\n");
        char zeichen=65;
        char* newname;
		newname=(char*)malloc(strlen(symfilename)+5);
        strcpy(newname,symfilename);
        fstream dummy;
        strcat(newname,".A");
        dummy.open(newname,ios::in);
        int counter=0;
		///maximal 25 Versuche eine Dateinamen zu finden...
        while ((!dummy.is_open()) && (counter<25)) {
            dummy.close();
            newname[strlen(newname)-1]=zeichen++;
            dummy.open(newname,ios::out|ios::binary);
            counter++;
        }
		//        printf("Writing %s\n",newname);
        if (!save(newname)) printf("Writing new Symbolfile fails. Changes not applied!");
        else {
            if (::rename(newname,symfilename)) printf("There was an error. Changes not applied!\n");
        }
    }
    unused_filepos.clear();
    if (idtable) delete idtable;
    symbols.clear();	    // delete sets from memory
    delete symfilename;
}


int SYMTBL::load(char *filename) {
/*
*  opens a symboltable:
*  reads existing symbols via symio and adds them to
*  the table
*  uses-entrys are not stored in the symbol-file
*  they have to be added via the use method
	*/

	if (open) return 0;                // tabel already open
	symfile.open(filename,ios::in|ios::out|ios::binary);
	if(!symfile.is_open()) {
		fprintf(stderr,"Could not load file with symbol table: %s\n",filename);
		return 0;
	}

	symfilename=new char[strlen(filename)+5];
	strcpy(symfilename,filename);
	// open file
	filesize = 0;                      // init filesize

	char* newlabel;
	long id;
	/*unsigned*/ char c;
	long filepos;

	int i;
	int error=0;

	int size = SIZE;
	newlabel = new char[SIZE];

	if(!idtable) idtable = new SYMIDREFHashSet();

	while (!symfile.eof())
	{
		id=0l;
		newlabel[0]=0;
		// there's always one iteration more than there are datas
		// to read the eof!
		filepos = symfile.tellg();
		// first: a few bytes with the ID, the the label itself
		for (i=0;i<IDSIZE&& symfile.get(c);i++)
		{
			if(c<0){
				id = (id << 8) + c + 256;
			}
			else{
				id = (id << 8) + c;
			}
		}


		if (id>=nextID) nextID=id+1;

		for (i=0;symfile.get(c) && c; i++)
		{
			if (i < size) {
				newlabel[i] = c;
			} else {
				char *hilfsstr = new char[size+SIZE];
				for (int k=0;k<size;k++)
				{
					hilfsstr[k] = newlabel[k];
				}
				hilfsstr[i] = c;
				delete[] newlabel;
				newlabel = hilfsstr;
				size += SIZE;
			}
		}
		if (i < size) {
			newlabel[i] = 0;
		} else {
			char *hilfsstr = new char[size+SIZE];
			for (int k=0;k<size;k++)
			{
				hilfsstr[k] = newlabel[k];
			}
			hilfsstr[i] = 0;
			delete[] newlabel;
			newlabel = hilfsstr;
			size += SIZE;
		}
		if (symfile.eof() && id)
		{
			fprintf(stderr,
				"error loading symbol table: eof missing.\n");
			error = 1;
			exit(2);
		}
		if (!strlen(newlabel) && (id != -1) )
		{
			// eof-found
		} else {
			if (id==-1) unused_filepos.add(filepos);
			else
			{
				SYMID symid(newlabel);
				symid.setfilepos(filepos);
				if (id > filesize) filesize = id;
				symid.setid(id);
				symbols.add(symid);
				SYMIDREF ref(symid);
				idtable->add(ref);
			}
		}
	}
	delete[] newlabel;

	open = 1;                           // marks tabel as open
	return 1;
}

int SYMTBL::load_done()
{
    if (idtable) delete idtable;
    idtable=NULL;
    persistency_level = PERSISTENT; // default
    return 0;
}

int SYMTBL::use(long id, TOID toid,SYMID& symid)
{
/*
*  mark a symbol as used by toid via filepos-nr.
*  (the filepos-nr. is saved to disk by the toid-structure)
	*/

    SYMIDREFSet::iterator ind;
    SYMIDREF search(id);
    if (!(idtable->contains(search)))
    {
        char* s = new char[100];
        sprintf(s,"unknown_symbol_%ld", id );
        create( s, symid );

		// very very dirty hack....
        printf("***\n*** symbol::use *** LabelID %ld not found -> creating dummy entry: %s\n***\n",id,s);
        long oldID = nextID;
        nextID = id;
        delete[] s;

        if( nextID < oldID )
        {
            nextID = oldID;
        }
        return mark_use(toid,symid);
    }
    ind=idtable->seek(search);
    symid =(*idtable)(ind).GetSymid();
    return mark_use(toid,symid);

}

int SYMTBL::mark_use(TOID toid, SYMID symid) {
	return symid.add(toid);
}

int SYMTBL::save(char *filename)
{
	//schreibt ein neues Symbolfile ohne Luecken (ID=-1)
    ofstream file;
    file.open(filename,ios::out);
    if (!file) {
#ifdef CB_TRACE
        printf("symbol::save *** Konnte File %s nicht oeffnen\n",filename);
#endif
        return 0;
    }

	//    printf("writing file %s (%d unused entries)...",symfilename,unused_filepos.length());
    if (!symbols.length()) return 0;
    for (SYMIDMap::iterator i=symbols.begin();i != symbols.end();i++)
    {
        (symbols)(i).setfilepos(file.tellp());
        long ID=(symbols)(i).getid();
        char *s=(symbols)(i).get_name();
		//        printf("schreibe eintrag: id=%ld label=%s\n",ID,s);
		char ch=(char) (ID/(256*256*256)) % 256;
        file.put( ch  );
        ch=(char) (ID/(256*256)) % 256;
        file.put( ch  );
        ch=(char) (ID/(256)) % 256;
        file.put( ch  );
        ch=(char) ID % 256;
        file.put( ch  );

        for (int a=0;a<=(signed)strlen(s);a++)
        {
            file.put(s[a]);
        }
    }
    file.close();
	//    printf("done\n");
    return 1;
}


int SYMTBL::create(char* label, SYMID& symid)
{
/*
*   adds a symbol to the symboltable, if the symbol is already
*   in the table the reference to the new toid will be added,
*   otherwise a new symbol will be added to the table
	*/


#if DLEVEL>10
    printf("SYMTBL::create(%s)\n",label);
#endif
    if (!open) return 0;

    SYMID search(label);
    SYMIDMap::iterator ind = symbols.seek(search);
    if (ind == symbols.end())
	{
		if (symfile.eof()) symfile.clear();  // clear an unwanted fail-flag
		symbols.add(search);                 // add then new SYMBOL to the table
		symfile.seekp(0,ios::end);           // filepos at end of file
		symid = search;
		symid.setfilepos(symfile.tellp());

		symid.setid(nextID);
		filesize=nextID;
		// printf("SYMTBL::create(%s) ==> %d\n",label,symid.getid());
		nextID++;

		char ch=(char) (filesize/(256*256*256)) % 256;
        	symfile.put( ch  );
        	ch=(char) (filesize/(256*256)) % 256;
        	symfile.put( ch  );
        	ch=(char) (filesize/(256)) % 256;
        	symfile.put( ch  );
        	ch=(char) filesize % 256;
        	symfile.put( ch  );

		char* s;
		s=(char*)malloc(symid.get_length());
		symid.get_name(s);
		for (int i=0;i<=(signed)strlen(s);i++)
		{
			symfile.put(s[i]);
		}
		symfile.flush();

		return 1;
	}
    search.destroy();
    symid=symbols(ind);

    return 1;
}


int SYMTBL::rename(char* newlabel, SYMID symid)
{
    int i;
    long l;

    if (!open) return 0;

    SYMIDMap::iterator ind = symbols.seek(symid);
    if (ind == symbols.end()) return 0;
    {
		SYMID search(newlabel);
		if (symbols.contains(search)) return 0;
    }
    SYMID help;
    help=symbols(ind);
    symbols.del(help);
    if (!help.rename(newlabel)) {
		symbols.add(help);
		return 0;
    }
    symbols.add(help);

    long fpos = help.getfilepos();
    if (symfile.eof()) symfile.clear();
    symfile.seekp(fpos,ios::beg);
    unused_filepos.add(fpos);
    l = -1;

    char ch=(char) (l/(256*256*256)) % 256;
    symfile.put( ch  );
    ch=(char) (l/(256*256)) % 256;
    symfile.put( ch  );
    ch=(char) (l/(256)) % 256;
    symfile.put( ch  );
    ch=(char) l % 256;
    symfile.put( ch  );

    if (symfile.eof()) symfile.clear();  // clear an unwanted fail-flag
    symfile.seekp(0,ios::end);           // filepos at end of file
    help.setfilepos(symfile.tellp());
    l = help.getid();

    ch=(char) (l/(256*256*256)) % 256;
    symfile.put( ch  );
    ch=(char) (l/(256*256)) % 256;
    symfile.put( ch  );
    ch=(char) (l/(256)) % 256;
    symfile.put( ch  );
    ch=(char) l % 256;
    symfile.put( ch  );

    for (i=0;i<=(signed)strlen(newlabel);i++)
	{
		symfile.put(newlabel[i]);
	}
    return 1;

}




int SYMTBL::destroy(char *label,TOID toid) {
/*
*   same function as del, only instead of the SYMID the lable
*   name is given - get the corresponding SYMID and call destroy
	*/
	if (!open) return 0;

	SYMID symid;
	if (get_symb(label,symid))        // get the symid
		return del(symid,toid);     // call delete
	return 0;
}


int SYMTBL::del(SYMID symid)
{
    long fpos = symid.getfilepos();
    symbols.del(symid);
    if (symid.destroy())
    {
        if (symfile.eof()) symfile.clear();
        unused_filepos.add(fpos);
        symfile.seekp(fpos,ios::beg);
        long l = -1;
		char ch=(char) (l/(256*256*256)) % 256;
		symfile.put( ch  );
		ch=(char) (l/(256*256)) % 256;
		symfile.put( ch  );
		ch=(char) (l/(256)) % 256;
		symfile.put( ch  );
		ch=(char) l % 256;
		symfile.put( ch  );
        return 1;
    }
	//  printf("try to delete not empty symid %s\n",symid.get_name());
    symbols.add(symid);
    return 0;
}


int SYMTBL::del(SYMID symid, TOID toid) {
/*
*   delete the toid from the used-by set of symid, if no toid is
*   using the symid afterwards, the symid is deleted
	*/


    /* unvollstaendig */
	if (!open) return 0;

	symid.del(toid);         // deleting the toid from the symbol-set
	return 1;

	/* in the moment the unused lable is left in the database */

	return 0;
}



int SYMTBL::get_symb(char *label, SYMID &symid) {
/*
*   gets the symid to the label - if the symbol does not exist,
*   an error is returned
	*/
	SYMID search(label);              // create an id to a symbol
	// with text label
	SYMIDMap::iterator ind = symbols.seek(search);   // find the symbol in the table
	search.destroy();                 // destroy the help-symbol
	if (ind == symbols.end()) return 0;               // return 0 if no symbol is found
	symid = symbols(ind);             // return the symid
	return 1;

}



int SYMTBL::get_name(SYMID symid,char *label) {
/*
*   gets the label of a symbol by calling a method of SYMID
*   the string pointed to by label must be big enough to hold
*   the new label
	*/
	return symid.get_name(label);
}




TOIDSETSTL* SYMTBL::name_uses(char *label) {
/*
*   same function as symb_uses, only instead of the SYMID the lable
*   name is given -returns the used-by set of the symid
	*/
	SYMID symid;
	if (get_symb(label,symid))
		return symid.get_uses();
	return &empty_set;
}

int SYMTBL::name_uses(char *label,TOIDSETSTL& toidset) {
/*
*   same function as symb_uses, only instead of the SYMID the lable
*   name is given -returns the used-by set of the symid
	*/

	SYMID symid;
	if (get_symb(label,symid))
		return symid.get_uses(toidset);
	toidset=empty_set;
	return 1;
}


TOIDSETSTL* SYMTBL::symb_uses(SYMID symid) {
/*
*   returns the used-by set of symid
	*/

	return symid.get_uses();
}


int SYMTBL::star_search(char *label,TOIDSETSTL& toidset) {
/*
* returns the union of the uses-sets connected to the
* symbols that fit label
*
* for the moment, label uses the * as MS-Dos does in
* filenames, a string has to fit the characters until
* the first occurance of *, then everything is allowed.
*
* for the future: a really extension to reg expressions
* could be useful
	*/

    int n=0;        // length of the first part of the string
    int star=0;     // a * is in the string
    char *s;
    for (s = label; *s && *s != '*'; s++) n++;
    if (*s == '*') star=1;
    for (SYMIDMap::iterator ind = symbols.begin();ind != symbols.end();ind++)
	{
		if (!(star?
			strncmp(symbols(ind).get_name(),label,n):
		strcmp(symbols(ind).get_name(),label)))
			toidset |= *(symbols(ind).get_uses());
	}
    return !toidset.empty();
}

int SYMTBL::symb_uses(SYMID symid, TOIDSETSTL& toidset) {
/*
*   returns the used-by set of symid
	*/

	return symid.get_uses(toidset);
}


void SYMTBL::get_attributes(TOIDSETSTL& toidset)
/*
*  returns all toid's that are "ConceptBase"-Attributes
*/

{
    TOID toid;
    for (SYMIDMap::iterator ind = symbols.begin();ind != symbols.end();ind++)
    {
		if (symbols(ind).get_type() != NONE)
			continue;
		TOIDSetIterator ind2 = symbols(ind).get_uses()->begin();
		if (ind2 != symbols(ind).get_uses()->end())
		{
			toid = (*ind2).second;
			if (! (toid == toid.Src() && toid == toid.Dst()))
				toidset |= *(symbols(ind).get_uses());
		}
    }
}

void SYMTBL::get_individuals(TOIDSETSTL& toidset)
/*
*  returns all toid's that are "ConceptBase"-Attributes
*/

{
    TOID toid;
    for (SYMIDMap::iterator ind = symbols.begin();ind != symbols.end();ind++)
    {
		if (symbols(ind).get_type() != NONE)
			continue;
		TOIDSetIterator ind2 = symbols(ind).get_uses()->begin();
		if (ind2 != symbols(ind).get_uses()->end())
		{
			toid = (*ind2).second;
			if (toid == toid.Src() && toid == toid.Dst())
				toidset |= *(symbols(ind).get_uses());
		}
    }
}



void SYMTBL::show_set() {
/*
*  test-methods, prints the table to the screen
	*/
	printf("SHOW-SET.\n");
	TOIDSETSTL tmp;
	SYMIDMap::iterator ind;
	for (ind = symbols.begin();ind != symbols.end() ;ind++) {
		printf("%ld %s\n",symbols(ind).getid(),symbols(ind).get_name());
		symbols(ind).get_uses(tmp);
		tmp.test();
	}
	printf("END OF SHOW-SET.\n");
}


/* maintain the persistency_level; if persistency_level=NONPERSISTENT
   do not store updates on disk (telosfile)
   ticket #319
*/
void SYMTBL::set_persistency_level(int newlevel)
{
    if (newlevel == 128)   // error in data can occur, 128 shall be interpretet like 0
       newlevel = NONPERSISTENT;
    if (newlevel > MAXPERSISTENCYLEVEL) 
       newlevel = MAXPERSISTENCYLEVEL;
//    printf("SYMTBL.cc: old persistency level %d \n",persistency_level);fflush(stdout);
//    printf("SYMTBL.cc: setting new persistency level %d \n",newlevel);fflush(stdout);
    if ((newlevel >= 0) && (newlevel <= MAXPERSISTENCYLEVEL))
	persistency_level = newlevel;
    else
	printf("SYMTBL.cc: wrong persistency level: %d (max=%d)\n",persistency_level,MAXPERSISTENCYLEVEL);fflush(stdout);

}


int SYMTBL::get_persistency_level()
{
    return persistency_level;
}

/* return the next free identifier (= key in the symbol table)
*/
long SYMTBL::get_nextID()
{
    return nextID;
}


