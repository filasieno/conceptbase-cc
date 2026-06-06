Using CBshell in a Unix pipe

Manfred Jeusfeld, 2012-08-22
This example shows how to employ CBshell in a Unix pipe.
The generator script
  printfiles4cbshell
generates CBshell commands that are passed to CBshell:

  printfiles4cbshell | cbshell -p

The parameter -p prepares CBshell for the pipe mode. It basically
turns off the display of the command line prompt.

You need to start a CBserver on localhost, port 4001, before
invoking the above command. It is most convenient to do
so by CBiva and loading the Telos file FileModel.sml
into the CBserver.

Afterwards, you can analyse the data, e.g. by asking for the instances of 
the class File or by evaluating the function dirSize.



Alternative:

  dirsize <dir>
  This shell script invokes gendirsize and passes its output to
  CBshell. There is no need to start a CBserver in advance.
  The shell script gendirsize generates a CBshell script that
  computes the directory size.






