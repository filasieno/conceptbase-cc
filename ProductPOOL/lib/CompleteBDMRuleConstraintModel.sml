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
{*
*
* File:        CompleteBDMRuleConstraintModel.sml
* Version:     2.4
* Creation:    20-Mar-1989, Eva Krueger (UPA)
* Last change: 24 Jul 1990, Manfred Jeusfeld (UPA)
* Release:     2
* ----------------------------------------------------------
* 
* This is the complete model for rules and constraints in CML following the
* BDM-approach.
*
*}



Class BDMConstraintCheck in AssertionEvaluators with end


Class BDMRuleCheck in AssertionEvaluators with
      attribute
              applyFurtherRuleIfInsert: BDMRuleCheck;
              applyFurtherRuleIfDelete: BDMRuleCheck;
              applyNowConstraintIfInsert: BDMConstraintCheck;
              applyNowConstraintIfDelete: BDMConstraintCheck

end

MSFOLrule with
 	attribute
		originalRule : BDMRuleCheck;
		specialRule  : BDMRuleCheck
end

MSFOLconstraint with
	attribute
		originalConstraint : BDMConstraintCheck;
		specialConstraint  : BDMConstraintCheck
end


{* ### MJf *}

Individual Proposition with
  attribute
    applyConstraintIfInsert: BDMConstraintCheck;
    applyConstraintIfDelete: BDMConstraintCheck;
    applyRuleIfInsert: BDMRuleCheck;
    applyRuleIfDelete: BDMRuleCheck;
    deducedBy: BDMRuleCheck
end






