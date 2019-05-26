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
POOL_ROOT=../../../../..

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
CurrDir=java/i5/cb/telos/frame/

# Die Sourcen
MK_SOURCES=Makefile

JAVACC_GENSOURCES=ASCII_CharStream.java \
	ParseException.java \
	Token.java \
	TokenMgrError.java \
	TelosParser.java \
	TelosParserConstants.java \
	TelosParserTokenManager.java

JAVA_SOURCES=$(notdir $(wildcard $(CB_POOL)/$(CurrDir)$(SRCDIR)/*.java))

#JAVA_MAIN=i5.cb.telos.CBclient

TARGETS=compilejava

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Java-Source-Codes\n\
	des TelosParsers und fuer die TelosFrame-Klassen
	
#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(TARGETS) $(MAKE_DIRS)


#$(JAVACC_GENSOURCES): Telos.jj
#	/home/java/JavaCC/bin/javac Telos.jj
	
#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)



#---------------------------------------
# Dependencies
#---------------------------------------
