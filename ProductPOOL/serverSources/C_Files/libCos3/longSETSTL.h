/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*   longSETSTL.h
*
**********************************************************************/

#ifndef _longSETSTL
#define _longSETSTL

#include <set>
#include <algorithm>
#include <stdio.h>

using namespace std;

/** long-Menge.\\
   Die Mengenoperatoren sind die der Gnu g++ Library
   */
   
struct longcmp
{
  bool operator()(long item1,long item2) const
  {
    return item1<item2;
  }
};

typedef set<long,longcmp> LongSet;

class longSETSTL{
private:
	LongSet data;
	LongSet getSTLSet() {return data;}
public:
	longSETSTL(){};
	LongSet::iterator begin() {return data.begin();}
	
	long first();
	
	LongSet::iterator end() {return data.end();}	
	
	int length();
	
	
	int empty();
	
	void add(long item);
	
	int  contains(long item);
	
	void del(long item);
	
	void clear();
		
	long next(LongSet::iterator i);
	
	
	LongSet::iterator   seek(long item);
	
	// This function is just for code compatibility
	long  operator () (LongSet::iterator i) { return (*i);}
  	
};

inline LongSet::iterator longSETSTL::seek(long item)
{
    LongSet::iterator i=data.find(item);
    return i;
}
inline long longSETSTL::next(LongSet::iterator i){
	i++;
	return (*i);
}

inline int longSETSTL::length(){
	return data.size();
}
inline int longSETSTL::empty(){
	return data.empty();
}
inline void longSETSTL::add(long item){
	data.insert(item);
}
inline int longSETSTL::contains(long item){
	LongSet::iterator position=data.find(item);
	if(position != data.end())
		return 1;
	else
		return 0;
}
inline void longSETSTL::del(long item){
	LongSet::iterator position=data.find(item);
	if(position!= data.end())
		data.erase(position);
}
inline void longSETSTL::clear(){
	data.clear();	
}

inline long longSETSTL::first(){
	LongSet::iterator i=data.begin();
	return (*i);
}

#endif
