#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/utils/CB_TestClient/Makefile,v $
# Version:     $Revision: 2.4 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2008/12/03 11:38:47 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/utils/CB_TestClient
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=../..

# Namen der Makefiles 
CONFIG_MK=$(word 1,$(wildcard $(CB_POOL)/config.mk $(CB_POOL)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(CB_POOL)/rules.mk $(CB_POOL)/src/rules.mk))

# Makefile fuer die spezifischen Variablen und Regeln fuer den Admin-Pool
ADMIN_MK=$(word 1,$(wildcard $(POOL_ROOT)/admin.mk $(POOL_ROOT)/src/admin.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=scripts

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=utils/CB_TestClient/

# Die Sourcen
MK_SOURCES=Makefile 
SH_SOURCES=CB_TestClient CB_Create_SYSTEM CB_AutoTest
PROLOG_SOURCES=BimIpc.pro \
	ExampleIpcClient.pro \
	ExampleClientCodeLoader.pro \
	IpcChannel.pro \
	IpcChannelAccess.pro \
	IpcParameters.pro

C_SOURCES=BimIpc.c
	
# Die Dateien, die nach EXPORT kopiert werden
# Hier werden die Sourcen exportiert, da nur fuer interne Zwecke
EXPORTFILES=$(SH_SOURCES) $(PROLOG_SOURCES) $(C_SOURCES) README startup stopServer.cbs

# Die Targets
# hier gibt es keine Targets

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer den TestClient von ConceptBase

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

	

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

include $(ADMIN_MK)

export: $(EXPDIR) $(EXPORTFILES)
	$(CP) $(filter-out EXPORT_%,$(filter-out $(EXPDIR),$^)) $(EXPDIR)
	chmod 755 EXPORT/CB_*



#---------------------------------------
# Dependencies
#---------------------------------------
