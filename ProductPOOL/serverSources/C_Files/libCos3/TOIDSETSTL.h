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
/**********************************************************************
*
*   TOIDSETSTL.h
*
**********************************************************************/

#ifndef _TOIDSETSTL
#define _TOIDSETSTL

#include "TOID.h"
#include <map>
#include <algorithm>
#include <stdio.h>

using namespace std;

/** TOID-Menge.\\
   Die Mengenoperatoren sind die der Gnu g++ Library
   */
   
struct TOIDcmp
{
  bool operator()(long item1,long item2) const
  {
    return item1<item2;
  }
};

typedef map<long,TOID,TOIDcmp> TOIDMap;

typedef TOIDMap::iterator TOIDSetIterator;

class TOIDSETSTL{
private:
	TOIDMap data;
	TOIDMap getSTLSet() {return data;}
public:
	TOIDSETSTL(){};
	TOIDSetIterator begin() {return data.begin();}
	
	TOID first();
	
	TOIDSetIterator end() {return data.end();}	
	int length();
	
	
	int empty();
	
	void add(TOID item);
	
	int  contains(TOID item);
	
	void del(TOID& item);
	
	void clear();
		
	TOID next(TOIDSetIterator i);
	
	void dump();
	
	void test();
	
	TOIDSetIterator   seek(TOID& item);
	
	// This function is just for code compatibility
	TOID&          	      operator () (TOIDSetIterator i) { return (*i).second;}
	
	void                  operator |= (TOIDSETSTL& b); // add all items in b     (union)
  	void                  operator -= (TOIDSETSTL& b); // delete items also in b (difference)
  	void                  operator &= (TOIDSETSTL& b); // delete items not in b  (intersection)

  	int                   operator == (TOIDSETSTL& b);
  	int                   operator != (TOIDSETSTL& b);
  	int                   operator <= (TOIDSETSTL& b); 
  	
 	/** Erzeugt die Indexstruktur. Dabei werden die long-Werte die in den TOID's
      	der src- und dst-Komponenten gespeichert sind in echte TOID's umgewandelt.\\
      	REWORK: hier sollte die Hash-Tabelle eingesetzt werdern
      	*/
      	void update();
    	
    	/// L\"oscht alle Telos-Objekte der Menge aus dem Speicher
	void destruct();
	
};

inline TOIDSetIterator TOIDSETSTL::seek(TOID& item)
{
    TOIDSetIterator i=data.find(item.GetId());
    return i;
}
inline TOID TOIDSETSTL::next(TOIDSetIterator i){
	i++;
	return (*i).second;
}
inline int TOIDSETSTL::operator <= (TOIDSETSTL& b){
	if( this->length() <= b.length())
		return 1;
	else
		return 0;
}

/*inline int TOIDSETSTL::operator == (TOIDSETSTL& b){
	if(data==b.getSTLSet())
		return 1;
	else	
		return 0;
}
inline int TOIDSETSTL::operator != (TOIDSETSTL& b){
	if(data==b.getSTLSet())
		return 0;
	else	
		return 1;
}
*/
inline void TOIDSETSTL::operator |= (TOIDSETSTL& b){
	TOIDMap tmp;
	set_union(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline void TOIDSETSTL::operator -= (TOIDSETSTL& b){
	TOIDMap tmp;
	set_difference(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline void TOIDSETSTL::operator &= (TOIDSETSTL& b){
	TOIDMap tmp;
	set_intersection(data.begin(), data.end(), b.begin(), b.end(),
                 inserter(tmp, tmp.begin()));
        data.clear();
        data=tmp;
}
inline int TOIDSETSTL::length(){
	return data.size();
}
inline int TOIDSETSTL::empty(){
	return data.empty();
}
inline void TOIDSETSTL::add(TOID item){
	data.insert(TOIDMap::value_type(item.GetId(),item));
}
inline int TOIDSETSTL::contains(TOID item){
	TOIDSetIterator position=data.find(item.GetId());
	if(position != data.end())
		return 1;
	else
		return 0;
}
inline void TOIDSETSTL::del(TOID& item){
	TOIDSetIterator position=data.find(item.GetId());
	if(position!= data.end())
		data.erase(position);
}
inline void TOIDSETSTL::clear(){
	data.clear();	
}

inline TOID TOIDSETSTL::first(){
	TOIDSetIterator Iterator=data.begin();
	return (*Iterator).second;
}

#endif
