#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/examples/Clients/LogClient
#
#

# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=../../..

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
CurrDir=examples/Clients/LogClient/

# Die Sourcen
MK_SOURCES=Makefile \
	MakeLogClient

C_SOURCES=LogClient.c

EXPORTFILES=MakeLogClient \
	$(C_SOURCES) \
	README


# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer den Beispiel-Client zur libCB, \
	der gleichzeitig auch die Log-Files von ConceptBase bearbeiten kann
	

# Damit es beim Einchecken keine Fehler gibt
CFLAGS+= -I$(CB_PRODUCT)/include

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

# gmake -f $(word 1,$(wildcard MakeLogClient src/MakeLogClient))



#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
 
