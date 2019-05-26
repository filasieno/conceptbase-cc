#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/mac/serverSources/C_Files/libtelosServer
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
CurrDir=mac/clientSources/libCB/

# z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=clientSources/libCB

# Die Sourcen
MK_SOURCES=Makefile
C_SOURCES=$(C_SOURCES_IND)

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Compilereinstellungen
INCLUDEDIR+=-I$(POOL_ROOT)/clientSources/libCBview \
	-I$(POOL_ROOT)/clientSources/libCBview/src

LIBCB=$(OBJDIR)/libCB.a
CLEAN_FILES+=$(LIBCB)

CFLAGS+=-DMACOS

#debug=99
ifdef debug
	CFLAGS+=-g -DCBDEBUG -DCBDBLVL=$(debug)
endif

# Die Targets
TARGETS=$(OBJDIR) $(LIBCB)

EXPORTFILES=$(LIBCB)

CLEAN_FILES+=$(OBJDIR)/testlib.o $(OBJDIR)/testlib $(OBJDIR)/testterm.o $(OBJDIR)/testterm

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die mac-Variante der libCB \n\
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \n\
	aufgerufen werden


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)


$(OBJDIR)/testlib: $(OBJECTS) testlib.c
	$(CC) $(LDFLAGS) -o $@ $(OBJDIR)/testlib.o $(LIBCB)

$(OBJDIR)/testterm: $(OBJECTS) testterm.c
	$(CC) $(LDFLAGS) -o $@ $(OBJDIR)/testterm.o $(LIBCB)


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
#include $(word 1,$(wildcard depend.mk src/depend.mk))
