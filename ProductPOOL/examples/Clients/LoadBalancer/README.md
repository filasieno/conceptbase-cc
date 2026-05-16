# README.md: CBserverLoadBalancer for Multi-User Installations of ConceptBase

Manfred Jeusfeld, 2026-05-07 (2026-05-16)


CBserverLoadBalancer is a Reverse Proxy Load Balancer for the ConceptBase server (CBserver). It pretends to ConceptBase clients to be a ConceptBase server. But in fact it forwards their requests to a ConceptBase server from a pool of such servers on localhost. When a client gracefully exits, the corresponding slot becomes free again. The assignment can be controlled by a number of parameters.


## A. The client-server architecture of ConnceptBase for multiple users

In most cases, ConceptBase is used in a single-user setup. The ConceptBase server is either started manually on localhost with the `cbserver` command or such a local CBserver is started in the background when the user interface CBIva is started. The defailt port numbers is 4001 and all clients of the user connect to the CBserver on `localhost:4001`.

A typical command to manually start the CBserver on a database MDB:

    cbserver -port 4001 -d MDB &


The CBserver does however also support multiple users. This makes most sense of the CBserver is started on a host, say `cbserver.acme.org`. Command line options eanble the multi-user mode:

    (cbserver -port 4001 -r 1 -a $USER -g public -ia 1 -u nonpersistent -d MDB &> log4001.txt) &

Here $USER is set as the administrator user (you!), who can shutdown the CBserver, e.g. via cbshell. The option `-g public` will among others make sure that a user gets a dedicated home module.
The option `-r 1` means that the server restarts itself one second after the last client exits. The delay here is 0 seconds.
The parameter `-ia 1` specifies that the CBserver regard a client inactive after 1 hour passed after its last message to the server. The parameter `nonpersistent` instructs the CBserver to work on a temporary copy of the database MDB.
More information on the command line parameters is available at https://conceptbase.sourceforge.net/userManual85/cbm007.html#sec%3Apubcbserver

The architecture below shows how a single ConceptBase server has connections from multiple clients from multiple users. In this case the users will work on the same database, even though they may be assigned to different so-called home modules, i.e. parts of the database. The disadvantage of this set-up is that 

- transactions of one user influence the other users
- a long transaction of one user blocks the transactions of the other users until completed

![Client/server architecture](https://gitlab.com/mjeu/conceptbasecc/-/raw/master/ProductPOOL/examples/Clients/LoadBalancer/justcbserver.svg)


## B. Compile the CBserverLoadBalancer

The load balancer is implemented in Rust from CBserverLoadBalancer.rs. To compile the Rust version use the command

    rustc -O  CBserverLoadBalancer.rs -o CBserverLoadBalancer

We used the Rust compiler rustc 1.95.0 but older versions such as 1.75 should also work.

There is also a Java variant CBserverLoadBalancer.java which can be compiled with

    javac CBserverLoadBalancer.java

However, we no longer maintain this variant.



## C. Simple use of CBserverLoadBalancer

The load balancer addresses the short-comings of the client/server architecture of ConceptBase by a three-tier architecture. A pool of worker CBservers is started on the host with local port numbers. User clients however do not directly connect to one of the pool servers but via CBserverLoadBalancer, which is serving the port number `cbserver.acme.org:4001`. The domain name here is just for illustration purposes. The firewalls must be configured to expose the port number 4001 to user computers.



### (1) To start the load balancer, first start a pool of CBservers with consecutive port numbers, e.g.

    (cbserver -port 5001 -r 1 -g public -ia 1 -u nonpersistent -d MDB &> log5001.txt) &
    (cbserver -port 5002 -r 1 -g public -ia 1 -u nonpersistent -d MDB &> log5002.txt) &

These commands should be placed in the bash script

    startpoolservers.sh

You can edit this script to adapt it to your needs. We assume that the commands are issued on the host computer `cbserver.acme.org`. The load balancer would however also work on `localhost`. The database `MDB` is used in `nonpersistent` mode, i.e.
each pool server is initialized with the database MDB from the file system but then holds it in main memory only. 
The option `-g public` assigns separate workspaces (called modules) to different users assigned to the same pool server.
More options are discussed in section D below.




### (2) To start the load balancer, enter a command like

    ./CBserverLoadBalancer mysecret123 4001 5001 5002

 1. mysecret123: example of a secret key to shut down the load balancer.
 2. 4001: the port to which the load balancer listens for ConceptBase clients connects. This is also the default port number of a ConceptBase server 
 3. 5001: Port number of the first pool server
 4. 5002: Port number of the last pool server

In this simple example, we only use two pool servers. 

### (3) Connections and restarts

ConceptBase clients like CBIva and CBGraph can connect to the service by connecting to `cbserver.acme.org:4001` (or `localhost`). The clients do not see any difference with the behavior of a normal CBserver.

The first message of a client is an ENROLL_ME message. The load balancer will then assign one of the pool
servers to that client and pass the request to the pool server and return its answers back to the client.
The last message of a client is normally a CANCEL_ME message. This will also be passed to the connected pool server, causing it to shutdown and restart (option -r). The pool server is then set to be available again by the load balancer.

The example below shows two different users `mary1` and `billA` who connect to a CBserver load balancer on a fictitious host `cbserver.acme.org` via port 4001. They use the protocol of ConceptBase clients, i.e. they assume that there is a CBserver running on port 4001. Instead, it is the load balancer.  The first client of `mary1` is mapped by the load balancer to the pool `cbserver1` on port 5001. Messages from `cbiva1` are received by the load balancer and passed unchanged to `cbserver1`. The answers go back the reverse direction.

    [mary1@cbiva1]   <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5001) [cbserver1]
    [billA@cbiva2]   <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5002) [cbserver2]
    [mary1@cbgraph1] <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5001) [cbserver1]
    [anne3@cbshell1] <-----> (cbserver.acme.org:4001) [loadbalancer]  <-----> (localhost:5001) [cbserver1]

The fourth line is for the third distinct user `anne3`. Since we only have two pool servers, the client of this user share the pool
server with an existing user, here `mary1`. This is the default behaviour. See section D for more options on
controlling which pool server is assigned to which user.



![Load Balancer architecture](https://gitlab.com/mjeu/conceptbasecc/-/raw/master/ProductPOOL/examples/Clients/LoadBalancer/loadbalancer.svg)

The second client `cbiva2` is for a different user `billA`. It gets another `cbserver2` assigned on port 5002.
Finally, the `cbgraph1` client is again for user `mary1`. It gets `cbserver1` assigned. All clients of the same
user are passed to the same CBserver.

The loadbalancer sniffs into the first packet received by a new client. It is supposed to be an ENROLL_ME (=login message). It contains among others the username. If the server is started with the `-r` option, then the last client connected to that CBserver will trigger
a fresh restart of the CBserver. If the CBserver shall serve a new user, it makes sense to use the `-u nonpersistent` mode for the cbserver. In this scenario, the next new client can then re-use the cbserver, e.g. `cbserver1` on port 5001.


### (4) Shutting down the load balancer

After logging in on the host of the CBserverLoadBalancer, you can stop it with the bash script

    ./stoploadbalancer.sh

Make sure that is stops the same ppol servers that were started by startpoolservers.sh.




### (5) Stopping the pool servers

The pool servers are not shut down automatically when you shutdown the load balancer. 
You need to use the bash script 

    ./stoppoolservers.sh

It is a good idea not to make the portnumbers of the pool servers visible outside `cbserver.acme.org`.




## D. Advanced use of CBserverLoadBalancer

In this scenario, we want that users get their dedicated databases, i.e. when they connect the first time
to the load balancer via a client such as CBIva, then the assigned pool server is memorized in a file and
that assignment will be re-used wben the load balancer is re-started. Hence, if the database of the pool
CBserver is persistent and all programs are restarted, the user still gets assigned the correct database.

### (1) Start a pool of CBservers with consecute port numbers and dedicated databases in persistent mode

    (cbserver -port 5001 -r 1 -u persistent -d MDB5001 &> log5001.txt) &
    (cbserver -port 5002 -r 1 -u persistent -d MDB5002 &> log5002.txt) &
    (cbserver -port 5003 -r 1 -u persistent -d MDB5003 &> log5003.txt) &
    (cbserver -port 5004 -r 1 -u persistent -d MDB5004 &> log5004.txt) &

Note that each CBserver has its own database here and it is started in persistent mode, i.e. the data is permanently stored and not lost when the client disconnects. If you leave out the option `-r 1`, then the CBserver continues to run on the dedicated database. It is however recommended to keep it because it will automatically restart the CBserver in the case of a crash.


### (2) Start the load balancer with user-port mapping file

    ./CBserverLoadBalancer mysecret123 4001 5001 5004 -c userportmap.cfg


A typical user-port mapping file looks like

    mary1@acme-linux:5001
    billA@factor-mac:5002
    anne3@acme-linux:5003
    shar5@solars-win:5004


The file is updated every 60 seconds. If a user logs out, the mapping may be updated with the next user who claims the pool server. 


### (3) Fixed pool servers per user

If you additionally use the command line parameter `-fix`, then the assignment of ports to users is
sticky. Even if the user logs out, the port can only be assigned to clients of the same user.

    ./CBserverLoadBalancer mysecret123 4001 5001 5004 -c userportmap.cfg -fix

This is needed if you want to make sure that a given user always gets assigned to the same pool server
that provides a dedicated ConceptBase database for that user. You can also pre-configure the user-port mapping file before starting the load balancer. It shall then use this assignment to link user clients to the dedicated CBservers.





## E. Known issues

- There are rare cases when a message is lost, either between clients and the load balancer or the load balancer and the pool servers. It seems that this only happens for initial messages.

- The load balancer does not start or restart a pool server. This has to be done by separate bash scrips or terminal commands.

- The messages are not encrypted. There are no passwords used. This is no different to the previous situation where clients directly communicate with a CBserver.












