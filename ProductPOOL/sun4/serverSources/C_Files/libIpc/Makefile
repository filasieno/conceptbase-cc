#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/sun4/serverSources/C_Files/libIpc
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
CurrDir=sun4/serverSources/C_Files/libIpc/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libIpc

# Die Sourcen
MK_SOURCES=Makefile
C_SOURCES=$(C_SOURCES_IND)
GEN_C_SOURCES=IpcParser.tab.c IpcParser.tab.h IpcParser.yy.c

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.l .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.y .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Compilereinstellungen

# Fuer C-Files nehmen wir hier ausnahmsweise g++
CC=$(CXX)
CFLAGS+=-Wno-unused

# Prefixe fuer flex und bison
LPREFIX=Ipc
YPREFIX=Ipc

LIB=$(OBJDIR)/libIpc.$(LIBSUFFIX)
CLEAN_FILES+=$(LIB) $(GEN_C_SOURCES)

# Die Targets
TARGETS=$(OBJDIR) $(LIB)

EXPORTFILES=$(LIB)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die libtelosServer vom CB-Server; \n\
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \n\
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
