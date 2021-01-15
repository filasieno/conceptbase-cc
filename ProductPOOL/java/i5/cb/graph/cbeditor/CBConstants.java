/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb.graph.cbeditor;

import i5.cb.graph.GEConstants;

/** These are constants used by many classes in this package
 *
 * @author schoeneb
 * created 07 March 2002
 */
public interface CBConstants extends GEConstants {

    /**
    * The name of the ConceptBase Editor app
    */
    final static String CBEDITOR_NAME = "CBGraph";

    /**
    * diarectory where the classes find their resources at runtime
    */
    final static String CB_RESOURCE_DIR = RESOURCE_DIR + "/cbeditor_resources";

    /**
    * the location of the REsourceBundle class (in our case just a textfile, but it's threatened as class)
    */
    final static String CB_BUNDLE_NAME =
        "resources.cbeditor_resources.CBBundle";

    /*
    These are handles used to retrieve buttons from the m_graphToolBar
    */
    final static String NEW_CONNECTION_BUTTON = "Add a new connection";
    final static String NEW_NODE_BUTTON = "Add a new node";
    final static String SHOW_RELATIONS_BUTTON = "Show Relations";

    public final static int QUERY_SUBCLASSES = 3;
    public final static int QUERY_SUPERCLASSES = 4;
    public final static int QUERY_EXPLICIT_INSTANCES = 5;
    public final static int QUERY_EXPLICIT_CLASSES = 6;
    public final static int QUERY_ATTRIBUTES = 7;

    public final static String DEFAULT_PALETTE = "DefaultJavaPalette";
    public final static String CB_HOME_MODULE = "oHome";
    public final static String CB_SYSTEM_MODULE = "System";

    public final static int POPUPMENU_MAX_SIZE = 14;

}
