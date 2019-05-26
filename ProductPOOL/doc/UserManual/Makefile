#
#
# File:        %M%
# Version:     %I%
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: %G% , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $CB_POOL/doc/UserManual
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
CurrDir=doc/UserManual/

# Die Sourcen
MK_SOURCES=Makefile
TEX_SOURCES=CB-Manual.tex
TEX_SOURCES_INCL=Title.tex \
	Introduction.tex \
	Language.tex \
	CBserver.tex \
	CBiva.tex \
	CBworkbench.tex \
	Moduleserver.tex \
	ECArules.tex \
	Functions.tex \
	AnswerFormat.tex \
	References.tex \
	InstallationGuide_40.tex \
	SyntaxDef.tex \
	Examples.tex \
	GraphicalTypes.tex

EXPORTFILES=$(PDFTEX_OBJECTS)


# Die Targets
TARGETS=$(PDFTEX_OBJECTS)

# Kurze Beschreibung der Komponente
INFO_TXT=Das UserManual zu ConceptBase

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(OBJDIR) $(MAKE_DIRS) $(TARGETS)



#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

#---------------------------------------
# Dependencies
#---------------------------------------

$(OBJDIR)/CB-Manual.pdf: $(TEX_SOURCES_INCL)
$(OBJDIR)/CB-Manual.dvi: $(TEX_SOURCES_INCL)

