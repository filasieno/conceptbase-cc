#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/man
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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=man/

# Die Sourcen
MK_SOURCES=Makefile

# Targets
TARGETS=

# Dateien, die nach EXPORT kopiert werden sollen
EXPORTFILES=

# Kurze Beschreibung der Komponente
INFO_TXT=Man-Pages zu ConceptBase

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
