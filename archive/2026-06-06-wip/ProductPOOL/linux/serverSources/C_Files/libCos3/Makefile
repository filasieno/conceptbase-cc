#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/linux/serverSources/C_Files/libCos3
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../../../..

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
CurrDir=linux/serverSources/C_Files/libCos3/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libCos3

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.x .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Sourcen
MK_SOURCES=Makefile


# Compiler-Flags
#CXX		=/usr/bin/g++
INCLUDEDIR	+=-I$(PL_HOME)/include

LIBS_TRANSFORM	=-lstdc++ -lm
LIBS_AUSLESEN	=-lstdc++ -lm
#LIBS_TRANSLATE  =
LIBS_OBJSTORE	=-lnsl -lsocket -lstdc++ -lm

CDEFS		=-D$(PROLOG_VARIANT) #-DDEBUG -DDLEVEL=0
#CFLAGS		=$(CDEFS) -Wall $(PROFILEFLAGS) $(DEBUGFLAGS) $(INCLUDEDIR)
CFLAGS		=-O2 -Wall $(INCLUDEDIR) $(CDEFS)
CXXFLAGS	=$(CFLAGS)
LDFLAGS		=-O2 -Wall


# Targets
TARGETS=$(OBJDIR) $(OBJDIR)/libCos.a \
	$(OBJDIR)/transform \
	$(OBJDIR)/auslesen
#	$(OBJDIR)/translate

CLEAN_FILES=$(OBJECTS) $(filter-out $(OBJDIR),$(TARGETS))

# Dateien, die nach EXPORT kopiert werden sollen
# RPC-Version wird nicht exportiert, da nur fuer Debugging sinnvoll
EXPORTFILES=$(OBJDIR)/libCos.a

# Kurze Beschreibung der Komponente
INFO_TXT= Verzeichnis fuer die ObjektSpeicher-Library vom CB-Server \n\
	CB_Make ohne Argumente erstellt die normale Version der libCos\n\
	CB_Make transform erstellt das transform (konv. OB.prop von 3.4 nach 4.0) \n\
	CB_Make auslesen erstellt das auslesen-Programm \n



#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

# Regeln fuer die Libraries sind in rules.mk

# Regel fuer Konverterierungsprogramm transform
$(OBJDIR)/transform: $(OBJDIR) $(CXX_OBJECTS) $(OBJDIR)/transform.$(OBJSUFFIX)
	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
	$(LIBS_TRANSFORM)

# Regel fuer das Ausleseprogramm auslesen
$(OBJDIR)/auslesen: $(OBJDIR) $(CXX_OBJECTS) $(OBJDIR)/auslesen.$(OBJSUFFIX)
	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
	$(LIBS_AUSLESEN)


# Object-Files fuer die Libraries nicht loeschen
.PRECIOUS: $(TARGETS)


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
include $(word 1,$(wildcard depend.mk src/depend.mk))

