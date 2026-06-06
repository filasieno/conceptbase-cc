= Example C Client
<cha:logclient>
This chapter explains the usage of the C programming interface with an
example program called `LogClient`. This program is able to read the
`OB.log` file created by ConceptBase server and performs the operations
stored in this file.

The full source code of this program is in the directory
``CB_HOME`/examples/Clients/LogClient`. The file `LogClient.c` contains
beside the main program some little functions to read the log file. This
source file must be compiled and linked together with a version of the
ConceptBase library `libCB.a`. The file `MakeLogClient` is a makefile,
which executes the necessary commands to compile and link the file with
`gcc` on a Unix-platform. The following paragraphs explain only the
important parts of the main program.

Before any functions of libCB can be used, one must include the header
file `CBinterface.h`.

```
  #include <CBinterface.h>

  int main(int argc,char* argv[]) {

    int PortNr;
    char* HostName;
    char* UserName;
    Answer *ans;
    Server *gserver;
    char* command;
    char* arg;

    char   *ClientName  = "LogClient";
```

The variables `PortNr`, `HostName`, `UserName` and `ClientName` are
initialized with the command line arguments and passed to the
`connect_CB_server` function below. `ans` stores the answer of an
operation with the ConceptBase server. `gserver` is a pointer to a
`Server` structure which is filled by the connect-function. `command` is
the command which has been read from the log file and `arg` is the
argument for this command.

```
    /* Reading and checking command line arguments */
    /* ... */

    /* Connect to CBserver */
    connect_CB_server(PortNr, HostName, ClientName, UserName, &gserver);
    if (!gserver) {
        fprintf(stderr,"Connection failed!\n");
        return 1;
```

The function `connect_CB_server` opens an IPC socket to the specified
ConceptBase server and performs an `ENROLL_ME` method as described in
chapter `serverinterface`. If the connection can be successfully
established, the `gserver` variable points to the connected server.
Otherwise, `gserver` will be `NULL`.

Now, the program begins to read the log file. As long as there are
commands in the log file, the variable `command` points to a string
containing the actual method and `arg` contains the arguments of this
method.

Depending on the value of `command`, the program executes the
corresponding function to pass the method with its arguments `arg` to
the ConceptBase server. Possible values for `command` are
e.g.~`tellCB, untell,ask_frames, ...`

```
    /* Read commands from logfile until end of file */
    while(readLogCommand(fp,&command,&arg)) {

        /* Ask user, if the command should be executed */
        /* ... */

        /* Tell */
        if (!strcmp(command,"tell")) {
            printf("Telling: 
            ans=tellCB( gserver, arg );

        /* Untell */
        if (!strcmp(command,"untell")) {
            printf("Untelling: 
            ans=untell( gserver, arg );

        /* Tell Model */
        if (!strcmp(command,"tell_model")) {
            printf("Loading models: 
            files=commaList2charArray(arg);
            ans=tell_model( gserver, files );
            for(i=0;i<MAX_FILES;i++) {
                if (files[i])
                    free(files[i]);
                free(files);

```

Note, that the `tell` and `untell` functions take a simple string
containing frames as argument, whereas the function `tell_model` takes a
list of filenames as argument. The frames are loaded from these files by
ConceptBase and the told to the knowledge base.

Tell and untell operations return a pointer to an Answer object. For
tell and untell, it is sufficient to check the completion value of the
answer. The return\_data can be ignored for these methods.

The following `ask` functions return also an Answer object. The answer
of the query is stored in the field return\_data, the completion is
`CB_OK`, if the query could be evaluated. Otherwise the completion will
CB\_ERROR or CB\_TIMEOUT.

```
        /* Ask objnames */
        if (!strcmp(command,"ask_objnames")) {
            printf("Ask (OBJNAMES): 
            ans=ask_objnames( gserver, arg, "LABEL","Now" );
            printf("Answer: 

        /* Ask frames */
        if (!strcmp(command,"ask_frames")) {
            printf("Ask (OBJNAMES): 
            ans=ask_frames( gserver, arg, "LABEL","Now" );
            printf("Answer: 

        /* Check completion */
        if (ans && ans->completion) {
            fprintf(stderr,
                    ">>> Server reports error on method: 
                    command,arg);
```

When an error occured, i.e. `completion` is not zero (another value than
`CB_OK`), than a error message is printed on the console. Perhaps, it is
also useful to get the all error messages from ConceptBase server, but
this is not done here#footnote[But that should be done in a _good_
client program.];.

```

    /* Close connection to CBserver */
    disconnect_CB_server(gserver);

    return 0;
```

If the while-loop is finished the connection to the ConceptBase server
can be closed with the function `disconnect_CB_server` and the program
is finished.
