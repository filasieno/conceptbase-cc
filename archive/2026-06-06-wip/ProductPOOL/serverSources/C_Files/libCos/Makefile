#
#
# File:        Makefile
# Version:     10.3
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: 05/22/96 , Christoph Quix (RWTH)
# Release:     10
#
# -----------------------------------------
# Makefile fuer $CB_POOL/serverSources/C_Files/libCos
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
CurrDir=serverSources/C_Files/libCos/

# Die Sourcen
MK_SOURCES=Makefile

# Gehoeren zu libCos, objstore und transform

CXX_SOURCES=long.Set.cc long.AVLSet.cc secure_put.cc\
	SYMTBL.cc SYMID.cc SYMID.AVLSet.cc SYMID.Set.cc\
	TOID.AVLSet.cc TOID.Set.cc TOID.cc TOIDSET.cc\
	Statistic.cc Statistic.Set.cc Statistic.CHSet.cc Statistic.CHNode.cc\
	Statistics.cc\
	TOBJ.cc TDB.cc TDB_testall.cc QUERY.cc\
	TIMELINE.cc TIMEPOINT.cc\
	TOIDREF.cc TOIDREF.Set.cc TOIDREF.CHSet.cc TOIDREF.CHNode.cc\
	SYMIDREF.cc SYMIDREF.Set.cc SYMIDREF.CHSet.cc SYMIDREF.CHNode.cc \
	Literals.cc \
	AlgLiterals.cc Tupel.OSLSet.cc Tupel.SLList.cc Tupel.Set.cc \
	Tupel.XPlex.cc Tupel.Plex.cc Tupel.XPBag.cc Tupel.Bag.cc \
	Tupel.STLSet.cc Tupel.STLBag.cc   


# Sourcen, die zur RPC-Version der libCos (also libCosRPC) gehoeren
RPCC_SRC=bim2c_rpc.c rpc_init.c rpc_idef_clnt.c rpc_idef_xdr.c 

# Sourcen, die zu objstore gehoeren (wird nur bei RPC-Version erstellt)
RPCS_SRC=rpc_idef_svc.c rpc_svi.c rpc_idef_xdr.c

RPCCXX_SRC=AlgToProlog_rpc.cc Algebra_rpc.cc

# Sourcen, die nur zur normalen libCos gehoeren
C_INTERFACE_SRC=bim2c.c

# Gehoert zur normalen libCos und zu transform
CXX_INTERFACE_SRC=trans.cc 

# Gehoert nur zur libCos
CXX_ALG_SRC=AlgToProlog.cc Algebra.cc C_Functor.cc

# Gehoert nur zu transform
CXX_TRANSFORM=transform.cc Algebra_rpc.cc AlgToProlog_rpc.cc

# Gehoert nur zu aus auslesen
CXX_AUSLESEN=auslesen.cc Algebra_rpc.cc AlgToProlog_rpc.cc

# Gehoert nur zu startAlgebra
CXX_STARTALG=startAlg.cc Algebra.cc TDB.cc AlgLiterals.cc C_Functor.cc

# Gehoert nur zu translate2.1-3.1
CXX_TRANSLATE=translate.cc Algebra_rpc.cc AlgToProlog_rpc.cc

# Die Targets
TARGETS=transform
#TARGETS=transform auslesen 
#TARGETS=startAlg

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die ObjektSpeicher-Library vom CB-Server; \n\
	ein CB_Make ohne Argumente compiliert alle C-Dateien \n\
	im Variantenzweig

DOCPPFILES=TDB.h TOBJ.h TOID.h TOIDSET.h SYMTBL.h SYMID.h TIMELINE.h TIMEPOINT.h

#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Verzweige fuer alle Targets in das Varianten-Verzeichnis
# make ohne Target erzeugt die normale libCos.a
all: $(TARGETS)
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_INTERFACE_SRC) $(CXX_ALG_SRC)" \
	C_SOURCES="$(C_SOURCES) $(C_INTERFACE_SRC)" \
	$(OBJDIR)/libCos.a

# Bei RPC-Version wird objstore und libCosRPC.a erstellt 
rpc: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_INTERFACE_SRC) $(RPCCXX_SRC)" \
	C_SOURCES="$(C_SOURCES) $(RPCS_SRC)" \
	$(OBJDIR)/objstore
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	C_SOURCES="$(RPCC_SRC)" \
	$(OBJDIR)/libCosRPC.a

# transform: Programm zur Konvertierung der OB.prop-Dateien
# von CBserver3.4 nach OB.telos und OB.symbol von CBserver4.x
transform: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_TRANSFORM)" \
	$(OBJDIR)/transform

# auslesen: liest das OB.telos file aus
auslesen: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_AUSLESEN)" \
	$(OBJDIR)/auslesen

# startAlgebra: startet eine Algebraanfrage...
startAlg: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_STARTALG)" \
	$(OBJDIR)/startAlg

# translate2.1-3.1: konvertiert OB.telos file von 2.1 nach 3.1
translate: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_TRANSLATE)" \
	$(OBJDIR)/translate

# Fuer clean oder aehnliches wird ebenfalls verzweigt
.DEFAULT: 
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	CXX_SOURCES="$(CXX_SOURCES) $(CXX_INTERFACE_SRC) $(CXX_TRANSFORM) $(CXX_ALG_SRC) $(CXX_STARTALG)" \
	C_SOURCES="$(C_SOURCES) $(C_INTERFACE_SRC)" \
        DOCPPFILES="$(DOCPPFILES)" \
	$@

#$(RPCS_SRC) $(RPCC_SRC)" 

export: all
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@

FORCE:

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
# hier nicht includen, da variantenabhaengig

#---------------------------------------
# Dependencies
#---------------------------------------
