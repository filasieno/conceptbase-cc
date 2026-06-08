= Specify Resizable Shapes

Verified independently via:

```bash
nix build .#checks.x86_64-linux.specify-resizable-shapes
```

== Input

=== `allshapes.sml.txt`

```telos
{
*
* File: allshapes.sml.txt
* Author: Manfred Jeusfeld
* Creation: 4-Dec-2013 (22-Nov-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Examples of all graphical shapes provided by ConceptBase graph editor
*
}

XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 




AllShapesPalette in JavaGraphicalPalette isA XPalette with
  palproperty
    longtitle: "ConceptBase.cc Graph Types"
  contains
    gt2: Arrow2_GT;
    gt3: Circle_GT;
    gt4: Cross_GT;
    gt5: Diamond_GT;
    gt6: DoubleArrow_GT;
    gt7: DownPentagon_GT;
    gt8: DownTriangle_GT;
    gt9: RoundRectangle_GT;
    gt10: Ellipse_GT;
    gt11: Hexagon_GT;
    gt12: Octagon_GT;
    gt13: Pentagon_GT;
    gt14: Rect_GT;
    gt16: Star_GT;
    gt17: UpHexagon_GT;
    gt18: XCross_GT;
    gt19: DiRect_GT;
    gt20: Triangle_GT;
    gt21: TriangleL_GT;
    gt22: TriangleR_GT;
    gt23: House_GT;
    gt24: Septagon_GT;
    gt25: FolderL_GT;
    gt26: FolderR_GT;
    gt27: Page_GT;
    gt28: DiRectL_GT;
    gt29: DiRectR_GT;
    gt30: Banner_GT;
    gt31: ArrowR_GT;
    gt32: ArrowL_GT;
    gt33: Tube_GT;
    gt34: Cloud_GT;
    shgt: FolderForShapes_GT;
    gt50 : StadionCurve_GT;
    gt51 : UpStadionCurve_GT;
    gt52 : DownArrow_GT;
    gt63 : PolygonShape_GT
end

Shapes in Class with
  graphtype gt: FolderForShapes_GT
  rule
   r1: $ forall gt/JavaGraphicalType sh/Shapes (AllShapesPalette contains gt)
          and (not exists s/String :(gt property/size s):)
         ==> (gt property/size "resizable") $;
   r2: $ forall sh/Proposition gt/JavaGraphicalType
          :(AllShapesPalette contains gt): and (sh graphtype gt) 
          and (sh <> Shapes) ==> (sh in Shapes) $;
   r3: $ forall gt/JavaGraphicalType sh/Shapes (AllShapesPalette contains gt)
          and (not exists s/String :(gt property/font s):)
         ==> (gt property/font "Arial") $;
   r4: $ forall gt/JavaGraphicalType sh/Shapes (AllShapesPalette contains gt)
          and (not exists s/String :(gt property/fontsize s):)
         ==> (gt property/fontsize "10") $
end


FolderForShapes_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,235";
	textcolor : "120,120,120";
	linecolor : "120,120,120";
	linewidth : "3";
        align: "topleft";
	shape : "i5.cb.graph.shapes.FolderL"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 23
end


Cloud with
  graphtype gt: Cloud_GT
end
Cloud_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Cloud"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Tube with
  graphtype gt: Tube_GT
end
Tube_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "right";
	shape : "i5.cb.graph.shapes.Tube"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

ArrowL with
  graphtype gt: ArrowL_GT
end
ArrowL_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.ArrowL"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


ArrowR with
  graphtype gt: ArrowR_GT
end
ArrowR_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.ArrowR"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

DiRectR with
  graphtype gt: DiRectR_GT
end
DiRectR_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.DiRectR"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

DiRectL with
  graphtype gt: DiRectL_GT
end
DiRectL_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.DiRectL"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Banner with
  graphtype gt: Banner_GT
end
Banner_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Banner"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Page with
  graphtype gt: Page_GT
end
Page_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Page"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


FolderR with
  graphtype gt: FolderR_GT
end
FolderR_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "topright";
	shape : "i5.cb.graph.shapes.FolderR"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

FolderL with
  graphtype gt: FolderL_GT
end
FolderL_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "topleft";
	shape : "i5.cb.graph.shapes.FolderL"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Septagon with
  graphtype gt: Septagon_GT
end
Septagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Septagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

House with
  graphtype gt: House_GT
end
House_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.House"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

TriangleR with
  graphtype gt: TriangleR_GT
end
TriangleR_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "left";
	shape : "i5.cb.graph.shapes.TriangleR"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

TriangleL with
  graphtype gt: TriangleL_GT
end
TriangleL_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "right";
	shape : "i5.cb.graph.shapes.TriangleL"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


DiRect with
  graphtype gt: DiRect_GT
end
DiRect_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.DiRect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


XCross with
  graphtype gt: XCross_GT
end
XCross_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.XCross"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

UpHexagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.UpHexagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

UpHexagon with
  graphtype gt: UpHexagon_GT
end
UpHexagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.UpHexagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Triangle with
  graphtype gt: Triangle_GT
end
Triangle_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "bottom";
	shape : "i5.cb.graph.shapes.Triangle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


Star with
  graphtype gt: Star_GT
end
Star_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Star"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

RoundRectangle with
  graphtype gt: RoundRectangle_GT
end
RoundRectangle_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.RoundRectangle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Rect with
  graphtype gt: Rect_GT
end
Rect_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Pentagon with
  graphtype gt: Pentagon_GT
end
Pentagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Pentagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Octagon with
  graphtype gt: Octagon_GT
end
Octagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Hexagon with
  graphtype gt: Hexagon_GT
end
Hexagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Hexagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Ellipse with
  graphtype gt: Ellipse_GT
end
Ellipse_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


DownTriangle with
  graphtype gt: DownTriangle_GT
end
DownTriangle_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        align: "top";
	shape : "i5.cb.graph.shapes.DownTriangle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

DownPentagon with
  graphtype gt: DownPentagon_GT
end
DownPentagon_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.DownPentagon"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

DoubleArrow with
  graphtype gt: DoubleArrow_GT
end
DoubleArrow_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.DoubleArrow"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Diamond with
  graphtype gt: Diamond_GT
end
Diamond_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


Cross with
  graphtype gt: Cross_GT
end
Cross_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Cross"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Arrow with
  graphtype gt: Arrow_GT
end
Arrow_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Arrow"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end

Arrow2 with
  graphtype gt: Arrow2_GT
end
Arrow2_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Arrow2"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


Circle with
  graphtype gt: Circle_GT
end
Circle_GT in JavaGraphicalType with
  property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	size : "45x45";
	shape : "i5.cb.graph.shapes.Circle"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end


StadionCurve with  
  graphtype
    gt : StadionCurve_GT
end 

StadionCurve_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "i5.cb.graph.shapes.StadionCurve"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 

UpStadionCurve with  
  graphtype
    gt : UpStadionCurve_GT
end 
UpStadionCurve_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "i5.cb.graph.shapes.UpStadionCurve"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 

DownArrow with  
  graphtype
    gt : DownArrow_GT
end 

DownArrow_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "i5.cb.graph.shapes.DownArrow"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


PolygonShapeXY with  
  graphtype
    gt : PolygonShape_GT
end 
PolygonShape_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    align: "top";
    shape : "PolygonShape;0,7,13,19,20,19,19,13, 7, 1,1,2,0;0,1, 0, 2, 6,10,14,28,13,12,8,4,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 



```

=== `userdefinedshapes.sml.txt`

```telos
{
*
* File: userdefinedshapes.sml.txt
* Author: Manfred Jeusfeld
* Creation: 20-Nov-2014 (21-Nov-2014/M.Jeusfeld)
* ----------------------------------------------------------------------
* 
* Examples of user-defined graphical types for the ConceptBase graph editor
*
}

{*
This file is governed by the Creative Commons license 
   attributeion 4.0 International (CC BY 4.0)
   https://creativecommons.org/licenses/by/4.0/
*}



XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 




UserShapesPalette in JavaGraphicalPalette isA XPalette with
  palproperty
    longtitle: "User-Defined Graphical Types"
  contains
    ug01 : Parallelogram_GT;
    ug02 : Trapezoid_GT;
    ug03 : RectWithBump_GT;
    ug04 : Folder_GT;
    ug05 : RectWithNotch_GT;
    ug06 : RectWithVLine_GT;
    ug07 : RectWithSpikes_GT;
    ug08 : SmileIcon_GT;
    ug09 : SmileIconShape_GT;
    ug10 : SmileIconShape2_GT
end

Shapes in Class with
  rule
   r1: $ forall gt/JavaGraphicalType sh/Shapes (UserShapesPalette contains gt)
          and (not exists s/String :(gt property/size s):)
         ==> (gt property/size "resizable") $;
   r2: $ forall sh/Proposition gt/JavaGraphicalType
          :(UserShapesPalette contains gt): and (sh graphtype gt) 
          and (sh <> Shapes) ==> (sh in Shapes) $;
   r3: $ forall gt/JavaGraphicalType sh/Shapes (UserShapesPalette contains gt)
          and (not exists s/String :(gt property/font s):)
         ==> (gt property/font "Arial") $;
   r4: $ forall gt/JavaGraphicalType sh/Shapes (UserShapesPalette contains gt)
          and (not exists s/String :(gt property/fontsize s):)
         ==> (gt property/fontsize "10") $
end




Parallelogram with  
  graphtype
    gt : Parallelogram_GT
end 
Parallelogram_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape; 2,25,23, 0,2;
                           0, 0,10,10,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 

Trapezoid with  
  graphtype
    gt : Trapezoid_GT
end 
Trapezoid_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape; 4,23,25, 0,4;
                           0, 0,10,10,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


RectWithBump with  
  graphtype
    gt : RectWithBump_GT
end 
RectWithBump_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape; 0,15,15,18,18,25,25, 0,0;
                           3, 3, 0, 0, 3, 3,10,10,3"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 

Folder with  
  graphtype
    gt : Folder_GT
end 
Folder_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape;0,6,7,10,10,0,0;1,1,0,0,7,7,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


RectWithNotch with  
  graphtype
    gt : RectWithNotch_GT
end 
RectWithNotch_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape; 0,3, 3,4,25,25, 0,0;
                           0,0, 9,0, 0,10,10,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


RectWithVLine with  
  graphtype
    gt : RectWithVLine_GT
end 
RectWithVLine_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "PolygonShape; 0,120,121,121,121,2500,2500,   0,0;
                           0,  0,998,998,  0,   0,1000,1000,0"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


RectWithSpikes with  
  graphtype
    gt : RectWithSpikes_GT
end 
RectWithSpikes_GT in JavaGraphicalType with  
  property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    align: "bottom";
    shape : "PolygonShape;  0,15,16,50,17,17,160,162,165,163,163,250,250,  0, 0;
                           40,40,14, 0,14,40, 40, 16,  0, 16, 40, 40,100,100,40"
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 22
end 


SmileIcon with  
  graphtype
    gt : SmileIcon_GT
end 
SmileIcon_GT in JavaGraphicalType with
property
   textcolor : "0,0,0";
   linecolor : "0,0,0";
   size: "resizable";
   image : "http://conceptbase.sourceforge.net/CBICONS/cbsmile.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
end

SmileIconShape with  
  graphtype
    gt : SmileIconShape_GT
end 
SmileIconShape_GT in JavaGraphicalType with
property
   textcolor : "0,0,0";
   linecolor : "0,0,0";
   size: "resizable";
   bgcolor: "220,220,220";
   shape : "i5.cb.graph.shapes.RoundRectangle";
   image : "http://conceptbase.sourceforge.net/CBICONS/cbsmile.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
end

SmileIconShape2 with  
  graphtype
    gt : SmileIconShape2_GT
end 
SmileIconShape2_GT in JavaGraphicalType with
property
   textcolor : "0,0,0";
   linecolor : "0,0,0";
   size: "resizable";
   bgcolor: "220,220,220";
   shape : "i5.cb.graph.shapes.Banner";
   textposition : "top";
   align : "left";
   image : "http://conceptbase.sourceforge.net/CBICONS/cbsmile.png"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
end










```

=== `WrappableShapes/Frogs.sml.txt`

```telos
{
* File: Frogs.sml.txt
* Author: Manfred Jeusfeld
* Created: 2017-07-07/M.Jeusfeld (2017-07-07/M.Jeusfeld)
* ------------------------------------------------------
* Shows how to use long wrapped texts in combination with images as node types
* 
* This requires ConceptBase 8.0 released after July 2017!
}

{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 4.0 International
   https://creativecommons.org/licenses/by-nc/4.0/
   https://creativecommons.org/licenses/by-nc/4.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


Species in Class with
  attribute
    definition: String;
    image: String
end

FrogSpecies isA Species end



PanamianGoldenFrog in FrogSpecies with
  definition
   d: "The Panamanian golden frog (Atelopus zeteki) is a species of toad endemic to Panama. Panamanian golden frogs inhabit the streams along the mountainous slopes of the Cordilleran cloud forests of west-central Panama. While the IUCN lists it as critically endangered, it may in fact have been extinct in the wild since 2007. Individuals have been collected for breeding in captivity in a bid to preserve the species. The alternative common name, Zetek's golden frog, and the epithet zeteki both commemorate the entomologist James Zetek. (source: Wikipedia)"
  image
   i: "frogs/220px-Atelopus_zeteki1.jpg"
end


EuropeanTreeFrog in FrogSpecies with
  definition
   d: "The European tree frog (Hyla arborea formerly Rana arborea) is a small tree frog found in Europe, Asia and part of Africa. Based on molecular genetic and other data, a number of taxa formerly treated as subspecies of H. arborea are now generally recognized as full species. (source: Wikipedia)"
  image
   i: "frogs/220px-Hyla_arborea_juv_2.jpg"
end





{* XPalette just makes is easier to define graphical palettes *}



XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 




{* This is the palette to display illustrations of frogs and other things *}

ImagePalette in Class,JavaGraphicalPalette isA XPalette with  
  contains
    sp1 : INDIVIDUAL_GT;
    sp2 : INSTOF_GT;
    sp3 : ATTR_GT;
    sp4 : Species_GT
end 


INSTOF_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    linecolor : "0,180,0";
    edgecolor : "0,180,0";
    edgewidth : "2";
    edgestyle : "ldashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 5
  rule
     gtrule: $ forall a/InstanceOf (a graphtype INSTOF_GT) $
end 

INSTOFDEDUCED_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    linecolor : "0,180,0";
    edgecolor : "0,180,0";
    edgewidth : "2";
    edgestyle : "dashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 5
end  


ATTR_GT in Class,JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    bgcolor : "255,255,255"  {* white *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 5
  rule
     gtrule: $ forall x/Proposition!attribute (x graphtype ATTR_GT) $
end 

ATTRDEDUCED_GT in JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    edgestyle : "dotted";
    bgcolor : "255,255,255"  {* white *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 5
end 

INDIVIDUAL_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
        size: "resizable";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 5
rule
     gtrule: $ forall x/Individual (x graphtype INDIVIDUAL_GT) $
end

Species_GT in Class,JavaGraphicalType with
property
	bgcolor : "240,255,255"; 
	textcolor : "0,0,0";
	linecolor : "150,150,150";
        fontsize : "9";
        font : "Serif";
        labellength : "2000"; 
	shape : "i5.cb.graph.shapes.Rect";
        size: "wrap";
        linewidth : "2";
        textposition : "right"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall x/Species (x graphtype Species_GT) $;
     labrule: $ forall x/Species s/String (x definition s) ==> (x gproperty/label s) $;
     imgrule: $ forall x/Species img/String (x image img) ==> (x gproperty/image img) $
end




```

== Graph files

- `shapes.gel`
- `usershapes.gel`
- `frogs.gel`

== Shell output

```text
=== HOW-TO: specify-resizable-shapes ===

>>> Telling ./WrappableShapes/Frogs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./allshapes.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./userdefinedshapes.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
