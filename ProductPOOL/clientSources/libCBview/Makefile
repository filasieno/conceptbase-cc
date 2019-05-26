#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/clientSources/libCB
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../..

# Wo sind die Makefiles
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
CurrDir=clientSources/libCBview/

# Die Sourcen
MK_SOURCES=Makefile
CXX_SOURCES=CBanswer.cc \
	CBclient.cc \
	CBerror.cc \
	CBviewDll.cc

DOCPPFILES=CBanswer.h \
	CBclient.h \
	CBerror.h


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Verzweige fuer alle Targets in das Varianten-Verzeichnis
all .DEFAULT:
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES_IND="$(CXX_SOURCES)" \
	DOCPPFILES="$(DOCPPFILES)" \
	$@

testlib:
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES_IND="testlib.cc" \
	$(OBJDIR)/testlib$(EXESUFFIX)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
# hier nicht includen, da variantenabhaengig

#---------------------------------------
# Dependencies
#---------------------------------------
