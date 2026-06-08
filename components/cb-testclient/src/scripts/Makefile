#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/utils/CB_TestClient/scripts/Makefile,v $
# Version:     $Revision: 2.14 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2006/11/20 09:54:00 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/utils/CB_TestClient/scripts
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=../../..

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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=utils/CB_TestClient/scripts

# Die Sourcen
MK_SOURCES=Makefile
SCRIPTS=FLIGHT_100.cbs \
	QUERIES_FRAME.cbs \
	QUERIES_LABEL.cbs \
	RULES_CONSTRAINTS.cbs \
	SYSTEM.cbs \
	RECURSION.cbs \
	USU.cbs \
	ECArules.cbs \
    DWQ.cbs \
    BuiltinQueries.cbs \
    AnswerFormat.cbs \
    BigFlights.cbs \
    BigFlights2.cbs \
    ER_Model.cbs \
    MetaFormulas.cbs \
    Modules.cbs \
    Datalog.cbs \
    Views.cbs \
    X-Petrinet-simu.cbs 


# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=$(SCRIPTS)

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Scripts des TestClients von ConceptBase

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

#---------------------------------------
# Dependencies
#---------------------------------------
