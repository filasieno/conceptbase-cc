#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/crontabs/Makefile,v $
# Version:     $Revision: 1.5 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2004/08/31 15:20:11 $ , Christoph Quix (RWTH)
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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=crontabs/

# Die Sourcen
MK_SOURCES=Makefile
SH_SOURCES=cron.daily cron.weekly.clean cron.weekly.export cron.weekly.test cron.admin cron.weekly.test.mail
BAT_SOURCES=daily.bat autotest.bat clean.bat

# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=$(SH_SOURCES) $(BAT_SOURCES) README

# Die Targets
# hier gibt es keine

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Shell-Scripts der cron-jobs

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
	chmod 744 EXPORT/*


#---------------------------------------
# Dependencies
#---------------------------------------
