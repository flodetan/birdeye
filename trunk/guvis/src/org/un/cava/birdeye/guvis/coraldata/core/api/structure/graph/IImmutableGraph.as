/*  
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 *
 * Author: Anselm Bradford (http://anselmbradford.com)
 * The coraldata data structure library was originally inspired by and adopted 
 * from JDSL (http://www.jdsl.org), any remaining similarities in architecture are 
 * credited to the respective authors in the JDSL classes.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
 * SVN propsets
 *
 * $HeadURL$
 * $LastChangedBy$
 * $Date$
 * $Revision$
 */

package org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph
{
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.IImmutablePositionalCollection;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	
	/**
	 * An interface describing methods for retrieving details of a graph. Provides 
	 * no methods for manipulating a graph structure.
	 *
	 */
	public interface IImmutableGraph extends IImmutablePositionalCollection 
	{
	  /**
	   * @return the number of getVertices
	   */
	  function numVertices() : int;
	
	  /**
	   * @return the number of edges
	   */
	  function numEdges() : int;
	
	  /**
	   * @return an iterator over all getVertices in the graph
	   */
	  function getVertices() : IIterator;
	
	  /**
	   * Retrieve a random vertex from the graph.
	   * @e Edge must be connected to vertex
	   * @return an arbitrary vertex
	   */
	  function aVertex( e:IEdge = null ) : IVertex;
	
	  /**
	   * @param The type of edge to return. Supply a constant in the <code>EdgeType</code>
	   * class. Default is <code>EdgeType.ALL</code>.
	   * @return an iterator over the edges of this graph.
	   * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType
	   */
	  function getEdges( incidentTo:IVertex = null , edgeType:int = EdgeType.ALL ) : IIterator;
	
	  /**
	  	* @param ofType restrict to a certain type
	  	* @param v Endpoint of the returned edge
	   * @return an arbitrary edge
	   */
	  function anEdge( ofType:int = EdgeType.ALL , v:IVertex = null ) : IEdge;	
	  	
	  /* edge methods */
	
	  /**
	   * @param e an edge
	   * @param v one endvertex of <code>e</code>. If supplied vertex is null the origin of the edge
	   * is used by default, which will always return <code>EdgeType.OUT</code> if the edge is 
	   * directed.
	   * @return the type ID of the supplied edge.
	   * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType
	   */
	  function getEdgeType ( e:IEdge , v:IVertex = null ) : int;
	
	  /**
	   * @param e an edge
	   * @return the origin vertex of <code>e</code>, if <code>e</code> is directed
	   */
	  function getEdgeOrigin ( e:IEdge ) : IVertex;
	
	  /**
	   * @param e an edge
	   * @return the destination vertex of <code>e</code>, if
	   * <code>e</code> is directed 
	   */
	  function getEdgeDestination ( e:IEdge ) : IVertex;	
	
	  /* direction methods */
	
	  /**
	   * @param e an edge
	   * @return <code>true</code> if <code>e</code> is directed,
	   * <code>false</code> otherwise
	   */
	  function isEdgeDirected ( e:IEdge ) : Boolean;
	
		/**
		 * @param v a vertex
		 * @param e an edge
		 * @return whether <code>v</code> and <code>e</code> are incident,
		 * e.g., whether <code>v</code> is an end vertex of <code>e</code>.
		 */
	  	function areIncident( v:IVertex , e:IEdge ) : Boolean;
		
		/**
		* Whether this edge is a self-loop edge or not.
		* @return True if this is a self-loop edge, false otherwise.
		*/
		function isEdgeSelfLoop( e:IEdge ) : Boolean;
	}
}