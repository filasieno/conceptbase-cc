#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/i86pc/serverSources/C_Files/libCos
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
CurrDir=i86pc/serverSources/C_Files/libCos/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libCos

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.x .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Sourcen
MK_SOURCES=Makefile

# Diese Dateien werden durch rpcgen mit rpc_idef.x erstellt
RPC_GENERATED=rpc_idef.h \
			rpc_idef_svc.c \
			rpc_idef_clnt.c \
			rpc_idef_xdr.c

# Alle anderen Source-Files werden ueber Parameter gesetzt


# Compiler-Flags
CXX			=$(CC)
INCLUDEDIR	+=-I$(BIM_PROLOG_DIR)/include

LIBS_TRANSFORM	=-lg++ -lstdc++
LIBS_AUSLESEN	=-lg++ -lstdc++
#LIBS_TRANSLATE  =-lg++
LIBS_OBJSTORE	=-lg++ -lnsl -lsocket -lstdc++

CDEFS		=-DDEBUG -DDLEVEL=0 -DALGEBRA
CFLAGS		=$(CDEFS) -Wall -O2 $(PROFILEFLAGS) $(DEBUGFLAGS) $(INCLUDEDIR)
CXXFLAGS	=$(CFLAGS)
LDFLAGS		=-Wall


# Zusaetzliche Compiler-Flags fuer Profiling und Debugging
ifdef profile
PROFILEFLAGS= -p
C_OBJECTS+=$(GCC_LIB_DIR)/gmon.o
endif

ifdef debug
DEBUGFLAGS=-g
endif

# Targets
TARGETS=$(OBJDIR) $(OBJDIR)/libCos.a \
	$(OBJDIR)/transform \
	$(OBJDIR)/auslesen
#	$(OBJDIR)/translate

CLEAN_FILES=$(OBJECTS) $(filter-out $(OBJDIR),$(TARGETS)) $(RPC_GENERATED)

# Dateien, die nach EXPORT kopiert werden sollen
# RPC-Version wird nicht exportiert, da nur fuer Debugging sinnvoll
EXPORTFILES=$(OBJDIR)/libCos.a

# Kurze Beschreibung der Komponente
INFO_TXT= Verzeichnis fuer die ObjektSpeicher-Library vom CB-Server \n\
	CB_Make ohne Argumente erstellt die normale Version der libCos\n\
	CB_Make rpc erstellt eine libCosRPC und objstore, \n\
	CB_Make transform erstellt das transform (konv. OB.prop von 3.4 nach 4.0) \n\
	CB_Make auslesen erstellt das auslesen-Programm \n\
	CB_Make profile=x debug=x erstellt die Library mit Debug/Profile-Info, \n\
	CB_Make rpcgen erstellt die RPC-Dateien mit rpcgen.\n\



#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

# Regeln fuer die Libraries sind in rules.mk

# Regel fuer objstore
$(OBJDIR)/objstore: $(OBJDIR) $(C_OBJECTS) $(CXX_OBJECTS)
	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
	$(LIBS_OBJSTORE)

# Regel fuer Konverterierungsprogramm transform
$(OBJDIR)/transform: $(OBJDIR) $(C_OBJECTS) $(CXX_OBJECTS)
	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
	$(LIBS_TRANSFORM)

# Regel fuer das Ausleseprogramm auslesen
$(OBJDIR)/auslesen: $(OBJDIR) $(C_OBJECTS) $(CXX_OBJECTS)
	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
	$(LIBS_AUSLESEN)

# Regel fuer das Konvertierungsproggie translate2.1-3.1
#$(OBJDIR)/translate: $(OBJDIR) $(C_OBJECTS) $(CXX_OBJECTS)
#	$(CC) $(LDFLAGS) $(PROFILEFLAGS) $(DEBUGFLAGS) -o $@ \
#	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
#	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile))) \
#	$(LIBS_TRANSLATE)


# Object-Files fuer die Libraries nicht loeschen
.PRECIOUS: $(TARGETS)


# Regeln fuer die rpcgen-erierten Dateien
rpcgen: $(RPC_GENERATED)

$(RPC_GENERATED): rpc_idef.x
	$(SYMLINK) $< rpc_idef.x
	rpcgen -K 600 rpc_idef.x
	$(RM) rpc_idef.x

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
include $(word 1,$(wildcard depend.mk src/depend.mk))

