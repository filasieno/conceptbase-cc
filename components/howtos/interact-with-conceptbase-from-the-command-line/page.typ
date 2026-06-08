= Interact With Conceptbase From The Command Line

Verified independently via:

```bash
nix build .#checks.x86_64-linux.interact-with-conceptbase-from-the-command-line
```

== Input

== Shell output

```text
=== HOW-TO: interact-with-conceptbase-from-the-command-line ===

>>> Documentation-only check: listing tutorial files
./ask.txt
./page.typ
./stopcb.txt
./tell.txt
./testask.txt

>>> CBShell smoke session
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>Proposition,MetaClass,"</graphtype>","
  <name>{this}</name>{Foreach(({this.property},{this|property}),(v,l),
  <property>
    <name>{l}</name>
    <value>{v}</value>
  </property>)}
  <implementedBy>{this.implementedBy}</implementedBy>
",GeneratedObject,0,$Rule(Condition(exists([In(_G48691, id_881)], forall([Aedot(id_886, _G48691, _G48697)], FALSE))), Conclusion(Adot(id_886, _G48691, id_1011)))$,DefaultJavaPalette,DeriveExpression,DefaultIndividualGT,DefaultLinkGT,ImplicitIsAGT,ImplicitInstanceOfGT,ImplicitAttributeGT,QueryCall,DefaultIsAGT,DefaultInstanceOfGT,DefaultAttributeGT,HiddenObject,MetametaGT,SimpleClassGT,MetaClassGT,Function,ClassGT,QueryClassGT,$ forall p/IsA (p graphtype DefaultIsAGT) $,$ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $,$ forall p/Attribute (p graphtype DefaultAttributeGT) $,$ forall p/Individual (p graphtype DefaultIndividualGT) $,$ forall c/MetametaClass (c graphtype MetametaGT) $,$ forall t/SimpleClass  (t graphtype SimpleClassGT) $,vQueryClass,$ forall t/MetaClass  (t graphtype MetaClassGT) $,$ forall c/Individual (c in Class) ==> (c graphtype ClassGT) $,$ forall c/QueryClass (c graphtype QueryClassGT) $,MetametaClass,"210,210,210","0,0,0","i5.cb.graph.shapes.Rect","i5.cb.graph.cbeditor.CBIndividual","2",$ not (this in HiddenObject) and not (this in Function) $,"i5.cb.graph.cbeditor.CBLink","0,205,255","3",1,"0,150,255",Version,"dashed","0,210,0",T_0,Module,"0,180,0",TransactionTime,Label,"20,20,20","127,255,212",Boolean,"32,178,170","i5.cb.graph.shapes.Ellipse","bold",10,FALSE,"255,192,203","255,0,0",TRUE,"135,206,235","65,105,225",System,ViewMaintenanceStrategy,"0,206,209",5,"255,255,255",BottomUpVM,"0,0,255","italic",7,$Rule(Condition(exists([In(_G23372, id_15)], TRUE)), Conclusion(Adot(id_876, _G23372, id_1042)))$,$Rule(Condition(exists([In(_G26016, id_1)], TRUE)), Conclusion(Adot(id_876, _G26016, id_1045)))$,TopDownVM,$Rule(Condition(exists([In(_G28635, id_6)], TRUE)), Conclusion(Adot(id_876, _G28635, id_1048)))$,$Rule(Condition(exists([In(_G31281, id_7)], TRUE)), Conclusion(Adot(id_876, _G31281, id_1022)))$,$Rule(Condition(exists([In(_G2266, id_11)], TRUE)), Conclusion(Adot(id_876, _G2266, id_1051)))$,$Rule(Condition(exists([In(_G4891, id_9)], TRUE)), Conclusion(Adot(id_876, _G4891, id_1054)))$,$Rule(Condition(exists([In(_G7498, id_10)], TRUE)), Conclusion(Adot(id_876, _G7498, id_1057)))$,NaiveVM,$Rule(Condition(exists([In(_G10493, id_7), In(_G10493, id_2)], TRUE)), Conclusion(Adot(id_876, _G10493, id_1060)))$,$Rule(Condition(exists([In(_G13216, id_65)], TRUE)), Conclusion(Adot(id_876, _G13216, id_1063)))$,ECArule,ECAassertion,ECAmode,$ forall r/ECArule e1,e2/ECAassertion
		(r ecarule e1) and (r ecarule e2) ==> (e1 == e2) $,$ forall r/ECArule exists e/ECAassertion
		(r ecarule e) $,$ forall r/ECArule m1,m2/ECAmode
		(r mode m1) and (r mode m2) ==> (m1 == m2) $,$ forall r/ECArule a1,a2/Boolean
		(r active a1) and (r active a2) ==> (a1 == a2) $,$ forall r/ECArule i,j/Integer
		(r depth i) and (r depth j) ==> (i == j) $,Immediate,ImmediateDeferred,Deferred,YesClass,yes,$forall([Adot(id_1406, _G7936, _G7942), Adot(id_1406, _G7936, _G7948)], IDENTICAL(_G7942, _G7948))$,Order,$Insert(Adot(id_1406, _G8372, _G8378), forall([e2], [Adot(_G8372, r, e2)], IDENTICAL(_G8378, e2)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$Insert(Adot(id_1406, _G9319, _G9331), forall([e1], [Adot(_G9319, r, e1)], IDENTICAL(e1, _G9331)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$forall([In(_G12295, id_1403)], exists([Adot(id_1406, _G12295, _G12301)], TRUE))$,$Insert(In(_G12658, id_1403), forall([], [], exists([e], [Adot(id_1406, _G12658, e)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,ascending,$Delete(Adot(id_1406, _G13321, _G13456), forall([], [In(r, id_1403)], exists([_G13456], [Adot(_G13321, r, _G13456)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,$forall([Adot(id_1410, _G17573, _G17579), Adot(id_1410, _G17573, _G17585)], IDENTICAL(_G17579, _G17585))$,$Insert(Adot(id_1410, _G18010, _G18016), forall([m2], [Adot(_G18010, r, m2)], IDENTICAL(_G18016, m2)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,$Insert(Adot(id_1410, _G18958, _G18970), forall([m1], [Adot(_G18958, r, m1)], IDENTICAL(m1, _G18970)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,descending,$forall([Adot(id_1411, _G23229, _G23235), Adot(id_1411, _G23229, _G23241)], IDENTICAL(_G23235, _G23241))$,$Insert(Adot(id_1411, _G23666, _G23672), forall([a2], [Adot(_G23666, r, a2)], IDENTICAL(_G23672, a2)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,$Insert(Adot(id_1411, _G24613, _G24625), forall([a1], [Adot(_G24613, r, a1)], IDENTICAL(a1, _G24625)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,AnswerFormat,$forall([Adot(id_1412, _G28832, _G28838), Adot(id_1412, _G28832, _G28844)], IDENTICAL(_G28838, _G28844))$,$Insert(Adot(id_1412, _G29269, _G29275), forall([j], [Adot(_G29269, r, j)], IDENTICAL(_G29275, j)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,$Insert(Adot(id_1412, _G30216, _G30228), forall([i], [Adot(_G30216, r, i)], IDENTICAL(i, _G30228)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,oHome,CB_User,AutoHomeModule,Resource,CB_Operation,CB_ReadOperation,CB_WriteOperation,TELL,TELL_MODEL,UNTELL,RETELL,LPI_CALL,ASK,HYPO_ASK,listModule,IsolatedValue,$ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $,DoNotSave_LM,$ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $,toLabel,"returns s as a label without quotes and special character and creates it as individual object",concat,"Appends string s2 to the end of string s1; same as ConcatenateStrings",BuiltinClass,COUNT,DoNotSave_1,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,purgeModule,listModuleReloadable,"(C) 1987 ConceptBase Team, in particular Manfred Jeusfeld, Martin Staudt, Hans Nissen, Christoph Quix, Eva Krueger; all rights reserved.","Use permitted under FreeBSD style license, see http://conceptbase.sourceforge.net/CB-FreeBSD-License.txt.","The System module is the root module of ConceptBase. It contains the pre-defineProposition,MetaClass,"</graphtype>","
  <name>{this}</name>{Foreach(({this.property},{this|property}),(v,l),
  <property>
    <name>{l}</name>
    <value>{v}</value>
  </property>)}
  <implementedBy>{this.implementedBy}</implementedBy>
",GeneratedObject,0,$Rule(Condition(exists([In(_G48691, id_881)], forall([Aedot(id_886, _G48691, _G48697)], FALSE))), Conclusion(Adot(id_886, _G48691, id_1011)))$,DefaultJavaPalette,DeriveExpression,DefaultIndividualGT,DefaultLinkGT,ImplicitIsAGT,ImplicitInstanceOfGT,ImplicitAttributeGT,QueryCall,DefaultIsAGT,DefaultInstanceOfGT,DefaultAttributeGT,HiddenObject,MetametaGT,SimpleClassGT,MetaClassGT,Function,ClassGT,QueryClassGT,$ forall p/IsA (p graphtype DefaultIsAGT) $,$ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $,$ forall p/Attribute (p graphtype DefaultAttributeGT) $,$ forall p/Individual (p graphtype DefaultIndividualGT) $,$ forall c/MetametaClass (c graphtype MetametaGT) $,$ forall t/SimpleClass  (t graphtype SimpleClassGT) $,vQueryClass,$ forall t/MetaClass  (t graphtype MetaClassGT) $,$ forall c/Individual (c in Class) ==> (c graphtype ClassGT) $,$ forall c/QueryClass (c graphtype QueryClassGT) $,MetametaClass,"210,210,210","0,0,0","i5.cb.graph.shapes.Rect","i5.cb.graph.cbeditor.CBIndividual","2",$ not (this in HiddenObject) and not (this in Function) $,"i5.cb.graph.cbeditor.CBLink","0,205,255","3",1,"0,150,255",Version,"dashed","0,210,0",T_0,Module,"0,180,0",TransactionTime,Label,"20,20,20","127,255,212",Boolean,"32,178,170","i5.cb.graph.shapes.Ellipse","bold",10,FALSE,"255,192,203","255,0,0",TRUE,"135,206,235","65,105,225",System,ViewMaintenanceStrategy,"0,206,209",5,"255,255,255",BottomUpVM,"0,0,255","italic",7,$Rule(Condition(exists([In(_G23372, id_15)], TRUE)), Conclusion(Adot(id_876, _G23372, id_1042)))$,$Rule(Condition(exists([In(_G26016, id_1)], TRUE)), Conclusion(Adot(id_876, _G26016, id_1045)))$,TopDownVM,$Rule(Condition(exists([In(_G28635, id_6)], TRUE)), Conclusion(Adot(id_876, _G28635, id_1048)))$,$Rule(Condition(exists([In(_G31281, id_7)], TRUE)), Conclusion(Adot(id_876, _G31281, id_1022)))$,$Rule(Condition(exists([In(_G2266, id_11)], TRUE)), Conclusion(Adot(id_876, _G2266, id_1051)))$,$Rule(Condition(exists([In(_G4891, id_9)], TRUE)), Conclusion(Adot(id_876, _G4891, id_1054)))$,$Rule(Condition(exists([In(_G7498, id_10)], TRUE)), Conclusion(Adot(id_876, _G7498, id_1057)))$,NaiveVM,$Rule(Condition(exists([In(_G10493, id_7), In(_G10493, id_2)], TRUE)), Conclusion(Adot(id_876, _G10493, id_1060)))$,$Rule(Condition(exists([In(_G13216, id_65)], TRUE)), Conclusion(Adot(id_876, _G13216, id_1063)))$,ECArule,ECAassertion,ECAmode,$ forall r/ECArule e1,e2/ECAassertion
		(r ecarule e1) and (r ecarule e2) ==> (e1 == e2) $,$ forall r/ECArule exists e/ECAassertion
		(r ecarule e) $,$ forall r/ECArule m1,m2/ECAmode
		(r mode m1) and (r mode m2) ==> (m1 == m2) $,$ forall r/ECArule a1,a2/Boolean
		(r active a1) and (r active a2) ==> (a1 == a2) $,$ forall r/ECArule i,j/Integer
		(r depth i) and (r depth j) ==> (i == j) $,Immediate,ImmediateDeferred,Deferred,YesClass,yes,$forall([Adot(id_1406, _G7936, _G7942), Adot(id_1406, _G7936, _G7948)], IDENTICAL(_G7942, _G7948))$,Order,$Insert(Adot(id_1406, _G8372, _G8378), forall([e2], [Adot(_G8372, r, e2)], IDENTICAL(_G8378, e2)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$Insert(Adot(id_1406, _G9319, _G9331), forall([e1], [Adot(_G9319, r, e1)], IDENTICAL(e1, _G9331)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$forall([In(_G12295, id_1403)], exists([Adot(id_1406, _G12295, _G12301)], TRUE))$,$Insert(In(_G12658, id_1403), forall([], [], exists([e], [Adot(id_1406, _G12658, e)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,ascending,$Delete(Adot(id_1406, _G13321, _G13456), forall([], [In(r, id_1403)], exists([_G13456], [Adot(_G13321, r, _G13456)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,$forall([Adot(id_1410, _G17573, _G17579), Adot(id_1410, _G17573, _G17585)], IDENTICAL(_G17579, _G17585))$,$Insert(Adot(id_1410, _G18010, _G18016), forall([m2], [Adot(_G18010, r, m2)], IDENTICAL(_G18016, m2)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,$Insert(Adot(id_1410, _G18958, _G18970), forall([m1], [Adot(_G18958, r, m1)], IDENTICAL(m1, _G18970)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,descending,$forall([Adot(id_1411, _G23229, _G23235), Adot(id_1411, _G23229, _G23241)], IDENTICAL(_G23235, _G23241))$,$Insert(Adot(id_1411, _G23666, _G23672), forall([a2], [Adot(_G23666, r, a2)], IDENTICAL(_G23672, a2)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,$Insert(Adot(id_1411, _G24613, _G24625), forall([a1], [Adot(_G24613, r, a1)], IDENTICAL(a1, _G24625)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,AnswerFormat,$forall([Adot(id_1412, _G28832, _G28838), Adot(id_1412, _G28832, _G28844)], IDENTICAL(_G28838, _G28844))$,$Insert(Adot(id_1412, _G29269, _G29275), forall([j], [Adot(_G29269, r, j)], IDENTICAL(_G29275, j)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,$Insert(Adot(id_1412, _G30216, _G30228), forall([i], [Adot(_G30216, r, i)], IDENTICAL(i, _G30228)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,oHome,CB_User,AutoHomeModule,Resource,CB_Operation,CB_ReadOperation,CB_WriteOperation,TELL,TELL_MODEL,UNTELL,RETELL,LPI_CALL,ASK,HYPO_ASK,listModule,IsolatedValue,$ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $,DoNotSave_LM,$ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $,toLabel,"returns s as a label without quotes and special character and creates it as individual object",concat,"Appends string s2 to the end of string s1; same as ConcatenateStrings",BuiltinClass,COUNT,DoNotSave_1,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,purgeModule,listModuleReloadable,"(C) 1987 ConceptBase Team, in particular Manfred Jeusfeld, Martin Staudt, Hans Nissen, Christoph Quix, Eva Krueger; all rights reserved.","Use permitted under FreeBSD style license, see http://conceptbase.sourceforge.net/CB-FreeBSD-License.txt.","The System module is the root module of ConceptBase. It contains the pre-defined objects and classes for ConceptBase.",XBridgePalette,"counts the instances of class",$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal contains gt)
                  ==> (pal contains gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultLink gt)
                  ==> (pal defaultLink gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitIsA gt)
                  ==> (pal implicitIsA gt) $,COUNT_Attribute,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitAttribute gt)
                  ==> (pal implicitAttribute gt) $,TelosPalette,"This is the preferred default graphical palette for ConceptBase 8.2 (released 2021). The previous DefaultJavaPalette is still supported. TelosPalette is closer to the symbols used in UML class diagrams and has better support for long strings.",INDIVIDUAL_TP_GT,ATTR_TP_GT,ISADEDUCED_TP_GT,INSTOFDEDUCED_TP_GT,ATTRDEDUCED_TP_GT,CLASS_TP_GT,QUERYCLASS_TP_GT,INSTOF_TP_GT,ISA_TP_GT,STRING_TP_GT,VALUE_TP_GT,ASSERTION_TP_GT,"Caret","counts the attributes in category <attrcat> of object <objname>","ldashed",6,$ forall a/InstanceOf (a graphtype INSTOF_TP_GT) $,"1",Integer,SUM,"0,50,255","Arrow",$ forall a/IsA (a graphtype ISA_TP_GT) $,"computes the sum of the instances of class (must be reals or integers)","10","255,255,255,240",$ forall x/Proposition!attribute (x graphtype ATTR_TP_GT) $,AVG,"Rect","resizable",$ forall x/Individual (x graphtype INDIVIDUAL_TP_GT) $,"250,250,250",$ forall x/Class (x graphtype CLASS_TP_GT) $,"computes the average of the instances of class (must be reals or integers)","100,100,100","11","wrap","1000","0.3",$ forall x/String (x graphtype STRING_TP_GT) $,MAX,$ forall x/Integer (x graphtype VALUE_TP_GT) $,Class,$ forall x/Real (x graphtype VALUE_TP_GT) $,8,"gives the maximum of the instances of class (must be reals or integers)",$ forall x/MSFOLassertion (x graphtype ASSERTION_TP_GT) $,"255,245,245",$ forall x/QueryClass (x graphtype QUERYCLASS_TP_GT) $,concatl,"Appends the labels2 to the label s1; result is a Label, i.e. not necessarily an object name",MIN,concatl4,"Concats the labels s1,s2,s3,s4",concatl6,Real,"Concats the labels s1,s2,s3,s4,s5,s6",HiddenLabel,resultOf,toString,"gives the minimum of the instances of class (must be reals or integers)","convert the label of obj into a string with double quotes around it",length,"compute the number of characters of the label of obj. The double quotes of strings are not counted.",isLike,"check wether the label (first parameter) is matching a pattern (2nd parameter); Use wildcard * in the pattern",GlobalVariable,currentPalette,valueOf,IsolatedCB_User,SUM_Attribute,$ not exists a/Attribute From(a,this) or To(a,this) $,DoNotSave_2,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             (~this in IsolatedCB_User) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G33706, id_881), In(_G33712, id_891), Isa(_G33712, id_1698), NE(_G33712, id_1640)], exists([Adot(id_879, id_1698, _G33706)], TRUE))), Conclusion(Adot(id_879, _G33712, _G33706)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G40259, id_881), In(_G40265, id_891), Isa(_G40265, id_1640), NE(_G40265, id_1640)], exists([Adot(id_879, id_1640, _G40259)], TRUE))), Conclusion(Adot(id_879, _G40265, _G40259)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G28653, id_891), Isa(_G28653, id_1698), NE(_G28653, id_1640), In(_G28647, id_881)], exists([Adot(id_894, id_1698, _G28647)], TRUE))), Conclusion(Adot(id_894, _G28653, _G28647)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G35135, id_891), Isa(_G35135, id_1640), NE(_G35135, id_1640), In(_G35129, id_881)], exists([Adot(id_894, id_1640, _G35129)], TRUE))), Conclusion(Adot(id_894, _G35135, _G35129)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G22851, id_891), Isa(_G22851, id_1698), NE(_G22851, id_1640), In(_G22845, id_881)], exists([Adot(id_895, id_1698, _G22845)], TRUE))), Conclusion(Adot(id_895, _G22851, _G22845)))$,"computes the sum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G29261, id_891), Isa(_G29261, id_1640), NE(_G29261, id_1640), In(_G29255, id_881)], exists([Adot(id_895, id_1640, _G29255)], TRUE))), Conclusion(Adot(id_895, _G29261, _G29255)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G17286, id_891), Isa(_G17286, id_1698), NE(_G17286, id_1640), In(_G17280, id_881)], exists([Adot(id_896, id_1698, _G17280)], TRUE))), Conclusion(Adot(id_896, _G17286, _G17280)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G23696, id_891), Isa(_G23696, id_1640), NE(_G23696, id_1640), In(_G23690, id_881)], exists([Adot(id_896, id_1640, _G23690)], TRUE))), Conclusion(Adot(id_896, _G23696, _G23690)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,AVG_Attrd objects and classes for ConceptBase.",XBridgePalette,"counts the instances of class",$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal contains gt)
                  ==> (pal contains gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultLink gt)
                  ==> (pal defaultLink gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitIsA gt)
                  ==> (pal implicitIsA gt) $,COUNT_Attribute,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitAttribute gt)
                  ==> (pal implicitAttribute gt) $,TelosPalette,"This is the preferred default graphical palette for ConceptBase 8.2 (released 2021). The previous DefaultJavaPalette is still supported. TelosPalette is closer to the symbols used in UML class diagrams and has better support for long strings.",INDIVIDUAL_TP_GT,ATTR_TP_GT,ISADEDUCED_TP_GT,INSTOFDEDUCED_TP_GT,ATTRDEDUCED_TP_GT,CLASS_TP_GT,QUERYCLASS_TP_GT,INSTOF_TP_GT,ISA_TP_GT,STRING_TP_GT,VALUE_TP_GT,ASSERTION_TP_GT,"Caret","counts the attributes in category <attrcat> of object <objname>","ldashed",6,$ forall a/InstanceOf (a graphtype INSTOF_TP_GT) $,"1",Integer,SUM,"0,50,255","Arrow",$ forall a/IsA (a graphtype ISA_TP_GT) $,"computes the sum of the instances of class (must be reals or integers)","10","255,255,255,240",$ forall x/Proposition!attribute (x graphtype ATTR_TP_GT) $,AVG,"Rect","resizable",$ forall x/Individual (x graphtype INDIVIDUAL_TP_GT) $,"250,250,250",$ forall x/Class (x graphtype CLASS_TP_GT) $,"computes the average of the instances of class (must be reals or integers)","100,100,100","11","wrap","1000","0.3",$ forall x/String (x graphtype STRING_TP_GT) $,MAX,$ forall x/Integer (x graphtype VALUE_TP_GT) $,Class,$ forall x/Real (x graphtype VALUE_TP_GT) $,8,"gives the maximum of the instances of class (must be reals or integers)",$ forall x/MSFOLassertion (x graphtype ASSERTION_TP_GT) $,"255,245,245",$ forall x/QueryClass (x graphtype QUERYCLASS_TP_GT) $,concatl,"Appends the labels2 to the label s1; result is a Label, i.e. not necessarily an object name",MIN,concatl4,"Concats the labels s1,s2,s3,s4",concatl6,Real,"Concats the labels s1,s2,s3,s4,s5,s6",HiddenLabel,resultOf,toString,"gives the minimum of the instances of class (must be reals or integers)","convert the label of obj into a string with double quotes around it",length,"compute the number of characters of the label of obj. The double quotes of strings are not counted.",isLike,"check wether the label (first parameter) is matching a pattern (2nd parameter); Use wildcard * in the pattern",GlobalVariable,currentPalette,valueOf,IsolatedCB_User,SUM_Attribute,$ not exists a/Attribute From(a,this) or To(a,this) $,DoNotSave_2,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             (~this in IsolatedCB_User) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G33706, id_881), In(_G33712, id_891), Isa(_G33712, id_1698), NE(_G33712, id_1640)], exists([Adot(id_879, id_1698, _G33706)], TRUE))), Conclusion(Adot(id_879, _G33712, _G33706)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G40259, id_881), In(_G40265, id_891), Isa(_G40265, id_1640), NE(_G40265, id_1640)], exists([Adot(id_879, id_1640, _G40259)], TRUE))), Conclusion(Adot(id_879, _G40265, _G40259)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G28653, id_891), Isa(_G28653, id_1698), NE(_G28653, id_1640), In(_G28647, id_881)], exists([Adot(id_894, id_1698, _G28647)], TRUE))), Conclusion(Adot(id_894, _G28653, _G28647)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G35135, id_891), Isa(_G35135, id_1640), NE(_G35135, id_1640), In(_G35129, id_881)], exists([Adot(id_894, id_1640, _G35129)], TRUE))), Conclusion(Adot(id_894, _G35135, _G35129)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G22851, id_891), Isa(_G22851, id_1698), NE(_G22851, id_1640), In(_G22845, id_881)], exists([Adot(id_895, id_1698, _G22845)], TRUE))), Conclusion(Adot(id_895, _G22851, _G22845)))$,"computes the sum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G29261, id_891), Isa(_G29261, id_1640), NE(_G29261, id_1640), In(_G29255, id_881)], exists([Adot(id_895, id_1640, _G29255)], TRUE))), Conclusion(Adot(id_895, _G29261, _G29255)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G17286, id_891), Isa(_G17286, id_1698), NE(_G17286, id_1640), In(_G17280, id_881)], exists([Adot(id_896, id_1698, _G17280)], TRUE))), Conclusion(Adot(id_896, _G17286, _G17280)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G23696, id_891), Isa(_G23696, id_1640), NE(_G23696, id_1640), In(_G23690, id_881)], exists([Adot(id_896, id_1640, _G23690)], TRUE))), Conclusion(Adot(id_896, _G23696, _G23690)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,AVG_Attribute,$Rule(Condition(exists([In(_G12072, id_891), Isa(_G12072, id_1698), NE(_G12072, id_1640), In(_G12066, id_881)], exists([Adot(id_897, id_1698, _G12066)], TRUE))), Conclusion(Adot(id_897, _G12072, _G12066)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,$Rule(Condition(exists([In(_G18566, id_891), Isa(_G18566, id_1640), NE(_G18566, id_1640), In(_G18560, id_881)], exists([Adot(id_897, id_1640, _G18560)], TRUE))), Conclusion(Adot(id_897, _G18566, _G18560)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G7142, id_891), Isa(_G7142, id_1698), NE(_G7142, id_1640), In(_G7136, id_881)], exists([Adot(id_898, id_1698, _G7136)], TRUE))), Conclusion(Adot(id_898, _G7142, _G7136)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G13623, id_891), Isa(_G13623, id_1640), NE(_G13623, id_1640), In(_G13617, id_881)], exists([Adot(id_898, id_1640, _G13617)], TRUE))), Conclusion(Adot(id_898, _G13623, _G13617)))$,$Rule(Condition(exists([In(_G17334, id_1)], TRUE)), Conclusion(Adot(id_876, _G17334, id_1732)))$,$Rule(Condition(exists([In(_G19893, id_15)], TRUE)), Conclusion(Adot(id_876, _G19893, id_1735)))$,$Rule(Condition(exists([In(_G22775, id_6)], TRUE)), Conclusion(Adot(id_876, _G22775, id_1710)))$,$Rule(Condition(exists([In(_G25430, id_7)], TRUE)), Conclusion(Adot(id_876, _G25430, id_1706)))$,$Rule(Condition(exists([In(_G28022, id_2)], TRUE)), Conclusion(Adot(id_876, _G28022, id_1726)))$,"computes the average of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$Rule(Condition(exists([In(_G30623, id_24)], TRUE)), Conclusion(Adot(id_876, _G30623, id_1738)))$,$Rule(Condition(exists([In(_G33222, id_18)], TRUE)), Conclusion(Adot(id_876, _G33222, id_1741)))$,$Rule(Condition(exists([In(_G35800, id_21)], TRUE)), Conclusion(Adot(id_876, _G35800, id_1741)))$,$Rule(Condition(exists([In(_G38459, id_33)], TRUE)), Conclusion(Adot(id_876, _G38459, id_1744)))$,$Rule(Condition(exists([In(_G41097, id_65)], TRUE)), Conclusion(Adot(id_876, _G41097, id_1729)))$,jeusfeld,nixbld,MAX_Attribute,String,"gives the maximum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",MIN_Attribute,"gives the minimum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",PLUS,"computes r1 + r2",IPLUS,"computes i1 + i2",AssertionEvaluators,MINUS,"computes r1 - r2",IMINUS,Assertions,"computes i1 - i2",MULT,"computes r1 * r2",IMULT,"computes i1 * i2",DIV,MSFOLassertion,"computes r1 / r2",IDIV,"computes truncate(i1/i2)",ConcatenateStrings,"Appends string s2 to the end of string s1",ConcatenateStrings3,MAssertion,"Append strings s1 + s2 + s3",ConcatenateStrings4,"Append strings s1 + s2 + s3 + s4",StringToLabel,"returns s as a label (without quotes)",BDMConstraintCheck,BDMRuleCheck,MRule,get_object,exists,rename,get_object_star,Magic,changeAttributeValue,find_instances,$ (this in ~class) $,find_storeframes_instances,MSFOLrule,$ (this in ~class) and (not
(this in MSFOLassertion)) and
(not (this in BDMConstraintCheck)) and
(not (this in BDMRuleCheck))$,ISINSTANCE,$ ((~obj in ~class)==>(this == TRUE))and
    (not (~obj in ~class)==>(this == FALSE)) $,ISSUBCLASS,$ ((~sub isA ~super)==>(this == TRUE))and
    (not (~sub isA ~super)==>(this == FALSE)) $,find_iattributes,metaMSFOLrule,$ To(this,~class) $,find_specializations,$    (~ded == TRUE) and (this isA ~class)
           or (~ded == FALSE) and Isa_e(this,~class) $,MSFOLconstraint,AvailableVersions,$ exists x/Proposition P(x,~this,'*instanceof',Version) and Known(x,~time) $,find_incoming_links,$ To(this,~objname) and In(this,~category) $,find_incoming_links_simple,$ To(this,~objname) $,find_outgoing_links,metaMSFOLconstraint,$ From(this,~objname) and In(this,~category) $,find_outgoing_links_simple,$ From(this,~objname) $,find_classes,$ In(~objname,this) or
              (In_s(~this,QueryClass) and In(~objname,~this)) or
              (In_s(~this,QueryCall) and In(~objname,~this))$,find_explicit_classes,$ In_s(~objname,this) $,find_explicit_instances,MSFOLquery,$ In_s(this,~class) $,find_generalizations,$    (~ded == TRUE) and (~class isA this)
           or (~ded == FALSE) and Isa_e(~class,this) $,IS_EXPLICIT_INSTANCE,$ (In_s(~obj,~class)==>(this == TRUE)) and
    (not In_s(~obj,~class)==>(this == FALSE)) $,IS_EXPLICIT_SUBCLASS,QueryClass,$ (Isa_e(~sub,~super)==>(this == TRUE)) and
    (not Isa_e(~sub,~super)==>(this == FALSE)) $,find_referring_objects,$ exists a/Attribute l/Label Pa(a,this,l,~class) $,AF_find_referring_objects_obi,"","{ASKquery(get_object[{this}/objname],FRAME)}",IS_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A(~src,l,~dst) and UNIFIES(this,TRUE) $,Individual,IS_EXPLICIT_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A_e(~src,l,~dst) and UNIFIES(this,TRUE) $,get_links2,GenericQueryClass,$ exists l/Label P(this,~src,l,~dst) $,get_links3,$ exists l/Label P(this,~src,l,~dst) and (this in ~cat) $,find_all_explicit_attribute_values,$ exists x/Attribute l/Label Pa(x,~objname,l,this) $,find_referring_objects2,$ AeD(~cat,this,~objname) $,BuiltinQueryClass,find_all_referring_objects2,$ AD(~cat,this,~objname) $,find_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,c,l,d) and not(UNIFIES(c,Proposition)) and
 not (In(d,MSFOLassertion) or In(d,BDMRuleCheck) or In(d,BDMConstraintCheck))) or UNIFIES(this,Attribute) $,find_used_attribute_categories,Token,View,$  exists x/Proposition AD(this,~objname,x) and 
                (this <> Class!rule) and (this <> Class!constraint) and 
                (this <> Proposition!applyConstraintIfInsert) and (this <> Proposition!applyConstraintIfDelete) and 
                (this <> Proposition!applyRuleIfInsert) and (this <> Proposition!applyRuleIfDelete) and 
                (this <> Proposition!deducedBy) $,find_attribute_values,$ AD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_explicit_attribute_values,$ AeD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_incoming_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,d,l,c) and not(UNIFIES(c,Proposition))) or UNIFIES(this,Attribute) $,find_used_incoming_attribute_categories,SubView,$  exists x/Proposition AD(this,x,~objname)  $,find_object,$ UNIFIES(this,~objname) $,DatalogQueryClass,"Similar to get_object, but just returns the object (used by JavaGraphBrowser)",GraphicalType,GraphicalPalette,JavaGraphicalType,$ forall jgt/JavaGraphicalType (not (exists i/Integer A_e(jgt,priority,i))) ==> A(jgt,priority,0) $,JavaGraphicalPalette,SimpleClass,CBGraphEditorResult,"This answer format has four parameters: 'obj' is the object
   which is related to the result objects, 'cat' is the category of the link
   between 'obj' and 'this', 'pal' is the graphical palette, and 'objtype'
   specifies whether 'obj' should be considered as source (src) or destination (dst)
   in the set of edges to be included in answer.","<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<result>",DatalogRule,"</result>","
{buildCBEditorResult({this},{obj},{cat},{pal},{objtype})}
",CBGraphEditorResultWithoutEdges,"This answer format is like CBGraphEditorResult but it
   will not output any edges. Therefore, it has only the parameter
   'pal' to indicate the graphical palette.","
{buildCBEditorResultWithoutEdges({this},{pal})}
",GetJavaGraphicalPalette,DatalogInRule,$ UNIFIES(this,~pal) $,XML_JavaGraphicalPalette,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<palette>","</palette>","
<contains>
{Foreach(({this.contains}),(gt),
{ASKquery(GetJavaGraphicalType[{gt}/gt],XML_JavaGraphicalType)})}
</contains>
  <defaultIndividual>{this.defaultIndividual}</defaultIndividual>
  <defaultLink>{this.defaultLink}</defaultLink>
  <implicitIsA>{this.implicitIsA}</implicitIsA>
  <implicitInstanceOf>{this.implicitInstanceOf}</implicitInstanceOf>
  <implicitAttribute>{this.implicitAttribute}</implicitAttribute>
{Foreach(({this.palproperty},{this|palproperty}),(v,l),
  <palproperty>
    <name>{l}</name>
    <value>{v}</value>
  </palproperty>)}
",GetJavaGraphicalType,DatalogAttrRule,$ UNIFIES(~gt,this)  $,XML_JavaGraphicalType,"<graphtype>"
[localhost:4001]>ibute,$Rule(Condition(exists([In(_G12072, id_891), Isa(_G12072, id_1698), NE(_G12072, id_1640), In(_G12066, id_881)], exists([Adot(id_897, id_1698, _G12066)], TRUE))), Conclusion(Adot(id_897, _G12072, _G12066)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,$Rule(Condition(exists([In(_G18566, id_891), Isa(_G18566, id_1640), NE(_G18566, id_1640), In(_G18560, id_881)], exists([Adot(id_897, id_1640, _G18560)], TRUE))), Conclusion(Adot(id_897, _G18566, _G18560)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G7142, id_891), Isa(_G7142, id_1698), NE(_G7142, id_1640), In(_G7136, id_881)], exists([Adot(id_898, id_1698, _G7136)], TRUE))), Conclusion(Adot(id_898, _G7142, _G7136)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G13623, id_891), Isa(_G13623, id_1640), NE(_G13623, id_1640), In(_G13617, id_881)], exists([Adot(id_898, id_1640, _G13617)], TRUE))), Conclusion(Adot(id_898, _G13623, _G13617)))$,$Rule(Condition(exists([In(_G17334, id_1)], TRUE)), Conclusion(Adot(id_876, _G17334, id_1732)))$,$Rule(Condition(exists([In(_G19893, id_15)], TRUE)), Conclusion(Adot(id_876, _G19893, id_1735)))$,$Rule(Condition(exists([In(_G22775, id_6)], TRUE)), Conclusion(Adot(id_876, _G22775, id_1710)))$,$Rule(Condition(exists([In(_G25430, id_7)], TRUE)), Conclusion(Adot(id_876, _G25430, id_1706)))$,$Rule(Condition(exists([In(_G28022, id_2)], TRUE)), Conclusion(Adot(id_876, _G28022, id_1726)))$,"computes the average of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$Rule(Condition(exists([In(_G30623, id_24)], TRUE)), Conclusion(Adot(id_876, _G30623, id_1738)))$,$Rule(Condition(exists([In(_G33222, id_18)], TRUE)), Conclusion(Adot(id_876, _G33222, id_1741)))$,$Rule(Condition(exists([In(_G35800, id_21)], TRUE)), Conclusion(Adot(id_876, _G35800, id_1741)))$,$Rule(Condition(exists([In(_G38459, id_33)], TRUE)), Conclusion(Adot(id_876, _G38459, id_1744)))$,$Rule(Condition(exists([In(_G41097, id_65)], TRUE)), Conclusion(Adot(id_876, _G41097, id_1729)))$,jeusfeld,nixbld,MAX_Attribute,String,"gives the maximum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",MIN_Attribute,"gives the minimum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",PLUS,"computes r1 + r2",IPLUS,"computes i1 + i2",AssertionEvaluators,MINUS,"computes r1 - r2",IMINUS,Assertions,"computes i1 - i2",MULT,"computes r1 * r2",IMULT,"computes i1 * i2",DIV,MSFOLassertion,"computes r1 / r2",IDIV,"computes truncate(i1/i2)",ConcatenateStrings,"Appends string s2 to the end of string s1",ConcatenateStrings3,MAssertion,"Append strings s1 + s2 + s3",ConcatenateStrings4,"Append strings s1 + s2 + s3 + s4",StringToLabel,"returns s as a label (without quotes)",BDMConstraintCheck,BDMRuleCheck,MRule,get_object,exists,rename,get_object_star,Magic,changeAttributeValue,find_instances,$ (this in ~class) $,find_storeframes_instances,MSFOLrule,$ (this in ~class) and (not
(this in MSFOLassertion)) and
(not (this in BDMConstraintCheck)) and
(not (this in BDMRuleCheck))$,ISINSTANCE,$ ((~obj in ~class)==>(this == TRUE))and
    (not (~obj in ~class)==>(this == FALSE)) $,ISSUBCLASS,$ ((~sub isA ~super)==>(this == TRUE))and
    (not (~sub isA ~super)==>(this == FALSE)) $,find_iattributes,metaMSFOLrule,$ To(this,~class) $,find_specializations,$    (~ded == TRUE) and (this isA ~class)
           or (~ded == FALSE) and Isa_e(this,~class) $,MSFOLconstraint,AvailableVersions,$ exists x/Proposition P(x,~this,'*instanceof',Version) and Known(x,~time) $,find_incoming_links,$ To(this,~objname) and In(this,~category) $,find_incoming_links_simple,$ To(this,~objname) $,find_outgoing_links,metaMSFOLconstraint,$ From(this,~objname) and In(this,~category) $,find_outgoing_links_simple,$ From(this,~objname) $,find_classes,$ In(~objname,this) or
              (In_s(~this,QueryClass) and In(~objname,~this)) or
              (In_s(~this,QueryCall) and In(~objname,~this))$,find_explicit_classes,$ In_s(~objname,this) $,find_explicit_instances,MSFOLquery,$ In_s(this,~class) $,find_generalizations,$    (~ded == TRUE) and (~class isA this)
           or (~ded == FALSE) and Isa_e(~class,this) $,IS_EXPLICIT_INSTANCE,$ (In_s(~obj,~class)==>(this == TRUE)) and
    (not In_s(~obj,~class)==>(this == FALSE)) $,IS_EXPLICIT_SUBCLASS,QueryClass,$ (Isa_e(~sub,~super)==>(this == TRUE)) and
    (not Isa_e(~sub,~super)==>(this == FALSE)) $,find_referring_objects,$ exists a/Attribute l/Label Pa(a,this,l,~class) $,AF_find_referring_objects_obi,"","{ASKquery(get_object[{this}/objname],FRAME)}",IS_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A(~src,l,~dst) and UNIFIES(this,TRUE) $,Individual,IS_EXPLICIT_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A_e(~src,l,~dst) and UNIFIES(this,TRUE) $,get_links2,GenericQueryClass,$ exists l/Label P(this,~src,l,~dst) $,get_links3,$ exists l/Label P(this,~src,l,~dst) and (this in ~cat) $,find_all_explicit_attribute_values,$ exists x/Attribute l/Label Pa(x,~objname,l,this) $,find_referring_objects2,$ AeD(~cat,this,~objname) $,BuiltinQueryClass,find_all_referring_objects2,$ AD(~cat,this,~objname) $,find_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,c,l,d) and not(UNIFIES(c,Proposition)) and
 not (In(d,MSFOLassertion) or In(d,BDMRuleCheck) or In(d,BDMConstraintCheck))) or UNIFIES(this,Attribute) $,find_used_attribute_categories,Token,View,$  exists x/Proposition AD(this,~objname,x) and 
                (this <> Class!rule) and (this <> Class!constraint) and 
                (this <> Proposition!applyConstraintIfInsert) and (this <> Proposition!applyConstraintIfDelete) and 
                (this <> Proposition!applyRuleIfInsert) and (this <> Proposition!applyRuleIfDelete) and 
                (this <> Proposition!deducedBy) $,find_attribute_values,$ AD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_explicit_attribute_values,$ AeD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_incoming_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,d,l,c) and not(UNIFIES(c,Proposition))) or UNIFIES(this,Attribute) $,find_used_incoming_attribute_categories,SubView,$  exists x/Proposition AD(this,x,~objname)  $,find_object,$ UNIFIES(this,~objname) $,DatalogQueryClass,"Similar to get_object, but just returns the object (used by JavaGraphBrowser)",GraphicalType,GraphicalPalette,JavaGraphicalType,$ forall jgt/JavaGraphicalType (not (exists i/Integer A_e(jgt,priority,i))) ==> A(jgt,priority,0) $,JavaGraphicalPalette,SimpleClass,CBGraphEditorResult,"This answer format has four parameters: 'obj' is the object
   which is related to the result objects, 'cat' is the category of the link
   between 'obj' and 'this', 'pal' is the graphical palette, and 'objtype'
   specifies whether 'obj' should be considered as source (src) or destination (dst)
   in the set of edges to be included in answer.","<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<result>",DatalogRule,"</result>","
{buildCBEditorResult({this},{obj},{cat},{pal},{objtype})}
",CBGraphEditorResultWithoutEdges,"This answer format is like CBGraphEditorResult but it
   will not output any edges. Therefore, it has only the parameter
   'pal' to indicate the graphical palette.","
{buildCBEditorResultWithoutEdges({this},{pal})}
",GetJavaGraphicalPalette,DatalogInRule,$ UNIFIES(this,~pal) $,XML_JavaGraphicalPalette,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<palette>","</palette>","
<contains>
{Foreach(({this.contains}),(gt),
{ASKquery(GetJavaGraphicalType[{gt}/gt],XML_JavaGraphicalType)})}
</contains>
  <defaultIndividual>{this.defaultIndividual}</defaultIndividual>
  <defaultLink>{this.defaultLink}</defaultLink>
  <implicitIsA>{this.implicitIsA}</implicitIsA>
  <implicitInstanceOf>{this.implicitInstanceOf}</implicitInstanceOf>
  <implicitAttribute>{this.implicitAttribute}</implicitAttribute>
{Foreach(({this.palproperty},{this|palproperty}),(v,l),
  <palproperty>
    <name>{l}</name>
    <value>{v}</value>
  </palproperty>)}
",GetJavaGraphicalType,DatalogAttrRule,$ UNIFIES(~gt,this)  $,XML_JavaGraphicalType,"<graphtype>"
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
