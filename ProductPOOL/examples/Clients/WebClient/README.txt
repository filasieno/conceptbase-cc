ConceptBase Web Client

Manfred Jeusfeld
2025-11-22


Most of the code was generated with the help of an LLM based on the source code of LocalCBClient.java

License for the source code in this directory: CC-BY 4.0





Compile the ConceptBaseGateway
==============================

javac -classpath $HOME/conceptbase/lib/classes/cb.jar ConceptBaseGateway.java


Start ConceptBase and the Gateway

cbserver -t low -sm slave & 
java -classpath $HOME/conceptbase/lib/classes/cb.jar:. ConceptBaseGateway

The ConceptBaseGateway needs to be terminated by CTRL-C


Start CB-WebClient.html
=======================

Just open the HTML file in a browser on the same computer that runs the ConceptBaseGateway

The CB-WebClient currently only supports frames in one line. Multiple lines have the newline replaced by \n,
which is not understood by the ConceptBase server.




