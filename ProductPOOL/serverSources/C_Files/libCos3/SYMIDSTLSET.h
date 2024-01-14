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
/**********************************************************************
*
*   SYMIDSTLSET.h
*
**********************************************************************/

#ifndef _SYMIDSTLSET
#define _SYMIDSTLSET

#include "SYMID.h"
#include <map>
#include <algorithm>
#include <stdio.h>

using namespace std;

/** SYMID-Menge.\\
   Die Mengenoperatoren sind die der Gnu g++ Library
   */
   
struct SYMIDcmp
{
  bool operator()(const char* s1, const char* s2) const
  {
    return strcmp(s1, s2) < 0;
  }
};

typedef map<char *,SYMID,SYMIDcmp> SYMIDMap;

class SYMIDSTLSET{
private:
	SYMIDMap data;
	SYMIDMap getSTLSet() {return data;}
public:
	SYMIDSTLSET(){};
	SYMIDMap::iterator begin() {return data.begin();}
	
	SYMID first();
	
	SYMIDMap::iterator end() {return data.end();}	
	int length();
	
	
	int empty();
	
	void add(SYMID& item);
	
	int  contains(SYMID& item);
	
	void del(SYMID& item);
	
	void clear();
		
	SYMID next(SYMIDMap::iterator i);
	
	void dump();
	
	SYMIDMap::iterator   seek(SYMID& item);
	
	// This function is just for code compatibility
	SYMID&          	      operator () (SYMIDMap::iterator i) { return (*i).second;}
	
	void                  operator |= (SYMIDSTLSET& b); // add all items in b     (union)
  	void                  operator -= (SYMIDSTLSET& b); // delete items also in b (difference)
  	void                  operator &= (SYMIDSTLSET& b); // delete items not in b  (intersection)

  	int                   operator == (SYMIDSTLSET& b);
  	int                   operator != (SYMIDSTLSET& b);
  	int                   operator <= (SYMIDSTLSET& b); 
  	
	
};

inline SYMIDMap::iterator SYMIDSTLSET::seek(SYMID& item)
{
    SYMIDMap::iterator i=data.find(item.get_name());
    return i;
}
inline SYMID SYMIDSTLSET::next(SYMIDMap::iterator i){
	i++;
	return (*i).second;
}
inline int SYMIDSTLSET::operator <= (SYMIDSTLSET& b){
	if( this->length() <= b.length())
		return 1;
	else
		return 0;
}

inline void SYMIDSTLSET::operator |= (SYMIDSTLSET& b){
	SYMIDMap tmp;
	set_union(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline void SYMIDSTLSET::operator -= (SYMIDSTLSET& b){
	SYMIDMap tmp;
	set_difference(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline void SYMIDSTLSET::operator &= (SYMIDSTLSET& b){
	SYMIDMap tmp;
	set_intersection(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline int SYMIDSTLSET::length(){
	return data.size();
}
inline int SYMIDSTLSET::empty(){
	return data.empty();
}
inline void SYMIDSTLSET::add(SYMID& item){
	data.insert(SYMIDMap::value_type(item.get_name(),item));
}
inline int SYMIDSTLSET::contains(SYMID& item){
	SYMIDMap::iterator position=data.find(item.get_name());
	if(position != data.end())
		return 1;
	else
		return 0;
}
inline void SYMIDSTLSET::del(SYMID& item){
	SYMIDMap::iterator position=data.find(item.get_name());
	if(position!= data.end())
		data.erase(position);
}
inline void SYMIDSTLSET::clear(){
	data.clear();	
}

inline SYMID SYMIDSTLSET::first(){
	SYMIDMap::iterator Iterator=data.begin();
	return (*Iterator).second;
}

#endif
