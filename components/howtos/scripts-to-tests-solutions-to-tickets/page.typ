= Scripts To Tests Solutions To Tickets

Split into independent Nix checks by ticket number range.

== Group misc

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-misc
```

```text
=== HOW-TO tickets group: misc ===

>>> Running ./BigFlights.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./issue1.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>M1
M1
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[
{ "id" : "QueryClass",
  "type" : ["Class"],
  "super" : ["Class"],
    "attribute/retrieved_attribute" : "Proposition",
    "attribute/computed_attribute" : "Proposition",
    "attribute/constraint" : "MSFOLquery"
}
]

[localhost:4001]>[
{ "id" : "QueryClass",
  "type" : ["Class"],
  "super" : ["Class"],
    "attribute/retrieved_attribute" : "Proposition",
    "attribute/computed_attribute" : "Proposition",
    "attribute/constraint" : "MSFOLquery"
}
]

[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[
{ "id" : "bill",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "100",
    "name/name" : "\"Bill\"",
    "attribute/age" : "20"
}
]

[localhost:4001]>[
{ "id" : "bill",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "100",
    "name/name" : "\"Bill\"",
    "attribute/age" : "20"
}
]

[localhost:4001]>bill in Pilot,Employee with 
   salary
    salary : 100
  name
    name : "Bill"
  attribute
    age : 20
end 

[localhost:4001]>bill in Pilot,Employee with 
   salary
    salary : 100
  name
    name : "Bill"
  attribute
    age : 20
end 

[localhost:4001]>[localhost:4001]>[localhost:4001]>[
{ "id" : "Manager",
  "super" : ["Employee"]}
]

[localhost:4001]>[
{ "id" : "Manager",
  "super" : ["Employee"]}
]

[localhost:4001]>[localhost:4001]>[localhost:4001]>{
* Module: System-oHome-M1
* ---------------------------------------------------------
* Listed for: nixbld@localhost_amd64_Linux at 2026-06-06 21:52:47.231 (UTC) 
*
}

{ 2026-06-06 21:52:46.667 }

Pilot in Class  end 

Employee in Class with 
   attribute
    salary : Integer;
    name : String
end 

{---} { 2026-06-06 21:52:46.767 }

bill in Pilot,Employee with 
   salary
    salary : 100
  name
    name : "Bill"
  attribute
    age : 20
end 

Manager isA Employee  end 

Employees in QueryClass isA Employee with 
   retrieved_attribute
    name : String;
    salary : Integer
end 

{---} { 2026-06-06 21:52:46.872 }

mary in Pilot,Employee with 
   salary
    salary : 101
  name
    name : "Mary"
  attribute
    age : 20
end 

jane in Pilot,Employee with 
   salary
    salary : 102
  name
    name : "Jane"
  attribute
    age : 20
end 

{ -/- }

[localhost:4001]>{
* Module: System-oHome-M1
* ---------------------------------------------------------
* Listed for: nixbld@localhost_amd64_Linux at 2026-06-06 21:52:47.231 (UTC) 
*
}

{ 2026-06-06 21:52:46.667 }

Pilot in Class  end 

Employee in Class with 
   attribute
    salary : Integer;
    name : String
end 

{---} { 2026-06-06 21:52:46.767 }

bill in Pilot,Employee with 
   salary
    salary : 100
  name
    name : "Bill"
  attribute
    age : 20
end 

Manager isA Employee  end 

Employees in QueryClass isA Employee with 
   retrieved_attribute
    name : String;
    salary : Integer
end 

{---} { 2026-06-06 21:52:46.872 }

mary in Pilot,Employee with 
   salary
    salary : 101
  name
    name : "Mary"
  attribute
    age : 20
end 

jane in Pilot,Employee with 
   salary
    salary : 102
  name
    name : "Jane"
  attribute
    age : 20
end 

{ -/- }

[localhost:4001]>[
{ "module" : "M1",
  "modulepath" : "System-oHome-M1" },

[
{ "id" : "Pilot",
  "type" : ["Class"]},

{ "id" : "Employee",
  "type" : ["Class"],
    "attribute/salary" : "Integer",
    "attribute/name" : "String"
}
],

[
{ "id" : "bill",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "100",
    "name/name" : "\"Bill\"",
    "attribute/age" : "20"
},

{ "id" : "Manager",
  "super" : ["Employee"]},

{ "id" : "Employees",
  "type" : ["QueryClass"],
  "super" : ["Employee"],
    "retrieved_attribute/name" : "String",
    "retrieved_attribute/salary" : "Integer"
}
],

[
{ "id" : "mary",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "101",
    "name/name" : "\"Mary\"",
    "attribute/age" : "20"
},

{ "id" : "jane",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "102",
    "name/name" : "\"Jane\"",
    "attribute/age" : "20"
}
]
]

[localhost:4001]>[
{ "module" : "M1",
  "modulepath" : "System-oHome-M1" },

[
{ "id" : "Pilot",
  "type" : ["Class"]},

{ "id" : "Employee",
  "type" : ["Class"],
    "attribute/salary" : "Integer",
    "attribute/name" : "String"
}
],

[
{ "id" : "bill",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "100",
    "name/name" : "\"Bill\"",
    "attribute/age" : "20"
},

{ "id" : "Manager",
  "super" : ["Employee"]},

{ "id" : "Employees",
  "type" : ["QueryClass"],
  "super" : ["Employee"],
    "retrieved_attribute/name" : "String",
    "retrieved_attribute/salary" : "Integer"
}
],

[
{ "id" : "mary",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "101",
    "name/name" : "\"Mary\"",
    "attribute/age" : "20"
},

{ "id" : "jane",
  "type" : ["Pilot","Employee"],
    "salary/salary" : "102",
    "name/name" : "\"Jane\"",
    "attribute/age" : "20"
}
]
]

[localhost:4001]>[localhost:4001]>[localhost:4001]>[
{ "id" : "bill",
  "type" : ["Employees"],
    "name/name" : "\"Bill\"",
    "salary/salary" : "100"
},

{ "id" : "mary",
  "type" : ["Employees"],
    "name/name" : "\"Mary\"",
    "salary/salary" : "101"
},

{ "id" : "jane",
  "type" : ["Employees"],
    "name/name" : "\"Jane\"",
    "salary/salary" : "102"
}
]


[
{ "id" : "bill",
  "type" : ["Employees"],
    "name/name" : "\"Bill\"",
    "salary/salary" : "100"
},

{ "id" : "mary",
  "type" : ["Employees"],
    "name/name" : "\"Mary\"",
    "salary/salary" : "101"
},

{ "id" : "jane",
  "type" : ["Employees"],
    "name/name" : "\"Jane\"",
    "salary/salary" : "102"
}
]


[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
```

== Group 000-099

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-000-099
```

```text
=== HOW-TO tickets group: 000-099 (asset validation) ===
>>> Validated ./ticket092a.cbs.txt
>>> Validated ./ticket092b.cbs.txt
```

== Group 100-199

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-100-199
```

```text
=== HOW-TO tickets group: 100-199 (asset validation) ===
>>> Validated ./Ticket168.cbs.txt
>>> Validated ./ticket125.cbs.txt
>>> Validated ./ticket162.cbs.txt
>>> Validated ./ticket164.cbs.txt
>>> Validated ./ticket180.cbs.txt
>>> Validated ./ticket191.cbs.txt
>>> Validated ./ticket194.cbs.txt
>>> Validated ./ticket197.cbs.txt
```

== Group 200-299

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-200-299
```

```text
=== HOW-TO tickets group: 200-299 ===

>>> Running ./ticket202.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Skipping ./ticket203.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket203a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket207.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket212.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket213.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket214.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket220.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket222.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket230.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket234.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket241.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket242.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket243.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket245.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket246.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket247.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket248.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket251.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket252.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket253.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket254.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket255.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket255a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket260.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket261.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket263.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket263a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket264.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket265.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket266.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket267.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket268.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket271.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket272.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket273.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket276.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket277.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket278.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket279.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket280.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket282.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket283.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket284.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket285.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket286.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket288.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket290.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket292.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket293.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket294.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket295.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket296.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket298.cbs.txt (max 1 per group in Nix check)
```

== Group 300-399

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-300-399
```

```text
=== HOW-TO tickets group: 300-399 ===

>>> Running ./ticket300.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>Mjeusfeld
[localhost:4001]>Mjeusfeld
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>Mjonny
[localhost:4001]>Mjonny
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>oHome
[localhost:4001]>oHome
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>System
[localhost:4001]>System
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Skipping ./ticket301.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket303.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket306.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket307.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket309.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket311.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket314.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket316.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket317.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket318.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket320.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket325.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket327.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket330.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket335.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket341.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket342.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket346-small.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket346.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket347.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket349.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket350.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket351.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket360.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket364.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket364a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket365.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket365a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket366.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket374.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket384.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket388.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket388a.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket392.cbs.txt (max 1 per group in Nix check)
>>> Skipping ./ticket397.cbs.txt (max 1 per group in Nix check)
```

== Group 400-599

```bash
nix build .#checks.x86_64-linux.scripts-to-tests-tickets-400-599
```

```text
=== HOW-TO tickets group: 400-599 ===

>>> Running ./ticket400.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>LowSalaryEmployee in EmptyClass,MSFOLrule,QueryClass isA Employee with 
   constraint
    c1 : $ exists s/Integer (this salary s) and (s < 500) $
end 

[localhost:4001]>LowSalaryEmployee in EmptyClass,MSFOLrule,QueryClass isA Employee with 
   constraint
    c1 : $ exists s/Integer (this salary s) and (s < 500) $
end 

[localhost:4001]>[localhost:4001]>[localhost:4001]>Employee in Class with 
   attribute
    salary : Integer
  constraint
    isEmpty_generated : $ forall x/LowSalaryEmployee   FALSE $
end 

[localhost:4001]>Employee in Class with 
   attribute
    salary : Integer
  constraint
    isEmpty_generated : $ forall x/LowSalaryEmployee   FALSE $
end 

[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./ticket404.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>yes
[localhost:4002]>yes
[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>yes
[localhost:4002]>yes
[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>yes
[localhost:4002]>yes
[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>[localhost:4002]>M,X
[localhost:4002]>M,X
[localhost:4002]>[localhost:4002]>[localhost:4002]>
>>> Skipping ./ticket404a.cbs.txt (max 2 per group in Nix check)
>>> Skipping ./ticket404b.cbs.txt (max 2 per group in Nix check)
>>> Skipping ./ticket415.cbs.txt (max 2 per group in Nix check)
>>> Skipping ./ticket423.cbs.txt (max 2 per group in Nix check)
>>> Skipping ./ticket432.cbs.txt (max 2 per group in Nix check)
>>> Skipping ./ticket433.cbs.txt (max 2 per group in Nix check)
```

== Sample input scripts

=== `BigFlights.cbs.txt`

```telos
startServer -u nonpersistent -c transient 
tellModel /home/jeusfeld/CBMODELS/BigFlights
result OK yes
ask DeadEndCity OBJNAMES FRAME Now
result OK "tripoli in DeadEndCity
end

malta in DeadEndCity
end

toulouse in DeadEndCity
end

sanfrancisco in DeadEndCity
end

edinburgh in DeadEndCity
end"
ask DeadStartCity OBJNAMES FRAME Now
result OK "juist in DeadStartCity
end

ljubljana in DeadStartCity
end

malaga in DeadStartCity
end

tanger in DeadStartCity
end

langeoog in DeadStartCity
end

santa_decompostela in DeadStartCity
end

helgoland in DeadStartCity
end


... (truncated; see repository for all 110 scripts)
```

=== `issue1.cbs.txt`

```telos
#
# File: issue1.cbs
# Author: Manfred Jeusfeld
# Created: 2019-05-31/M.Jeusfeld (2019-05-31/M.Jeusfeld)
# ------------------------------------------------------
# Test JSON output format for frames
#

# cbserver -t low
connect

mkdir M1
cd M1

ask get_object[QueryClass/objname] OBJNAMES JSONIC Now

tell '
Pilot in Class end
Employee in Class with
  attribute
    salary: Integer;
    name: String
end
'

tell '
bill in Pilot,Employee with
  salary
    salary: 100
  name
     name: "Bill"
  attribute
     age: 20
end
Manager isA Employee end

Employees in QueryClass isA Employee with
  retrieved_attribute
    name: String;
    salary: Integer

... (truncated; see repository for all 110 scripts)
```

=== `ticket092a.cbs.txt`

```telos
startServer -u nonpersistent 
tell "
Place with
  attribute
    sendsToken: Transition;
    tokenFill: Integer  
end
Transition with 
  attribute
     producesToken : Place
end 
"
result OK "yes"
tell "
TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (~place tokenFill ~this) $
end
EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken ~this) 
                 ==> (TokenNr[pl/place] > 0)
         $
end
ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (~this sendsToken ~trans) or (~trans producesToken ~this) $
end
TransToPlace in GenericQueryClass isA Transition!producesToken with
  parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~trans) and To(~this,~place) $
end
PlaceToTrans in GenericQueryClass isA Place!sendsToken with

... (truncated; see repository for all 110 scripts)
```

=== `ticket092b.cbs.txt`

```telos
startServer -u nonpersistent 
tell "
Place with
  attribute
    sendsToken: Transition;
    tokenFill: Integer  
end
Transition with 
  attribute
     producesToken : Place
end 
"
result OK "yes"
tell "
TokenNr in Function isA Integer with
  parameter
    place: Place
  constraint
    c1: $ (~place tokenFill ~this) $
end
EnabledTransition in QueryClass isA Transition with
  constraint
    c1: $ forall pl/Place (pl sendsToken ~this) 
                 ==> (TokenNr[pl/place] > 0)
         $
end
ConnectedPlace in GenericQueryClass isA Place with
  parameter
    trans: Transition
  constraint
    isConnected: $ (~this sendsToken ~trans) or (~trans producesToken ~this) $
end
TransToPlace in GenericQueryClass isA Transition!producesToken with
  parameter
    trans: Transition;
    place: Place
  constraint
    c1: $ From(~this,~trans) and To(~this,~place) $
end
PlaceToTrans in GenericQueryClass isA Place!sendsToken with

... (truncated; see repository for all 110 scripts)
```

=== `ticket125.cbs.txt`

```telos



startServer -u nonpersistent -t veryhigh
tell "
{*
* File:	Assignment2.sml
* Author:	Paul ligthart, p.j.h.ligthart@uvt.nl
* 	  	Remco van Strien, r.a.m.vanstrien@uvt.nl
* Date:   	13-Nov-2006
*----------------------------------------------------------------
*
* The (3) answers of assignment 2 of Method Engineering 2006
*
*}


{*** M3: NOTATION DEFINITION LEVEL ***}

NodeOrLink with
  attribute
     connectedTo: NodeOrLink
end

Node isA NodeOrLink end
NodeOrLink!connectedTo isA NodeOrLink end

Model isA Node with
  attribute
    contains: NodeOrLink
end


{** M2: NOTATION LEVEL *** }

ObjectType in Node end  
EntityType in Node isA ObjectType end

RelationshipType in Node isA ObjectType with
  connectedTo

... (truncated; see repository for all 110 scripts)
```

