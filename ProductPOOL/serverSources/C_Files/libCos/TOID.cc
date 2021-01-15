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
*   TOID.cc:       
*
*   Creation:      9.1.1993
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   30.6.1993
*   Changed by:    Thomas List
*   Version 2.1a
*
**********************************************************************/

#include "TOID.h"
#include "TOBJ.h"
#include <std.h>
#include <stdio.h>




/****************************** TOID *********************************/

void TOID::create(long ID) {
/* 
*  create a new TelosObj and init the ID
*/
  TelosObj = new TOBJ;
  TelosObj->SetId(ID);
}

void TOID::destroy() {
  delete TelosObj;
}

void TOID::Connect () {
/*
*  adds the connections of the TOID to the 
*  connected TOIDs:
*/
  if (!(identical(TelosObj->Src()) && identical(TelosObj->Dst()))) {
    (TelosObj->Src()).Update_index(OUT,*this);
    (TelosObj->Dst()).Update_index(IN,*this);
  }
}

void TOID::Disconnect () {
/*
*  deletes the connections of the TOID from the 
*  connected TOIDs:
*/
  if (!(identical(TelosObj->Src()) && identical(TelosObj->Dst()))) {
    (TelosObj->Src()).Del_index(OUT,*this);
    (TelosObj->Dst()).Del_index(IN,*this);
  }
}

// int TOID::identical( TOID toid ) {
// /*
// *  returns 1 if the pointers to the objects are equal
// */
//  return ( TelosObj == toid.TelosObj );
// }

TOID& TOID::operator=(TOID neu) {
/*
*  sets the pointer of the TOID to the TOBJ refered 
*  by the other TOID
*  if the TOID points to another object, this link
*  is lost, so take care that another link exists
*  or the object is destructed before
*/

 TelosObj = neu.TelosObj;
 return *this;
}


int TOID::operator==(TOID toid) {
/*
*  returns 1 if both pointers are 0 or the refered
*  objects are equal (have the same ID)
*/
  if (identical(toid)) return 1;      // the same pointer 
                                      // (includes 0-Pointer)
  if (!TelosObj || !(toid.TelosObj)) return 0;
                                      // at this point only one
                                      // pointer can be 0
  return TelosObj->GetId() == toid.TelosObj->GetId();  
                                      // compares the ID's
}

int TOID::operator==(TOBJ *tobj) {
    return TelosObj == tobj;
}

int TOID::operator<=(TOID toid) {
/*
*  compares two toids to less or equal by comparing
*  the ID-entrys. A 0-pointer is defined as lower than
*  a non-0-pointer
*/
  if (identical (toid)) return 1; 
                                      // identical pointers
                                      // (includes 0-pointers) 
  if (!TelosObj) return 0;            // if the first TOID is 0
                                      // the other is non-0
  if (!toid.TelosObj) return 1;       // the second TOID is 0
  return ( TelosObj->GetId() <= toid.TelosObj->GetId() );
                                      // comparing the ID's
}



/**************  Methods of TOBJ that are called via TOID ******************/
/*
*  (a TOBJ is always accessed via a TOID, see comments at TOBJ.cc
*/

void TOID::SetId (long l) {
  TelosObj->SetId(l);
}

long TOID::GetId () 
    const
{
  return TelosObj->GetId();
}

void TOID::GetOid(char *s)
{
    sprintf(s,"id_%ld",GetId());
}


void TOID::set(long nr) {
  TelosObj = (TOBJ*) nr;
}

long TOID::get() {
  return (long) TelosObj;
}

void TOID::Update_index(int set, TOID referenz) {
  TelosObj->Update_index( set, referenz );
}

void TOID::Del_index(int set, TOID referenz) {
  TelosObj->Del_index( set, referenz );
}

void TOID::Update( TOID src,TOID dst ) {
  TelosObj->Update(src,dst);
}

void TOID::Update( long src, long dst) {

  TelosObj->Update(src,dst);
}
  
void TOID::Update_StartTime( TIMEPOINT time ) {
  TelosObj->Update_StartTime(time);
}
 
void TOID::Update_EndTime( TIMEPOINT time ) {
  TelosObj->Update_EndTime(time);
}
    
void TOID::Update_Label(SYMID& symid) {
  TelosObj->Update_Label(symid);
}

void TOID::SetTemp(int whattmp) {
    TelosObj->SetTemp(whattmp);
}

void TOID::UnsetTemp() {
    TelosObj->UnsetTemp();
}

TOID TOID::Src() {
  return TelosObj->Src();
}
   
TOID TOID::Dst() {
  return TelosObj->Dst();
}
    
SYMID TOID::Lab() {
  return TelosObj->Lab();
}
    
TIMELINE TOID::Valid() {
  return TelosObj->Valid();
}

int TOID::is_valid(TIMEPOINT point, int space) 
{
    return TelosObj->is_valid(point,space);
}

int TOID::is_valid(TIMEPOINT point, int space, TOID module) 
{
    return TelosObj->is_valid(point,space,module);
}

int TOID::is_valid(TIMEPOINT point, int space, TOID module, int pattern, int strict) 
{
    return TelosObj->is_valid(point,space,module,pattern,strict);
}

int TOID::is_strictly_valid(TIMEPOINT point, int space, TOID module) 
{
    return TelosObj->is_strictly_valid(point,space,module);
}

TIMEPOINT TOID::STime() {
  return TelosObj->STime();
}

TIMEPOINT TOID::ETime() {
  return TelosObj->ETime();
}
    
TOIDSET& TOID::IofI() {
  return TelosObj->IofI();
}
    
TOIDSET& TOID::IofO() {
  return TelosObj->IofO();
}
    
TOIDSET& TOID::IsaI() {
  return TelosObj->IsaI();
}
    
TOIDSET& TOID::IsaO() {
  return TelosObj->IsaO();
}
    
TOIDSET& TOID::AtrI() {
  return TelosObj->AtrI();
}
    
TOIDSET& TOID::AtrO() {
  return TelosObj->AtrO();
}
    

void TOID::SetSystemModule(TOID toid) {
    TelosObj->SetSystemModule(toid);
}

void TOID::Update_Module(TOID toid) {
  TelosObj->Update_Module(toid);
}

void TOID::Update_Module(long l) {
  TelosObj->Update_Module(l);
}

TOID TOID::GetModule() {
  return TelosObj->GetModule();
}

int TOID::SetModule() {
  return TelosObj->SetModule();
}

int TOID::UnsetModule() {
    return TelosObj->UnsetModule();
}

TOIDSET& TOID::Contains() {
  return TelosObj->Contains();
}

TOIDSET& TOID::Export() {
  return TelosObj->Export();
}

TOIDSET& TOID::Import() {
  return TelosObj->Import();
}

int TOID::NewExport(TOID t) {
  return TelosObj->NewExport(t);
}

int TOID::DeleteExport(TOID t) {
  return TelosObj->DeleteExport(t);
}

int TOID::NewImport(TOID t) {
  return TelosObj->NewImport(t);
}

int TOID::DeleteImport(TOID t) {
  return TelosObj->DeleteImport(t);
}

void TOID::test()
{
    printf("(id_%ld,id_%ld,%s,id_%ld)",GetId(),Src().get_name(),Lab().get_name(),Dst().get_name());
}
