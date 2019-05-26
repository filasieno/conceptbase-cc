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
# Makefile fuer $CB_POOL/java
#


# Wurzel des Pool-Verzeichnis relativ zum aktuellen Verzeichnis
POOL_ROOT=..

# Namen der Makefiles
CONFIG_MK=$(word 1,$(wildcard $(POOL_ROOT)/config.mk $(POOL_ROOT)/src/config.mk))
RULES_MK=$(word 1,$(wildcard $(POOL_ROOT)/rules.mk $(POOL_ROOT)/src/rules.mk))

# Hole zuerst die globalen Variablen aus config.mk
include $(CONFIG_MK)


#---------------------------------------
# Lokale Variablen
#---------------------------------------
# Alle SubDirectories
SubDirs=i5 resources

# Aktuelles Verzeichnis relativ zur POOL-Wurzel (endet mit /)
CurrDir=java/

# Die Sourcen
MK_SOURCES=Makefile

TARGETS=javadoc cb.jar CBinstaller.jar

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Java-Source-Codes der Clients und \n\
	Programmierbibliotheken fuer ConceptBase \n \
	Im Unterverzeichnis classes sind die compilierten Klassen bzw. \n\
	das JAR-File zu finden. \n\
	Das Unterverzeichnis docs enthaelt die Doku im JavaDoc-Format.

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(POOL_ROOT)/$(JAVA_CLASSPATH) $(MAKE_DIRS) $(TARGETS)


#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)


# create jar files only if CB_VARIANT is capable of Java; see also config.mk
ifneq "$(findstring /$(CB_VARIANT)/,$(JAVA_CAPABLE))" ""
cb.jar: $(POOL_ROOT)/$(JAVA_CLASSPATH)
	cd classes ; $(JAVADIR)/bin/jar cmvf ../$(SRCDIR)/manifest.txt cb.jar i5 resources

CBinstaller.jar: $(POOL_ROOT)/$(JAVA_CLASSPATH)
	cd classes ; $(JAVADIR)/bin/jar cmvf ../$(SRCDIR)/CBinstaller-manifest.txt CBinstaller.jar i5/cb/CBinstaller.class i5/cb/CBFileFilter.class
else
cb.jar:

CBinstaller.jar:
endif

# Ueberschreibe clean-Regel damit die Verzeichnisse classes und docs entfernt werden
clean: $(CLEAN_DIRS) FORCE
	/bin/rm -rf classes docs

#---------------------------------------
# Dependencies
#---------------------------------------
