README.txt: CBserverLoadBalancer

Manfred Jeusfeld, 2026-05-07 (2026-05-10)


CBserverLoadBalancer is a Reverse Proxy Load Balancer for the ConceptBase server. It pretends to ConceptBase
clients to be a ConceptBase server. But in fact it forwards their requests to a pool of ConceptBase servers
on localhost. When a client gracefully exits, the corresponding slot becomes free again, assuming that the
ConceptBase server restarts itself on the same port.

Compile with Java 11 or later:
javac CBserverLoadBalancer.java


A. Simple use
=============


(1) To start the load balancer, first start a pool of CBservers with consecute port numbers, e.g.

(cbserver -port 5001 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5001.txt) &
(cbserver -port 5002 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5002.txt) &
(cbserver -port 5003 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5003.txt) &
(cbserver -port 5004 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5004.txt) &

Here $USER is set as the administrator user (you!), who can shutdown the CBserver, e.g. via cbshell.
The option -g public will among others make sure that a user gets a dedicated home module.
The option 'r 0' means that the server restarts itself after the last client exits. The
delay here is 0 seconds.
The parameter '-ia 1' specifies that the CBserver regard a client inactive after 1 hour passed after
its last message to the server.

More, see: https://conceptbase.sourceforge.net/userManual85/cbm007.html#sec%3Apubcbserver


(2) To start the load balancer, enter a command like

java CBserverLoadBalancer mysecret123 4001 5001 5004

mysecret123: example of a secret key to shut down the load balancer. 
4001: the port to which the load balancer listens for ConceptBase clients connects. This is also the default port
      number of a ConceptBase server
5001: Port number of the first pool server
5004: Port number of the last pool server



(3) Connections and restarts

ConceptBase clients like CBIva and CBGraph can connect to the service by connecting to localhost with port 4001,
or they can use the full domain name of the host if the service is made available to other computers. The clients
do not see any difference with the behavior of a normal CBserver.

The first message of a client is an ENROLL_ME message. The load balancer will then assign one of the pool
servers to that client and pass the request to the pool server and return its answers back to the client.
The last message of a client is normally a CANCEL_ME message. This will also be passed to the connected pool server,
causing it to shutdown and restart (option -r). The pool server is then set to be available again by the
load balancer.

The example below shows two different users u1 and u2 who connect via port 400. The use the protocol of ConceptBase
clients, i.e. they assume that there is a CBserver running on port 4001. Instead, it is the load balancer. 
The first client of u1 is mapped by the load balancer to the pool cbsrver1 on port 5001. Messages of cbiva1
are received by the load balancer and passed unchanged to cbserver1. The answers go back the reverse direction.

[u1@cbiva1]   <-----> (4001) [loadbalancer]  <-----> (5001) [cbserver1]
[u2@cbiva2]   <-----> (4001) [loadbalancer]  <-----> (5002) [cbserver2]
[u1@cbgraph1] <-----> (4001) [loadbalancer]  <-----> (5001) [cbserver1]

The second client cbiva2 is for a different user u2. It gets another cbserver2 assigned on port 5002.
Finally, the cbgraph1 client is again by user u1. It gets cbserver1 assigned. All clients of the same
user are passed to the same CBserver.

The loadbalancer sniffs into the first packet received by a new client. It is supposed to be an 
ENROLL_ME (=login message). It contains aming users the username.

If the server is started with the -r option, then the last client connected to that cbserver will trigger
a fresh restart of the cbserver. If the cbserver shall serve a new user, it makes sense to use the -u nonpersistent
model for the cbserver. The next new client can then re-use the cbserver, e.g. cbserver1 on port 5001.





(4) Stopping the load balancer

On localhost, you can stop it with the command

echo "SHUTDOWN_BALANCER mysecret123" | nc localhost 4001

You can also shut it down remotely if you know the secret key.



(5) Stopping the pool servers

The pool servers are not shut down automatically when you shutdown the load balancer. 
You need to use cbshell on localhost to shut them down. For example:

cbshell
This is CBShell, the command line interface to ConceptBase.cc
[offline]>connect localhost 5001
Successfully connected to server
[localhost:5001]>stop

It is a good idea not to make the portnumbers of the pool servers visible outside localhost.



-----------------------------

B. Advanced use
===============

In this scenerio, we want that users get their dedicated databases, i.e. when they connect the first time
to the load balancer via a client such as CVIva, then the assigned pool server is memorized in a file and
that assignment will be re-used wben the load balancer is re-started. Hence, if the database of the pool
CBserver is persistent and all programs are restarted, the user still gets assigned the correct database.

(1) Start a pool of CBservers with consecute port numbers and dedicated databases in persistent mode

(cbserver -port 5001 -r 0 -u persistent -d MDB5001 &> log5001.txt) &
(cbserver -port 5002 -r 0 -u persistent -d MDB5002 &> log5002.txt) &
(cbserver -port 5003 -r 0 -u persistent -d MDB5003 &> log5003.txt) &
(cbserver -port 5004 -r 0 -u persistent -d MDB5004 &> log5004.txt) &


(2) To start the load balancer with user-port mapping file

java CBserverLoadBalancer mysecret123 4001 5001 5004 -c up1.txt


A typical user-port maiing file looks like

freddie1@computer1:5001
mary.kal@computer2:5002
anne.rol@computer1:5003
sharon.h@computer2:5004


The file is updated every 60 seconds. If a user logs out. the mapping may be updated with the next
user who claims the pool server. 

If you use in addition the command line paramter -fix, the the assigment of ports to users is
sticky. Even if the user logs out, the port can only be assigned to clients of the same user.

java CBserverLoadBalancer mysecret123 4001 5001 5004 -c up1.txt -fix

This is needed if you want to make sure that a given user always gets assigned to the same pool server
that provides a dedicated ConceptBase database for that user.














