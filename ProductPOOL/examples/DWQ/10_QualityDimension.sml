{*
The ConceptBase.cc Copyright

Copyright 1987-2014 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{---------------------------------------------------------
                    Telos Frames for qdim-admin.tex
 ---------------------------------------------------------}

"Administration and Maintenance" in QualityCategory with
name
  de_name : "Administration und Wartung";
  en_name : "Administration and Maintenance"
description
  de_desc : "Vorhandensein von Funktionen und deren Eignung zur Administration und Wartung des Systems"
end

"Administration and Maintenance -- Reporting" in QualityDimension with
name
  de_name : "Berichterstattung";
  en_name : "Reporting"
description
  de_desc : "Fähigkeit des Systems zur Erstellung von Berichten über durchgeführte Operationen und Änderungen und aufgetretene Ereignisse"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Ability to document" in QualityDimension with
name
  de_name : "Dokumentierbarkeit";
  en_name : "Ability to document"
description
  de_desc : "Fähigkeit und Aufwand durchgeführte Operationen und Änderungen zu dokumentieren"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Metadata Availability" in QualityDimension with
name
  de_name : "Metadatenverfügbarkeit";
  en_name : "Metadata Availability"
description
  de_desc : "Vorhandensein von Funktionen zum Abfragen von Metadaten der Systemkomponenten"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Effectivity" in QualityDimension with
name
  de_name : "Effektivität";
  en_name : "Effectivity"
description
  de_desc : "Aufwand zur Durchführung der notwendigen Aufgaben"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Analyzability" in QualityDimension with
name
  de_name : "Analysierbarkeit";
  en_name : "Analyzability"
description
  de_desc : "Aufwand zur Bestimmung von Mängeln oder Ursachen von Fehlern"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Instrumentation" in QualityDimension with
name
  de_name : "Ausstattung";
  en_name : "Instrumentation"
description
  de_desc : "Umfang der zur Verfügung stehenden Werkzeuge und Funktionen"
isSubDimOf
   category : "Administration and Maintenance"
end



{---------------------------------------------------------
                    Telos Frames for qdim-besch.tex
 ---------------------------------------------------------}

"Data Integration (ETL-Process)" in QualityCategory with
name
  de_name : "Datenbeschaffung";
  en_name : "Data Integration (ETL-Process)"
description
  de_desc : "Extraktion, Transformation, Integration und Laden der Daten in das Data Warehouse"
end

"Data Integration (ETL-Process) -- Extraction" in QualityCategory with
name
  de_name : "Extraktion";
  en_name : "Extraction"
description
  de_desc : "Qualitätsmerkmale des Extraktionsprozesses"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Extraction -- Completeness" in QualityDimension with
name
  de_name : "Vollständigkeit";
  en_name : "Completeness"
description
  de_desc : "Verhältnis zwischen extrahierten und verfügbaren Daten"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Extraction -- Efficiency" in QualityDimension with
name
  de_name : "Effizienz";
  en_name : "Efficiency"
description
  de_desc : "Durchsatz, Zeit- und Verbrauchsverhalten des Extraktionsprozesses"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Extraction -- Traceability" in QualityDimension with
name
  de_name : "Nachvollziehbarkeit";
  en_name : "Traceability"
description
  de_desc : "Vorhandensein von Funktionen zum Nachvollziehen des tatsächlichen Ablaufs eines Extraktionsprozesses"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning" in QualityCategory with
name
  de_name : "Transformation und Bereinigung";
  en_name : "Transformation and Cleaning"
description
  de_desc : "Qualitätsmerkmale des Transformations- und Bereinigungsprozesses"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Efficiency" in QualityDimension with
name
  de_name : "Effizienz";
  en_name : "Efficiency"
description
  de_desc : "Durchsatz, Zeit- und Verbrauchsverhalten des Transformationsprozesses"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Correctness" in QualityDimension with
name
  de_name : "Korrektheit";
  en_name : "Correctness"
description
  de_desc : "Korrektheit der Transformationsfunktionen und Bereinigungsprozesse"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Accuracy" in QualityDimension with
name
  de_name : "Genauigkeit";
  en_name : "Accuracy"
description
  de_desc : "Genauigkeit der transformierten oder bereinigten Daten"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Value-Added" in QualityDimension with
name
  de_name : "Mehrwert";
  en_name : "Value-Added"
description
  de_desc : "Grad der Verbesserung durch Transformation und Bereinigung"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Integration and Loading" in QualityCategory with
name
  de_name : "Integration und Laden";
  en_name : "Integration and Loading"
description
  de_desc : "Qualitätsmerkmale des Integrations- und Ladeprozesses"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Completeness" in QualityDimension with
name
  de_name : "Vollständigkeit";
  en_name : "Completeness"
description
  de_desc : "Grad, zu dem die Integrationsprozesse die vollständigen Daten integrieren"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Correctness" in QualityDimension with
name
  de_name : "Korrektheit";
  en_name : "Correctness"
description
  de_desc : "Korrektheit der Integrationsregeln und Ladevorschriften"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Traceability" in QualityDimension with
name
  de_name : "Nachvollziehbarkeit";
  en_name : "Traceability"
description
  de_desc : "Vorhandensein von Funktionen zum Nachvollziehen des tatsächlichen Ablaufs eines Integrationsprozesses und zum Ursprung der Daten"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Robustness" in QualityDimension with
name
  de_name : "Robustheit";
  en_name : "Robustness"
description
  de_desc : "Aufwand für Anpassungen im Integrations- und Ladeprozess aufgrund von Änderungen in den Datenquellen"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Flexibility" in QualityDimension with
name
  de_name : "Flexibilität";
  en_name : "Flexibility"
description
  de_desc : "Aufwand für Verbesserungen und Anpassungen des Integrations- und Ladeprozesses"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end



{---------------------------------------------------------
                    Telos Frames for qdim-dv.tex
 ---------------------------------------------------------}

"Data Processing" in QualityCategory with
name
  de_name : "Datenverarbeitung";
  en_name : "Data Processing"
description
  de_desc : "Speicherung und Bereitstellung der Daten"
end

"Data Processing -- Data Quality" in QualityCategory with
name
  de_name : "Datenqualität";
  en_name : "Data Quality"
description
  de_desc : "Qualitätsmerkmale eines Datenobjekts"
isSubDimOf
   mainCat : "Data Processing"
end

"Data Processing -- Data Quality -- Accuracy" in QualityDimension with
name
  de_name : "Genauigkeit";
  en_name : "Accuracy"
description
  de_desc : "Übereinstimmung des Datums mit dem tatsächlichem Wert"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Objectivity" in QualityDimension with
name
  de_name : "Objektivität";
  en_name : "Objectivity"
description
  de_desc : "Unbefangenheit und Objektivität bei der Erfassung"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Believability" in QualityDimension with
name
  de_name : "Glaubwürdigkeit";
  en_name : "Believability"
description
  de_desc : "Glaubwürdigkeit der Datenquelle/des Datenerfassers"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Reputation" in QualityDimension with
name
  de_name : "Vertrauenswürdigkeit";
  en_name : "Reputation"
description
  de_desc : "Ansehen der und Vertrauen in die Datenquelle"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Redundancy" in QualityDimension with
name
  de_name : "Redundanz";
  en_name : "Redundancy"
description
  de_desc : "Umfang von mehrfach enthaltenen Daten (z.B.\ Duplikate, Ableitbarkeit aus anderen Datenfeldern)"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Timeliness" in QualityDimension with
name
  de_name : "Aktualität";
  en_name : "Timeliness"
description
  de_desc : "Alter der Daten, Verhältnis zwischen Aktualisierungshäufigkeit des Datums und des realen Objekts"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Verifiability" in QualityDimension with
name
  de_name : "Überprüfbarkeit";
  en_name : "Verifiability"
description
  de_desc : "Überprüfbarkeit der Korrektheit der Daten"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Accessibility" in QualityCategory with
name
  de_name : "Zugriffsqualität";
  en_name : "Accessibility"
description
  de_desc : "Zugreifbarkeit der Daten"
isSubDimOf
   mainCat : "Data Processing"
end

"Data Processing -- Accessibility -- Possibilities for Access" in QualityDimension with
name
  de_name : "Möglichkeit";
  en_name : "Possibilities for Access"
description
  de_desc : "Angebotene Schnittstellen zu den Daten"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Security" in QualityDimension with
name
  de_name : "Sicherheit";
  en_name : "Security"
description
  de_desc : "Vorhandensein von Zugriffsbeschränkungen"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Availability" in QualityDimension with
name
  de_name : "Verfügbarkeit";
  en_name : "Availability"
description
  de_desc : "Verfügbarkeit des Systems"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Responsiveness" in QualityDimension with
name
  de_name : "Antwortverhalten";
  en_name : "Responsiveness"
description
  de_desc : "Antwort- und Bearbeitungszeiten für Anfragen"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Reliability" in QualityDimension with
name
  de_name : "Zuverlässigkeit";
  en_name : "Reliability"
description
  de_desc : "Fähigkeit des Systems, gleiche Antworten mit gleichbleibenden Antwortzeiten zu liefern"
isSubDimOf
   category : "Data Processing -- Accessibility"
end



{---------------------------------------------------------
                    Telos Frames for qdim-entwurf.tex
 ---------------------------------------------------------}

"Design" in QualityCategory with
name
  de_name : "Entwurf";
  en_name : "Design"
description
  de_desc : "Qualität des Entwurfs der Architektur und konzeptuellen Modelle"
end

"Design -- Architecture" in QualityCategory with
name
  de_name : "Architektur";
  en_name : "Architecture"
description
  de_desc : "Qualität der Architektur für das gesamte System und einzelne Programme"
isSubDimOf
   mainCat : "Design"
end

"Design -- Architecture -- Modifiability" in QualityDimension with
name
  de_name : "Modifizierbarkeit";
  en_name : "Modifiability"
description
  de_desc : "Anpassungsfähigkeit der Architektur an neue Anforderungen, Umgebung oder Bedingungen"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Reliability" in QualityDimension with
name
  de_name : "Ausfallsicherheit";
  en_name : "Reliability"
description
  de_desc : "Berücksichtigung von Systemausfällen in der Architektur (z.B.\ durch Bereitstellung von zwei gespiegelten Datenbanksystemen)"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Security" in QualityDimension with
name
  de_name : "Sicherheit";
  en_name : "Security"
description
  de_desc : "Berücksichtigung von Sicherheitsaspekten in der Architektur (z.B.\ Firewall, Zugriffskontrollen)"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Appropriateness" in QualityDimension with
name
  de_name : "Angemessenheit";
  en_name : "Appropriateness"
description
  de_desc : "Verhältnis zwischen angebotener Funktionalität und Anforderungen"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Efficiency" in QualityDimension with
name
  de_name : "Effizienz";
  en_name : "Efficiency"
description
  de_desc : "Verhältnis zwischen Nutzen und Aufwand"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Conceptual Models" in QualityCategory with
name
  de_name : "Konzeptuelle Modelle";
  en_name : "Conceptual Models"
description
  de_desc : "Qualität der konzeptuellen Datenmodelle der Datenquellen, des Data Warehouse und anderer Datenbanken"
isSubDimOf
   mainCat : "Design"
end

"Design -- Conceptual Models -- Correctness" in QualityDimension with
name
  de_name : "Korrektheit";
  en_name : "Correctness"
description
  de_desc : "Grad zu dem das Modell der Wirklichkeit entspricht"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Consistenz" in QualityDimension with
name
  de_name : "Konsistenz";
  en_name : "Consistenz"
description
  de_desc : "Freiheit von Widersprüchen innerhalb eines Modells oder in Bezug zu anderen Modellen"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Completeness" in QualityDimension with
name
  de_name : "Vollständigkeit";
  en_name : "Completeness"
description
  de_desc : "Vollständige Repräsentation der zu modellierenden Wirklichkeit"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Accuracy" in QualityDimension with
name
  de_name : "Genauigkeit";
  en_name : "Accuracy"
description
  de_desc : "Detaillierungsgrad der (formalen) Beschreibungen der Konzepte und Beziehungen"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Minimality" in QualityDimension with
name
  de_name : "Minimalität";
  en_name : "Minimality"
description
  de_desc : "Vermeidung von Redundanzen und unnötigen Konzepten bzw.\ Beziehungen"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Interpretability" in QualityDimension with
name
  de_name : "Interpretierbarkeit";
  en_name : "Interpretability"
description
  de_desc : "Verständlichkeit und Eindeutigkeit des Modells"
isSubDimOf
   category : "Design -- Conceptual Models"
end



{---------------------------------------------------------
                    Telos Frames for qdim-impl.tex
 ---------------------------------------------------------}

"Implementation" in QualityCategory with
name
  de_name : "Implementierung";
  en_name : "Implementation"
description
  de_desc : "Eigenschaften der Implementierung der Softwarekomponenten und Datenmodelle"
end

"Implementation -- Software Implementation" in QualityCategory with
name
  de_name : "Software-Implementierung";
  en_name : "Software Implementation"
description
  de_desc : "Eigenschaften der Implementierung der Softwarekomponenten"
isSubDimOf
   mainCat : "Implementation"
end

"Implementation -- Software Implementation -- Functionality" in QualityCategory with
name
  de_name : "Funktionalität";
  en_name : "Functionality"
description
  de_desc : "Vorhandensein einer Menge von Funktionen, die die Erfordernisse erfüllen"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Functionality -- Suitability" in QualityDimension with
name
  de_name : "Angemessenheit";
  en_name : "Suitability"
description
  de_desc : "Vorhandensein und Eignung von Funktionen für spezifizierte Aufgaben"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Accuracy" in QualityDimension with
name
  de_name : "Richtigkeit";
  en_name : "Accuracy"
description
  de_desc : "Lieferung der richtigen/vereinbarten Ergebnisse oder Wirkungen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Interoperability" in QualityDimension with
name
  de_name : "Interoperabilität";
  en_name : "Interoperability"
description
  de_desc : "Zusammenwirkung mit vorgegebenen Systemen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Compliance" in QualityDimension with
name
  de_name : "Ordnungsmäßigkeit";
  en_name : "Compliance"
description
  de_desc : "Erfüllung von Normen, Vereinbarungen oder gesetzl.\ Bestimmungen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Security" in QualityDimension with
name
  de_name : "Sicherheit";
  en_name : "Security"
description
  de_desc : "Eignung zur Verhinderung von unberichtigten Zugriffen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Reliability" in QualityCategory with
name
  de_name : "Zuverlässigkeit";
  en_name : "Reliability"
description
  de_desc : "Fähigkeit das Leistungsniveau unter festgelegten Bedingungen über einen festgelegten Zeitraum zu bewahren"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Reliability -- Maturity" in QualityDimension with
name
  de_name : "Reife";
  en_name : "Maturity"
description
  de_desc : "Häufigkeit von Fehlern durch Fehlzustände in der Software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Reliability -- Fault Tolerance" in QualityDimension with
name
  de_name : "Fehlertoleranz";
  en_name : "Fault Tolerance"
description
  de_desc : "Eignung ein Leistungsniveau bei Software-Fehlern oder Nicht-Einhaltung der Spezifikation zu bewahren"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Reliability -- Recoverability" in QualityDimension with
name
  de_name : "Wiederherstell\-barkeit";
  en_name : "Recoverability"
description
  de_desc : "Möglichkeiten bei Fehlern das Leistungsniveau und die benötigten Daten wiederherzustellen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Usability" in QualityCategory with
name
  de_name : "Benutzbarkeit";
  en_name : "Usability"
description
  de_desc : "Für die Benutzung erforderlicher Aufwand und Bewertung durch eine Gruppe von Benutzern"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Usability -- Understandability" in QualityDimension with
name
  de_name : "Verständlichkeit";
  en_name : "Understandability"
description
  de_desc : "Zum Verständnis der Anwendung erforderlicher Aufwand"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Usability -- Learnability" in QualityDimension with
name
  de_name : "Erlernbarkeit";
  en_name : "Learnability"
description
  de_desc : "Lernaufwand für die Benutzer"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Usability -- Operability" in QualityDimension with
name
  de_name : "Bedienbarkeit";
  en_name : "Operability"
description
  de_desc : "Aufwand zur Bedienung und Ablaufsteuerung"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Efficiency" in QualityCategory with
name
  de_name : "Effizienz";
  en_name : "Efficiency"
description
  de_desc : "Verhältnis zwischen Leistungsniveau und Umfang der eingesetzten Betriebsmittel"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Efficiency -- Time behavior" in QualityDimension with
name
  de_name : "Zeitverhalten";
  en_name : "Time behavior"
description
  de_desc : "Antwort- und Verarbeitungszeiten und Durchsatz bei Ausführung der Funktionen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Efficiency"
end

"Implementation -- Software Implementation -- Efficiency -- Resource Behavior" in QualityDimension with
name
  de_name : "Verbrauchsverhalten";
  en_name : "Resource Behavior"
description
  de_desc : "Zur Erfüllung der Funktionen benötigte Betriebsmittel"
isSubDimOf
   category : "Implementation -- Software Implementation -- Efficiency"
end

"Implementation -- Software Implementation -- Maintainability" in QualityCategory with
name
  de_name : "Änderbarkeit";
  en_name : "Maintainability"
description
  de_desc : "Aufwand zur Durchführung von Änderungen"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Maintainability -- Analyzability" in QualityDimension with
name
  de_name : "Analysierbarkeit";
  en_name : "Analyzability"
description
  de_desc : "Aufwand zur Bestimmung von Mängeln oder Ursachen von Fehlern"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Changeability" in QualityDimension with
name
  de_name : "Modifizierbarkeit";
  en_name : "Changeability"
description
  de_desc : "Aufwand zur Verbesserung, Fehlerbeseitigung oder Anpassung an Umgebungsänderungen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Stability" in QualityDimension with
name
  de_name : "Stabilität";
  en_name : "Stability"
description
  de_desc : "Risiko unerwarteter Wirkungen von Änderungen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Testability" in QualityDimension with
name
  de_name : "Prüfbarkeit";
  en_name : "Testability"
description
  de_desc : "Aufwand zur Prüfung geänderter Software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Portability" in QualityCategory with
name
  de_name : "Übertragbarkeit";
  en_name : "Portability"
description
  de_desc : "Eignung der Software, von einer Umgebung in eine andere übertragen zu werden"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Portability -- Adaptability" in QualityDimension with
name
  de_name : "Anpassbarkeit";
  en_name : "Adaptability"
description
  de_desc : "Möglichkeiten zur Anpassung an verschiedene Umgebungen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Installability" in QualityDimension with
name
  de_name : "Installierbarkeit";
  en_name : "Installability"
description
  de_desc : "Aufwand zur Installierung der Software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Conformance" in QualityDimension with
name
  de_name : "Konformität";
  en_name : "Conformance"
description
  de_desc : "Erfüllung von Normen oder Vereinbarungen zur Übertragbarkeit"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Replaceabilitty" in QualityDimension with
name
  de_name : "Austauschbarkeit";
  en_name : "Replaceabilitty"
description
  de_desc : "Möglichkeit und Aufwand zur Verwendung der Software anstelle einer anderen"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Implementation of Data Models" in QualityCategory with
name
  de_name : "Implementierung der Datenmodelle";
  en_name : "Implementation of Data Models"
description
  de_desc : "Eigenschaften der Implementierung der Datenmodelle"
isSubDimOf
   mainCat : "Implementation"
end

"Implementation -- Implementation of Data Models -- Correctness" in QualityDimension with
name
  de_name : "Korrektheit";
  en_name : "Correctness"
description
  de_desc : "Korrektheit der Umsetzung"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Completeness" in QualityDimension with
name
  de_name : "Vollständigkeit";
  en_name : "Completeness"
description
  de_desc : "Vollständige Repräsentation der konzeptuellen Modelle"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Efficiency" in QualityDimension with
name
  de_name : "Effizienz";
  en_name : "Efficiency"
description
  de_desc : "Effizienz des Ergebnisses"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Appropriateness" in QualityDimension with
name
  de_name : "Angemessenheit";
  en_name : "Appropriateness"
description
  de_desc : "Angemessene Darstellung der Konzepte (z.B.\ sinnvolle Datentypen)"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end



{---------------------------------------------------------
                    Telos Frames for qdim-usage.tex
 ---------------------------------------------------------}

"Data Usage" in QualityCategory with
name
  de_name : "Datennutzung";
  en_name : "Data Usage"
description
  de_desc : "Eignung der Daten zur Nutzung in bestimmten Kontexten"
end

"Data Usage -- Contextual Data Quality" in QualityCategory with
name
  de_name : "Kontextuelle Datenqualität";
  en_name : "Contextual Data Quality"
description
  de_desc : "Qualitätsmerkmale von Datenobjekten im Kontext einer Anwendung"
isSubDimOf
   mainCat : "Data Usage"
end

"Data Usage -- Contextual Data Quality -- Relevancy" in QualityDimension with
name
  de_name : "Relevanz";
  en_name : "Relevancy"
description
  de_desc : "Anwendbarkeit und Nützlichkeit der Daten in der Anwendung"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Value-Added" in QualityDimension with
name
  de_name : "Mehrwert";
  en_name : "Value-Added"
description
  de_desc : "Zusatznutzen der Daten für die Anwendung"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Timeliness" in QualityDimension with
name
  de_name : "Aktualität";
  en_name : "Timeliness"
description
  de_desc : "Verhältnis zwischen tatsächlicher und notwendiger Aktualität"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Completeness" in QualityDimension with
name
  de_name : "Vollständigkeit";
  en_name : "Completeness"
description
  de_desc : "Umfang und Vollständigkeit der Daten"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Appropriate amount of data" in QualityDimension with
name
  de_name : "Informationsgehalt";
  en_name : "Appropriate amount of data"
description
  de_desc : "Passende Menge der Daten für die Anwendung"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Representational Data Quality" in QualityCategory with
name
  de_name : "Darstellungsqualität";
  en_name : "Representational Data Quality"
description
  de_desc : "Eignung der Darstellung der Daten für bestimmte Anwendungen"
isSubDimOf
   mainCat : "Data Usage"
end

"Data Usage -- Representational Data Quality -- Suitability" in QualityDimension with
name
  de_name : "Angemessenheit";
  en_name : "Suitability"
description
  de_desc : "Angemessene Darstellung der Daten für Anwendungszweck"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Interpretability" in QualityDimension with
name
  de_name : "Interpretierbarkeit";
  en_name : "Interpretability"
description
  de_desc : "Vorhandensein von Interpretationshilfen und Dokumentation in der Darstellung"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Understandability" in QualityDimension with
name
  de_name : "Verständlichkeit";
  en_name : "Understandability"
description
  de_desc : "Aufwand zum Verstehen der Darstellung"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Conciseveness" in QualityDimension with
name
  de_name : "Prägnanz";
  en_name : "Conciseveness"
description
  de_desc : "Verhältnis zwischen Menge der Informationen und Darstellungsgröße"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Consistency" in QualityDimension with
name
  de_name : "Konsistenz";
  en_name : "Consistency"
description
  de_desc : "Eignung der Darstellung die Daten im gleichen Format anzuzeigen"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Adaptability" in QualityDimension with
name
  de_name : "Anpassungsfähigkeit";
  en_name : "Adaptability"
description
  de_desc : "Eignung zur Anpassung der Darstellung an neue Kriterien"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Usability" in QualityDimension with
name
  de_name : "Benutzbarkeit";
  en_name : "Usability"
description
  de_desc : "Für die Benutzung erforderlicher Aufwand und Bewertung durch eine Gruppe von Benutzern"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end



