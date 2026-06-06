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
*   TOID.h
*
*   Creation:      8.12.1992
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   8.7.1993
*   Changed by:    Thomas List
*   version 2.1a
*
*
**********************************************************************/

#ifndef _TOID
#define _TOID

  #define OUT 0
  #define IN 1

  #include "TIMELINE.h"


/** Telos object Id.
  An instance of TOID ist im Wesentlichen ein pointer auf ein Telos object (TOBJ). Alle
  Zugriffe auf das Telos object finden about die Class TOID statt. Es can mehrere TOID's
  for ein Telos object geben. Sind alle TOID's, die auf ein TOBJ zeigen gel\"oscht, so
  can das Telos object not more gefunden are and blockiert memory. In particular wird
  durch den Destruktor not der memorybereich des Telos objects freigegeben! Fast alle Methoden
  of TOBJ sind about TOID ansprechbar.
  */
class TOID {
        /// pointer auf das Telos object
    class TOBJ* TelosObj;
public:
        /// constructor
    TOID () { TelosObj = 0; };
        /// Der pointerwert is auf den numerischen Wert des Parameters gesetzt
    void set(long);
        /// Der pointerwert is als long-Wert returned
    long get();
        /// Ausgabe der Werte
    void test();
        /// Ein neues Telos object mit Id ID is angelegt
    void create(long);
        /// Das Telos object is from dem memory gel\"oscht
    void destroy();

        /// Der Id des Telos objects is gesetzt
    void SetId (long );
        /// returns the ID des Telos objects
    long GetId ()const;
        /** memoryt den OID des Telos objects in s\\
          FRAGE: ist das n\"otig?
          */
    void GetOid(char *s);
        /// ruft Update\_index im Telos object auf
    void Update_index(int, TOID);
        /// ruft Del\_index im Telos object auf
    void Del_index(int, TOID);

        /// F\"ugt das object in die Index-structure ein
    void Connect();
        /// L\"oscht das object from der Indextruktur
    void Disconnect();

        /// Vergleichsoperator: Gleichheit, if beide TOID's auf das same Telos object zeigen
    int identical( TOID toid ) { return TelosObj == toid.TelosObj; };

        /// Zuweisungsoperator
    TOID& operator=( TOID );
        /// Vergleichsoperator (vergleicht die ID's der objects)
    int operator==( TOID );
        /// Vergleichsoperator (vergleicht ID's)
    int operator==( TOBJ* );
        /// kleiner-gleich Operator (vergleicht ID's)
    int operator <= (TOID);


    // Aequivalente functionen zu TOBJ

        /// Update of TOBJ
    void Update(TOID,TOID);
        /// Update of TOBJ
    void Update(long,long);
        /// Update\_StartRime of TOBJ
    void Update_StartTime(TIMEPOINT);
        // Update\_EndTime of TOBJ
    void Update_EndTime(TIMEPOINT);
        /// Update\_Label on TOBJ
    void Update_Label(class SYMID&);
        /// SetTemp of TOBJ
    void SetTemp(int);
        /// UnsetTemp of TOBJ
    void UnsetTemp();

        /// Src of TOBJ
    TOID Src ();
        /// Dst of TOBJ
    TOID Dst ();
        /// Lab of TOBJ
    SYMID Lab ();
        /// Valid of TOBJ
    class TIMELINE Valid ();
        /// is\_valid of TOBJ
    int is_valid(TIMEPOINT, int);
        /// is\_valid of TOBJ
    int is_valid(TIMEPOINT, int, TOID);
        /// is\_valid of TOBJ
    int is_valid(TIMEPOINT, int, TOID, int, int);
        /// is\_strictly\_valid of TOBJ
    int is_strictly_valid(TIMEPOINT, int, TOID);
        /// STime on TOBJ
    class TIMEPOINT STime();
        /// ETime of TOBJ
    class TIMEPOINT ETime();

        /// IofI of TOBJ
    class TOIDSET& IofI ();
        /// IofO of TOBJ
    class TOIDSET& IofO ();
        /// IsaI of TOBJ
    class TOIDSET& IsaI ();
        /// IsaO of TOBJ
    class TOIDSET& IsaO ();
        /// AtrI of TOBJ
    class TOIDSET& AtrI ();
        /// AtrO of TOBJ
    class TOIDSET& AtrO ();
    
        /*
         * for die module
         */

        /// SetSystemModul of TOBJ
    void SetSystemModule(TOID);
        /// Update\_Module of TOBJ
    void Update_Module(TOID);
        /// Update\_Module of TOBJ
    void Update_Module(long);
        /// GetModule of TOBJ
    class TOID GetModule();
        /// SetModule of TOBJ
    int SetModule();
        /// UnsetModul of TOBJ
    int UnsetModule();
        /// Contains of TOBJ
    class TOIDSET& Contains();
        /// Export of TOBJ
    class TOIDSET& Export();
        /// Import of TOBJ
    class TOIDSET& Import();
        /// NewExport of TOBJ
    int NewExport(TOID);
        /// DeleteExport of TOBJ
    int DeleteExport(TOID);
        /// MewImport of TOBJ
    int NewImport(TOID);
        /// DeleteImport of TOBJ
    int DeleteImport(TOID);
 };

inline bool operator<(const TOID& t1,const TOID& t2)

{  
    return t1.GetId()<t2.GetId();
};

#endif
