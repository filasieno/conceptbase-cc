#!/bin/sh
# startCBserver.sh  (for Linux/Solaris/Mac-OS X)
# ----------------------------------------------------------------------
# Script to start the ConceptBase server without having to set
# CB_HOME in advance.
# See doc/TechInfo/InstallationGuide.txt for more details.
# Other than the standard script bin/CBserver, this script also
# works without installing ConceptBase on a computer system.
# To start the script enter the following commands into a shell window
#    cd <CB_HOME>
#    ./startCBserver.sh
#



#*** CB_HOME is the Directory where the ConceptBase Kernel System is installed
CB_HOME=`dirname $0`
export CB_HOME

"$CB_HOME/bin/CBserver" "$@"

