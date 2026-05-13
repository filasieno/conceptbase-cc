# README.md: CBserverLoadBalancer

Manfred Jeusfeld, 2026-05-07 (2026-05-13)


CBserverLoadBalancer is a Reverse Proxy Load Balancer for the ConceptBase server. It pretends to ConceptBase clients to be a ConceptBase server. But in fact it forwards their requests to a ConceptBase server from a pool of such servers on localhost. When a client gracefully exits, the corresponding slot becomes free again. The assignment can be controlled by a number of parameters.

Compile with Java 11 or later:

    javac CBserverLoadBalancer.java


## A. Simple use


### (1) To start the load balancer, first start a pool of CBservers with consecutive port numbers, e.g.

    (cbserver -port 5001 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5001.txt) &
    (cbserver -port 5002 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5002.txt) &
    (cbserver -port 5003 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5003.txt) &
    (cbserver -port 5004 -r 0 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log5004.txt) &

Here $USER is set as the administrator user (you!), who can shutdown the CBserver, e.g. via cbshell. The option `-g public` will among others make sure that a user gets a dedicated home module.
The option `-r 0` means that the server restarts itself after the last client exits. The delay here is 0 seconds.
The parameter `-ia 1` specifies that the CBserver regard a client inactive after 1 hour passed after its last message to the server.

More, see: https://conceptbase.sourceforge.net/userManual85/cbm007.html#sec%3Apubcbserver


### (2) To start the load balancer, enter a command like

    java CBserverLoadBalancer mysecret123 4001 5001 5004

 1. mysecret123: example of a secret key to shut down the load balancer.
 2. 4001: the port to which the load balancer listens for ConceptBase clients connects. This is also the default port number of a ConceptBase server 
 3. 5001: Port number of the first pool server
 4. 5004: Port number of the last pool server

### (3) Connections and restarts

ConceptBase clients like CBIva and CBGraph can connect to the service by connecting to localhost with port 4001, or they can use the full domain name of the host if the service is made available to other computers. The clients do not see any difference with the behavior of a normal CBserver.

The first message of a client is an ENROLL_ME message. The load balancer will then assign one of the pool
servers to that client and pass the request to the pool server and return its answers back to the client.
The last message of a client is normally a CANCEL_ME message. This will also be passed to the connected pool server, causing it to shutdown and restart (option -r). The pool server is then set to be available again by the load balancer.

The example below shows two different users `mary1` and `billA` who connect to a CBserver load balancer on a fictitious host `cbserver.acme.org` via port 4001. They use the protocol of ConceptBase clients, i.e. they assume that there is a CBserver running on port 4001. Instead, it is the load balancer.  The first client of `mary1` is mapped by the load balancer to the pool `cbserver1` on port 5001. Messages from `cbiva1` are received by the load balancer and passed unchanged to `cbserver1`. The answers go back the reverse direction.

    [mary1@cbiva1]   <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5001) [cbserver1]
    [billA@cbiva2]   <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5002) [cbserver2]
    [mary1@cbgraph1] <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5001) [cbserver1]



![Load Balancer architecture](https://gitlab.com/mjeu/conceptbasecc/-/raw/master/ProductPOOL/examples/Clients/LoadBalancer/loadbalancer.svg)

The second client `cbiva2` is for a different user `billA`. It gets another `cbserver2` assigned on port 5002.
Finally, the `cbgraph1` client is again for user `mary1`. It gets `cbserver1` assigned. All clients of the same
user are passed to the same CBserver.

The loadbalancer sniffs into the first packet received by a new client. It is supposed to be an ENROLL_ME (=login message). It contains among others the username. If the server is started with the `-r` option, then the last client connected to that CBserver will trigger
a fresh restart of the CBserver. If the CBserver shall serve a new user, it makes sense to use the `-u nonpersistent` mode for the cbserver. In this scenario, the next new client can then re-use the cbserver, e.g. `cbserver1` on port 5001.


### (4) Stopping the load balancer

On localhost, you can stop it with the command

    echo "SHUTDOWN_BALANCER mysecret123" | nc localhost 4001

You can also shut it down remotely if you know the secret key.



### (5) Stopping the pool servers

The pool servers are not shut down automatically when you shutdown the load balancer. 
You need to use cbshell on localhost to shut them down. For example:

    cbshell
    This is CBShell, the command line interface to ConceptBase.cc
    [offline]>connect localhost 5001
    Successfully connected to server
    [localhost:5001]>stop

It is a good idea not to make the portnumbers of the pool servers visible outside localhost.




## B. Advanced use

In this scenario, we want that users get their dedicated databases, i.e. when they connect the first time
to the load balancer via a client such as CBIva, then the assigned pool server is memorized in a file and
that assignment will be re-used wben the load balancer is re-started. Hence, if the database of the pool
CBserver is persistent and all programs are restarted, the user still gets assigned the correct database.

### (1) Start a pool of CBservers with consecute port numbers and dedicated databases in persistent mode

    (cbserver -port 5001 -r 0 -u persistent -d MDB5001 &> log5001.txt) &
    (cbserver -port 5002 -r 0 -u persistent -d MDB5002 &> log5002.txt) &
    (cbserver -port 5003 -r 0 -u persistent -d MDB5003 &> log5003.txt) &
    (cbserver -port 5004 -r 0 -u persistent -d MDB5004 &> log5004.txt) &


### (2) Start the load balancer with user-port mapping file

    java CBserverLoadBalancer mysecret123 4001 5001 5004 -c userportmap.txt


A typical user-port mapping file looks like

    mary1@acme-linux:5001
    billA@factor-mac:5002
    anne3@acme-linux:5003
    shar5@solars-win:5004


The file is updated every 60 seconds. If a user logs out, the mapping may be updated with the next user who claims the pool server. 

If you additionally use the command line parameter `-fix`, then the assignment of ports to users is
sticky. Even if the user logs out, the port can only be assigned to clients of the same user.

    java CBserverLoadBalancer mysecret123 4001 5001 5004 -c userportmap.txt -fix

This is needed if you want to make sure that a given user always gets assigned to the same pool server
that provides a dedicated ConceptBase database for that user. You can also pre-configure the user-port mapping file before starting the load balancer. It shall then use this assignment to link user clients to the dedicated CBservers.


## C. A Rust implementation

The load balancer is also posrted to Rust, see CBserverLoadBalancer.rs. It should behave the same or very simular to CBserverLoadBalancer.java. To compile the Rust version use

    rustc -O  CBserverLoadBalancer.rs -o CBserverLoadBalancer

Tu run it, use for example

    ./CBserverLoadBalancer stop 4001 5001 5002


## D. Know issues

- There are rare cases when a message is lost, either between clients and the load balancer or the load balancer and the pool servers. It seems that this only happens for initial messages.

- The load balancer does not start or restart a pool server. This has to be done by separate bash scrips or terminal commands.

- The messages are not encrypted. There are no passwords used. This is no different to the previous situation where clients directly communicate with a CBserver.












