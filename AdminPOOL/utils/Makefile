#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/utils/Makefile,v $
# Version:     $Revision: 2.4 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2002/10/04 15:12:01 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/utils
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=..

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
SubDirs=CB_TestClient

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=utils/

# Die Sourcen
MK_SOURCES=Makefile
SH_SOURCES=CB_ExportProduct CB_ExportAdmin \
    CB_AnalyzerDiff CB_OutputAnalyzer CB_Makedepend \
    CB_CopyOldFiles sccs2cvs

# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=$(SH_SOURCES)

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer Utilities zur Pool-Verwaltung

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
	chmod 755 EXPORT/*
	chmod 744 EXPORT/CB_Export*


#---------------------------------------
# Dependencies
#---------------------------------------
