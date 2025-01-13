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
/****************************************************************
*
*   SYMID.cc
*
*   Creation:      15.5.1993
*   Created by:    Thomas List
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   Version 0.1
*
*
****************************************************************/

#include "TOIDSETSTL.h"
#include "SYMID.h"

#include <string.h>
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* an empty set for error-results! */

static TOIDSETSTL empty_set;

/***********************   S Y M B O L   *********************/


SYMBOL::SYMBOL(char* label) 
{
/*
 *   constructor: copies the string given by label into name
 */
    
    name = new char[strlen(label)+1]; // +1: terminating 0
    strncpy(name,label,strlen(label)+1);
    id = filepos = UNDEF;             // just to habe something done
    quersumme=0;
    for (unsigned int a=0;a<strlen(name);a++) quersumme+=(unsigned short)name[a];
}

SYMBOL::~SYMBOL() 
{
    delete[] name;
}

int SYMBOL::rename(char *newlabel) 
{
    // need changes for new SYMTBL
    delete[] name;
    name = new char[strlen(newlabel)+1];
    strncpy(name,newlabel,strlen(newlabel)+1);
    quersumme=0;
    for (unsigned int a=0;a<strlen(name);a++) quersumme+=(unsigned short)name[a];
    return 1;
}

int SYMBOL::add(TOID toid) 
{
/*
 *    adds a toid to the uses set
 */
    //printf("Adding to SymTable:[%s,%ld, ]\n",get_name(),toid.GetId());
    uses.add(toid);
    return 1;	
 /*
    Pix ind = uses.add(toid);
    if (ind==0) return 0;
    else return 1;
*/
}


int SYMBOL::del(TOID toid) 
{
/*
 *   delets a toid from the uses set
 */

    uses.del(toid);
    return 1;
}


int SYMBOL::get_length() 
{
/*
 *  returns the length of the lable, just to give someone a chance
 *  to use get_name! (+1 for terminating 0)
 */
    if (!name) return 0;
    return strlen(name)+1;
}

int SYMBOL::get_sum() const
{
    return quersumme;
}


int SYMBOL::get_name(char* label) const 
{
/*
 *   returns the label, the string pointed to by label must be
 *   big enough to hold the text
 *   returns 0 if name is empty
 */

    strcpy(label,name);
    return name[0] == 0;
}

// char *SYMBOL::get_name()
// {
//     return name;
// }

int SYMBOL::get_type() 
{
/*
 *  returns ISA, INSTANCEOF or NONE
 */
    if (!strcmp(name,"*isa")) return ISA;
    if (!strcmp(name,"*instanceof")) return INSTANCEOF;
    return NONE;
}



TOIDSETSTL* SYMBOL::get_uses() 
{
/*
 *  returns the uses set
 *  the result is 0 if uses contains no elements
 */
    return &uses;
}

int SYMBOL::get_uses(TOIDSETSTL& toidset) 
{
/*
 *  returns the uses set
 *  the result is 0 if uses contains no elements
 */
    TOID toid;
    toidset.clear();
    for(TOIDMap::iterator Iterator=uses.begin(); Iterator != uses.end(); Iterator++){
    	toid = (*Iterator).second;
    	toidset.add(toid);
    }
    return !uses.empty();
}


int SYMBOL::empty() 
{
/*
 *   returns, if uses is empty
 */
    
    return uses.empty();
}

long SYMBOL::setfilepos(long newpos) 
{
/*
 *  sets the filepos-nr.
 */
    return filepos=newpos;
}

long SYMBOL::getfilepos() 
{
/*
 *  returns the filepos-nr.
 */
    return filepos;
}

long SYMBOL::setid(long newid) 
{
/*
 *  sets the filepos-nr.
 */
    return id=newid;
}

long SYMBOL::getid() 
{
/*
 *  returns the filepos-nr.
 */
    return id;
}


void SYMBOL::test() 
{
    printf("SYMBOL: test.\ntext: %s.\nfilepos: %ld\nid: %ld\ntoidset: [",name,getfilepos(),getid());
    uses.test();
    printf("].\n");
}


/*************************   S Y M I D   ***********************/

SYMID::SYMID (char *label) 
{
/*
 *   creates a new(!) SYMBOL with text label
 *   the constructor allocates memory that is not deallocated
 *   by the destructor but by the method destroy()
 *   the programmer has to take care of that!
 */
    SymbolObj = new SYMBOL(label);
}


SYMID::SYMID (TOID toid) 
{
/*
 *  create a new(!) SYMBOL with the text given by the SYMBOL
 *  of the TOID
 *  It is not a good Idea to use this! Too much copying of
 *  strings!
 */
    char* s;
	s=(char*)malloc(toid.Lab().get_length());
    toid.Lab().get_name(s);
    SymbolObj = new SYMBOL(s);
}

SYMID::SYMID(const SYMID& symid) 
{
/*
 *  this stuff is dangerous to use!
 *  I don't know anymore why it is here!
 *  It's called a hell of times when automatically casting!
 *
 *  creates a new SYMID and sets the pointer to the symbol 
 *  pointed to by the other symid
 */
    SymbolObj = symid.SymbolObj;
}

//SYMID::SYMID(SYMID& symid) 
//{
/*
 *  this stuff is dangerous to use!
 *  I don't know anymore why it is here!
 *
 *  creates a new SYMID and sets the pointer to the symbol 
 *  pointed to by the other symid
 */
//    SymbolObj = symid.SymbolObj;
//}


SYMID::SYMID () 
{
/*
 *  create a SYMBOL with 0-string as text
 */
    
  SymbolObj = 0;
}

int SYMID::rename(char *newlabel) 
{
/*
 *  the rename function
 *  not much to say
 */
    if (SymbolObj) return SymbolObj->rename(newlabel);
    return 0;
}

int SYMID::add(TOID toid) 
{
/*
 *   add a TOID to the uses set of the SYMBOL by calling 
 *   the add-method of symbol
 */
    if (SymbolObj) return SymbolObj->add(toid);
    return 0;
}


int SYMID::del(TOID toid) 
{
/*
 *   delete a TOID from the uses set of the SYMBOL by calling 
 *   the del-method of symbol
 */
    
  return SymbolObj->del(toid);
}

int SYMID::empty() 
{
/*
 *   returns if the uses-set of the symbol is empty by calling 
 *   the empty-method of symbol
 */

  return SymbolObj->empty();
}


long SYMID::setfilepos(long newpos) 
{
/*
 *  sets the filepos-nr.
 */
  return SymbolObj->setfilepos(newpos);
}


long SYMID::getfilepos() 
{
/*
 *  returns the filepos-nr.
 */
    return SymbolObj->getfilepos();
}

long SYMID::setid(long newid) 
{
/*
 *  sets the filepos-nr.
 */
  return SymbolObj->setid(newid);
}


long SYMID::getid() 
{
/*
 *  returns the filepos-nr.
 */
    return SymbolObj->getid();
}


int SYMID::destroy() 
{
/*
 *   destroy a SYMBOL (deallocates the memory)
 *   if the uses set of the SYMBOL poited to is not empty
 *   an error is returned
 */

    if (!SymbolObj->empty()) return 0;
    delete SymbolObj;
    SymbolObj = 0;
    return 1;
}



TOIDSETSTL* SYMID::get_uses() 
{
/*
 *  returns the uses-set of SymbolObj
 */
    
    if (!SymbolObj) return &(empty_set);
    return SymbolObj->get_uses();
}


int SYMID::get_uses(TOIDSETSTL& toidset) 
{
/*
 *  returns the uses-set of SymbolObj
 */
    
    if (!SymbolObj) return 0;
    return SymbolObj->get_uses(toidset);
}



int SYMID::get_length()
{
/*
 * returns the length of the string
 */
    if (!SymbolObj) return 0;
    return SymbolObj->get_length();
}

int SYMID::get_sum() const
{
    if (!SymbolObj) return 0;
    return SymbolObj->get_sum();
}

int SYMID::get_name(char *s) 
{
/*
 *   returns the text of SymbolObj
 */
    if (!SymbolObj) return 0;
    return SymbolObj->get_name(s);
}

// char *SYMID::get_name()
// {
//    if (!SymbolObj) return NULL;
//    return SymbolObj->get_name();
// }

int SYMID::get_type() 
{
/*
 *  ISA, INSTANCEOF or NONE
 */
    if (!SymbolObj) return -1;
    return SymbolObj->get_type();
}




int SYMID::get_savestring(char *s) 
{
/*
 *   returns a string, this string is used as identifier 
 *   for the symbol when saving the database to disk
 */
    sprintf(s,"%18.0ld",getfilepos());
    return 1;
}

SYMID& SYMID::operator=(const SYMID &symid) 
{
/*
 *  SYMID assignment
 */
    
    SymbolObj = symid.SymbolObj;
    return *this;
}


int SYMID::operator==(const SYMID &symid) 
{
/*
 *   compares two symids, returns 1 if equal
 */
    
/*
    char s1[get_length()],s2[symid.get_length()];
    get_name(s1);
    symid.get_name(s2);
*/
    if (!symid.get_name() || !get_name()) return 0;
    if (get_sum()==symid.get_sum())
        return (!strcmp(get_name(),symid.get_name()));
    else return 0;
}


int SYMID::operator<=(const SYMID &symid) 
{
/*
 *   compares two symids to <=
 */
/*    
    char s1[get_length()],s2[symid.get_length()];
    get_name(s1); 
    symid.get_name(s2);
*/
    if (!symid.get_name() || !get_name()) return 0;
   
    return (strcmp(get_name(),symid.get_name()) <= 0);
}
