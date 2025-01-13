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

#include <map>
#include <stdlib.h>
#include <iostream>
#include "TermCache.h"
#include "prolog.h"
using namespace std;

typedef map<string, record_t> recordMap;
typedef map<string, recordMap > clusterMap;

class TermCache {
  clusterMap clusters;

public:

  /**
   * Stores a copy of the PROLOG_TERM 'record' associated to
   * double key (key1, key2). Fails with an error if there
   * is already a value associated to the double key.
   */
  int pc_record(char* key1, char* key2, record_t record) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_record(..) not yet tested for BIM!\n";
    #endif
    //cout << "pc_record(..): record = " << (int)record << "\n";
    string k1 = string(key1);
    string k2 = string(key2);
    //Logger log(string("TermCache.log"));
    //ostringstream buffer;
    //buffer << "pc_record(" << k1 << ", " << k2 << "): ";
    //string msg = buffer.str();
    //log.debug(msg + "entered");
    int solve = FAIL;
    recordMap* cluster = &clusters[k2];
    if(cluster->find(k1) == cluster->end()) {
      cluster->insert(recordMap::value_type(k1, record));
      solve = SUCCEED;
    }

    /*
    recordMap::const_iterator keyTermPair;
    for(keyTermPair = cluster->begin(); keyTermPair != cluster->end(); ++keyTermPair) {
      //cout << "current key == " << keyTermPair->first << "\n";
    }
    */
    //delete log;
    return solve;
  }

  /**
   * Stores a copy of the PROLOG_TERM 'record' associated to
   * double key (key1, key2). Any value that was associated
   * to the double key, is erased.
   */
  int pc_rerecord(char* key1, char* key2, record_t record) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_rerecord(..) not yet tested for BIM!\n";
    #endif
    string k1 = string(key1);
    string k2 = string(key2);
    recordMap* cluster = &clusters[k2];
    //cout << "pc_rerecord(..): Fetch iterator on key1-Element\n";
    recordMap::iterator oldRecord = cluster->find(k1);
    //cout << "pc_rerecord(..): oldRecord != cluster->end():" << (oldRecord != cluster->end()) << "\n";
    if(oldRecord == cluster->end()) {
      cluster->insert(recordMap::value_type(k1, record));
    } else {
      #ifdef SWI
        PL_erase(oldRecord->second);
      #endif
      oldRecord->second = record;
    }
    //cout << "pc_rerecord(..): return\n";
    return SUCCEED;
  }

  /**
   * Unifies the PROLOG_TERM 'record' with the record associated
   * to the double key (key1, key2). Fails if there is nothing
   * associated to the double key.
   */
  int pc_recorded(char* key1, char* key2, record_t* record) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_recorded(..) not yet tested for BIM!\n";
    #endif
    string k1 = string(key1);
    string k2 = string(key2);
    int solve = FAIL;
    clusterMap::iterator clusterP = clusters.find(k2);
    if(clusterP != clusters.end()) {
      recordMap* cluster = &(clusterP->second);
      recordMap::iterator recordP = cluster->find(k1);
      if(recordP != cluster->end()) {
        ////cout<<"Found record with given double key ("<<(int)(recordP->second)<<")\n";
        *record = (recordP->second);
        solve = SUCCEED;
      }
    }
    return solve;
  }

  /*
   * Succeeds if there is an association to double key (key1, key2).
   */
  int pc_is_a_key(char* key1, char* key2) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_is_a_key(..) not yet tested for BIM!\n";
    #endif
    string k1 = string(key1);
    string k2 = string(key2);
    int solve = FAIL;
    clusterMap::iterator clusterP = clusters.find(k2);
    if(clusterP != clusters.end()) {
      recordMap::iterator cluster = clusterP->second.find(k1);
      if(cluster != clusterP->second.end()) solve = SUCCEED;
    }
    return solve;
  }

  /**
   * Any record associated to the double key (key1, key2) is
   * erased. Succeeds always.
   */
  int pc_erase(char* key1, char* key2) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_erase(..) not yet tested for BIM!\n";
    #endif
    string k1 = string(key1);
    string k2 = string(key2);
    clusterMap::iterator clusterP = clusters.find(k2);
    if(clusterP != clusters.end()) {
      recordMap* cluster = &(clusterP->second);
      if(cluster->size() > 1) {
        //cout << "Erase single element with key (" << key1 << ", " << key2 << ")\n";
        // If there are yet more elements in this cluster.
        cluster->erase(k1);
      } else {
        //cout << "Erase whole cluster with key ( _X, " << key2 << ") and one element\n";
        // Else erase whole cluster.
        clusters.erase(k2);
      }
    }
    return SUCCEED;
  }

  /**
   * All associations to double keys with second key (key2) are
   * erased.
   */
  int pc_erase_all(char* key2) {
    #ifdef BIM
      cout << "WARN: TermCache::pc_erase_all(..) not yet tested for BIM!\n";
    #endif
    string k2 = string(key2);
    clusterMap::iterator clusterP = clusters.find(k2);
    if(clusterP != clusters.end()) {
      recordMap cluster = clusterP->second;
      recordMap::const_iterator keyTermPair;
      for(keyTermPair = cluster.begin(); keyTermPair != cluster.end(); ++keyTermPair) {
        #ifdef SWI
          //cout << "Erase whole cluster with key ( _X, " << key2 << ") and one element\n";
          PL_erase(keyTermPair->second);
        #endif
      }
    }
    clusters.erase(k2);
    return SUCCEED;
  }

  /**
   * Succeeds for all double keys (key1, key2) that have an
   * associated value. If one or both of the arguments are free, all
   * matching solutions are returned by backtracking. The order is
   * undefined.
   */
  int pc_current_key(char* key1, char* key2, PROLOG_TERM resultList) {
    int solve = FAIL;
    #ifdef BIM
      cout << "WARN: TermCache::pc_current_key(..) not yet tested for BIM!\n";
    #endif
    string k2 = string(key2);
    clusterMap::iterator clusterP = clusters.find(k2);

    //PROLOG_TERM resultList2;
    //INIT_TERM(resultList2);
    PROLOG_TERM term;
    PROLOG_FUNC keyStruct;
    keyStruct=GET_PRED(STR2ATOM(FALSE,"double_key"), 2);
    PROLOG_TERM key1Term;
    PROLOG_TERM key2Term;
    PROLOG_TERM key2TermConst = STR2ATOM(FALSE, k2.c_str());
    // If there are values stored, otherwise return the empty list.
    if(clusterP != clusters.end()) {
      recordMap cluster = clusterP->second;
      recordMap::const_iterator record = cluster.begin();
      //cout << "Creating result list.\n";
      solve = SUCCEED;
      while(record != cluster.end()) {
          // Unify resTerm with a new list.
          //cout << "1: Unify resultList with a new list.\n";
          INIT_LIST(resultList);
          // Create new term.
          //cout << "Create new term.\n";
          INIT_TERM(term);
          // Assign to term the first arg of resTerm (the list's head).
          //cout << "Assign to term the first arg of resultList (the list's head).\n";
          GET_ARG(resultList, 1, term);
          //cout << "record->first == " << record->first << "\n";

          // Set up the double key structure.
          //cout << "Set up the double key structure.\n";
          UNIFY_FUNC(term, keyStruct);
          INIT_TERM(key1Term);
          GET_ARG(term, 1, key1Term);
          UNIFY_ATOM(key1Term, STR2ATOM(FALSE,record->first.c_str()));
          INIT_TERM(key2Term);
          GET_ARG(term, 2, key2Term);
          UNIFY_ATOM(key2Term, key2TermConst);

          // Assign to term the second arg of resultList (the list's tail).
	  GET_ARG(resultList, 2, term);
	  // The list is now it's tail for the next iteration.
	  resultList = term;
	  record++;
      }
    }
    // Finish the list by assigning the empty list to the tail.
    UNIFY_ATOM(resultList, STR2ATOM(TRUE,"[]"));
    //UNIFY_TERMS(resultList, resultList2);
    return solve;
  }
};

/*************************************************************************/
/* C implementation of TermCache.h passes calls to cpp TermCache object. */
/*************************************************************************/

static TermCache tc;

int pc_record(char* key1, char* key2, record_t record) {
  return tc.pc_record(key1, key2, record);
}

int pc_rerecord(char* key1, char* key2, record_t record) {
  return tc.pc_rerecord(key1, key2, record);
}

int pc_recorded(char* key1, char* key2, record_t* record) {
  return tc.pc_recorded(key1, key2, record);
}

int pc_is_a_key(char* key1, char* key2) {
  return tc.pc_is_a_key(key1, key2);
}

int pc_erase(char* key1, char* key2) {
  return tc.pc_erase(key1, key2);
}

int pc_erase_all(char* key2) {
  return tc.pc_erase_all(key2);
}

int pc_current_key(char* key1, char* key2, PROLOG_TERM resultList) {
  return tc.pc_current_key(key1, key2, resultList);
}

