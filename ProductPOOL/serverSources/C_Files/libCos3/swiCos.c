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


#include <string.h>

#include "SWI-Prolog.h"

#include "prolog.h"

#include "bim2c.h"
#include "objstore.h"
#include <stdio.h>


#define VARSTRING "\0"

foreign_t swi_init(term_t ret, term_t atom) {
    int res;
    char* str;
    if(!PL_is_atom(atom))
        PL_fail;

    PL_get_atom_chars(atom,&str);
    res=c_init(str);
    if(!PL_unify_integer(ret,res))
        PL_fail;
    PL_succeed;
}

foreign_t swi_test() {
    c_test();
    PL_succeed;
}

foreign_t swi_done() {
    c_done();
    PL_succeed;
}

foreign_t swi_retrieve_prop_query(term_t prop,term_t result) {

    char* tuple[4];
    term_t arg[4];
    int i;
    term_t result2;

    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<4;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_retrieve_prop_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_retrieve_prop_module_query(term_t prop,term_t result) {

    char* tuple[5];
    term_t arg[5];
    term_t result2;
    int i;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<5;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_retrieve_prop_module_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}


foreign_t swi_Attr_s_query(term_t prop,term_t result) {

    char* tuple[2];
    term_t arg[2];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<2;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_Attr_s_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}



foreign_t swi_In_s_query(term_t prop,term_t result) {

    char* tuple[2];
    term_t arg[2];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<2;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_In_s_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_In_i_query(term_t prop,term_t result) {

    char* tuple[2];
    term_t arg[2];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<2;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_In_i_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_Isa_query(term_t prop,term_t result) {

    char* tuple[2];
    term_t arg[2];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<2;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_Isa_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_sys_class_query(term_t prop,term_t result) {

    char* tuple[2];
    term_t arg[2];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<2;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_sys_class_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}


foreign_t swi_Adot_query(term_t prop,term_t result) {

    char* tuple[4];
    term_t arg[4];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<4;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_Adot_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}


foreign_t swi_Aidot_query(term_t prop,term_t result) {

    char* tuple[4];
    term_t arg[4];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<4;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_Aidot_query(tuple,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}


foreign_t swi_A_query(term_t prop,term_t result) {

    char* tuple[3];
    term_t arg[3];
    int i;
    term_t result2;
    if(!PL_is_compound(prop))
        PL_fail;

    for(i=0;i<3;i++) {
        arg[i]=PL_new_term_ref();
        if(!PL_get_arg(i+1,prop,arg[i]))
            PL_fail;
        if(PL_is_variable(arg[i]))
            tuple[i]=VARSTRING;
        else if(PL_is_atom(arg[i]))
            PL_get_atom_chars(arg[i],&(tuple[i]));
        else
            PL_fail;
    }
    result2=PL_new_term_ref();
    c_A_query(tuple,result2);
   if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_star_query(term_t atom,term_t result) {

    char* label;
    term_t result2;

    if(!PL_is_atom(atom))
        PL_fail;

    PL_get_atom_chars(atom,&label);
    result2=PL_new_term_ref();
    c_star_query(label,result2);
    if(PL_unify(result,result2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_create_name2id(term_t retterm, term_t labterm,term_t idterm) {

    char* label;
    char* id;
    int ret;

    if(!PL_is_atom(labterm))
        PL_fail;

    PL_get_atom_chars(labterm,&label);
    ret=c_create_name2id(label,&id);

    if(id && PL_unify_atom_chars(idterm,id) && PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_name2id(term_t retterm, term_t labterm,term_t idterm) {

    char* label;
    char* id;
    int ret;

    if(!PL_is_atom(labterm))
        PL_fail;

    PL_get_atom_chars(labterm,&label);
    ret=c_name2id(label,&id);

    if(id && PL_unify_atom_chars(idterm,id) && PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}


foreign_t swi_id2name(term_t retterm, term_t idterm,term_t labterm) {

    char* label;
    char* id;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_id2name(id,&label);

    if(label && PL_unify_atom_chars(labterm,label) && PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_select2id(term_t retterm, term_t labterm,term_t idterm) {

    char* label;
    char* id;
    int ret;

    if(!PL_is_atom(labterm))
        PL_fail;

    PL_get_atom_chars(labterm,&label);
    label=strdup(label);
    ret=c_select2id(label,&id);

    if(id && PL_unify_atom_chars(idterm,id) && PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}


foreign_t swi_id2select(term_t retterm, term_t idterm,term_t labterm) {

    char* label;
    char* id;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_id2select(id,&label);

    if(label && PL_unify_atom_chars(labterm,label) && PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}


foreign_t swi_id2starttime(term_t retterm, term_t idterm,term_t msterm, term_t secterm,
    term_t minterm, term_t hourterm, term_t dayterm, term_t monterm, term_t yearterm) {

    char* id;
    int ms,sec,min,hour,day,mon,year;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_id2starttime(id,&ms,&sec,&min,&hour,&day,&mon,&year);

    if(PL_unify_integer(msterm,ms) &&
       PL_unify_integer(secterm,sec) &&
       PL_unify_integer(minterm,min) &&
       PL_unify_integer(hourterm,hour) &&
       PL_unify_integer(dayterm,day) &&
       PL_unify_integer(monterm,mon) &&
       PL_unify_integer(yearterm,year) &&
       PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

/* same code as above; only difference is that end time of an object is 
   retrieved; would be nice to factor the common code out.
*/
foreign_t swi_id2endtime(term_t retterm, term_t idterm,term_t msterm, term_t secterm,
    term_t minterm, term_t hourterm, term_t dayterm, term_t monterm, term_t yearterm) {

    char* id;
    int ms,sec,min,hour,day,mon,year;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_id2endtime(id,&ms,&sec,&min,&hour,&day,&mon,&year);

    if(PL_unify_integer(msterm,ms) &&
       PL_unify_integer(secterm,sec) &&
       PL_unify_integer(minterm,min) &&
       PL_unify_integer(hourterm,hour) &&
       PL_unify_integer(dayterm,day) &&
       PL_unify_integer(monterm,mon) &&
       PL_unify_integer(yearterm,year) &&
       PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_check_implicit(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_check_implicit(id);

    if(PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_create_node(term_t retterm, term_t labterm, term_t idterm) {

    char* lab;
    char* id;
    int ret;

    if(!PL_is_atom(labterm))
        PL_fail;

    PL_get_atom_chars(labterm,&lab);
    ret=c_create_node(lab,&id);

    if(id && PL_unify_integer(retterm,ret) && PL_unify_atom_chars(idterm,id)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_create_implicit_node(term_t retterm, term_t labterm, term_t idterm) {

    char* lab;
    char* id;
    int ret;

    if(!PL_is_atom(labterm))
        PL_fail;

    PL_get_atom_chars(labterm,&lab);
    ret=c_create_implicit_node(lab,&id);

    if(id && PL_unify_integer(retterm,ret) && PL_unify_atom_chars(idterm,id)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_create_link(term_t retterm, term_t idterm, term_t srcterm, term_t labterm, term_t dstterm) {

    char* lab;
    char* id;
    char* src;
    char* dst;
    int ret;

    if(!PL_is_atom(labterm) || !PL_is_atom(srcterm) || !PL_is_atom(dstterm))
        PL_fail;

    PL_get_atom_chars(srcterm,&src);
    PL_get_atom_chars(labterm,&lab);
    PL_get_atom_chars(dstterm,&dst);
    ret=c_create_link(&id,src,lab,dst);

    if(id && PL_unify_integer(retterm,ret) && PL_unify_atom_chars(idterm,id)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_remove(term_t retterm, term_t idterm) {
    char* id;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_remove(id);

    if(PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

/* remove an object from the temporary store tmp1 */
foreign_t swi_removetmp(term_t retterm, term_t idterm) {
    char* id;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_removetmp(id);

    if(PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}


foreign_t swi_rename(term_t retterm, term_t newterm, term_t oldterm) {
    char* newlab;
    char* oldlab;
    int ret;

    if(!PL_is_atom(newterm) || !PL_is_atom(oldterm))
        PL_fail;

    PL_get_atom_chars(newterm,&newlab);
    PL_get_atom_chars(oldterm,&oldlab);
    ret=c_rename(newlab,oldlab);

    if(PL_unify_integer(retterm,ret)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_changeAttrValue(term_t attrterm, term_t dstterm) {
    char* attr;
    char* dst;

    if(!PL_is_atom(attrterm) || !PL_is_atom(dstterm))
        PL_fail;

    PL_get_atom_chars(attrterm,&attr);
    PL_get_atom_chars(dstterm,&dst);
    c_changeAttrValue(attr,dst);

    PL_succeed;
}

foreign_t swi_insert_commit() {
    c_insert_commit();
    PL_succeed;
}

foreign_t swi_insert_abort() {
    c_insert_abort();
    PL_succeed;
}

foreign_t swi_remove_abort() {
    c_remove_abort();
    PL_succeed;
}

foreign_t swi_remove_end() {
    c_remove_end();
    PL_succeed;
}

foreign_t swi_set_act() {
    c_set_act();
    PL_succeed;
}

foreign_t swi_set_temp() {
    c_set_temp();
    PL_succeed;
}

foreign_t swi_set_hist() {
    c_set_hist();
    PL_succeed;
}

foreign_t swi_set_persistency_level(term_t newlevelterm) {
    long newlevel;
    if (PL_unify_integer(newlevelterm,newlevel))
    {
      c_set_persistency_level((int)newlevel);
      PL_succeed;
    } 
    else PL_fail;
}

foreign_t swi_set_act_temp() {
    c_set_act_temp();
    PL_succeed;
}

foreign_t swi_set_overrule_temp() {
    c_set_overrule_temp();
    PL_succeed;
}

foreign_t swi_set_overrule_temp_tell() {
    c_set_overrule_temp_tell();
    PL_succeed;
}

foreign_t swi_set_overrule_temp_untell() {
    c_set_overrule_temp_untell();
    PL_succeed;
}

foreign_t swi_set_overrule_act() {
    c_set_overrule_act();
    PL_succeed;
}

foreign_t swi_set_act_hist() {
    c_set_act_hist();
    PL_succeed;
}

foreign_t swi_set_old_OB() {
    c_set_old_DB();
    PL_succeed;
}

foreign_t swi_set_new_OB() {
    c_set_new_DB();
    PL_succeed;
}

foreign_t swi_set_current_OB() {
    c_set_current_DB();
    PL_succeed;
}

foreign_t swi_get_sys_class(term_t retterm, term_t idterm, term_t clsterm) {
    char* id;
    char* cls;
    int ret;

    if(!PL_is_atom(idterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    ret=c_get_sys_class(id,&cls);

    if(cls && PL_unify_integer(retterm,ret) && PL_unify_atom_chars(clsterm,cls)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_get_prop_id(term_t retterm, term_t idterm) {
    char* id;
    int ret;

    ret=c_get_prop_id(&id);

    if(id && PL_unify_integer(retterm,ret) && PL_unify_atom_chars(idterm,id)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_set_time_point(term_t msec, term_t sec, term_t min, term_t hour, term_t day, term_t month, term_t year) {
    int imsec,isec,imin,ihour,iday,imonth,iyear;

    if(!PL_is_integer(msec) ||
       !PL_is_integer(sec) ||
       !PL_is_integer(min) ||
       !PL_is_integer(hour) ||
       !PL_is_integer(day) ||
       !PL_is_integer(month) ||
       !PL_is_integer(year)) {
        PL_fail;
    }

    PL_get_integer(msec,&imsec);
    PL_get_integer(sec,&isec);
    PL_get_integer(min,&imin);
    PL_get_integer(hour,&ihour);
    PL_get_integer(day,&iday);
    PL_get_integer(month,&imonth);
    PL_get_integer(year,&iyear);

    c_set_time_point(imsec,isec,imin,ihour,iday,imonth,iyear);
    PL_succeed;
}

foreign_t swi_set_search_point(term_t msec, term_t sec, term_t min, term_t hour, term_t day, term_t month, term_t year) {
    int imsec,isec,imin,ihour,iday,imonth,iyear;

    if(!PL_is_integer(msec) ||
       !PL_is_integer(sec) ||
       !PL_is_integer(min) ||
       !PL_is_integer(hour) ||
       !PL_is_integer(day) ||
       !PL_is_integer(month) ||
       !PL_is_integer(year)) {
        PL_fail;
    }

    PL_get_integer(msec,&imsec);
    PL_get_integer(sec,&isec);
    PL_get_integer(min,&imin);
    PL_get_integer(hour,&ihour);
    PL_get_integer(day,&iday);
    PL_get_integer(month,&imonth);
    PL_get_integer(year,&iyear);

    c_set_search_point(imsec,isec,imin,ihour,iday,imonth,iyear);
    PL_succeed;
}

foreign_t swi_delete_history_db(term_t msec, term_t sec, term_t min, term_t hour, term_t day, term_t month, term_t year) {
    int imsec,isec,imin,ihour,iday,imonth,iyear;

    if(!PL_is_integer(msec) ||
       !PL_is_integer(sec) ||
       !PL_is_integer(min) ||
       !PL_is_integer(hour) ||
       !PL_is_integer(day) ||
       !PL_is_integer(month) ||
       !PL_is_integer(year)) {
        PL_fail;
    }

    PL_get_integer(msec,&imsec);
    PL_get_integer(sec,&isec);
    PL_get_integer(min,&imin);
    PL_get_integer(hour,&ihour);
    PL_get_integer(day,&iday);
    PL_get_integer(month,&imonth);
    PL_get_integer(year,&iyear);

    c_delete_history_db(imsec,isec,imin,ihour,iday,imonth,iyear);
    PL_succeed;
}

foreign_t swi_update_zaehler(term_t retterm, term_t idterm, term_t boxterm, term_t countterm) {
    char* id;
    int box,ret;
    long count;

    if(!PL_is_atom(idterm) ||
       !PL_is_integer(boxterm)) {
        PL_fail;
    }

    PL_get_atom_chars(idterm,&id);
    PL_get_integer(boxterm,&box);

    ret=c_update_zaehler(id,box,&count);
    if(PL_unify_integer(retterm,ret) && PL_unify_integer(countterm,count)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_update_zaehler_ohne_huelle(term_t retterm, term_t idterm, term_t boxterm, term_t countterm) {
    char* id;
    int box,ret;
    long count;

    if(!PL_is_atom(idterm) ||
       !PL_is_integer(boxterm)) {
        PL_fail;
    }

    PL_get_atom_chars(idterm,&id);
    PL_get_integer(boxterm,&box);

    ret=c_update_zaehler_ohne_huelle(id,box,&count);
    if(PL_unify_integer(retterm,ret) && PL_unify_integer(countterm,count)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_get_zaehler(term_t retterm, term_t idterm, term_t boxterm, term_t countterm) {
    char* id;
    int box,ret;
    long count;

    if(!PL_is_atom(idterm) ||
       !PL_is_integer(boxterm)) {
        PL_fail;
    }

    PL_get_atom_chars(idterm,&id);
    PL_get_integer(boxterm,&box);

    ret=c_get_zaehler(id,box,&count);
    if(PL_unify_integer(retterm,ret) && PL_unify_integer(countterm,count)) {
        PL_succeed;
    }
    PL_fail;
}

foreign_t swi_update_histogramm(term_t retterm, term_t idterm, term_t dirterm) {
    char* id;
    int ret,dir;

    if(!PL_is_atom(idterm) || !PL_is_integer(dirterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    PL_get_integer(dirterm,&dir);

    ret=c_update_histogramm(id,dir);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_update_histogramm_with_restr(term_t retterm, term_t idterm, term_t dirterm, term_t srcterm, term_t dstterm) {
    char* id;
    char* src;
    char* dst;
    int ret,dir;

    if(!PL_is_atom(idterm) || !PL_is_atom(srcterm) || !PL_is_atom(dstterm) || !PL_is_integer(dirterm))
        PL_fail;

    PL_get_atom_chars(idterm,&id);
    PL_get_atom_chars(srcterm,&src);
    PL_get_atom_chars(dstterm,&dst);
    PL_get_integer(dirterm,&dir);

    ret=c_update_histogramm_with_restr(id,dir,src,dst);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_get_one_histogramm(term_t retterm, term_t idterm, term_t countterm) {
    char* id;
    int ret;
    long count;

    ret=c_get_histogramm(&id,&count);
    if(id && PL_unify_atom_chars(idterm,id) && PL_unify_integer(countterm,count) && PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_start_get_histogramm(term_t retterm, term_t idterm, term_t dirterm) {
    char* id;
    int ret,dir;

    if(!PL_is_atom(idterm) || !PL_is_integer(dirterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);
    PL_get_integer(dirterm,&dir);

    ret=c_start_get_histogramm(id,dir);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_set_module(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_set_module(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_set_overrule_module(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_set_overrule_module(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_initialize_module(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_initialize_module(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_system_module(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_system_module(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_new_export(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_new_export(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}


foreign_t swi_delete_export(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_delete_export(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}



foreign_t swi_new_import(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_new_import(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}


foreign_t swi_delete_import(term_t retterm, term_t idterm) {

    char* id;
    int ret;

    if(!PL_is_atom(idterm)) {
        PL_fail;
    }
    PL_get_atom_chars(idterm,&id);

    ret=c_delete_import(id);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}



void install_libCos() {

    /* init, test and done */
    REGISTER_FOREIGN("ExternalCodeLoader","init",2,swi_init,0);
    REGISTER_FOREIGN("ExternalCodeLoader","test",0,swi_test,0);
    REGISTER_FOREIGN("ExternalCodeLoader","done",0,swi_done,0);

    /* Queries */
    REGISTER_FOREIGN("ExternalCodeLoader","retrieve_prop_query",2,swi_retrieve_prop_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","retrieve_prop_module_query",2,swi_retrieve_prop_module_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Attr_s_query",2,swi_Attr_s_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","In_s_query",2,swi_In_s_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","In_i_query",2,swi_In_i_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Isa_query",2,swi_Isa_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","sys_class_query",2,swi_sys_class_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Adot_query",2,swi_Adot_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Aidot_query",2,swi_Aidot_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","A_query",2,swi_A_query,0);
    REGISTER_FOREIGN("ExternalCodeLoader","star_query",2,swi_star_query,0);

    /* id2name, name2id, ... */
    REGISTER_FOREIGN("ExternalCodeLoader","create_name2id",3,swi_create_name2id,0);
    REGISTER_FOREIGN("ExternalCodeLoader","name2id",3,swi_name2id,0);
    REGISTER_FOREIGN("ExternalCodeLoader","id2name",3,swi_id2name,0);
    REGISTER_FOREIGN("ExternalCodeLoader","select2id",3,swi_select2id,0);
    REGISTER_FOREIGN("ExternalCodeLoader","id2select",3,swi_id2select,0);
    REGISTER_FOREIGN("ExternalCodeLoader","id2starttime",9,swi_id2starttime,0);
    REGISTER_FOREIGN("ExternalCodeLoader","id2endtime",9,swi_id2endtime,0);

    /* create, remove, rename, ... */
    REGISTER_FOREIGN("ExternalCodeLoader","check_implicit",2,swi_check_implicit,0);
    REGISTER_FOREIGN("ExternalCodeLoader","create_node",3,swi_create_node,0);
    REGISTER_FOREIGN("ExternalCodeLoader","create_implicit_node",3,swi_create_implicit_node,0);
    REGISTER_FOREIGN("ExternalCodeLoader","create_link",5,swi_create_link,0);
    REGISTER_FOREIGN("ExternalCodeLoader","remove",2,swi_remove,0);
    REGISTER_FOREIGN("ExternalCodeLoader","removetmp",2,swi_removetmp,0);
    REGISTER_FOREIGN("ExternalCodeLoader","rename",3,swi_rename,0);
    REGISTER_FOREIGN("ExternalCodeLoader","changeAttrValue",2,swi_changeAttrValue,0);

    /* TA control: commit, abort */
    REGISTER_FOREIGN("ExternalCodeLoader","insert_commit",0,swi_insert_commit,0);
    REGISTER_FOREIGN("ExternalCodeLoader","insert_abort",0,swi_insert_abort,0);
    REGISTER_FOREIGN("ExternalCodeLoader","remove_abort",0,swi_remove_abort,0);
    REGISTER_FOREIGN("ExternalCodeLoader","remove_end",0,swi_remove_end,0);

    /* SearchSpace management: set... */
    REGISTER_FOREIGN("ExternalCodeLoader","set_act",0,swi_set_act,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_temp",0,swi_set_temp,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_hist",0,swi_set_hist,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_act_temp",0,swi_set_act_temp,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_overrule_temp",0,swi_set_overrule_temp,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_overrule_temp_tell",0,swi_set_overrule_temp_tell,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_overrule_temp_untell",0,swi_set_overrule_temp_untell,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_overrule_act",0,swi_set_overrule_act,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_act_hist",0,swi_set_act_hist,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_old_OB",0,swi_set_old_OB,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_new_OB",0,swi_set_new_OB,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_current_OB",0,swi_set_current_OB,0);

    /* Persistency */
    REGISTER_FOREIGN("ExternalCodeLoader","set_persistency_level",1,swi_set_persistency_level,0);

    /* System classes and time points */
    REGISTER_FOREIGN("ExternalCodeLoader","get_sys_class",3,swi_get_sys_class,0);
    REGISTER_FOREIGN("ExternalCodeLoader","get_prop_id",2,swi_get_prop_id,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_time_point",7,swi_set_time_point,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_search_point",7,swi_set_search_point,0);
    REGISTER_FOREIGN("ExternalCodeLoader","delete_history_db",7,swi_delete_history_db,0);

    /* Histograms */
    REGISTER_FOREIGN("ExternalCodeLoader","update_zaehler",4,swi_update_zaehler,0);
    REGISTER_FOREIGN("ExternalCodeLoader","update_zaehler_ohne_huelle",4,swi_update_zaehler_ohne_huelle,0);
    REGISTER_FOREIGN("ExternalCodeLoader","get_zaehler",4,swi_get_zaehler,0);
    REGISTER_FOREIGN("ExternalCodeLoader","update_histogramm",3,swi_update_histogramm,0);
    REGISTER_FOREIGN("ExternalCodeLoader","update_histogramm",5,swi_update_histogramm_with_restr,0);
    REGISTER_FOREIGN("ExternalCodeLoader","get_one_histogramm",3,swi_get_one_histogramm,0);
    REGISTER_FOREIGN("ExternalCodeLoader","start_get_histogramm",3,swi_start_get_histogramm,0);

    /* Modules */
    REGISTER_FOREIGN("ExternalCodeLoader","set_module",2,swi_set_module,0);
    REGISTER_FOREIGN("ExternalCodeLoader","set_overrule_module",2,swi_set_overrule_module,0);
    REGISTER_FOREIGN("ExternalCodeLoader","initialize_module",2,swi_initialize_module,0);
    REGISTER_FOREIGN("ExternalCodeLoader","system_module",2,swi_system_module,0);
    REGISTER_FOREIGN("ExternalCodeLoader","new_export",2,swi_new_export,0);
    REGISTER_FOREIGN("ExternalCodeLoader","delete_export",2,swi_delete_export,0);
    REGISTER_FOREIGN("ExternalCodeLoader","new_import",2,swi_new_import,0);
    REGISTER_FOREIGN("ExternalCodeLoader","delete_import",2,swi_delete_import,0);

}
