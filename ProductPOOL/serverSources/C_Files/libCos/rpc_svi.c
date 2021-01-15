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
#include "rpc_idef.h"
#include "trans_c.h"

int *r_init_1( inp )
  in_name2id *inp;
{
  static int res;
  res = init(inp->name);
  return &res;
}


void *r_test_1()
{
  test();
  return (void*) 1;
}


void *r_done_1()
{
   done();
   exit(0);
   return (void*) 1;
}


out_getquery *r_getquery_1( inp )
   in_getquery *inp;
{
   static out_getquery res;
   char *tupel[4];

   tupel[0] = inp->p4.id;
   tupel[1] = inp->p4.src;
   tupel[2] = inp->p4.lab;
   tupel[3] = inp->p4.dst;

   res.nr = getquery(tupel);

   return( &res );
}

out_getquery *r_literal_getquery_1( inp )
   in_literal_getquery *inp;
{
  static out_getquery res;
  char *tuple[2];
  tuple[0] = inp->o2.id1;
  tuple[1] = inp->o2.id2;

  if (inp->WhatLit == 3) {
      res.nr = star_getquery(tuple[0]);
  } else {
      res.nr = Literal_getquery(tuple, inp->WhatLit);
  }

  return( &res );
}

out_getquery *r_literal3_getquery_1( inp )
   in_literal3_getquery *inp;
{
   static out_getquery res;
   char *tupel[3];

/*   tupel[0] = inp->p4.id;*/
   tupel[0] = inp->p3.src;
   tupel[1] = inp->p3.lab;
   tupel[2] = inp->p3.dst;

   res.nr = Literal3_getquery(tupel, inp->WhatLit);

   return( &res );
}


out_getquery *r_literal4_getquery_1( inp )
   in_literal4_getquery *inp;
{
   static out_getquery res;
   char *tupel[4];

   tupel[0] = inp->p4.id;
   tupel[1] = inp->p4.src;
   tupel[2] = inp->p4.lab;
   tupel[3] = inp->p4.dst;

   res.nr = Literal4_getquery(tupel, inp->WhatLit);

   return( &res );
}


out_find *r_find_1( inp )
   in_find *inp;
{
   static out_find res;
   char *tupel[4];
   
   res.success = find(inp->query,tupel);

   res.p4.id = tupel[0];
   res.p4.src = tupel[1];
   res.p4.lab = tupel[2];
   res.p4.dst = tupel[3];

   return( &res );
}



out_literal_find *r_literal_find_1( inp )
   in_literal_find *inp;
{
  static out_literal_find res;
  char *tuple[2];

  if (inp->WhatLit == 3) {
      res.success = star_find(inp->query,tuple);
      res.o2.id1 = tuple[0];
      res.o2.id2 = "empty";
  } else {
      res.success = Literal_find(inp->query,tuple,inp->WhatLit);
      res.o2.id1 = tuple[0];
      res.o2.id2 = tuple[1];
  }
  return( &res );
}

out_find3 *r_literal3_find_1( inp )
   in_literal_find *inp;
{
  static out_find3 res;
  char *tuple[3];

  res.success = Literal3_find(inp->query,tuple,inp->WhatLit);

/*  res.p4.id = tuple[0];*/
  res.p3.src = tuple[0];
  res.p3.lab = tuple[1];
  res.p3.dst = tuple[2];

  return( &res );
}

out_find *r_literal4_find_1( inp )
   in_literal_find *inp;
{
  static out_find res;
  char *tuple[4];

  res.success = Literal4_find(inp->query,tuple,inp->WhatLit);

  res.p4.id = tuple[0];
  res.p4.src = tuple[1];
  res.p4.lab = tuple[2];
  res.p4.dst = tuple[3];

  return( &res );
}


void *r_freequery_1( inp )
   int *inp;
{
  freequery(*inp);
  return (void *) 1;
}

void *r_literal_freequery_1( inp )
   in_literal_freequery *inp;
{
  Literal_freequery(inp->query,inp->WhatLit);
  return (void *) 1;
}


out_getid *r_getid_1()
{
   static out_getid res;

   getid(&(res.id));

   return( &res );
}

out_getid *r_literal_getid_1(inp)
   int inp;
{
   static out_getid res;

   Literal_getid(&(res.id),inp);

   return( &res );
}

out_create_name2id *r_create_name2id_1( inp )
   in_create_name2id *inp;
{
   static out_create_name2id res;

   res.success = create_name2id(inp->name,&(res.oid));

   return( &res );
}


out_name2id *r_name2id_1( inp )
   in_name2id *inp;
{

   static out_name2id res;   

   res.success = name2id(inp->name,&(res.oid));

   return( &res );
}


out_id2name *r_id2name_1( inp )
   in_id2name *inp;
{
   static out_id2name res;

   res.success = id2name(inp->oid,&(res.name));

   return( &res );
}


out_select2id *r_select2id_1( inp )
   in_select2id *inp;
{
   static out_select2id res;

   res.success = select2id(inp->name,&(res.oid));

   return( &res );
}


out_id2select *r_id2select_1( inp )
   in_id2select *inp;
{
   static out_id2select res;

   res.success = id2select(inp->oid,&(res.name));

   return( &res );
}

out_id2time *r_id2time_1( inp )
   in_id2time *inp;

{
   static out_id2time res;

   res.success = id2time(inp->oid,
	 &(res.milsec), &(res.sec),&(res.min),&(res.hour),&(res.mday),&(res.mon),&(res.year));
   return( &res );
}

int *r_check_implicit_1( inp )
   in_id2select *inp;
{
    static int res;
    res = check_implicit( inp->oid );
    return( &res );
}

out_create_node *r_create_node_1( inp )
   in_create_node *inp;
{
   static out_create_node res;
   char *tupel[4];

   tupel[0] = inp->p4.id;
   tupel[1] = inp->p4.src;
   tupel[2] = inp->p4.lab;
   tupel[3] = inp->p4.dst;
   res.success = create_node(tupel);
   res.p4.id  = tupel[0];
   res.p4.src = tupel[1];
   res.p4.lab = tupel[2];
   res.p4.dst = tupel[3];

   return( &res );
}

out_create_node *r_create_implicit_node_1( inp )
   in_create_node *inp;
{
   static out_create_node res;
   char *tupel[4];

   tupel[0] = inp->p4.id;
   tupel[1] = inp->p4.src;
   tupel[2] = inp->p4.lab;
   tupel[3] = inp->p4.dst;
   res.success = create_implicit_node(tupel);
   res.p4.id  = tupel[0];
   res.p4.src = tupel[1];
   res.p4.lab = tupel[2];
   res.p4.dst = tupel[3];

   return( &res );
}


out_create_link *r_create_link_1( inp )
   in_create_link *inp;
{
   static out_create_link res;
   char *tupel[4];

   tupel[0] = inp->p4.id;
   tupel[1] = inp->p4.src;
   tupel[2] = inp->p4.lab;
   tupel[3] = inp->p4.dst;
   res.success = create_link(tupel);
   res.p4.id  = tupel[0];
   res.p4.src = tupel[1];
   res.p4.lab = tupel[2];
   res.p4.dst = tupel[3];

   return( &res );
}

void *r_insert_commit_1()
{
  insert_commit();
  return (void *) 1;
}

void *r_insert_abort_1()
{
  insert_abort();
  return (void *) 1;
}

int* r_remove_1( inp ) 
  in_remove *inp;
{
   static int res;

   res = remove_(inp->oid);

   return( &res );
}

void *r_remove_abort_1()
{
  remove_abort();
  return (void *) 1;
}

void *r_remove_end_1()
{
  remove_end();
  return (void *) 1;
}

int *r_rename_1( inp )
in_rename *inp;
{
    static int res;
    
    res = rename_object(inp->newname,inp->oldname);

    return( &res );
}

void *r_set_act_1()
{
  set_act();
  return (void *) 1;
}


void *r_set_temp_1()
{
  set_temp();
  return (void *) 1;
}

void *r_set_overrule_temp_1()
{
  set_overrule_temp();
  return (void *) 1;
}

void *r_set_overrule_temp_tell_1()
{
  set_overrule_temp_tell();
  return (void *) 1;
}

void *r_set_overrule_temp_untell_1()
{
  set_overrule_temp_untell();
  return (void *) 1;
}

void *r_set_overrule_act_1()
{
  set_overrule_act();
  return (void *) 1;
}

void *r_set_hist_1()
{
  set_hist();
  return (void *) 1;
}


void *r_set_act_temp_1()
{
  set_act_temp();
  return (void *) 1;
}

void *r_set_act_hist_1()
{
  set_act_hist();
  return (void *) 1;
}

void *r_set_new_db_1()
{
  set_new_db();
  return (void *) 1;
}

void *r_set_old_db_1()
{
  set_old_db();
  return (void *) 1;
}

void *r_set_current_db_1()
{
  set_current_db();
  return (void *) 1;
}


out_get_sys_class *r_get_sys_class_1( inp )
   in_get_sys_class *inp;
{
   static out_get_sys_class res;

   res.success = get_sys_class(inp->name,&(res.oid));

   return( &res );
}

out_get_prop_id *r_get_prop_id_1()
{
   static out_get_prop_id res;

   res.success = get_prop_id(&(res.oid));

   return( &res );
}

void *r_set_time_point_1( inp )
   in_set_time_point *inp;
{
   set_time_point(inp->milsec,inp->sec,inp->min,inp->hour,inp->mday,inp->mon,inp->year);

   return (void*) 1;
}

void *r_set_search_point_1( inp )
   in_set_time_point *inp;
{
   set_search_point(inp->milsec,inp->sec,inp->min,inp->hour,inp->mday,inp->mon,inp->year);

   return (void*) 1;
}

void *r_delete_history_db_1( inp )
   in_set_time_point *inp;
{
    delete_history_db(inp->milsec,inp->sec,inp->min,inp->hour,inp->mday,inp->mon,inp->year);
    
    return (void*) 1;
}

/*************************************************************/

out_getquery *r_getquerym_1( inp )
   in_getqueryM *inp;
{
   static out_getquery res;
   char *tupel[5];

   tupel[0] = inp->p5.id;
   tupel[1] = inp->p5.src;
   tupel[2] = inp->p5.lab;
   tupel[3] = inp->p5.dst;
   tupel[4] = inp->p5.mod;

   res.nr = getqueryM(tupel);

   return( &res );
}

out_findM *r_findm_1( inp )
   in_find *inp;
{
   static out_findM res;
   char *tupel[5];
   
   res.success = findM(inp->query,tupel);

   res.p5.id = tupel[0];
   res.p5.src = tupel[1];
   res.p5.lab = tupel[2];
   res.p5.dst = tupel[3];
   res.p5.mod = tupel[4];

   return( &res );
}



int *r_set_module_1( inp )
   in_module *inp;
{
   static int res;
   res = set_module( inp->oid );
   return( &res );
}

int *r_set_overrule_module_1( inp )
   in_module *inp;
{
   static int res;
   res = set_overrule_module( inp->oid );
   return( &res );
}

int *r_system_module_1( inp )
   in_module *inp;
{
   static int res;
   res = system_module( inp->oid );
   return( &res );
}

int *r_initialize_module_1( inp )
   in_module *inp;
{
   static int res;
   res = initialize_module( inp->oid );
   return( &res );
}

int *r_new_export_1( inp )
   in_module *inp;
{
   static int res;
   res = new_export( inp->oid );
   return( &res );
}

int *r_new_import_1( inp )
   in_module *inp;
{
   static int res;
   res = new_import( inp->oid );
   return( &res );
}

int *r_delete_export_1( inp )
   in_module *inp;
{
   static int res;
   res = delete_export( inp->oid );
   return( &res );
}

int *r_delete_import_1( inp )
   in_module *inp;
{
   static int res;
   res = delete_import( inp->oid );
   return( &res );
}


/*************************************************************/


out_zaehler *r_update_zaehler_1( inp )
   in_zaehler *inp;
{
   static out_zaehler res;
   res.success = update_zaehler( inp->oid, inp->box,  &(res.count));
   return( &res );
}

out_zaehler *r_update_zaehler_ohne_huelle_1( inp )
   in_zaehler *inp;
{
   static out_zaehler res;
   res.success = update_zaehler_ohne_huelle( inp->oid, inp->box,  &(res.count));
   return( &res );
}


out_zaehler *r_get_zaehler_1( inp )
   in_zaehler *inp;
{
   static out_zaehler res;
   res.success = get_zaehler( inp->oid, inp->box,  &(res.count));
   return( &res );
}

int *r_start_get_histogramm_1( inp )
   in_zaehler *inp;
{
    static int res;
    res = start_get_histogramm( inp->oid, inp->box );
    return ( &res );
}

out_get_histogramm *r_get_histogramm_1()
{
    static out_get_histogramm res;
    res.success = get_histogramm( &(res.oid), &(res.count) );
    return ( &res );
}

int *r_update_histogramm_1( inp )
   in_zaehler *inp;
{
    static int res;
    res = update_histogramm( inp->oid, inp->box );
    return ( &res );
}

int *r_update_histogramm_with_restr_1( inp )
   in_upd_restr_hist *inp;
{
    static int res;
    res = update_histogramm_with_restr( inp->oid, inp->box , inp->src, inp->dst);
    return ( &res );
}

