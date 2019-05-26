#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/examples/FLIGHT
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
SubDirs=

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=examples/FLIGHT/

# Die Sourcen
MK_SOURCES=Makefile
SML_FILES=c100.sml \
	c1470_0.sml \
	cities100.sml \
	cities1470.sml \
	city.sml \
	fl100.sml \
	fl1470.sml \
	queries.sml \
	BigFlights.sml \
	BigFlights2.sml

# Dateien, die nach EXPORT kopiert werden sollen
EXPORTFILES=$(SML_FILES) \
	README

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer das Flugdaten-Beispiel

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
