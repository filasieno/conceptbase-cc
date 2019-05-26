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
# Makefile fuer $CB_POOL/serverSources
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
SubDirs=Prolog_Files C_Files

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=serverSources/

# Die Sourcen
MK_SOURCES=Makefile


TARGETS=link_server

CB_OPTIONS=

# Datum setzen, wird bei copyright-notice ausgegeben
ifeq "$(CB_VARIANT)" "windows"
  CB_DATE:=$(shell $(WINADM)\date '+%Y-%m-%d')
  export CB_DATE
else
  CB_DATE:=$(shell date '+%Y-%m-%d')
  export CB_DATE
endif

export CB_POOL

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Source-Codes vom CB-Server; \n\
	Prolog-Dateien und C-Dateien werden getrennt verwaltet; \n\
	ein CB_Make ohne Argumente compiliert beide Zweige \n\
	CB_Make link_server linkt einen Server (Default-Target) \n\
	Wenn CB_Make mit der Option FAST=1 (oder CBserver -i fast) gestartet wird, \n\
	dann wird der Server direkt gestartet bzw. gelinkt ohne \n\
	die Komponenten in den Subdirectories zu ueberpruefen. \n\
	CB_Make iserver startet einen interaktiven Server, \n\
	aber es ist besser den interaktiven Server ueber das \n\
	CBserver-Skript zu starten.

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)



.DEFAULT:
	$(MAKE) -$(MAKEFLAGS)\
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@


# Wenn bei CB-Option -i "fast" angegeben wird,
# wird die Variable FAST gesetzt (s.u.)
ifeq "$(findstring -i fast,$(CB_OPTIONS))" "-i fast"
FAST=1
endif

# Wenn die Variable FAST gesetzt ist, verzichten wir auf ein
# Make in allen Subdirectories
ifndef FAST
iserver link_server: $(MAKE_DIRS)
	$(MAKE) -$(MAKEFLAGS) CB_OPTIONS="$(CB_OPTIONS)"\
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@
else
iserver link_server:
	$(MAKE) -$(MAKEFLAGS) CB_OPTIONS="$(CB_OPTIONS)"\
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@
endif

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

# Die Regel fuer export wird hier ueberschrieben,
# damit cbRTexec und cbRTdata im Variantenverzeichnis
# erzeugt und exportiert werden (gleiches gilt fuer clean)
export: $(EXPORT_DIRS)
	$(MAKE) -$(MAKEFLAGS)\
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@

clean: $(CLEAN_DIRS)
	$(MAKE) -$(MAKEFLAGS)\
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@



#---------------------------------------
# Dependencies
#---------------------------------------
