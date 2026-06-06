#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/Makefile,v $
# Version:     $Revision: 2.3 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2004/06/25 13:40:02 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=.

# Namen der Makefiles
CONFIG_MK=$(word 1,$(wildcard $(CB_POOL)/config.mk $(CB_POOL)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(CB_POOL)/rules.mk $(CB_POOL)/src/rules.mk))

# Makefile fuer die spezifischen Variablen und Regeln fuer den Admin-Pool
ADMIN_MK=$(word 1,$(wildcard $(POOL_ROOT)/admin.mk $(POOL_ROOT)/src/admin.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=bin lib distrib doc utils crontabs web

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=

# Die Sourcen
MK_SOURCES=Makefile admin.mk

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=Wurzel-Verzeichnis des AdminPOOLs; \n\
	ein CB_Make ohne Argumente ruft die Makefiles in den Subdirectories auf; \n\
	ein CB_Make mit einem Directory als Argument ($(SubDirs)) \n\
	legt das entsprechende Verzeichnis im Pool an

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)



#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

include $(ADMIN_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
