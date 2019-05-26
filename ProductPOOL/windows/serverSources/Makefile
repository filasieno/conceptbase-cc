#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows
#
#


# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../..

# Namen der Makefiles
CONFIG_MK=$(word 1,$(wildcard $(POOL_ROOT)/config.mk $(POOL_ROOT)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(POOL_ROOT)/rules.mk $(POOL_ROOT)/src/rules.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=Prolog_Files C_Files

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=windows/serverSources/


NotVariantDir=serverSources

vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Sourcen
MK_SOURCES=Makefile

# ----------------------
# Dateinamen fuer die Libraries
# ----------------------
LIB_IPC=$(word 1,$(wildcard C_Files/libIpc/$(OBJDIR)/libIpc.$(LIBSUFFIX) \
			C_Files/libIpc/$(EXPDIR)/libIpc.$(LIBSUFFIX) \
			$(CB_POOL)/$(CurrDir)C_Files/libIpc/$(EXPDIR)/libIpc.$(LIBSUFFIX)))

LIB_GENERAL=$(word 1,$(wildcard C_Files/libGeneral/$(OBJDIR)/libGeneral.$(LIBSUFFIX) \
			C_Files/libGeneral/$(EXPDIR)/libGeneral.$(LIBSUFFIX) \
			$(CB_POOL)/$(CurrDir)C_Files/libGeneral/$(EXPDIR)/libGeneral.$(LIBSUFFIX)))

LIB_TELOSSERVER=$(word 1,$(wildcard C_Files/libtelosServer/$(OBJDIR)/libtelosServer.$(LIBSUFFIX) \
			C_Files/libtelosServer/$(EXPDIR)/libtelosServer.$(LIBSUFFIX) \
			$(CB_POOL)/$(CurrDir)C_Files/libtelosServer/$(EXPDIR)/libtelosServer.$(LIBSUFFIX)))

LIB_TELOS=$(word 1,$(wildcard C_Files/libtelos/$(OBJDIR)/libtelos.$(LIBSUFFIX) \
			C_Files/libtelos/$(EXPDIR)/libtelos.$(LIBSUFFIX) \
			$(CB_POOL)/$(CurrDir)C_Files/libtelos/$(EXPDIR)/libtelos.$(LIBSUFFIX)))

LIB_COS=$(word 1,$(wildcard C_Files/libCos3/$(OBJDIR)/libCos.$(LIBSUFFIX) \
			C_Files/libCos3/$(EXPDIR)/libCos.$(LIBSUFFIX) \
			$(CB_POOL)/$(CurrDir)C_Files/libCos3/$(EXPDIR)/libCos.$(LIBSUFFIX)))

# ------------------------------
# Dateinamen fuer die Prolog-Start-Dateien
# ------------------------------
STARTCBSERVER=$(word 1,$(wildcard Prolog_Files/$(OBJDIR)/startCBserver.wic \
			$(CB_POOL)/$(CurrDir)Prolog_Files/$(OBJDIR)/startCBserver.wic))

EXTERNALCODELOADER=$(word 1,$(wildcard Prolog_Files/$(OBJDIR)/ExternalCodeLoader.wic \
			$(CB_POOL)/$(CurrDir)Prolog_Files/$(OBJDIR)/ExternalCodeLoader.wic))


# ----------------------------
# Variablen fuer den interaktiven Server
# ----------------------------
TMPDIR:=/tmp

# Wo sind die SYSTEM.* Dateien?
SYSFILES=$(wildcard $(POOL_ROOT)/lib/SYSTEM.rule \
	$(POOL_ROOT)/lib/SYSTEM.builtin \
	$(POOL_ROOT)/lib/SYSTEM.telos \
	$(POOL_ROOT)/lib/SYSTEM.symbol)

ifeq ("$(words $(SYSFILES))","4")
override CBL_DIR:=$(POOL_ROOT)/lib
override CBS_DIR:=$(POOL_ROOT)/lib
else
override CBL_DIR:=$(CB_POOL)/lib/src
override CBS_DIR:=$(CB_POOL)/lib/src
endif



# ----------------------------
# Variablen zum Linken des Servers
# ----------------------------
PL_XTC_EXE=$(CC)
PL_XTL_EXE=$(CC)
PL_XTC_CMD=$(CC) -c -MD %S %A %I -FoPL.obj
PL_XTF_OBJ=PL.obj

TABLE_SIZES=-THb1m -THl5m -TSb512k -TSl3m  -TBb1m -TBl5m -TDb32k -TFb16k -TIb512k -TCb120k -TRb1k

SWI_HOME_DIR=$(SWI_HOME)
export SWI_HOME_DIR

# -------------------------------------
# Diese Variablen werden an das Environment exportiert
# -------------------------------------
export LIB_IPC
export LIB_GENERAL
export LIB_COS
export LIB_TELOSSERVER
export LIB_TELOS
export LIB_GCC
export LIB_GPP
export LIB_STDCPP
export PL_XTC_EXE
export PL_XTL_EXE
export PL_XTC_CMD
export PL_XTF_OBJ
export TMPDIR
export CBL_DIR
export CBS_DIR
export CB_VARIANT


# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Server-Sourcen der windows-Variante \n\
	CB_Make sollte nur vom variantenunabhaengigen Zweig aus aufgerufen werden.

EXPORTFILES=$(OBJDIR)/cbRTdata $(OBJDIR)/cbRTexec.exe

# Nicht in die SubDirectories verzweigen
EXPORT_DIRS=
CLEAN_DIRS=
MAKE_DIRS=

#---------------------------------------
# Lokale Regeln
#---------------------------------------
all:


# Rekursiver Make-Aufruf damit die Variablen fuer die Libs
# richtig gesetzt sind
ifeq "$(PROLOG_VARIANT)" "BIM"
EXPORTFILES=$(OBJDIR)/cbRTdata $(OBJDIR)/cbRTexec$(EXESUFFIX)

iserver:
	$(CB_START) - $(CB_OPTIONS)

link_server: $(OBJDIR)
	$(PL_HOME)/bin/PLlink.exe -vh CBS_DIR -pr -HcbRTdata -po -HcbRTexec \
	- $(TABLE_SIZES) $(STARTCBSERVER) $(EXTERNALCODELOADER)
	movecbrt.bat
endif

ifeq "$(PROLOG_VARIANT)" "SWI"
EXPORTFILES=$(OBJDIR)/CBserver$(EXESUFFIX)

$(OBJDIR)\plcb.exe: swiInteractive.c $(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER)
	$(CP) $< .
	$(SWI_PLLD) -v -cc $(CC) -pl $(PROLOG_COMP) -o $@ -nostate \
	swiInteractive.c \
	$(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER) \
	wsock32.lib kernel32.lib user32.lib advapi32.lib
	$(RM) swiInteractive.c

iserver: $(OBJDIR)\plcb.exe
	$(OBJDIR)\plcb.exe -L0 -G0 -T50m -A50m -- $(CB_OPTIONS)

link_server: swiMain.c $(OBJDIR) $(OBJDIR)\plcb.exe $(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER)
	$(CP) $< .
	$(SWI_PLLD) -v -cc $(CC) -o $(OBJDIR)\CBserver.exe -pl $(OBJDIR)\plcb.exe \
	-pl-options,--report-error=false,-q,-O,--autoload=false,--allow-variable-name-as-functor=true,-L0,-G0,-T50m,-A50m \
	swiMain.c Prolog_Files/startCBserver.swi.pl \
	$(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER) \
	wsock32.lib kernel32.lib user32.lib advapi32.lib
	$(RM) swiMain.c
endif

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

ifeq "$(PROLOG_VARIANT)" "BIM"
export: $(EXPDIR)
	copy $(OBJDIR)\cbRTdata $(EXPDIR)
	copy $(OBJDIR)\cbRTexec$(EXESUFFIX) $(EXPDIR)
endif

ifeq "$(PROLOG_VARIANT)" "SWI"
export: $(EXPDIR)
	copy $(OBJDIR)\CBserver$(EXESUFFIX) $(EXPDIR)
endif

#---------------------------------------
# Dependencies
#---------------------------------------
