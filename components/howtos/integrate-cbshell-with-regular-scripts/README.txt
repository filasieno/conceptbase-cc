Shell Integration with ConceptBase

Manfred Jeusfeld, 2012-07-12


The example is about retrieving information about files via
a Bourne shell script, to store the information in ConceptBase,
and then to retrieve answers to queries about this information.

The CBshell scripts are

tell    -- tells a frame to a ConceptBase server
ask     -- asks simple queries  to ConceptBase
stopcb  -- just stops a ConceptBase server


The Bourne shell scripts are

startcb      -- starts a CBserver with on a database 
fileSizeDemo -- the main script coordinating the other scripts



To prepare the demo, make all scripts executable.

  chmod u+x tell ask stopcb startcb fileSizeDemo

The scripts run in the current directory. If you want to
use them anywhere, you need to copy them into a directory that
is in your search path!


Running the demo:

  fileSizeDemo

The script will return some answer like 
  Result is 90,752,...
The numbers are the file sizes as stored in ConceptBase.

All information gets stored in the database FILEDB. The command
dumpcb in fileSizeDemo makes sure that the directory FILEDB
also conatins the readable form of the information in the database.
See file FILEDB/System-oHome.sml


The script is a bit slow since it starts up the CBserver. If the
CBserver would already be running, it would be a bit faster.

The demo requires ConceptBase 7.4.05 because the 'tell' script
relies on the -q option for CBshell.





