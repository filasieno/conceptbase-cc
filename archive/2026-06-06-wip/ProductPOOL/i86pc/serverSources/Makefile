#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/i86pc
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
CurrDir=i86pc/serverSources/


NotVariantDir=serverSources

# vpath for C-Source-File
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Sourcen
MK_SOURCES=Makefile

# ----------------------
# Dateinamen fuer die Libraries
# ----------------------
LIB_IPC=$(word 1,$(wildcard C_Files/libIpc/$(OBJDIR)/libIpc.a \
			C_Files/libIpc/$(EXPDIR)/libIpc.a \
			$(CB_POOL)/$(CurrDir)C_Files/libIpc/$(EXPDIR)/libIpc.a))

LIB_GENERAL=$(word 1,$(wildcard C_Files/libGeneral/$(OBJDIR)/libGeneral.a \
			C_Files/libGeneral/$(EXPDIR)/libGeneral.a \
			$(CB_POOL)/$(CurrDir)C_Files/libGeneral/$(EXPDIR)/libGeneral.a))

LIB_TELOSSERVER=$(word 1,$(wildcard C_Files/libtelosServer/$(OBJDIR)/libtelosServer.a \
			C_Files/libtelosServer/$(EXPDIR)/libtelosServer.a \
			$(CB_POOL)/$(CurrDir)C_Files/libtelosServer/$(EXPDIR)/libtelosServer.a))

LIB_TELOS=$(word 1,$(wildcard C_Files/libtelos/$(OBJDIR)/libtelos.a \
			C_Files/libtelos/$(EXPDIR)/libtelos.a \
			$(CB_POOL)/$(CurrDir)C_Files/libtelos/$(EXPDIR)/libtelos.a))

LIB_COS=$(word 1,$(wildcard C_Files/libCos3/$(OBJDIR)/libCos.a \
			C_Files/libCos3/$(EXPDIR)/libCos.a \
			$(CB_POOL)/$(CurrDir)C_Files/libCos3/$(EXPDIR)/libCos.a))


LIBSTDCPP=$(GCC_DIR)/lib/libstdc++.a

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
TMPDIR:=/var/tmp

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

#override SHELL:=/bin/csh

GCC:=$(CC)
BIM_DLC_CMD:=$(GCC) -c %I
CB_START=$(BIM_PROLOG_DIR)/bin/BIMprolog $(TABLE_SIZES) $(STARTCBSERVER)


# ----------------------------
# Variablen zum Linken des Servers
# ----------------------------
BIM_XTC_CMD=$(GCC) -c %S %I
BIM_XTL_CMD=$(GCC) %S -o %O %I $(LIBSTDCPP) -lm -lsocket -lnsl -ldl
BIM_XTL_FILE=/tmp/BP.xt%U

TABLE_SIZES=-THb1m -THl5m -TSb512k -TSl3m  -TBb1m -TBl5m -TDb32k -TFb16k -TIb512k -TCb120k -TRb1k


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
export BIM_XTC_CMD
export BIM_XTL_CMD
export BIM_XTL_FILE
export TMPDIR
export CBL_DIR
export CBS_DIR
export SHELL
export CB_VARIANT
export CB_POOL
export BIM_DLC_CMD


# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Server-Sourcen der i86pc-Variante \n\
	CB_Make sollte nur vom variantenunabhaengigen Zweig aus aufgerufen werden.


# Ueberschreibe die Default-Definition von CP,RM und MV, da hier C-Shell benutzt wird
CP=/bin/cp
MV=/bin/mv
RM=/bin/rm -f

# Nicht in die SubDirectories verzweigen
EXPORT_DIRS=
CLEAN_DIRS=
MAKE_DIRS=

#---------------------------------------
# Lokale Regeln
#---------------------------------------
all:

ifeq "$(PROLOG_VARIANT)" "BIM"
EXPORTFILES=$(OBJDIR)/cbRTexec $(OBJDIR)/cbRTdata
CLEAN_FILES=$(EXPORTFILES)

iserver:
	@echo Starte interaktiven Server mit folgenden Libraries/Start-Dateien: ;\
	echo "libGeneral    : $(LIB_GENERAL)" ;\
	echo "libIpc        : $(LIB_IPC)" ;\
	echo "libtelosServer: $(LIB_TELOSSERVER)" ;\
	echo "libCos        : $(LIB_COS)" ;\
	echo "libtelos      : $(LIB_TELOS)" ;\
	echo "CBL_DIR       : $(CBL_DIR)" ;\
	echo "CBS_DIR       : $(CBS_DIR)" ;\
	echo "startCBserver : $(STARTCBSERVER)" ;\
	echo "ExternalCodeL.: $(EXTERNALCODELOADER)" ;\
	echo "GCC           : $(GCC)" ;\
	$(CB_START) - $(CB_OPTIONS)

link_server: $(OBJDIR)
	@echo Linke Server mit folgenden Libraries/Start-Dateien: ;\
	echo "libGeneral    : $(LIB_GENERAL)" ;\
	echo "libIpc        : $(LIB_IPC)" ;\
	echo "libtelosServer: $(LIB_TELOSSERVER)" ;\
	echo "libCos        : $(LIB_COS)" ;\
	echo "libtelos      : $(LIB_TELOS)" ;\
	echo "CBL_DIR       : $(CBL_DIR)" ;\
	echo "CBS_DIR       : $(CBS_DIR)" ;\
	echo "startCBserver : $(STARTCBSERVER)" ;\
	echo "ExternalCodeL.: $(EXTERNALCODELOADER)" ;\
	echo
	$(BIM_PROLOG_DIR)/bin/BIMlinker -vh CBS_DIR -pr -HcbRTdata -po -HcbRTexec \
	- $(TABLE_SIZES) $(STARTCBSERVER) $(EXTERNALCODELOADER)
	$(MV) cbRTdata cbRTexec $(OBJDIR)
endif

ifeq "$(PROLOG_VARIANT)" "SWI"
EXPORTFILES=$(OBJDIR)/CBserver$(EXESUFFIX)
CLEAN_FILES=$(EXPORTFILES)

$(OBJDIR)/plcb: swiInteractive.c $(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER)
	$(SWI_PLLD) -v -cc $(CC) -pl $(PROLOG_COMP) -o $@ -nostate $< -lnsl -lsocket -lstdc++ -lpl \
	-LC_Files/libIpc/$(OBJDIR) -lIpc \
	-LC_Files/libGeneral/$(OBJDIR) -lGeneral \
	-LC_Files/libCos3/$(OBJDIR) -lCos \
	-LC_Files/libtelos/$(OBJDIR) -ltelos \
	-LC_Files/libtelosServer/$(OBJDIR) -ltelosServer

iserver: $(OBJDIR)/plcb
	$(OBJDIR)/plcb -L0 -G0 -T50m -A50m -- $(CB_OPTIONS)

link_server: swiMain.c $(OBJDIR) $(OBJDIR)/plcb $(LIB_IPC) $(LIB_GENERAL) $(LIB_COS) $(LIB_TELOS) $(LIB_TELOSSERVER)
	$(SWI_PLLD) -v -cc $(CC) -pl $(PROLOG_COMP) -o $(OBJDIR)/CBserver -pl $(OBJDIR)/plcb \
	-pl-options,--report-error=false,-q,-O,--autoload=false,--allow-variable-name-as-functor=true,-L0,-G0,-T50m,-A50m \
	$< Prolog_Files/startCBserver.swi.pl -lnsl -lsocket -lstdc++ -lpl \
	-LC_Files/libIpc/$(OBJDIR) -lIpc \
	-LC_Files/libGeneral/$(OBJDIR) -lGeneral \
	-LC_Files/libCos3/$(OBJDIR) -lCos \
	-LC_Files/libtelos/$(OBJDIR) -ltelos \
	-LC_Files/libtelosServer/$(OBJDIR) -ltelosServer
endif


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)


#---------------------------------------
# Dependencies
#---------------------------------------
