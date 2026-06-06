= Syntax Specifications
<cha:SyntaxSpec>
== Syntax Specification for IPC messages
<sec:ipcmessages>
```
<ipcmessage>         ->  ipcmessage(<sender>,<receiver>,<method_and_args>).
 
<sender>             ->  IPCSTRING
 
<receiver>           ->  IPCSTRING
 
<method_and_args>    ->  <tell>
                     |   <untell>
                     |   <ask>
                     |   <hypoask>
                     |   <tellmodel>
                     |   <enrollme>
                     |   <cancelme>
                     |   <nextmessage>
                     |   <stopserver>
                     |   <reportclients>
                     |   <lpicall>
 
<tell>               ->  TELL , [ <telosframes> <modulearg> ]
 
<tellmodel>          ->  TELL_MODEL , [ <filelist> <modulearg> ]
 
<filelist>           ->  [ <ipcstringlist>  ]
 
<untell>             ->  UNTELL , [ <telosframes> <modulearg> ]
 
<ask>                ->  ASK , [ <askargs> <modulearg> ]
 
<askargs>            ->  <query>  , <answerrep>  , <rollbacktime>
 
<query>              ->  FRAMES , <telosframes>
                     |   OBJNAMES , <objnames>
 
<objnames>           ->  IPCSTRING
 
<answerrep>          ->  IPCSTRING
 
<rollbacktime>       ->  IPCSTRING
 
<hypoask>            ->  HYPO_ASK , [ <telosframes>  , <askargs> <modulearg> ]
 
<enrollme>           ->  ENROLL_ME , [ <toolclass>  , <username> <modulearg> ]
 
<modulearg>     --> ',' IPCID 
                 | "empty"

<toolclass>          ->  IPCSTRING
 
<username>           ->  IPCSTRING
 
<cancelme>           ->  CANCEL_ME , [ ]
 
<nextmessage>        ->  NEXT_MESSAGE , [ <method>  ]
 
<method>             ->  "empty"
                     |   IPCID
 
<stopserver>         ->  STOP_SERVER , [ <method>  ]
 
<reportclients>      ->  REPORT_CLIENTS , [ ]
 
<lpicall>            ->  LPI_CALL , [ IPCSTRING ]
 
<telosframes>        ->  IPCSTRING
 
<ipcstringlist>      ->  IPCSTRING
                     |   <ipcstringlist>  , IPCSTRING
 
IPCSTRING            ->  everything enclosed in " except " and \, 
                         which must be escape with \
 
IPCID                ->  [a-zA-Z]+[a-zA-Z0-9_]*
```

== Syntax Specification for IPC answers
<sec:ipcanswers>
```
<ipcanswer>          ->  ipcanswer(<sender>,<completion>,<result>).

<sender>             ->  IPCSTRING

<completion>         ->  ok
                     |   error
                     |   not_handled
                     
<result>             ->  IPCSTRING
```
