README.txt
for installing individual workspaces in ConceptBase


Manfred Jeusfeld, 18-Sep-2007 (4-Feb-2014)


Step 1: Start a CBserver with regular security
  % cbserver -d MYDB

Step 2: Start CBiva and tell the file OwnerProtect.sml to the CBserver
  in module oHome (default)

Step 3: Stop the CBserver

Afterwards you can re-start the CBserver in secure mode:

   % cbserver -s 2 -d MYDB

Users will get individual workspaces. They can do anything within their workspace,
even create submodules. But they can never switch to another user's workspace.
Well, at least it's not so easy ...