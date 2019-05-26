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
/***********************************************************************
*
*      Statistics.cc
*
*      Creation     : 26.04.1996
*      Created By   : Thomas List
*      Last Change  : 26.04.1996
*      Changed By   : Thomas List
*      Version      : 0.1
*
************************************************************************/

#include "TOID.h"
#include "TDB.defs.h"
#include "Statistics.h"
#include "Literals.h"
#include <stdlib.h>
#include <stdio.h>

Statistics::Statistics() : tbl()
{
}


Statistic& Statistics::get(TOID toid) {
    StatisticSet::iterator ind;

    static Statistic search(toid);
    ind = tbl.seek(search);
    if (ind != tbl.end())
	return tbl(ind);
    search.create();
    tbl.add(search);
    return search;
}

int Statistics::ask(TOID toid) {
    Statistic search(toid);
    if (tbl.seek(search) != tbl.end())
	return 1;
    return 0;
}

int Statistics::update_zaehler(TOID toid, int box, long &count, 
	       TIMEPOINT timepoint,
	       int searchspace)
{
    TOIDSETSTL helpset,helpset2,helpset3,solution;
    TOIDMap::iterator ind;
    TOID module,current;

    if (box < 0 || box >= BOX_ANZAHL) return 0;
    
    switch (box) {
    case BOX_IN_O:
	apply_desti(toid.IofO(), helpset, timepoint, searchspace, module, FREE_MODULE );
	closure(helpset, solution, generalization, timepoint, searchspace, module, FREE_MODULE );
	break;
    case BOX_IN_I:
	helpset.add(toid);
	closure(helpset, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind = helpset2.begin();ind != helpset2.end();ind++) 
        {
            current=(*ind).second;
	    helpset3 |= current.IofI();
	}
	apply_source(helpset3,solution,timepoint,searchspace, module, FREE_MODULE );
        break;
    case BOX_ISA_O:
	helpset.add(toid);
	closure(helpset, solution, generalization, timepoint, searchspace, module, FREE_MODULE  );
	break;
    case BOX_ISA_I:
	helpset.add(toid);
	closure(helpset, solution, specialization, timepoint, searchspace, module, FREE_MODULE  );
	break;
    case BOX_A_O:
	helpset.add(toid);
	closure(helpset, helpset2, generalization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind= helpset2.begin();ind != helpset2.end();ind++) 
        {
            current=(*ind).second;
	    solution |= current.AtrO();
	}
	break;
    case BOX_A_I:
	helpset.add(toid);
	closure(helpset, helpset2, generalization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind = helpset2.begin();ind != helpset2.end();ind++) 
        {
            current=(*ind).second;
	    helpset3 |= current.AtrI();
	}
	apply_source(helpset3,solution,timepoint,searchspace, module, FREE_MODULE );
        break;
    default:
	break;
    }
    count = get(toid)[box] = solution.length();
    return 1;
}

int Statistics::update_zaehler_wo_closure(TOID toid, int box, long &count, 
	       TIMEPOINT timepoint,
	       int searchspace)
{
    TOIDSETSTL helpset,helpset2,helpset3,solution;
    TOIDMap::iterator ind; 
    TOID module,current;

    if (box < 0 || box >= BOX_ANZAHL) return 0;
    
    switch (box) {
    case BOX_IN_O:
	apply_desti(toid.IofO(), solution, timepoint, searchspace, module, FREE_MODULE  );
	break;
    case BOX_IN_I:
	apply_source(toid.IofI(),solution,timepoint,searchspace, module, FREE_MODULE );
        break;
    case BOX_ISA_O:
	if (!toid.IsaO().length())
	    break;
	for (ind = toid.IsaO().begin();ind != toid.IsaO().end() ;ind++){
	    current=(*ind).second;
	    if (current.is_valid(timepoint,searchspace)){
		current=(*ind).second;
		solution.add(current);
	    }
	}
		
	break;
    case BOX_ISA_I:
	if (!toid.IsaI().length())
	    break;
	for (ind = toid.IsaI().begin();ind != toid.IsaI().end() ;ind++){
	    current=(*ind).second;
	    if (current.is_valid(timepoint,searchspace)){
		solution.add(current);
	    }
	}
	break;
    case BOX_A_O:
	if (!toid.AtrO().length())
	    break;
	for (ind = toid.AtrO().begin();ind != toid.AtrO().end();ind++){
	    current=(*ind).second;
	    if (current.is_valid(timepoint,searchspace)){
		solution.add(current);
	    }
	}
	break;
    case BOX_A_I:
	if (!toid.AtrI().length())
	    break;
	for (ind = toid.AtrI().begin();ind != toid.AtrI().end() ;ind++){
	    current=(*ind).second;
	    if (current.is_valid(timepoint,searchspace)){
		solution.add(current);
	    }
	}
        break;
    default:
	break;
    }
    count = get(toid)[box] = solution.length();
    return 1;
}


int Statistics::set_zaehler(TOID toid, int box, long count)
{
    if (box < 0 || box >= BOX_ANZAHL) return 0;
    get(toid)[box] = count;
    return 1;
}

int Statistics::get_zaehler(TOID toid, int box, long &count)
{
    if (box < 0 || box >= BOX_ANZAHL) return 0;
    if (!ask(toid)) return -1;
    count = get(toid)[box];
    return 1;
}


void Statistics::walk_histogramm(TOID oid, int dir)
{
    TOID toid;
    long l;
    Histogramm *hst;

    switch (dir) {
    case SRC:
	hst = get(oid).hist_walk(HISTOGRAMM_SRC);
	break;
    case DST:
	hst = get(oid).hist_walk(HISTOGRAMM_DST);
	break;
    default:
	return;
    }

    while (hst)
    {
	hst->get(toid,l);
	printf("TOID: %ld: %ld\n",toid.GetId(),l);
	hst = hst->walk();
    }

}

Histogramm *Statistics::get_histogramm(TOID oid, int dir)
{

    switch (dir) {
    case SRC:
	return get(oid).hist_walk(HISTOGRAMM_SRC);
	break;
    case DST:
	return get(oid).hist_walk(HISTOGRAMM_DST);
	break;
    default:
	return NULL;
    }

}


int Statistics::update_histogramm(TOID oid, int dir, TOID object, long &count,
	       TIMEPOINT timepoint,
	       int searchspace)
{
    TOIDSETSTL solution;
    TOIDSETSTL helpset1,helpset2,helpset3;
    TOIDMap::iterator ind; 
    TOID module,current;

    helpset1.add(oid);
    closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
    for (ind = helpset2.begin();ind != helpset2.end() ;ind++) 
    {
    	current=(*ind).second;
	helpset3 |= current.IofI();
    }
    apply_source(helpset3,solution,timepoint,searchspace, module, FREE_MODULE );

    for (count=0,ind=solution.begin();ind != solution.end();ind++)
    {
    	current=(*ind).second;
	switch (dir) {
	case SRC: 
	    if (current.Src() == object) count++;
	    break;
	case DST:
	    if (current.Dst() == object) count++;
	    break;
	default:
	    ;
	}
    }

    switch (dir) {
    case SRC:
	get(oid).hist_insert(HISTOGRAMM_SRC,object,count);
	break;
    case DST:
	get(oid).hist_insert(HISTOGRAMM_DST,object,count);
	break;
    }

    return 1;
}

int Statistics::update_histogramm(TOID oid, int dir,
	       TIMEPOINT timepoint,
	       int searchspace)
{
    TOIDSETSTL solution,objects;
    TOIDSETSTL helpset1,helpset2,helpset3;
    TOIDMap::iterator  ind,ind2;
    long count;
    TOID module, current, current2;

    switch (dir) {
    case SRC:
	get(oid).hist_delete(HISTOGRAMM_SRC);
	break;
    case DST:
	get(oid).hist_delete(HISTOGRAMM_DST);
	break;
    }
    
    helpset1.add(oid);
    closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
    for (ind = helpset2.begin();ind != helpset2.end();ind++) 
    {
    	current=(*ind).second;
	helpset3 |= current.IofI();
    }
    apply_source(helpset3,solution,timepoint,searchspace, module, FREE_MODULE );

    helpset1.clear();
    helpset2.clear();
    helpset3.clear();

    TOID dummy;
    switch (dir) {
    case SRC:
        dummy=oid.Src();
	helpset1.add(dummy);
	break;
    case DST:
        dummy=oid.Dst();
	helpset1.add(dummy);
	break;
    default:
	break;
    }

    closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
    for (ind = helpset2.begin();ind != helpset2.end();ind++) 
    {
    	current=(*ind).second;
	helpset3 |= current.IofI();
    }
    apply_source(helpset3,objects,timepoint,searchspace, module, FREE_MODULE );

    for (ind2 = objects.begin();ind2 != objects.end() ;ind2++)
    {
	current2=(*ind2).second;
	for (count=0,ind=solution.begin();ind != solution.end();ind++)
	    {
	    	current=(*ind).second;
		switch (dir) {
		case SRC: 
		    if (current.Src() == current2) count++;
		    break;
		case DST:
		    if (current.Dst() == current2) count++;
		    break;
		default:
		    ;
		}
	    }

	switch (dir) {
	case SRC:
	    get(oid).hist_insert(HISTOGRAMM_SRC,current2,count);
	    break;
	case DST:
	    get(oid).hist_insert(HISTOGRAMM_DST,current2,count);
	    break;
	}
    }
    return 1;
}
				  



int Statistics::update_histogramm_with_class_restriction(
    TOID oid, int dir, 
    TOID src_restr, TOID dst_restr, int restr_dir,
    TIMEPOINT timepoint,
    int searchspace)
{
    TOIDSETSTL solution,objects;
    TOIDSETSTL helpset1,helpset2,helpset3;
    TOIDSETSTL src_restriction,dst_restriction;

    TOIDMap::iterator ind,ind2;
    long count;
    int rev_dir;
    TOID module, current, current2;

    rev_dir = (dir == SRC)?DST:SRC;


    if ( (restr_dir & SRC) && (src_restr == oid.Src()) )
	restr_dir -= SRC;

    if ( (restr_dir & DST) && (dst_restr == oid.Dst()) )
	restr_dir -= DST;


    if (restr_dir & SRC)
    {
	helpset1.add(src_restr);
	closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind = helpset2.begin();ind != helpset2.end();ind++) 
	{
	    current=(*ind).second;
	    helpset3 |= current.IofI();
	}
	apply_source(helpset3,src_restriction,timepoint,searchspace, module, FREE_MODULE );
	helpset1.clear();
	helpset2.clear();
	helpset3.clear();
    }

    if (restr_dir & DST)
    {
	helpset1.add(dst_restr);
	closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind = helpset2.begin();ind != helpset2.end();ind++) 
	{
	    current=(*ind).second;
	    helpset3 |= current.IofI();
	}
	apply_source(helpset3,dst_restriction,timepoint,searchspace, module, FREE_MODULE );
	helpset1.clear();
	helpset2.clear();
	helpset3.clear();
    }


    switch (dir) {
    case SRC:
	get(oid).hist_delete(HISTOGRAMM_SRC);
	break;
    case DST:
	get(oid).hist_delete(HISTOGRAMM_DST);
	break;
    }
    
    helpset1.add(oid);
    closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
    for (ind = helpset2.begin();ind != helpset2.end();ind++) 
    {
    	current=(*ind).second;
	helpset3 |= current.IofI();
    }
    apply_source(helpset3,solution,timepoint,searchspace, module, FREE_MODULE );

    helpset1.clear();
    helpset2.clear();
    helpset3.clear();


    if (restr_dir & dir)
    {
	switch (dir) {
	case SRC:
	    objects |= src_restriction;
	    break;
	case DST:
	    objects |= dst_restriction;
	    break;
	default:
	    ;
	}
    }
    else
    {
        TOID dummy;
	switch (dir) {
	case SRC:
            dummy=oid.Src();
	    helpset1.add(dummy);
	    break;
	case DST:
            dummy=oid.Dst();
	    helpset1.add(dummy);
	    break;
	default:
	    break;
	}
	closure(helpset1, helpset2, specialization, timepoint, searchspace, module, FREE_MODULE  );
	for (ind = helpset2.begin();ind != helpset2.end();ind++) 
	{
	    current=(*ind).second;
	    helpset3 |= current.IofI();
	}
	apply_source(helpset3,objects,timepoint,searchspace, module, FREE_MODULE );
    }

    for (ind2 = objects.begin();ind2 != objects.end() ;ind2++)
    {
    	current2=(*ind2).second;
	for (count=0,ind=solution.begin();ind != solution.end();ind++)
	{
	    current=(*ind).second;
	    if (rev_dir & restr_dir)
	    {
                TOID dummy;
		switch (rev_dir) {
		case SRC:
                    dummy=current.Src();
		    if (!src_restriction.contains(dummy))
			continue;
		    break;
		case DST:
                    dummy=current.Dst();
		    if (!dst_restriction.contains(dummy))
			continue;
		    break;
		default:
		    ;
		}
	    }
	    switch (dir) {
	    case SRC: 
		if (current.Src() == current2) count++;
		break;
	    case DST:
		if (current.Dst() == current2) count++;
		break;
	    default:
		;
	    }
	}

	switch (dir) {
	case SRC:
	    get(oid).hist_insert(HISTOGRAMM_SRC,current2,count);
	    break;
	case DST:
	    get(oid).hist_insert(HISTOGRAMM_DST,current2,count);
	    break;
	}
    }

    return 1;
}
				  



