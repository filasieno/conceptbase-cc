#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/windows/bin
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
CurrDir=windows/bin/

NotVariantDir=bin

# Wo sind die Sourcen?
vpath %.c .:$(POOL_ROOT)/$(NotVariantDir):src:$(POOL_ROOT)/$(NotVariantDir)/src

# Nix zu tun hier, da CBreplaceOptions nur fuer Unix relevant ist

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------
