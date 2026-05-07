README.txt: CBserverLoadBalancer

Manfred Jeusfeld, 2026-05-07


CBserverLoadBalancer is a Reverse Proxy Load Balancer for the ConceptBase server. It pretends to ConceptBase
clients to be a ConceptBase server. But in fact it forwards their requests to a pool of ConceptBase servers
on localhost. When a client gracefully exits, the corresponding slot becomes free again, assuming that the
ConceptBase server restarts itself on the same port.

Compile with Java 11 or later:
javac CBserverLoadBalancer.java

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








