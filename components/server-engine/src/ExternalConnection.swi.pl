%
% The ConceptBase.cc Copyright
%
% Copyright 1987-2020 The ConceptBase Team. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted
% provided that the following conditions are met:
%
%    1. Redistributions of source code must retain the above copyright notice, this list of
%       conditions and the following disclaimer.
%    2. Redistributions in binary form must reproduce the above copyright notice, this list of
%       conditions and the following disclaimer in the documentation and/or other materials
%       provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
% OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
% OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are those of the authors
% and should not be interpreted as representing official policies, either expressed or implied,
% of the ConceptBase Team.
%
%
% The ConceptBase Team is represented by
%
% Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
% Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
% Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
%
%
% This license is a FreeBSD-style copyright license.
% Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
%
%  ***********************************************************
%             W A R N I N G
%  Throughout this file, curly braces in comments were replaced
%  with square brackets because the Prolog preprocessor cannot
%  handle them otherwise.
%  ***********************************************************
%
% File:		ExternalConnection.pro
% Creation:	1998, Wang Hua(RWTH)
%
%
%
% The ExternalConnection module provides the methods that implement access to external sources.
% Using the example DB mainlibrary, the implementation of external access is illustrated.
%
% 1) To communicate with the external data source server, the external JEB server must be started first.
% 	go to .../JEBserver, then start with runjava host port 	( host and port indicate where the CB server runs, e.g. warhol 4001)
%
% 2) First the external source must be defined in CB. Here the URL of the source and of the driver must be given.
%
% Individual mainlibrary in ExternalDataSource with
%   attribute,url
%      eurl : "JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary"
%   attribute,driver
%      edriver : "i5.cb.jdbc.JEBJdbcDriver"
% end
%
% The driver attribute gives the URL of the driver to connect to; in this case the bridge between JEB and JDBC: JEBJdbcDriver.
% The driver is loaded during connection setup. Then it tries to connect to the data source. The URL of the data source is
% given in the url attribute. Often additional drivers are needed; their URLs are also given in url.
% Generally this can have a form like: "Prefix:URLs of further drivers:URL of the data source".
% E.g. JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary
%
%
%
% During storage of this source definition the metadata from this source is also loaded. The metadata corresponds to the
% schema definitions and is stored under ExternalObject. This information serves as entry points for the external data
% to be loaded later.
%
% e.g.:
% Individual itemInmainlibrary in ExternalObject with
%   attribute,field
%      "author_name": LONGVARCHAR;
%      "title" : LONGVARCHAR;
%      "subject" : LONGVARCHAR
%   attribute,key
%      itemkey : "SET(NULL)"
%   attribute,datasource
%      EmployeeDatasource : mainlibrary
% end
%
% NOTE:
% 	1) To avoid possible name conflicts, all imported names in CB are designated as "external name" + "In" + "name of the source".
% 	e.g. for the table item in mainlibrary it is named itemInmainlibrary in CB.
% 	2) Because external sources may have different syntax than ours, all attributes are quoted with " ",
% 	so almost anything can be represented in CB.
%
%
% 3) Next external views can be constructed. An external view corresponds to a direct query to the external source.
% It is specified by a source name and a query string.
%
% Individual Author in ExternalQuery with
%   attribute,datasource
%      Adatasource : mainlibrary
%   attribute,query
%      tquery : "select author_name, title from item"
% end
%
% Here a view is constructed that should return all books with names and authors. One notices that the corresponding attributes
% are missing! These are necessary, otherwise it would not be consistent to store the associated data (books with names and authors) under this
% view.
% This attribute extension is done automatically during view storage. The actual view in CB then looks as follows:
%
% Individual Author in ExternalQuery with
%   attribute,datasource
%      Adatasource : mainlibrary
%   attribute,query
%      tquery : "select author_name, title from item"
%   attriut, field
%      "author_name" : LONGVARCHAR;
%      "title" : LONGVARCHAR
% end
%
%
% To make view definition easier for users, generic external views are also provided.
% These views contain parameterized query strings in which similar queries can be combined.
% To use these, one only needs to give the name and the matching parameters.
%
%
% Individual BookofAuthor in GenericExternalQuery with
%   attribute,datasource
%      Adatasource : mainlibrary
%   attribute,query
%      tquery : "select title from item where author_name=\"[author]\""
%   attribute,parameter
%      author : String
% end
%
%
%
% NOTE:
% 	1) " and \ are special symbols and should be escaped with \.
% 	2) Parameters are usually declared as String. The quotes are however automatically removed when parsing the query string,
% 	e.g. "select ... where salary=[x]" and x is "1000.0", then after parsing: "select...where salary=1000.0".
% 	If quotes in the query string are still needed, they must be embedded in the query string oneself, as in the example above.
%
%
% 4) Furthermore one can specify how these external objects (ExternalObject, ExternalQuery) should be loaded and stored.
% Normally all external data is loaded into CB without integrity checking to reduce loading time. But if IC is necessary,
% one can re-enable IC by specifying the check attribute of ExternalQuery or ExternalObject.
% e.g.
% itemInmainlibrary with
%   check
% 	icheck: TRUE
% end
%
% Furthermore one notices that all external objects currently exist only virtually in CB, because all their instances still lie in
% external sources. However this data may also have been materialized in CB beforehand in order to achieve fast evaluation.
%
% itemInmainlibrary with
%   store
% 	istore: TRUE
% end
%
% Using the store attribute of ExternalQuery and ExternalObject, one can specify whether instances should be materialized or not.
% When store=True is set in CB, the associated instances are automatically imported from external sources and stored persistently in CB.
%
%
% 5) Queries:
% After all metadata is imported and all ExternalQuery/GenericExternalQuery are defined, we can
% query the external source main. A query can reference external objects (ExternalObject, ExternalQuery and GenericExternalQuery),
% whose instances are either already materialized in CB or exist only virtually in CB. During query evaluation, if external
% objects are affected and their instances are not yet imported into CB, they are then loaded from external sources and stored
% short-term in CB.
%
% Query with ExternalObject:
%
% Aut1 in QueryClass isA String with
%   attribute,computed_attribute
%      title : String;
%      subject: String
%   attribute,constraint
%      ac : $exists i/itemInmainlibrary A(i, "author_name", this) and A(i, "title", ~title) and A(i, "subject", ~subject)$
% end
%
% Query with ExternalQuery:
%
% Aut2 in QueryClass isA String with
%   attribute,computed_attribute
%      title : String
%   attribute,constraint
%      ac : $exists a/Author A(a, "author_name", this) and A(a, "title", ~title)$
% end
%
% Query with GenericExternalQuery:
%
% BookOfAut in QueryClass isA BookofAuthor["David Flanagan" / author] with
%   attribute,retrieved_attribute
%      "title" : VARCHAR
% end
%
%
%
%

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
  %  22-Jun-2004/M.Jeusfeld

:- dynamic 'ObjectLoadedflag'/1 .
:- dynamic 'ifcheck'/1 .
:- style_check(-singleton).
% **************************   LoadDataSourceMetaData    ************************************
%  Loading metadata for an external source is triggered by an ECA rule when TELLing an
%  ExternalDataSource object. LoadDataSourceMetaData collects all DB information for the
%  given DB name, builds an IPC message, and sends it to the Java side.
%  The metadata consists of DB schemas and type info, delivered as SML fragments.
%  If the response is empty (an error occurred), either the DB info was specified
%  incorrectly or the data-source server is not running properly. If the response is
%  not empty, the metadata is stored in CB.
% *******************************************************************************************

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
%  *******************************  DelDataSourceMetaData    ******************************************
%  Here we attempt, during UNTELL of a source definition in CB, to delete its metadata accordingly
%  are also deleted.

'DelDataSourceMetaData'(_ds):-
	name2id(_ds,_dsID),
	findall(_ObjID,prove_literal('A'(_ObjID,datasource,_dsID)),_ObjIDlist),
	write('Metadata will be untold...\n'),
	'UNTellExDaten'(_ObjIDlist).
% *********************************** LoadExQStructure ***********************************************
%  When defining an ExternalQuery/GenericExternalQuery object, the definition is extended with
%  corresponding attributes that describe the structure of the query string.
%  LoadExQStructure collects the data-source info; together with the query string it builds
%  an IPC message and sends it to the Java side. If the response is empty (an error occurred),
%  either the DB info or the query string was specified incorrectly. If not empty, the
%  attributes are stored accordingly.
%  Here we distinguish extension for ExternalQuery vs GenericExternalQuery.
%  When defining an ExternalQuery object, extension is triggered by an ECA rule.
%  When defining a GenericExternalQuery, attributes are not loaded yet because
%  the query is not complete. Only when specializations with specified parameters are stored
%  is attribute extension performed. This is not triggered by ECA rules but called directly
%  from FragmentToPropositions when storing the specialization.
%  Reason: these specializations appear in the IsA part of a query, and the query
%  need not be permanently stored in CB. A specialization may be stored permanently or
%  temporarily, and so may the extended attributes. An ECA rule cannot distinguish
%  permanent vs temporary storage.
%  Check whether attributes have already been extended.

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
	getGenExQueryinfo(_Obj,_plist,_infoCharlist),  % three-part, for GenericExternalQuery
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
%  ************************* tell_temp_ExObj ***************************************************
%  tell_temp_ExObj loads all instances of the given external objects from external sources.
%  External objects may be ExternalQuery, GenericExternalQuery, or ExternalObject.
%  The loaded instances are then stored temporarily in CB.
%  *********************************************************************************************

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
	assert('ObjectLoadedflag'(_ExObjName)),  % track whether an external object was already loaded in CB during query evaluation
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
%  ************************** remove_tmp_infos ********************************
%  For query evaluation, instances of external objects are
%  temporarily stored in CB, but after evaluation they must be removed.

remove_tmp_infos:-
	remove_temp_exports_imports,
  	remove_transaction_time,
  	remove_temporary_information,
        'WriteListOnTrace'(high,['   ... [1] temporary information retracted\n']),  % not very interesting message
	!.
% ******************************************* testIfShallLoad ****************************************************************
%  Here we check whether an object comes from external data sources, and whether it is already loaded.
%  *****************************************************************************************************************************

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
%  prove_literal(A(_id,field,_)) filters out GenericExternalQuery with uninitialized parameters.
%  When we write GEQ[...], both GEQ and GEQ[...] are found! But we do not want GEQ!
%  The difference: for GEQ[...] we have already extended attributes; GEQ has not.

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
%  ************************* wait_answer **************************
%  wait_answer waits for the message from the Java side (JEBserver)
%  until the corresponding message arrives.

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
	(serve_goal2( _err, _fd, _out, _ipo ),  % Error
	 extern_deallocate( _ipo ))),
	!.

get_answer( 0, _fd, _out, _parserOutput,[_answerString] ) :-
	'GetIpcMessageFromC'( _parserOutput, ipcmessage(_ToolId,_CBserverId,'TELL',[_answerString1])),
	strdup(_answerString,_answerString1).
%  ******************************* TellExDaten *********************************************************
%  TellExDaten stores the given data temporarily in CB. Note that no
%  semantic integrity check (IC) is performed here! Metadata loading happens during
%  definition of an external source; IC is performed afterward anyway.

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
%  *****************************  GetExInstance  ************************************************
%  GetExInstance loads instances of given objects that may be ExternalObject, ExternalQuery,
%  or GenericExternalQuery. GenericExternalQuery has the form: derive(_Obj,_plist).

'GetExInstance'(derive(_Obj,_plist),_answer):-  % GenericExternalQuery
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
	write('Load instance for '),write(derive(_Obj,_plist)),write(' ...\n\n'),
	make_ipcanswerstring( _answerstring, _receiver,loadExQInstance, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer).
'GetExInstance'(_Obj,_answer):-  % ExternalQuery or ExternalObject
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
	write('Load instance for '),write(_Obj),write(' ...\n\n'),
	make_ipcanswerstring( _answerstring, _receiver,_mode, _cstring, _answerlen ),
	memfree(_cstring),
	!,
	signal_wrapper('SIGPIPE',accept),
	ipc_write(_ok,_fd,_answerstring),
	memfree(_answerstring),
	!,
	wait_answer(_answer).
% ****************** External_Update *******************************************
%  External_Update performs an update operation. From the update instruction
%  and data-source info an IPC message is built and sent to the Java side.
%  The operation is executed there, and the corresponding reactions
%  are returned combined (Successful or Failed...).

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
%  ************************************************** getXXXinfo *******************************************************
%
%  Possible info patterns that can be sent to the Java side as IPC messages:
% 	a) Load metadata: [DSName][Url][driver][]
% 	b) Load object instances:
% 		b.1) For ExternalObject [ObjectName][Url][driver][SchemaName] — ObjectName is
%  		     the CB representation; SchemaName is the actual name in the external source,
% 		     e.g. testInmysql and test.
% 		b.2) For ExternalQuery [ObjectName][Url][Driver][QueryString]
% 		b.3) For GenericExternalQuery [ObjectID][Url][Driver][QueryString]
% 		     Note that the query string is parsed beforehand, i.e. parameters are substituted.
% 	c) Load ExternalQuery structure info, as in b.2)
% 	d) Update: [][Url][Driver][Update-Command]
%
% ********************************************************************************************************************
% for loadDataSourceMetaData

getDSinfo(_ds,_infostring):-
	name2id(_ds,_dsID),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	'TermToCharList'(_ds,_dschar),
	multiAppend([['{'],_dschar,['}','{'],_url,['}','{'],_driver,['}','{'],['}']],_infostring).
%  for GetExInstance

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
%  Load instances of ExternalObject. Instances for one object are imported from the external source.
%  Note that the name must be converted first, e.g. testInmysql --> test.

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
% for loadExStructure, getExObjinfo

getExQueryinfo(_Obj,_infostring):-
	name2id(_Obj,_ObjID),
	prove_literal('A'(_ObjID,datasource,_dsID)),
	get_query(_ObjID,_query),
	get_url(_dsID,_url),
	get_driver(_dsID,_driver),
	'TermToCharList'(_Obj,_Objchar),
	multiAppend([['{'],_Objchar,['}','{'],_url,['}','{'],_driver,['}','{'],_query,['}']],_infostring).
% for GenericExternalQuery
% The query string must be parsed beforehand.

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
% for Update

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
%  Case of a GenericExternalQuery object whose query string must be parsed first.
%  The first quote character is removed!

get_query1(_id,_query):-
	prove_literal('A'(_id,query,_queryID)),
	retrieve_proposition('P'(_queryID,_queryID,_query1,_queryID)),
	'TermToCharList'(_query1,_query2),
	_query2=['"'|_query],!.
%  Parse the query string with parameters. Similar to answer-format patterns with content to substitute.

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
%  E.g. [substitute(Employee,p1),substitute(Mysql,p2)] becomes [Employee,Mysql] and [p1,p2].
%  If a parameter is a String, the quotes are stripped.
%  To represent a string literal in the pattern, embed quotes in the pattern yourself!

'Convert2ParAndValueList'([],[],[]):-!.
'Convert2ParAndValueList'([substitute(_pVatom1,_p)|_rplist],[_p|_rparlist],[_pValue|_rparValuelist]):-
	(id2name(_pVatom1,_pVatom);_pVatom=_pVatom1),
	(
	(quotedAtom(_pVatom),  % String appears in parsed query string without quotes
	'TermToCharList'(_pVatom,_pValue1),
	delete_first_and_last(_pValue1,_pValue));
	'TermToCharList'(_pVatom,_pValue)
	),
	'Convert2ParAndValueList'(_rplist,_rparlist,_rparValuelist).
