#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/serverSources/C_Files/libtelosServer
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
CurrDir=windows/clientSources/libCB/

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

LIBCB=$(OBJDIR)/libCB.$(LIBDLLSUFFIX)
TESTLIB_EXE=$(OBJDIR)/testlib$(EXESUFFIX)
TESTTERM_EXE=$(OBJDIR)/testterm$(EXESUFFIX)

# Building the DLL
#ifeq ($(MAKECMDGOALS),all)
CFLAGS=-nologo -MD -W3 -GX -O2 $(INCLUDEDIR) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" -D "_USRDLL" \
	-D "LIBCB_EXPORTS" -Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c
#endif

# Building testlib.exe or testterm.exe
#ifneq ($(MAKECMDGOALS),all)
#CFLAGS=-nologo -MT -W3 -GX -O2 $(INCLUDEDIR) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_CONSOLE" -D "_MBCS" \
#    -Fo"$(OBJDIR)\\" /Fd"$(OBJDIR)\\" -c
#endif

LIBCB_DEF=$(word 1,$(wildcard libcb.def $(SRCDIR)/libcb.def))
ARDLL_FLAGS+=-def:"$(LIBCB_DEF)" -implib:"$(OBJDIR)/libCB.lib"

LDFLAGS=kernel32.lib user32.lib wsock32.lib $(OBJDIR)/libCB.lib \
 -nologo -subsystem:console -incremental:no -machine:I386


ifdef debug
	CFLAGS+=-DCBDEBUG -DCBDBLVL=$(debug)
endif

# Die Targets
TARGETS=$(OBJDIR) $(LIBCB)

EXPORTFILES=$(LIBCB) $(OBJDIR)/libCB.lib

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die windows-Variante der libCB \n\
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \n\
	aufgerufen werden


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

$(TESTLIB_EXE): $(OBJECTS) testlib.c
	$(MSVCDir)\bin\link.exe $(LDFLAGS) $(OBJDIR)/testlib.obj -out:"$(OBJDIR)\testlib.exe"

$(TESTTERM_EXE): $(OBJECTS) testterm.c
	$(MSVCDir)\bin\link.exe $(LDFLAGS) $(OBJDIR)/testterm.obj -out:"$(OBJDIR)\testterm.exe"

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
#include $(word 1,$(wildcard depend.mk src/depend.mk))
