#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
# Date released : %E%  (YY/MM/DD)
#
# SCCS-Source-Pool : %P%
# Date retrieved : %D% (YY/MM/DD)
#
# -----------------------------------------
# Makefile fuer $CB_POOL/clientSources
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../..

# Namen der Makefiles 
CONFIG_MK=$(word 1,$(wildcard $(POOL_ROOT)/config.mk $(POOL_ROOT)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(POOL_ROOT)/rules.mk $(POOL_ROOT)/src/rules.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=cb

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=java/i5/

# Die Sourcen
MK_SOURCES=Makefile

JAVA_SOURCES=$(notdir $(wildcard $(CB_POOL)/$(CurrDir)$(SRCDIR)/*.java))

TARGETS=compilejava

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Java-Source-Codes der Clients und \n\
	Programmierbibliotheken fuer ConceptBase
	
#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(TARGETS) $(MAKE_DIRS) 


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)


#---------------------------------------
# Dependencies
#---------------------------------------
