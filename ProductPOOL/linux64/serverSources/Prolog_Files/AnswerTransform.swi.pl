/**
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
**/
/* *********************************************************** */
/*            A C H T U N G                                    */
/* Generell wurden in diesem File die geschweiften Klammern in */
/* Kommentaren durch eckige Klammern ersetzt, da der           */
/* PrologPreProcessor nicht damit umgehen kann.                */
/* *********************************************************** */





/*
* File:        AnswerTransform.pro
* Creation:    1998, Wang Hua(RWTH)
*
*
*
Definition einer Answerformat:
1. forQuery:
Hier gibt an, welche Anfragen mit dieser Format gebunden sind. Hier muss aufpassen,dass eine Anfrage max. nur
ein Format besitzen darf.
Spezifikation der Anfragen als ein Attribut von AnswerFormat darzustellen, hat den Vorteil, dass man das zugehoerigen
Format einer Anfrage beliebig aendern kann.

2.order:
Hier gibt an, in welcher Ordnung die Loesungen sortiert werden sollen.
Im Moment sind ascending und descending moeglich.

3.orderBy:
Hier gibt an, wonach die Loesungen sortiert werden sollen.
Es gibt z.B. folgende Moeglichkeiten:
     "this" sortiert nach dem Namen des Loesungsobjekts.
     "this.attribute_name" sortiert nach dem Wert des entsprechenden Attributs.
        Fuer mehrwertiges Attribut, wird das erste Element der Menge genommen.

4.head:
Hier gibt an, was vor der eigentliche Loesung steht, z.B. eine Ueberschrift. Hier koennen Praedikate aufgeruft werden.
Der Loesungsinhalt kann hier nicht spezifizieren.

5.tail:
Hier gibt an, was nach der Antwort vorkommt. Aufbau wie Fall 4.

6.split:
Es gibt mehrwertiges Attribut, dafuer gibt es split.
wenn split is TRUE ,dann wird aus einer Loesung gemaess ihrer Attr_werten mehrere Loesungen entstanden.
(Ist im Moment noch nicht implementiert worden.)

7.pattern:
Pattern gibt an ,wie die Antworten aussehen sollen.
    Syntax:
    * Ein Pattern ist ein String, mit " " geklammert. Die Sache, die drin steht, soll so ausgegeben werden, wie sie ist.
    * Was nachher erstezt werden soll, werden mit geschweiften Klammern (wie in Prolog-Kommentaren, daher kann man sie
      jetzt hier nicht benutzen, in den Beispielen werden daher eckige Klammern benutzt) geklammert. Die in Klamma stehenden Terme sind der zu ersetzende Inhalt,
      z.B. ein Term wie [this], [this.salary] werden durch den Namen eines Loesungsobjekts und den Attributwert von salary
      ersetzt. Weiterhin koennen dort auch Praedikate aufgeruft werden, z.B. [ASKquery(...)]

      Folgende Spezifikationen und Praedikataufrufe koennen vorkommen:
          this, this.inOmega, this.in, this.isa, this.attribute, this|attribute, this.attrCategory
          this.salary, this|salary, this^wangssalary, oder
      Variablen, oder
      Praedikate wie
        Foreach((Liste von Wertmenge), ( Liste von Variablen), Ausgabepattern)
            Foreach(([this.attribute],[this|attribute]),(x,y),Label:[y]; Value: [x] \\n))
        IFTHENELSE(Condition,Ausgabepattern1,Ausgabepattern2)
        AND/2,OR/2,EQUAL/2,GREATER/2,LOWER/2, ASKquery(Anfragename,Format), STRINGENCODING/1, STRINGDECODING/1

    Genaue Beschreibung sehe auch bei ersetzen().



    * Sondersymbol:
      In einer Patterndefinition  haben '"', '[', ']', '\'  alle spezielle Bedeutungen! '"' bezeichet Anfang
      bwz. Ende einer Patterndefinition. '[' und ']'  zeigen an, dass der drin stehenden Inhalt
      ersetzt werden soll. '\' weist ein Sondersymbol hin. Wenn die vorherigen erlaeuterten Symbole in Pattern
      vorkommen und andere Bedeutungen haben, dann soll dies mit '\' escapt werden!!

      Weiter innerhalb des Klammas '[' und ']' haben '(', ')', ',' auch spezielle Bedeutungen. '(' weist
      einen Praedikat-Aufruf hin. ')' zeigt Ende des Argumentparsens. ',' soll die Argumenten eines
      Praedikats trennen.

    Genaue Beschreibung sehe auch bei ersetzen() bzw. argumentparsen().

      Es konnte noch einige spezielle symbole in Pattern vorkommen, um Ausgabe zu steuern.
      '\n': NEW LINE, '\t' : TAB ,  '\b': BACKSPACE, das letzte Zeichen wird geloescht.






Beispiel:
Es sei ein QueryClass-Objekt test gegeben, das alle Angestellten mit Namen und Gehalt liefern soll.

   QueryClass test isA Employee with
    retrieved_attribute
      salary:Integer;
      name:String
   end

Hier wird ein Format fuer die Anfrage test definiert, mit dem die Anfrageergebnisse als eine ungeordnet Liste
liefern sollen.

  Individual Listfortest in AnswerFormat with
    attribute,forQuery
     fq : test
    attribute,order
     od : ascending
    attribute,orderBy
     oby : "this.salary"
    attribute,head
     h : "Here is the answer:"
    attribute,tail
     t : "that's all!"
    attribute,pattern
     p : "OBJ([this])\\tName([this.name])\\tSalary([this.salary])"
    attribute,split
     s : TRUE
  end


Hier wird ein Format definiert und gemaess dieses Format soll alle Angestellten-Daten
in entsprechende HTML-Code transformiert werden.

  Individual HTMLfortest in AnswerFormat with
    attribute,forQuery
     fq : test
    attribute,order
     od : descending
    attribute,orderBy
     oby : "this.salary"
    attribute,head
     h :"<html>
    <head><title>conceptbase www interface </title></head>
    <body>
    <h2>Hier ist die Antworte:</h2>
    <ul>"
    attribute,tail
     t:"</ul>
    <h2>Das ist alles!!!</h2>
    </body>
    </html>"
    attribute,pattern
     p :"<li>object([this]) salary([this.salary])"
    attribute,split
     s : TRUE
  end



Mit unserer Patterndefinitionssprache koennen auch allgemeine Formate definiert werden, also ein Format gleich
fuer mehrere Anfragen dienen, z.B. eine Frame-Darstellung:

  Individual FrameFormat in AnswerFormat with
    attribute,head
     h : "Here is the answer:"
    attribute,tail
     t : "that's all!"
    attribute,split
     s : TRUE
    attribute,pattern
     p : "[this]\\n[Foreach(([this.attrCategory]),(x),\\t[x]\\n[Foreach(([this|[x]]),(z),\\t\\t[z]:\\t[this^[z]];\\n)]\\b\\b\\n)]\\nend"
  end


Eine Tabelle-Darstellung:

Individual Table in AnswerFormat with
  attribute,head
     th : "<html>
    <head>
    <title>The answer in table form</title>
    </head>
    <body>
    <h1>Here is the Answer: </h1>
    <table border=6>"
  attribute,pattern
     tp : "<tr>[Foreach(([this.attrCategory]),(x),<td>[x]\([this.[x]]\)</td>)]</tr>"
  attribute,tail
     tt : "</table>
    </body>
    </html>"
end


******Komplexe Pfad-Ausdruck in Bezug auf Views:******

View EmpDeptSalary isA Employee with
   retrieved_attribute, partof
     dept : Department with
               retrieved_attribute, partof
                    head : Manager with retrieved_attribute
                     salary: Integer
                end
            end
end

Individual testFormatforView in AnswerFormat with
  attribute,forQuery
     fq : EmpDeptSalary
  attribute,head
     h : "Here is the answer:"
  attribute,tail
     t : "that's all!"
  attribute,split
     s : TRUE
  attribute,pattern
     p : "
Object([this])
Attribute_Wert([this.attribute])
Attribute_Label([this|attribute])
AttributeCategorie([this.attrCategory])
Dept([this.dept.this])
Dept_Head([this.dept.head.this])
Dept_Head_salary([this.dept.head.salary])"
end


***************** Web Anfragen *******************************************
Wenn man aus dem Web anfragen will, muss dabei nur passende URL einzugeben.
Beispielsweise um dei Anfrage test aufzurufen soll man als folgende URL angeben:
http://moers:4001/Query(test)
Wobei gibt moers an, wo der  CB-Server laueft, und 4001 der Port.


Wenn Order oder OrderBy nicht gegeben sind, dann werden die Loesungen nach nach Default-Wert sortiert:
Order ist ascending und OrderBy ist "this".
Wenn split nicht gegeben ist, dann als default "FAULSE".
Wenn Pattern nicht gegeben ist, dann werden die Antworten wie vorher in Frame,Label oder Fragment zurueckliefern.
Wenn in Pattern irgendeine Attribute Name falsch eingegeben, dann wird die durch ERROR eingesetzt!
*/

:- module('AnswerTransform',[
'delete_first_and_last'/2
,'eraseParameters'/1
,'parse'/2
,'recordParameters'/1
,'recordValue'/2
,'remove_initialed_values'/1
,'transform_answer_in_Updateformat'/3
,'transform_answer_in_format'/4
,'IsLastFrame'/1
,'IsFirstFrame'/1
,'eraseAnswerParameters'/1
,'addAnswerParameters'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('GeneralUtilities.swi.pl').







:- use_module('Literals.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('IpcChannel.swi.pl').
:- use_module('AnswerTransformator.swi.pl').


:- use_module('ScanFormatUtilities.swi.pl').



:- use_module('SelectExpressions.swi.pl').
:- use_module('ExternalCodeLoader.swi.pl').









:- use_module('PrologCompatibility.swi.pl').













:- use_module('AnswerTransformUtilities.swi.pl').

















:- use_module('GlobalParameters.swi.pl').
:- use_module('MetaUtilities.swi.pl').




:- dynamic 'Frag'/1 .

/** this two flags are for solving ticket #30 **/
:- dynamic 'IsLastFrame'/1 .
:- dynamic 'IsFirstFrame'/1 .


:- style_check(-singleton).




transform_answer_in_format(solution(_q,_sol),_fid,_ansrep,_answerlist):-
    transform(solution(_q,_sol),_fragmentlist),
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered),
    !,
    pc_update('IsLastFrame'(no)),     /** #30 **/
    pc_update('IsFirstFrame'(yes)),   /** #30 **/
    build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_answerlist),
    build_headtail(_fraglist_ordered,_answerlist,_headID,_tailID,_answerlist).

transform_answer_in_format(_fragmentlist,_fid,_ansrep,_answerlist):-
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered),
    !,
    pc_update('IsLastFrame'(no)),     /** #30 **/
    pc_update('IsFirstFrame'(yes)),   /** #30 **/
    build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_answerlist),
    build_headtail(_fraglist_ordered,_answerlist,_headID,_tailID,_answerlist).

transform_answer_in_format(_fa,_fid,_ansrep,''):-
    write('Fehler by transforming answer!!!'),nl.

transform_answer_in_Updateformat(_fa,_fid,_UpdatePattern):-
    transform(_fa,_fragmentlist),
    get_all_formatinfos(_fid,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID),
    !,
    build_UpdatePattern(_fragmentlist,_patternID,_UpdatePattern).



get_all_formatinfos(_id,_orderID,_orderByID,_headID,_tailID,_patternID,_splitID):-
    get_order(_id,_orderID),
    get_orderBy(_id,_orderByID),
    get_head(_id,_headID),
    get_tail(_id,_tailID),
    get_pattern(_id,_patternID),
    get_split(_id,_splitID).


/** no sorting done for bulk queries **/
order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist) :-
   getFlag(bulkQuery,on),
   !.

/** ticket #416: no sorting when 'orderBy' attribute of answer format is set to "none" **/
order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist) :-     
    is_id(_orderByID),
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"none"',
    !.

order_answer(_fragmentlist,_orderID,_orderByID,_fragmentlist):-
    (    var(_orderID);var(_orderByID)    ),
    tooBigList(_fragmentlist),
    !.

order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    (    var(_orderID);var(_orderByID)    ),
    !,
    convertlist(_fragmentlist,what(_),_list),
    quicksort(_list,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).




order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-                    /*order nach obj,obj.attr_cat*/
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"this"',
    !,
    convertlist(_fragmentlist,what(_),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).

/** 18-Jul-2006/M.Jeusfeld: explicitely cover the case when the orderBy tag of the answer format **/
/** is set to "this.oid"  (= order by object identifier). See also ticket #108                   **/
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-   
    retrieve_proposition('P'(_orderByID,_orderByID,_o,_orderByID)),
    _o=='"this.oid"',
    !,
    convertlist(_fragmentlist,oid,_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).



order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    retrieve_proposition('P'(_orderByID,_orderByID,_a,_orderByID)),
    pc_atomconcat('"this.',_attr_cat1,_a),
    !,
    pc_atomconcat(_attr_cat,'"',_attr_cat1),
    convertlist(_fragmentlist,attr_value(_attr_cat),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).
order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    retrieve_proposition('P'(_orderByID,_orderByID,_l,_orderByID)),
    pc_atomconcat('"this|',_attr_cat1,_l),
    !,
    pc_atomconcat(_attr_cat,'"',_attr_cat1),
    convertlist(_fragmentlist,attr_label(_attr_cat),_list),
    sort(_list,_orderID,_fraglist_ordered1),
    unconvertlist(_fraglist_ordered1,_fraglist_ordered).


order_answer(_fragmentlist,_orderID,_orderByID,_fraglist_ordered):-
    write('Error while order answer! Maybe syntax error with order or order durch?'),nl,!,fail.


sort(_list,_orderID,_list):-
   tooBigList(_list),
   !.

sort(_list,_orderID,_list_sorted):-
    retrieve_proposition('P'(_orderID,_orderID,ascending,_orderID)),        /*kann man spaeter durch keysort,oder quicksort ersetzen.*/
    !,
    quicksort(_list,_list_sorted).
sort(_list,_orderID,_list_sorted):-
    retrieve_proposition('P'(_orderID,_orderID,descending,_orderID)),
    !,
    quicksort(_list,_list1),
    reverse(_list1,_list_sorted).
sort(_,_,_):-
    write('AnswerTransform: sort failed!'),nl.



/** we do not sort very large lists since it can cause stack overflows **/
tooBigList(_list) :-
  get_cb_feature(sortLimit,_max),
  checkTooBig(_max,_list),
  'WriteTrace'(minimal,'AnswerTransform',['Answer not sorted because it exceeds ', _max, ' elements.']),
  !.


checkTooBig(_nr,[]) :- 
  _nr > 0,
  !,
  fail.

checkTooBig(0,[_x|_rest]) :- !.

checkTooBig(_nr,[_x|_rest]) :-
  _nr > 0,
  _nr1 is _nr - 1,
  checkTooBig(_nr1,_rest).






/* Wenn das Pattern nicht angegeben ist, dann werden die Anfrageergebnis als Frame, Label oder SML-Fragment transformiert.*/
build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    var(_patternID),
    !,
    build_answer1(_fraglist_ordered,_ansrep,_anslist_with_format).

/* Ansonst wird die Losungen gemaess die angegebene Pattern transformiert.*/
build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    var(_splitID),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    build_answer2(_fraglist_ordered,_pattern,_anslist_with_format).

build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    ground(_splitID),
    retrieve_proposition('P'(_splitID,_splitID,'FALSE',_splitID)),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    build_answer2(_fraglist_ordered,_pattern,_anslist_with_format).

build_answer(_fraglist_ordered,_patternID,_ansrep,_splitID,_anslist_with_format):-
    ground(_patternID),
    ground(_splitID),
    retrieve_proposition('P'(_splitID,_splitID,'TRUE',_splitID)),
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    !,
    split_answer(_fraglist_ordered,_fraglist_splited),
    build_answer2(_fraglist_splited,_pattern,_anslist_with_format).


build_answer1([],_,_res).

build_answer1(_fraglist_ordered,'LABEL',_res):-
	!,
    collect_frame_labels(_fraglist_ordered,_labels),
    listToAtomWithCommata(_labels,_res),
    appendBuffer(_res,'\n').

build_answer1(_fraglist_ordered,'FRAGMENT',_res):-
    !,
    pc_atom_to_term(_atom,_fraglist_ordered),
    appendBuffer(_res,_atom),
    appendBuffer(_res,'\n').

build_answer1(_fraglist_ordered,'FRAME',_res):-
    !,
    fragments_to_frames(_fraglist_ordered,_res),
    appendBuffer(_res,'\n').

build_answer1(_fraglist_ordered,'JSONIC',_res):-
    !,
    fragments_to_frames(_fraglist_ordered,_res),
    appendBuffer(_res,'\n').

/** the character \001 is temporarily inserted in _anslist_with_format **/
/** as placeholder for ','. We need the replace it accordingly before  **/
/** we return the answer.                                              **/
build_answer2([],_,_anslist_with_format) :-
    replaceCharacterInBuffer(_anslist_with_format,'\001',',').   

/** distinguish this case to be able to raise the flag IsLastFrame **/
build_answer2([_frag],_pattern,_anslist_with_format):-
    pc_update('IsLastFrame'(yes)),   /** #30 **/
    build_answer_with_format(_frag,_pattern,_anslist_with_format),
    replaceCharacterInBuffer(_anslist_with_format,'\001',','),
    !.

build_answer2([_frag|_rfraglist_ordered],_pattern,_anslist_with_format):-
    build_answer_with_format(_frag,_pattern,_anslist_with_format),
    pc_update('IsFirstFrame'(no)),   /** #30 **/
    build_answer2(_rfraglist_ordered,_pattern,_anslist_with_format).


/*TODO: NOCH ZU AENDERN auf StringBuffer (oder ganz rauswerfen) */
build_UpdatePattern([],_,''):-!.
build_UpdatePattern([_fragment|_rfragmentlist],_patternID,_UpdatePattern):-
    retrieve_proposition('P'(_patternID,_patternID,_pattern,_patternID)),
    pc_atomconcat('"',_rpattern,_pattern),
    'TermToCharList'(_rpattern,_rpatternlist),
    asserta('Frag'(_fragment)),
    !,
    parse(_rpatternlist,_p),
    pc_atomconcat(_p,_patom),
    retract('Frag'(_fragment)),
    build_UpdatePattern(_rfragmentlist,_patternID,_rUpdatePattern),
    pc_atomconcat(_patom,_rUpdatePattern,_UpdatePattern).



build_answer_with_format(_fragment,_pattern,_anslist):-
    pc_atomconcat('"',_rpattern,_pattern),
    'TermToCharList'(_rpattern,_rpatternlist),
    asserta('Frag'(_fragment)),
    !,
    parse(_rpatternlist,_anslist),  /** orginally an '\n' was appended to _ans, 2-Nov-2000/MJf **/		/*parse ersetzt strings wie this ... durch die tats?chlischen werte beim Aufruf und Formatiert die patternlist zus?tlich mit Zeilenumbr?chen*/
    retract('Frag'(_fragment)).





/**************************Hilfs Fkt*******************************/

get_order(_id,_orderID):-
    prove_literal('A'(_id,'AnswerFormat',order,_orderID)).
get_order(_id,_).

get_orderBy(_id,_orderByID):-
    prove_literal('A'(_id,'AnswerFormat',orderBy,_orderByID)).
get_orderBy(_id,_).

get_head(_id,_headID):-
    prove_literal('A'(_id,'AnswerFormat',head,_headID)).
get_head(_id,_).

get_tail(_id,_tailID):-
    prove_literal('A'(_id,'AnswerFormat',tail,_tailID)).
get_tail(_id,_).

get_pattern(_id,_patternID):-
    prove_literal('A'(_id,'AnswerFormat',pattern,_patternID)).
get_pattern(_id,_).

get_split(_id,_splitID):-
    prove_literal('A'(_id,'AnswerFormat',split,_splitID)).
get_split(_id,_).


/* In Head- bzw. Tail-Block ist es auch moeglich, auf die Loesungen zuzugreifen, allerdings nur die erste Loesung!*/
build_headtail([_fragment|_rfragment],_ansatom,_headID,_tailID,_answer):-
    asserta('Frag'(_fragment)),
    !,
    createBuffer(_hlist),
    createBuffer(_tlist),
    !,
    build_head(_headID,_hlist),
    build_tail(_tailID,_tlist),
    retract('Frag'(_fragment)),
    getStringFromBuffer(_hatom,_hlist),
    getStringFromBuffer(_tatom,_tlist),
    prependBuffer(_ansatom,_hatom),
    appendBuffer(_ansatom,_tatom),
    disposeBuffer(_hlist),
    disposeBuffer(_tlist),
    !.


build_head(_headID,_hlist):-
    ground(_headID),
    retrieve_proposition('P'(_headID,_headID,_head,_headID)),
    pc_atomconcat('"',_rhead,_head),
    'TermToCharList'(_rhead,_hlist1),
    parse(_hlist1,_hlist).   /** originally, an '\n' was appended to _hlist *, 2-Nov-2000/MJf **/

build_head(_headID,_):-
    var(_headID).

build_tail(_tailID,_tlist):-
    ground(_tailID),
    retrieve_proposition('P'(_tailID,_tailID,_tail,_tailID)),
    pc_atomconcat('"',_rtail,_tail),
    'TermToCharList'(_rtail,_tlist1),
    parse(_tlist1,_tlist).

build_tail(_tailID,_):-
    var(_tailID).


/*hier bauert einer list mit einzel element als:(_wert,SML(_)),*/
/*also man nimm die zu sortiert Wert aus.*/

convertlist([],_,[]):-!.

convertlist([_fragment|_rest],_crit,[(_v,_fragment)|_rlist]):-
    getOrderValue(_fragment,_crit,_v),
    convertlist(_rest,_crit,_rlist).



/** getOrderValue(_fragment,_crit,_v) computes an order value for _fragment according **/
/** to _criterion.                                                                    **/

getOrderValue(_fragment,what(_),_v) :-
    'Out_Object'([_fragment],[_v|_]),
    !.

/** 18-Jul-2006/M.Jeusfeld: this case supports the answer formatting for **/
/** being sorted according to the object identifier. See ticket #108.    **/
getOrderValue(_fragment,oid,_v) :-
    _fragment = 'SMLfragment'(what(_objname),_,_,_,_),
    eval(_objname,replaceSelectExpression,_o),
    pc_atomconcat('id_',_v,_o),
    !.

getOrderValue(_fragment,attr_value(_attr_cat),_v) :-
   'Out_attribute_value'([_fragment],_attr_cat,[_v|_]),    /** will take the first attribute value **/
   !.

getOrderValue(_fragment,attr_label(_attr_cat),_v) :-
  'Out_attribute_label'([_fragment],_attr_cat,[_v|_]),     /** will take the first attribute label **/
  !.

/** catchall **/
getOrderValue(_fragment,_crit,'0').


unconvertlist([],[]):-!.
unconvertlist([(_,_fragment)|_r],[_fragment|_res]):-
    unconvertlist(_r,_res).


/*Hier wird die erst und letzt Element(naemlich  "  ) in List geloescht.*/
delete_first_and_last([],[]).

delete_first_and_last(['"'|_rest],_outlist) :-
  delete_last(_rest,[],_outlist),
  !.

delete_first_and_last(_,_):-
    write('Error!  "  missed!'),nl,!,fail.

delete_last(['"'],_sofar,_sofar) :-
 !.

delete_last([_a|_rest],_sofar,_outlist) :-
  _rest \= [],
  append(_sofar,[_a],_sofar1),
  delete_last(_rest,_sofar1,_outlist).


/******************************************** Out_XXX  ******************************************************/
/* Out_XXX wird aus einer Liste von SMLfragments den erwueschten Wert in Bezug auf XXX liefen, der Wert wird */
/* als eine Liste von Atom/Term geliefert.                                   */
/************************************************************************************************************/

'Out_Object'([],[]):-!.
'Out_Object'(['SMLfragment'(what(_o),_,_,_,_)|_rest],[_on|_rObjlist]) :-
    outIdentifier(_o,_on),
    'Out_Object'(_rest,_rObjlist).

'Out_ObjectId'([],[]):-!.
'Out_ObjectId'(['SMLfragment'(what(_o),_,_,_,_)|_rest],[_oid|_rObjlist]) :-
    eval(_o,replaceSelectExpression,_oid),
    'Out_ObjectId'(_rest,_rObjlist).


/** if the argument _o is an atom, then it is the result of the evaluation of **/
/** some path expression. The result may be a simple objectname or an atom    **/
/** like Object!attr. Out_ObjectId has to use select2id to convert this back  **/
/** to an oid.                                        26-Jul-2006/M.Jeusfeld  **/
'Out_ObjectId'([_o|_rest],[_oid|_rObjlist]) :-
    atom(_o), 
    select2id(_o,_oid),
    'Out_ObjectId'(_rest,_rObjlist).

'Out_SystemClass'([],[]):-!.
'Out_SystemClass'(['SMLfragment'(_,in_omega(_classlist),_,_,_)|_rest],_slist):-
    getObjectFromClasslist(_classlist,_sl1),
    'Out_SystemClass'(_rest,_sl2),
    append(_sl1,_sl2,_slist).

'Out_Class'([],[]):-!.
'Out_Class'(['SMLfragment'(_,_,in(_classlist),_,_)|_rest],_clist):-
    getObjectFromClasslist(_classlist,_cl1),
    'Out_Class'(_rest,_cl2),
    append(_cl1,_cl2,_clist).

'Out_SuperClass'([],[]):-!.
'Out_SuperClass'(['SMLfragment'(_,_,_,isa(_classlist),_)|_rest],_clist):-
    getObjectFromClasslist(_classlist,_cl1),
    'Out_SuperClass'(_rest,_cl2),
    append(_cl1,_cl2,_clist).

getObjectFromClasslist([],[]):-!.
getObjectFromClasslist([class(_c)|_rest],[_cn|_r]):-
    outIdentifier(_c,_cn),
    getObjectFromClasslist(_rest,_r).

'Out_attribute_label'([],_,[]):-!.
'Out_attribute_label'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_attr_cat,_labels):-
    search_label(_attrdecl_list,_attr_cat,_labels1),
    'Out_attribute_label'(_rest,_attr_cat,_labels2),
    append(_labels1,_labels2,_labels).

'Out_attribute_value'([],_,[]):-!.
'Out_attribute_value'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_attr_cat,_values):-
    search_value(_attrdecl_list,_attr_cat,_values1),
    'Out_attribute_value'(_rest,_attr_cat,_values2),
    append(_values1,_values2,_values).


search_label([],_,['NULL']):-!.

search_label([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_label):-
    member(_attr_cat,_catlist),
    !,
    'Out_label'(_propertylist,_label).

search_label([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_label):-
    search_label(_restlist,_attr_cat,_label).

search_value([],_,['NULL']):-!.

search_value([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_value):-
    member(_attr_cat,_catlist),
    !,
    'Out_value'(_propertylist,_value).

search_value([attrdecl(_catlist,_propertylist)|_restlist],_attr_cat,_value):-
    search_value(_restlist,_attr_cat,_value).


'Out_label'([],[]):-!.

'Out_label'([property(_l,_)|_res],[_l|_r]):-
    'Out_label'(_res,_r).


'Out_value'([],[]):-!.

'Out_value'([property(_,_v)|_res],[_vn|_r]):-
    outIdentifier(_v,_vn),
    'Out_value'(_res,_r).


'Out_label_value'([],_,[]):-!.
'Out_label_value'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_label,_values):-
    find_label_value(_attrdecl_list,_label,_values1),
    'Out_label_value'(_rest,_label,_values2),
    append(_values1,_values2,_values).

find_label_value([],_,['NULL']):-!.
find_label_value([attrdecl(_catlist,_propertylist)|_restlist],_label,_values):-
    'Out_label'(_propertylist,_labels),
    (
    (member(_label,_labels),
    get_label_value(_propertylist,_label,_values));
    find_label_value(_restlist,_label,_values)
    ).

get_label_value([],_,['NULL']):- !.
get_label_value([property(_l,_v)|_rest],_label,_value):-
    (
    (_l==_label,_value=[_v]);
    (get_label_value(_rest,_label,_value))
    ).



'Out_all_attribute_labels'([],[]):-!.
'Out_all_attribute_labels'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_labels):-
    get_all_labels(_attrdecl_list,_labels1),
    'Out_all_attribute_labels'(_rest,_labels2),
    append(_labels1,_labels2,_labels).

get_all_labels([],[]):-!.
get_all_labels([attrdecl(_catlist,_propertylist)|_restlist],_labels):-
    'Out_label'(_propertylist,_label),
    get_all_labels(_restlist,_rlabels),
    append(_label,_rlabels,_labels).


'Out_all_attribute_values'([],[]):-!.
'Out_all_attribute_values'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_values):-
    get_all_values(_attrdecl_list,_values1),
    'Out_all_attribute_values'(_rest,_values2),
    append(_values1,_values2,_values).


get_all_values([],[]):-!.
get_all_values([attrdecl(_catlist,_propertylist)|_restlist],_values):-
    'Out_value'(_propertylist,_value),
    get_all_values(_restlist,_rvalues),
    append(_value,_rvalues,_values).


/*Hier bemerkt man, in diese Liste von Attribute Katagorie, soll */
/*Keine 'attribute' als Listelement vorkommen. */
'Out_all_attribute_Categories'([],[]):-!.
'Out_all_attribute_Categories'(['SMLfragment'(_,_,_,_,with(_attrdecl_list))|_rest],_Catlist):-
    get_all_Cats(_attrdecl_list,_Catlist1),
    'Out_all_attribute_Categories'(_rest,_Catlist2),
    append(_Catlist1,_Catlist2,_Catlist).

get_all_Cats([],[]):-!.
get_all_Cats([attrdecl(_catlist,_propertylist)|_restlist],_cats):-
    'Out_Cat'(_catlist,_cat),
    get_all_Cats(_restlist,_rcats),
    append(_cat,_rcats,_cats).

/* output attribute if list contains nothing else */
'Out_Cat'([attribute],[attribute]):-!.

'Out_Cat'(_i,_o) :-
    'Out_Cat2'(_i,_o).

/* do not output attribute if there is something else in the list */
'Out_Cat2'([],[]):-!.
'Out_Cat2'([_c|_res],[_c|_r]):-
    _c \== 'attribute',
    'Out_Cat2'(_res,_r).

'Out_Cat2'([_c|_res],_r):-
    'Out_Cat2'(_res,_r).




/*Sortierung jetzt fkt auch wenn a Integer oder Real Werten sind*/
quicksort([_pilot|_res],_listsorted):-
    partition(_res,_pilot,_less,_bigger),
    quicksort(_less,_ls),
    quicksort(_bigger,_bs),
    append(_ls,[_pilot|_bs],_listsorted).
quicksort([],[]):-!.



partition([_x|_xs],_y,_ls,[_x|_bs]):-
    _x=(_xx,_),_y=(_yy,_),
    greater(_xx,_yy),
    partition(_xs,_y,_ls,_bs).

partition([_x|_xs],_y,[_x|_ls],_bs):-
    partition(_xs,_y,_ls,_bs).
partition([],_,[],[]):-!.


/*Bei Vergleich check zuerst ob _xx,_yy ein Integer sein konnten.*/
greater(_xx,_yy):-
    (pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
    (pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy)),
    _x > _y.

greater(_xx,_yy):-
    \+((
        (pc_inttoatom(_x,_xx);pc_floattoatom(_x,_xx)),
        (pc_inttoatom(_y,_yy);pc_floattoatom(_y,_yy))
    )),
_xx @> _yy.



split_answer(_fragmentlist_ordered,_fragmentlist_ordered).





/********************************************* PARSE *****************************************************/
/* Parse(Pattern,Ausgabe)                                         */
/* Pattern: Die Patterndefinition in Charlist. Das erst '"' ist schon weg und das letzt '"' muss da sein!*/
/* Ausgabe: geparst Pattern, gleichzeitig ist dies die Antwortausgabe fuer eine einzele Loesung.        */
/* Patterndefinitionssprache:                                        */
/* Ein Pattern wird durch ein String definiert, alles in diesem String soll auch so dargestellt werden,    */
/* ausser die Terme, die in [ ] stehen. Die in klamma stehenden Terme sind die zuersetzenden Inhalte.    */
/* Die koennen ein Term wie [this],[this.salary] (wird durch Object Name und salary Werte ersetzt), oder    */
/* ein Praedikate-aufruf wie [ASKquery()]...(Der in [] stehendem Inhalt wird dann durch die Ausgabe von    */
/* Praedikate-aufruf ersetzt( Die Ausgabe sind meistens die letzte Argument.)), oder in Klamma kann noch    */
/* Variable stehen wie [x], die Variablen werden in Moment nur innerhalb Praedikat:Foreach() moeglich.    */
/* Mehr details siehe auch bei ersetzen().                                */
/*                                                    */
/* Sondersymbole:                                            */
/* In einer Patterndefinition  haben '"','[',']','\'  alle spezielle Bedeutungen! '"' bezeichet Anfang    */
/* bwz. Ende einer Patterndefinition, '[' und ']'  zeigen an, dass die drin stehenden Inhalt soll     */
/* ersetzt werden. '\' weist ein Sondersymbol hin. Wenn so was in Pattern vorkommen und nicht mit    */
/* diesen Bedeutungen, dann soll man escapen mit '\'!!                            */
/* Weiter innerhalb [] haben '(',')',',' auch spezielle Bedeutungen. '(' weist Ende eine Functor bzw.    */
/* eines Praedikate-Aufrufs. ')' zeigt Ende der Argumentparse an. ',' soll die Argumenten von einem    */
/* Praediket trennen. Genaue Beschreibung findet man auch bei ersetzen() bzw. argumentparsen() .        */
/*                                                    */
/* Es konnte noch einige spezielle symbole in Pattern vorkommen, um Ausgabe zu steuern.            */
/* '\n': neue Line, '\t' : TAB ,  '\b': BACKSPACE, letzt Zeichen wird geloescht.                */

/*
Bemerkung zum Praedikat-aufruf:
1.Praedikate name darf nicht im CB  schon existiert, wie and, or!! sonst kann man nicht global machen.
2. Argumentname, functor name wenn (,) [,],enthaelt, soll escapen!
Man bemerkt [ASKquery(find_instances[[this]/class],LABEL)] und [ASKquery(find_instances[\[this\]/class],LABEL)] anders sind!!!
3. In pattern wenn [,]," vorkommt, soll escapen!
4. Wenn aufruf eines praedikate fehlerhaft, dann werden die einfach unveraendert ausgegeben.
Praedikate definition:
Predicate(_Output,_arg1,_arg2,...)
_argi sind die eigentliche parameter! _output ist die rueckgabe parameter!
Schreibt man in AnswerTransformUtilities rein und dann mach dies global!
*/




parse([],_anslist):-!.
parse(['"'|_rpatternlist],_anslist):-
    !.

parse(['\\'|_rpatternlist],_anslist):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_f),
    appendBuffer(_anslist,_f),
    parse(_restpatternlist,_anslist),
    !.


parse(['{'|_rpatternlist],_anslist):-
    !,
    ersetzen(_rpatternlist,_anslist,_rlist),
    parse(_rlist,_anslist),
    !.


parse([_x|_rpatternlist],_anslist):-
    appendBuffer(_anslist,_x),
    parse(_rpatternlist,_anslist).



/*Hier wird den Praedikate gefunden, functor als ein Atom und Argument als eine Liste von Atom.*/
findnextpraedikat(_rpatternlist1,_functor,_argumentlist,_restpatternlist):-
    'Ignore_blank'(_rpatternlist1,_rpatternlist),
        findfunctor(_rpatternlist,_functor1,_restpatternlist1),
        !,
        atom2list(_functor,_functor1),
        argsparsen(_restpatternlist1,_argumentlist,_restpatternlist).


/*Find the functor if it exists, returns as a atom.*/
findfunctor([_x|_patternlist],[],_patternlist):-
    (_x=='}';_x=='{';_x=='"';_x==','),
       !,
       fail.

findfunctor(['('|_patternlist],[],_patternlist):-
    !.

findfunctor(['\\'|_patternlist],[_f|_rfunctor],_restpatternlist):-
    sonderZeichen(_patternlist,_rlist,_f),
    findfunctor(_rlist,_rfunctor,_restpatternlist).

findfunctor([_x|_patternlist],[_x|_rfunctor],_restpatternlist):-
    findfunctor(_patternlist,_rfunctor,_restpatternlist).


/************************argsparsen****************************/
/*Parsen the arguments, returns a list of atoms.             */

argsparsen([],_,_):-
    write('ERROR with argument parsing'),
    !,
    fail.

argsparsen([')'|_rpatternlist],[],_rlist):-
    !,
    _rpatternlist=['}'|_rlist].

argsparsen(_rpatternlist1,[_arg|_rargumentlist],_restpatternlist):-
    'Ignore_blank'(_rpatternlist1,_rpatternlist),
    createBuffer(_argBuffer),
    !,
    setFlag(listOn,false),  /** indicates that we are currently parsing a list like [x1,x2] **/
    argumentparsen(_rpatternlist,_argBuffer,_rlist),
    getPointerFromBuffer(_resultString,_argBuffer),
    save_stringtoatom(_resultString,_arg),
    disposeBuffer(_argBuffer),
    !,
    argsparsen(_rlist,_rargumentlist,_restpatternlist).


/* Hier wird einzele Argument geparst und eine Liste von Char wird geliefert.  */
/* Man soll aufpassen: innerhalb einer Argument kann auch zuersetzende Inhalt  */
/* vorkommen, Als letzte Argument von einem Praedikat-aufruf, ist meinsten ein */
/* Ausgabe-pattern, in dem ist alles moeglich!                      */
/* Bem. '[', ']', '(', ')', ',' '\' haben spezielle Bedeutungen, wenn in       */
/* Wenn in Argument vokommen und nicht mit solchen Bedeutungen, dann soll man  */
/* escapen mit '\'!!!                                  */

argumentparsen(['\\'|_rpatternlist],_outPutBuffer,_rlist):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_f),
    appendBuffer(_outPutBuffer,_f),
    argumentparsen(_restpatternlist,_outPutBuffer,_rlist).


/** a comma within a list is not terminating an argument **/
argumentparsen([','|_rpatternlist],_outPutBuffer,_rlist):-
    getFlag(listOn,true),
    !,
    appendBuffer(_outPutBuffer,','),
    argumentparsen(_rpatternlist,_outPutBuffer,_rlist).


/** other commas do terminate the argument **/
argumentparsen([','|_rpatternlist],_outPutBuffer,_rpatternlist):-
    !.

argumentparsen([')'|_rpatternlist],_outPutBuffer,[')'|_rpatternlist]):-
    !.

/*Innerhalb einer Argument konnte auch zuersetzt Object vorkommen!*/
argumentparsen(['{'|_rpatternlist],_outPutBuffer,_restlist):-
    !,
    ersetzen(_rpatternlist,_outPutBuffer,_rlist),
    argumentparsen(_rlist,_outPutBuffer,_restlist).


/** characters '[' and ']' indicate that we are processing a list; in this **/
/** case, the comma ',' is not indicating that an argument is completed    **/
/** see ticket #182                                                        **/

argumentparsen(['['|_rpatternlist],_outPutBuffer,_rlist):-
    setFlag(listOn,true),
    appendBuffer(_outPutBuffer,'['),
    argumentparsen(_rpatternlist,_outPutBuffer,_rlist).

argumentparsen([']'|_rpatternlist],_outPutBuffer,_rlist):-
    setFlag(listOn,false),
    appendBuffer(_outPutBuffer,']'),
    argumentparsen(_rpatternlist,_outPutBuffer,_rlist).


argumentparsen([_x|_rpatternlist],_outPutBuffer,_rlist):-
    appendBuffer(_outPutBuffer,_x),
    argumentparsen(_rpatternlist,_outPutBuffer,_rlist).



/**************************************  ersetzen  ****************************************************************/
/*Ersetzen ersetzt alles, was in [ ] steht, liefert eine Liste von Atom/Term zurueck,Bei Fehler, wird dann     */
/*Inhalt durch 'ERROR' ersetzt, ersetzen() nicht fail schlaegen, denn machmal ist Teilergebnisse auch sinnvoll... */
/******************************************************************************************************************/
/*
Zu ersetzenden Ausdruck ist wie folgt aufgebaut:
1) eine Term wie :
this-->
    Loesungsobjectname, z.B. wird durch ["Wang Hua"] ersetzt.

this.inOmega, this.in, this.isa-->
    liefert die Loesungsobjekt zugehoerige Systemklasse, Klasse und Superklasse zurueck.

this.attribute, this|attribute-->
    alle Attributen Werte bzw. alle Labels von dem Loesungsobjekt,
    zB. this|attribute wird durch [Wangssalary1,Wangssalary2,Wangsname,Wangsdept] ersetzt.

this.attrCategory-->
    alle Attribute Kategorien von dem Loesungsobjekt,
    zB. wird durch [salary,name,dept] ersetzt.

this.salary-->
    werte von Attributecategorie salary, z.B.[10000,5000], man bemerkt, hier konnte mehrwertig sein!!!

this|salary-->
    labels von AttributeCategorie salary ebenfalls mehrwertig sein konnte, z.B.[Wangssalary1,Wangssalary2]

this^Wangssalary-->
    Wert von AttributLabel Wangssalary, z.B. [100000], hier ist eine Wert eindeutig bestimmt!!!
x-->
    Eine Variable
    z.B. wird durch [salary] ersetzt! Variable koennen im Moment nur innerhalb Foreach()-Aufruf vorkommen,
    sie repraesentieren normalerweise eine Menge von Werten und wird in Foreach jedes mal durch einen Wert
    ersetzt.

2) ein Praedikat wie Foreach()
    Foreach wird als sonder faelle behandelt, denn hier Variable vorkommt.

3) normale Praedikat: EQUAL()... z.B. liefert [TRUE] zurueck.

4) Komplexe und geschachtete Ausdruecke, wie this.[x].head, hier wird zuerst das inneren Teil ersetzt, dann Ganze.


BEM:

\ , ( ) [] " , haben alle spezielle Bedeutungen!
\--> Escapezeichen
( )--> bei Praedikat Aufruf, z.B. Foreach(...)
[ ]--> signalisiert zu ersetzende Teile
, --> Trennungssymbol fuer Argumentlsite in  einem Praedikat
"--> Anfang bzw. Ende eines Patterns

Wenn man solche Symbole trotz noch einsetzen will und zwar mit einer anderen Bedeutung, dann muessen sie mit Escape-zeichen
kombiniert werden, z.B. [IFTHENELSE([GREATER([this.salary],10000)],SALARY\(High\),SALARY\(Low\))]

*/

ersetzen(_patternlist1,_ersetztInhalt,_rlist):-
    'Ignore_blank'(_patternlist1,_patternlist),
    _patternlist = ['F','o','r','e','a','c','h'|_],
 /**   append(['F','o','r','e','a','c','h'],_,_patternlist), **/
    !,
        (
        parsen_foreach(_patternlist,_ersetztInhalt,_rlist);
        (
        write('Error with Parsing Foreach in:        '),
        atom2list(_errorpattern,_patternlist),
        write(_errorpattern),nl,
        appendBuffer(_ersetztInhalt,'SYNTAX-ERROR-Foreach \n')
        )
    ).

ersetzen(_patternlist,_ersetztInhalt,_rlist):-
    findObj(_patternlist,_object,_rlist),
    !,
    ersetzen2(_object,_ersetztInhalt),
    !.

ersetzen(_patternlist1,_ersetztInhalt,_rlist):-
    'Ignore_blank'(_patternlist1,_patternlist),
    findnextpraedikat(_patternlist,_functor,_argumentlist,_rlist),
    !,
    (
         callpraed(_functor,_argumentlist,_ersetztInhalt);
         (pc_atomconcat(['ERROR calling predicate ',_functor,'\n'],_atom),
          appendBuffer(_ersetztInhalt,_atom)
         )
    ),
    !.

ersetzen2(_object,_ersetztInhalt) :-
    atom2list('this',_object),
    !,
    'Frag'(_fragment),
    (
    'Out_Object'([_fragment],[_ersetztInhaltAtom]),appendBuffer(_ersetztInhalt,_ersetztInhaltAtom);
    appendBuffer(_ersetztInhalt,'NOOBJECT \n')         /** was 'ERROR' before; now to be checked in foreach(), MJf, 1-Nov-2000, CBNEWS[201]*/
    ),
    !.


ersetzen2(_object,_ersetztInhalt) :-
    atom2list(_o,_object),
    pc_atomconcat('this',_path1,_o),        /*_path1 ist z.B. .x|y^z.attrCategory*/
    !,
    atom2list(_path1,_path),
    'Frag'(_fragment),
    (
    (parsen_PathExp([_fragment],_path,_ersetztInhalt));
    appendBuffer(_ersetztInhalt,'NOOBJECT \n')          /** was 'ERROR' before; now to be checked in foreach(), MJf, 1-Nov-2000, CBNEWS[201]*/
    ),
    !.

ersetzen2(_object,_ersetztInhalt) :-
    atom2list(_o,_object),
    pc_recorded(_o,'AnswerFormatVariable',_value1),
    !,
    atom2list(_value,_value1),
    appendBuffer(_ersetztInhalt,_value).

/** take care of expressions like [param] where [param] is a parameter of a **/
/** query call like Q[value/param]. This is set in QAmanager.pro and reset  **/
/** in CBserverInterface.pro.                                               **/

ersetzen2(_object,_ersetztInhalt) :-
    atom2list(_o,_object),
    (pc_recorded(_o,'AuxAnswerParameter',_value);
     pc_recorded(_o,'PersistentAnswerParameter',_value)),
    !,
    appendBuffer(_ersetztInhalt,_value).


/** expressions that are not replacable are included with 'not replaced' tag **/
/** to allow debugging.                                                      **/

ersetzen2(_object,_ersetztInhalt) :-
    !,
    atom2list(_o,_object),
    pc_atomconcat(['{',_o,': ///not replaced///}'],_value),
    appendBuffer(_ersetztInhalt,_value).









/********************************************************************************************************************/
/*FindObj liefert ein zuersetzenden Objekt als eine Charliste zurueck, allerding soll es nicht ein Praedikate sein. */
/*Bsp: 'this.attribute', 'this.dept.head', '[x].salary', etc.  Man bemerkt Variable koennen auch vorkommen...       */
/********************************************************************************************************************/

findObj(['}'|_rpatternlist],[],_rpatternlist):-
    !.

/*Wenn zuersetzende Teil ( oder ) enthaelt, dann handelt es sich um Praedikate...*/
findObj(['('|_rpatternlist],[],_rpatternlist):-
    !,
    fail.

findObj([')'|_rpatternlist],[],_rpatternlist):-
    !,
    fail.

/*TODO: StringBuffer*/
findObj(['{'|_rpatternlist],_objectlist,_rlist):-
    !,        /*Hier kann nur eine Variable vorkommen!!*/
    createBuffer(_buf),
    !,
    ersetzen(_rpatternlist,_buf,_rlist1),
    findObj(_rlist1,_restobjectlist,_rlist),
    atom2list(_restobject,_restobjectlist),
    appendBuffer(_buf,_restobject),
    getStringFromBuffer(_object,_buf),
    atom2list(_object,_objectlist),
    disposeBuffer(_buf),
    !.

findObj(['\\'|_rpatternlist],[_s|_rObjlist],_r):-
    !,
    sonderZeichen(_rpatternlist,_restpatternlist,_s),
    findObj(_restpatternlist,_rObjlist,_r).

findObj([_x|_rpatternlist],[_x|_rObjlist],_r):-
    findObj(_rpatternlist,_rObjlist,_r).



/*****************************************************************************************************************************/
/* Hier wird eine Pfad-Ausdruck hinter einander geparst und abgearbeitet, z.B. '.dept.head' . Dieser Ausdruck repraesentiert */
/* Wertebzgl. den SMLfragmentlsite, z.B. '.dept' repraesentiert Werte unter Kategorie dept in Bezug auf den angegebenen      */
/* SMLfragment. SMLfragment konnte geschachtet sein, deswegen kommen solche komplexe Ausdrucke vor, wie '.dept.head',        */
/* hier ist der Attributwert von dept wieder SMLfragment. parsen_PathExp() liefert eine Liste von Atom/Term zurueck.         */
/*****************************************************************************************************************************/
addAtomListToBuffer(_buffer,[_f]):-
      appendBuffer(_buffer,_f).

addAtomListToBuffer(_buffer,[_f|_rlist]):-
      appendBuffer(_buffer,_f),
      appendBuffer(_buffer,'\001'),  /** Ascii char \001 is placeholder for ',' **/
      addAtomListToBuffer(_buffer,_rlist).

parsen_PathExp(_eValue,[],_ersetzt_Value):-
      addAtomListToBuffer(_ersetzt_Value,_eValue),!.

parsen_PathExp(_fraglist,_pathExp,_ersetzt_Value):-
     getHead(_pathExp,_h,_t),
        (
            (
        _h=='.this',
        !,
        'Out_Object'(_fraglist,_valuelist)
        );
          (
        _h=='.oid',
        !,
        'Out_ObjectId'(_fraglist,_valuelist)
        );
        (
        _h=='.inOmega',
        !,
        'Out_SystemClass'(_fraglist,_valuelist)
        );
        (
        _h=='.in',
        !,
        'Out_Class'(_fraglist,_valuelist)
        );
        (
        _h=='.isa',
        !,
        'Out_SuperClass'(_fraglist,_valuelist)
        );
            (
        _h=='.attribute',
        !,
        'Out_all_attribute_values'(_fraglist,_valuelist)
        );
            (
        _h=='|attribute',
        !,
        'Out_all_attribute_labels'(_fraglist,_valuelist)
        );
        (
        _h=='.attrCategory',
        !,
        'Out_all_attribute_Categories'(_fraglist,_valuelist)
        );
            (
        pc_atomconcat('.',_attr_cat,_h),
        !,
        'Out_attribute_value'(_fraglist,_attr_cat,_valuelist)
        );
            (
        pc_atomconcat('^',_attr_label,_h),
        !,
        'Out_label_value'(_fraglist,_attr_label,_valuelist)
        );
            (
        pc_atomconcat('|',_attr_cat,_h),
        !,
        'Out_attribute_label'(_fraglist,_attr_cat,_valuelist)
        )
        ),
    parsen_PathExp(_valuelist,_t,_ersetzt_Value).


/*******************************************************************/
/* Ein pfad wie '.dept.head' wird hinter einander abgearbeitet,    */
/* getHead liefert zuerst das erst Teil,in diesem Fall ist '.dept'.*/
/*******************************************************************/
getHead([_f|_rest_pathExp],_h,_t):-
    member(_f,['.','!','|','^']),
    findNextTeilPath(_rest_pathExp,_nextTeilPath,_t),
    append([_f],_nextTeilPath,_h1),
    atom2list(_h,_h1).


findNextTeilPath([],[],[]).
findNextTeilPath([_f|_rest],[],[_f|_rest]):-
    member(_f,['.','!','|','^']).
findNextTeilPath([_f|_rest],[_f|_r],_rpath):-
    findNextTeilPath(_rest,_r,_rpath).



/********************************************************************************************************************/
/*Hier wird zuerst ueberprueft man ob es nach \ ein Zeichen mit spezielle Bedeutung gibt, Moment gibt es \n,\t,\b.  */
/*Wenn nicht, dann heisst, sit ein normale Sondersymbol, wird einfach uebernehmen, z.B. '"','[',']','(',')',',',etc.*/
/********************************************************************************************************************/

sonderZeichen(['\\','n'|_restpatternlist],_restpatternlist,'\n'):-
    !.

sonderZeichen(['\\','t'|_restpatternlist],_restpatternlist,'\t'):-
    !.

sonderZeichen(['\\','b'|_restpatternlist],_restpatternlist,'\b'):-
    !.

/** empty atom denoted as '\0' in answer formats **/
sonderZeichen(['0'|_restpatternlist],_restpatternlist,''):-
    !.




/*Hier ist fuer den Fall _s == ",[,],(,)...*/
sonderZeichen([_s|_restpatternlist],_restpatternlist,_s):-
    !.




callpraed(_functor,_arglist,_outputBuffer):-
    _p=..[_functor|[_outputBuffer|_arglist]],
    pc_has_a_definition(_p),   /** to prevent crashes when _p is undefined **/
    call(_p),
    !.

callpraed(_functor,_arglist,_):-
    _p=..[_functor|[_out|_arglist]],
    'WriteTrace'(low,'AnswerTransform',['Call to predicate  ',_p,' failed!']),
    !,
    fail.


parsen_foreach(['F','o','r','e','a','c','h','('|_rpatternlist11],_ersetztInhalt,_rlist):-
    'Ignore_blank'(_rpatternlist11,_rpatternlist1),
    parsen_var_value(_rpatternlist1,_rpatternlist21,_varValueList),        /*varValueList==[ [[w,a,n,g],[q,u,i,x]],[[1,0,0,0],[3,0,0,0]]]*/
    'Ignore_blank'(_rpatternlist21,_rpatternlist2),
    parsen_var(_rpatternlist2,_rpatternlist3,_varlist),                /*varlist == [ wh, qu ]*/
    (
     (foreach(_varValueList,_varlist,_rpatternlist3,_rlist1,_ersetztInhalt),!);
     (remove_initialed_values(_varlist),!,fail)
    ),
    _rlist1 = [')','}'|_rlist].



/*Hier fuer den Fall das initial_variable failed, d.h. Forschleife fertig!*/
foreach([[]|_rvarValueList],_varlist,_patternlist,_rpatternlist,_ersetztInhalt):-
    !.

/*initial_variable ist sowie eine Zaehler, wenn alle Werte einmal gebrauchte, dann fertig mit Foreach.*/
foreach(_varValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt):-
    initial_variable(_varValueList,_varlist,_restvarValueList),
    expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt, _restvarValueList).


/** for the current loop, all variables are bound to NULL; just ignore this binding and proceed with next. */
/** We have to call 'argumentparsen' for this case to get the correct setting for _rpatternlist, i.e. the  */
/** remaining pattern to be processed subsequently. We don't use its outout however here!                  */

expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt, _restvarValueList) :-
    allNULL(_varlist),
    createBuffer(_outputBuffer),
    !,
    argumentparsen(_patternlist,_outputBuffer,_rpatternlist),    /** we need to do this to instantiate _rpatternlist **/
    disposeBuffer(_outputBuffer),
    !,
    remove_initialed_values(_varlist),
    foreach(_restvarValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt),
    !.

/** not all variable are bound to NULL: do normal expansion */
/** this sets __rpatternlist anyway                         */

expandInnerPattern(_varValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt, _restvarValueList) :-
    createBuffer(_outputBuffer),
    !,
    argumentparsen(_patternlist,_outputBuffer,_rpatternlist),
    getStringFromBuffer(_output,_outputBuffer),
    disposeBuffer(_outputBuffer),
    !,
    remove_initialed_values(_varlist),
    foreach(_restvarValueList,_varlist,_patternlist,_rpatternlist,_ersetztInhalt),
    appendBuffer(_ersetztInhalt,_output).


/** allNULL(_vars) is true when all variables in _vars are bound to [N,U,L,L] **/
allNULL([]) :- !.
allNULL([_var|_rest]) :-
    (pc_recorded(_var,'AnswerFormatVariable',['N','U','L','L']);
     pc_recorded(_var,'AnswerFormatVariable',['N','O','O','B','J','E','C','T'])),      /** 1-Nov-2000/MJf: NOOBJECT indicates that no solution is found, CBNEWS[201] */
    allNULL(_rest).


initial_variable(_varValueList,_varlist,_restvarValueList):-
    getfirstValue(_varValueList,_fvalues,_restvarValueList),
    recordValue(_fvalues,_varlist).

/*get the firstvalue for each variable*/
getfirstValue([],[],[]):-!.
getfirstValue([_varValues|_rvarValueList],[_fvalue|_rfvalues],[_restValues|_restvarValueList]):-
    _varValues \== [],              /* [] , dann heisst, es gibt keine Wert mehr for the Variable, fail,==> foreach fertig!*/
    _varValues = [_fvalue|_restValues],
    getfirstValue(_rvarValueList,_rfvalues,_restvarValueList).


/* Man bemerkt, fuer Einfachheit, heir erlaubt nur eindeutige Variable definition
! Also Varialble wird nicht mit Domain verbunden!!!*/
/* D.h. wenn unterschiedliche Variable in eine Patterndef sollen auch unterschied
liche bezeichnet werden.*/

recordValue([],_).

recordValue([_value|_rvalues],[_var|_rvar]):-
        pc_record(_var,'AnswerFormatVariable',_value),
        recordValue(_rvalues,_rvar).

recordParameters([]).
recordParameters([substitute(_val1,_name)|_r]) :-
    eval(_val1,replaceSelectExpression,_val), /* value of a parameter may be a select expression */
    atom2list(_val,_vallist),
    pc_record(_name,'AnswerFormatVariable',_vallist),
    recordParameters(_r).

eraseParameters([]).
eraseParameters([substitute(_val,_name)|_r]) :-
    pc_erase(_name,'AnswerFormatVariable'),
    eraseParameters(_r).

eraseAnswerParameters(_key) :-
  pc_erase_all(key).

addAnswerParameters(_key,[]) :- !.

addAnswerParameters(_key,[_val/_param|_rest]) :-
  ((pc_recorded(_param,_key,_),pc_rerecord(_param,_key,_val));
   pc_record(_param,_key,_val)),
  addAnswerParameters(_key,_rest).


  

remove_initialed_values([]).
remove_initialed_values([_var|_rvarlist]):-
        pc_erase(_var,'AnswerFormatVariable'),
        remove_initialed_values(_rvarlist).

parsen_var_value(['('|_rlist],_rpatternlist,_varValueList):-
    !,
    parsen_var_value(_rlist,_rpatternlist,_varValueList).

parsen_var_value([')'|_rlist1],_rlist,[]):-
    !,
    _rlist1=[_|_rlist]. /*komma soll auch weg!*/

parsen_var_value([','|_rlist],_rpatternlist,_varValueList):-
    !,
    parsen_var_value(_rlist,_rpatternlist,_varValueList).

parsen_var_value(['{'|_rlist],_rpatternlist,[_varValues|_rvarValueList]):-
    !,
    createBuffer(_varValuesBuffer),
    !,
    ersetzen(_rlist,_varValuesBuffer,_rpatternlist1),
    getPointerFromBuffer(_resultString,_varValuesBuffer),
    save_stringtoatom(_resultString,_varValues1),
    disposeBuffer(_varValuesBuffer),
    !,
    'TermToListOfStrings'(_varValues1,_varValues2),
    convertValuelist(_varValues2,_varValues),
    !,
    parsen_var_value(_rpatternlist1,_rpatternlist,_rvarValueList).

'TermToListOfStrings'([],[]):-!.

'TermToListOfStrings'(_term,_stringlist):-
    atom2list( _term, _atomlist ),
    atomListToStringList(_atomlist,_stringlist).

atomListToStringList([_a],[_a]).

atomListToStringList([_a|_b],[_h|_t]):-
    _b = [_c|_d],
    ( _c == '\001',_h = _a,atomListToStringList(_d,_t);
      pc_atomconcat(_a,_c,_atom),atomListToStringList([_atom|_d],[_h|_t])
    ).

/*Hier wird eine Liste von Atom/Term in Liste von CharListe umgewandelt. */
/*[800]-->[[8,0,0]] und [800,1000]-->[[8,0,0],[1,0,0,0]]            */

convertValuelist([],[]):-!.

convertValuelist([_f|_r],[_el|_rest]):-
    'TermToCharList'(_f,_el),
    !,
    convertValuelist(_r,_rest).


/*Man bemerkt hier ist _varList eine Liste von Atome!!!*/
parsen_var(['('|_rlist],_rpatternlist,_varList):-
    !,
    parsen_var(_rlist,_rpatternlist,_varList).

parsen_var([')'|_rlist1],_rlist,[]):-
    !,
    _rlist1=[_|_rlist].

parsen_var(_patternlist,_rpatternlist,[_var|_rvarList]):-
    createBuffer(_vlistBuffer),
    !,
    argumentparsen(_patternlist,_vlistBuffer,_rest),
    getPointerFromBuffer(_resultString,_vlistBuffer),
    save_stringtoatom(_resultString,_var),
    disposeBuffer(_vlistBuffer),
    !,
    parsen_var(_rest,_rpatternlist,_rvarList).

/******************************************************************************************************************************************/
/* Soll noch genauer beruecksichtigt werden, in Moment werden in Prinzip die Blanks before jede Functor, Argument der Funktion ignoriert...*/
/* D.h. Wir koennen schreibeb [Functor( arg1, arg2,   arg3)], diese Darstellung ist gleich wie [Functor( arg1,arg2,arg3)]                 */
/* Bei Foreach(x,y,z), die Leer Zeichen vor letzte Argument werden aber gezaehlt!!!*/
'Ignore_blank'([' '|_rlist],_restlist):-
    !,
    'Ignore_blank'(_rlist,_restlist).

'Ignore_blank'(_rlist,_rlist) :- !.



/**************************************************************************************************************************/
/* ersetzen() wird eine List von Atom/Term liefen, dann muesst diese List in eine Charlist umwandeln. TermListToCharList  */
/* Wandelt eine Liste von Atom/Term in Charlist um, man bemerkt, komma soll nicht vergesst werden.             */
/* Bsp: [100,200]==>[1,0,0,,,2,0,0]                                             */
/**************************************************************************************************************************/

'TermListToCharList'([],[]).
'TermListToCharList'([_term|_rest],_charlist):-
    (
    ('TermToCharList'(_term,_clist1),_rest==[]);
    ('TermToCharList'(_term,_clist11),append(_clist11,[','],_clist1))
    ),
    'TermListToCharList'(_rest,_clist2),
    append(_clist1,_clist2,_charlist).


