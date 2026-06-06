{
*
* File: SameGen.sml
* Author: Manfred Jeusfeld
* Creation: 27-Feb-2002 (2024-01-16)
* ----------------------------------------------------------------------
* Shows a linear recursive query. It runs fine with ConceptBase
* V5.2.2 (February 2002) but will cause earlier versions to crash.
* Call the query SameGen (or its variant SameGenProper) with Lot or Kain
* as example parameters or even without parameters.
}



Class Person with
  attribute
    hasChild: Person
end


GenericQueryClass SameGen isA Person with
  parameter,computed_attribute
    sgperson: Person
  constraint
    c1: $
          (~this == ~sgperson) 
        or
          ( exists p1,p2/Person (p1 in SameGen[p2/sgperson]) and 
                                (p1 hasChild ~sgperson) and (p2 hasChild ~this) )
        $
end

{* SameGenProper is not reflexive, i.e. (x in SameGenProper[x/sgperson]) does not hold *}
GenericQueryClass SameGenProper isA Person with
  parameter,computed_attribute
    sgperson: Person
  constraint
    c1: $ (
          ( exists p/Person (p hasChild ~this) and (p hasChild ~sgperson) )
        or
          ( exists p1,p2/Person (p1 in SameGen[p2/sgperson]) and
                                (p1 hasChild ~sgperson) and (p2 hasChild ~this) )
          )
          and not (~this == ~sgperson)
        $
end


{* the answer format makes the answers just more readable *}
AnswerFormat SG_Format with
   forQuery q1: SameGen; q2: SameGenProper
   head h: "Same generation of persons: 

"
   pattern p: "{this} is in the same generation as{Foreach( ({this.sgperson}),(p), {p}\,)}
"
end

Person Eva with
  hasChild
    c1: Kain;
    c2: Abel;
    c3: Seth
end


Person Abel with
  hasChild
    c1: Abraham;
    c2: Lea
end

Person Abraham with
  hasChild
    c1: Isaak;
    c2: Ismael
end

Person Seth with
  hasChild
    c1: Lot
end

Person Kain with
end

Person Lea with
end

Person Isaak with
end

Person Ismael with
end

Person Lot with
end



