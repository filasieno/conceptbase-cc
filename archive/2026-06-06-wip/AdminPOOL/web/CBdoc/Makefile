#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/web/CBdoc/Makefile,v $
# Version:     $Revision: 1.5 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2008/05/29 09:36:07 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Makefile fuer $ADMIN_POOL/web/CBdoc
#
#


# Wurzel des POOL-Verzeichnisses relativ zum aktuellen Directory
POOL_ROOT=../..

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
CurrDir=web/CBdoc/

# Die Sourcen
MK_SOURCES=Makefile


# Die Dateien, die nach EXPORT kopiert werden
EXPORTFILES=O-Telos.html \
    WhatIsConceptBase.html \
    cbaccess.html \
    cbfaqs-33.html \
    cbfaqs-40.html \
    cbfaqs-5.html \
    cbfaqs.html \
    cbflyer.html \
    cbforumReg.html \
    cblit.html \
    cbscreens-bpr.html \
    cbscreens-erd.html \
    cbteam.html \
    cbteam94.html \
    cbteam96.html \
    onlineReg.html \
    cb.css


# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die statischen Web-Seiten zu ConceptBase

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Make in allen Subdirectories aufrufen
all: $(MAKE_DIRS) $(TARGETS)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
include $(RULES_MK)

include $(ADMIN_MK)

