= Deal With Ocl Style Invariants

Verified independently via:

```bash
nix build .#checks.x86_64-linux.deal-with-ocl-style-invariants
```

== Input

=== `ClubMemberDesignModel.sml.txt`

```telos
{* 
* File: ClubMemberDesignModel.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2012-03-28 (2012-03-30)
*----------------------------------------------------------------
*
* ConceptBase representation of the UML design model 'ClubMember'
*
*}

GenderType in Class end
male in GenderType end
female in GenderType end


Person in Class with
  attribute
     firstName: String;
     lastName: String;
     gender: GenderType
end

GenderConstraints in Class with
  constraint
    isComplete: $ forall p/Person (p gender female) or (p gender male) $;
    isDisjoint1: $ forall p/Person (p gender female) ==>  not (p gender male) $;
    isDisjoint2: $ forall p/Person (p gender male) ==>  not (p gender female) $
end


MemberType in Class end
full in MemberType end
provisional in MemberType end


{* The constraints of ClubMember correspond to the OCL constraints    *}
{* on the last slide of lect09. In ConceptBase, the variable 'this'   *}
{* stands for any instance of the class (here ClubMember). Hence, it  *}
{* is similar to OCL 'self'.                                          *}
{* isFemale corresponds to                                            *}
{*      "self.gender=female"                                          *}
{* existsMentor corresponds to                                        *}
{*      "self.MemberType=provisional implies self.Mentor->nonEmpty()" *}
{* fullNoMentor corresponds to                                        *}
{*      "self.MemberType=full implies self.Mentor->isEmpty()"         *}
{* mentorMustbeFullMember corresponds to                              *}
{*      "self.Mentor->forall(m | m.MemberType=full)"                  *}   

ClubMember in Class isA Person with
  attribute
    memberId: String;
    memberType: MemberType;
    mentor: ClubMember
  constraint
    isFemale: $ (this gender female) $;
    existsMentor: $ (this memberType provisional) 
                     ==> exists fm/ClubMember (this mentor fm) $;
    fullNoMentor: $ (this memberType full) 
                     ==> not exists m/ClubMember (this mentor m) $ ;
    mentorMustbeFullMember: $ forall m/ClubMember (this mentor m) ==> (m memberType full) $
end


MemberConstraints in Class with
  constraint
    isComplete: $ forall p/ClubMember (p memberType full) or (p memberType provisional) $;
    isDisjoint1: $ forall p/ClubMember (p memberType full) ==>  not (p memberType provisional) $;
    isDisjoint2: $ forall p/ClubMember (p memberType provisional) ==>  not (p memberType female) $
end





p123 in ClubMember with
  memberId id: "p123"
  firstName fn: "Mary"
  lastName ln: "Smith"
  gender g: female
  memberType mt: full
end

p999 in ClubMember with
  memberId id: "p999"
  firstName fn: "Carla"
  lastName ln: "Miller"
  gender g: female
  memberType mt: full
end

p888 in Person with
  firstName fn: "John"
  lastName ln: "Doe"
  gender g: male
end

p345 in ClubMember with
  memberId id: "p345"
  firstName fn: "Anne"
  lastName ln: "Arbor"
  mentor m1: p123
  gender g: female
  memberType mt: provisional
end



{ ** inconsistent data
p888 in ClubMember end


p123 with
   mentor
     m2: p999
end


p346 in ClubMember with
  memberId id: "p346"
  firstName fn: "Paula"
  lastName ln: "Arbor"
  gender g: female
  memberType mt: provisional
end


*}

```

=== `ClubMemberDomainModel.sml.txt`

```telos
{* 
* File: ClubMemberDomainModel.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2012-03-28 (2012-03-30)
*----------------------------------------------------------------
*
* ConceptBase representation of the UML domain model 'ClubMember'
*
*}


Person in Class with
  attribute
     firstName: Individual;
     lastName: Individual
end

Female isA Person end
Male isA Person end

GenderConstraints in Class with
  constraint
    isComplete: $ forall p/Person (p in Female) or (p in Male) $;
    isDisjoint1: $ forall p/Female not (p in Male) $;
    isDisjoint2: $ forall p/Male not (p in Female) $
end

ClubMember isA Female with
  attribute
    memberId: Individual
end

FullMember isA ClubMember end

ProvisionalMember in Class isA ClubMember with
  attribute
    mentor: FullMember
  constraint
    c1: $ forall pm/ProvisionalMember exists fm/FullMember (pm mentor fm) $
end

MemberConstraints in Class with
  constraint
    isComplete: $ forall p/ClubMember (p in FullMember) or (p in ProvisionalMember) $;
    isDisjoint1: $ forall p/FullMember not (p in ProvisionalMember) $;
    isDisjoint2: $ forall p/ProvisionalMember not (p in FullMember) $
end




p123 in FullMember with
  memberId id: "p123"
  firstName fn: "Mary"
  lastName ln: "Smith"
end

p999 in FullMember with
  memberId id: "p999"
  firstName fn: "Carla"
  lastName ln: "Miller"
end

p888 in Male with
  firstName fn: "John"
  lastName ln: "Doe"
end

p345 in ProvisionalMember with
  memberId id: "p345"
  firstName fn: "Anne"
  lastName ln: "Arbor"
  mentor m1: p123
end


{ ** inconsistent data
p888 in ClubMember end

p123 with
   mentor
     m2: p999
end


p346 in ProvisionalMember with
  memberId id: "p346"
  firstName fn: "Paula"
  lastName ln: "Arbor"
end


*}


```

== Shell output

```text
=== HOW-TO: deal-with-ocl-style-invariants ===

>>> Telling ./ClubMemberDesignModel.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./ClubMemberDomainModel.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
