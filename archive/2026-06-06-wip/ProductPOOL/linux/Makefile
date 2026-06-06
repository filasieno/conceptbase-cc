#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/linux
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=..

# Namen der Makefiles 
CONFIG_MK=$(word 1,$(wildcard $(POOL_ROOT)/config.mk $(POOL_ROOT)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(POOL_ROOT)/rules.mk $(POOL_ROOT)/src/rules.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=serverSources bin clientSources

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=linux/

NotVariantDir=.

# Die Sourcen
MK_SOURCES=Makefile

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die linux-Variante

# Nicht in die SubDirectories verzweigen
override EXPORT_DIRS=
override CLEAN_DIRS=
override MAKE_DIRS=

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make NICHT in allen Subdirectories aufrufen
all: 


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
