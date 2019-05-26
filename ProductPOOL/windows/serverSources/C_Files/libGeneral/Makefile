#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/serverSources/C_Files/libGeneral
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
CurrDir=windows/serverSources/C_Files/libGeneral/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libGeneral

# Die Sourcen
MK_SOURCES=Makefile
C_SOURCES=$(C_SOURCES_IND) WinFileSys.c
CXX_SOURCES=$(CXX_SOURCES_IND)

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

INCLUDEDIR	+=-I "$(MSVCDir)\INCLUDE\stlport"
INCLUDEDIR      +=-I "$(MSVCDir)\INCLUDE"
INCLUDEDIR      +=-I "$(MSVCDir)\MFC\INCLUDE"
INCLUDEDIR      +=-I "$(MSVCDir)\ATL\INCLUDE"

# Compilereinstellungen

CFLAGS=-nologo -MD -W3 -GX -O2 $(INCLUDEDIR) -D $(PROLOG_VARIANT) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" -D "_LIB" \
	-Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c
CXXFLAGS=-nologo -MD -W3 -GX -X  $(subst /,\,$(INCLUDEDIR)) -D $(PROLOG_VARIANT) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" \
	-D "_LIB" -Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c

LIBGENERAL=$(OBJDIR)/libGeneral.$(LIBSUFFIX)

# Die Targets
TARGETS=$(OBJDIR) $(LIBGENERAL)

EXPORTFILES=$(OBJDIR)/*.$(LIBSUFFIX)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die libGeneral vom CB-Server


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
