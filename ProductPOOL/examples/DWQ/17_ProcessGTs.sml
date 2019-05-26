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
DW_ProcessGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/process.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

DW_ProcessClassGT in JavaGraphicalType with
property
	textcolor : "100,125,200";
	fontstyle : "italic";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/process-class.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

DW_Process with
graphtype
	gt : DW_ProcessClassGT
end

ActivityGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/activity.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

ActivityClassGT in JavaGraphicalType with
property
	textcolor : "100,125,200";
	fontstyle : "italic";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/activity-class.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

Activity with
graphtype
	gt : ActivityClassGT
end

TaskGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/task.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end


TaskClassGT in JavaGraphicalType with
property
	textcolor : "100,125,200";
	fontstyle : "italic";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/task-class.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

Task with
graphtype
	gt : TaskClassGT
end

TransformationGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.DoubleArrow";
	bgcolor : "232,24,24";
	textcolor : "0,0,0";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end


TransformationClassGT in JavaGraphicalType with
property
	shape : "i5.cb.graph.shapes.DoubleArrow";
	bgcolor : "232,232,232";
	textcolor : "50,62,100";
	fontstyle : "italic";
	linecolor : "0,0,0"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

Transformation with
graphtype
	gt : TransformationClassGT
end

EvolutionGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/evolution.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end


EvolutionClassGT in JavaGraphicalType with
property
	textcolor : "100,125,200";
	fontstyle : "italic";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/evolution-class.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 42
end

EvolutionProcess with
graphtype
	gt2 : EvolutionClassGT
end

DWQ_Palette with
contains
	c60 : DW_ProcessGT;
	c61 : ActivityGT;
	c62 : TaskGT;
	c63 : TransformationGT;
	c64 : EvolutionGT;
	c65 : DW_ProcessClassGT;
	c66 : ActivityClassGT;
	c67 : TaskClassGT;
	c68 : TransformationClassGT;
	c69 : EvolutionClassGT
rule
	rProcess : $ forall p/DW_Process (p graphtype DW_ProcessGT) $;
	rActivity : $ forall p/Activity (p graphtype ActivityGT) $;
	rTask : $ forall p/Task (p graphtype TaskGT) $;
	rTransformation : $ forall p/Transformation (p graphtype TransformationGT) $;
	rEvolution : $ forall p/EvolutionProcess (p graphtype EvolutionGT) $
end
