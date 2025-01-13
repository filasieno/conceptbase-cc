{*
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
*}

#MODULE(ViewCodeGenerator)
#ENDMODDECL()


#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(select2id/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(remove_multiple_elements/2,GeneralUtilities)
#IMPORT(outObjectName/2,ScanFormatUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(sys_In/2,Literals)
#IMPORT(untell_objproc/3,ObjectProcessor)
#IMPORT(attribute/1,validProposition)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(SetUpdateMode/1,TellAndAsk)
#IMPORT(RemoveUpdateMode/1,TellAndAsk)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{** Teil 1 **}
{ CodeFragmente fuer die C++-Klassen der Sichten }

{ CppViewAdmin }
{ name ist der Name des Views! }
#MODE((generate(i,i,i,o)))


generate(CppViewAdmin,description,_view,'This class handles the connection to the CBserver and
	processes the update messages from ConceptBase.').

generate(CppViewAdmin,className,_view,_viewman) :-
	pc_atomconcat(_view,'Admin',_viewman).

generate(CppViewAdmin,includes,_name,_incl) :-
	pc_atomconcat(['#include "CBviewAdmin.h"
#include "CBview.h"
#include "CBref.h"
#include "CBset.h"
#include "CBattribute.h"
#include "CBobjectName.h"
#include "',_name,'.h"\n'],_incl).

generate(CppViewAdmin,inheritance,_name,' : public CBviewAdmin').

generate(CppViewAdmin,friends,_name,'// Add your friend statements here').
generate(CppViewAdmin,constructors,_name,_const) :-
	replace_atom('%VIEW%Admin(char* host, int port, char* tool="%VIEW%Admin",char* user=NULL)
: CBviewAdmin(host,port,tool,user) {
    if (connected()) {
         CBanswer* ans=notificationRequest("view(%VIEW%)");
         if (ans)
             handleUpdateMessage(ans->getResult());
    }
}','%VIEW%',_name,_const).

generate(CppViewAdmin,destructors,_name,_dest) :-
	replace_atom('virtual ~%VIEW%Admin() {
}','%VIEW%',_name,_dest).

generate(CppViewAdmin,public,_name,'// Add your public declarations here!').
generate(CppViewAdmin,private,_name,'// Add your private declarations here!').




{ CppViewMain }
generate(CppViewMain,description,_name,_text) :-
	replace_atom('This class represents the main objects of view %VIEW%.','%VIEW%',_name,_text).

generate(CppViewMain,className,_name,_name).

generate(CppViewMain,includes,_name,_incl) :-
	save_setof(_sv,get_direct_subview(_name,_sv),_svlist),
	generate_include_list(_svlist,_incl1),
	pc_atomconcat('#include "CBview.h"
#include "CBref.h"
#include "CBset.h"
#include "CBattribute.h"
#include "CBobjectName.h"\n',_incl1,_incl).

generate(CppViewMain,inheritance,_name,' : public CBview').
generate(CppViewMain,friends,_name,_friend) :-
	replace_atom('friend class CBref< %VIEW% >;','%VIEW%',_name,_friend).

generate(CppViewMain,constructors,_name,_const) :-
	replace_atom('%VIEW%(const CBterm *t) : CBview(t) {
}','%VIEW%',_name,_const).

generate(CppViewMain,destructors,_name,_destr) :-
	replace_atom('virtual ~%VIEW%() {
}','%VIEW%',_name,_destr).

generate(CppViewMain,settype,_name,_set) :-
	replace_atom('CBset< CBref < %VIEW% > >','%VIEW%',_name,_set).

generate(CppViewMain,membername,_name,_var) :-
	pc_atomconcat(_name,'Set',_var).


generate(CppViewMain,handleInsert,_name,_ins) :-
	replace_atom('void handleInsert_%VIEW%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    if(!%VIEW%Set.insert(r))
        delete r;
}','%VIEW%',_name,_ins).

generate(CppViewMain,handleDelete,_name,_del) :-
	replace_atom('void handleDelete_%VIEW%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    %VIEW%Set.remove(*r);
    delete r;
}','%VIEW%',_name,_del).

generate(CppViewMain,public,_name,'// Add your public declarations here!').
generate(CppViewMain,private,_name,'// Add your private declarations here!').


{ CppSubViewMain }
generate(CppSubViewMain,description,_name,_text) :-
	replace_atom('This class represents the objects of the subview %SUBVIEW%.
	Normally, you access the objects via the main view.','%SUBVIEW%',_name,_text).

generate(CppSubViewMain,className,_name,_name).
generate(CppSubViewMain,includes,_name,_incl) :-
	save_setof(_sv,get_direct_subview(_name,_sv),_svlist),
	generate_include_list(_svlist,_incl1),
	pc_atomconcat('#include "CBsubView.h"
#include "CBref.h"
#include "CBset.h"
#include "CBattribute.h"
#include "CBobjectName.h"\n',_incl1,_incl).

generate(CppSubViewMain,inheritance,_name,' : public CBsubView').
generate(CppSubViewMain,friends,_name,_friend) :-
	generate(CppViewMain,friends,_name,_friend).

generate(CppSubViewMain,constructors,_name,_const) :-
	replace_atom('%VIEW%(const CBterm *t) : CBsubView(t) {
}','%VIEW%',_name,_const).

generate(CppSubViewMain,destructors,_name,_destr) :-
	generate(CppViewMain,destructors,_name,_destr).

generate(CppSubViewMain,settype,_name,_set) :-
	generate(CppViewMain,settype,_name,_set).

generate(CppSubViewMain,membername,_name,_var) :-
	generate(CppViewMain,membername,_name,_var).

generate(CppSubViewMain,handleInsert,_name,_ins) :-
	generate(CppViewMain,handleInsert,_name,_ins).

generate(CppSubViewMain,handleDelete,_name,_del) :-
	generate(CppViewMain,handleDelete,_name,_del).

generate(CppSubViewMain,public,_name,_pub) :-
	generate(CppViewMain,public,_name,_pub).

generate(CppSubViewMain,private,_name,_pri) :-
	generate(CppViewMain,private,_name,_pri).


{ CppAttribute }
{ _view ist der Name des Views, _attr der Attributlabel, und subview }
{ ist die Zielklasse f"ur das Attribut.}

#MODE((generate(i,i,i,i,i,o)))


{** DEFAULT **}
{ Attribut wird nur als Menge von einfachen Objektnamen dargestellt. }
generate(CppAttribute_default,description,_view,_attr,_subview,
'This variant represents the attribute as normal object
and does not respect any information of the attribute.').

generate(CppAttribute_default,type,_view,_attr,_subview,'CBattribute< CBobjectName >').

generate(CppAttribute_default,settype,_view,_attr,_subview,'CBset<CBattribute< CBobjectName > >').

generate(CppAttribute_default,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;
    CBobjectName* o=new CBobjectName(t->getArg(3));
    CBattribute<CBobjectName >* a=new CBattribute<CBobjectName >(t->getArg(2)->getFunctor(),o);
    if(!(*e)->%ATTR%.insert(a))
        delete a;
    }
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%ATTR%',_attr,_ins).

generate(CppAttribute_default,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else {
        delete r;
        CBobjectName* o=new CBobjectName(t->getArg(3));
        CBattribute<CBobjectName >* a=new CBattribute<CBobjectName >(t->getArg(2)->getFunctor(),o);
        (*e)->%ATTR%.remove(*a);
        delete a;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%ATTR%',_attr,_del).


{** PARTOF **}
{ Das Attribut ist ein Verweis auf einen SubView. Die einzelnen Attributwerte sind }
{ Referenzen auf den entsprechenden SubView. }
generate(CppAttribute_partof,description,_view,_attr,_subview,_desc) :-
	replace_atom('The attribute is specified as a partof-link.
The values are stored as instances
of the class %SUBVIEW%.','%SUBVIEW%',_subview,_desc).

generate(CppAttribute_partof,type,_view,_attr,_subview,_type) :-
	replace_atom('CBattribute< CBref< %SUBVIEW% > >','%SUBVIEW%',_subview,_type).

generate(CppAttribute_partof,settype,_view,_attr,_subview,_settype) :-
	replace_atom('CBset< CBattribute< CBref< %SUBVIEW% > > >','%SUBVIEW%',_subview,_settype).

generate(CppAttribute_partof,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;

    CBref< %SUBVIEW% >* d=new CBref< %SUBVIEW% >(t->getArg(3));
    CBref< %SUBVIEW% >* d2=%SUBVIEW%Set.find(*d);
    if (d2) {
        delete d;
        d=new CBref< %SUBVIEW% >(*d2);
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        if (!(*e)->%ATTR%.insert(a))
            delete a;
    }
    else {
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        %SUBVIEW%Set.insert(d);
        if(!(*e)->%ATTR%.insert(a))
            delete a;
    }
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%SUBVIEW%',_subview,_ins2),
	replace_atom(_ins2,'%ATTR%',_attr,_ins).

generate(CppAttribute_partof,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else {
        delete r;
        CBref< %SUBVIEW% >* d=new CBref< %SUBVIEW% >(t->getArg(3));
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        (*e)->%ATTR%.remove(*a);
        delete a;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%SUBVIEW%',_subview,_del2),
	replace_atom(_del2,'%ATTR%',_attr,_del).


{** SINGLE **}
{ Das Attribut hat nur einen Wert, Mengen sind also nicht noetig. }
{ Hier ist der Wert wieder nur ein einfacher Objektname. }
generate(CppAttribute_single,description,_view,_attr,_subview,_desc) :-
	replace_atom('There is only one attribute value for each instance of the class
%VIEW%. It is not necessary to store the attribute in a set.
Notice, that the attribute may have no value,
so there must be a correct NULL value for the attribute.','%VIEW%',_view,_desc).

generate(CppAttribute_single,type,_view,_attr,_subview,'CBattribute< CBobjectName >').

generate(CppAttribute_single,settype,_view,_attr,_subview,'CBattribute< CBobjectName >').

generate(CppAttribute_single,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;
    CBobjectName* o=new CBobjectName(t->getArg(3));
    CBattribute<CBobjectName >* a=new CBattribute<CBobjectName >(t->getArg(2)->getFunctor(),o);
    (*e)->%ATTR%=*a;
    delete a;
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%ATTR%',_attr,_ins).

generate(CppAttribute_single,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else {
        delete r;
        CBobjectName* o=new CBobjectName(t->getArg(3));
        CBattribute<CBobjectName >* a=new CBattribute<CBobjectName >(t->getArg(2)->getFunctor(),o);
        // Attribute is single, but is deleted
        // set attribute to a default value!
        // (*e)->%ATTR%=NULL;
        delete a;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%ATTR%',_attr,_del).


{** SINGLE & PARTOF **}
{ Das Attribut hat nur einen Wert, Mengen sind also nicht noetig. }
{ Hier ist der Wert eine Referenz auf einen SubView }
generate(CppAttribute_single_partof,description,_view,_attr,_subview,_desc) :-
	replace_atom('This attribute is specified as single and partof.
The attribute value is stored in a reference
to the subview %SUBVIEW%.Notice, that the attribute
may have no value, so there must be a correct NULL
value for the attribute.','%SUBVIEW%',_subview,_desc).

generate(CppAttribute_single_partof,type,_view,_attr,_subview,_type) :-
	replace_atom('CBattribute< CBref< %SUBVIEW% > >','%SUBVIEW%',_subview,_type).

generate(CppAttribute_single_partof,settype,_view,_attr,_subview,_settype) :-
	replace_atom('CBattribute< CBref< %SUBVIEW% > >','%SUBVIEW%',_subview,_settype).

generate(CppAttribute_single_partof,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;

    CBref< %SUBVIEW% >* d=new CBref< %SUBVIEW% >(t->getArg(3));
    CBref< %SUBVIEW% >* d2=%SUBVIEW%Set.find(*d);
    if (d2) {
        delete d;
        d=new CBref< %SUBVIEW% >(*d2);
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        (*e)->%ATTR%=*a;
        delete a;
    }
    else {
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        %SUBVIEW%Set.insert(d);
        (*e)->%ATTR%=*a;
        delete a;
    }
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%SUBVIEW%',_subview,_ins2),
	replace_atom(_ins2,'%ATTR%',_attr,_ins).

generate(CppAttribute_single_partof,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e) {
        delete r;
        return;
    }
    else {
        delete r;
        CBref< %SUBVIEW% >* d=new CBref< %SUBVIEW% >(t->getArg(3));
        CBattribute<CBref< %SUBVIEW% > >* a=new CBattribute<CBref< %SUBVIEW% > >(t->getArg(2)->getFunctor(),d);
        // Attribute is single, but is deleted
        // set attribute to a default value!
        // (*e)->%ATTR%=NULL;
        delete a;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%SUBVIEW%',_subview,_del2),
	replace_atom(_del2,'%ATTR%',_attr,_del).




{** INTEGER **}
{ Attribut hat als Zielklasse Integer. }
generate(CppAttribute_integer,description,_view,_attr,_subview,_desc) :-
	replace_atom('The class %SUBVIEW% is a subclass of Integer. Therefore,
the type of attribute is int, new values are added
and deleted values are subtracted.','%SUBVIEW%',_subview,_desc).

generate(CppAttribute_integer,type,_view,_attr,_subview,'int').

generate(CppAttribute_integer,settype,_view,_attr,_subview,'int').

generate(CppAttribute_integer,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;
    int i=(int) (t->getArg(3));
    (*e)->%ATTR%+=i;
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%ATTR%',_attr,_ins).

generate(CppAttribute_integer,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else {
        delete r;
        int i=(int) (t->getArg(3));
        (*e)->%ATTR%-=i;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%ATTR%',_attr,_del).

{** REAL **}
{ Attribut hat als Zielklasse Real. }
generate(CppAttribute_real,description,_view,_attr,_subview,_desc) :-
	replace_atom('The class %SUBVIEW% is a subclass of Real. Therefore,
the type of attribute is double, new values are added
and deleted values are subtracted.','%SUBVIEW%',_subview,_desc).

generate(CppAttribute_real,type,_view,_attr,_subview,'double').

generate(CppAttribute_real,settype,_view,_attr,_subview,'double').

generate(CppAttribute_real,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;
    double d=(double) (t->getArg(3));
    (*e)->%ATTR%+=d;
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%ATTR%',_attr,_ins).

generate(CppAttribute_real,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else {
        delete r;
        double d=(double) (t->getArg(3));
        (*e)->%ATTR%-=d;
    }
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%ATTR%',_attr,_del).


{** STRING **}
{ Attribut hat als Zielklasse String. }
generate(CppAttribute_string,description,_view,_attr,_subview,_desc) :-
	replace_atom('The type of attribute is char*, new values overwrites
the old value and when the attribute is deleted, the string is deallocated.
Notice, that this is only useful for "single" strings.','%SUBVIEW%',_subview,_desc).

generate(CppAttribute_string,type,_view,_attr,_subview,'char*').

generate(CppAttribute_string,settype,_view,_attr,_subview,'char*').

generate(CppAttribute_string,handleInsert,_view,_attr,_subview,_ins) :-
	replace_atom('void handleInsert_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        %VIEW%Set.insert(r);
        e=r;
    }
    else
        delete r;
    delete (*e)->%ATTR%;
    (*e)->%ATTR%=decodeString((char*) (t->getArg(3)));
}','%VIEW%',_view,_ins1),
	replace_atom(_ins1,'%ATTR%',_attr,_ins).

generate(CppAttribute_string,handleDelete,_view,_attr,_subview,_del) :-
	replace_atom('void handleDelete_%VIEW%_%ATTR%(CBterm* t) {
    CBref< %VIEW% >* r=new CBref< %VIEW% >(t->getArg(1));
    CBref< %VIEW% >* e=%VIEW%Set.find(*r);
    if (!e)  {
        delete r;
        return;
    }
    else
        delete r;
    delete (*e)->%ATTR%;
    (*e)->%ATTR%=NULL;
}','%VIEW%',_view,_del1),
	replace_atom(_del1,'%ATTR%',_attr,_del).





{** Teil 2 **}
{ Generierung eines Terms, der die Codefragmente eines Views enthaelt }

#MODE((generate_cpp_code(i,o)))

generate_cpp_code(_view,CppViewCode(_view,_l1,_l2,_l3,_l4)) :-
	generate_view_admin_code(_view,_l1),
	!,
	generate_view_main_code(_view,_l2),
	!,
	generate_subview_code(_view,_l3),
	!,
	generate_attribute_code(_view,_l4),
	!.


{** ViewAdmin **}

generate_view_admin_code(_view,CppViewAdmin(_viewadmin,_codelist)) :-
	pc_atomconcat(_view,'Admin',_viewadmin),
	setof(code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_pub,_pri),
		get_view_admin_code(_view,code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_pub,_pri)),
    _codelist).

get_view_admin_code(_view,_encatoms) :-
	generate(CppViewAdmin,description,_view,_desc),
	generate(CppViewAdmin,className,_view,_classname),
	generate(CppViewAdmin,includes,_view,_incl),
	generate(CppViewAdmin,inheritance,_view,_inh),
   	generate(CppViewAdmin,friends,_view,_friends),
   	generate(CppViewAdmin,constructors,_view,_cons),
   	generate(CppViewAdmin,destructors,_view,_dest),
	generate(CppViewAdmin,public,_view,_pub),
	generate(CppViewAdmin,private,_view,_pri),
	encodeAtoms2(code(default,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_pub,_pri),_encatoms).

get_view_admin_code(_view,code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_pub,_pri)) :-
	name2id(_view,_viewid),
	name2id(CppViewAdmin,_cppid),
	name2id(CppViewApi,_apiid),
	prove_literal(In(_viewmain,_apiid)),
	prove_literal(A(_viewmain,itsView,_viewid)),
	prove_literal(A(_viewmain,itsAdmin,_viewmanid)),
	prove_literal(In(_viewmanid,_cppid)),
	id2name(_viewmain,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_viewmanid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_viewmanid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_viewmanid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_viewmanid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_viewmanid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_viewmanid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_viewmanid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_viewmanid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_viewmanid,private,_prid)),
	id2name(_prid,_pri).


{ ViewMain }
generate_view_main_code(_view,CppViewMain(_view,_codelist)) :-
	_itsview = _view,
	setof(code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri,_itsview),
		get_view_main_code(_view,code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri)),
		_codelist).


get_view_main_code(_view,_encatoms) :-
	generate(CppViewMain,description,_view,_desc),
	generate(CppViewMain,className,_view,_classname),
	generate(CppViewMain,includes,_view,_incl),
	generate(CppViewMain,inheritance,_view,_inh),
   	generate(CppViewMain,friends,_view,_friends),
   	generate(CppViewMain,constructors,_view,_cons),
  	generate(CppViewMain,destructors,_view,_dest),
	generate(CppViewMain,settype,_view,_settype),
	generate(CppViewMain,membername,_view,_member),
	generate(CppViewMain,handleInsert,_view,_ins),
	generate(CppViewMain,handleDelete,_view,_del),
	generate(CppViewMain,public,_view,_pub),
	generate(CppViewMain,private,_view,_pri),
	encodeAtoms2(code(default,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri),_encatoms).


get_view_main_code(_view,code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri)) :-
	name2id(_view,_viewid),
	name2id(CppMainView,_cppid),
	name2id(CppViewApi,_apiid),
	prove_literal(In(_cppview,_apiid)),
	prove_literal(A(_cppview,itsView,_viewid)),
	prove_literal(A(_cppview,itsMainView,_viewmainid)),
	prove_literal(In(_viewmainid,_cppid)),
	id2name(_cppview,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_viewmainid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_viewmainid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_viewmainid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_viewmainid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_viewmainid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_viewmainid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_viewmainid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_viewmainid,settype,_setid)),
	id2name(_setid,_settype),
	prove_literal(A(_viewmainid,membername,_memid)),
	id2name(_memid,_member),
	prove_literal(A(_viewmainid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_viewmainid,handleDelete,_delid)),
	id2name(_delid,_del),
	prove_literal(A(_viewmainid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_viewmainid,private,_prid)),
	id2name(_prid,_pri).


{ SubViewMain }
generate_subview_code(_view,_svcodelist) :-
	save_setof(_subviewcode,[_subview]^(get_subview(_view,_subview),
			generate_subview_code2(_subview,_subviewcode)),
			_svcodelist).

generate_subview_code2(_subview,CppSubViewMain(_subview,_codelist)) :-
	_itsview = _subview,
	setof(code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri,_itsview),
		get_subview_code(_subview,code(_label,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri)),
		_codelist).

get_subview(_view,_subview) :-
	name2id(_view,_viewid),
	name2id(SubView,_svid),
	is_partof(_viewid,_subviewid),
	prove_literal(Isa(_subviewid,_subviewid2)),
	prove_literal(In(_subviewid2,_svid)),
	id2name(_subviewid2,_subview).

get_subview(_view,_subsubview) :-
	name2id(_view,_viewid),
	name2id(SubView,_svid),
	is_partof(_viewid,_subviewid),
	prove_literal(Isa(_subviewid,_subviewid2)),
	prove_literal(In(_subviewid2,_svid)),
	id2name(_subviewid2,_subview),
	get_subview(_subview,_subsubview).

get_direct_subview(_view,_subview) :-
	name2id(_view,_viewid),
	name2id(SubView,_svid),
	prove_literal(A(_viewid,partof,_subviewid)),
	prove_literal(Isa(_subviewid,_subviewid2)),
	prove_literal(In(_subviewid2,_svid)),
	id2name(_subviewid2,_subview).

is_partof(_viewid,_subviewid) :-
	prove_literal(A(_viewid,partof,_subviewid)).

get_subview_code(_view,_encatoms) :-
	generate(CppSubViewMain,description,_view,_desc),
	generate(CppSubViewMain,className,_view,_classname),
	generate(CppSubViewMain,includes,_view,_incl),
	generate(CppSubViewMain,inheritance,_view,_inh),
   	generate(CppSubViewMain,friends,_view,_friends),
   	generate(CppSubViewMain,constructors,_view,_cons),
   	generate(CppSubViewMain,destructors,_view,_dest),
	generate(CppSubViewMain,settype,_view,_settype),
	generate(CppSubViewMain,membername,_view,_member),
	generate(CppSubViewMain,handleInsert,_view,_ins),
	generate(CppSubViewMain,handleDelete,_view,_del),
	generate(CppSubViewMain,public,_view,_pub),
	generate(CppSubViewMain,private,_view,_pri),
	encodeAtoms2(code(default,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri),_encatoms).


get_subview_code(_subview,code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri)) :-
	name2id(_subview,_subviewid),
	name2id(CppSubView,_cppid),
	name2id(CppViewApi,_apiid),
	prove_literal(In(_cppview,_apiid)),
	prove_literal(A(_cppview,itsView,_viewid)),
	prove_literal(A(_cppview,itsSubViews,_viewmainid)),
	prove_literal(A(_viewmainid,itsView,_subviewid)),
	prove_literal(In(_viewmainid,_cppid)),
	id2name(_cppview,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_viewmainid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_viewmainid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_viewmainid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_viewmainid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_viewmainid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_viewmainid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_viewmainid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_viewmainid,settype,_setid)),
	id2name(_setid,_settype),
	prove_literal(A(_viewmainid,membername,_memid)),
	id2name(_memid,_member),
	prove_literal(A(_viewmainid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_viewmainid,handleDelete,_delid)),
	id2name(_delid,_del),
	prove_literal(A(_viewmainid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_viewmainid,private,_prid)),
	id2name(_prid,_pri).


{ Attribute }
generate_attribute_code(_view,_attrcodelist) :-
	save_setof(_attrcode,[_attrview,_attr,_subview]^
	         (get_attribute(_view,_attrview,_attr,_subview),
	          generate_attribute_code2(_attrview,_attr,_subview,_attrcode)
			 ),
		  _attrcodelist).

generate_attribute_code2(_attrview,_attr,_subview,CppAttribute(_attrname,_codelist)) :-
	pc_atomconcat([_attrview,'.',_attr],_attrname),
	pc_atomconcat([_attrview,'!',_attr],_select),
	setof(code(_label,_desc,_type,_settype,_ins,_del,_attrview,_select),
		get_attribute_code(_attrview,_attr,_subview,code(_label,_desc,_type,_settype,_ins,_del)),
		_codelist).

get_attribute(_view,_view,_attr,_subview) :-
	name2id(_view,_viewid),
	is_relevant_attribute(_viewid,_attr,_subviewid),
	id2name(_subviewid,_subview).

get_attribute(_view,_subview,_attr,_subsubview) :-
	get_direct_subview(_view,_sview),
	get_attribute(_sview,_subview,_attr,_subsubview).


is_relevant_attribute(_viewid,_attrlabel,_subviewid) :-
	prove_literal(P(_id,_viewid,_attrlabel,_subviewid2)),
	prove_literal(P(_subviewid2,_,_deriveatom,_)),
   	pc_atom_to_term(_deriveatom,_deriveterm),
	(_deriveterm=derive(_subviewid,_);
	 (_deriveterm\=derive(_,_),
	  _subviewid=_subviewid2
	)),
	prove_literal(P(_rattr,id_65,retrieved_attribute,_)),   {* id_65 = QueryClass *}
	prove_literal(P(_cattr,id_65,computed_attribute,_)),
	(prove_literal(In(_id,_rattr));
	 prove_literal(In(_id,_cattr))
	).


get_attribute_code(_view,_attr,_subview,_code) :-
	((get_attr_default(_view,_attr,_subview,_code));
	 (is_single(_view,_attr,_subview),
	  get_attr_single(_view,_attr,_subview,_code));
	 (is_single(_view,_attr,_subview),
	  is_partof(_view,_attr,_subview),
	  get_attr_single_partof(_view,_attr,_subview,_code));
	 (is_partof(_view,_attr,_subview),
	  get_attr_partof(_view,_attr,_subview,_code));
	 (is_integer(_view,_attr,_subview),
	  get_attr_integer(_view,_attr,_subview,_code));
	 (is_real(_view,_attr,_subview),
	  get_attr_real(_view,_attr,_subview,_code));
	 ({ is_string(_view,_attr,_subview), }  { String immer erlauben }
	  get_attr_string(_view,_attr,_subview,_code))
	).


get_attribute_code(_view,_attr,_subview,code(_encapiname,_desc,_type,_settype,_ins,_del)) :-
	pc_atomconcat([_view,'!',_attr],_sel),
	select2id(_sel,_selid),
	name2id(CppAttribute,_cppid),
	name2id(CppViewApi,_apiid),
	prove_literal(In(_viewapi,_apiid)),
	prove_literal(A(_viewapi,itsAttributes,_cppattrid)),
	prove_literal(A(_cppattrid,itsAttribute,_selid)),
	prove_literal(In(_cppattrid,_cppid)),
	id2name(_viewapi,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_cppattrid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_cppattrid,type,_typeid)),
	id2name(_typeid,_type),
	prove_literal(A(_cppattrid,settype,_settypeid)),
	id2name(_settypeid,_settype),
	prove_literal(A(_cppattrid,settype,_settypeid)),
	id2name(_settypeid,_settype),
	prove_literal(A(_cppattrid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_cppattrid,handleDelete,_delid)),
	id2name(_delid,_del).



get_attr_default(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_default,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_default,type,_view,_attr,_subview,_type),
	generate(CppAttribute_default,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_default,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_default,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(default,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_single(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_single,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_single,type,_view,_attr,_subview,_type),
	generate(CppAttribute_single,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_single,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_single,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(Single,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_single_partof(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_single_partof,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_single_partof,type,_view,_attr,_subview,_type),
	generate(CppAttribute_single_partof,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_single_partof,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_single_partof,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(Single_Partof,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_partof(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_partof,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_partof,type,_view,_attr,_subview,_type),
	generate(CppAttribute_partof,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_partof,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_partof,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(Partof,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_integer(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_integer,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_integer,type,_view,_attr,_subview,_type),
	generate(CppAttribute_integer,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_integer,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_integer,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(Integer,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_real(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_real,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_real,type,_view,_attr,_subview,_type),
	generate(CppAttribute_real,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_real,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_real,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(Real,_desc,_type,_settype,_ins,_del),_enccode).

get_attr_string(_view,_attr,_subview,_enccode) :-
	generate(CppAttribute_string,description,_view,_attr,_subview,_desc),
	generate(CppAttribute_string,type,_view,_attr,_subview,_type),
	generate(CppAttribute_string,settype,_view,_attr,_subview,_settype),
	generate(CppAttribute_string,handleInsert,_view,_attr,_subview,_ins),
	generate(CppAttribute_string,handleDelete,_view,_attr,_subview,_del),
	encodeAtoms2(code(String,_desc,_type,_settype,_ins,_del),_enccode).



is_single(_view,_attr,_subview) :-
	pc_atomconcat([_view,'!',_attr],_sel),
	select2id(_sel,_selid),
	name2id(Single,_singleid),
	prove_literal(In(_selid,_singleid)).

is_partof(_view,_attr,_subview) :-
	pc_atomconcat([_view,'!',_attr],_sel),
	select2id(_sel,_selid),
	select2id('View!partof',_pid),
	prove_literal(In(_selid,_pid)).

is_integer(_view,_attr,_subview) :-
	name2id(_subview,_svid),
	name2id(Integer,_intid),
	prove_literal(Isa(_svid,_intid)).

is_real(_view,_attr,_subview) :-
	name2id(_subview,_svid),
	name2id(Real,_realid),
	prove_literal(Isa(_svid,_realid)).

is_string(_view,_attr,_subview) :-
	name2id(_subview,_svid),
	name2id(String,_strid),
	prove_literal(Isa(_svid,_strid)).


{** Teil 3 **}
{ Laden einer fertigen Programmierschnittstelle }

load_api(_api,CppViewCode(_view,_admin,_main,_subviews,_attrs)) :-
	name2id(_api,_apiid),
	prove_literal(A(_apiid,itsView,_viewid)),
	id2name(_viewid,_view),
	load_admin(_apiid,_admin),
	load_main(_apiid,_main),
	load_subviews(_apiid,_subviews),
	load_attributes(_apiid,_attrs).


load_admin(_apiid,CppViewAdmin(_admin,[code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_pub,_pri)])) :-
	id2name(_apiid,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_apiid,itsAdmin,_admid)),
	id2name(_admid,_admin),
	prove_literal(A(_admid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_admid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_admid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_admid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_admid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_admid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_admid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_admid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_admid,private,_prid)),
	id2name(_prid,_pri).


load_main(_apiid,CppViewMain(_viewmain,[code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri,_itsview)])) :-
	id2name(_apiid,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	prove_literal(A(_apiid,itsMainView,_viewmainid)),
	id2name(_viewmainid,_viewmain),
	prove_literal(A(_viewmainid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_viewmainid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_viewmainid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_viewmainid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_viewmainid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_viewmainid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_viewmainid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_viewmainid,settype,_setid)),
	id2name(_setid,_settype),
	prove_literal(A(_viewmainid,membername,_memid)),
	id2name(_memid,_member),
	prove_literal(A(_viewmainid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_viewmainid,handleDelete,_delid)),
	id2name(_delid,_del),
	prove_literal(A(_viewmainid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_viewmainid,private,_prid)),
	id2name(_prid,_pri),
	prove_literal(A(_viewmainid,itsView,_itsviewid)),
	id2name(_itsviewid,_itsview).


load_subviews(_apiid,_svlist) :-
	save_setof(_svcode,[_cppsvid]^
			(prove_literal(A(_apiid,itsSubViews,_cppsvid)),
			 load_subview(_apiid,_cppsvid,_svcode)),
			_svlist).

load_subview(_apiid,_cppsvid,CppSubViewMain(_name,[code(_encapiname,_desc,_classname,_incl,_inh,_friends,_cons,_dest,_settype,_member,_ins,_del,_pub,_pri,_itsview)])) :-
	id2name(_apiid,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	id2name(_cppsvid,_name),
	prove_literal(A(_cppsvid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_cppsvid,className,_nameid)),
	id2name(_nameid,_classname),
	prove_literal(A(_cppsvid,includes,_inclid)),
	id2name(_inclid,_incl),
	prove_literal(A(_cppsvid,inheritance,_inhid)),
	id2name(_inhid,_inh),
	prove_literal(A(_cppsvid,friends,_frid)),
	id2name(_frid,_friends),
	prove_literal(A(_cppsvid,constructors,_cid)),
	id2name(_cid,_cons),
	prove_literal(A(_cppsvid,destructors,_did)),
	id2name(_did,_dest),
	prove_literal(A(_cppsvid,settype,_setid)),
	id2name(_setid,_settype),
	prove_literal(A(_cppsvid,membername,_memid)),
	id2name(_memid,_member),
	prove_literal(A(_cppsvid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_cppsvid,handleDelete,_delid)),
	id2name(_delid,_del),
	prove_literal(A(_cppsvid,public,_pubid)),
	id2name(_pubid,_pub),
	prove_literal(A(_cppsvid,private,_prid)),
	id2name(_prid,_pri),
	prove_literal(A(_cppsvid,itsView,_itsviewid)),
	id2name(_itsviewid,_itsview).


load_attributes(_apiid,_attrlist) :-
	save_setof(_attrcode,[_cppattrid]^
			(prove_literal(A(_apiid,itsAttributes,_cppattrid)),
			 load_attribute(_apiid,_cppattrid,_attrcode)),
			_attrlist).

load_attribute(_apiid,_cppattrid,CppAttribute(_name,[code(_encapiname,_desc,_type,_settype,_ins,_del,_view,_attrname)])) :-
	id2name(_apiid,_apiname),
	encodeAtoms3([_apiname],[_encapiname]),
	id2name(_cppattrid,_name),
	prove_literal(A(_cppattrid,description,_descid)),
	id2name(_descid,_desc),
	prove_literal(A(_cppattrid,type,_typeid)),
	id2name(_typeid,_type),
	prove_literal(A(_cppattrid,settype,_settypeid)),
	id2name(_settypeid,_settype),
	prove_literal(A(_cppattrid,settype,_settypeid)),
	id2name(_settypeid,_settype),
	prove_literal(A(_cppattrid,handleInsert,_insid)),
	id2name(_insid,_ins),
	prove_literal(A(_cppattrid,handleDelete,_delid)),
	id2name(_delid,_del),
	prove_literal(A(_cppattrid,isAttributeOf,_viewid)),
	id2name(_viewid,_view),
	prove_literal(A(_cppattrid,itsAttribute,_attrid)),
	outObjectName(_attrid,_attrname).


{** Teil 4 **}
{ Loeschen einer Schnittstelle }

delete_api(_api) :-
	name2id(_api,_apiid),
	get_all_api_ids(_apiid,_duplist),
	remove_multiple_elements(_duplist,_idlist),
	build_frag_from_ids(_idlist,_frags),
	!,
        SetUpdateMode(UPDATE),
	untell_objproc(_frags,_gen,_err),
	_err == noerror,
	!,
        RemoveUpdateMode(_).

get_all_api_ids(_apiid,[_apiid|_list]) :-
	get_all_ids([_apiid],_list1),
	setof(_id,(prove_literal(A(_apiid,itsAdmin,_id));
			   prove_literal(A(_apiid,itsMainView,_id));
			   prove_literal(A(_apiid,itsSubViews,_id));
			   prove_literal(A(_apiid,itsAttributes,_id))
			  ),
		  _idlist),
	get_all_ids(_idlist,_list2),
	append(_list1,_list2,_list).

get_all_ids([],[]).

get_all_ids([_id|_r],_list) :-
	get_in(_id,_inlist),
	!,
	get_isa(_id,_isalist),
	!,
	get_attr(_id,_attrlist),
	!,
	get_attrval(_id,_attrlist,_attrvallist),
	!,
	append(_inlist,_isalist,_list1),
	append(_attrlist,_list1,_list2),
	append(_attrvallist,_list2,_list3),
	!,
	get_all_ids(_r,_list4),
	append(_list3,_list4,_list).


get_in(_id,_inlist) :-
	setof(_in,_x ^ prove_literal(P(_in,_id,'*instanceof',_x)),_inlist);
	_inlist = [].

get_isa(_id,_isalist) :-
	setof(_isa,_x ^ prove_literal(P(_isa,_id,'*isa',_x)),_isalist);
	_isalist = [].

get_attr(_id,_list) :-
	(setof(_a, [_l,_y,_id2,_c,_ml,_d] ^ (prove_literal(P(_a,_id,_l,_y)),
		    attribute(P(_a,_id,_l,_y)),
        	prove_literal(In_e(_a,_id2)),
			prove_literal(P(_id2,_c,_ml,_d)),
    		attribute(P(_id2,_c,_ml,_d))),
		  _alist);
	_alist = []),
	get_attrin(_alist,_ainlist),
	append(_alist,_ainlist,_list).

get_attrin([],[]).

get_attrin([_a|_rest],_ainlist) :-
	get_in(_a,_list1),
	get_attrin(_rest,_list2),
	append(_list1,_list2,_ainlist).


get_attrval(_id,[],[]).
get_attrval(_id,[_a|_rest],_list) :-
	(setof(_d,[_l] ^ (prove_literal(P(_a,_id,_l,_d)),
			deletable_string(_d,_id)),
		  _dlist);
	_dlist = []),
	get_attrin(_dlist,_dinlist),
	get_attrval(_id,_rest,_rlist),
	append(_dlist,_dinlist,_list2),
	append(_list2,_rlist,_list).


deletable_string(_d,_id) :-
	name2id(String,_strid),
	prove_literal(In(_d,_strid)),
	not (prove_literal(P(_,_x,_,_d)), _x \== _d, _x \== _id),
	not (prove_literal(P(_,_d,_,_x)), _x \== _d, _x \== _id, _x \== _strid).


build_frag_from_ids([],[]).
build_frag_from_ids([_x|_xs],[_f|_fs]) :-
	sys_In(_x,_c),
	_f = SMLfragment(what(_x),
		in_omega([class(_c)]),
		in([]),
		isa([]),
		with([])),
	build_frag_from_ids(_xs,_fs).

{** Teil 5 **}
{ Generieren der Dateien }
generate_files(_api,_directory) :-
	name2id(_api,_apiid),
	generate_admin_file(_apiid,_directory),
	!,
	generate_view_files(_apiid,_directory).


{ Generiere Header-Datei fuer ViewAdmin-Klasse }
generate_admin_file(_apiid,_directory) :-
	prove_literal(A(_apiid,itsAdmin,_admid)),
	get_admin_class_code(_apiid,_codelist),
	store_admin_class_code(_admid,_codelist,_directory).


get_admin_class_code(_apiid,_codelist) :-
	setof(code(_view,_ins,_del),
		get_views_and_attrs(_apiid,_view,_ins,_del),
		_codelist).

get_views_and_attrs(_apiid,view(_view,_set,_membername),_ins,_del) :-
	(prove_literal(A(_apiid,itsMainView,_cppviewid));
	 prove_literal(A(_apiid,itsSubViews,_cppviewid))
	),
	prove_literal(A(_cppviewid,itsView,_viewid)),
	id2name(_viewid,_view),
	prove_literal(A(_cppviewid,settype,_setid)),
	decodeIdString(_setid,_set),
	prove_literal(A(_cppviewid,membername,_memberid)),
	decodeIdString(_memberid,_membername),
	prove_literal(A(_cppviewid,handleInsert,_insid)),
	decodeIdString(_insid,_ins),
	prove_literal(A(_cppviewid,handleDelete,_delid)),
	decodeIdString(_delid,_del).

get_views_and_attrs(_apiid,attr(_view,_label),_ins,_del) :-
	prove_literal(A(_apiid,itsAttributes,_cppattrid)),
	prove_literal(A(_cppattrid,isAttributeOf,_viewid)),
	id2name(_viewid,_view),
	prove_literal(A(_cppattrid,itsAttribute,_attrid)),
	prove_literal(P(_attrid,_,_label,_)),
	prove_literal(A(_cppattrid,handleInsert,_insid)),
	decodeIdString(_insid,_ins),
	prove_literal(A(_cppattrid,handleDelete,_delid)),
	decodeIdString(_delid,_del).

store_admin_class_code(_admid,_codelist,_dir) :-
	prove_literal(A(_admid,className,_classnameid)),
	decodeIdString(_classnameid,_classname),
	prove_literal(A(_admid,description,_descid)),
	decodeIdString(_descid,_desc),
	prove_literal(A(_admid,includes,_incid)),
	decodeIdString(_incid,_includes),
	prove_literal(A(_admid,inheritance,_inhid)),
	decodeIdString(_inhid,_inheritance),
	prove_literal(A(_admid,friends,_frid)),
	decodeIdString(_frid,_friends),
	prove_literal(A(_admid,constructors,_consid)),
	decodeIdString(_consid,_cons),
	prove_literal(A(_admid,destructors,_destid)),
	decodeIdString(_destid,_dest),
	prove_literal(A(_admid,public,_pubid)),
	decodeIdString(_pubid,_public),
	prove_literal(A(_admid,private,_privid)),
	decodeIdString(_privid,_private),
	buildHandle(_codelist,_handlemethods),
	buildSetDeclarations(_codelist,_sets),
	pc_atomconcat([_dir,'/',_classname,'.h'],_fname),
	pc_fopen(admfile,_fname,w),
	write(admfile,'/*  Generated by ConceptBase \n\n'),
	write(admfile,_desc),
	write(admfile,' */\n\n\n'),
	write(admfile,'#ifndef _'),
	write(admfile,_classname),
	write(admfile,'_H_\n'),
	write(admfile,'#define _'),
	write(admfile,_classname),
	write(admfile,'_H_\n\n\n'),
	write(admfile,_includes),
	write(admfile,'\n\nclass '),
	write(admfile,_classname),
	write(admfile,' '),
	write(admfile,_inheritance),
	write(admfile,' { \n\n\n'),
	write(admfile,_friends),
	write(admfile,'\n\n public: \n\n'),
	write(admfile,_cons),
	nl(admfile),nl(admfile),
	write(admfile,_dest),
	nl(admfile),nl(admfile),
	write(admfile,'    /* These are the generated and user-defined handle-Methods */\n'),
	write(admfile,_handlemethods),
	nl(admfile),nl(admfile),
	write(admfile,'    /* These are the generated member variables for views and sub views */\n'),
	write(admfile,_sets),
	nl(admfile),nl(admfile),
	write(admfile,'    /* Userdefined public methods and declarations */\n'),
	write(admfile,_public),
	nl(admfile),nl(admfile),
	write(admfile,' private:\n'),
	write(admfile,'    /* Userdefined public methods and declarations */\n'),
	write(admfile,_private),
	nl(admfile),nl(admfile),
	write(admfile,'};\n\n'),
	write(admfile,'#endif\n'),
	pc_fclose(admfile).

#MODE((buildHandle(i,o)))

buildHandle(_codelist,_atom) :-
	buildHandle_main(_codelist,_ins,_del),
	pc_atomconcat(['    virtual void handleInsert(CBterm* t) {\n',_ins,'    }'],_insmethod),
	pc_atomconcat(['    virtual void handleDelete(CBterm* t) {\n',_del,'    }'],_delmethod),
	buildHandle2(_codelist,_atom2),
	pc_atomconcat([_insmethod,'\n\n',_delmethod,'\n\n',_atom2],_atom).


#MODE((buildHandle_main(i,o,o)))

buildHandle_main([],'','').

buildHandle_main([code(view(_view,_set,_membername),_,_)|_r],_ins,_del) :-
	replace_atom('        if (!strcmp(t->getFunctor(),"%VIEW%")) handleInsert_%VIEW%(t);\n','%VIEW%',_view,_ins1),
	replace_atom('        if (!strcmp(t->getFunctor(),"%VIEW%")) handleDelete_%VIEW%(t);\n','%VIEW%',_view,_del1),
	buildHandle_main(_r,_ins2,_del2),
	pc_atomconcat(_ins1,_ins2,_ins),
	pc_atomconcat(_del1,_del2,_del).

buildHandle_main([code(attr(_view,_label),_,_)|_r],_ins,_del) :-
	pc_atomconcat([_view,'_',_label],_viewlabel),
	replace_atom('        if (!strcmp(t->getFunctor(),"%VIEW%")) handleInsert_%VIEW%(t);\n','%VIEW%',_viewlabel,_ins1),
	replace_atom('        if (!strcmp(t->getFunctor(),"%VIEW%")) handleDelete_%VIEW%(t);\n','%VIEW%',_viewlabel,_del1),
	buildHandle_main(_r,_ins2,_del2),
	pc_atomconcat(_ins1,_ins2,_ins),
	pc_atomconcat(_del1,_del2,_del).


#MODE((buildHandle2(i,o)))

buildHandle2([],'').

buildHandle2([code(_,_ins,_del)|_r],_methods) :-
	pc_atomconcat([_ins,'\n\n',_del,'\n\n'],_m1),
	buildHandle2(_r,_m2),
	pc_atomconcat([_m1,'\n\n',_m2],_methods).


#MODE((buildSetDeclarations(i,o)))

buildSetDeclarations([],'').

buildSetDeclarations([code(view(_view,_set,_member),_,_)|_r],_setdecl) :-
	pc_atomconcat(['    ',_set,' ',_member,';\n'],_set1),
	buildSetDeclarations(_r,_set2),
	pc_atomconcat(_set1,_set2,_setdecl).

buildSetDeclarations([code(attr(_,_),_,_)|_r],_set) :-
	buildSetDeclarations(_r,_set).


{ Generierung der Header-Dateien fuer Views und Subviews }
#MODE((generate_view_files(i,i)))

generate_view_files(_apiid,_directory) :-
	setof(_vid,(prove_literal(A(_apiid,itsMainView,_vid));prove_literal(A(_apiid,itsSubViews,_vid))),_cppviewlist),
	generate_view_files2(_cppviewlist,_directory).


#MODE((generate_view_files2(i,i)))

generate_view_files2([],_dir).

generate_view_files2([_cppviewid|_r],_dir) :-
	generate_view_files2(_r,_dir),
	get_all_attributes(_cppviewid,_attrlist),
	prove_literal(A(_cppviewid,description,_descid)),
	decodeIdString(_descid,_desc),
	prove_literal(A(_cppviewid,className,_nameid)),
	decodeIdString(_nameid,_classname),
	prove_literal(A(_cppviewid,includes,_inclid)),
	decodeIdString(_inclid,_includes),
	prove_literal(A(_cppviewid,inheritance,_inhid)),
	decodeIdString(_inhid,_inheritance),
	prove_literal(A(_cppviewid,friends,_frid)),
	decodeIdString(_frid,_friends),
	prove_literal(A(_cppviewid,constructors,_consid)),
	decodeIdString(_consid,_cons),
	prove_literal(A(_cppviewid,destructors,_destid)),
	decodeIdString(_destid,_dest),
	prove_literal(A(_cppviewid,public,_pubid)),
	decodeIdString(_pubid,_public),
	prove_literal(A(_cppviewid,private,_privid)),
	decodeIdString(_privid,_private),
	buildAttrDeclarations(_attrlist,_attrdecl),
	pc_atomconcat([_dir,'/',_classname,'.h'],_fname),
	pc_fopen(viewfile,_fname,w),
	write(viewfile,'/*  Generated by ConceptBase \n\n'),
	write(viewfile,_desc),
	write(viewfile,' */\n\n\n'),
	write(viewfile,'#ifndef _'),
	write(viewfile,_classname),
	write(viewfile,'_H_\n'),
	write(viewfile,'#define _'),
	write(viewfile,_classname),
	write(viewfile,'_H_\n\n\n'),
	write(viewfile,_includes),
	write(viewfile,'\n\nclass '),
	write(viewfile,_classname),
	write(viewfile,' '),
	write(viewfile,_inheritance),
	write(viewfile,' { \n\n\n'),
	write(viewfile,_friends),
	write(viewfile,'\n\n public: \n\n'),
	write(viewfile,_cons),
	nl(viewfile),nl(viewfile),
	write(viewfile,_dest),
	nl(viewfile),nl(viewfile),
	write(viewfile,'    /* Generated member variables for attributes of view */\n'),
	write(viewfile,_attrdecl),
	nl(viewfile),nl(viewfile),
	write(viewfile,'    /* Userdefined public methods and declarations */\n'),
	write(viewfile,_public),
	nl(viewfile),nl(viewfile),
	write(viewfile,' private:\n'),
	write(viewfile,'    /* Userdefined public methods and declarations */\n'),
	write(viewfile,_private),
	nl(viewfile),nl(viewfile),
	write(viewfile,'};\n\n'),
	write(viewfile,'#endif\n'),
	pc_fclose(viewfile).


#MODE((get_all_attributes(i,o)))

get_all_attributes(_cppviewid,_attrlist) :-
	prove_literal(A(_cppviewid,itsView,_viewid)),
	save_setof(attr(_label,_settype),
		(get_all_attributes_code(_cppviewid,_viewid,_label,_settype)),
		_attrlist).

#MODE((get_all_attributes_code(i,i,o,o)))

get_all_attributes_code(_cppviewid,_viewid,_attrlabel,_settype) :-
	is_relevant_attribute(_viewid,_attrlabel,_dest),
	id2name(_viewid,_view),
	pc_atomconcat([_view,'!',_attrlabel],_select),
	select2id(_select,_selid),
	name2id(CppViewApi,_cppviewapi),
	prove_literal(In(_apiid,_cppviewapi)),
	(prove_literal(A(_apiid,itsMainView,_cppviewid));
	 prove_literal(A(_apiid,itsSubViews,_cppviewid))
	),
	prove_literal(A(_apiid,itsAttributes,_cppattrid)),
	prove_literal(A(_cppattrid,itsAttribute,_selid)),
	prove_literal(A(_cppattrid,settype,_setid)),
	decodeIdString(_setid,_settype).


#MODE((buildAttrDeclarations(i,o)))

buildAttrDeclarations([],'').

buildAttrDeclarations([attr(_label,_set)|_r],_declatom) :-
	buildAttrDeclarations(_r,_decl1),
	pc_atomconcat(['    ',_set,' ',_label,';\n',_decl1],_declatom).



{**  Hilfspraedikate **}
#MODE((replace_atom(i,i,i,o)))

replace_atom(_inatom,_torepl,_replacement,_outatom) :-
	pc_atomtolist(_inatom,_ilist),
	pc_atomtolist(_torepl,_tolist),
	pc_atomtolist(_replacement,_replist),
	!,
	replace_atom2(_ilist,_tolist,_replist,_outlist),
	!,
	pc_atomtolist(_outatom,_outlist).

#MODE((replace_atom2(i,i,i,o)))

replace_atom2([],_,_,[]) :- !.
replace_atom2(_ilist,_tolist,_replist,_outlist) :-
	append(_tolist,_r,_ilist),
	!,
	replace_atom2(_r,_tolist,_replist,_o),
	append(_replist,_o,_outlist).

replace_atom2([_x|_r],_tolist,_replist,[_x|_o]) :-
	replace_atom2(_r,_tolist,_replist,_o).


#MODE((encodeAtoms(i,?)))

encodeAtoms([],[]) :- !.
encodeAtoms([_c|_r],[_ec|_er]) :-
	encodeAtoms2(_c,_ec),
	encodeAtoms(_r,_er).


#MODE((encodeAtoms2(i,?)))

encodeAtoms2(_c,_ec) :-
	_c =..[code|_atoms],
	encodeAtoms3(_atoms,_encatoms),
	_ec =.. [code|_encatoms].


#MODE((encodeAtoms3(i,?)))

encodeAtoms3([],[]) :-!.
encodeAtoms3([_a|_r],[_enca|_encr]) :-
	replace_atom(_a,'\\','\\\\',_enca1),
	replace_atom(_enca1,'"','\\"',_enca2),
	pc_atomconcat(['"',_enca2,'"'],_enca),
	!,
	encodeAtoms3(_r,_encr).

#MODE((decodeString(i,o)))

decodeString(_atom,_newatom) :-
	pc_atomtolist(_atom,_atomlist),
	_atomlist = ['"'|_rlist],
	decodeString2(_rlist,_newatomlist),
	pc_atomtolist(_newatom,_newatomlist).

#MODE((decodeString2(i,o)))

decodeString2(['"'],[]).

decodeString2(['\\','\\'|_rest],['\\'|_nrest]) :-
	!,
	decodeString2(_rest,_nrest).

decodeString2(['\\','"'|_rest],['"'|_nrest]) :-
	!,
	decodeString2(_rest,_nrest).

decodeString2([_c|_rest],[_c|_nrest]) :-
	decodeString2(_rest,_nrest).


#MODE((decodeIdString(i,o)))

decodeIdString(_id,_s) :-
	id2name(_id,_encs),
	decodeString(_encs,_s).


#MODE((generate_include_list(i,o)))


generate_include_list([],'').

generate_include_list([_view|_r],_atom) :-
   	generate_include_list(_r,_ratom),
	pc_atomconcat([_ratom,'#include "',_view,'.h"\n'],_atom).

