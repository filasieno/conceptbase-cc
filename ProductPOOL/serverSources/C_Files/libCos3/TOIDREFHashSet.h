/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
*   TOIDREFHashSet.h
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


#ifndef _TOIDREFHashSet
#define _TOIDREFHashSet


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

#include <TOIDREF.h>
#include <algorithm>
#include <stdio.h>

using namespace std;

/** long-Menge.\\
   Die Mengenoperatoren sind die der Gnu g++ Library
   */
   
struct eqlong
{
  bool operator()(const long ref1,const long ref2) const
  {
    return ref1==ref2;
  }
};

#ifdef __clang__
typedef std::tr1::unordered_map<long,TOIDREF, std::tr1::hash<long>, eqlong> TOIDREFSet;
#elif GCC_VERSION < 40300
typedef hash_map<long,TOIDREF, hash<long>, eqlong> TOIDREFSet;
#else
typedef std::tr1::unordered_map<long,TOIDREF, std::tr1::hash<long>, eqlong> TOIDREFSet;
#endif


class TOIDREFHashSet{
private:
	TOIDREFSet data;
	TOIDREFSet getSTLSet() {return data;}
public:
	TOIDREFHashSet(){};
	TOIDREFSet::iterator begin() {return data.begin();}
	
	TOIDREF first();
	
	TOIDREFSet::iterator end() {return data.end();}	
	
	int length();
	
	
	int empty();
	
	void add(TOIDREF& item);
	
	int  contains(TOIDREF& item);
	
	void del(TOIDREF& item);
	
	void clear();
		
	TOIDREF next(TOIDREFSet::iterator i);
	
	
	TOIDREFSet::iterator   seek(TOIDREF& item);
	
	// This function is just for code compatibility
	TOIDREF  operator () (TOIDREFSet::iterator i) { return (*i).second;}
  	
};

inline TOIDREFSet::iterator TOIDREFHashSet::seek(TOIDREF& item)
{
    TOIDREFSet::iterator i=data.find(item.GetId());
    return i;
}
inline TOIDREF TOIDREFHashSet::next(TOIDREFSet::iterator i){
	i++;
	return (*i).second;
}

inline int TOIDREFHashSet::length(){
	return data.size();
}
inline int TOIDREFHashSet::empty(){
	return data.empty();
}
inline void TOIDREFHashSet::add(TOIDREF& item){
	data.insert(TOIDREFSet::value_type(item.GetId(),item));
}
inline int TOIDREFHashSet::contains(TOIDREF& item){
	TOIDREFSet::iterator position=data.find(item.GetId());
	if(position != data.end())
		return 1;
	else
		return 0;
}
inline void TOIDREFHashSet::del(TOIDREF& item){
	TOIDREFSet::iterator position=data.find(item.GetId());
	if(position!= data.end())
		data.erase(position);
}
inline void TOIDREFHashSet::clear(){
	data.clear();	
}

inline TOIDREF TOIDREFHashSet::first(){
	TOIDREFSet::iterator i=data.begin();
	return (*i).second;
}

#endif
