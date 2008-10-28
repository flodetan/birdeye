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
	/**
	 * An <code>IPosition</code>s that represents edges in a graph. 
	 */
	public interface IEdge extends IGraphPosition
	{
		/**
		* An endpoint of an edge. This specifies the originating endpoint in an
		* edge that is directed.
		* @return The originating vertex.
		*/
		function get origin() : IVertex;

		/**
		* An endpoint of an edge. This specifies the destination endpoint in an
		* edge that is directed.
		* @return The destination vertex.
		*/
		function get destination() : IVertex;

		/**
		* Swap the endpoints (the <code>origin</code> and 
		* <code>destination</code>) of an edge.
		*/
		function swapEndpoints() : void;
		
		/**
		* Find the vertex at the opposite end of an edge.
		* @param The vertex to find the opposite vertex of.
		* @return The opposite vertex of the given vertex.
		* @throw Error if the supplied vertex is not an endpoint of this edge.
		*/
		function opposite( v:IVertex ) : IVertex;
		
		/**
		* Whether this edge is directed or not.
		* @return True if this edge is directed, false otherwise.
		*/
		function isDirected() : Boolean;
		
		/**
		* Make this edge directed.
		*/
		function makeDirected() : void;

		/**
		* Make this edge undirected.
		*/		
		function makeUndirected() : void;
		
		/**
		* Return the type of this edge relative to the vertex specified. 
		* Can be undirected, incoming, or outgoing. 
		* Integer value can be compared to 
		* that in the static final class <code>EdgeType</code>
		* @return The integer specifying what type this edge is
		* @see org.un.cava.birdeye.guvis.coraldata.core.api.structure.graph.EdgeType
		*/
		function getType( endpoint:IVertex ) : int;
				
		/**
		* Whether is edge is a self-loop edge or not.
		* @return True if this is a self-loop edge, false otherwise.
		*/
		function isSelfLoop() : Boolean;
	}
}