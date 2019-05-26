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

{ Sources }

Source StatisticsDepartment end

{ Conceptual}

SourceModel StatisticsDepartmentModel with
isModelOf
	modelOf : StatisticsDepartment
end


AtomicConcept Citizen with
refersTo
	refTo : StatisticsDepartmentModel
end

{ Logical }

SourceSchema StatisticsDepartmentSchema in RelationalSchema with
isSchemaOf
	schemaOf : StatisticsDepartment
end


Relation CitizenRelation with
isViewOn
	viewOn : Citizen
refersTo
	refTo : StatisticsDepartmentSchema
end


{ Physical }

SourceDataStore StatisticsDepartmentDataStore with
isStoreOf
	storeOf : StatisticsDepartment
hasSchema
	schema : StatisticsDepartmentSchema
end


{ QualityFactorTypes }


SchemaUsefulness0 in QualityFactorType with
dimension
	dimension : "Data Usage -- Representational Data Quality -- Usability"
onObject
	onObject : Schema
expected
	expected : "P[Boolean]"
achieved
	achieved : Boolean
comment
	com : "Is the schema useful for some query"
end


ConceptSchemaCompleteness1 in QualityFactorType with
dimension
	dimension : "Design -- Conceptual Models -- Completeness"
onObject
	onObject : Concept
expected
	expected : "P(Integer)"
achieved
	achieved : Integer
comment
	com : "% instances represented in source/enterprise"
end

DataStoreTimeliness in QualityFactorType with
dimension
        dimension : "Data Processing -- Data Quality -- Timeliness"
onObject
        onObject : DataStore
expected
        expected : "P[0;100]"
achieved
        achieved : "[0;100]"
comment
        com : "% invalid tuples due to age"
when
        when : DateTime
end



{ QualityFactors on Timeliness of Data Stores }

QueryClass "[0:10]" in "P[0;100]" isA Integer with
constraint
	c : $ (this <= 10) and (this >= 0) $
end

QueryClass "[0:20]" in "P[0;100]" isA Integer with
constraint
	c : $ (this <= 20) and (this >= 0) $
end

QueryClass "[0:2]" in "P[0;100]" isA Integer with
constraint
	c : $ (this <= 2) and (this >= 0) $
end

QueryClass "[0:5]" in "P[0;100]" isA Integer with
constraint
	c : $ (this <= 5) and (this >= 0) $
end



StatisticsDepartmentTimeliness in DataStoreTimeliness with
onObject
	on : StatisticsDepartmentDataStore
expected
	exp : "[0:10]"
achieved
	ach : 6
when
	date : "Feb 12, 2003"
graphtype
	gt3232 : GoodQualityFactorGT
end

StatisticsDepartmentTimeliness2 in DataStoreTimeliness with
onObject
	on : StatisticsDepartmentDataStore
expected
	exp : "[0:10]"
achieved
	ach : 12
when
	date : "Feb 18, 2003"
graphtype
	gt1231 : BadQualityFactorGT
end

"Feb 18, 2003" in DateTime end
"Feb 12, 2003" in DateTime end


{ Quality Factors for Usefulness of Schemas }

"{TRUE}" in "P[Boolean]"
end


StatisticsDepartmentSchemaUsefulness in SchemaUsefulness0 with
onObject
	on : StatisticsDepartmentSchema
expected
	exp : "{TRUE}"
achieved
	ach : TRUE
comment
	com : "This schema is useful because, it has information about professions, age, etc."
end


QueryClass "[50:100]" in "P(Integer)" isA Integer with
constraint
	c : $ (this <= 100) and (this >= 50) $
end

QueryClass "[90:100]" in "P(Integer)" isA Integer with
constraint
	c : $ (this <= 100) and (this >= 90) $
end
QueryClass "[95:100]" in "P(Integer)" isA Integer with
constraint
	c : $ (this <= 100) and (this >= 95) $
end




CitizenCompleteness in ConceptSchemaCompleteness1 with
onObject
	onObject : Citizen
expected
	exp : "[50:100]"
achieved
	ach : 80
comment
	com : "This factor measures, how many customers of the enterprise are in represented in the statistics dept."
end


6 in "[0;100]" end
1 in "[0;100]" end
12 in "[0;100]" end
17 in "[0;100]" end
80 in "[0;100]" end
90 in "[0;100]" end
98 in "[0;100]" end


{ Goals and Goal Types }


QualityGoalType AchieveMoreCurrentData with
description
        description : "Not more than a certain percentage of data may become invalid due to age"
direction
        dir : Achieve
imposedOn
        imposedOn : DataStore
forPerson
        forPerson : DecisionMaker
dimension
        dim : "Data Processing -- Data Quality -- Timeliness"
concreteBy
        concreteBy : "Which Data Stores have a volatility outside the expected range?"
end


"Which Data Stores have a volatility outside the expected range?" in QualityQuestionType with
implementedBy
        implementedBy : BadVolatilityOfDataStores
evaluates
        eval : DataStoreTimeliness
end

View BadVolatilityOfDataStores in QualityQuery isA DataStoreTimeliness with
constraint
        c: $ exists i/Integer s/"P[0;100]" (this achieved i) and (this expected s) and not (i in s) $
end


"John Doe" in DecisionMaker end

AchieveMoreCurrentData MoreCurrentDataInStatisticsDepartment with
imposedOn
        obj : StatisticsDepartmentDataStore
forPerson
        person : "John Doe"
end

