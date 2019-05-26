#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/linux64/serverSources/C_Files/libtelos
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
CurrDir=linux64/serverSources/C_Files/libtelos/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libtelos

# Die Sourcen
MK_SOURCES=Makefile
C_SOURCES=$(C_SOURCES_IND)
GEN_C_SOURCES=te_parser.tab.c te_parser.tab.h te_parser.yy.c

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.l .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.y .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Compilereinstellungen
# . und src/.. werden includiert, weil dort die Header-
# Dateien von Lex und Yacc liegen
CFLAGS+=-Wno-unused -DCBSERVER


# Prefixe fuer flex und bison
LPREFIX=te_parser_
YPREFIX=te_parser_

LIB=$(OBJDIR)/libtelos.a
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
