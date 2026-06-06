#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/distrib/Makefile,v $
# Version:     $Revision: 2.6 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2003/04/15 09:28:25 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/distrib
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
CurrDir=distrib/

# Die Sourcen
MK_SOURCES=Makefile


# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=CBinstall \
    make_dist \
    make_programmer_package \
    tar-exclude \
    tar-include \
    cb-request.awk \
    cbreg.cgi \
    mail.txt \
    sendKey \
    sendKey.awk \
    $(C_PROGRAMS)

C_SOURCES=makeKey.c checkKey.c

C_PROGRAMS=$(addprefix $(OBJDIR)/,$(basename $(C_SOURCES)))

# Die Targets
TARGETS=$(C_PROGRAMS)


# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Programme, um die Verteilversion \n\
	von ConceptBase zu erstellen und um die Registrierungen \n\
	zu verarbeiten

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
	chmod 750 EXPORT/make_* EXPORT/sendKey 
	chmod 755 EXPORT/CBinstall EXPORT/cbreg.cgi EXPORT/makeKey EXPORT/checkKey

#---------------------------------------
# Dependencies
#---------------------------------------
