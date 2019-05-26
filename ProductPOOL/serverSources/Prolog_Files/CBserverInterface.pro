{*
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
*}
{
*
* File:         CBserverInterface.pro
* Version:      11.5
* Creation:    22-Jun-1989, Manfred Jeusfeld (UPA)
* Last Change   : 5-Oct-2000, Manfred Jeusfeld (KUB Tilburg)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.CBserverInterface.pro
* Date retrieved : 97/07/09 (YY/MM/DD)
* ----------------------------------------------------------
*
*
* Exported predicates:
* --------------------
*
*
*   + queue_message/3
*   + active_sender/1
*   + handle_message/2
*	Answer message arg1 with arg2.
*       (former pred of module MessageHandler)
*   + thisToolClass/1
*
* 4-Jul-1991/MJf: fact transaction_mode unnecessary
* 5-Oct-2000/MJf: small bug removal in REPORT_CLIENTS which prevented all clients to be reported
*
}


#MODULE(CBserverInterface)
#EXPORT(Deleted/1)
#EXPORT(Inserted/1)
#EXPORT(active_sender/1)
#EXPORT(checkPermission/3)
#EXPORT(current_sender/1)
#EXPORT(enactModuleContext/2)
#EXPORT(handle_message/2)
#EXPORT(knownTool/5)
#EXPORT(queue_message/3)
#EXPORT(server_id/1)
#EXPORT(thisToolClass/1)
#EXPORT(thisToolId/1)
#EXPORT(writeNotifyMessage/2)
#EXPORT(do_set_module_context/6)
#EXPORT(active_user/1)
#EXPORT(switchModule/1)
#EXPORT(shutDownSlaveIfNoClients/1)
#EXPORT(currentClient/3)
#ENDMODDECL()

#IMPORT(TELL/2,TellAndAsk)
#IMPORT(UNTELL/2,TellAndAsk)
#IMPORT(ASK/6,TellAndAsk)
#IMPORT(HYPO_ASK/7,TellAndAsk)
#IMPORT(RETELL/3,TellAndAsk)
#IMPORT(createBuffer/1,GeneralUtilities)   {* createBuffer with default size *}
#IMPORT(createBuffer/2,GeneralUtilities)
#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(prependBuffer/2,ExternalCodeLoader)
#IMPORT(getPointerFromBuffer/2,ExternalCodeLoader)
#IMPORT(save_stringtoatom/2,GeneralUtilities)
#IMPORT(getStringFromBuffer/2,ExternalCodeLoader)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(ask_objproc/3,ObjectProcessor)
#IMPORT(load_model/1,ModelConfiguration)
#IMPORT(newIdentifier/1,validProposition)
#IMPORT(getoutofConceptBase/0,stopCBserver)
#IMPORT(user/1,prologToUnixSUN4)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(name2id_list/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(not_prove_literal/1,Literals)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(set_transaction_time/0,TransactionTime)
#IMPORT(get_transaction_time/1,TransactionTime)
#IMPORT(replaceCString/2,GeneralUtilities)
#IMPORT(handle_error_message_queue/1,ErrorMessages)
#IMPORT(current_fd/1,IpcChannel)
#IMPORT(client_db_files/3,IpcChannel)
#IMPORT(output_answer/3,IpcChannel)
#IMPORT(init_eca_state/0,ECAruleManager)
#IMPORT(handle_notification_request/4,ClientNotification)
#IMPORT(delete_all_notification_requests/1,ClientNotification)
#IMPORT(setModule/1,ModelConfiguration)
#IMPORT(getModule/1,ModelConfiguration)
#IMPORT(getModuleName/1,ModelConfiguration)
#IMPORT(transform_querycall/4,Literals)
#IMPORT(checkToEmptyCacheOnNewTransaction/0,Literals)
#IMPORT(checkToEmptyCacheOnSearchSpaceChange/0,Literals)
#IMPORT(checkToEnableCacheAfterUpdate/0,Literals)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(encodeAtom/2,ErrorMessages)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_stringtoatom/2,PrologCompatibility)
#IMPORT(pc_pointer/1,PrologCompatibility)
#IMPORT(pc_save_atom_to_term/2,PrologCompatibility)
#IMPORT(reset_counter/1,GeneralUtilities)
#IMPORT(set_counter/2,GeneralUtilities)
#IMPORT(checkUpdate/1,ObjectProcessor)
#IMPORT(reset_ECA_ExecutionQueue/0,ECAruleManager)
#IMPORT(create_if_builtin_object/3,FragmentToPropositions)
#IMPORT(removeCheckUpdateMode/1,TellAndAsk)
#IMPORT(eraseAnswerParameters/1,AnswerTransform)
#IMPORT(addAnswerParameters/2,AnswerTransform)
#IMPORT(timetoatom/2,GeneralUtilities)
#IMPORT(timetoatom/3,GeneralUtilities)
#IMPORT(makeSaveAtom/2,GeneralUtilities)
#IMPORT(resetStratificationError/0,Literals)
#IMPORT(setFlag/2,GeneralUtilities)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(resetFlag/1,GeneralUtilities)
#IMPORT(getModulePath/1,ModelConfiguration)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(save_bagof/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(select2id/2,GeneralUtilities)
#IMPORT(write_lcall/1,Literals)
#IMPORT(saveModuleTree/2,ConfigurationUtilities)
#IMPORT(saveSingleModule/2,ConfigurationUtilities)
#IMPORT(currentCheckUpdateMode/1,TellAndAsk)
#IMPORT(haltCBserver/0,IpcChannel)
#IMPORT(pc_gettime/1,PrologCompatibility)
#IMPORT(pc_atompartsall/3,PrologCompatibility)



#DYNAMIC(ipcqueue/3)
#DYNAMIC(active_sender/1)

    {used in module ErrorMessages}

#DYNAMIC(Inserted/1)
#DYNAMIC(Deleted/1)
	 {used in BDMEvaluation}

#DYNAMIC(knownTool/5)
#DYNAMIC(current_sender/1)

#DYNAMIC(client_lastactivity/2)



#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


getToolname(_sender,_toolname) :-
   knownTool(_sender,_toolclass,_user,_,_),
   usernameWithouthost(_user,_shortname),
   pc_atomconcat([_toolclass,'-',_shortname],_toolname),
   !.
getToolname(_sender,_sender).

{ ***************** h a n d l e _ m e s s a g e **************** }
{                                                                }
{ handle_message(_m,_a)                                          }
{   _m: any                                                      }
{   _a: any                                                      }
{                                                                }
{ The message _m is answered with _a.                            }
{                                                 8-Mar-1990/MJf }
{ ************************************************************** }

{*** case 1: the message can be answered by local tools }

handle_message( ipcmessage(_sender,_receiver,_method,_args),
                ipcanswer(_CBs,_completion,_return) ) :-
	thisToolId(_CBs),
	(_method = NEXT_MESSAGE;
	 (replaceCString(_args,_newargs),
          getToolname(_sender,_toolname),
	  WriteTrace(minimal,_toolname,['CALL ', _method, ' ON ',_newargs])
	)),
	pc_update(current_sender(_sender)),
        setBasicCallContext(_sender),
        setLastActivity(_sender),  {* ticket #378: kill inactive clients of public CBserver *}
	!,
	ipcinterface(_receiver,_sender,_method,_args,_completion,_return),
	(_method = NEXT_MESSAGE;
         displayAnswerOnTrace(_CBs,_return,_completion)
        ),
	!.


{*** case 2: the message is put into a queue if possible }

handle_message( _message, ipcanswer(_CBs,_completion,_return) ) :-
  thisToolId(_CBs),
  queue_message(_message,_completion,_return),  {* only queued if receiver of _message is not _CBs *}
  WriteTrace(low,MessageHandler, [_message, ' is queued by ', _CBs]),
  !.

{*** case 3: message cannot be handled }

handle_message( ipcmessage(_sender,_receiver,_method,_args),
                ipcanswer(_CBs,error,no) ) :-
  thisToolId(_CBs),
  WriteTrace(low,MessageHandler,
                 [_CBs, ' responds to ',_sender, ': ',no,' (completion=',error,')']),
  !.


{* This makes the answer look nicer, esp. when [] is the result of a query *}
{* 18-Sep-2002/M.Jeusfeld                                                  *}

displayAnswerOnTrace(_toolid,_answer,_completion) :-
   pc_pointer(_answer),
  WriteTrace(low,_toolid,['RESPONSE IS ',stringBuffer(_answer)]),
  WriteTrace(minimal,_toolid,['COMPLETION IS ',_completion]),
  !.

displayAnswerOnTrace(_toolid,_answer,_completion) :-
  makeAnswerAtom(_answer,_atom),
  WriteTrace(low,_toolid,['RESPONSE IS ',_atom]),
  WriteTrace(minimal,_toolid,['COMPLETION IS ',_completion]),
  !.


makeAnswerAtom(_answer,_atom) :-
  _answer =.. [char_list|[_list]],
  produceAtom(_list,_atom),
  !.

makeAnswerAtom(_x,_x).

produceAtom([],'nil') :-  !.  {* make sure that empty list is really displayed *}

produceAtom(_list,_atom) :-
  pc_atomconcat(_list,_atom).





{ ****************** i p c i n t e r f a c e ******************* }
{                                                                }
{ ipcinterface(_rec,_sen,_m,_args,_c,_r)                         }
{   _rec: any: ground                                            }
{   _sen: ground                                                 }
{   _m: atom                                                     }
{   _args: list                                                  }
{   _c: free: atom                                               }
{   _r: free: ground                                             }
{                                                                }
{ The parameter _rec is the receiving tool instance, _sen is the }
{ sending tool, _m is the requested method and _args contains    }
{ the arguments for _m. The output consists of the completion _c }
{ (giving information about successful computations) and the     }
{ return value _r.                                               }
{ Note that each tool participating in the IPC channel has to    }
{ give such an interface.                                        }
{                                                                }
{ ************************************************************** }

ipcinterface(_r,_s,TELL,[_frames , _module ],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_),
   pc_pointer(_frames),
  BEGIN_TRANSACTION(_s,_module,_user,TELL),
      TELL(_frames,_c1) ,
      checkUpdate(_err),
      computeCompletionReturn(_c1,_err,_c,_ret),
      handle_error_message_queue(_c),
    END_TRANSACTION,
  !.

ipcinterface(_r,_s,TELL,[_frames ],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
   pc_pointer(_frames),
  BEGIN_TRANSACTION(_s,_module,_user,TELL),
      TELL(_frames,_c1) ,
      checkUpdate(_err),
      computeCompletionReturn(_c1,_err,_c,_ret),
      handle_error_message_queue(_c),
    END_TRANSACTION,
  !.


ipcinterface(_r,_s,UNTELL,[_frames,_module],_c,_ret) :-
   thisToolId(_r),
   knownTool(_s,_,_user,_,_),
   pc_pointer(_frames),
   BEGIN_TRANSACTION(_s,_module,_user,UNTELL),
   UNTELL(_frames,_c1) ,
   checkUpdate(_err),
   computeCompletionReturn(_c1,_err,_c,_ret),
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.


ipcinterface(_r,_s,UNTELL,[_frames],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
  pc_pointer(_frames),
  BEGIN_TRANSACTION(_s,_module,_user,UNTELL),
  UNTELL(_frames,_c1) ,
  checkUpdate(_err),
  computeCompletionReturn(_c1,_err,_c,_ret),
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.

ipcinterface(_r,_s,ASK,[_queryformat,_query,_ansrep,_rbtime,_module],_c,_ret) :-
  pc_pointer(_query),
  thisToolId(_r),
  knownTool(_s,_,_user,_,_),
  BEGIN_TRANSACTION(_s,_module,_user,ASK),
  memoRollbacktime(_rbtime),
  createBuffer(_ret,large),
  !,
  ASK(_queryformat,_query,_ansrep,_rbtime,_c,_ret),
  checkUpdate(_err),   {* an ASK may have incurred some updates, see ticket #102 *}
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.


ipcinterface(_r,_s,ASK,[_queryformat,_query,_ansrep,_rbtime],_c,_ret) :-
  pc_pointer(_query),
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
  BEGIN_TRANSACTION(_s,_module,_user,ASK),
  memoRollbacktime(_rbtime),
  createBuffer(_ret,large),  {* this buffer is involved in ticket #263; buffer size 1000 leads to crash *}
  !,                         {* in the corresponding disposeBuffer of IpcChannel.pro                    *}
  ASK(_queryformat,_query,_ansrep,_rbtime,_c,_ret),
  checkUpdate(_err),   {* an ASK may have incurred some updates, see ticket #102 *}
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.

ipcinterface(_r,_s,HYPO_ASK,[_objects,_queryformat,_query,_ansrep,_rbtime,_module],_c,_ret) :-
  pc_pointer(_query),
  thisToolId(_r),
  knownTool(_s,_,_user,_,_),
  BEGIN_TRANSACTION(_s,_module,_user,HYPO_ASK),
  memoRollbacktime(_rbtime),
  createBuffer(_ret,large),
  !,
  HYPO_ASK(_objects,_queryformat,_query,_ansrep,_rbtime,_c,_ret),
  handle_error_message_queue(_c),

  END_TRANSACTION,
  !.

ipcinterface(_r,_s,HYPO_ASK,[_objects,_queryformat,_query,_ansrep,_rbtime],_c,_ret) :-
  pc_pointer(_query),
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
  BEGIN_TRANSACTION(_s,_module,_user,HYPO_ASK),
  memoRollbacktime(_rbtime),
  createBuffer(_ret,large),
  !,
  HYPO_ASK(_objects,_queryformat,_query,_ansrep,_rbtime,_c,_ret),
  handle_error_message_queue(_c),

  END_TRANSACTION,
  !.

ipcinterface(_r,_s,TELL_MODEL,[_modelnames,_module],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_),
  BEGIN_TRANSACTION(_s,_module,_user,TELL_MODEL),
  load_model(_modelnames),
  checkUpdate(_err),
  computeCompletionReturn(_err,_err,_c,_ret),
  handle_error_message_queue(_c),

  END_TRANSACTION,
  !.

ipcinterface(_r,_s,TELL_MODEL,[_modelnames],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
  BEGIN_TRANSACTION(_s,_module,_user,TELL_MODEL),
  load_model(_modelnames),
  checkUpdate(_err),
  computeCompletionReturn(_err,_err,_c,_ret),
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.

ipcinterface(_r,_s,TELL_MODEL,_,error,no) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
     handle_error_message_queue(error),
  !.


ipcinterface(_r,_s,RETELL,[[_untell,_tell],_module],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_),
  BEGIN_TRANSACTION(_s,_module,_user,RETELL),
  RETELL(_untell,_tell,_c1),
  checkUpdate(_err),
  computeCompletionReturn(_c1,_err,_c,_ret),
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.


ipcinterface(_r,_s,RETELL,[[_untell,_tell]],_c,_ret) :-
  thisToolId(_r),
  knownTool(_s,_,_user,_,_module),
  BEGIN_TRANSACTION(_s,_module,_user,RETELL),
  RETELL(_untell,_tell,_c1),
  checkUpdate(_err),
  computeCompletionReturn(_c1,_err,_c,_ret),
  handle_error_message_queue(_c),
  END_TRANSACTION,
  !.


{13-Jul-1994/MJf:}
ipcinterface(_r,_s,LPI_CALL,[_what],ok,_return) :-
  thisToolId(_r),
  knownTool(_s,_name,_u1,_,_old_module),		{ get old default module }
  BEGIN_TRANSACTION(_s,_old_module,_u1,LPI_CALL),  { Prolog calls do not have a sensible module context }
 	_what = [_op|_args],
    	_goal =.. [_op,_return|_args],
	knownTool(_r,_,_u2,_,_),
        permitted_LPI_CALL(_u1,_u2,_args),
	pc_has_a_definition(_goal),
#IF(SWI)
    catch(_goal,_ex,(write('**** Exception in LPI_CALL:'),write(_ex),nl,fail)),
#ELSE()
 	call(_goal),
#ENDIF(SWI)
  END_TRANSACTION,
  !.


ipcinterface(_r,_s,LPI_CALL,_,error,no) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.

{* 29-Jan-2004/M.Jeusfeld: allow clients to check their current module context *}
ipcinterface(_r,_s,GET_MODULE_CONTEXT,[],ok,_module) :-
  thisToolId(_r),
  knownTool(_s,_toolclass,_username,_fd,_module),
  {* we memorize the tool that issued GET_MODULE_CONTEXT; see ticket #153 *}
  setFlag(lastToolGetModuleContext,knownTool(_s,_toolclass,_username,_fd,_module)),
  !.

ipcinterface(_r,_s,GET_MODULE_CONTEXT,_,error,no) :-
 !.

{* 23-Jan-2014/M.Jeusfeld: allow clients to check their current module path *}
ipcinterface(_r,_s,GET_MODULE_PATH,[],ok,_mpathatom) :-
  thisToolId(_r),
  knownTool(_s,_toolclass,_user,_fd,_module),
  BEGIN_TRANSACTION(_s,_module,_user,GET_MODULE_PATH),
  getModulePath(_mpath),        {* fetch the path to the current module *}
  pc_atom_to_term(_mpathatom,_mpath),   {* convert to an atom (avoiding quotes) *}
  END_TRANSACTION,
  !.

ipcinterface(_r,_s,GET_MODULE_PATH,_,error,no) :-
 !.


ipcinterface(_r,_s,SET_MODULE_CONTEXT,[_newmodule],ok,_newmodule1) :-
  thisToolId(_r),
  knownTool(_s,_toolclass,_user,_fd,_old_module),
  evalModuleExpression(_toolclass,_user,_newmodule,_newmodule1),
  BEGIN_TRANSACTION(_s,_old_module,_user,[SET_MODULE_CONTEXT,_newmodule1]),
  do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule1,_completion),
  END_TRANSACTION,
  handle_error_message_queue(_completion),
  _completion=ok,
  !.

ipcinterface(_r,_s,SET_MODULE_CONTEXT,_,error,no) :-
 !.



{* ENROLL_ME calls of 'PingClient' are treated like a check whether the CBserver is alive *}
ipcinterface(_,_,ENROLL_ME,['PingClient'|[_raw_username_client|_]],ok,yes) :-
  get_cb_feature(multiuser,disabled),   {* we have disabled the multi-user ability of CB *}
  telosUsername(_raw_username_client,_username_client),
  thisToolId(_r),                   {* this is this CBserver instance *}
  knownTool(_r,CBserver,_username_server,_,_),     {* to fetch the username who has started the CBserver *}
  get_cb_feature(adminUser,_admin),
  (sameUser(_username_client,_username_server);  {* the new client was started by this user *}
   sameUser(_username_client,_admin)),   {* or the user is also the admin user *}
  WriteTrace(low,CBserverInterface,['Ping successful: ',_raw_username_client]),
  !.

ipcinterface(_,_,ENROLL_ME,['PingClient'|[_raw_username_client|_]],ok,yes) :-
  get_cb_feature(multiuser,enabled),   {* we have enabled the multi-user ability of CB *}
  WriteTrace(low,CBserverInterface,['Ping successful: ',_raw_username_client]),
  !.

ipcinterface(_,_,ENROLL_ME,['PingClient'|[_raw_username_client|_]],error,no) :-
  get_cb_feature(multiuser,disabled),   {* we have disabled the multi-user ability of CB *}
  WriteTrace(low,CBserverInterface,['Ping unsuccessful: ',_raw_username_client]),
  !.


{* 19-Nov-2003/M.Jeusfeld: disallow clients started by another user when *}
{* the multi-user feature has been disabled                              *}
ipcinterface(_,_,ENROLL_ME,[_toolclass|[_raw_username_client|_]],error,no) :-
  _toolclass \== CBserver,          {* some client (not CBserver) wants to connect *}
  get_cb_feature(multiuser,disabled),   {* we have disabled the multi-user ability of CB *}
  telosUsername(_raw_username_client,_username_client),
  thisToolId(_r),                   {* this is this CBserver instance *}
  knownTool(_r,CBserver,_username_server,_,_),     {* to fetch the username who has started the CBserver *}
  \+ sameUser(_username_client,_username_server),  {* the new client was started by another user *}
  get_cb_feature(adminUser,_admin),
  \+ sameUser(_username_client,_admin),   {* the user is also not the admin user *}
  WriteTrace(low,CBserverInterface,['ENROLL_ME rejected. Multiuser feature is disabled for this ConceptBase server!']),
  !.


ipcinterface(_,_,ENROLL_ME,[_toolclass,_raw_username,_default_module],ok,_toolid) :-
  newIdentifier(_id),
  pc_atomconcat([_toolclass,'_',_id],_toolid),
  telosUsername(_raw_username,_username),
  usernameWithouthost(_username,_u),
  set_active_user(_u),
  (current_fd(_fd);_fd=0),
  assert(knownTool(_toolid,_toolclass,_username,_fd,_default_module)),
  !.

ipcinterface(_,_,ENROLL_ME,[_toolclass,_raw_username],ok,_toolid) :-
  newIdentifier(_id),
  pc_atomconcat([_toolclass,'_',_id],_toolid),
  telosUsername(_raw_username,_username),
  usernameWithouthost(_username,_u),
  set_active_user(_u),
  resetCountersAndState,   {* findHomeModule may actually TELL something, so better reset all counters *}
  findHomeModule(_toolclass,_username,_homemodule),  {* 28-Jan-2004/M.Jeusfeld *}
  checkUpdate(_err),
  _err == noerror,
  checkToEnableCacheAfterUpdate,
  (current_fd(_fd);_fd=0),
  assert(knownTool(_toolid,_toolclass,_username,_fd,_homemodule)),  {* correct tool info *}
  WriteTrace('high', CBserverInterface, ['Client ', _toolid, ' of user ', _username, ' gets home module ', _homemodule]),
  remove_active_user,
  !.

ipcinterface(_,_,ENROLL_ME,[_toolclass,_username],error,no) :-
  remove_active_user,
  !.

ipcinterface(_r,_s,CANCEL_ME,[],ok,yes) :-
  thisToolId(_r),
  knownTool(_s,_,_u,_,_mod),
  trySaveModuleTree(_r,_s,_mod),
  retract(knownTool(_s,_,_,_,_)),
  delete_all_notification_requests(_s),
  shutDownSlaveIfNoClients(_u),  {* a 'slave' CBserver is shutdown by the last local client *}
  !.

ipcinterface(_r,_s,CANCEL_ME,[],error,no) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.

ipcinterface(_r,_s,NEXT_MESSAGE,[],ok,_message) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  retract(ipcqueue(_qid,_s,_message)),
  !.

ipcinterface(_r,_s,NEXT_MESSAGE,[],ok,empty_queue) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.


ipcinterface(_r,_s,NEXT_MESSAGE,[_method],
                         ok,ipcmessage(_encSender,_encReceiver,_method,_args)) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  retract(ipcqueue(_qid,_s,ipcmessage(_sender,_s,_method,_args))),
  encodeAtom(_sender,_encSender),
  encodeAtom(_s,_encReceiver),
{  _encSender = _sender,
  _encReceiver = _s,}
  !.

ipcinterface(_r,_s,NEXT_MESSAGE,[_method],ok,empty_queue) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.

ipcinterface(_r,_s,STOP_SERVER,_args,ok,yes) :-
  ( _args = [] ; _args = [_] ),
  thisToolId(_r),
  knownTool(_s,_,_u1,_,_module),
  knownTool(_r,_,_u2,_,_),
  authorizedFor('STOP_SERVER',_u1,_u2,_s),
  setFlag(requestDownCBserver,regular),  {* will be detected in IpcChannel.pro *}
  getoutofConceptBase,
  !.

ipcinterface(_r,_s,STOP_SERVER,_args,error,no) :-
  ( _args = [] ; _args = [_] ),
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.

ipcinterface(_r,_s,REPORT_CLIENTS,[],ok,_clients) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  bagof(client(_id,_cl,_u),isknownTool(_id,_cl,_u),_clients),
  !.

ipcinterface(_r,_s,REPORT_CLIENTS,[],ok,[]) :-
  thisToolId(_r),
  knownTool(_s,_,_,_,_),
  !.


ipcinterface(_r,_s,NOTIFICATION_REQUEST,[_arg,_tool,_module],ok,_response) :-
	thisToolId(_r),
	knownTool(_tool,_,_,_,_),
	handle_notification_request(_s,_tool,[_arg],_response),
	!.

ipcinterface(_r,_s,NOTIFICATION_REQUEST,[_arg,_tool],ok,_response) :-
	thisToolId(_r),
	knownTool(_tool,_,_,_,_),
	handle_notification_request(_s,_tool,[_arg],_response),
	!.

{* _operation is known but execution was not permitted *}
ipcinterface(_r,_s,_operation,_args,error,no) :-
	name2id(_operation,_op),
	name2id(CB_Operation,_cbop),
	prove_literal(In(_op,_cbop)),
	handle_error_message_queue(error),
	!.


#IF(SWI)
:- module_transparent 'PROLOG_CALL'/2 .
#ENDIF(SWI)
#GLOBAL(PROLOG_CALL/2)

PROLOG_CALL(yes,update(MSP(_newmodule)))	:-
	!,
	current_sender(_s),
	knownTool(_s,_toolclass,_user,_fd,_old_module),
	do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule),
	!.


PROLOG_CALL(_ret,_goal) :-
	call(_goal),
	pc_atom_to_term(_ret,_goal).

PROLOG_CALL(no,_goal).



{* case 1: receiver=sender --> the CBserver unregisters from itself = shutdown of CBserver *}
trySaveModuleTree(_s,_s,_mod) :-
  saveModuleTree(_compl,System), {* save module tree starting from root module *}
  !.

{* case 2: a client has unregistered *}
trySaveModuleTree(_r,_s,_mod) :-
  _r \= _s,
  saveModuleTree(_compl,_mod),   {* save the tree starting from the client's home module *}
  !.

{* catchall *}
trySaveModuleTree(_r,_s,_mod).


{* auxiliary function for REPORT_CLIENTS: *}

isknownTool(_id,_cl,_u) :-  knownTool(_id,_cl,_u,_,_).
   {* bagof/setof do not like unquantified valiables in the query expression *}


{ ********************* q u e u e _ m e s s a g e *************************** }
{                                                                             }
{	queue_message ( _ipcmessage , _completion, _return )                  }
{			_ipcmessage : ground                                  }
{			_completion : free                                    }
{			_return : free                                        }
{                                                                             }
{	message _ipcmessage (ipc format) is stored in the queue of the        }
{	specified receiver.                                                   }
{                                                                             }
{ 9-Mar-1990/MJf: Assign a unique identifier to each entry in the queue. This }
{ identifier is now the return value. Previously, an atom 'message queued'    }
{ was returned.                                                               }
{                                                                             }
{ *************************************************************************** }

queue_message(ipcmessage(_sender,_receiver,_method,_args),
               ok,_newQid) :-
  ground(_receiver),
  knownTool(_receiver,_,_,_,_),
  not(thisToolId(_receiver)),
  knownTool(_sender,_,_,_,_),
  getFlag(QueuedMessage_counter,_qid),
  _newQid is _qid+1,
  setFlag(QueuedMessage_counter,_newQid),
  assert(ipcqueue(_newQid,_receiver,
                  ipcmessage(_sender,_receiver,_method,_args))),
  !.



active_sender(NEW_CLIENT).


{======================================}
{* Method for client notification     *}
{* Used for view maintenance          *}
{======================================}
writeNotifyMessage([],_).

writeNotifyMessage([_toolid|_rest],_msg) :-
	knownTool(_toolid,_,_,_fd,_),
	client_db_files(_fd,_in,_out),
	WriteTrace(veryhigh,CBserverInterface,['Writing notification message for tool ',_toolid,':\n',_msg]),
	output_answer(_fd,_out,ipcanswer(_toolid,notification,_msg)),
	writeNotifyMessage(_rest,_msg).


{* "Same" users have the same name. Maybe they are at different hosts. }
{* Remember that user names are represented as "user@hostname" in CB.  }

sameUser(_u1,_u2) :-
  usernameWithouthost(_u1,_u1a),
  usernameWithouthost(_u2,_u2a),
  convertToCapital(_u1a,_userc),
  convertToCapital(_u2a,_userc),
  !.

sameUser(_u,_u) :- !.

convertToCapital(_n,_nc) :-
  name(_n,_ln),
  do_convertToCapital(_ln,_lnc),
  name(_nc,_lnc).

do_convertToCapital([],[]) :- !.

do_convertToCapital([_a|_r],[_ac|_rc]) :-
  _a >= 97,  {* ASCII for 'a' *}
  _a =< 122, {* ASCII for 'z' *}
  _ac is _a - 32,  {* capital character for _a *}
  !,
  do_convertToCapital(_r,_rc).

do_convertToCapital([_a|_r],[_a|_rc]) :-
  do_convertToCapital(_r,_rc).


{* 28-Jan-2004/M.Jeusfeld: determine the home module of a user trying *}
{* to ENROLL_ME to the CBserver. The home module can be specified for *}
{* instances of CB_User in the database.                              *}

{* 5-Feb-2004/M.Jeusfeld: enable the feature of AutoHomeModule        *}
{* AutoHomeModules are modules wheres users automatically get         *}
{* a submodule named '_username' as their context. This               *}
{* is useful for multi-user applications of ConceptBase where users   *}
{* work automagically in their private context rather than            *}
{* interfering with each other.                                       *}
{* Some users can be allowed to have an auto home module as their     *}
{* home module, e.g. to add objects visible to all other users. Such  *}
{* users are mentioned as 'exception' in the auto home module.        *}


{* new case: if a CB_Graph_Editor enrolls, then it shall get the module *}
{* context of the JavaWorkBench from which it was startet. That context *}
{* is stored in the value lastToolGetModuleContext. It is set by the    *}
{* operation GET_MODULE_CONTEXT that the tool calls just                *}
{* before is forks the CB_GraphEditor application. See ticket #153.     *}

findHomeModule('CB_GraphEditor',_username,_homemodule) :-
  getLastToolModuleContext(_username,_homemodule,_s),
  WriteTrace(high,CBserverInterface,['CB_GraphEditor inherits module context ',_homemodule,
                                     ' from ',_s]),
  !.

findHomeModule(_toolclass,_fullusername,_homemodule) :-
 _toolclass \= CBserver,   {* CBserver always runs in System module *}
  usernameWithouthost(_fullusername,_username),
  makeSaveAtom(_username,_qusername),  {* see ticket #117 *}
  getUserId(_qusername,_userid),
  initialHomeModule(_userid,_modid),  {* may be overridden by AutoHome feature *}
  name2id(AutoHomeModule,_ahmid),
  determineHomeModule(_qusername,_userid,_modid,_ahmid,_homemodule),
  !.

{* if that fails, fall back to 'oHome' module if it exists*}
findHomeModule(_,_,oHome) :-
  name2id(oHome,_oh),  
  WriteTrace(high,CBserverInterface, ['fallback to oHome as home module']),
  !.

{* if that fails, we fall back to the root module 'System' *}
findHomeModule(_,_,'System') :-
  WriteTrace(high,CBserverInterface, ['fallback to System as home module']),
  !.


{* The graph editor can be called by itself (show in new window) or from the Java *}
{* workbench.                                                                     *}
getLastToolModuleContext(_username,_homemodule,_s) :-
  getFlag(lastToolGetModuleContext,knownTool(_s,'CB_GraphEditor',_username,_fd,_homemodule)),
  resetFlag(lastToolGetModuleContext),
  !.

getLastToolModuleContext(_username,_homemodule,_s) :-
  getFlag(lastToolGetModuleContext,knownTool(_s,'JavaWorkbench',_username,_fd,_homemodule)),
  resetFlag(lastToolGetModuleContext),
  !.





{* user is known to have a home module *}
initialHomeModule(_userid,_modid) :-
   prove_literal(A(_userid,CB_User,homeModule,_modid)),
   !.

{* user has no home module, so take 'oHome' as initial guess *}
initialHomeModule(_userid,_modid) :-
{*   write('no defined home module'),nl, *}
   name2id(oHome,_modid).

initialHomeModule(_userid,_modid) :-
{*   write('no defined home module'),nl, *}
   name2id('System',_modid).

{* the user is known in the database *}
getUserId(_username,_userid) :-
  name2id(_username,_userid),
  atom(_userid),
  !.

{* the user is not known in the database *}
getUserId(_username,_userid) :-
  name2id(oHome,_oh),  {* only tell the new user if oHome is defined *}
  pc_atomconcat(_username,' in CB_User end',_toTell),
  pc_stringtoatom(_frame,_toTell),  {* make a string pointer for the frame to be told *}
  enactModuleContext(oHome), {* do TELL in context of oHome module *}
  set_transaction_time,
  TELL(_frame,_completion),  {* TELL the new submodule *}
  checkUpdate(_err),
  _completion == 'noerror',
  _err == 'noerror',
  name2id(_username,_userid),
  WriteTrace(veryhigh,CBserverInterface,['New user created: ',_username]),
  !.

{* case 1: home module is of type AutoHomeModule but user _userid is mentioned *}
{* as 'exception' to the auto-home-mechanism.                                  *}
{* ==> take this module as the home module                                     *}
determineHomeModule(_username,_userid,_modid,_ahmid,_homemodule) :-
  prove_literal(In(_modid,_ahmid)),
  prove_literal(A(_modid,AutoHomeModule,exception,_userid)),
  id2name(_modid,_homemodule),
  !.

{* case 2: home module is of type AutoHomeModule and user _userid is'nt mentioned *}
{* as 'exception' to the auto-home-mechanism.                                     *}
{* ==> we need to assign a sub module of _modid for this user                     *}
determineHomeModule(_username,_userid,_modid,_ahmid,_newsubmodule) :-
  prove_literal(In(_modid,_ahmid)),
  not_prove_literal(A(_modid,AutoHomeModule,exception,_userid)),
  id2name(_modid,_module),
  createOrTakeSubModule(_username,_modid,_module,_newsubmodule),
  !.

{* case 3: home module is not of type AutoHomeModule  *}
{* ==> take this as the home module                   *}
determineHomeModule(_username,_userid,_modid,_ahmid,_homemodule) :-
  id2name(_modid,_homemodule),
  !.


{* a) check wether the _newsubmodule already exists *}
createOrTakeSubModule(_username,_modid,_module,_newsubmodule) :-
  pc_atomconcat('M_',_username,_newsubmodule),
  name2id(_newsubmodule,_),                    {* the submodule already exists: take it *}
  !.

{* b) the _newsubmodule has to be created *}
createOrTakeSubModule(_username,_modid,_module,_newsubmodule) :-
  pc_atomconcat('M_',_username,_newsubmodule),
  pc_atomconcat(_newsubmodule,' in Module end',_toTell),
  pc_stringtoatom(_frame,_toTell),  {* make a string pointer for the frame to be told *}
  enactModuleContext(_module), {* do TELL in context of _modid *}
  set_transaction_time,
  TELL(_frame,_completion),  {* TELL the new submodule *}
  _completion == 'noerror',
  WriteTrace(veryhigh,CBserverInterface,['New submodule created: ',_newsubmodule]),
  !.

{* c) when creation fails: take the original home module  *}
{* (should never happen, though)                          *}
createOrTakeSubModule(_username,_modid,_module,_module) :-
  WriteTrace(low,CBserverInterface,['Auto home failed for ',_module]),
  !.



{* ticket #379: make sure that the user name has no special chars that *}
{* are not allowed as object names.                                    *}
telosUsername(_raw_username,_username) :-
  makeSaveAtom(_raw_username,_username),
  !.
telosUsername(_username,_username).
   



usernameWithouthost(_fullusername,_save_username) :-
  pc_atomtolist(_fullusername,_inputlist),
  scanTillHost(_inputlist,[],_outputlist),
  pc_atomtolist(_username,_outputlist),
  makeSaveAtom(_username,_save_username),
  !.

usernameWithouthost(_u,_u).

scanTillHost(['@'|_rest],_current,_current) :- !.

scanTillHost([_char|_rest],_current,_outputlist) :-
  append(_current,[_char],_newcurrent),
  scanTillHost(_rest,_newcurrent,_outputlist).


{* 6-arg version of do_set_module_context shall be kep intact. *}
{* It fails when the module context cannot be set.             *}
{* The new 7-arg version includes the 7th argument for the     *}
{* completion of the operation. It always succeeds.            *}

do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule) :-
  do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule,_completion),
  _completion=ok.

do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule,error) :-
  no_read_permission(_user,_old_module,_newmodule),
  report_error( MOD3, CBserverInterface, [_user,_newmodule]), 
  !.




do_set_module_context(_s,_toolclass,_user,_fd,_old_module,_newmodule,ok) :-
  retract(knownTool(_s,_toolclass,_user,_fd,_old_module)),
  assert(knownTool(_s,_toolclass,_user,_fd,_newmodule)),
  WriteTrace(veryhigh,CBserverInterface,['Module context for ',_s,' set to: >',_newmodule ,'<']),
  !.



{* realize behavior like "cd .."  and "cd $Home" for SET_MODULE *}

evalModuleExpression(_toolclass,_username,'..',_new_module) :-
  getModulePath(_mpath),        {* fetch the path to the current module *}
  getSuperModule(_mpath,_new_module),
  !.

evalModuleExpression(_toolclass,_username,'$Home',_homemodule) :-
  findHomeModule(_toolclass,_username,_homemodule),
  !.

{* if the above clause fails *}
evalModuleExpression(_toolclass,_username,'$Home','oHome') :-
  !.

evalModuleExpression(_toolclass,_username,_new_module,_new_module) :-
  !.

  
getSuperModule((_prefix-_last),_new_module) :-
    pc_save_atom_to_term(_new_module,_prefix),
    !.
getSuperModule((_prefix/_last),_new_module) :-
    pc_save_atom_to_term(_new_module,_prefix),
    !.


no_read_permission(_fullusername,_oldmodule,_newmodule) :-
  enactModuleContext(_newmodule,_compl),  
  _compl = error, {* newmodule does not exist *}
  WriteTrace(veryhigh,CBserverInterface,['*** ',_newmodule, ' does not exist']),
  !.

no_read_permission(_fullusername,_oldmodule,_newmodule) :-
  get_cb_feature(securityLevel,_lev),
  _lev == '2',            {* full access control is enabled *}
  enactModuleContext(_newmodule),  {* owner of _newmodule can set rights management locally *}
  getPermissionTest(_fullusername,ASK,_newmodule,_query_lit),
  not_prove_literal(_query_lit),
  WriteTrace(veryhigh,CBserverInterface,['*** User ',_fullusername, ' has no read permission for ',_newmodule]),
  !.



permitted_LPI_CALL(_u1,_u2,_args) :-
  sameUser(_u1,_u2),
  !.

permitted_LPI_CALL(_u1,_u2,_args) :-
  _args  =  [pc_update(MSP(_module))],
  !.


{ ******************* B E G I N _ T R A N S A C T I O N ******************* }
{                                                           24-Jan-1990/MJf }
{ BEGIN_TRANSACTION                                                         }
{   _s: atom                                                                }
{   _mode: atom                                                             }
{   _user: atom                                                             }
{   _op: atom                                                               }
{                                                                           }
{ This procedure marks the beginning of a transaction. The _mode controls   }
{ the visibility of temporary information, _s is the name of the sender tool}
{ which has triggered the transaction. See also modules PropositionBase and }
{ LiteralBase.                                                              }
{ Sometime in the future we can extend this procedure to allow parallel     }
{ transactions and stuff like that.                                         }
{ 24-Feb-2004/M.Jeusfeld: additional parameters for _user and _op to check  }
{ whether _user is allowed to permitted to execute operation _op.           }
{                                                                           }
{ ************************************************************************* }


BEGIN_TRANSACTION(_s,_module,_user,_op) :-
   	getFlag(Transaction_counter,_tid),
   	_newTid is _tid + 1,
   	setFlag(Transaction_counter,_newTid),
   	resetFlag(currentAnswerFormat),
        usernameWithouthost(_user,_u),
        set_active_user(_u),
        resetCountersAndState,
   	set_transaction_time,
   	get_transaction_time(_tt),
        get_cb_feature(maximalErrors,_maxe),
        setFlag(remainingErrorQueueSlots,_maxe),
        setFlag(bulkQuery,off),  {* reset bulkQuery mode to off *}
   	{* for BDMEvaluation:}
         	retractall(Inserted(_)),
         	retractall(Deleted(_)),
        {* for Literals/ded_In: }
        checkToEmptyCacheOnNewTransaction,
	pc_update(active_sender(_s)),    { * store the name of the responsible tool }
        checkPermission(_user,_op,_module),  {* also sets module context to _module *}
        storeTransactionTime(_op,_tt),
        timetoatom(noniso,_tt,_ttatom),
        getModulePath(_mpath),   {* fetch the path to the current module *}
        pc_atom_to_term(_mpathatom,_mpath),   {* convert to an atom (avoiding quotes) *}
        getModuleName(_mname),
        eraseAnswerParameters('AuxAnswerParameter'),
        addAnswerParameters('AuxAnswerParameter',[_user/user,
                                                  _ttatom/transactiontime,
                                                  _mname/currentmodule,
                                                  _mpathatom/currentpath
                                                 ]),
   	WriteTrace(veryhigh,CBserverInterface,
              	['BEGIN OF TRANSACTION ',_newTid,' FOR ',_s, ' at ',_tt, ' in Module-Searchspace  >',_module,'<']),
   !.

{ Transaktion soll auf nicht-existierenden Modulkontext stattfinden : LWEB }
BEGIN_TRANSACTION(_s,_module,_user,_op) :-
	not(retrieve_proposition_noimport(_,P(_mid,_mid,_module,_mid))),
	report_error( MOD1, CBserverInterface, [_module]),
	!,
	fail.


{* basic context of the CBserver when an ipcmessage is about to be handled *}
{* superseded by BEGIN_TRANSACTION for ASK/TELL operations                 *}
setBasicCallContext(_sender) :-
        knownTool(_sender,_,_user,_,_),
        usernameWithouthost(_user,_u),
        set_active_user(_u),
  	set_transaction_time,
   	get_transaction_time(_tt),
        timetoatom(_tt,_ttatom),
        addAnswerParameters('AuxAnswerParameter',[_sender/sender,_user/user,_ttatom/transactiontime]),
        !.
setBasicCallContext(_sender).  {* never fail *}


{* 18-Sep-2007: introduce resetCountersAndState for BEGIN_TRANSACTION and ENROLL_ME *}
resetCountersAndState :-
        reset_counter('error_number@F2P'),
        reset_counter('error_number@F2HP'),
        reset_counter('error_number@SI'),
        reset_counter('error_number@UI'),
        reset_counter('error_number@ECA'),
        reset_ECA_ExecutionQueue,          {* see ticket #93 *}
        init_eca_state,
        removeCheckUpdateMode,             {* see TellAndAsk.pro *}
        resetStratificationError,
        setFlag(optimizeLevel,1),       {* used in MetaRFormToAssText *}
        !.
resetCountersAndState.



storeTransactionTime(_op,_tt) :-
	member(_op,[TELL,RETELL]),   {* do not store the transaction time object for pure UNTELLs *}
	pc_atom_to_term(_ttatom,tt(_tt)),
	pc_atomconcat(['"',_ttatom,'"'],_ttstring),
	create_if_builtin_object(_ttstring,TransactionTime,_created_id),
	!.
storeTransactionTime(_,_).



{* 26-Feb-2004/M.Jeusfeld: simple access control feature; see also CBNEWS[209] *}

{* setting the module context to a new module is requiring read access *}
checkPermission(_fullusername,[SET_MODULE_CONTEXT,'..'],_module) :-
   !. {* super module is always readable *}

checkPermission(_fullusername,[SET_MODULE_CONTEXT,_newmodule],_module) :-
  checkPermission(_fullusername,ASK,_newmodule).

checkPermission(_fullusername,_operation,_module) :-
   enactModuleContext(_module,ok),
   get_cb_feature(securityLevel,_lev),       
   (_lev == '0'; _lev == '1'),  {* access control disabled,  CBserver option -s *}
   !.

{* ticket #300: no permission test possible in System module. *}
{* instead: we disallow write operations to System when security level is 2 or higher *}
checkPermission(_fullusername,_operation,'System') :-
   member(_operation,['ASK','HYPO_ASK']),
   get_cb_feature(securityLevel,_lev),  
   _lev \== '0', _lev \== '1',
   enactModuleContext('System'),
   !.


{* case 2: securityLevel=2, module is not protected: allow _anybody to execute _operation *}
checkPermission(_fullusername,_operation,_module) :-
   _module \== 'System',
   get_cb_feature(securityLevel,_lev),  
   _lev == '2',
   enactModuleContext(_module,ok),
   \+ getPermissionTest(_fullusername,_operation,_module,_query_lit),   {* no query CB_Permitted* defined in _module *}
   !.


{* case 3: securityLevel=2, module is protected and we can show that _username is permitted for _operation *}
checkPermission(_fullusername,_operation,_module) :-
   _module \== 'System',
   get_cb_feature(securityLevel,_lev),  
   _lev == '2',
   enactModuleContext(_module,ok),
   getPermissionTest(_fullusername,_operation,_module,_query_lit),
   prove_literal(_query_lit),
   !.

{* case 4a: securityLevel=3, only READ operations are permitted when no CB_Permitted* is defined *}
checkPermission(_fullusername,_operation,_module) :-
   member(_operation,['ASK','HYPO_ASK']),
   get_cb_feature(securityLevel,_lev),  
   _lev == '3',
   enactModuleContext(_module,ok),
   \+ getPermissionTest(_fullusername,_operation,_module,_query_lit),   {* no query CB_Permitted* defined in _module *}
   !.

{* case 4b: securityLevel=3, at most READ operations are permitted, subject to CB_Permitted* *}
checkPermission(_fullusername,_operation,_module) :-
   member(_operation,['ASK','HYPO_ASK']),
   get_cb_feature(securityLevel,_lev),  
   _lev == '3',
   enactModuleContext(_module,ok),
   getPermissionTest(_fullusername,_operation,_module,_query_lit),
   prove_literal(_query_lit),
   !.



{* else: permission is not granted *}
checkPermission(_fullusername,_operation,_module) :-
   enactModuleContext(oHome),
   report_error( NPERMERR, CBserverInterface, [_fullusername,_operation,_module]),
   !,
   fail.


{* generate the internal query lit to call a CB_Permitted* query *}
getPermissionTest(_fullusername,_operation,_module,_query_lit) :-
  usernameWithouthost(_fullusername,_username),
  (
    pc_atomconcat(CB_Permitted,_module,_queryname);  {* e.g. CB_PermittedMyModule *}
    _queryname=CB_Permitted
  ),
  transform_querycall(_queryname,_username,[_username/user,_operation/op,_module/res],_query_lit),
  !.



{* ticket #324: compute some statistics on the number of triggers that can guide *}
{* the integrity checker                                                         *}

computeTriggerComplexity :-
  currentCheckUpdateMode(_mode),  {* only needed when the db was updated in the current transaction *}
  computeTriggerComplexity(_mode),
  !.


computeTriggerComplexity(YES) :-
  findTriggerCount(id_407,_c1),  {* id_407 = MSFOLrule!specialRule *}
  findTriggerCount(id_409,_c2),   {* id_409 = MSFOLconstraint!specialConstraint *}
  set_counter(ruleTriggerCount,_c1),
  set_counter(ruleTriggerCount,_c2),
  write('Rule triggers = '),write(_c1),write(',  Constraint triggers = '),write(_c2),nl,
  !.

computeTriggerComplexity(_).

findTriggerCount(_catid,_count) :-
  save_bagof(_x,prove_literal(In_s(_x,_catid)),_set),
  length(_set,_count).
 

  



{ ********************* E N D _ T R A N S A C T I O N ********************* }
{                                                           24-Jan-1990/MJf }
{ END_TRANSACTION                                                           }
{                                                                           }
{ END_TRANSACTION is the inverse of BEGIN_TRANSACTION: it closes a trans-   }
{ action.                                                                   }
{                                                                           }
{ ************************************************************************* }

END_TRANSACTION :-
{*  computeTriggerComplexity,  *** ticket #324 *}
   active_sender(_s),
   getFlag(Transaction_counter,_tid),
{*   enactModuleContext(System), *} { setze MSP auf System zurueck }
   pc_update(active_sender(unknown)),
   remove_active_user,
   eraseAnswerParameters('AuxAnswerParameter'),
   WriteTrace(veryhigh,CBserverInterface,
              ['END OF TRANSACTION ',_tid,' FOR ',_s]),
   !.

END_TRANSACTION.  {never fail}


{* return the ID of the current client, its toolclass and the username *}
currentClient(_toolid,_toolclass,_user) :-
  active_sender(_toolid),
  knownTool(_toolid,_toolclass,_username,_fd,_currentmodule),
  !.
  



{* enable a module context by setting the search space accordingly *}
{* the variant enactModuleContext/1 never fails, whereas the       *}
{* enactModuleContext/2 returns whether the module enactment was   *}
{* successful.                                                     *}

enactModuleContext('$Home') :-
  active_sender(_s),
  knownTool(_s,_toolclass,_username,_fd,_currentmodule),
  findHomeModule(_toolclass,_username,_homemodule),
  enactModuleContext(_homemodule,_),
  !.

enactModuleContext(_module_path) :-
  enactModuleContext(_module_path,_).

enactModuleContext(_module_path,ok) :-
  atom(_module_path),
  pc_save_atom_to_term(_module_path,_p),  {* for example System-oHome-M1 *}
  enactModulePath(_p),
  !.

{* module context could not be enabled *}
enactModuleContext(_module_name,error) :-
  WriteTrace(low,CBserverInterface,['Module context could not be enacted: ',_module_name]),
  !.



enactModulePath(_mod) :-
  atom(_mod),
  enactOneModuleContext(_mod),
  !.

enactModulePath((_path-_mod)) :-
  atom(_mod),
  enactModulePath(_path),
  enactOneModuleContext(_mod).

{* ticket #372: also support '/' as module separator *}
enactModulePath((_path/_mod)) :-
  atom(_mod),
  enactModulePath(_path),
  enactOneModuleContext(_mod).

{* changing to 'System' module can be done quicker because we have cached *}
{* the identifier earlier.                                                *}
enactOneModuleContext(System) :-
  System(_mid),
  switchModule(_mid),
  !.

{* otherwise look up the module id and change context accordingly *}
enactOneModuleContext(_module_name) :-
  atom(_module_name),
  retrieve_proposition_noimport(_,P(_mid,_mid,_module_name,_mid)),
  name2id(Module,_module),
  prove_literal(In_e(_mid,_module)),
  switchModule(_mid),
  !.


{* 1-arg version of switchModule *}
switchModule(_mid) :-
  getModule(_oldmid),
  switchModule(_oldmid,_mid).



switchModule(_mid,_mid) :- !.  {* nothing to be done as new module as old module *}

switchModule(_oldmid,_newmid) :-
  saveSingleModule(_compl,_oldmid),          {* save content of old module if it has changed *}
  checkToEmptyCacheOnSearchSpaceChange,      {* since we are changing the search space *}
  setModule(_newmid),
  !.

{* see ticket #139: be stricter in allowing a client to shut down a CBserver *}
{* Other tools will just be denied to execute STOP_SERVER.                   *}

{* case 1: client user u1 is the same as server user u2 *}
authorizedFor('STOP_SERVER',_u1,_u2,_toolid) :-
  pc_atompartsall(_u1,_u2,1),  {* server user string _u2 is prefix of the client user string _u1 *}
  !.

{* If an adminUser is declared for the CBserver, e.g. 'billy@myhost' then a client that enrolled *}
{* to the CBserver with a user name like 'billy@myhost_amd64_Linux' can stop the CBserver.       *}
{* If the adminUser is just 'billy', then he can stop the CBserver from any client machine.      *}
authorizedFor('STOP_SERVER',_u1,_u2,_toolid) :-
  get_cb_feature(adminUser,_admin), 
  pc_atompartsall(_u1,_admin,1).  {* admin user string _admin is prefix of the client user string _u1 *}


#DYNAMIC(thisToolId/1)

#DYNAMIC(server_id/1)


thisToolClass('CBserver').

thisToolId('').  {to be changed on program start}

server_id('').


{* computeCompletionReturn(_err1,_err2,_completion,_return)  determines *}
{* the completion and return for a TELL/UNTELL/RETELL-operation. The    *}
{* parameter _err1 is the error code of the operation itself, _error2   *}
{* is the error code of the checkUpdate procedure called after the      *}
{* operation.                                                           *}
computeCompletionReturn(noerror,noerror,ok,yes) :- !.
computeCompletionReturn(error,_,error,no) :- !.
computeCompletionReturn(_,error,error,no) :- !.



{* 
The active user is the short name of the user who has started the current operation
of the CBserverInterface. Similar to active_sender.
*}


set_active_user(_u) :-
  pc_recorded('ACTIVE_USER','CBserverInterface',_u1),
  _u1 \= _u,
  pc_rerecord('ACTIVE_USER','CBserverInterface',_u),
  !.
set_active_user(_u) :-
  pc_recorded('ACTIVE_USER','CBserverInterface',_u),
  !.
set_active_user(_u) :-
  pc_record('ACTIVE_USER','CBserverInterface',_u),
  !.
set_active_user(_u).   {* never fail *}

active_user(_u) :-
  pc_recorded('ACTIVE_USER','CBserverInterface',_u).

remove_active_user :-
  pc_erase('ACTIVE_USER','CBserverInterface'),
  !.
remove_active_user.



{* memoRollbacktime makes the rollback time of an ASK transaction accessible as a *}
{* variable in answer formats.                                                    *}

memoRollbacktime('Now') :-
  addAnswerParameters('AuxAnswerParameter',['Now'/rollbacktime]),
  !.

memoRollbacktime(_rbtime) :-
  atom(_rbtime),
  pc_atom_to_term(_rbtime,_term),
  timetoatom(_term,_rbatom),
  addAnswerParameters('AuxAnswerParameter',[_rbatom/rollbacktime]),
  !.

memoRollbacktime(_rbtime).





{* shut down ConceptBase if it was started in 'slave'  mode and the last local client *}
{* was removed via CANCEL_ME.                                                         *}

shutDownSlaveIfNoClients(_clientuser) :-
   thisToolId(_serverid),
   get_cb_feature(servermode,slave), 
   noClientLeft(_serverid,_clientuser),
   getoutofConceptBase,
   setRequestDownOnLastClientIfUnset,
   !.
shutDownSlaveIfNoClients(_clientuser).

setRequestDownOnLastClientIfUnset :-
  getFlag(requestDownCBserver,regular),  {* already marked to shut down via STOP_SERVER *}
  !.
setRequestDownOnLastClientIfUnset :-
  setFlag(requestDownCBserver,lastclient),  {* will be detected in IpcChannel.pro *}
  !.



{* there are still other clients left on this CBserver *}
noClientLeft(_serverid,_clientuser) :-
  isknownTool(_toolid,_cl,_u),
  _toolid \== _serverid,
  stillActive(_toolid),  {* ticket #378 *}
  !,
  WriteTrace(low,CBserverInterface, ['Server not shut down; use explicit STOP_SERVER command']),
  fail.

{* the CBserver is a regular one (no -r option) enabled and
   has no other client but the clientuser requesting the shutdown is not an admin user;
   this is then typically a regular CBserver serving remote clients
*}
noClientLeft(_serverid,_clientuser) :-
  get_cb_feature(repeatLoop,off), 
  isknownTool(_toolid,_cl,_u),
  get_cb_feature(adminUser,_adminuser),
  \+ sameUser(_clientuser,_adminuser), 
  !,
  WriteTrace(low,CBserverInterface, ['User not authorized to shutdown non-restarting server: ',_clientuser]),
  fail.


{* otherwise we accept the shutdown *}
noClientLeft(_serverid,_clientuser).



{* a client is still active if the last operation is less than 2 hours ago *}
stillActive(_client) :-
  get_cb_feature(servermode,slave),   {* true for public CBservers *}
  get_cb_feature(inactivityInterval,_tmax),   {* time in hours of that characterizes inactivity *}
  _tmax >= 0.0,  {* negative tmax means that any client shall be regarded active *}
  getLastActivity(_client,_t),
  pc_gettime(_now),
  _elapsed is _now - _t,  {* elapsed seconds since last activity of _client *}
  _elapsed > _tmax * 3600 , {* tmax is in hours *}
  !,
  fail.
stillActive(_client).


  

{* the following predicates maintain the times of last activities for all clients *}

setLastActivity(_client) :-
  get_cb_feature(servermode,master),   {* the CBserver is not shuuting down on client exit *}
  !.                                   {* then we do not memorize last activity times      *}

setLastActivity(_client) :-
  pc_gettime(_t),  {* current time in seconds since 1970-01-01 as float number *}
  client_lastactivity(_client,_t1),
  retract(client_lastactivity(_client,_t1)),
  assert(client_lastactivity(_client,_t)),
  !.

setLastActivity(_client) :-
  pc_gettime(_t),
  assert(client_lastactivity(_client,_t)),
  !.

getLastActivity(_client,_t) :-
  client_lastactivity(_client,_t).



  




