#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/examples/ER_MODEL
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

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=examples/Servlets/

# Die Sourcen
MK_SOURCES=Makefile

# Kurze Beschreibung der Komponente
INFO_TXT=Beispiel fuer die Benutzung von Servlets mit CB

# exportierte Dateien fuer die Verteilversion
EXPORTFILES=Paper.sml \
   PaperForm.html \
   PaperInst.sml \
   README \
   default.cfg \
   runservlets \
   servlet.properties \
   servlets.properties 

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)



#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
