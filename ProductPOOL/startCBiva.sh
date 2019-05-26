#!/bin/sh

# startCBiva.sh  (for Linux/Unix/Mac-OS X)
# ----------------------------------------------------------------------
# This script allows to start the ConceptBase user interface without prior
# installation of ConceptBase on the local computer.
# See doc/TechInfo/InstallationGuide.txt for more details.
# Can be started in s shell window by
#    cd <CB_HOME>
#    startCBiva.sh
# It is assumed that the program java is in the call path.
# Otherwise, pre-pend the absolute call path of java
# 25-Aug-2004 (11-Jan-2006), M. Jeusfeld


cd `dirname $0`
CB_HOME=`pwd`
export CB_HOME

#default for java is the one found in the search path
JAVAEXEC=java

# take java5 if installed; 
if [ -x /usr/lib/jvm/java-1.5.0-sun/bin/java ]; then
  JAVAEXEC=/usr/lib/jvm/java-1.5.0-sun/bin/java
fi
# take openjdk6 if installed;
if [ -x /usr/lib/jvm/java-6-openjdk/bin/java ]; then
  JAVAEXEC=/usr/lib/jvm/java-6-openjdk/bin/java
fi
# take jdk6_7 if installed
if [ -x /opt/jdk1.6.0_7/bin/java ]; then
  JAVAEXEC=/opt/jdk1.6.0_7/bin/java
fi
# take jdk6_10 if installed
if [ -x /opt/jdk1.6.0_10/bin/java ]; then
  JAVAEXEC=/opt/jdk1.6.0_10/bin/java
fi
# take opt/jre6_10 if installed
if [ -x /opt/jre1.6.0_10/bin/java ]; then
  JAVAEXEC=/opt/jre1.6.0_10/bin/java
fi
# take $HOME/jre6_10 if installed
if [ -x $HOME/jre1.6.0_10/bin/java ]; then
  JAVAEXEC=$HOME/jre1.6.0_10/bin/java
fi
# take $CB_HOME/jre6_10 if installed
if [ -x $CB_HOME/jre1.6.0_10/bin/java ]; then
  JAVAEXEC=$CB_HOME/jre1.6.0_10/bin/java
fi

# display Java version; helps with debugging
$JAVAEXEC -version
exec $JAVAEXEC -DCB_HOME="$CB_HOME" -jar "$CB_HOME/lib/classes/cb.jar"


