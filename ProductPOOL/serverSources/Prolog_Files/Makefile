#
# File:        %M%
# Version:     %I%
#
#
# Date released : %E%  (YY/MM/DD)
#
# SCCS-Source-Pool : %P%
# Date retrieved : %D% (YY/MM/DD)
#
#
# -----------------------------------------
# Makefile fuer $CB_POOL/serverSources/Prolog_Files
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
CurrDir=serverSources/Prolog_Files/

# Die Sourcen
MK_SOURCES=Makefile
PROLOG_SOURCES1=startCBserver.pro \
	dcg.pro \
	PrologCompatibility.pro \
	GlobalParameters.pro \
	GlobalPredicates.pro \
	stopCBserver.pro \
	ObjectProcessor.pro \
	ObjectTransformer.pro \
	FragmentToPropositions.pro \
	ViewToPropositions.pro \
	VMruleGenerator.pro \
	ViewMonitor.pro \
	PropositionsToLiterals.pro \
	ViewEvaluator.pro \
	ClientNotification.pro \
	PropositionsToFragment.pro \
	Literals.pro \
	PROLOGruleProcessor.pro \
	AssertionCompiler.pro \
	AssertionTransformer.pro \
	MSFOLpreProcessor.pro \
	MSFOLassertionParser.pro \
	MSFOLassertionSimplifier.pro \
	MSFOLassertionTransformer.pro \
	VarTabHandling.pro \
	MSFOLassertionUtilities.pro \
	MSFOLassertionParserUtilities.pro \
	parseAss_dcg.pro \
	PropositionProcessor.pro \
	validProposition.pro \
	SearchSpace.pro

PROLOG_SOURCES2=BDMIntegrityChecker.pro \
	BDMCompile.pro \
	BDMForget.pro \
	BDMEvaluation.pro \
	BDMKBMS.pro \
	BDMTransFormula.pro \
	BDMLiteralDeps.pro \
	SMLaxioms.pro \
	SemanticOptimizer.pro \
	SemanticIntegrity.pro \
	QueryProcessor.pro \
	QueryEvaluator.pro \
	QueryCompiler.pro \
	SubQueryCompiler.pro \
	ViewCompiler.pro \
	QueryCompilerUtilities.pro \
	TriggerGenerator.pro \
	RuleOptimizer.pro \
	RuleSpecializer.pro \
	cfixpoint.pro \
	AnswerTransformator.pro \
	AnswerTransform.pro \
	AnswerTransformUtilities.pro \
        ExternalConnection.pro \
	QAmanager.pro \
	Datalog2Algebra.pro \
	LTcompiler.pro \
	LTstubs.pro \
	CodeCompiler.pro \
	CodeStorage.pro \
	Calendar.pro \
	BIM2C.pro \
	debug.pro \
	CBprofiler.pro

PROLOG_SOURCES3=FragmentToHistoryPropositions.pro \
	TransactionTime.pro \
	tokens_dcg.pro \
	LanguageInterface.pro \
	SelectExpressions.pro \
	ScanFormatUtilities.pro \
	ModelConfiguration.pro \
	ConfigurationUtilities.pro \
	WeakPersistency.pro \
	prologToUnixSUN4.pro \
	GeneralUtilities.pro \
	ErrorMessages.pro \
	IpcParser.pro \
	BimIpc.pro \
	IpcChannel.pro \
	CBserverInterface.pro \
	TellAndAsk.pro \
	ExternalCodeLoader.pro \
	QO_costBase.pro \
	QO_costs.pro \
	QO_heaps.pro \
	QO_heur.pro \
	QO_literals.pro \
	QO_optimize.pro \
	QO_preproc.pro \
	QO_profile.pro \
	QO_search.pro \
	QO_utils.pro \
	QO_vartab.pro \
	RuleBase.pro

PROLOG_SOURCES4=ECAeventManager.pro \
	ECAruleManager.pro \
	ECAruleCompiler.pro \
	ECAutilities.pro \
	ECAactionManager.pro \
	ECAqueryEvaluator.pro \
	ECAruleProcessor.pro \
        SystemBuiltin.pro

META_SOURCES=AToAdot.pro \
	MetaSimplifier.pro \
	MetaFormulas.pro \
	MetaRFormulas.pro \
	MetaBindingPath.pro \
	MetaLiterals.pro \
	MetaUtilities.pro \
	MetaRFormToAssText.pro \
	MetaTriggerGen.pro \
	MetaBDMEvaluation.pro \
	cbserver.pro \
	RangeformSimplifier.pro


PROLOG_SOURCES=$(PROLOG_SOURCES1) $(PROLOG_SOURCES2) $(PROLOG_SOURCES3) $(PROLOG_SOURCES4) $(META_SOURCES)

PROLOG_SOURCES_IND=$(PROLOG_SOURCES)
export PROLOG_SOURCES_IND

DCG_FILES = tokens_dcg.pro sml_gramm_dcg.pro parseAss_dcg.pro

TARGETS=$(DCG_FILES) makePrologVariantSource

# Kurze Beschreibung der Komponente
INFO_TXT=Verzeichnis fuer die Prolog-Source-Codes vom CB-Server; \n\
	ein CB_Make ohne Argumente compiliert alle Prolog-Dateien


#---------------------------------------
# Lokale Regeln
#---------------------------------------
# Verzweige fuer alle Targets in das Varianten-Verzeichnis
all .DEFAULT: $(TARGETS)
	$(MAKE) -$(MAKEFLAGS) \
	-C $(POOL_ROOT)/$(CB_VARIANT)/$(CurrDir) \
	$@

dcg .DEFAULT: $(DCG_FILES)

#---------------------------------------
# Nun die globalen Regeln
#---------------------------------------
# hier nicht includen, da variantenabhaengig

#---------------------------------------
# Dependencies
#---------------------------------------
