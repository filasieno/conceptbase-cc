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
package i5.cb.graph;

public interface GEConstants {

    /**
     * This is the resource directory for all applicastions
     */
    public static final String RESOURCE_DIR = "/resources";

    /**
     * Here the classes of this package can find their resources at runtime
     */
    public static final String GE_RESOURCE_DIR =
        RESOURCE_DIR + "/graph_resources";

    /**
     * This is the ResourceBundle of this package
     */
    public static final String GE_BUNDLE_NAME =
        "resources.graph_resources.GEBundle";

    /*
     These are handles for the GraphEditor's buttons which are used to get them back
     from the toolbar to change their tooltiptext or other stuff
     */
    public static final String SAVE_BUTTON = "save";
    public static final String LOAD_BUTTON = "load";
    public static final String REMOVE_BUTTON = "remove";
    public static final String NEWFRAME_BUTTON = "new";

    /*
     These are the positions a node can have relative
     to another node when added to a {@i5.cb.graph.DiagramDesktop}
     */
    public static final int DEFAULT_POSITION = 0;
    public static final int N_POSITION = 1;
    public static final int E_POSITION = 2;
    public static final int S_POSITION = 3;
    public static final int W_POSITION = 4;

} //GEConstants
