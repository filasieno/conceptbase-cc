#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/bin/Makefile,v $
# Version:     $Revision: 11.6 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2003/09/10 12:12:55 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/bin
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
CurrDir=bin/

# Die Sourcen
MK_SOURCES=Makefile
SH_SOURCES=latex_fix \
	pdflatex_fix \
	touch_ifw \
	CB_Make \
	CB_CheckIn \
	CB_CheckOut \
	CB_CreateCVSPool \
	CB_updateOnCommit

BAT_SOURCES=CB_Make.bat \
	CB_env.bat

C_SOURCES=CBase_cvs_update.c

C_PROGRAMS=$(addprefix $(OBJDIR)/,$(basename $(C_SOURCES)))

# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=$(C_PROGRAMS) $(SH_SOURCES) $(BAT_SOURCES)

# Die Targets
TARGETS=$(C_PROGRAMS)

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Skripte zur Verwaltung \n\
	der Sourcen von ConceptBase

CLEAN_FILES+=$(C_PROGRAMS)

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

$(C_PROGRAMS): $(OBJDIR) $(C_OBJECTS)
	$(CC) $(CFLAGS) $@.o -o $@

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

include $(ADMIN_MK)

# Ueberschreiben der Default-Regel von export
export: $(EXPDIR) $(EXPORTFILES)
	$(CP) $(filter-out EXPORT_%,$(filter-out $(EXPDIR),$^)) $(EXPDIR)
	chmod 750 EXPORT/*
	chmod 755 EXPORT/CB_env.bat
	chmod u+s EXPORT/CBase_cvs_update

#---------------------------------------
# Dependencies
#---------------------------------------
