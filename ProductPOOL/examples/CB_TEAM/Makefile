#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/examples/CB_TEAM
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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=examples/CB_TEAM/

# Die Sourcen
MK_SOURCES=Makefile
SML_FILES=cbteam.sml
BITMAPS=cb.xpm \
	christophQ.xpm \
	christophR.xpm \
	claudia.xpm \
	hans.xpm \
	kai.xpm \
	manfred.xpm \
	markus.xpm \
	martin.xpm \
	rainer.xpm \
	rene.xpm \
	stefan.xpm \
	thomas.xpm

# Dateien, die nach EXPORT kopiert werden sollen
EXPORTFILES=$(SML_FILES) \
	$(BITMAPS) \
	README

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer das CB-Team-Beispiel

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
