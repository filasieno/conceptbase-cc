ConceptBase Web Client

Manfred Jeusfeld
2025-11-22 (2025-11-23)


Most of the code was generated with the help of an LLM based on the source code of LocalCBClient.java

License for the source code in this directory: CC-BY 4.0





1. Compile the ConceptBaseGateway
=================================

javac -classpath $HOME/conceptbase/lib/classes/cb.jar ConceptBaseGateway.java


2. Start ConceptBase and the Gateway
====================================

cbserver -t low -sm slave & 
java -classpath $HOME/conceptbase/lib/classes/cb.jar:. ConceptBaseGateway

The ConceptBaseGateway later needs to be terminated by CTRL-C


3. Start the Web Client
=======================

Open the HTML file in a browser on the same computer that runs the ConceptBaseGateway.
There are two variants

- CB-WebClient.html : The first version
- CB-WebClient.html2: A slightly more sophisticated version that has separate buttons for TELL, UNTELL, ASK, CLEAR and LIST








