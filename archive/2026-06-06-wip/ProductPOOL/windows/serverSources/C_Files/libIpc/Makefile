#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/serverSources/C_Files/libIpc
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
CurrDir=windows/serverSources/C_Files/libIpc/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libIpc

# Die Sourcen
MK_SOURCES=Makefile
GEN_C_SOURCES=IpcParser.tab.c IpcParser.yy.c IpcParser.tab.h
C_SOURCES=$(C_SOURCES_IND)

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.l .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.y .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src



# Fuer C-Files nehmen wir hier ausnahmsweise g++
CFLAGS=-TP -nologo -MD -W3 -GX -O2 $(INCLUDEDIR) -D $(PROLOG_VARIANT) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" -D "_LIB" \
	-Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c


# Prefixe fuer flex und bison
LPREFIX=Ipc
YPREFIX=Ipc

LIBIPC=$(OBJDIR)/libIpc.$(LIBSUFFIX)

CLEAN_FILES+=IpcParser.tab.c IpcParser.tab.h IpcParser.yy.c

# Die Targets
TARGETS=$(OBJDIR) $(LIBIPC)

EXPORTFILES=$(OBJDIR)/*.$(LIBSUFFIX)

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
