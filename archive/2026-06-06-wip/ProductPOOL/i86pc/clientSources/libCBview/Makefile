#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/i86pc/serverSources/C_Files/libtelosServer
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../../..

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
CurrDir=i86pc/clientSources/libCBview/

# z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=clientSources/libCBview

# Die Sourcen
MK_SOURCES=Makefile
CXX_SOURCES=$(CXX_SOURCES_IND)

# Wo sind die Sourcen
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Compilereinstellungen
INCLUDEDIR+=-I$(POOL_ROOT)/clientSources/libCBview \
	-I$(POOL_ROOT)/clientSources/libCBview/src \
	-I$(POOL_ROOT)/clientSources/libCB \
	-I$(POOL_ROOT)/clientSources/libCB/src
	

LIB=$(OBJDIR)/libCBview.a
CLEAN_FILES+=$(LIB) $(OBJDIR)/testlib $(OBJDIR)/testlib.o

CXXFLAGS+=-DSOLARIS

ifdef debug
	CFLAGS+=-g -DCBDEBUG -DCBDBLVL=$(debug)
endif

# Die Targets
TARGETS=$(OBJDIR) $(LIB)

EXPORTFILES=$(LIB)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die i86pc-Variante der libCBview \n\
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \n\
	aufgerufen werden


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)


$(OBJDIR)/testlib: $(OBJECTS) testlib.cc
	$(CC) $(LDFLAGS) -o $@ $(OBJDIR)/testlib.o $(LIBCB) -L $(POOL_ROOT)/i86pc/clientSources/libCB/$(OBJDIR) -L $(OBJDIR) -lCB -lCBview -lnsl -lsocket -lstdc++

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
#include $(word 1,$(wildcard depend.mk src/depend.mk))
