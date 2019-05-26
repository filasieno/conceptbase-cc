#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/lib/Makefile,v $
# Version:     $Revision: 1.2 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2002/10/04 13:40:57 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/lib
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=..

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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=lib/

# Die Sourcen
MK_SOURCES=Makefile


# Die Dateien, die nach EXPORT kopiert werden

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=ehemals Verzeichnis fuer die Perl-Module

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
