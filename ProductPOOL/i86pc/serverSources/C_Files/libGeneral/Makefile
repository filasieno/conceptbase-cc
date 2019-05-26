#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/i86pc/serverSources/C_Files/libGeneral
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../../../..

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
CurrDir=i86pc/serverSources/C_Files/libGeneral/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libGeneral

# Die Sourcen
MK_SOURCES=Makefile
C_SOURCES=$(C_SOURCES_IND) UnixFileSys.c
CXX_SOURCES=$(CXX_SOURCES_IND)

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Compilereinstellungen
INCLUDEDIR+=-I$(BIM_PROLOG_DIR)/include

CFLAGS+=-DOS=SUNOS \
	-DOS_VERSION=54

LIB=$(OBJDIR)/libGeneral.a
CLEAN_FILES+=$(LIB)

# Die Targets
TARGETS=$(OBJDIR) $(LIB)

EXPORTFILES=$(LIB)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die libGeneral vom CB-Server; \
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \
	aufgerufen werden


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
include $(word 1,$(wildcard depend.mk src/depend.mk))
