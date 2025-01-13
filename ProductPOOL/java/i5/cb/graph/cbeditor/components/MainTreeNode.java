/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
package i5.cb.graph.cbeditor.components;

import i5.cb.graph.cbeditor.CBQuery;

import javax.swing.tree.DefaultMutableTreeNode;

/** This class contains the queries' results as childnodes in the componentview's JTree
 * It may either contain a query itself (in this case the query's results will appear as direct children)
 * or it contains one or two childnodes (also MainTreeNode instances) which contain a query by themselfs
 * (i.e. there may be one layer between the MainTreeNode closest to root and the results of a query)
 */
public class MainTreeNode extends DefaultMutableTreeNode {
    
    private static final String ALL_LABEL = "All";
    
    private static final String EXPLICIT_LABEL = "explicit";
    
    private MainTreeNode m_nExplicitChild = null;
    
    private MainTreeNode m_nAllChild = null;
    
    
    private CBQuery m_cbQuery;
    
    private DefaultMutableTreeNode m_dummyNode = null;
    
    public MainTreeNode(CBQuery cbQuery) {
        super(cbQuery);
        m_cbQuery = cbQuery;
        m_dummyNode = new DefaultMutableTreeNode();
        this.add(m_dummyNode);
        
    }
    
    /** This constructor is used when this node shall have an explicit and/or All childnode which are suppused to contain the actual queries
     * @param sLabel
     */
    public MainTreeNode(java.lang.String sLabel) {
        super(sLabel);
        m_dummyNode = new DefaultMutableTreeNode();
        this.add(m_dummyNode);
    }
    
    void setAllChild(CBQuery AllQuery) {
        
        if(AllQuery == null) {
            if(isNodeChild(m_nAllChild) ){
                remove(m_nAllChild);
            }
            m_nAllChild = null;
        }
        else {
            assert !this.hasQuery() : "CBTree$MainTreeNode.setAllChild: this instance of MainTreeNode has already a query itself";
            
            m_nAllChild = new MainTreeNode( ALL_LABEL );
            m_nAllChild.setQuery(AllQuery);
            
            if(!isNodeChild(m_nAllChild) ){
                insert(m_nAllChild, 0);
            }
            if(isNodeChild(m_dummyNode) ){
                remove(m_dummyNode);
            }
        }
    }
    
    void setExplicitChild(CBQuery explicitQuery) {
        if(explicitQuery == null) {
            if(isNodeChild(m_nExplicitChild) ){
                remove(m_nExplicitChild);
            }
            m_nExplicitChild = null;
        }
        else {
            assert !this.hasQuery() : "CBTree$MainTreeNode.setExplicitChild: this instance of MainTreeNode has already a query itself";
            
            if(isNodeChild(m_dummyNode) ){
                remove(m_dummyNode);
            }
            
            m_nExplicitChild = new MainTreeNode( EXPLICIT_LABEL );
            m_nExplicitChild.setQuery( explicitQuery );
                       
            if( !isNodeChild(m_nExplicitChild) ){
                insert(m_nExplicitChild, 0);
            }
        }
    }
    
    CBQuery getQuery() {
        return m_cbQuery;
    }
    
    void setQuery(CBQuery cbQuery){
        assert !(this.hasExplicitChild() || this.hasAllChild() ) : "A MainTreeNode may not have a query *and* one of explicit or All child";
        m_cbQuery = cbQuery;
    }
    
    boolean hasQuery() {
        return m_cbQuery != null;
    }
    
    boolean hasAllChild() {
        return m_nAllChild != null;
    }
    
    boolean hasExplicitChild() {
        return m_nExplicitChild != null;
    }
    
    MainTreeNode getExplicitChild() {
        return m_nExplicitChild;
    }
    
    MainTreeNode getAllChild() {
        return m_nAllChild;
    }
    
    boolean hasDummy() {
        return this.isNodeChild(m_dummyNode);
    }
    
    void removeDummy() {
        remove(m_dummyNode);
    }
    
}

