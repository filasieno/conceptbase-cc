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
#ifndef CB_PROLOG_H
#define CB_PROLOG_H

#ifdef BIM
#include "BPextern.h"

#define PROLOG_TERM     BP_Term
#define PROLOG_FUNC     BP_Functor
#define PROLOG_ATOM     BP_Atom
#define PROLOG_POINTER  BP_Pointer
#define	INIT_LIST(l)    BIM_Prolog_unify_term_value(l,BP_T_LIST)
#define INIT_TERM(t)    t=BIM_Prolog_new_term()
#define	UNIFY_FUNC(a,b)	BIM_Prolog_unify_term_value(a,BP_T_STRUCTURE,b)
#define UNIFY_ATOM(a,b) BIM_Prolog_unify_term_value(a,BP_T_ATOM,b)
#define UNIFY_TERMS(a,b) BIM_Prolog_unify_terms(a,b)
#define UNIFY_POINTER(a,b)  BIM_Prolog_unify_term_value(a,BP_T_POINTER,b)
#define	STR2ATOM(f,a)	BIM_Prolog_string_to_atom(f,a)
#define	GET_ARG(t,n,a)	BIM_Prolog_get_term_arg(t,n,&(a))
#define	GET_PRED(s,a)	BIM_Prolog_get_predicate(s,a)
#define PL_TERM_IS_ATOM(a)  (BIM_Prolog_get_term_type(a)==BP_T_ATOM)
#define PL_TERM_IS_LIST(a)  (BIM_Prolog_get_term_type(a)==BP_T_LIST)
#endif

#ifdef SWI
#include "SWI-Prolog.h"

#define PROLOG_TERM     term_t
#define PROLOG_FUNC     functor_t
#define PROLOG_ATOM     atom_t
#define PROLOG_POINTER  void*
#define	INIT_LIST(l)    PL_unify_list(l,PL_new_term_ref(),PL_new_term_ref())
#define INIT_TERM(t)    t=PL_new_term_ref()
#define	UNIFY_FUNC(a,b) PL_unify_functor(a,b)
#define UNIFY_ATOM(a,b) PL_unify_atom(a,b)
#define UNIFY_TERMS(a,b) PL_unify(a,b)
#define UNIFY_POINTER(a,b)  PL_unify_pointer(a,b)
#define	STR2ATOM(f,s)   PL_new_atom(s)
#define	GET_ARG(t,n,a)  PL_get_arg(n,t,a)
#define	GET_PRED(s,a)   PL_new_functor(s,a)
#define PL_TERM_IS_ATOM(a)  PL_is_atom(a)
#define PL_TERM_IS_LIST(a)  PL_is_list(a)

#ifdef DYNAMIC_PROLOG_LINKING
#define REGISTER_FOREIGN(module,name,arity,func,flag)   PL_register_foreign_in_module(module,name,arity,func,flag)
#else
#define REGISTER_FOREIGN(module,name,arity,func,flag)   addExternalPredicate(module,name,arity,func,flag)
#ifdef __cplusplus
extern "C" {
#endif
   void addExternalPredicate(const char*,const char*,short,pl_function_t,short);
#ifdef __cplusplus
}
#endif

#endif /* STATIC_PROLOG_LINKING */

#endif /* SWI */

#endif /* CB_PROLOG_H */
