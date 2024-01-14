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
Class DW_Process in ObjectType isA DW_Element with
attribute
	intendedFor : Task;
	describedBy : Function;
	performedBy : Activity
end

{Organisational Level}

Class Task in ObjectType with
attribute
	dependsOn : Task;
	desc : String
end

Task!dependsOn with
attribute
	type : DependencyType;
	strength : DependencyStrength;
	wrt : DW_Object;
	desc : String
end


Class DependencyType end

GoalDependency in DependencyType end
TaskDependency in DependencyType end
ResourceDependency in DependencyType end
SoftGoalDependency in DependencyType end

Class DependencyStrength end

OpenDependency in DependencyStrength end
CommittedDependency in DependencyStrength end
CriticalDependency in DependencyStrength end


Stakeholder with
attribute
	hasTask : Task
end


{Functional Level}

Class Function in ObjectType with
attribute
	formalExpr : String;
	description : String
end

Class Transformation in ObjectType isA Function with
attribute
	source : LogicalObject;
	target : LogicalObject;
	consistsOf : Transformation
end


{Execution Level}

Class Activity in ObjectType with
attribute
	triggeredBy : Event;
	steps : Step;
	executedBy : DW_Component
end

DW_Component!deliversTo with
attribute
	activity : Activity
end

Class Event end

Class ScheduleEvent isA Event end
Class PointInTimeEvent isA ScheduleEvent end
Class IntervalEvent isA ScheduleEvent end

Class ExternalEvent isA Event end
Class InternalEvent isA Event end
Class CascadeEvent isA InternalEvent end
Class RetryEvent isA InternalEvent end

Class Step in ObjectType isA Activity with
attribute
	next : Step
end

Step!next with
attribute
	condition : Condition
end

Class Condition with
attribute
	formalExpression : String;
	description : String
end

Class ProcessExecution in ObjectType with
attribute
	executes : Activity;
	start : DateTime;
	finishedAt : DateTime;
	state : ExecutionState;
	subProcess : ProcessExecution
end

Class ExecutionState end

Commit in ExecutionState end
Abort in ExecutionState end
Running in ExecutionState end


{ Evolution }

Class EvolutionFunction isA Function with
attribute
	worksOn : DW_Element;
	consistsOf : EvolutionFunction
end


EvolutionFunction!worksOn with
attribute
	semantics : EvolutionSemantics
end

Class EvolutionSemantics
end

Insert in EvolutionSemantics end
Delete in EvolutionSemantics end
Update in EvolutionSemantics end

Class EvolutionProcess isA DW_Process with
attribute
	describedBy : EvolutionFunction
end

EvolutionProcess!describedBy isA DW_Process!describedBy
end
