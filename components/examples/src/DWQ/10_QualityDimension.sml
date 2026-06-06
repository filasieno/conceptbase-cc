{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{---------------------------------------------------------
                    Telos Frames for qdim-admin.tex
 ---------------------------------------------------------}

"Administration and Maintenance" in QualityCategory with
name
  en_name : "Administration and Maintenance"
description
  en_desc : "Availability of functions and their suitability for system administration and maintenance"
end

"Administration and Maintenance -- Reporting" in QualityDimension with
name
  en_name : "Reporting"
description
  en_desc : "Ability of the system to generate reports on operations performed, changes made, and events that occurred"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Ability to document" in QualityDimension with
name
  en_name : "Ability to document"
description
  en_desc : "Ability and effort required to document operations performed and changes made"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Metadata Availability" in QualityDimension with
name
  en_name : "Metadata Availability"
description
  en_desc : "Availability of functions for querying metadata of system components"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Effectivity" in QualityDimension with
name
  en_name : "Effectivity"
description
  en_desc : "Effort required to perform necessary tasks"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Analyzability" in QualityDimension with
name
  en_name : "Analyzability"
description
  en_desc : "Effort required to identify deficiencies or causes of errors"
isSubDimOf
   category : "Administration and Maintenance"
end

"Administration and Maintenance -- Instrumentation" in QualityDimension with
name
  en_name : "Instrumentation"
description
  en_desc : "Scope of available tools and functions"
isSubDimOf
   category : "Administration and Maintenance"
end



{---------------------------------------------------------
                    Telos Frames for qdim-besch.tex
 ---------------------------------------------------------}

"Data Integration (ETL-Process)" in QualityCategory with
name
  en_name : "Data Integration (ETL-Process)"
description
  en_desc : "Extraction, transformation, integration, and loading of data into the data warehouse"
end

"Data Integration (ETL-Process) -- Extraction" in QualityCategory with
name
  en_name : "Extraction"
description
  en_desc : "Quality characteristics of the extraction process"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Extraction -- Completeness" in QualityDimension with
name
  en_name : "Completeness"
description
  en_desc : "Ratio between extracted and available data"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Extraction -- Efficiency" in QualityDimension with
name
  en_name : "Efficiency"
description
  en_desc : "Throughput, time, and resource consumption behavior of the extraction process"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Extraction -- Traceability" in QualityDimension with
name
  en_name : "Traceability"
description
  en_desc : "Availability of functions for tracing the actual flow of an extraction process"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Extraction"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning" in QualityCategory with
name
  en_name : "Transformation and Cleaning"
description
  en_desc : "Quality characteristics of the transformation and cleansing process"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Efficiency" in QualityDimension with
name
  en_name : "Efficiency"
description
  en_desc : "Throughput, time, and resource consumption behavior of the transformation process"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Correctness" in QualityDimension with
name
  en_name : "Correctness"
description
  en_desc : "Correctness of transformation functions and cleansing processes"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Accuracy" in QualityDimension with
name
  en_name : "Accuracy"
description
  en_desc : "Accuracy of transformed or cleansed data"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Transformation and Cleaning -- Value-Added" in QualityDimension with
name
  en_name : "Value-Added"
description
  en_desc : "Degree of improvement achieved through transformation and cleansing"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Transformation and Cleaning"
end

"Data Integration (ETL-Process) -- Integration and Loading" in QualityCategory with
name
  en_name : "Integration and Loading"
description
  en_desc : "Quality characteristics of the integration and loading process"
isSubDimOf
   mainCat : "Data Integration (ETL-Process)"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Completeness" in QualityDimension with
name
  en_name : "Completeness"
description
  en_desc : "Degree to which integration processes integrate complete data"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Correctness" in QualityDimension with
name
  en_name : "Correctness"
description
  en_desc : "Correctness of integration rules and loading specifications"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Traceability" in QualityDimension with
name
  en_name : "Traceability"
description
  en_desc : "Availability of functions for tracing the actual flow of an integration process and the origin of data"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Robustness" in QualityDimension with
name
  en_name : "Robustness"
description
  en_desc : "Effort required for adjustments in the integration and loading process due to changes in data sources"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end

"Data Integration (ETL-Process) -- Integration and Loading -- Flexibility" in QualityDimension with
name
  en_name : "Flexibility"
description
  en_desc : "Effort required for improvements and adjustments to the integration and loading process"
isSubDimOf
   category : "Data Integration (ETL-Process) -- Integration and Loading"
end



{---------------------------------------------------------
                    Telos Frames for qdim-dv.tex
 ---------------------------------------------------------}

"Data Processing" in QualityCategory with
name
  en_name : "Data Processing"
description
  en_desc : "Storage and provision of data"
end

"Data Processing -- Data Quality" in QualityCategory with
name
  en_name : "Data Quality"
description
  en_desc : "Quality characteristics of a data object"
isSubDimOf
   mainCat : "Data Processing"
end

"Data Processing -- Data Quality -- Accuracy" in QualityDimension with
name
  en_name : "Accuracy"
description
  en_desc : "Agreement of the data with the actual value"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Objectivity" in QualityDimension with
name
  en_name : "Objectivity"
description
  en_desc : "Impartiality and objectivity in data capture"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Believability" in QualityDimension with
name
  en_name : "Believability"
description
  en_desc : "Credibility of the data source/data collector"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Reputation" in QualityDimension with
name
  en_name : "Reputation"
description
  en_desc : "Reputation of and trust in the data source"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Redundancy" in QualityDimension with
name
  en_name : "Redundancy"
description
  en_desc : "Extent of multiply contained data (e.g.\ duplicates, derivability from other data fields)"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Timeliness" in QualityDimension with
name
  en_name : "Timeliness"
description
  en_desc : "Age of the data, ratio between update frequency of the data and the real-world object"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Data Quality -- Verifiability" in QualityDimension with
name
  en_name : "Verifiability"
description
  en_desc : "Verifiability of data correctness"
isSubDimOf
   category : "Data Processing -- Data Quality"
end

"Data Processing -- Accessibility" in QualityCategory with
name
  en_name : "Accessibility"
description
  en_desc : "Accessibility of the data"
isSubDimOf
   mainCat : "Data Processing"
end

"Data Processing -- Accessibility -- Possibilities for Access" in QualityDimension with
name
  en_name : "Possibilities for Access"
description
  en_desc : "Interfaces offered for accessing the data"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Security" in QualityDimension with
name
  en_name : "Security"
description
  en_desc : "Availability of access restrictions"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Availability" in QualityDimension with
name
  en_name : "Availability"
description
  en_desc : "Availability of the system"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Responsiveness" in QualityDimension with
name
  en_name : "Responsiveness"
description
  en_desc : "Response and processing times for requests"
isSubDimOf
   category : "Data Processing -- Accessibility"
end

"Data Processing -- Accessibility -- Reliability" in QualityDimension with
name
  en_name : "Reliability"
description
  en_desc : "Ability of the system to deliver consistent answers with stable response times"
isSubDimOf
   category : "Data Processing -- Accessibility"
end



{---------------------------------------------------------
                    Telos Frames for qdim-entwurf.tex
 ---------------------------------------------------------}

"Design" in QualityCategory with
name
  en_name : "Design"
description
  en_desc : "Quality of the design of the architecture and conceptual models"
end

"Design -- Architecture" in QualityCategory with
name
  en_name : "Architecture"
description
  en_desc : "Quality of the architecture for the overall system and individual programs"
isSubDimOf
   mainCat : "Design"
end

"Design -- Architecture -- Modifiability" in QualityDimension with
name
  en_name : "Modifiability"
description
  en_desc : "Adaptability of the architecture to new requirements, environment, or conditions"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Reliability" in QualityDimension with
name
  en_name : "Reliability"
description
  en_desc : "Consideration of system failures in the architecture (e.g.\ by providing two mirrored database systems)"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Security" in QualityDimension with
name
  en_name : "Security"
description
  en_desc : "Consideration of security aspects in the architecture (e.g.\ firewall, access controls)"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Appropriateness" in QualityDimension with
name
  en_name : "Appropriateness"
description
  en_desc : "Ratio between provided functionality and requirements"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Architecture -- Efficiency" in QualityDimension with
name
  en_name : "Efficiency"
description
  en_desc : "Ratio between benefit and effort"
isSubDimOf
   category : "Design -- Architecture"
end

"Design -- Conceptual Models" in QualityCategory with
name
  en_name : "Conceptual Models"
description
  en_desc : "Quality of the conceptual data models of data sources, the data warehouse, and other databases"
isSubDimOf
   mainCat : "Design"
end

"Design -- Conceptual Models -- Correctness" in QualityDimension with
name
  en_name : "Correctness"
description
  en_desc : "Degree to which the model corresponds to reality"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Consistency" in QualityDimension with
name
  en_name : "Consistency"
description
  en_desc : "Freedom from contradictions within a model or in relation to other models"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Completeness" in QualityDimension with
name
  en_name : "Completeness"
description
  en_desc : "Complete representation of the reality to be modeled"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Accuracy" in QualityDimension with
name
  en_name : "Accuracy"
description
  en_desc : "Level of detail of the (formal) descriptions of concepts and relationships"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Minimality" in QualityDimension with
name
  en_name : "Minimality"
description
  en_desc : "Avoidance of redundancies and unnecessary concepts or relationships"
isSubDimOf
   category : "Design -- Conceptual Models"
end

"Design -- Conceptual Models -- Interpretability" in QualityDimension with
name
  en_name : "Interpretability"
description
  en_desc : "Understandability and unambiguity of the model"
isSubDimOf
   category : "Design -- Conceptual Models"
end



{---------------------------------------------------------
                    Telos Frames for qdim-impl.tex
 ---------------------------------------------------------}

"Implementation" in QualityCategory with
name
  en_name : "Implementation"
description
  en_desc : "Properties of the implementation of software components and data models"
end

"Implementation -- Software Implementation" in QualityCategory with
name
  en_name : "Software Implementation"
description
  en_desc : "Properties of the implementation of software components"
isSubDimOf
   mainCat : "Implementation"
end

"Implementation -- Software Implementation -- Functionality" in QualityCategory with
name
  en_name : "Functionality"
description
  en_desc : "Availability of a set of functions that meet the requirements"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Functionality -- Suitability" in QualityDimension with
name
  en_name : "Suitability"
description
  en_desc : "Availability and suitability of functions for specified tasks"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Accuracy" in QualityDimension with
name
  en_name : "Accuracy"
description
  en_desc : "Delivery of correct/agreed results or effects"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Interoperability" in QualityDimension with
name
  en_name : "Interoperability"
description
  en_desc : "Interoperation with specified systems"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Compliance" in QualityDimension with
name
  en_name : "Compliance"
description
  en_desc : "Compliance with standards, agreements, or legal regulations"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Functionality -- Security" in QualityDimension with
name
  en_name : "Security"
description
  en_desc : "Suitability for preventing unauthorized access"
isSubDimOf
   category : "Implementation -- Software Implementation -- Functionality"
end

"Implementation -- Software Implementation -- Reliability" in QualityCategory with
name
  en_name : "Reliability"
description
  en_desc : "Ability to maintain the level of performance under specified conditions over a specified period"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Reliability -- Maturity" in QualityDimension with
name
  en_name : "Maturity"
description
  en_desc : "Frequency of failures due to fault conditions in the software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Reliability -- Fault Tolerance" in QualityDimension with
name
  en_name : "Fault Tolerance"
description
  en_desc : "Suitability for maintaining a level of performance in the event of software faults or non-compliance with the specification"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Reliability -- Recoverability" in QualityDimension with
name
  en_name : "Recoverability"
description
  en_desc : "Ability to restore the level of performance and required data in the event of failures"
isSubDimOf
   category : "Implementation -- Software Implementation -- Reliability"
end

"Implementation -- Software Implementation -- Usability" in QualityCategory with
name
  en_name : "Usability"
description
  en_desc : "Effort required for use and assessment by a group of users"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Usability -- Understandability" in QualityDimension with
name
  en_name : "Understandability"
description
  en_desc : "Effort required to understand the application"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Usability -- Learnability" in QualityDimension with
name
  en_name : "Learnability"
description
  en_desc : "Learning effort for users"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Usability -- Operability" in QualityDimension with
name
  en_name : "Operability"
description
  en_desc : "Effort required for operation and flow control"
isSubDimOf
   category : "Implementation -- Software Implementation -- Usability"
end

"Implementation -- Software Implementation -- Efficiency" in QualityCategory with
name
  en_name : "Efficiency"
description
  en_desc : "Ratio between level of performance and amount of resources used"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Efficiency -- Time behavior" in QualityDimension with
name
  en_name : "Time behavior"
description
  en_desc : "Response and processing times and throughput when executing functions"
isSubDimOf
   category : "Implementation -- Software Implementation -- Efficiency"
end

"Implementation -- Software Implementation -- Efficiency -- Resource Behavior" in QualityDimension with
name
  en_name : "Resource Behavior"
description
  en_desc : "Resources required to perform the functions"
isSubDimOf
   category : "Implementation -- Software Implementation -- Efficiency"
end

"Implementation -- Software Implementation -- Maintainability" in QualityCategory with
name
  en_name : "Maintainability"
description
  en_desc : "Effort required to implement changes"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Maintainability -- Analyzability" in QualityDimension with
name
  en_name : "Analyzability"
description
  en_desc : "Effort required to identify deficiencies or causes of errors"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Changeability" in QualityDimension with
name
  en_name : "Changeability"
description
  en_desc : "Effort required for improvement, defect removal, or adaptation to environmental changes"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Stability" in QualityDimension with
name
  en_name : "Stability"
description
  en_desc : "Risk of unexpected effects from changes"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Maintainability -- Testability" in QualityDimension with
name
  en_name : "Testability"
description
  en_desc : "Effort required to test modified software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Maintainability"
end

"Implementation -- Software Implementation -- Portability" in QualityCategory with
name
  en_name : "Portability"
description
  en_desc : "Suitability of the software to be transferred from one environment to another"
isSubDimOf
   mainCat : "Implementation -- Software Implementation"
end

"Implementation -- Software Implementation -- Portability -- Adaptability" in QualityDimension with
name
  en_name : "Adaptability"
description
  en_desc : "Options for adaptation to different environments"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Installability" in QualityDimension with
name
  en_name : "Installability"
description
  en_desc : "Effort required to install the software"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Conformance" in QualityDimension with
name
  en_name : "Conformance"
description
  en_desc : "Compliance with standards or agreements on portability"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Software Implementation -- Portability -- Replaceabilitty" in QualityDimension with
name
  en_name : "Replaceabilitty"
description
  en_desc : "Feasibility and effort to use the software in place of another"
isSubDimOf
   category : "Implementation -- Software Implementation -- Portability"
end

"Implementation -- Implementation of Data Models" in QualityCategory with
name
  en_name : "Implementation of Data Models"
description
  en_desc : "Properties of the implementation of data models"
isSubDimOf
   mainCat : "Implementation"
end

"Implementation -- Implementation of Data Models -- Correctness" in QualityDimension with
name
  en_name : "Correctness"
description
  en_desc : "Correctness of the implementation"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Completeness" in QualityDimension with
name
  en_name : "Completeness"
description
  en_desc : "Complete representation of the conceptual models"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Efficiency" in QualityDimension with
name
  en_name : "Efficiency"
description
  en_desc : "Efficiency of the result"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end

"Implementation -- Implementation of Data Models -- Appropriateness" in QualityDimension with
name
  en_name : "Appropriateness"
description
  en_desc : "Appropriate representation of concepts (e.g.\ meaningful data types)"
isSubDimOf
   category : "Implementation -- Implementation of Data Models"
end



{---------------------------------------------------------
                    Telos Frames for qdim-usage.tex
 ---------------------------------------------------------}

"Data Usage" in QualityCategory with
name
  en_name : "Data Usage"
description
  en_desc : "Suitability of the data for use in specific contexts"
end

"Data Usage -- Contextual Data Quality" in QualityCategory with
name
  en_name : "Contextual Data Quality"
description
  en_desc : "Quality characteristics of data objects in the context of an application"
isSubDimOf
   mainCat : "Data Usage"
end

"Data Usage -- Contextual Data Quality -- Relevancy" in QualityDimension with
name
  en_name : "Relevancy"
description
  en_desc : "Applicability and usefulness of the data in the application"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Value-Added" in QualityDimension with
name
  en_name : "Value-Added"
description
  en_desc : "Added value of the data for the application"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Timeliness" in QualityDimension with
name
  en_name : "Timeliness"
description
  en_desc : "Ratio between actual and required timeliness"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Completeness" in QualityDimension with
name
  en_name : "Completeness"
description
  en_desc : "Scope and completeness of the data"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Contextual Data Quality -- Appropriate amount of data" in QualityDimension with
name
  en_name : "Appropriate amount of data"
description
  en_desc : "Appropriate amount of data for the application"
isSubDimOf
   category : "Data Usage -- Contextual Data Quality"
end

"Data Usage -- Representational Data Quality" in QualityCategory with
name
  en_name : "Representational Data Quality"
description
  en_desc : "Suitability of the data representation for specific applications"
isSubDimOf
   mainCat : "Data Usage"
end

"Data Usage -- Representational Data Quality -- Suitability" in QualityDimension with
name
  en_name : "Suitability"
description
  en_desc : "Appropriate representation of the data for the application purpose"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Interpretability" in QualityDimension with
name
  en_name : "Interpretability"
description
  en_desc : "Availability of interpretation aids and documentation in the representation"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Understandability" in QualityDimension with
name
  en_name : "Understandability"
description
  en_desc : "Effort required to understand the representation"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Conciseveness" in QualityDimension with
name
  en_name : "Conciseveness"
description
  en_desc : "Ratio between amount of information and representation size"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Consistency" in QualityDimension with
name
  en_name : "Consistency"
description
  en_desc : "Suitability of the representation for displaying data in the same format"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Adaptability" in QualityDimension with
name
  en_name : "Adaptability"
description
  en_desc : "Suitability for adapting the representation to new criteria"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end

"Data Usage -- Representational Data Quality -- Usability" in QualityDimension with
name
  en_name : "Usability"
description
  en_desc : "Effort required for use and assessment by a group of users"
isSubDimOf
   category : "Data Usage -- Representational Data Quality"
end



