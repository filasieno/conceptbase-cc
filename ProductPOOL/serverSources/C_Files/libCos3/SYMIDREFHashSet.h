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
*   SYMIDREFHashSet.h
*
**********************************************************************/

/* set GCC_VERSION of Gnu Compiler; set to 0 if other compiler is used */
#ifdef __GNUC__
#define GCC_VERSION (__GNUC__ * 10000 \
                               + __GNUC_MINOR__ * 100 \
                               + __GNUC_PATCHLEVEL__)
#else
#define GCC_VERSION 0
#endif


#ifndef _SYMIDREFHashSet
#define _SYMIDREFHashSet


#ifndef WIN32
#ifdef __clang__
  #include <tr1/unordered_map>
#elif GCC_VERSION < 40300
  #include <hash_map.h>
#else
  #include <tr1/unordered_map>
#endif 
#else
#include <hash_map>
#endif

#include <SYMIDREF.h>
#include <algorithm>
#include <stdio.h>

using namespace std;


/** long-Menge.\\
   Die Mengenoperatoren sind die der Gnu g++ Library
   */
   
struct eqlong1
{
  bool operator()(const long ref1,const long ref2) const
  {
    return ref1==ref2;
  }
};

#ifdef __clang__
typedef std::tr1::unordered_map<long,SYMIDREF, std::tr1::hash<long>, eqlong1> SYMIDREFSet;
#elif GCC_VERSION < 40300
typedef hash_map<long,SYMIDREF, hash<long>, eqlong1> SYMIDREFSet;
#else
typedef std::tr1::unordered_map<long,SYMIDREF, std::tr1::hash<long>, eqlong1> SYMIDREFSet;
#endif


class SYMIDREFHashSet{
private:
	SYMIDREFSet data;
	SYMIDREFSet getSTLSet() {return data;}
public:
	SYMIDREFHashSet(){};
	SYMIDREFSet::iterator begin() {return data.begin();}
	
	SYMIDREF first();
	
	SYMIDREFSet::iterator end() {return data.end();}	
	
	int length();
	
	
	int empty();
	
	void add(SYMIDREF& item);
	
	int  contains(SYMIDREF& item);
	
	void del(SYMIDREF& item);
	
	void clear();
		
	SYMIDREF next(SYMIDREFSet::iterator i);
	
	
	SYMIDREFSet::iterator   seek(SYMIDREF& item);
	
	// This function is just for code compatibility
	SYMIDREF  operator () (SYMIDREFSet::iterator i) {return (*i).second;}
  	
};

inline SYMIDREFSet::iterator SYMIDREFHashSet::seek(SYMIDREF& item)
{
    	SYMIDREFSet::iterator i=data.find(item.GetId());
    	return i;
}
inline SYMIDREF SYMIDREFHashSet::next(SYMIDREFSet::iterator i){
	i++;
	return (*i).second;
}

inline int SYMIDREFHashSet::length(){
	return data.size();
}
inline int SYMIDREFHashSet::empty(){
	return data.empty();
}
inline void SYMIDREFHashSet::add(SYMIDREF& item){
	data.insert(SYMIDREFSet::value_type(item.GetId(),item));
}
inline int SYMIDREFHashSet::contains(SYMIDREF& item){
	SYMIDREFSet::iterator position=data.find(item.GetId());
	if(position != data.end())
		return 1;
	else
		return 0;
}
inline void SYMIDREFHashSet::del(SYMIDREF& item){
	SYMIDREFSet::iterator position=data.find(item.GetId());
	if(position!= data.end())
		data.erase(position);
}
inline void SYMIDREFHashSet::clear(){
	data.clear();	
}

inline SYMIDREF SYMIDREFHashSet::first(){
	SYMIDREFSet::iterator i=data.begin();
	return (*i).second;
}

#endif
