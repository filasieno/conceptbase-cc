#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/serverSources/C_Files/libCos2
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
CurrDir=windows/serverSources/C_Files/libCos2/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/C_Files/libCos2

# Wo sind die Sourcen
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.cc .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.h .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.x .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Sourcen
MK_SOURCES=Makefile


# Alle anderen Source-Files werden ueber Parameter gesetzt


# Compiler-Flags
INCLUDEDIR	+=-I$(PL_HOME)/include
CPP_PROJ=-nologo -MD -W3 -GX -O2 $(subst /,\,$(INCLUDEDIR)) -D "WIN32" -D "__WINDOWS__" -D "NDEBUG" -D "_MBCS" \
	-D "_LIB" -Fo"$(OBJDIR)\\" -Fd"$(OBJDIR)\\" -c


#CDEFS		=-DDEBUG -DDLEVEL=99
CXXFLAGS	=$(CPP_PROJ)
CFLAGS		=$(CXXFLAGS)

# Flags fuer den Linker zum Erstellen von transform und auslesen
# Wahrscheinlich sind nicht alle Libraries notwendig, aber es schadet nicht
LDFLAGS		=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib \
	shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib \
	user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib \
	oleaut32.lib uuid.lib odbc32.lib odbccp32.lib \
	-nologo -subsystem:console -incremental:no -machine:I386

# Targets
TARGETS=$(OBJDIR) $(OBJDIR)/libCos.$(LIBSUFFIX) \
	$(OBJDIR)/transform$(EXESUFFIX) \
	$(OBJDIR)/auslesen$(EXESUFFIX)
#	$(OBJDIR)/translate$(EXESUFFIX)


# Dateien, die nach EXPORT kopiert werden sollen
EXPORTFILES=$(OBJDIR)/*.$(LIBSUFFIX)

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
$(OBJDIR)/transform.exe: $(OBJDIR) $(OBJDIR)/transform.obj $(CXX_OBJECTS)
	$(AR) $(LDFLAGS) -out:"$(OBJDIR)\transform.exe" \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile)))

# Regel fuer das Ausleseprogramm auslesen
$(OBJDIR)/auslesen.exe: $(OBJDIR) $(OBJDIR)/auslesen.obj $(CXX_OBJECTS)
	$(AR) $(LDFLAGS) -out:"$(OBJDIR)\auslesen.exe" \
	$(foreach ofile,$(notdir $(filter-out $(OBJDIR), $^)), \
	$(word 1,$(wildcard $(OBJDIR)/$(ofile) $(CB_POOL)/$(CurrDir)$(OBJDIR)/$(ofile)) $(OBJDIR)/$(ofile)))

# Object-Files fuer die Libraries nicht loeschen
.PRECIOUS: $(TARGETS)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------

