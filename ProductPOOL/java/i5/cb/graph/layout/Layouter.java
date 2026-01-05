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
/*
 * Created on 2004-12-3
 *
 */
package i5.cb.graph.layout;


/**
 * This class calculate the layout of given graph
 * 
 * @author Li, Yong
 * 
 * @version 1.0
 */
public class Layouter {
    /**
     * abstract graph data structure
     */
    private LayoutGraph m_gGraph;

    /**
     * graph configuration
     */
    private Config m_config;

    /**
     * the minimum distance between two nodes in the same rank
     */
    private double m_minNodeDistance = 20.0;

    /**
     * the minimum distantce between two ranks
     */
    private double m_minRankDistance = 50.0;

    /**
     * the ranker used to assign rank to nodes
     */
    private Ranker m_ranker;

    /**
     * the cross optimizer used to reduce crosses
     */
    private CrossOptimizer m_optimizer;

    /**
     * the X coordinates assignator
     */
    private XSolver m_xsolver;

    /**
     * the Y coordinates assignator
     */
    private YSolver m_ysolver;

    /**
     * the edge router
     */
    private EdgeRouter m_router;

    /**
     * only for debug output
     */
//    private PrintWriter debugout;

    public Layouter(LayoutGraph g) {
        m_gGraph = g;
        m_config = new Config();
        m_ranker = new Ranker();
        m_optimizer = new CrossOptimizer();
        m_xsolver = new XSolver();
        m_ysolver = new YSolver();
        m_router = new EdgeRouter();

//        try {
//            File temp = File.createTempFile("Con_Debug", ".txt", new File(
//                    "E:\\Study\\Aachen\\CBase\\ConceptBase\\debug\\"));
//            debugout = new PrintWriter(new FileOutputStream(temp));
//        } catch (IOException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
    }

    /**
     * @return Returns the m_minNodeDistance.
     */
    public double getMinNodeDistance() {
        return m_minNodeDistance;
    }

    /**
     * @param nodeDistance
     *            The m_minNodeDistance to set.
     */
    public void setMinNodeDistance(double nodeDistance) {
        m_minNodeDistance = nodeDistance;
    }

    /**
     * @return Returns the m_minRankDistance.
     */
    public double getMinRankDistance() {
        return m_minRankDistance;
    }

    /**
     * @param rankDistance
     *            The m_minRankDistance to set.
     */
    public void setMinRankDistance(double rankDistance) {
        m_minRankDistance = rankDistance;
    }

    public void doIncrementalLayout() {
        m_config.executeDeletion(m_gGraph);
        
//        debugout.println("After deletion (Main Graph)=====================");
//        m_gGraph.printGraph(debugout);
//        debugout.println();
//        debugout.println("After deletion (Con Graph)=====================");
//        m_config.print(debugout);
//        debugout.println();

        m_ranker.ranking(m_gGraph);

//        debugout.println("After ranking (Main Graph)=====================");
//        m_gGraph.printGraph(debugout);
//        debugout.println();

        m_config.updateConGraph(m_gGraph);

//        debugout.println("After update (Con Graph)=====================");
//        m_config.print(debugout);
//        debugout.println();

        m_optimizer.reOrder(m_config);
        m_config.fixNodes();

//        debugout.println("After optimize (Main Graph)=====================");
//        m_gGraph.printGraph(debugout);
//        debugout.println();
//        debugout.println("After optimize (Con Graph)=====================");
//        m_config.print(debugout);
//        debugout.println();
        m_config.updateNodes();
        
        m_xsolver.place(m_config, m_minNodeDistance);

        m_ysolver.place(m_config, m_minRankDistance);

        m_router.routeEdge(m_gGraph);

    }
}