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
CurrDir=windows/clientSources/libCBview/

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




LIBCBVIEW=$(OBJDIR)/libCBview.$(LIBDLLSUFFIX)
TESTLIB_EXE=$(OBJDIR)/testlib$(EXESUFFIX)

# Building the DLL
#ifeq ($(MAKECMDGOALS),all)
CXXFLAGS=-nologo -MD -W3 -GX -O2 $(INCLUDEDIR) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" -D "_USRDLL" \
	-D "LIBCBVIEW_EXPORTS" -Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c
#endif

# Building testlib.exe
#ifneq ($(MAKECMDGOALS),all)
#CXXFLAGS=-nologo -MT -W3 -GX -O2 $(INCLUDEDIR) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_CONSOLE" -D "_MBCS" \
#    -Fo"$(OBJDIR)\\" /Fd"$(OBJDIR)\\" -c
#endif


ARDLL_FLAGS+=../libCB/$(OBJDIR)/libCB.lib -implib:"$(OBJDIR)/libCBview.lib"

LDFLAGS=kernel32.lib user32.lib wsock32.lib ../libCB/$(OBJDIR)/libCB.lib $(OBJDIR)/libCBview.lib \
   -nologo -subsystem:console -incremental:no -machine:I386


ifdef debug
	CXXFLAGS+=-DCBDEBUG -DCBDBLVL=$(debug)
endif


# Die Targets
TARGETS=$(OBJDIR) $(LIBCBVIEW)

EXPORTFILES=$(LIBCBVIEW) $(OBJDIR)/libCBview.lib

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die windows-Variante der libCBview \n\
	ein CB_Make muss im variantenunabhaengigen Verzeichnis \n\
	aufgerufen werden


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

$(TESTLIB_EXE): $(OBJECTS) testlib.cc
	$(MSVCDir)\bin\link.exe $(LDFLAGS) $(OBJDIR)/testlib.obj -out:"$(OBJDIR)\testlib.exe"

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
include $(word 1,$(wildcard depend.mk src/depend.mk))
