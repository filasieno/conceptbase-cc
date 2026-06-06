#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/linux64/serverSources/C_Files/libtelosServer
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
CurrDir=linux64/clientSources/libtelos/

# z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=clientSources/libtelos

ServerLibDir=serverSources/C_Files/libtelos
# Die Sourcen
MK_SOURCES=Makefile

C_SOURCES=$(C_SOURCES_IND) te_parser.tab.c te_parser.yy.c

# Wo sind die Sourcen
vpath %.c $(POOL_ROOT)/$(ServerLibDir):$(POOL_ROOT)/$(ServerLibDir)/src:$(POOL_ROOT)/linux64/$(ServerLibDir):$(POOL_ROOT)/linux64/$(ServerLibDir)/src
vpath %.h $(POOL_ROOT)/$(ServerLibDir):$(POOL_ROOT)/$(ServerLibDir)/src:$(POOL_ROOT)/linux64/$(ServerLibDir):$(POOL_ROOT)/linux64/$(ServerLibDir)/src

# Compilereinstellungen
INCLUDEDIR+=-I$(POOL_ROOT)/$(ServerLibDir) \
	-I$(POOL_ROOT)/$(ServerLibDir)/src \
	-I$(POOL_ROOT)/linux64/$(ServerLibDir) \
	-I$(POOL_ROOT)/linux64/$(ServerLibDir)/src



LIBTELOS=$(OBJDIR)/libtelos.a
CLEAN_FILES+=$(LIBTELOS) $(OBJDIR)/te_test_access $(OBJDIR)/te_test_access.o

# Die Targets
TARGETS=$(OBJDIR) $(LIBTELOS)

EXPORTFILES=$(LIBTELOS)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die linux64-Variante der libtelos \n\
     diese Lib wird in zwei Varianten erstellt, f’r Server und f’r Client \n\
     hier wird die Client-Lib erstellt, alle Source liegen im Verzeichnis \n\
     $(ServerLibDir)



#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

$(OBJDIR)/te_test_access: $(OBJECTS) te_test_access.c
	$(CC) $(LDFLAGS) -o $@ $(OBJDIR)/te_test_access.o $(LIBTELOS)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
#include $(word 1,$(wildcard depend.mk src/depend.mk))
