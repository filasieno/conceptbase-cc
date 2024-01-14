/**
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
**/
/* *********************************************************** */
/*            A C H T U N G                                    */
/* Generell wurden in diesem File die geschweiften Klammern in */
/* Kommentaren durch eckige Klammern ersetzt, da der           */
/* PrologPreProcessor nicht damit umgehen kann.                */
/* *********************************************************** */


/*
* File:		ExternalConnection.pro
* Creation:	1998, Wang Hua(RWTH)
*/


/*


Das Modul ExternalConnection stellt die Methoden bereit, die Zugriffe auf externe Quellen realisiert.
Anhand eines Beispiel-DB mainlibrary wird die Realisierung des externen Zugriffs verdeutlicht.


1) Um mit dem externen Datenquelle-Server kommunizieren zu koennen, muss der externe JEB-Server zuerst gestartet werden.
	gehe zu .../JEBserver, dann starten mit runjava host port 	( host und port deutet an, wo der CB-Server laeuft, z.B. warhol 4001)

2) Zuerst muss die externe Quelle in CB definiert werden. Hier muessen die URL der Quelle und des Treibers angegeben werden.

Individual mainlibrary in ExternalDataSource with
  attribute,url
     eurl : "JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary"
  attribute,driver
     edriver : "i5.cb.jdbc.JEBJdbcDriver"
end

Das Attribut driver gibt die URL des zu verbindende Treibers an, in diesem Fall, die Bruecke zwischen JEB und JDBC: JEBJdbcDriver.
Der Treiber wird waerend der Verbindungsaufbau geladen. Danach versucht er dann mit der Datenquelle anzubinden. Die URL der Datenquelle wird
im Attribut url angegeben. Oft werden noch weitere Treiber benoetigt, die URLs dieser Treiber werden auch in url mitgegeben.
Allgemein kann dies eine Form wie: "Prefix:URLs der weiteren Treiber:URL der Datenquelle".
Z.B. JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary



Waehrend der Abspeicherung dieser Quellen-Definition wird noch die Metadaten aus dieser Quelle geladen. Die Metadaten entsprechen den
Schema-Definitionen und werden unter ExternalObjekt abgespeichert. Diese Information dienen als Einstiegspunkte fuer die spaeter zu ladende
externe Daten.

z.B.:
Individual itemInmainlibrary in ExternalObject with
  attribute,field
     "author_name": LONGVARCHAR;
     "title" : LONGVARCHAR;
     "subject" : LONGVARCHAR
  attribute,key
     itemkey : "SET(NULL)"
  attribute,datasource
     EmployeeDatasource : mainlibrary
end

BEM:
	1) Um moegliche Name-Konflikte zu vermeiden, werden alle importierten Namen in CB als "externe Name" + "In" + "Name der Quelle" bezeichnet.
	z.B. fuer die Tabelle item in mainlibrary wird in CB als itemInmainlibrary bezeichnet.
	2) Weil externe Quellen eine andere Syntax als unsere haben koennten, werden alle Attribute mit " " geklammert,
	somit koennen fast alles in CB dargestellt werden.


3) Als naechstes koennen externe Sichten konstruiert werden. Eine externe Sicht entspricht einer direkten Anfrage an die externe Quelle.
Sie wird durch einen Quellennamen und ein Anfragestring spezifiziert.

Individual Author in ExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select author_name, title from item"
end

Hier wird eine Sicht konstruiert, die alle Buecher mit Namen und Autoren liefern soll. Hier bemerkt man, das die entsprechende Attribute
dafuer fehlen! Diese sind noetig, denn sonst waere es nicht konsistent, die zugehoerige Daten (Buecher mit Namen und Autoren) unter dieser
Sicht abzulegen.
Diese Attributerweiterung wird automatisch waehrend der Sichtabspeicherung gemacht. Die tatsaechliche Sicht in CB sieht dann wie folgt aus:

Individual Author in ExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select author_name, title from item"
  attriut, field
     "author_name" : LONGVARCHAR;
     "title" : LONGVARCHAR
end


Weiter um Benutzer die Sicht-Definition zu erleichtern, werden noch generische externe Sichten gegeben.
Diese Sichten enthalten parametisierte Anfragestrings, in denen aehnliche Anfragen zusammengefasst werden koennen.
Um diese zu benutzen, braucht man nur einfach den Namen und die passende Parameter anzugeben.


Individual BookofAuthor in GenericExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select title from item where author_name=\"[author]\""
  attribute,parameter
     author : String
end



BEM:
	1) " und \ sind Sondersymbole, sollen durch \ escapt werden.
	2) Parameter werden normalerweise als String deklariert. Die Hochkommta werden allerdings bei Parsen des Anfragestrings automatisch
	entfernt, z.B. "select ... where salary=[x]" und x ist "1000.0", dann nach dem Parsen wird enstanden: "select...where salary=1000.0".
	Wenn man trotz die Hochkommata in dem Anfragestrin benoetigt, muss  dann selber in Anfragestring einbauen, wie das Beispiel oben.


4) Weiterhin kann man festlegen, wie diese externe Objekte (ExternalObject, ExternalQuery) geladen und abgespeichert werden sollen.
Normalerwiese werden alle externe Daten ohne Integritaetsueberpruefung in CB geladen, um die Ladezeit zu reduzieren. Wenn aber IC noetig
ist, kann man durch spezifikation des Attributs check von ExternalQuery oder ExternalObject die IC wieder aktivieren.
z.B.
itemInmainlibrary with
  check
	icheck: TRUE
end

Desweiteres bemerkt man, dass alle externe Objekte im Moment nur virtuell in CB existieren, denn alle ihren Instanzen liegen noch in
externen Quellen. Diese Daten koennen aber auch vorher in CB materialisert sein, um somit eine schnelle Auswertung zu erreichen.

itemInmainlibrary with
  store
	istore: TRUE
end

Mit dem Attribut store von ExternalQuery und ExternalObjekt kann man spezifizieren, ob die Instanzen materialisiert werden sollen oder nicht.
Wenn store=True in CB getellt wird, werden die zugehoerigen Instanzen automatisch aus externen Quellen importiert und in CB festgespeichert.


5) Anfragen:
Nach alle Metadaten importiert sind und alle ExternalQuery/GenericExternalQuery definiert sind, koennen wir
die externe Quelle main abfragen. Eine Anfrage koennen externe Objekte referenzieren (ExternalObject, ExternalQuery und GenericExternalQuery),
deren Instanzen entweder in CB schon materialisiert sind oder nur virtuell in CB existieren. Waehrend einer Anfrageauswertung, falls externe
Objekte betroffen sind, und deren Instanzen noch nicht in CB importiert sind, werden sie dann aus externen Quellen geladen und kurzfristig
in CB abgespeichert.

Anfrage mit ExternalObject:

Aut1 in QueryClass isA String with
  attribute,computed_attribute
     title : String;
     subject: String
  attribute,constraint
     ac : $exists i/itemInmainlibrary A(i, "author_name", this) and A(i, "title", ~title) and A(i, "subject", ~subject)$
end

Anfrage mit ExtenalQuery:

Aut2 in QueryClass isA String with
  attribute,computed_attribute
     title : String
  attribute,constraint
     ac : $exists a/Author A(a, "author_name", this) and A(a, "title", ~title)$
end

Anfrage mit GenericExternalQuery:

BookOfAut in QueryClass isA BookofAuthor["David Flanagan" / author] with
  attribute,retrieved_attribute
     "title" : VARCHAR
end


*/

:- module('ExternalConnection',[
'External_Update'/2
,'LoadExQStructure'/1
,'ObjectLoadedflag'/1
,'ifcheck'/1
,'remove_tmp_infos'/0
,'tell_temp_ExObj'/1
,'testIfExistsExternalDataSource'/0
,'testIfShallLoad'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ExternalCodeLoader.swi.pl').

:- use_module('BimIpc.swi.pl').
:- use_module('GeneralUtilities.swi.pl').



:- use_module('IpcParser.swi.pl').






:- use_module('CBserverInterface.swi.pl').
:- use_module('ClientNotification.swi.pl').
:- use_module('IpcChannel.swi.pl').



:- use_module('ErrorMessages.swi.pl').
:- use_module('Literals.swi.pl').




:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('ObjectProcessor.swi.pl').





:- use_module('TellAndAsk.swi.pl').

:- use_module('AnswerTransformator.swi.pl').
:- use_module('AnswerTransform.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('TransactionTime.swi.pl').




:- use_module('FragmentToPropositions.swi.pl').
:- use_module('LanguageInterface.swi.pl').
:- use_module('PrologCompatibility.swi.pl').







  /** 22-Jun-2004/M.Jeusfeld **/



:- dynamic 'ObjectLoadedflag'/1 .

:- dynamic 'ifcheck'/1 .


:- style_check(-singleton).







/*****************************   LoadDataSourceMetaData    ***************************************/
/* Laden der Metadaten einer externen Quelle wird von ECAregel getriggert, waehrend TELL eines 	*/
/* ExternalDataSource-Objects.  LoadDataSourceMetaData sammelt alle DB-informationen aus dem	*/
/* angegebenen DB-Name, konstruiert eine IPC-Nachricht und schickt die nach der Java-Seite.	*/
/* Die Metadaten bestehen aus DB-Schemata und Typ-Infos, und sollen als SML-Fragmente geliefert	*/
/* werden. Wenn die Antwort leer ist, d.h. es kommt Fehlern vor, entweder sind die DB-Infos  	*/
/* falsch angegeben oder laeuft der Datequelle-Server nicht richtig. Wenn die Antwort nicht 	*/
/* leer, werden diese Metadaten in CB abgespeichert.						*/
/*************************************************************************************************/

'LoadDataSourceMetaData'(_ds):-
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!\n'),!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getDSinfo(_ds,_infoCharlist),
	length(_infoCharlist,_charlistlength),
	'CharListToCString'(_cstring,_infoCharlist,_charlistlength),
	write('Load Metadata from Datasource: '),write(_ds),write(' ...\n\n'),
	make_ipcanswerstring( _answerstring, _receiver,loadMetaData, _cstring, _answerlen ),
	memfree(_cstring),
	!,	
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer),
	(
	(_answer==[''],
	write('Load Metadata from '),write(_ds),write(' failed!\n'),
	write('Check the given DB-infos and the DB status...\n\n'),
	!,fail);
	(write('Got Metadata from ExternalSource and prepare for telling...\n'),
	'TellExDaten'(_answer,'Datasource Metadata '))
	).


/* *******************************  DelDataSourceMetaData    *********************************************/
/* Hier wird versucht, waehrend UNTELL einer Quelle-Definition in CB, deren Metadaten entsprechend 	*/
/* auch geloescht werden. 										*/

'DelDataSourceMetaData'(_ds):-
	name2id(_ds,_dsID),
	findall(_ObjID,prove_literal('A'(_ObjID,datasource,_dsID)),_ObjIDlist),
	write('Metadata will be untold...\n'),
	'UNTellExDaten'(_ObjIDlist).


/************************************** LoadExQStructure *********************************************** */
/* Waehrend der Definition eines ExternalQuery/GeniericExternalQuery Objekts soll diese Definition um 	*/
/* entsprechende Attribute erweitert werden. Diese Attribute ensprechen die Struktur-Beschreibung	*/
/* des Anfragestrings.											*/
/* LoadExQStructure sammelt die Datenquelle-Infos, zusammen mit dem Anfragestring konstruiert der 	*/
/* eine IPC-Nachricht, und schickt sie an der Java-Seite. Wenn die Antwort leer ist, d.h. es kommt	*/
/* Fehler vor, entweder die DB-Infos oder die Anfragestring sind falsch angegeben. Wenn die nicht 	*/
/* leer, werden diese Attribute demansprechend adgespeichert. 						*/

/* Hier unterscheiden wir noch Erweiterung fuer ExternalQuery und fuer GenericExternalQuery. 		*/
/* Bei Definition einer ExternalQuery-Objekts, wird die Erweiterung durch ECA-Regel getriggert. 		*/
/* Wenn man eine GenericExternalQuery definiert, werden die Attribute noch nicht geladen, denn 		*/
/* die Anfrage ist nicht vollstaendig. Erst bei deren Spezialisierungen mit angegebenen Parametern, 	*/
/* werden die Attribut-Erweiterung durchgefuehrt. Allerdings wird es nicht von ECA-Regeln getriggert,	*/
/* sonder direkt aus FragmentToPropositions aufgerufen, waehrend Abspeicherung dieser Spezialisierung.	*/
/* Der Grund dafuer ist: diese Spezialiserungen kommen in IsA-Teil einer Anfrage vor und die Anfrage 	*/
/* muss nicht notwendigeweise in CB fest gespeichert werden. Deswegen kann eine Spezialisierung entweder */
/* fest oder temproraer abgelegt werden, entsprechend auch fuer die erweiterten Attribute. Die ECA-Regel */
/* kann die feste oder temproraere Abspeicherung aber nicht unterscheiden. 				*/

/*Hier prueft es, Ob Attribute schon erweitert sind.*/
'LoadExQStructure'(derive(_qID,_slist)):-
	pc_atom_to_term(_Objatom,derive(_qID,_slist)),
  	retrieve_proposition('P'(_id,_id,_Objatom,_id)),
	prove_literal('A'(_id,field,_)),
	!.

'LoadExQStructure'(derive(_Obj,_plist)):-
	!,
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!\n'),!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getGenExQueryinfo(_Obj,_plist,_infoCharlist), /* Drei stellig, fuer GenericExternalQuery*/
	length(_infoCharlist,_charlistlength),
	'CharListToCString'(_cstring,_infoCharlist,_charlistlength),
	write('Load  QueryStructure for '),write(derive(_Obj,_plist)),write(' ...\n'),
	make_ipcanswerstring( _answerstring, _receiver,loadExQueryStructure, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer),
	(
	(_answer==[''],
	write('Load attribut for '),write(derive(_Obj,_plist)),write(' failed!\n'),
	write('Check the given DB-infos, query and the DB status...\n\n'),
	!,fail);
	(write('Got attribute for '),write(derive(_Obj,_plist)), write(' and prepare for telling...\n'),
	'TellExDaten'(_answer,'GenericExternalQuery structure'))
	).


'LoadExQStructure'(_Obj):-
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!'),nl,!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getExQueryinfo(_Obj,_infoCharlist),
	length(_infoCharlist,_charlistlength),
	'CharListToCString'(_cstring,_infoCharlist,_charlistlength),
	write('Load  QueryStructure for '),write(_Obj),write(' ...'),nl,
	make_ipcanswerstring( _answerstring, _receiver,loadExQueryStructure, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer),
	(
	(_answer==[''],
	write('Load attribut for '),write(_Obj),write(' failed!\n'),
	write('Check the given DB-infos, query and the DB status...\n\n'),
	!,fail);
	(write('Got attribute for '),write(_Obj), write(' and prepare for telling...\n'),
	'TellExDaten'(_answer,'ExternalQuery structure'))
	).



/* ************************* tell_temp_ExObj *************************************************** */
/* tell_temp_ExObj laedt alle Instanzen von angegeben externen Objekten aus externen Quellen.	*/
/* Externe Objekte koennen ExternalQuery, GenericExternalQuery oder ExternalObjekt sein koennen.	*/
/* Die geladenen Instanzen werden dann temproraer in CB gespeichert.				*/
/* ********************************************************************************************* */

tell_temp_ExObj([]).

tell_temp_ExObj([_ExObj|_res]):-
	id2name(_ExObj,_ExObjName1),
	pc_atom_to_term(_ExObjName1,_ExObjName),
	'GetExInstance'(_ExObjName,_answer),
	(
	(_answer==[''],
	write('Loadinstance for '),write(_ExObjName1),write(' failed!\n'),
	write('No instances exist or the name is wrong!\n\n'));
	(write('Got instances for '),write(_ExObjName1),write(' and prepare for telling...\n\n'),
	'TellExDaten'(_answer,'Instance ')),
	!,
	assert('ObjectLoadedflag'(_ExObjName)),	/*Damit man weiss, ob ein externen Objekt waehrend der Anfrageauswertung schon im CB geladen ist.*/
	(ifcheck(yes);
	if_not_check(_ExObj);
	assert(ifcheck(yes)))
	),
	tell_temp_ExObj(_res).



tell_temp_ExObj(_qlist):-
	remove_tmp_infos,
	handle_error_message_queue(error),
	!,
	fail.

/* ************************** remove_tmp_infos ***********************************/
/* Fuer di Anfrageauswertung werden die Instanzen von externen Objekten		*/
/* temproraer in CB abgelegt, nach der Auswertung mussen sie aber entfernt	*/
/* werden...									*/

remove_tmp_infos:-
	remove_temp_exports_imports,
  	remove_transaction_time,
  	remove_temporary_information,
        'WriteListOnTrace'(high,['   ... [1] temporary information retracted\n']),  /** not very interesting message **/
	!.



/********************************************** testIfShallLoad **************************************************************** */
/* Hier wird ueberpfrueft, ob ein Object aus externen Datenquellen sind, und ob das schon geladen ist.				*/
/* ***************************************************************************************************************************** */

testIfShallLoad([],[]) :- !.
testIfShallLoad([_o|_r],[_o|_rest]):-
	testIfFromExtern(_o),
	id2name(_o,_oName1),
	pc_atom_to_term(_oName1,_oName),
	not('ObjectLoadedflag'(_oName)),
	if_not_stored(_o),
	!,
	testIfShallLoad(_r,_rest).


testIfShallLoad([_o|_r],_ObjToLoad):-
	testIfShallLoad(_r,_ObjToLoad).



testIfFromExtern(_id):-
	name2id('ExternalQuery',_exQueryid),
	prove_literal('In_e'(_id,_exQueryid)),
	prove_literal('A'(_id,field,_)).

/*prove_literal(A(_id,field,_)) wird hier GenericExternalQuery mit nicht initializiert Parameter aussotiert! Denn wenn wir GEQ[...] schreiben,*/
/*Dann werden GEQ und GEQ[...] gefunden! Aber GEQ wollen wir nicht! Die Unterschied zwischen die Beide liegt dran, dass fuer GEQ[...] haben*/
/* Wir schon Attributen erweitert! GEQ natuerlich nicht!*/

testIfFromExtern(_id):-
	name2id('ExternalObject',_exObjid),
	prove_literal('In_e'(_id,_exObjid)).

testIfExistsExternalDataSource :-
    name2id('ExternalDataSource',_id),
    retrieve_proposition('P'(_,_,'*instanceof',_id)).


if_not_stored(_id):-
	name2id('TRUE',_tid),
	prove_literal('A'(_id,store,_tid)),
	!,
	fail.
if_not_stored(_id).

if_not_check(_id):-
	name2id('TRUE',_tid),
	prove_literal('A'(_id,check,_tid)),
	!,
	fail.
if_not_check(_id).



/* ************************* wait_answer *****************************/
/* wait_answer wartet die Nachricht aus Java-Seite(JEBserver) bis    */
/* die entsprechende Nachricht kommt.				    */

wait_answer(_answer):-
	knownTool(_,'JEBserver',_,_fd,'System'),
	_rfd is 1 << _fd,
	select_input( _rfd, _sfd ),
	extern_allocate( _ipo, 'IpcParserOutput' ),
	client_db_files( _fd , _inp , _out ),
	get_ipcmessage( _inp, _msg, _out, _fd, _inp),
	!,
	'IpcParse'( _msg, _ipo ),
	memfree( _msg ),
	!,
	extern_get( _ipo^err, _err ),
	((_err = 0,
 	 get_answer( _err, _fd, _out, _ipo,_answer ),
	 extern_address( _ipo^im^0, _im ),
	 pc_pointer(_im),
	 (
		( \+(pc_isNullPointer(_im)),
	  	'DeleteIpcMessage'( _im ),
	  	! )
		;
		true
	 ),
	 extern_deallocate( _ipo ));
	(serve_goal2( _err, _fd, _out, _ipo ), /* Error */
	 extern_deallocate( _ipo ))),
	!.


get_answer( 0, _fd, _out, _parserOutput,[_answerString] ) :-
	'GetIpcMessageFromC'( _parserOutput, ipcmessage(_ToolId,_CBserverId,'TELL',[_answerString1])),
	strdup(_answerString,_answerString1).








/* ******************************* TellExDaten *********************************************************	*/
/* TellExDaten speichert die angegebenen Daten in CB temproraer ab. Man bemerkt, dass hier wird kein	*/
/* semantische Integritaetscheck(IC) durchgefuehrt wird! Denn das Metadatenladen geschieht waehrend 	*/
/* der Definition einer externen Quelle, das IC wird sowieso nachher durchgefuehrt.			*/


'TellExDaten'([_answer],_comment):-
	pc_pointer(_answer),
	build_fragments_from_cstring(_answer,_fraglist),
        'SetUpdateMode'('UPDATE'),
	do_tell(_fraglist),
	write(_comment),write(' temporarily told!\n\n'),
  	'RemoveUpdateMode'(_).


'UNTellExDaten'([]):-
	!.
'UNTellExDaten'(_ObjIDlist):-
	getFragmentlist(_ObjIDlist,_fraglist),
        'SetUpdateMode'('UPDATE'),
	do_untell(_fraglist),
	write('Metadata temporarily untold!\n\n'),
  	'RemoveUpdateMode'(_).



getFragmentlist([],[]):-!.
getFragmentlist([_Obj|_Objrest],[_frag|_fragrest]):-
	ask_objproc(ask([derive(get_object,[substitute(_Obj,objname)])],'FRAGMENT'),'Now',_frag),
	getFragmentlist(_Objrest,_fragrest).






/* *****************************  GetExInstance  ***************************************************/
/* GetExInstance laedt die Instanzen von angegebenen Objekten, die ExternalObjekt, ExternalQuery   */
/* oder GenericExternalQuery sein koennen. GenericExternalQuery hat die Form: derive(_Obj,_plist). */

'GetExInstance'(derive(_Obj,_plist),_answer):-	/*GenericExternalQuery*/
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!'),nl,!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getGenExQueryinfo(_Obj,_plist,_infoCharlist),
	length(_infoCharlist,_charlistlength),
	'CharListToCString'(_cstring,_infoCharlist,_charlistlength),
	write('Load Instanz for '),write(derive(_Obj,_plist)),write(' ...\n\n'),
	make_ipcanswerstring( _answerstring, _receiver,loadExQInstance, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer).

'GetExInstance'(_Obj,_answer):-			/*ExternalQuery oder ExternalObjekt*/
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!'),nl,!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getExinfo(_Obj,_mode,_infoCharlist),
	length(_infoCharlist,_charlistlength),
	'CharListToCString'(_cstring,_infoCharlist,_charlistlength),
	write('Load Instanz for '),write(_Obj),write(' ...\n\n'),
	make_ipcanswerstring( _answerstring, _receiver,_mode, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer).



/********************* External_Update ******************************************* */
/* External_Update fuehrt eine Update-Operation durch. Aus der Update-Anweisung    */
/* und die Datenquelle-Infos werden eine IPC-Nachricht gebaut und nach Java-Seite  */
/* gesendet. Die Operation wird dort ausgefuehrt, und die entsprechende Reaktionen */
/* werden zurueckgeliefert(Successful oder Failed...				  */


'External_Update'(_CharlistOfOperation,_desID):-
	(
		knownTool(_toolId,'JEBserver',_,_fd,'System');
		(write('Please start JEBserver first!!!'),nl,!,fail)
	),
	thisToolId(_receiver),
	client_db_files( _fd , _inp , _out ),
	!,
	getUpdateinfo(_CharlistOfOperation,_desID,_infostring),
	length(_infostring,_charlistlength),
	'CharListToCString'(_cstring,_infostring,_charlistlength),
	write('Update operations will be executed ... '),nl,
	make_ipcanswerstring( _answerstring, _receiver,'Update', _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer([_answer]),
	write('Get Reaction from JEBserver:   '),write(_answer),nl,nl.





/* ************************************************** getXXXinfo ******************************************************* */
/*															*/
/* Wir haben jetzt fogende moegliche InfoPattern, die mit IPC-message an Java-Seite zugeschickt werden koennen.		*/
/*	a) Laden von Metadaten: [DSName][Url][driver][]									*/
/*	b) Laden von Objekt Instanzen:											*/
/*		b.1) Fuer ExternalObject [ObjectName][Url][driver][SchemaName] Man bemerkt hier ObjectName ist		*/
/* 		     Darstellung in CB, und SchemaName ist der eigentliche Name in externen Quelle, 			*/
/*		     z.B. testInmysql und test.										*/
/*		b.2) Fuer ExternalQuery [ObjectName][Url][Driver][Anfragestring]					*/
/*		b.3) Fuer GenericExternalQuery [ObjectID][Url][Driver][Anfragestring]					*/
/*		     Man bemerkt dass das Anfragestring vorher geparst werden, d.h. die Parametern werden eingesetzt.	*/
/*	c) Laden von ExternalQueryStrukturInfo, wie b.2)								*/
/*	d) Update : [][Url][Driver][Update-Command]									*/
/*															*/
/*********************************************************************************************************************** */


/*fuer loadDataSourceMetaData*/
getDSinfo(_ds,_infostring):-
	name2id(_ds,_dsID),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	'TermToCharList'(_ds,_dschar),
	multiAppend([['{'],_dschar,['}','{'],_url,['}','{'],_driver,['}','{'],['}']],_infostring).



/*fuer GetExInstanz*/
getExinfo(_Obj,loadExObjInstance,_infostring):-
	name2id(_Obj,_ObjID),
	name2id('ExternalObject',_ExObjID),
	prove_literal('In'(_ObjID,_ExObjID)),
	getExObjinfo(_Obj,_infostring).

getExinfo(_Obj,loadExQInstance,_infostring):-
	name2id(_Obj,_ObjID),
	name2id('ExternalQuery',_ExQueryID),
	prove_literal('In'(_ObjID,_ExQueryID)),
	getExQueryinfo(_Obj,_infostring).

/*fuer Laden der Instanzen von ExternalObject. Hier werden die Instanzen gemaess eines Objekts aus externer Quelle importiert.*/
/*Man bemerkt, dass der Name vorher konvertiert werden muss, z.B testInmysql --> test. 					     */
getExObjinfo(_Obj,_infostring):-
	name2id(_Obj,_ObjID),
	prove_literal('A'(_ObjID,datasource,_dsID)),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	(
	(name2id('ExternalObject',_ExObjID),
	 prove_literal('In'(_ObjID,_ExObjID)),
	 id2name(_dsID,_ds),
	 pc_atomconcat('In',_ds,_dsterm),
       	 pc_atomconcat(_Obj1,_dsterm,_Obj),
	 'TermToCharList'(_Obj1,_SchemaName));
	 'TermToCharList'(_Obj,_SchemaName)
	),
	'TermToCharList'(_Obj,_Objchar),
	multiAppend([['{'],_Objchar,['}','{'],_url,['}','{'],_driver,['}','{'],_SchemaName,['}']],_infostring).

/*fuer loadExStructure, getExObjinfo*/
getExQueryinfo(_Obj,_infostring):-
	name2id(_Obj,_ObjID),
	prove_literal('A'(_ObjID,datasource,_dsID)),
	get_query(_ObjID,_query),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	'TermToCharList'(_Obj,_Objchar),
	multiAppend([['{'],_Objchar,['}','{'],_url,['}','{'],_driver,['}','{'],_query,['}']],_infostring).

/*fuer GenericExternalQuery             */
/*Das Anfragestring muss vorher geparst.*/
getGenExQueryinfo(_ObjID,_plist,_infostring):-
	prove_literal('A'(_ObjID,datasource,_dsID)),
	get_query1(_ObjID,_query_with_parameter),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	parseQueryString(_query_with_parameter,_plist,_query),
	pc_swriteQuotes(_atom,derive(_ObjID,_plist)),
	retrieve_proposition('P'(_Oid,_Oid,_atom,_Oid)),
	'TermToCharList'(_Oid,_Objchar),
	multiAppend([['{'],_Objchar,['}','{'],_url,['}','{'],_driver,['}','{'],_query,['}']],_infostring).


/*fuer Update */
getUpdateinfo(_CharlistOfOperation,_desID,_infostring):-
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	multiAppend([['{'],['}','{'],_url,['}','{'],_driver,['}','{'],_CharlistOfOperation,['}']],_infostring).

get_url(_id,_url):-
	prove_literal('A'(_id,url,_urlID)),
	retrieve_proposition('P'(_urlID,_urlID,_url1,_urlID)),
	'TermToCharList'(_url1,_url),!.
get_driver(_id,_driver):-
	prove_literal('A'(_id,driver,_driverID)),
	retrieve_proposition('P'(_driverID,_driverID,_driver1,_driverID)),
	'TermToCharList'(_driver1,_driver),!.
get_query(_id,_query):-
	prove_literal('A'(_id,query,_queryID)),
	retrieve_proposition('P'(_queryID,_queryID,_query1,_queryID)),
	'TermToCharList'(_query1,_query),!.

/* Hier ist fuer den Fall eines GenericExternalQuery-Objekts, das Anfrage String muss vorher geparst werden.*/
/* Das erste Hochkomma wird entfernt!*/
get_query1(_id,_query):-
	prove_literal('A'(_id,query,_queryID)),
	retrieve_proposition('P'(_queryID,_queryID,_query1,_queryID)),
	'TermToCharList'(_query1,_query2),
	_query2=['"'|_query],!.





/* Hier werden das Anfagestring mit Parametern geparst. Aehnlich wie Antwortformatpattern mit zu erstezenden Inhalt 	*/
/* wird das Ganze funktionieren.												*/

parseQueryString(_queryPattern,_plist,_query):-
	'Convert2ParAndValueList'(_plist,_parlist,_parValuelist),
	recordValue(_parValuelist,_parlist),
	parse(_queryPattern,_query),
	!,
	remove_initialed_values(_parlist).

parseQueryString(_query_with_parameter,_plist,_query):-
	'Convert2ParAndValueList'(_plist,_parlist,_parValuelist),
	remove_initialed_values(_parlist),
	write('Parsing QueryString failed! '),nl,
	!,
	fail.



/*Hier wird z.B [substitute(Employee,p1),substitute(Mysql,p2)] in [Employee,Mysql] und [p1,p2] umgewandlt.*/
/*Wenn die Parameter ein String sind, werden die Hochkommata weggeloescht.				 */
/*Wenn man ein String in Pattern darstellen wollen, soll man selber in Pattern " hinschreiben!		 */

'Convert2ParAndValueList'([],[],[]):-!.
'Convert2ParAndValueList'([substitute(_pVatom1,_p)|_rplist],[_p|_rparlist],[_pValue|_rparValuelist]):-
	(id2name(_pVatom1,_pVatom);_pVatom=_pVatom1),
	(
	(quotedAtom(_pVatom),		/* String wird in geparsten Anfragestring ohne " " erscheinen!*/
	'TermToCharList'(_pVatom,_pValue1),
	delete_first_and_last(_pValue1,_pValue));
	'TermToCharList'(_pVatom,_pValue)
	),
	'Convert2ParAndValueList'(_rplist,_rparlist,_rparValuelist).

