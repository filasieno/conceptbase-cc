#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/serverSources/Prolog_Files
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
CurrDir=windows/serverSources/Prolog_Files/

# Z.Z. sind wir im Variantenverzeichnis, NotVariantDir
# ist das Verzeichnis, wo die allgemeinen Sourcen zu finden sind
NotVariantDir=serverSources/Prolog_Files

# Die Sourcen
PROLOG_SOURCES=$(PROLOG_SOURCES_IND)

# Wo sind die Sourcen
vpath %.pro .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.pl .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath %.dcg .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src
vpath SYSTEM.% .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Die Targets
TARGETS=$(OBJDIR) $(PROLOG_OBJECTS)


EXPORTFILES=

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Prolog-Source-Codes vom CB-Server; \n\
	ein CB_Make ohne Argumente compiliert alle Prolog-Dateien \n\
	fuer die Variante windows

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

parseAss_dcg.wic: parseAss_dcg.pro parseAss.dcg
parseAss_dcg.pro: parseAss.dcg
sml_gramm_dcg.wic: sml_gramm_dcg.pro sml_gramm.dcg
sml_gramm_dcg.pro: sml_gramm.dcg
tokens_dcg.wic: tokens_dcg.pro tokens.dcg
tokens_dcg.pro: tokens.dcg
