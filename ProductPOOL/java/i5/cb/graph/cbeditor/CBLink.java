/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*/
package i5.cb.graph.cbeditor;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Shape;
import i5.cb.graph.shapes.*;



public class CBLink extends CBUserObject{

    Color getEdgeColor(){
        if(hasProperty("edgecolor") ){
            return CBUtil.stringToColor( getProperty("edgecolor") );
        }
        else{
            return Color.BLACK;
        }
    }

    Color getEdgeHeadColor(){
        if(hasProperty("edgeheadcolor") ){
            return CBUtil.stringToColor( getProperty("edgeheadcolor") );
        }
        else{
            return this.getEdgeColor();
        }
    }

    Shape getEdgeHeadShape(){
        if(hasProperty("edgeheadshape") ){
            return stringToShape( getProperty("edgeheadshape") );
        }
        else{
            return this.getDefaultEdgeHeadShape();
        }
    }


    BasicStroke getEdgeStroke() {
        int edgewidth=1;

        if(hasProperty("edgewidth"))
            edgewidth=Integer.parseInt( getProperty("edgewidth") );

        if(hasProperty("edgestyle")) {
            String sStyle=getProperty("edgestyle");
            if(sStyle.equals("dashed")) {
                float dash[] = { 4.0f };
                return new BasicStroke(edgewidth, BasicStroke.CAP_BUTT,
                                BasicStroke.JOIN_MITER, 10.0f, dash, 0.0f);
            }
            // long dashed
            if(sStyle.equals("ldashed")) {
                float dash[] = { 5.8f };
                return new BasicStroke(edgewidth, BasicStroke.CAP_BUTT,
                                BasicStroke.JOIN_MITER, 10.0f, dash, 0.0f);
            }
            if(sStyle.equals("dotted")) {
                float dash[] = { 1.0f };
                return new BasicStroke(edgewidth, BasicStroke.CAP_BUTT,
                                BasicStroke.JOIN_MITER, 10.0f, dash, 0.0f);
            }
            // long dotted
            if(sStyle.equals("ldotted")) {
                float dash[] = { 2.0f };
                return new BasicStroke(edgewidth, BasicStroke.CAP_BUTT,
                                BasicStroke.JOIN_MITER, 10.0f, dash, 0.0f);
            }
            if(sStyle.equals("dashdotted")) {
                float dash[] = { 5.0f, 2.0f, 1.0f, 2.0f };
                return new BasicStroke(edgewidth, BasicStroke.CAP_BUTT,
                                BasicStroke.JOIN_MITER, 10.0f, dash, 0.0f);
            }
            // default is continuous
        }
        return new BasicStroke(edgewidth);
    }

    Shape stringToShape(String shapename) {
      try {
        if (shapename.equals("none")) {
           return null;
         } else {
           if (!shapename.contains(".shapes."))
              shapename = "i5.cb.graph.shapes." + shapename;
           Class shapeClass = Class.forName(shapename);
           return (Shape) shapeClass.newInstance();
         }
      } catch (Exception e) {
        return getDefaultEdgeHeadShape();
      }
    }





    Shape getDefaultEdgeHeadShape() {
      if (getEdgeStroke().getLineWidth() < 2.5F) 
        return new VeeArrow();  // thin edges get a slightly modified edge head
      else
        return new Arrow();
    }
}



