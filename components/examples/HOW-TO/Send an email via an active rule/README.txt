
*********************************
Sending an email from ConceptBase
*********************************

Manfred Jeusfeld, 21-Aug-2007
last update: 19-Sep-2014


This example show how to send an email by a ConceptBase active rule.
The example require Linux/Unix as host operation system for the ConceptBase server.
The host operating system must have the sendmail utility installed at /usr/sbin.
The example is written for ConceptBase 7.0.

The example is provided as is and without warranty of any type.



Files
*****

01-ecamail.sml
  Definitions of the scenario of the example. The scenerio is taken from conference management
  where some forms are submitted to the ConceptBase server. In this case, we are interested
  in the form type "AbstractSubmission". The active rule is called MailObjectOnFormSubmission.
  Every type a form of type AbstractSubmission is inserted to the ConceptBase database, it will
  mail the content to all 'members' who have subscribed to "AbstractSubmission".
  Edit the email address of the members to a known email address, e.g. your own.

02-trigger.sml
  An example abstract submission. Tell this file to trigger the active rule.

SENDMAIL.swi.lpi
  Plug-in for the ConceptBase server to allow it to call the sendmail utility.
  


Script to test the functionality
********************************

1. Edit the file 01-ecamail and replace the member 'johndoe@erath.universe.org' 
   by an appropriate email address, e.g. your own.

2. Start the cbserver 
     cbserver -d MYDB

3. Start the ConceptBase user interface cbiva, connect to the cbserver and load the model
   01-ecamail.sml

4. Stop the CBserver via cbiva

5. Copy the SENDMAIl plug-in to the database created before
     cp SENDMAIL.swi.lpi MYDB

6. Start the cbserver again
     cbserver -d MYDB

7. Start the ConceptBase user interface, connect to the cbserver and load the model
   02-trigger.sml

==> An email should be sent to the persons subscribed to "AbstractSubmission" (see file 01-ecamail.sml)




