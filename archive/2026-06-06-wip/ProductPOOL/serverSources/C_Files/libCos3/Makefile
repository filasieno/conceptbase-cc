#
#
# File:        Makefile
# Version:     10.3
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: 05/22/96 , Christoph Quix (RWTH)
# Release:     10
#
# -----------------------------------------
# Makefile fuer $CB_POOL/serverSources/C_Files/libCos3
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../../..

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
CurrDir=serverSources/C_Files/libCos3/

# Die Sourcen
MK_SOURCES=Makefile

# Gehoeren zu libCos3, objstore und transform

CXX_SOURCES_IND=secure_put.cc\
	SYMTBL.cc SYMID.cc \
	TOID.cc SYMIDSTLSET.cc \
	Statistic.cc StatisticHashSet.cc \
	Statistics.cc trans.cc\
	TOBJ.cc TDB.cc TDB_testall.cc QUERY.cc\
	TIMELINE.cc TIMEPOINT.cc\
	TOIDREF.cc TOIDREFHashSet.cc \
	SYMIDREF.cc SYMIDREFHashSet.cc   \
	Literals.cc builtin.cc error.cc TOIDSETSTL.cc \
	longSETSTL.cc


# Sourcen, die nur zur normalen libCos3 gehoeren
C_INTERFACE_SRC=bim2c.c objstore.c

ifeq "$(PROLOG_VARIANT)" "SWI"
C_INTERFACE_SRC+= swiCos.c
endif

# Gehoert zur normalen libCos3 und zu transform
CXX_INTERFACE_SRC=trans.cc

# Gehoert nur zu transform
CXX_TRANSFORM=transform.cc

# Gehoert nur zu aus auslesen
CXX_AUSLESEN=auslesen.cc

# Gehoert nur zu translate2.1-3.1
CXX_TRANSLATE=translate.cc

# Die Targets
TARGETS=transform
#TARGETS=transform auslesen
#TARGETS=startAlg

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die ObjektSpeicher-Library vom CB-Server; \n\
	ein CB_Make ohne Argumente compiliert alle C-Dateien \n\
	im Variantenzweig

DOCPPFILES=TDB.h TOBJ.h TOID.h TOIDSET.h SYMTBL.h SYMID.h TIMELINE.h TIMEPOINT.h

CXX_SOURCES=$(CXX_SOURCES_IND)
C_SOURCES=$(C_INTERFACE_SRC)
export CXX_SOURCES
export C_SOURCES

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Verzweige fuer alle Targets in das Varianten-Verzeichnis
# make ohne Target erzeugt die normale libCos.a

all: $(TARGETS)
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$(OBJDIR)/libCos.$(LIBSUFFIX)

#---------------------------------------
# transform: Programm zur Konvertierung der OB.prop-Dateien
# von CBserver3.4 nach OB.telos und OB.symbol von CBserver4.x
# und zur Konvertierung von SML0.prop (Basisobjekte, daher wichtig!)
transform:
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$(OBJDIR)/transform$(EXESUFFIX)

#---------------------------------------
# auslesen: liest das OB.telos file aus
auslesen:
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$(OBJDIR)/auslesen$(EXESUFFIX)


# Fuer clean oder aehnliches wird ebenfalls verzweigt
.DEFAULT:
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@

export: all
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@

FORCE:

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
# hier nicht includen, da variantenabhaengig

#---------------------------------------
# Dependencies
#---------------------------------------
