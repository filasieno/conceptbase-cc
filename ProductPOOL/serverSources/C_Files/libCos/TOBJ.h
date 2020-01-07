/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
*   TOBJ.h 
*
*   Creation:      8.12.1992
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   Version 2.1a
*
*
**********************************************************************/

#ifndef _TOBJ
#define _TOBJ

#define MODULE_SET_CONTAINS 0
#define MODULE_SET_EXPORT 1
#define MODULE_SET_IMPORT 2

#define MODULE_SETS 3

#include "TDB.defs.h"
#include "TOIDSET.h"
#include "TOID.h"
#include "TIMEPOINT.h"
#include "TIMELINE.h"
#include "SYMID.h"
#include "SYMTBL.h"

  class TOBJ {
    //    Komponenten des Objekts

    long id;                      // Identifikator
    TOID src,dst;                 // Source, Destination
    SYMID Label;                  // Label-Komponente
    TIMEPOINT StartTime,EndTime;  // Zeit-Kompnenten

    TOIDSET *IofIn,*IofOut,*IsaIn,*IsaOut,*AtrIn,*AtrOut;

    char istemp;

    static TOIDSET emptyset;
    static TOID system_module;

    TOIDSET* create_if_NULL(TOIDSET **set) { return ((*set)?(*set):(*set=new TOIDSET)); };
    TOIDSET* delete_if_empty(TOIDSET **set) { return (sizeof(*set))?(*set):(delete *set, *set=NULL); };
    TOIDSET* set_or_empty(TOIDSET *set) { return ((set)?(set):(&emptyset)); };

    /* fuer die Module */

    TOID reverse_contains;
    TOIDSET *module_sets;

  public:

    // Schnittstellen

    TOBJ();                // Constructor: Erzeugt Object mit 0-Label
    TOBJ( SYMID,long );    // Constructor: Erzeugt Object mit Label
    ~TOBJ() {};            // Destructor

    void SetId ( long neu ) { id = neu; };
    long GetId () { return id; };

    void Update_Label(SYMID);
    void Update(TOID,TOID);     // Vervollstaendigt Object durch src+dst
    void Update(long,long);
    void Update_StartTime(TIMEPOINT);  // setzt erste Zeitkomp.
    void Update_EndTime(TIMEPOINT);    // setzt zweite Zeitkomp.

    void Update_index(int, TOID);      // fuegt Referenz in Index-Menge ein
    void Del_index(int, TOID);         // Entfernt Referenz aus Index-Mge
    void SetTemp(int);
    void UnsetTemp();

    TOID Src() { return src; };         //
    TOID Dst() { return dst; };         //  liefert einzelne Komponenten
    SYMID Lab() { return Label; };      //  des Objekts
    TIMELINE Valid();                   //

    int is_valid(TIMEPOINT, int);       // Kontrolle auf Zeitpunkt 
				        // und Suchmenge
    int is_valid(TIMEPOINT, int, TOID); // Kontrolle auf Zeitpunkt, Suchmenge und Modul
    int is_strictly_valid(TIMEPOINT, int, TOID);  // Kontrolle auf Zeitpunkt, Suchmenge und Modul
    int is_valid(TIMEPOINT, int, TOID, int, int); // Kontrolle auf Zeitpunkt, Suchmenge und Modul
				                  // bei Kontrolle des Search-Patterns
    
    TIMEPOINT STime();
    TIMEPOINT ETime();

    TOIDSET& IofI();
    TOIDSET& IofO();
    TOIDSET& IsaI();
    TOIDSET& IsaO();
    TOIDSET& AtrI();
    TOIDSET& AtrO();

    /* fuer die Module */

    void SetSystemModule(TOID);

    void Update_Module(TOID);
    void Update_Module(long);

    TOID GetModule();

    int SetModule();
    int UnsetModule();

    TOIDSET& Contains();
    TOIDSET& Export();
    TOIDSET& Import();

    int NewExport(TOID);
    int DeleteExport(TOID);
    int NewImport(TOID);
    int DeleteImport(TOID);
  };

#endif
