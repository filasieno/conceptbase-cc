#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
# Date released : %E%  (YY/MM/DD)
#
# SCCS-Source-Pool : %P%
# Date retrieved : %D% (YY/MM/DD)
#
# -----------------------------------------
# Makefile fuer $CB_POOL/clientSources
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
CurrDir=java/resources/cbeditor_resources/

# Die Sourcen
MK_SOURCES=Makefile

PROP_FILES=$(notdir $(wildcard $(CB_POOL)/$(CurrDir)$(SRCDIR)/*.properties))
XML_FILES=$(notdir $(wildcard $(CB_POOL)/$(CurrDir)$(SRCDIR)/*.xml))
GIFS=$(notdir $(wildcard $(CB_POOL)/$(CurrDir)$(SRCDIR)/*.gif))
RESDIR=$(POOL_ROOT)/$(JAVA_CLASSPATH)/resources/cbeditor_resources

TARGETS=$(RESDIR) copyfiles

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer der Resourcen fuer den CBEditor

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(TARGETS) $(MAKE_DIRS)


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

copyfiles: $(GIFS) $(PROP_FILES) $(XML_FILES)
	$(CP) $? $(RESDIR)

$(RESDIR):
	$(MKDIR) -p $(RESDIR)

#---------------------------------------
# Dependencies
#---------------------------------------
