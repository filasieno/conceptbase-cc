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
POOL_ROOT=../../../../..

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
CurrDir=java/i5/cb/workbench/gif/

# Die Sourcen
MK_SOURCES=Makefile

GIFS=CBIva.gif \
	CBIvaS.gif \
	Java.gif \
	ask.gif \
	back.gif \
	clear.gif \
	connect.gif \
	copy.gif \
	cut.gif \
	disconnect.gif \
	exit.gif \
	for.gif \
	frame.gif \
	lpicall.gif \
	open.gif \
	paste.gif \
	redo.gif \
	retell.gif \
	save.gif \
	tell.gif \
	telos.gif \
	untell.gif \
	collapsed.gif \
	expanded.gif

TARGETS=cpgifs
	
# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Gif-Bilder der Workbench

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
