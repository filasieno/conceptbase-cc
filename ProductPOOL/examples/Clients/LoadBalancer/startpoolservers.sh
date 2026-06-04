#! /bin/bash
# Example to start a number of ConceptBase pool cbservers to be used by CBserverLoadBalancer
# The pool cbservers are started in nonpersistent mode and use -g public, hence can serve multiple users in principle.
# Each user gets a dedicated home directory such as System-oHome-maryA
# We start here just 2 pool servers, each with its own log file. Add more as needed.
# The restart delay is set to 20 seconds to mitigate denial of service

(cbserver -port 5001 -r 20 -a $USER -g public -u nonpersistent -t minimal &>> log5001.log) &
(cbserver -port 5002 -r 20 -a $USER -g public -u nonpersistent -t minimal &>> log5002.log) &



