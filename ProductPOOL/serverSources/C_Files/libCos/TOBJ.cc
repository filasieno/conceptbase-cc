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
/**********************************************************************
*
*   TOBJ.cc
*
*   Creation:      4.1.1993
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   8.7.1993
*   Changed by:    Thomas List
*   Version 2.1a
*
*
**********************************************************************/

#include "TOBJ.h"
#include "TDB.defs.h"

TOIDSET TOBJ::emptyset;
TOID TOBJ::system_module;

TOBJ::TOBJ () {  //  Konstruktor 1
/*
*  create a TOBJ with empty entries:
*  src,dst,Label are 0-Pointers,
*  StartTime, EndTime, id are 0  
*/
  id = 0;
  istemp=0;
  IofIn=IofOut=IsaIn=IsaOut=AtrIn=AtrOut=NULL;
  module_sets = NULL;
}

TOBJ::TOBJ ( SYMID symid, long NewIndex ) {    
/*
*  create a TOBJ with preset id and Label-entry
*/
  id = NewIndex;
  Label = symid;
  istemp=0;
  IofIn=IofOut=IsaIn=IsaOut=AtrIn=AtrOut=NULL;
  module_sets = NULL;
}

void TOBJ::Update_Label(SYMID symid) {
/*
*  Update the label
*/
  Label = symid;
}

void TOBJ::Update (TOID newsrc, TOID newdst) {
/*
*  Update the src and dst - entries
*/
  src = newsrc;
  dst = newdst;
}

void TOBJ::Update (long newsrc, long newdst) {
/*
*   
*  
*/
  src.set(newsrc);
  dst.set(newdst);
}

void TOBJ::Update_StartTime (TIMEPOINT newstart) {
/*
*  Update StartTime
*/
  StartTime = newstart;
}

void TOBJ::Update_EndTime (TIMEPOINT newend) {
/*
*  Update EndTime
*/
  //  setzt die Endzeit des Objekts
  EndTime = newend;
}


void TOBJ::Update_index (int set, TOID toid) {
/*
* adds the TOID to the intern sets
*/
  switch (toid.Lab().get_type()) {
  case ISA:
       if (set==IN)  create_if_NULL(&IsaIn)->add(toid);
       if (set==OUT) create_if_NULL(&IsaOut)->add(toid);
       break;
  case INSTANCEOF:
       if (set==IN) create_if_NULL(&IofIn)->add(toid);
       if (set==OUT) create_if_NULL(&IofOut)->add(toid);
       break;
  case NONE:
       if (set==IN) create_if_NULL(&AtrIn)->add(toid);
       if (set==OUT) create_if_NULL(&AtrOut)->add(toid);
       break;
  }
}

void TOBJ::Del_index (int set, TOID toid) {
/*
*  deletes the TOID from the intern sets
*/
  switch (toid.Lab().get_type()) {
  case ISA:
       if (set==IN) { IsaIn->del(toid); delete_if_empty(&IsaIn); }
       if (set==OUT) { IsaOut->del(toid); delete_if_empty(&IsaOut); }
       break;
  case INSTANCEOF:
       if (set==IN) { IofIn->del(toid); delete_if_empty(&IofIn); }
       if (set==OUT) { IofOut->del(toid); delete_if_empty(&IofOut); }
       break;
  case NONE:
       if (set==IN) { AtrIn->del(toid); delete_if_empty(&AtrIn); }
       if (set==OUT) { AtrOut->del(toid); delete_if_empty(&AtrOut); }
       break;
  }
}

void TOBJ::SetTemp(int whattmp) {
    istemp = whattmp;
}

void TOBJ::UnsetTemp() {
    istemp = 0;
}

TIMELINE TOBJ::Valid() {
/*
*  returns the Timeline of the object
*  (time  while the object is actual)
*/
  return TIMELINE(StartTime,EndTime);
}

int TOBJ::is_valid(TIMEPOINT point, int set, TOID module, int Pattern, int strict)
{
    if (Pattern & FREE_MODULE) 
	return is_valid(point,set);
    if (strict) 
	return is_strictly_valid(point,set,module);
    return is_valid(point,set,module);
}

int TOBJ::is_valid(TIMEPOINT point, int set) 
/* 
 * checks if the object is valid in the set at the timepoint 
 * it is important to check if the object is in tmp, the rest
 * can be checked via the timeline of the object.
*/
{


    if ((istemp & TEMP_DB_TELL) && !(set & TEMP_DB_TELL))
        return 0;

    if ((istemp & TEMP_DB_UNTELL) && !(set & TEMP_DB_UNTELL))
        return 0;

    int help=0;

    if (set & ACTUAL_DB)
        help = 1;
    if (set & HISTORY_DB)
        help = 1;
    
    if ((set & TEMP_DB_TELL) && (istemp & TEMP_DB_TELL))
        help = 1;
    
    if ((set & TEMP_DB_UNTELL) && (istemp & TEMP_DB_UNTELL))
        help = 1;

    if (!help)
        return 0;
    
    return Valid().Is_In_Interval(point);
}


int TOBJ::is_strictly_valid(TIMEPOINT point, int set, TOID module)
{

    return is_valid(point,set) && module == reverse_contains;
}


int TOBJ::is_valid(TIMEPOINT point, int set, TOID module) 
/* 
 * checks if the object is valid in the set at the timepoint 
 * it is important to check if the object is in tmp, the rest
 * can be checked via the timeline of the object.
*/
{
    if (!is_valid(point,set))
	return 0;

//    if (!module.is_valid(point,TEMP_DB|ACTUAL_DB|HISTORY_DB ))
//	return 0;


    Pix ind,ind2;
    TOID toid,toid2;;

    if ((reverse_contains==module || reverse_contains==system_module))
	return 1;


    if (module.Import().length()) 
    {
	for (ind=module.Import().first();ind;module.Import().next(ind))
	    {
		toid = module.Import()(ind);
		if (!toid.is_valid(point,TEMP_DB_TELL|ACTUAL_DB|HISTORY_DB))
		    continue;

		toid = toid.Dst();
		if (!toid.Export().length())
		    continue;

		for (ind2=toid.Export().first();ind2;toid.Export().next(ind2))
		    {
			toid2 = toid.Export()(ind2);
			if (toid2.Dst()==(this) && toid2.is_valid(point,TEMP_DB_TELL|ACTUAL_DB|HISTORY_DB)) 
			    return 1;
		    }
	    }
    }


    if (!(module.GetModule() == system_module))
	return is_valid(point,set,module.GetModule());

    return 0;
}


TIMEPOINT TOBJ::STime() {
  return StartTime;
}

TIMEPOINT TOBJ::ETime() {
  return EndTime;
}


TOIDSET& TOBJ::IofI() { 
  return *set_or_empty(IofIn); 
}
  
TOIDSET& TOBJ::IofO() { 
  return *set_or_empty(IofOut); 
} 
 
TOIDSET& TOBJ::IsaI() { 
  return *set_or_empty(IsaIn); 
}
 
TOIDSET& TOBJ::IsaO() { 
  return *set_or_empty(IsaOut);
}

TOIDSET& TOBJ::AtrI() { 
  return *set_or_empty(AtrIn);  
}

TOIDSET& TOBJ::AtrO() { 
  return *set_or_empty(AtrOut); 
}

void TOBJ::Update_Module(TOID toid)
{
    reverse_contains = toid;
}

void TOBJ::Update_Module(long l)
{
    reverse_contains.set(l);
}

TOID TOBJ::GetModule()
{
    return reverse_contains;
}


void TOBJ::SetSystemModule(TOID toid)
{
    system_module = toid;
}

int TOBJ::SetModule() 
{
    if (!module_sets)
    {
	module_sets = new TOIDSET[MODULE_SETS];
	return 1;
    }
    return 0;
}

int TOBJ::UnsetModule()
{
    if (!module_sets)
	return 0;
    delete module_sets;
    module_sets = NULL;
    return 1;
}

TOIDSET& TOBJ::Contains() {
    if (!module_sets) return emptyset;
    return module_sets[MODULE_SET_CONTAINS];
}

TOIDSET& TOBJ::Export() {
    if (!module_sets) return emptyset;
    return module_sets[MODULE_SET_EXPORT];
}

TOIDSET& TOBJ::Import() {
    if (!module_sets) return emptyset;
    return module_sets[MODULE_SET_IMPORT];
}

int TOBJ::NewExport(TOID exp) {
    if (!module_sets) SetModule();
    module_sets[MODULE_SET_EXPORT].add(exp);
    return 1;
}

int TOBJ::DeleteExport(TOID exp) {
    if (!module_sets) return 0;
    module_sets[MODULE_SET_EXPORT].del(exp);
    return 1;
}

int TOBJ::NewImport(TOID import) {
    if (!module_sets) SetModule();;
    module_sets[MODULE_SET_IMPORT].add(import);
    return 1;
}

int TOBJ::DeleteImport(TOID import) {
    if (!module_sets) return 0;
    module_sets[MODULE_SET_IMPORT].del(import);
    return 1;
}


