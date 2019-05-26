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

{ Graphical Types for MetametaClasses }

QualityMetametaGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Rect";
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 40
end

ObjectType with
graphtype
	gt : QualityMetametaGT
end

PowerSet with
graphtype
	gt : QualityMetametaGT
end



{ GraphicalTypes for MetaClasses }

QualityMetaGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Rect";
	bgcolor : "211,211,211";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 41
end

QualityGoalTypeGT in JavaGraphicalType with
implementedBy
	implBy : "i5.cb.graph.cbeditor.tests.QualityGoal"
priority
    pr : 55
end

QualityGoalType with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/QualityGoalType (g graphtype QualityGoalTypeGT) $;
	metagtrule : $ forall x/VAR (exists c/QualityGoalType In(x,c)) ==> (x graphtype QualityObjectGT) $
end

QualityQuestionType with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/QualityQuestionType (g graphtype QualityClassGT) $;
	metagtrule : $ forall x/VAR (exists c/QualityQuestionType In (x,c)) ==> (x graphtype QualityObjectGT) $
end

Purpose  with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall p/Purpose (p graphtype QualityClassGT) $
end

QualityQuery  with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/QualityQuery (g graphtype QualityClassGT) $
end

QualityDomainType with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/QualityDomainType (g graphtype QualityClassGT) $;
	metagtrule : $ forall x/VAR (exists c/QualityDomainType In (x,c)) ==> (x graphtype QualityObjectGT) $
end

MetricUnit with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/MetricUnit (g graphtype QualityClassGT) $
end

TimestampType  with
graphtype
	gt : QualityMetaGT
rule
	gtrule : $ forall g/TimestampType (g graphtype QualityClassGT) $
{;	metagtrule : $ forall x/VAR (exists c/TimestampType In (x,c)) ==> (x
graphtype QualityObjectGT) $ }
end

{ StakeholderType }

Class StakeholderInstGT in JavaGraphicalType with
rule
	r: $ forall x/VAR (exists s/StakeholderType In(x,s)) ==> (x graphtype StakeholderInstGT) $
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/stakeholderinst.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

Class StakeholderGT in JavaGraphicalType with
rule
	r: $ forall s/StakeholderType (s graphtype StakeholderGT) $
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/stakeholder.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

Class StakeholderTypeGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/stakeholdertype.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

StakeholderType with
graphtype
	gt : StakeholderTypeGT
end


{ QualityDimension }
QualityDimensionGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Ellipse";
	bgcolor : "211,211,211";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end

QualityDimension with
graphtype
	gt : QualityDimensionGT
end

Class InstanceOfQualityDimensionGT in JavaGraphicalType with
rule
        gtrule : $ forall t/QualityDimension (t graphtype InstanceOfQualityDimensionGT) $
property
	shape : "i5.cb.graph.shapes.Ellipse";
	bgcolor : "122,122,122";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end


{ QualityFactors }
QualityFactorTypeGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Diamond";
	bgcolor : "211,211,211";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "120x40"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end

QualityFactorType with
graphtype
	gt : QualityFactorTypeGT
end

Class QualityFactorGT in JavaGraphicalType with
rule
	r: $ forall q/QualityFactorType (q graphtype QualityFactorGT) $
{ property
	shape : "i5.cb.graph.shapes.Diamond";
	bgcolor : "122,122,122";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "120x40"
}
implementedBy
	implBy : "i5.cb.graph.cbeditor.tests.QualityFactor"
priority
    pr : 43
end




{Graphical Types for second level }

Class QualityClassGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Rect";
	bgcolor : "122,122,122";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end

{Graphical Types for third level }

Class QualityObjectGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Rect";
	bgcolor : "0,0,0";
	textcolor : "255,255,255";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end

{ Graphical type for quality factors, which do not }
{ fulfil the quality requirements. Background is red. }
BadQualityFactorGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Diamond";
	bgcolor : "255,50,50";
	textcolor : "0,0,0";
	linecolor : "0,0,255";
    size : "130x45"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end


{ Graphical type for all good quality factors }
GoodQualityFactorGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.Diamond";
	bgcolor : "0,0,0";
	textcolor : "255,255,255";
	linecolor : "0,0,0";
	size : "130x45"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 43
end

DWQ_Palette with
contains
	c40 : QualityMetametaGT;
	c41 : QualityMetaGT;
	c42 : StakeholderTypeGT;
	c42a : StakeholderInstGT;
	c42b : StakeholderGT;
	c43 : QualityDimensionGT;
	c44 : InstanceOfQualityDimensionGT;
	c45 : QualityFactorTypeGT;
	c46 : QualityFactorGT;
	c47 : QualityClassGT;
	c47b : QualityObjectGT;
	c48 : BadQualityFactorGT;
	c49 : GoodQualityFactorGT;
	c50 : QualityGoalTypeGT
end
