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
CurrDir=windows/clientSources/libtelos/

# z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=clientSources/libtelos

ServerLibDir=serverSources/C_Files/libtelos

# Die Sourcen
MK_SOURCES=Makefile

C_SOURCES=$(C_SOURCES_IND) te_parser.tab.c te_parser.yy.c

# Wo sind die Sourcen
vpath %.c $(POOL_ROOT)/$(ServerLibDir):$(POOL_ROOT)/$(ServerLibDir)/src:$(POOL_ROOT)/windows/$(ServerLibDir):$(POOL_ROOT)/windows/$(ServerLibDir)/src
vpath %.h $(POOL_ROOT)/$(ServerLibDir):$(POOL_ROOT)/$(ServerLibDir)/src:$(POOL_ROOT)/windows/$(ServerLibDir):$(POOL_ROOT)/windows/$(ServerLibDir)/src



LIBTELOS=$(OBJDIR)/libtelos.$(LIBDLLSUFFIX)
TESTLIB_EXE=$(OBJDIR)/te_test_access$(EXESUFFIX)

# Compilereinstellungen
INCLUDEDIR+=-I$(POOL_ROOT)/$(ServerLibDir) \
	-I$(POOL_ROOT)/$(ServerLibDir)/src \
	-I$(POOL_ROOT)/windows/$(ServerLibDir) \
	-I$(POOL_ROOT)/windows/$(ServerLibDir)/src

# Building the DLL
#ifeq ($(MAKECMDGOALS),all)
CFLAGS=-nologo -MD -W3 -GX -O2 $(INCLUDEDIR) -D "YY_NO_UNISTD_H" -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" -D "_USRDLL" \
	-D "LIBTELOS_EXPORTS" -Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c
#endif

# Building testlib.exe or testterm.exe
#ifneq ($(MAKECMDGOALS),all)
#CFLAGS=-nologo -MT -W3 -GX -O2 $(INCLUDEDIR) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_CONSOLE" -D "_MBCS" \
#    -Fo"$(OBJDIR)\\" /Fd"$(OBJDIR)\\" -c
#endif

LIBTELOS_DEF=$(word 1,$(wildcard libtelos.def $(SRCDIR)/libtelos.def))

ARDLL_FLAGS+=-def:"$(LIBTELOS_DEF)" -implib:"$(OBJDIR)/libtelos.lib"

LDFLAGS=kernel32.lib user32.lib wsock32.lib $(OBJDIR)/libtelos.lib \
   -nologo -subsystem:console -incremental:no -machine:I386


ifdef debug
	CFLAGS+=-DCBDEBUG -DCBDBLVL=$(debug)
endif

# Die Targets
TARGETS=$(OBJDIR) $(LIBTELOS)

EXPORTFILES=$(LIBTELOS) $(OBJDIR)/libtelos.lib

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die windows-Variante der libtelos \n\
     diese Lib wird in zwei Varianten erstellt, f’r Server und f’r Client \n\
     hier wird die Client-Lib erstellt, alle Source liegen im Verzeichnis \n\
     $(ServerLibDir)


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

$(TESTLIB_EXE): $(OBJECTS) te_test_access.c
	$(MSVCDir)\bin\link.exe $(LDFLAGS) $(OBJDIR)/te_test_access.obj -out:"$(OBJDIR)\te_test_access.exe"


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
#include $(word 1,$(wildcard depend.mk src/depend.mk))
