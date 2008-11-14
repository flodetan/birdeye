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

package org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph
{	
	import org.un.cava.birdeye.guvis.coraldata.core.impl.iterator.ArrayIterator;
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.*;
	import org.un.cava.birdeye.guvis.coraldata.core.api.iterator.IIterator;
	
	/*
	import org.un.cava.birdeye.guvis.coraldata.core.api.structure.tree.IImmutableTree;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.tree.OrderedTree;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.traversal.strategy.GenerateTreeStrategy;
	import org.un.cava.birdeye.guvis.coraldata.core.impl.structure.graph.traversal.algorithm.DFS;
	*/
	
	/**
	 * A static final class of utility methods for operating on a graph.
	 */
	public final class GraphUtil 
	{
		/*----------------------------------------------------------------------
		* public methods
		*---------------------------------------------------------------------*/    		

		/**
		 * Gives the degree (number connected edges) of a vertex, counting all edges of the 
		 * specified type.
	  	 *
		 * @param v a vertex
		 * @param edgeType A constant from the <code>EdgeType</code> static class.
		 * Default is <code>EdgeType.ALL</code>.
		 * @return the number of edges of the specified type incident with <code>v</code>
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType
		 */
		public static function getVertexDegree( v:IVertex , edgeType:int = EdgeType.ALL ) : int
		{
			var it:IIterator = IGraph(v.collection).getEdges( v , edgeType );
			return it.size();
		}
		
		/**
		 * All vertices on the other end of edges of a certain type connected to 
		 * this vertex.
		 * @param v a vertex
		 * @param edgeType A constant from the <code>EdgeType</code> static class.
		 * @return An iterator over the incident vertices.
		 * @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType
		 */
		public static function adjacentVertices( v:IVertex , edgeType:int = EdgeType.ALL ) : IIterator
		{
			var accum:Array = new Array();
			var graph:IGraph = IGraph(v.collection);
			var it:IIterator = graph.getEdges( v , edgeType );
			
			while( it.hasNext() )
			{
				if (!graph.isEdgeSelfLoop(IEdge(it.next()))) accum.push( GraphUtil.getOppositeVertex(v,IEdge(it.current())) );
			}
						
			return new ArrayIterator(accum);
		}

		/**
	     * Checks whether two edges have at least one common endpoint. 
	     * (For example, parallel edges are considered adjacent, as are
	     * two self-loops incident on a single vertex.)
	     * @param e1 an edge
	     * @param e2 an edge
	     * @return whether <code>e1</code> and <code>e2</code> are adjacent,
	     * i.e., whether they have at least one common end vertex
	     */
		public static function areAdjacentEdges( e1:IEdge , e2:IEdge ) : Boolean
		{
			var g1:IGraph = IGraph(e1.collection);
			var g2:IGraph = IGraph(e2.collection);
			
			var ev1o:IVertex = g1.getEdgeOrigin(e1);
			var ev1d:IVertex = g1.getEdgeDestination(e1);

			var ev2o:IVertex = g2.getEdgeOrigin(e2);
			var ev2d:IVertex = g2.getEdgeDestination(e2);

			return ( ev1o == ev2o || ev1o == ev2d || ev1d == ev2o || ev1d == ev2d );
		}

		/**
		 * @param v1 a vertex
	     * @param v2 a vertex
	     * @return whether <code>v1</code> and <code>v2</code> are adjacent,
	     * e.g., whether they are the end vertices of a common edge.
		 */
		public static function areAdjacentVertices( v1:IVertex , v2:IVertex ) : Boolean
		{
			var g1:IGraph = IGraph(v1.collection);
			var g2:IGraph = IGraph(v2.collection);
			if( GraphUtil.getVertexDegree(v1) < GraphUtil.getVertexDegree(v2) ) 
			{
				var edges:IIterator = g1.getEdges(v1);
				while(edges.hasNext()) 
				{
					if( GraphUtil.getOppositeVertex( v1 , IEdge(edges.next()) ) == v2 ) 
					{
						return true;
					}
				}
				return false;
			}
			else {
				edges = g2.getEdges(v2);
				while(edges.hasNext()) 
				{
					if( GraphUtil.getOppositeVertex( v2 , IEdge(edges.next()) ) == v1 ) 
					{
						return true;
					}
				}
				return false;
			}
		}
	
		/**
	     * Gives all edges connecting two vertices.  If <code>v1==v2</code>,
	     * gives all self-loops of the vertex, each reported twice.
	     * @param v1 a vertex
	     * @param v2 a vertex
	     * @return an iterator over the edges in common between
	     * <code>v1</code> and <code>v2</code> 
		 */
		public static function connectingEdges( v1:IVertex , v2:IVertex ) : IIterator
		{
			var edges:IIterator;
			var accum:Array = new Array();
			var e:IEdge;
			var g1:IGraph = IGraph(v1.collection);
			var g2:IGraph = IGraph(v2.collection);
			if( GraphUtil.getVertexDegree(v1) < GraphUtil.getVertexDegree(v2) ) 
			{
				edges = g1.getEdges(v1);
				while(edges.hasNext()) 
				{
					e = edges.next() as IEdge;
					if(GraphUtil.getOppositeVertex(v1,e) == v2) accum.push(e);
				}
			}
			else 
			{
				edges = g2.getEdges(v2);
				while(edges.hasNext()) 
				{
					e = edges.next() as IEdge;
					if(GraphUtil.getOppositeVertex(v2,e) == v1) accum.push(e);
				}
			}

			return new ArrayIterator(accum);
		}

		/**
		 * @param e1 an edge
		 * @param e2 an edge
		 * @return any vertex that is an endpoint of both <code>e1</code> and <code>e2</code>
		 */
		public static function aCommonVertex( e1:IEdge , e2:IEdge ) : IVertex
		{
			var g1:IGraph = IGraph(e1.collection);
			var g2:IGraph = IGraph(e2.collection);
			
			var ev1o:IVertex = g1.getEdgeOrigin(e1);
			var ev1d:IVertex = g1.getEdgeDestination(e1);
			
			var ev2o:IVertex = g2.getEdgeOrigin(e2);
			var ev2d:IVertex = g2.getEdgeDestination(e2);
			
			if (ev1o == ev2o || ev1o == ev2d) return ev1o;
			if (ev1d == ev2o || ev1d == ev2d) return ev1d;
		//	return Vertex.NONE;
			return undefined;
		}

		
		/** 
	     * Gives an arbitrary edge from among those connecting the two
	     * specified vertices.  If <code>v1==v2</code>, gives a self-loop
	     * of the vertex. 
	     * @param v1 a vertex
	     * @param v2 a vertex
	     * @return an edge between <code>v1</code> and <code>v2</code>.
		 */
		public static function aConnectingEdge( v1:IVertex , v2:IVertex ) : IEdge
		{
			var g:IGraph = IGraph(v1.collection);
			if( GraphUtil.getVertexDegree(v1) < GraphUtil.getVertexDegree(v2) ) 
			{
				var edges:IIterator = g.getEdges(v1);
				var e:IEdge;
				while(edges.hasNext()) 
				{
					e = edges.next() as IEdge;
					if(GraphUtil.getOppositeVertex(v1,e) == v2) return e;
				}
				//return Edge.NONE;
				return undefined;
			}
			else 
			{
				g = IGraph(v2.collection);
				edges = g.getEdges(v2);
				while(edges.hasNext()) 
				{
					e = edges.next() as IEdge;
					if(GraphUtil.getOppositeVertex(v2,e) == v1) return e;
				}
				//return Edge.NONE;
				return undefined;
			}
		}


		/**
		 * Attaches a new vertex, containing an element object, to an existing vertex
		 * by inserting a new edge.  This is equivalent to calling
		 * <code>addVertex(.)</code> followed by <code>addEdge(.)</code>.
		 * @param v a vertex
		 * @param vertexElement the object to be stored in <code>v</code>
		 * @param edgeElement the object to be stored in the new edge
		 * @return the new edge; to get the new vertex, use method
		 * <code>getOppositeVertex(v,e)</code>.
		 */
		public static function attachVertex( v:IVertex , vertexElement:Object , edgeElement:Object , edgeType:int = EdgeType.UNDIR ) : IEdge
		{
			var graph:IGraph = IGraph(v.collection);
			var returnVal:IEdge;
			var newv:IVertex;
			switch( edgeType )
			{
				case EdgeType.UNDIR : 
					newv = graph.addVertex( vertexElement );
					returnVal = graph.addEdge( v, newv, edgeElement, EdgeType.UNDIR );
				break;

				case EdgeType.OUT : 
					newv = graph.addVertex( vertexElement );
					returnVal = graph.addEdge( v, newv, edgeElement, EdgeType.OUT);
				break;

				case EdgeType.IN : 
					newv = graph.addVertex( vertexElement );
					returnVal = graph.addEdge( newv, v, edgeElement, EdgeType.IN);
				break;
				default:
					throw new Error( "Supplied edge type is not valid!" );
				break;
			}
			
			return returnVal;
		}
	
		/**
		 * Splits an existing edge by inserting a new vertex and two new edges,
		 * and removing the old edge.
		 * If the edge is directed, the two new edges maintain the
		 * direction.  The old edge is removed; its <code>element()</code>
		 * can still be retrieved.  
		 * @param e the edge to be split
		 * @param vertElement the object to be stored in the new vertex
		 * @param edgeElement1 the object to be stored in the first new edge
		 * @param edgeElement2 the object to be stored in the second new edge
		 * @return the new vertex <code>w</code>.
		 */
		public static function splitEdge ( e:IEdge , vertElement:Object , edgeElement1:Object , edgeElement2:Object ) : IVertex
		{
			var graph:IGraph = IGraph(e.collection);
			var newv:IVertex = graph.addVertex( vertElement );	
			var edgeType:int = graph.getEdgeType(e);
			
			// insert new edges between endpoints and new midpoint
			graph.addEdge( graph.getEdgeOrigin(e) , newv , edgeElement1 , edgeType );
			graph.addEdge( newv , graph.getEdgeDestination(e) , edgeElement2 , edgeType );
			
			// remove old edge, return new vertex
			graph.remove( e );

			return newv ;
		}
		
		/**
		* Transforms edge-vertex-edge into a single edge.  The vertex must
		* be of degree 2.  The edges and the vertex are removed (their
		* <code>element()s</code> can still be retrieved), and a new edge is 
		* inserted in their place.  The new edge stores the specified element.
		* <p>
		* If the two incident edges of <code>v</code>
		* are consistently directed, the new edge is directed in that
		* direction.  If they are both undirected, the new edge
		* is undirected.  Any other combination of directions also results in
		* an undirected edge.
		* 
		* @param v the vertex to be removed
		* @param edgeElement the element to be stored in the new edge
		* @return the new edge
		*/
		public static function unsplitEdge ( v:IVertex , edgeElement:Object ) : IEdge
		{
			var graph:IGraph = IGraph(v.collection);
		
			// make sure v's degree is right
			if(GraphUtil.getVertexDegree(v)!=2)
			{
				//throw new InvalidVertexException("trying to unsplitEdge on vertex of degree " + ilv.degree());
				throw new Error( "trying to unsplitEdge on vertex of degree" );
			}
			
			// get the 2 edges associated with v
			var edges:IIterator = graph.getEdges(v);
			var e1:IEdge = edges.next() as IEdge;
			var e2:IEdge = edges.next() as IEdge;
			
			// make sure this isn't a lone vertex with a self-loop
			if (e1==e2) throw new Error ("trying to unsplitEdge on a vertex with only a self-loop");
			var v1:IVertex = GraphUtil.getOppositeVertex(v, e1);
			var v2:IVertex = GraphUtil.getOppositeVertex(v, e2);
			
			// decide whether to direct the new edge (and if so, make sure
			// v1 is the origin of the new edge, swapping v1 and v2 if necessary).
			var isdirected:Boolean = false;
			if( graph.isEdgeDirected(e1) && graph.isEdgeDirected(e2) ) 
			{
				if( graph.getEdgeOrigin(e1)==graph.getEdgeOrigin(e2) || 
				graph.getEdgeDestination(e1)==graph.getEdgeDestination(e2) ) 
				{
					// the edges are inconsistently directed
					isdirected = false;
				}
				else 
				{
					isdirected = true;
					if( graph.getEdgeDestination(e1)==v1 ) 
					{
						var vtemp:IVertex = v1;
						v1 = v2;
						v2 = vtemp;
					}
				}
			}
			// else isdirected==false because e1 or e2 is undirected    
		
			// remove the old vertex and incident edges, and add an edge
			graph.remove(v);
			return graph.addEdge( v1, v2, edgeElement, (isdirected ? EdgeType.OUT : EdgeType.UNDIR) );
		}
		
		/**
		* @param vert The vertex to find the opposite of on the given edge.
		* @param edge The edge to examine
		* @return The opposite vertex of <code>vert</code>.
		*/
		public static function getOppositeVertex( vert:IVertex , edge:IEdge ) : IVertex
		{
			var g:IGraph = IGraph( edge.collection );

			var returnVal:IVertex;
			var endo:IVertex = g.getEdgeOrigin(edge);
			var endd:IVertex = g.getEdgeDestination(edge);

			if( endo == vert ) returnVal= endd;
			if( endd == vert ) returnVal= endo;
			
			return returnVal;
		}
		
		
		
		
		/**
		* returns the current BFS tree of the graph.
		* @param v The root node of the tree.
		*/
		/*
		public static function getTree(v:IVertex = null):IImmutableTree
		{
			var g:IGraph = IGraph(v.collection);
			if (v == null) v = g.aVertex();
			
			
			var search:DFS = new DFS( g , v );
			var result:GenerateTreeStrategy = search.execute( new GenerateTreeStrategy( OrderedTree ) ) as GenerateTreeStrategy;			
			
			return result.tree;
		}
		*/
			
	
	}
}